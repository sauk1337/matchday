# Matchday - features/videos.tcl
# Posts video highlights after the final whistle. ESPN attaches clips to
# the match summary minutes to hours after the end, so each finished
# match is re-checked a few times. Clips whose headline looks like a
# highlights package are preferred; at most videos.max per match.
# Delivered as engine events of type "video" (category "videos").

namespace eval ::md::vid {}

proc ::md::vid::on_event {ev m} {
    if {[dict get $ev type] ne "ft" || ![::md::cfg videos.enabled 1]} return
    if {[dict get $m prov] ne "espn" || [dict get $m kind] ne "team"} return
    set uid [dict get $m uid]
    if {[string match replay:* $uid]} return
    set i 0
    foreach delay [::md::cfg videos.checks {600 1800 3600 7200 14400}] {
        ::md::timer vid.$uid.[incr i] [expr {$delay * 1000}] [list ::md::vid::check $uid]
    }
}
::md::hook::add event ::md::vid::on_event

proc ::md::vid::check {uid} {
    set m [::md::poll::match $uid]
    if {$m eq ""} return
    set posted [::md::db_get videos $uid ids]
    if {[llength $posted] >= [::md::cfg videos.max 2]} return
    ::md::espn::summary [dict get $m lkey] [dict get $m eid] [list ::md::vid::_got $uid] 300
}

proc ::md::vid::_got {uid status r} {
    if {$status ne "ok"} return
    set m [::md::poll::match $uid]
    if {$m eq ""} return
    set posted [::md::db_get videos $uid ids]
    set max [::md::cfg videos.max 2]
    set re [::md::cfg videos.prefer {highlight|all goals|every goal|recap|resumen|goles|melhores momentos|résumé|sintesi|zusammenfassung}]
    set filter [::md::cfg videos.filter ""]
    # preferred clips first, otherwise ESPN's order
    set cands {}
    foreach v [dict get $r videos] {
        if {[dict get $v id] in $posted} continue
        set hl [dict get $v headline]
        if {$filter ne "" && ![regexp -nocase -- $filter $hl]} continue
        set pri [expr {[regexp -nocase -- $re $hl] ? 0 : 1}]
        if {$pri == 1 && [::md::cfg videos.only_highlights 0]} continue
        lappend cands [list $pri $v]
    }
    foreach c [lsort -integer -index 0 $cands] {
        if {[llength $posted] >= $max} break
        set v [lindex $c 1]
        lappend posted [dict get $v id]
        ::md::db_set videos $uid [dict create ids $posted ts [clock seconds]]
        set ev [dict create type video uid $uid headline [dict get $v headline] \
            url [dict get $v url] duration [dict get $v duration]]
        ::md::dispatch::emit $m [list $ev]
    }
}

proc ::md::vid::gc {} {
    if {![info exists ::md::db(videos)]} return
    set cut [expr {[clock seconds] - 3 * 86400}]
    dict for {uid d} $::md::db(videos) {
        if {[::md::dg $d 0 ts] < $cut} { ::md::db_unset videos $uid }
    }
}

proc ::md::vid::init {} {
    ::md::store::load videos
    ::md::every vid.gc 21600000 ::md::vid::gc
}

proc ::md::vid::dur {secs} {
    if {![string is integer -strict $secs] || $secs <= 0} { return "" }
    format "%d:%02d" [expr {$secs / 60}] [expr {$secs % 60}]
}
