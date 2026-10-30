# Matchday - engine/diff.tcl
# Turns consecutive snapshots of a match into discrete events.
#
# Per-match memory lives in ::md::diff::st(uid) and is persisted, so a
# restart never re-announces old goals. The first time a match is seen
# its current state is absorbed silently.
#
# Emitted event dicts always have: type uid  (+ type-specific fields)
#   kickoff ht 2h et shootout ft postponed cancelled abandoned suspended
#   delayed resumed goal scorer disallowed card penmiss so period_end ot
#   score close set leader

namespace eval ::md::diff {
    variable st
    array set st {}
}

proc ::md::diff::_int {v} {
    if {[string is integer -strict $v]} { return $v }
    if {[string is double -strict $v]} { return [expr {int($v)}] }
    return ""
}

proc ::md::diff::_sc {m side} {
    _int [dict get $m [expr {$side eq "h" ? "home" : "away"}] score]
}

proc ::md::diff::other {side} { expr {$side eq "h" ? "a" : "h"} }

# Build fresh memory from a snapshot (nothing announced)
proc ::md::diff::absorb {m} {
    variable st
    set uid [dict get $m uid]
    set seen {}
    set gkeys {}
    set scorers {}
    foreach e [dict get $m events] {
        dict set seen [dict get $e k] 1
        if {[dict get $e type] in {goal pen og}} {
            dict set gkeys [dict get $e k] 1
            if {[dict get $e type] ne "og" && [dict get $e player] ne ""} {
                dict incr scorers [dict get $e player]
            }
        }
    }
    set h [_sc $m h]; set a [_sc $m a]
    set flags {}
    if {[dict get $m state] ne "pre"} { dict set flags kickoff 1 }
    if {[dict get $m state] eq "post"} { dict set flags ft 1 }
    if {[dict get $m code] eq "ht"} { dict set flags ht[dict get $m period] 1 }
    set st($uid) [dict create seen $seen gkeys $gkeys scorers $scorers \
        goals [dict create h [expr {$h eq "" ? 0 : $h}] a [expr {$a eq "" ? 0 : $a}]] \
        anon {h 0 a 0} trailed {h 0 a 0} flags $flags sets 0 leader "" \
        code [dict get $m code] period [dict get $m period] ts [clock seconds]]
    if {[dict exists $m results] && [llength [dict get $m results]]} {
        dict set st($uid) leader [dict get [lindex [dict get $m results] 0] name]
    }
    if {[dict get $m kind] eq "duel"} {
        dict set st($uid) sets [_sets_done $m]
    }
    return {}
}

proc ::md::diff::forget {uid} {
    variable st
    unset -nocomplain st($uid)
}

proc ::md::diff::known {uid} {
    variable st
    info exists st($uid)
}

# Main entry: compare previous snapshot (may be "") with the new one.
proc ::md::diff::run {old new} {
    variable st
    set uid [dict get $new uid]
    if {![info exists st($uid)]} {
        return [absorb $new]
    }
    if {$old eq ""} { set old $new }
    set ev {}
    switch -- [dict get $new kind] {
        race { set ev [_race $old $new] }
        duel { set ev [_duel $old $new] }
        default {
            if {[dict get $new sport] eq "soccer"} {
                set ev [_soccer $old $new]
            } else {
                set ev [_teamsport $old $new]
            }
        }
    }
    dict set st($uid) code [dict get $new code]
    dict set st($uid) period [dict get $new period]
    dict set st($uid) ts [clock seconds]
    set out {}
    foreach e $ev { lappend out [dict merge [dict create uid $uid] $e] }
    return $out
}

proc ::md::diff::_flag {uid name} {
    variable st
    if {[dict exists $st($uid) flags $name]} { return 1 }
    dict set st($uid) flags $name 1
    return 0
}

proc ::md::diff::_unflag {uid name} {
    variable st
    dict unset st($uid) flags $name
}

# Common status transitions for all kinds
proc ::md::diff::_status {old new} {
    variable st
    set uid [dict get $new uid]
    set ev {}
    set os [dict get $old state]; set ns [dict get $new state]
    set oc [dict get $st($uid) code]; set nc [dict get $new code]

    if {$nc in {postponed cancelled abandoned} && $oc ne $nc} {
        if {![_flag $uid $nc]} { lappend ev [dict create type $nc] }
        return $ev
    }
    if {$nc in {suspended delayed} && $oc ne $nc} {
        if {![_flag $uid $nc]} { lappend ev [dict create type $nc] }
    }
    if {$oc in {suspended delayed} && $nc ni {suspended delayed postponed cancelled abandoned} && $ns eq "in"} {
        _unflag $uid $oc
        lappend ev [dict create type resumed]
    }
    if {$ns eq "in" && ![dict exists $st($uid) flags kickoff]} {
        _flag $uid kickoff
        lappend ev [dict create type kickoff]
    }
    return $ev
}

proc ::md::diff::_final {old new} {
    set uid [dict get $new uid]
    if {[dict get $new state] eq "post" && [dict get $new code] in {ft aet pens}} {
        if {![_flag $uid ft]} {
            return [list [dict create type ft code [dict get $new code]]]
        }
    }
    return {}
}

# ---------------------------------------------------------------- soccer

proc ::md::diff::_soccer {old new} {
    variable st
    set uid [dict get $new uid]
    set ev [_status $old $new]
    set nc [dict get $new code]
    set np [dict get $new period]
    set oc [dict get $st($uid) code]
    set op [dict get $st($uid) period]

    # goals first (a goal at 45+2 should precede the half-time whistle)
    lappend ev {*}[_goals $new]
    lappend ev {*}[_cards $new]

    if {$nc eq "ht" && ![_flag $uid ht$np]} {
        lappend ev [dict create type ht period $np]
    }
    if {$nc eq "live" && $oc eq "ht"} {
        if {$np == 2 && ![_flag $uid 2h]} {
            lappend ev [dict create type 2h]
        }
    }
    if {$nc eq "live" && $np >= 3 && ($op ne "" && $op < 3) && ![_flag $uid et]} {
        lappend ev [dict create type et]
    }
    if {$nc eq "shootout" && ![_flag $uid shootout]} {
        lappend ev [dict create type shootout]
    }
    lappend ev {*}[_final $old $new]
    return $ev
}

proc ::md::diff::_goals {m} {
    variable st
    set uid [dict get $m uid]
    set nh [_sc $m h]; set na [_sc $m a]
    if {$nh eq "" || $na eq ""} { return {} }
    set ev {}
    set g [dict get $st($uid) goals]
    set pend [dict create h [expr {$nh - [dict get $g h]}] a [expr {$na - [dict get $g a]}]]

    set fresh {}
    foreach e [dict get $m events] {
        if {[dict get $e type] ni {goal pen og}} continue
        if {[dict exists $st($uid) gkeys [dict get $e k]]} continue
        lappend fresh $e
    }
    foreach e $fresh {
        set s [dict get $e side]
        if {$s eq ""} { set s h }
        set o [other $s]
        # data mismatch (e.g. own goal credited to the player's team)
        if {[dict get $pend $s] <= 0 && [dict get $pend $o] > 0} { set s $o }
        if {[dict get $pend $s] > 0} {
            dict set st($uid) gkeys [dict get $e k] 1
            dict incr pend $s -1
            lappend ev [_goal_event $uid $s $e]
        } elseif {[dict get $st($uid) anon $s] > 0} {
            # late attribution of an already announced goal
            dict set st($uid) gkeys [dict get $e k] 1
            dict set st($uid) anon $s [expr {[dict get $st($uid) anon $s] - 1}]
            _count_scorer $uid $e
            lappend ev [dict create type scorer side $s player [dict get $e player] \
                assist [dict get $e assist] min [dict get $e min] gtype [dict get $e type]]
        }
        # else: detail arrived before the score; keep it for the next poll
    }
    foreach s {h a} {
        while {[dict get $pend $s] > 0} {
            dict incr pend $s -1
            dict set st($uid) anon $s [expr {[dict get $st($uid) anon $s] + 1}]
            lappend ev [_goal_event $uid $s [dict create type goal player "" assist "" min [dict get $m minute]]]
        }
    }
    # score went down: goal ruled out (VAR) or data correction
    foreach s {h a} n [list $nh $na] {
        set have [dict get $st($uid) goals $s]
        if {$n < $have} {
            dict set st($uid) goals $s $n
            if {[dict get $st($uid) anon $s] > 0} {
                dict set st($uid) anon $s [expr {[dict get $st($uid) anon $s] - 1}]
            }
            # forget scoring keys no longer present so a re-awarded goal is announced
            set present {}
            foreach e [dict get $m events] { dict set present [dict get $e k] 1 }
            foreach k [dict keys [dict get $st($uid) gkeys]] {
                if {![dict exists $present $k]} { dict unset st($uid) gkeys $k }
            }
            lappend ev [dict create type disallowed side $s h $nh a $na]
        }
    }
    return $ev
}

proc ::md::diff::_count_scorer {uid e} {
    variable st
    set p [dict get $e player]
    if {$p eq "" || [dict get $e type] eq "og"} { return 0 }
    set sc [dict get $st($uid) scorers]
    dict incr sc $p
    dict set st($uid) scorers $sc
    dict get $sc $p
}

proc ::md::diff::_goal_event {uid s e} {
    variable st
    set o [other $s]
    set bh [dict get $st($uid) goals h]
    set ba [dict get $st($uid) goals a]
    dict set st($uid) goals $s [expr {[dict get $st($uid) goals $s] + 1}]
    set ah [dict get $st($uid) goals h]
    set aa [dict get $st($uid) goals a]
    set mine [dict get $st($uid) goals $s]
    set theirs [dict get $st($uid) goals $o]
    set before_mine [expr {$s eq "h" ? $bh : $ba}]
    set before_theirs [expr {$s eq "h" ? $ba : $bh}]
    set ctx {}
    if {$before_mine == 0 && $before_theirs == 0} { lappend ctx first }
    if {$mine == $theirs} { lappend ctx equaliser }
    if {$mine > $theirs && $before_mine <= $before_theirs} {
        lappend ctx lead
        if {[dict get $st($uid) trailed $s]} { lappend ctx comeback }
    }
    if {$mine - $theirs >= 3} { lappend ctx rout }
    if {$theirs > $mine} { lappend ctx consolation }
    # remember who has trailed
    if {$ah < $aa} { dict set st($uid) trailed h 1 }
    if {$aa < $ah} { dict set st($uid) trailed a 1 }
    set min [::md::dg $e "" min]
    if {[regexp {^(\d+)} $min -> mm] && $mm >= 85} { lappend ctx late }
    set n [_count_scorer $uid $e]
    if {$n == 2} { lappend ctx brace }
    if {$n == 3} { lappend ctx hattrick }
    if {$n > 3} { lappend ctx poker }
    dict create type goal side $s gtype [::md::dg $e goal type] player [::md::dg $e "" player] \
        assist [::md::dg $e "" assist] min $min h $ah a $aa ctx $ctx goals_by_player $n
}

proc ::md::diff::_cards {m} {
    variable st
    set uid [dict get $m uid]
    set ev {}
    foreach e [dict get $m events] {
        set t [dict get $e type]
        if {$t ni {yellow yred red penmiss so}} continue
        set k [dict get $e k]
        if {[dict exists $st($uid) seen $k]} continue
        dict set st($uid) seen $k 1
        switch -- $t {
            penmiss { lappend ev [dict create type penmiss side [dict get $e side] player [dict get $e player] min [dict get $e min] text [dict get $e text]] }
            so { lappend ev [dict create type so side [dict get $e side] player [dict get $e player] scored [dict get $e scored]] }
            default { lappend ev [dict create type card ctype $t side [dict get $e side] player [dict get $e player] min [dict get $e min]] }
        }
    }
    return $ev
}

# ---------------------------------------------------------------- other team sports

# seconds left from a game clock string "2:00", "0:35.4", "12:00"
proc ::md::diff::_secs {clock} {
    if {[regexp {^(\d+):(\d+)} $clock -> m s]} { return [expr {[scan $m %d] * 60 + [scan $s %d]}] }
    if {[regexp {^(\d+)(?:\.\d+)?$} $clock -> s]} { return [scan $s %d] }
    return ""
}

proc ::md::diff::_profile {sport} {
    # regulation periods, per-score announcements, close-game rule {margin seconds}
    switch -- $sport {
        basketball { return {periods 4 scores 0 close {5 120}} }
        football   { return {periods 4 scores 1 close {8 120}} }
        hockey     { return {periods 3 scores 1 close {1 120}} }
        baseball   { return {periods 9 scores 1 close {}} }
        rugby      { return {periods 2 scores 1 close {7 300}} }
        default    { return {periods 4 scores 0 close {}} }
    }
}

proc ::md::diff::_teamsport {old new} {
    variable st
    set uid [dict get $new uid]
    set ev [_status $old $new]
    set prof [_profile [dict get $new sport]]
    set nh [_sc $new h]; set na [_sc $new a]
    set np [dict get $new period]
    set op [dict get $st($uid) period]
    if {$nh ne "" && $na ne "" && [dict get $new state] eq "in"} {
        set dh [expr {$nh - [dict get $st($uid) goals h]}]
        set da [expr {$na - [dict get $st($uid) goals a]}]
        if {($dh != 0 || $da != 0)} {
            if {[dict get $prof scores]} {
                lappend ev [dict create type score dh $dh da $da h $nh a $na]
            }
            dict set st($uid) goals h $nh
            dict set st($uid) goals a $na
        }
    } elseif {$nh ne "" && $na ne ""} {
        dict set st($uid) goals h $nh
        dict set st($uid) goals a $na
    }
    if {[dict get $new state] eq "in" && [string is integer -strict $op] && [string is integer -strict $np] && $np > $op && $op >= 1} {
        if {![_flag $uid pe$op]} { lappend ev [dict create type period_end period $op h $nh a $na] }
        if {$np > [dict get $prof periods] && ![_flag $uid ot$np]} {
            lappend ev [dict create type ot period $np]
        }
    }
    if {[dict get $new code] eq "ht" && ![_flag $uid ht]} {
        lappend ev [dict create type ht period $np]
    }
    # close game alert
    set close [dict get $prof close]
    if {[llength $close] && [dict get $new state] eq "in" && $nh ne "" && $na ne ""
        && [string is integer -strict $np] && $np >= [dict get $prof periods]} {
        lassign $close margin secs
        set left [_secs [dict get $new clock]]
        if {$left ne "" && $left <= $secs && abs($nh - $na) <= $margin && ![_flag $uid close$np]} {
            lappend ev [dict create type close h $nh a $na left [dict get $new clock] period $np]
        }
    }
    lappend ev {*}[_final $old $new]
    return $ev
}

# ---------------------------------------------------------------- duels / races

proc ::md::diff::_sets_done {m} {
    expr {([_int [dict get $m home score]] ne "" ? [dict get $m home score] : 0) +
          ([_int [dict get $m away score]] ne "" ? [dict get $m away score] : 0)}
}

proc ::md::diff::_duel {old new} {
    variable st
    set uid [dict get $new uid]
    set ev [_status $old $new]
    if {[dict get $new sport] eq "tennis" && [dict get $new state] eq "in"} {
        set n [_sets_done $new]
        if {$n > [dict get $st($uid) sets]} {
            dict set st($uid) sets $n
            set i [expr {$n - 1}]
            set hg [lindex [dict get $new home ls] $i]
            set ag [lindex [dict get $new away ls] $i]
            set w [expr {$hg ne "" && $ag ne "" && $hg > $ag ? "h" : "a"}]
            lappend ev [dict create type set setno $n side $w games "$hg-$ag"]
        }
    }
    lappend ev {*}[_final $old $new]
    return $ev
}

proc ::md::diff::_race {old new} {
    variable st
    set uid [dict get $new uid]
    set ev [_status $old $new]
    if {[dict get $new state] eq "in" && [dict exists $new results] && [llength [dict get $new results]]} {
        set lead [dict get [lindex [dict get $new results] 0] name]
        if {$lead ne "" && $lead ne [dict get $st($uid) leader]} {
            if {[dict get $st($uid) leader] ne ""} {
                lappend ev [dict create type leader name $lead prev [dict get $st($uid) leader]]
            }
            dict set st($uid) leader $lead
        }
    }
    lappend ev {*}[_final $old $new]
    return $ev
}

# ---------------------------------------------------------------- persistence

proc ::md::diff::export {} {
    variable st
    set d {}
    set cutoff [expr {[clock seconds] - 3 * 86400}]
    foreach uid [array names st] {
        if {[dict get $st($uid) ts] >= $cutoff} { dict set d $uid $st($uid) }
    }
    return $d
}

proc ::md::diff::import {d} {
    variable st
    dict for {uid v} $d { set st($uid) $v }
}

proc ::md::diff::gc {} {
    variable st
    set cutoff [expr {[clock seconds] - 2 * 86400}]
    foreach uid [array names st] {
        if {[dict get $st($uid) ts] < $cutoff} { unset st($uid) }
    }
}
