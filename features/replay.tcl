# Matchday - features/replay.tcl
# Replays a finished real match through the narrator at accelerated
# speed. Great to demo/test the bot in a channel any day of the week.
#
#   !md replay <league> <espnEventId> [speed] [#chan]
#   !md demo [#chan]        picks the most eventful finished match cached

namespace eval ::md::replay {
    variable R
    array set R {}
}

proc ::md::replay::c_replay {ctx sub argv} {
    set target [dict get $ctx chan]
    if {[string index [lindex $argv end] 0] eq "#"} {
        set target [lindex $argv end]
        set argv [lrange $argv 0 end-1]
    }
    if {$target eq ""} { set target [dict get $ctx nick] }
    set speed [::md::cfg replay.speed 30]
    if {$sub eq "demo"} {
        set best ""
        set bestn -1
        foreach m [::md::poll::matches "" post] {
            if {[dict get $m sport] ne "soccer" || [dict get $m code] ni {ft aet pens}} continue
            set n [llength [dict get $m events]]
            if {$n > $bestn} { set bestn $n; set best $m }
        }
        if {$best eq ""} {
            ::md::reply $ctx "No finished soccer match cached yet. Use: replay <league> <eventId> \[speed\] \[#chan\]"
            return
        }
        set lk [dict get $best lkey]
        set eid [dict get $best eid]
    } else {
        if {[llength $argv] < 2} { ::md::reply $ctx "replay <league> <eventId> \[speed\] \[#chan\]"; return }
        set lk [::md::catalog::find [lindex $argv 0]]
        set eid [lindex $argv 1]
        if {$lk eq "" || ![string is digit -strict $eid]} { ::md::reply $ctx "bad league or event id"; return }
        if {[llength $argv] > 2 && [string is integer -strict [lindex $argv 2]]} { set speed [lindex $argv 2] }
    }
    set speed [::md::clamp $speed 1 600]
    ::md::espn::summary $lk $eid [list ::md::replay::_got $ctx $target $lk $eid $speed] 600
}

proc ::md::replay::_got {ctx target lk eid speed status r} {
    variable R
    if {$status ne "ok"} { ::md::cmd::err $ctx err.provider; return }
    set m [dict get $r match]
    if {[dict get $m state] ne "post"} {
        ::md::reply $ctx "That match has not finished; narrate it live instead."
        return
    }
    # timeline: key events and commentary, in feed order, with a sim time
    set items {}
    set i 0
    foreach k [dict get $r keyev] {
        lappend items [list [_simt [::md::narr::ord [dict get $k min] [dict get $k clock]] [dict get $k period] [dict get $k type]] [incr i] k $k]
    }
    foreach c [dict get $r comm] {
        set o [::md::narr::ord [dict get $c min] [dict get $c clock]]
        # added time of the first half ("45+2'") still belongs to period 1
        set p [expr {[dict get $c clock] > 2700 ? 2 : 1}]
        lappend items [list [_simt $o $p ""] [incr i] c $c]
    }
    set items [lsort -integer -index 0 [lsort -integer -index 1 $items]]
    set uid "replay:$lk:$eid:[clock seconds]"
    set pm [dict replace $m uid $uid lkey $lk lname [::md::catalog::label $lk] state pre code scheduled \
        minute "" start [expr {[clock seconds] + 30}] events {}]
    dict set pm home score 0
    dict set pm away score 0
    dict set pm home so ""
    dict set pm away so ""
    set kind [expr {[string index $target 0] eq "#" ? "chan" : "user"}]
    set lang [expr {$kind eq "chan" ? [::md::chan::lang $target] : [dict get $ctx ulang]}]
    set id [::md::narr::start $target $kind [dict get $ctx nick] $pm full $lang 1]
    set R($id) [dict create items $items pos 0 t -120 full $r final $m pm $pm lk $lk speed $speed]
    ::md::narr::say $::md::narr::S($id) "{c:warn}[::md::t $lang replay.banner teams [::md::render::teams $m] speed $speed]{/c}"
    # pre-match feed (intro/lineups) then start the clock
    _feed $id
    ::md::timer replay.$id 3000 [list ::md::replay::tick $id]
}

# map match clock to a monotonic sim time; half-time break = 5 sim minutes
proc ::md::replay::_simt {clock period type} {
    if {$type eq "kickoff"} { return 0 }
    if {$period >= 2} { return [expr {$clock + 300 + ($period >= 3 ? 300 : 0)}] }
    return $clock
}

proc ::md::replay::tick {id} {
    variable R
    if {![info exists R($id)] || ![info exists ::md::narr::S($id)]} {
        unset -nocomplain R($id)
        return
    }
    dict incr R($id) t 60
    _feed $id
    set d $R($id)
    if {[dict get $d pos] >= [llength [dict get $d items]] && [dict get $d t] > 0} {
        # final whistle: hand the real final state to the narrator
        set m [dict get $d final]
        dict set m uid [dict get [dict get $d pm] uid]
        dict set m lkey [dict get $d lk]
        set r [dict get $d full]
        dict set r match $m
        dict set r keyev [_upto [dict get $d items] [dict get $d pos] k]
        dict set r comm [_upto [dict get $d items] [dict get $d pos] c]
        _push $id $r
        unset R($id)
        return
    }
    set ms [expr {max([::md::cfg replay.min_tick 200], 60000 / [dict get $d speed])}]
    ::md::timer replay.$id $ms [list ::md::replay::tick $id]
}

proc ::md::replay::_upto {items pos kind} {
    set out {}
    foreach it [lrange $items 0 [expr {$pos - 1}]] {
        if {[lindex $it 2] eq $kind} { lappend out [lindex $it 3] }
    }
    return $out
}

proc ::md::replay::_feed {id} {
    variable R
    set d $R($id)
    set items [dict get $d items]
    set pos [dict get $d pos]
    set t [dict get $d t]
    set m [dict get $d pm]
    while {$pos < [llength $items] && [lindex $items $pos 0] <= $t && $t >= 0} { incr pos }
    dict set R($id) pos $pos
    # state & minute of the simulated match
    if {$t < 0} {
        dict set m state pre
        dict set m code scheduled
    } else {
        dict set m state in
        dict set m code live
        set last [lindex $items [expr {$pos - 1}] 3]
        set min [::md::dg $last "" min]
        if {$min ne ""} { dict set m minute $min }
        if {$pos > 0 && [::md::dg $last "" type] eq "halftime"} { dict set m code ht }
    }
    dict set R($id) pm $m
    set r [dict get $d full]
    dict set r match $m
    dict set r keyev [_upto $items $pos k]
    dict set r comm [_upto $items $pos c]
    _push $id $r
}

proc ::md::replay::_push {id r} {
    set m [dict get $r match]
    dict set ::md::narr::S($id) snap $m
    ::md::narr::_sum $id ok $r
}

proc ::md::replay::stop_all {} {
    variable R
    foreach id [array names R] { ::md::cancel replay.$id }
    array unset R
}
