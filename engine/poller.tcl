# Matchday - engine/poller.tcl
# Adaptive polling of the competitions somebody cares about.
#
# The watch set is the union of: channel leagues, followed leagues,
# competitions where followed teams play soon, narrated/predicted
# matches, temporary watches and conf(leagues.always).
#
# Interval per competition: live matches -> poll.live (30s); kick-off
# within 15 min or just finished -> poll.soon (60s); otherwise sleep until
# shortly before the next kick-off, capped at poll.idle (15 min).

namespace eval ::md::poll {
    variable L        ;# lkey -> dict {next inflight fails lastlive lastok n}
    variable M        ;# uid -> latest match snapshot
    variable byL      ;# lkey -> uids in last scoreboard
    variable temp     ;# lkey -> expiry epoch (temporary watch)
    array set L {}
    array set M {}
    array set byL {}
    array set temp {}
}

# ---------------------------------------------------------------- hooks

namespace eval ::md::hook {
    variable H
    array set H {}
}
proc ::md::hook::add {name cmd} {
    variable H
    if {![info exists H($name)] || $cmd ni $H($name)} { lappend H($name) $cmd }
}
proc ::md::hook::run {name args} {
    variable H
    if {![info exists H($name)]} return
    foreach cmd $H($name) {
        if {[catch {uplevel #0 [concat $cmd $args]} err opts]} {
            ::md::log error "hook $name ($cmd): $err"
            ::md::log debug [dict get $opts -errorinfo]
        }
    }
}
# collect: each hook returns a list; results concatenated
proc ::md::hook::collect {name args} {
    variable H
    set out {}
    if {![info exists H($name)]} { return $out }
    foreach cmd $H($name) {
        if {[catch {uplevel #0 [concat $cmd $args]} r]} {
            ::md::log error "hook $name ($cmd): $r"
        } else {
            lappend out {*}$r
        }
    }
    return $out
}

# ---------------------------------------------------------------- provider routing

namespace eval ::md::prov {}

# Which provider serves a feature for a competition
proc ::md::prov::for {lkey feature} {
    set sport [::md::catalog::get $lkey sport]
    if {$sport eq "soccer" && [::md::cfg apifootball.key ""] ne "" && [::md::catalog::get $lkey af] ne ""} {
        set mode [::md::cfg apifootball.mode extras]
        if {$mode eq "primary"} { return apifootball }
        if {$mode eq "extras" && $feature in {h2h}} { return apifootball }
    }
    return espn
}

proc ::md::prov::call {feature lkey args} {
    set p [for $lkey $feature]
    if {[info commands ::md::${p}::$feature] eq ""} { set p espn }
    ::md::${p}::$feature $lkey {*}$args
}

# ---------------------------------------------------------------- watch set

proc ::md::poll::watch {lkey {secs 3600}} {
    variable temp
    set until [expr {[clock seconds] + $secs}]
    if {![info exists temp($lkey)] || $temp($lkey) < $until} { set temp($lkey) $until }
    # poll soon
    variable L
    if {[info exists L($lkey)] && ![dict get $L($lkey) inflight]} {
        dict set L($lkey) next [expr {min([dict get $L($lkey) next], [clock seconds] + 2)}]
    }
}

proc ::md::poll::watched {} {
    variable temp
    set now [clock seconds]
    set set [::md::cfg leagues.always {}]
    foreach k [array names temp] {
        if {$temp($k) < $now} { unset temp($k) } else { lappend set $k }
    }
    lappend set {*}[::md::hook::collect leagues]
    set out {}
    foreach k [::md::luniq $set] {
        if {[::md::catalog::get $k path] ne ""} { lappend out $k }
    }
    return $out
}

# ---------------------------------------------------------------- loop

proc ::md::poll::init {} {
    ::md::every poll.tick [expr {[::md::cfg poll.tick 5] * 1000}] ::md::poll::tick
    ::md::every poll.gc 3600000 ::md::poll::gc
}

proc ::md::poll::tick {} {
    variable L
    set now [clock seconds]
    set want [watched]
    set maxpar [::md::cfg poll.max_parallel 3]
    set busy 0
    foreach k [array names L] {
        if {[dict get $L($k) inflight]} { incr busy }
        if {$k ni $want && ![dict get $L($k) inflight]} { unset L($k) }
    }
    foreach k $want {
        if {![info exists L($k)]} {
            set L($k) [dict create next $now inflight 0 fails 0 lastlive 0 lastok 0 n 0]
        }
        if {[dict get $L($k) inflight] || [dict get $L($k) next] > $now} continue
        if {$busy >= $maxpar} break
        incr busy
        fetch $k
    }
}

proc ::md::poll::fetch {lkey} {
    variable L
    dict set L($lkey) inflight 1
    dict set L($lkey) started [clock seconds]
    if {[catch {::md::prov::call scoreboard $lkey "" [list ::md::poll::_got $lkey]} err]} {
        ::md::log error "poll $lkey: $err"
        _got $lkey error $err
    }
}

proc ::md::poll::_got {lkey status data} {
    variable L
    variable M
    variable byL
    set now [clock seconds]
    if {![info exists L($lkey)]} {
        set L($lkey) [dict create next $now inflight 0 fails 0 lastlive 0 lastok 0 n 0]
    }
    dict set L($lkey) inflight 0
    if {$status ne "ok"} {
        set f [expr {[dict get $L($lkey) fails] + 1}]
        dict set L($lkey) fails $f
        dict set L($lkey) error $data
        dict set L($lkey) next [expr {$now + min(900, 30 * (1 << min($f, 5)))}]
        ::md::log [expr {$f >= 3 ? "warn" : "debug"}] "scoreboard $lkey failed ($f): $data"
        return
    }
    dict set L($lkey) fails 0
    dict set L($lkey) lastok $now
    dict unset L($lkey) error
    set uids {}
    set live 0
    foreach m $data {
        set uid [dict get $m uid]
        lappend uids $uid
        set old [expr {[info exists M($uid)] ? $M($uid) : ""}]
        set evs [::md::diff::run $old $m]
        set M($uid) $m
        if {[dict get $m state] eq "in"} { set live 1 }
        if {[llength $evs]} {
            ::md::dispatch::emit $m $evs
        }
    }
    set byL($lkey) $uids
    if {$live} { dict set L($lkey) lastlive $now }
    dict set L($lkey) n [llength $uids]
    dict set L($lkey) next [expr {$now + [interval $lkey $data]}]
    ::md::hook::run scoreboard $lkey $data
}

proc ::md::poll::interval {lkey matches} {
    variable L
    set now [clock seconds]
    set live [::md::cfg poll.live 30]
    set soon [::md::cfg poll.soon 60]
    set idle [::md::cfg poll.idle 900]
    set next ""
    foreach m $matches {
        set st [dict get $m state]
        if {$st eq "in"} { return [_jitter $live] }
        if {$st eq "pre" && [dict get $m code] ni {postponed cancelled}} {
            set dt [expr {[dict get $m start] - $now}]
            if {$dt < 900} { return [_jitter $soon] }
            if {$next eq "" || $dt < $next} { set next $dt }
        }
    }
    # just finished: keep checking for corrections for 10 minutes
    if {$now - [dict get $L($lkey) lastlive] < 600} { return [_jitter $soon] }
    if {$next ne ""} { return [_jitter [expr {max($soon, min($idle, $next - 600))}]] }
    return [_jitter $idle]
}

proc ::md::poll::_jitter {s} {
    expr {max(10, int($s * (0.92 + rand() * 0.16)))}
}

# ---------------------------------------------------------------- queries

proc ::md::poll::match {uid} {
    variable M
    if {[info exists M($uid)]} { return $M($uid) }
    return ""
}

proc ::md::poll::store {m} {
    variable M
    set uid [dict get $m uid]
    if {![info exists M($uid)] || [dict get $m updated] >= [dict get $M($uid) updated]} {
        set M($uid) $m
    }
}

# All known matches, optionally filtered by league list and/or state list
proc ::md::poll::matches {{lkeys ""} {states ""}} {
    variable M
    set out {}
    foreach uid [array names M] {
        set m $M($uid)
        if {$lkeys ne "" && [dict get $m lkey] ni $lkeys} continue
        if {$states ne "" && [dict get $m state] ni $states} continue
        lappend out $m
    }
    sortm $out
}

proc ::md::poll::sortm {list} {
    lsort -command {apply {{x y} {
        set a [dict get $x start]; set b [dict get $y start]
        if {$a != $b} { return [expr {$a < $b ? -1 : 1}] }
        string compare [dict get $x uid] [dict get $y uid]
    }}} $list
}

proc ::md::poll::league_status {} {
    variable L
    set out {}
    foreach k [lsort [array names L]] {
        set d $L($k)
        lappend out [dict create lkey $k next [expr {[dict get $d next] - [clock seconds]}] \
            fails [dict get $d fails] n [dict get $d n] \
            live [expr {[clock seconds] - [dict get $d lastlive] < 60}] \
            error [::md::dg $d "" error]]
    }
    return $out
}

# Keep yesterday's matches for result queries, drop older ones
proc ::md::poll::gc {} {
    variable M
    set cutoff [expr {[clock seconds] - [::md::cfg poll.keep_hours 36] * 3600}]
    set keep [::md::hook::collect keep_uids]
    foreach uid [array names M] {
        set m $M($uid)
        if {[dict get $m state] ne "in" && [dict get $m start] < $cutoff && $uid ni $keep} {
            unset M($uid)
        }
    }
    ::md::diff::gc
}

# Persistence of snapshots + diff memory so restarts are seamless
proc ::md::poll::save {} {
    variable M
    set snap {}
    set cutoff [expr {[clock seconds] - 86400}]
    foreach uid [array names M] {
        set m $M($uid)
        if {[dict get $m start] >= $cutoff || [dict get $m state] eq "in"} {
            dict set snap $uid $m
        }
    }
    set ::md::db(state) [dict create saved [clock seconds] matches $snap diff [::md::diff::export]]
    ::md::store::mark state
}

proc ::md::poll::restore {} {
    variable M
    set d [::md::store::load state]
    set age [expr {[clock seconds] - [::md::dg $d 0 saved]}]
    # after a long downtime, absorb current state silently instead of
    # announcing goals that happened an hour ago as if they were new
    if {$age <= [::md::cfg poll.restore_max_age 900]} {
        ::md::diff::import [::md::dg $d {} diff]
    }
    dict for {uid m} [::md::dg $d {} matches] { set M($uid) $m }
    if {$age < 86400} {
        ::md::log info "restored [dict size [::md::dg $d {} matches]] matches (state ${age}s old)"
    }
}
