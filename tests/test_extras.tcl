# Players, win probability, hot-match alerts and video highlights.
source [file join [file dirname [info script]] testlib.tcl]
set F [file join $::T(dir) fixtures]
fconfigure stdout -encoding utf-8
::md::cfgset cmd.flood_count 1000

::md::http::fixture "*search/v2*type=player*"        [list file $F/psearch_mbappe.json]
::md::http::fixture "*/soccer/athletes/231388/overview" [list file $F/ath_mbappe_ov.json]
::md::http::fixture "*/soccer/athletes/231388"        [list file $F/ath_mbappe.json]
::md::http::fixture "*summary?event=401915417*"        [list file $F/ars_summary.json]

proc say {nick chan text {ms 300}} {
    if {$chan eq ""} { ::sim::msg $nick $text } else { ::sim::pub $nick $chan $text }
    ::sim::run $ms
    ::stub::texts
}
proc any {lines pattern} {
    foreach l $lines { if {[string match $pattern $l]} { return 1 } }
    return 0
}
proc show {lines} { if {[info exists ::env(VERBOSE)]} { foreach l $lines { puts "    | $l" } } }

# ---------------------------------------------------------------- probability model
test prob.fit {
    lassign [::md::prob::fit 0.786 0.146 0.068] lh la
    list [expr {abs($lh - 2.44) < 0.1}] [expr {abs($la - 0.57) < 0.1}]
} {1 1}
check prob.sums {
    lassign [::md::prob::outcome 1.4 1.1 1 0] w d l
    expr {abs($w + $d + $l - 1.0) < 1e-9 && $w > $l}
}
check prob.red_card_hurts {
    ::md::prob::prematch t1 {}
    set base [dict create uid t1 state in code live minute "30'" period 1 home {score 0} away {score 0} events {}]
    set a [::md::prob::soccer $base]
    set b [::md::prob::soccer [dict replace $base events [list [dict create side h type red]]]]
    expr {[dict get $b h] < [dict get $a h] - 0.1}
}

# ---------------------------------------------------------------- !player
set o [say Bob #futbol "!player mbappe" 2000]; show $o
check player.head  { any $o "*Kylian Mbappé*Real Madrid*Forward #10*27 y/o*France*" }
check player.stats { any $o "*2026-27 LALIGA: 7 goals, 2 assists, 8 starts, 44 shots (24 on target)*" }
check player.next  { any $o "*Next: Sevilla at Real Madrid*" }
check player.also  { any $o "*Also: Ethan Mbappé (Lille)*" }
set o [say Bob #futbol "!jugador mbappe" 2000]; show $o
check player.alias { any $o "*Kylian Mbappé*" }

# ---------------------------------------------------------------- !prob / !match with odds
proc side {id name score} { dict create id $id name $name short $name abbr "" score $score so "" winner false ls {} form "" ha "" order 0 }
proc ars {state code hs as min {events {}}} {
    dict create uid espn:uefa.champions:401915417 prov espn lkey uefa.champions lname "Champions League" \
        sport soccer kind team eid 401915417 start [expr {[clock seconds] - 1800}] state $state code $code sname "" \
        detail "" clock "" minute $min period 1 home [side 359 Arsenal $hs] away [side 166 Lille $as] \
        events $events round "" venue "" link "" updated [clock seconds] note "" tv {}
}
::md::chan::put #futbol leagues {uefa.champions}
::md::teams::learn soccer 359 Arsenal Arsenal ARS uefa.champions
::md::poll::_got uefa.champions ok [list [ars pre scheduled "" "" ""]]
::md::poll::_got uefa.champions ok [list [ars in live 0 0 "30'"]]
::sim::run 500
::stub::take
set o [say Bob #futbol "!prob arsenal"]; show $o
check prob.cmd { any $o "*Arsenal*Win probability: Arsenal *% · draw *% · Lille *%*" }
# same summary but as if the match were still being played
set body [string map {{"state":"post"} {"state":"in"} STATUS_FULL_TIME STATUS_SECOND_HALF {"completed":true} {"completed":false}} [::md::readfile $F/ars_summary.json]]
::md::http::fixture "*summary?event=401915417*" $body
::md::http::flush_cache
set o [say Bob #futbol "!match arsenal"]; show $o
check match.scorers_named { any $o "*Jurriën Timber 64'*" }
::md::http::fixture "*summary?event=401915417*" [list file $F/ars_summary.json]
::md::http::flush_cache
check prob.match { any $o "*Win probability: Arsenal*" }

# ---------------------------------------------------------------- hot match alerts
proc ev {type side min player} {
    dict create k "$type:$side:$min:$player" type $type side $side min "$min'" clock [expr {$min * 60}] player $player assist "" pid $player scored [expr {$type in {goal pen og}}] text ""
}
# Lille were 7% pre-match: home side is the big favourite (from the odds fixture)
check hot.odds_learnt { expr {[::md::prob::pre_win espn:uefa.champions:401915417 a] < 0.15} }
set E [list [ev goal a 61 David]]
::md::poll::_got uefa.champions ok [list [ars in live 0 1 "61'" $E]]
::sim::run 500
set o [::stub::texts]; show $o
check hot.upset { any $o "*Upset alert!*Lille*% pre-match) lead:*Arsenal*0-1*Lille*" }
lappend E [ev goal a 63 David] [ev goal h 66 Saka]
::md::poll::_got uefa.champions ok [list [ars in live 1 2 "66'" $E]]
::sim::run 500
set o [::stub::texts]; show $o
check hot.flurry { any $o "*Hot match!*3 goals in 10 minutes:*Arsenal*1-2*Lille*" }
lappend E [ev goal h 80 Saka]
::md::poll::_got uefa.champions ok [list [ars in live 2 2 "80'" $E]]
::sim::run 500
set o [::stub::texts]; show $o
check hot.comeback { any $o "*Comeback on!*Arsenal were two goals down:*2-2*" }
lappend E [ev goal a 90 David]
::md::poll::_got uefa.champions ok [list [ars in live 2 3 "90'" $E]]
::md::poll::_got uefa.champions ok [list [ars post ft 2 3 "" $E]]
::sim::run 500
set o [::stub::texts]; show $o
check hot.shock { any $o "*Shock result!*Lille*win:*Arsenal*2-3*Lille*" }
check hot.once { expr {[llength [lsearch -all -glob $o "*Upset alert!*"]] == 0} }

# ---------------------------------------------------------------- videos after full time
::md::cfgset videos.checks {0}
set m [ars in live 3 0 "80'"]
dict set m uid espn:uefa.champions:401915417:v
::md::poll::_got uefa.champions ok [list $m]
::md::poll::_got uefa.champions ok [list [dict replace $m state post code ft]]
# fetch + parse + the 400 ms coalescing window: wait for it instead of
# guessing a fixed delay (slow machines)
set o {}
for {set i 0} {$i < 25 && ![any $o "*Video:*"]} {incr i} { ::sim::run 200; lappend o {*}[::stub::texts] }
show $o
check video.posted { any $o "*Video: Arsenal 3-0 Lille — Arteta labels Arsenal's second half*https://www.espn.com/video/clip/*" }
::md::vid::check espn:uefa.champions:401915417:v
::sim::run 1500
test video.once { llength [lsearch -all -glob [::stub::texts] "*Video: Arsenal 3-0 Lille — Arteta*"] } 0

# hotscope: channel without the league still gets hot alerts when scope=all
::md::chan::put #futbol leagues {}
::md::chan::put #futbol hotscope all
::md::hot::_emit [ars in live 1 1 "50'"] [dict create kind goalfest n 5 min "50'"]
::sim::run 500
check hot.scope_all { any [::stub::texts] "*Goal fest!*" }

# ---------------------------------------------------------------- automatic narration
::md::chan::put #futbol hotscope leagues
::md::teams::learn soccer 93 "Athletic Club" Athletic ATH esp.1
proc ath {id start {state pre} {code scheduled}} {
    dict create uid espn:esp.1:$id prov espn lkey esp.1 lname LALIGA sport soccer kind team eid $id \
        start $start state $state code $code sname "" detail "" clock "" minute "" period 0 \
        home [side 93 "Athletic Club" ""] away [side 83 Barcelona ""] events {} round "" venue "" \
        link "" updated [clock seconds] note "" tv {}
}
set o [say Owner #futbol "!mdset autonarr add athletic"]; show $o
check auto.set { any $o "*autonarr*Athletic*" }
set o [say Owner #futbol "!mdset narrstyle completa"]; show $o
check auto.style { any $o "*narrstyle*full*" }
set o [say Owner #futbol "!mdset"]; show $o
check auto.show { any $o "*autonarr=Athletic*narrstyle=full*" }
# kick-off in 3 hours: too early
::md::poll::store [ath 9001 [expr {[clock seconds] + 3 * 3600}]]
::md::narr::auto_tick
::sim::run 200
check auto.too_early { expr {[llength [::md::narr::sessions #futbol]] == 0} }
# kick-off in 30 minutes: starts, with intro/line-ups ahead
::md::poll::store [ath 9002 [expr {[clock seconds] + 1800}]]
::md::narr::auto_tick
::sim::run 300
set o [::stub::texts]; show $o
check auto.started { any $o "*Narration #* on: *Athletic*Barcelona*(full,*" }
check auto.one { expr {[llength [::md::narr::sessions #futbol espn:esp.1:9002]] == 1} }
::md::narr::auto_tick
check auto.no_dup { expr {[llength [::md::narr::sessions #futbol espn:esp.1:9002]] == 1} }
# an op stops it: it must not come back on the next tick
set o [say Owner #futbol "!narrate off"]; show $o
::md::narr::auto_tick
::sim::run 200
check auto.respects_off { expr {[llength [::md::narr::sessions #futbol]] == 0} }
# a match already live is picked up too (bot restarted mid-match)
::md::poll::store [ath 9003 [expr {[clock seconds] - 1200}] in live]
::md::narr::auto_tick
check auto.live { expr {[llength [::md::narr::sessions #futbol espn:esp.1:9003]] == 1} }
foreach id [::md::narr::sessions #futbol] { ::md::narr::stop $id 0 }
# teams in autonarr are polled even if their league is not in the channel
::md::chan::put #futbol leagues {}
check auto.chan_teams { expr {"soccer:93" in [::md::chan_teams]} }
::stub::take

done
