# Narrator test: replays a real recorded match (Inter 3-4 Club Brugge,
# UCL 2026-10-13) through the narrator at high speed.
source [file join [file dirname [info script]] testlib.tcl]
set F [file join $::T(dir) fixtures]
fconfigure stdout -encoding utf-8
::md::http::fixture "*summary?event=401915413*" [list file $F/ucl_summary.json]
::md::cfgset replay.min_tick 5
::md::cfgset out.max_per_minute 1000
::md::cfgset out.max_burst 1000
::md::cfgset cmd.flood_count 1000

set lang [expr {[llength $argv] ? [lindex $argv 0] : "en"}]
::md::chan::put #futbol lang $lang
::stub::take

::sim::pub Owner #futbol "!md replay ucl 401915413 600 #futbol"
set all {}
for {set i 0} {$i < 200} {incr i} {
    ::sim::run 200
    lappend all {*}[::stub::texts]
    if {![llength [::md::narr::sessions]] && $i > 5} break
}
if {[info exists ::env(VERBOSE)]} { foreach l $all { puts "    | $l" } }
proc any {pattern} {
    foreach l $::all { if {[string match $pattern $l]} { return 1 } }
    return 0
}
proc count {pattern} {
    set n 0
    foreach l $::all { if {[string match $pattern $l]} { incr n } }
    return $n
}

if {$lang eq "en"} {
    check narr.banner   { any "*REPLAY x600*Inter Milan - Club Brugge*" }
    check narr.intro    { any "*Inter Milan - Club Brugge*Champions League*" }
    check narr.lineups  { any "*Line-ups are in!*" }
    check narr.kickoff  { any "*Inter Milan*Club Brugge*" }
    check narr.pen      { any "*GOAL!*Tresoldi*30'*" }
    check narr.equal    { any "*GOAL!*Lautaro*44'*1-1*" }
    check narr.ht       { expr {[any "*Half-time!*1-1*"] || [any "*break.*1-1*"]} }
    check narr.2h       { any "*econd half*" }
    check narr.cards    { expr {[count "*Spileers*"] >= 1} }
    check narr.chances  { expr {[count "*{s:chance}*"] == 0 && [count "*WOODWORK*"] + [count "*Off the post*"] + [count "*bar saves*"] >= 1} }
    check narr.ft       { any "*3-4*Club Brugge*" }
    check narr.ft_line  { expr {[any "*FULL-TIME!*"] || [any "*all over!*"] || [any "*Final whistle!*"]} }
    check narr.signoff  { any "*Thanks for following!*" }
    check narr.ended    { expr {[llength [::md::narr::sessions]] == 0} }
    check narr.volume   { expr {[llength $all] > 40 && [llength $all] < 220} }
    check narr.no_double_mic { expr {[count "*♪ ♪*"] == 0} }
} else {
    check narr.any { expr {[llength $all] > 20} }
}
done
