# Matchday - features/hot.tcl
# "Hot match" alerts for football: goal flurries, goal fests, comebacks
# from two goals down, underdogs leading late and shock results (using
# the pre-match odds model). They are delivered as engine events of type
# "hot" (category "hot"), so channels and users filter them like any
# other event. Channels can receive them from every competition the bot
# watches with: !mdset hotscope all

namespace eval ::md::hot {
    variable H         ;# uid -> dict {goals flags maxdef}
    array set H {}
}

proc ::md::hot::_mm {min} {
    if {[regexp {^(\d+)(?:\+(\d+))?} $min -> a b]} {
        return [expr {[scan $a %d] + ($b eq "" ? 0 : [scan $b %d])}]
    }
    return ""
}

proc ::md::hot::_st {uid} {
    variable H
    if {![info exists H($uid)]} {
        set H($uid) [dict create goals {} flags {} maxdef {h 0 a 0} ts [clock seconds]]
    }
}

proc ::md::hot::_once {uid flag} {
    variable H
    if {[dict exists $H($uid) flags $flag]} { return 0 }
    dict set H($uid) flags $flag 1
    return 1
}

proc ::md::hot::on_event {ev m} {
    variable H
    if {[dict get $m sport] ne "soccer" || [string match replay:* [dict get $m uid]]} return
    set uid [dict get $m uid]
    switch -- [dict get $ev type] {
        kickoff {
            # learn the pre-match odds once (cached for hours)
            if {[::md::cfg hot.odds 1]} {
                ::md::espn::summary [dict get $m lkey] [dict get $m eid] [list ::md::hot::_odds $uid] 21600
            }
        }
        goal { _goal $ev $m }
        ft { _ft $m }
    }
}
::md::hook::add event ::md::hot::on_event

proc ::md::hot::_odds {uid status r} {
    if {$status eq "ok"} { ::md::prob::prematch $uid [dict get $r odds] }
}

proc ::md::hot::_emit {m ev} {
    ::md::dispatch::emit $m [list [dict merge [dict create type hot uid [dict get $m uid]] $ev]]
}

proc ::md::hot::_goal {ev m} {
    variable H
    set uid [dict get $m uid]
    _st $uid
    set mm [_mm [dict get $ev min]]
    if {$mm eq ""} { set mm [_mm [dict get $m minute]] }
    set h [dict get $ev h]; set a [dict get $ev a]
    set side [dict get $ev side]
    # deficits before this goal
    set bh [expr {$side eq "h" ? $h - 1 : $h}]
    set ba [expr {$side eq "a" ? $a - 1 : $a}]
    foreach s {h a} d [list [expr {$ba - $bh}] [expr {$bh - $ba}]] {
        if {$d > [dict get $H($uid) maxdef $s]} { dict set H($uid) maxdef $s $d }
    }
    if {$mm ne ""} { dict lappend H($uid) goals $mm }
    set win [::md::cfg hot.flurry_minutes 10]
    set need [::md::cfg hot.flurry_goals 3]
    if {$mm ne ""} {
        set n 0
        foreach g [dict get $H($uid) goals] { if {$mm - $g <= $win} { incr n } }
        if {$n >= $need && [_once $uid flurry]} {
            _emit $m [dict create kind flurry n $n mins $win min [dict get $ev min]]
            return
        }
    }
    if {$h + $a >= [::md::cfg hot.goalfest 5] && ($mm eq "" || $mm <= 80) && [_once $uid goalfest]} {
        _emit $m [dict create kind goalfest n [expr {$h + $a}] min [dict get $ev min]]
        return
    }
    # comeback from two (or more) goals down
    set mine [expr {$side eq "h" ? $h : $a}]
    set theirs [expr {$side eq "h" ? $a : $h}]
    if {$mine >= $theirs && [dict get $H($uid) maxdef $side] >= 2 && [_once $uid comeback$side]} {
        _emit $m [dict create kind comeback side $side min [dict get $ev min] lead [expr {$mine > $theirs}]]
        return
    }
    # underdog in front late
    if {$mine > $theirs && $mm ne "" && $mm >= [::md::cfg hot.upset_minute 60]} {
        set p [::md::prob::pre_win $uid $side]
        if {$p ne "" && $p <= [::md::cfg hot.upset 0.20] && [_once $uid upset$side]} {
            _emit $m [dict create kind upset side $side pct [::md::prob::pct $p] min [dict get $ev min]]
        }
    }
}

proc ::md::hot::_ft {m} {
    variable H
    set uid [dict get $m uid]
    _st $uid
    set h [dict get $m home score]; set a [dict get $m away score]
    if {![string is integer -strict $h] || ![string is integer -strict $a] || $h == $a} return
    set side [expr {$h > $a ? "h" : "a"}]
    set p [::md::prob::pre_win $uid $side]
    if {$p ne "" && $p <= [::md::cfg hot.upset 0.20] && [_once $uid shock]} {
        _emit $m [dict create kind shock side $side pct [::md::prob::pct $p]]
    }
}

proc ::md::hot::gc {} {
    variable H
    set cut [expr {[clock seconds] - 86400}]
    foreach uid [array names H] {
        if {[dict get $H($uid) ts] < $cut} { unset H($uid) }
    }
}

proc ::md::hot::init {} {
    ::md::every hot.gc 3600000 ::md::hot::gc
}
