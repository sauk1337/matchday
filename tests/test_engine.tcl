# Engine test: a synthetic match goes through poller -> diff -> dispatch
# and we check what the channel and subscribers receive.
source [file join [file dirname [info script]] testlib.tcl]

::md::chan::put #futbol leagues {esp.1}
::stub::addchan #other
::stub::adduser #other Dave

# Dave (not in #futbol) and Bob (in #futbol) follow Real Madrid
::md::subs::follow n:dave team:soccer:86 "Real Madrid"
::md::db_set users n:dave nick Dave
::md::subs::setpref n:dave events {goals reds cards pens start ht ft status alerts reminders}
::md::subs::follow n:bob team:soccer:86 "Real Madrid"
::md::db_set users n:bob nick Bob

proc side {id name score {so ""}} {
    dict create id $id name $name short $name abbr [string toupper [string range $name 0 2]] score $score so $so winner false ls {} form "" ha "" order 0
}
proc ev {type side min player {k ""}} {
    if {$k eq ""} { set k "$type:$side:$min:$player" }
    dict create k $k type $type side $side min "$min'" clock [expr {$min * 60}] player $player assist "" pid $player scored [expr {$type in {goal pen og}}] text ""
}
proc mk {state code hs as events {minute ""} {period 1}} {
    dict create uid espn:esp.1:999 prov espn lkey esp.1 lname LALIGA sport soccer kind team eid 999 \
        start [expr {[clock seconds] + ($state eq "pre" ? 3000 : -3000)}] state $state code $code sname "" \
        detail "" clock "" minute $minute period $period home [side 86 "Real Madrid" $hs] away [side 243 Sevilla $as] \
        events $events round "" venue "Bernabéu" link "" updated [clock seconds] note "" tv {}
}
proc feed {m} {
    ::md::poll::_got esp.1 ok [list $m]
    ::sim::run 450
    set out {}
    foreach o [::stub::take] {
        lappend out [list [lindex [split [lindex $o 1] " "] 1] [::stub::visible [lindex $o 1]]]
    }
    return $out
}
proc to {out target} {
    set r {}
    foreach o $out { if {[string equal -nocase [lindex $o 0] $target]} { lappend r [lindex $o 1] } }
    return $r
}
proc has {out target pattern} {
    foreach l [to $out $target] { if {[string match $pattern $l]} { return 1 } }
    return 0
}

set E1 {}
test engine.absorb_pre { llength [feed [mk pre scheduled "" "" {}]] } 0

set o [feed [mk in live 0 0 {} "1'"]]
check engine.kickoff { has $o #futbol "*Kick-off:*Real Madrid - Sevilla*" }
check engine.kickoff_dave { has $o Dave "*Kick-off:*" }

set E1 [list [ev goal h 23 Mbappé]]
set o [feed [mk in live 1 0 $E1 "23'"]]
check engine.goal_chan { has $o #futbol "*GOAL!*Real Madrid*1-0*Sevilla*Mbappé*23'*" }
check engine.goal_dave { has $o Dave "*GOAL!*Mbappé*" }
test  engine.bob_dedupe { llength [to $o Bob] } 0

# away goal arrives before its scorer
set o [feed [mk in live 1 1 $E1 "30'"]]
check engine.anon_goal { has $o #futbol "*GOAL!*1-1*Equaliser!*" }
lappend E1 [ev goal a 30 "En-Nesyri"]
set o [feed [mk in live 1 1 $E1 "31'"]]
check engine.scorer_update { has $o #futbol "*Goal update: En-Nesyri 30'*" }

# yellow card: channel default filter excludes yellows, Dave wants them
lappend E1 [ev yellow a 35 Gudelj]
set o [feed [mk in live 1 1 $E1 "35'"]]
test  engine.yellow_chan_filtered { llength [to $o #futbol] } 0
check engine.yellow_dave { has $o Dave "*Yellow card: Gudelj (Sevilla)*" }

set o [feed [mk in ht 1 1 $E1 "45'"]]
check engine.ht { has $o #futbol "*Half-time:*1-1*Mbappé 23'*En-Nesyri 30'*" }
set o [feed [mk in live 1 1 $E1 "46'" 2]]
check engine.2h { has $o #futbol "*Second half*" }

lappend E1 [ev goal h 70 Mbappé]
set o [feed [mk in live 2 1 $E1 "70'" 2]]
check engine.brace { has $o #futbol "*GOAL!*2-1*Brace for Mbappé!*" }

# VAR: goal removed
set E2 [lrange $E1 0 end-1]
set o [feed [mk in live 1 1 $E2 "72'" 2]]
check engine.var { has $o #futbol "*Goal disallowed*Real Madrid*1-1*" }

lappend E2 [ev red a 80 Ramos]
set o [feed [mk in live 1 1 $E2 "80'" 2]]
check engine.red { has $o #futbol "*RED CARD!*Ramos (Sevilla)*" }

# late winner
lappend E2 [ev goal h 89 Vinícius]
set o [feed [mk in live 2 1 $E2 "89'" 2]]
check engine.late { has $o #futbol "*GOAL!*2-1*Vinícius 89'*Late drama!*" }

set o [feed [mk post ft 2 1 $E2 "" 2]]
check engine.ft { has $o #futbol "*Full-time:*Real Madrid*2-1*Sevilla*" }
test  engine.idempotent { llength [feed [mk post ft 2 1 $E2 "" 2]] } 0

# persistence: diff state survives a save/restore cycle
::md::poll::save
check engine.persist { dict exists [dict get $::md::db(state) diff] espn:esp.1:999 }

# penalties final
proc mkpens {} {
    set m [mk post pens 1 1 {} "" 5]
    dict set m uid espn:esp.1:1000
    dict set m home so 4
    dict set m away so 3
    return $m
}
set m [mkpens]
dict set m state in
dict set m code shootout
feed $m
set o [feed [mkpens]]
check engine.pens { has $o #futbol "*Real Madrid win 4-3 on penalties*" }

# reminders: channel with remind=30 gets one reminder, once
::md::chan::put #futbol remind 30
::md::subs::setpref n:dave remind 30
set pm [mk pre scheduled "" "" {}]
dict set pm uid espn:esp.1:1001
dict set pm start [expr {[clock seconds] + 1200}]
set o [feed $pm]
check engine.reminder { has $o #futbol "*Starts in 20 min*Real Madrid - Sevilla*" }
check engine.reminder_dave { has $o Dave "*Starts in*" }
test  engine.reminder_once { llength [to [feed $pm] #futbol] } 0

# quiet hours / dnd silence private alerts
::md::subs::setpref n:dave dnd 1
set m [mk in live 0 0 {} "1'"]
dict set m uid espn:esp.1:1002
feed [mk pre scheduled "" "" {}]
set m0 $m; dict set m0 state pre; dict set m0 code scheduled
feed $m0
set o [feed $m]
test engine.dnd { llength [to $o Dave] } 0
::md::subs::setpref n:dave dnd 0

# basketball: close game + period end + final
proc nba {state code h a period clock} {
    dict create uid espn:nba:1 prov espn lkey nba lname NBA sport basketball kind team eid 1 \
        start [clock seconds] state $state code $code sname "" detail "Q$period $clock" clock $clock minute "" period $period \
        home [side 13 Lakers $h] away [side 2 Celtics $a] events {} round "" venue "" link "" updated [clock seconds] note "" tv {}
}
::md::chan::put #futbol leagues {esp.1 nba}
::md::chan::put #futbol events {goals reds pens start ht ft status alerts}
feed [nba pre scheduled 0 0 0 0:00]
set o [feed [nba in live 2 0 1 11:40]]
check nba.start { has $o #futbol "*Underway:*Lakers - Celtics*" }
set o [feed [nba in live 30 28 2 12:00]]
check nba.period_end { has $o #futbol "*End of Q1*" }
set o [feed [nba in live 101 100 4 1:30]]
check nba.close { has $o #futbol "*Close game!*1:30 left in Q4*" }
set o [feed [nba post ft 105 102 4 0:00]]
check nba.final { has $o #futbol "*Full-time:*Lakers*105-102*Celtics*" }

# missed results: Eve follows Real Madrid but is offline at full time
::md::subs::follow n:eve team:soccer:86 "Real Madrid"
::md::db_set users n:eve nick Eve
set mm [mk in live 1 0 {} "80'"]
dict set mm uid espn:esp.1:2000
feed [dict replace $mm state pre code scheduled]
feed $mm
feed [dict replace $mm state post code ft]
::sim::joinchan Eve #futbol
::sim::run 50
set o [::stub::texts]
check missed.welcome { expr {[lsearch -glob $o "*Welcome back!*(1)*"] >= 0 && [lsearch -glob $o "*Real Madrid*1-0*Sevilla*"] >= 0} }
::sim::joinchan Eve #other
test missed.once { llength [::stub::texts] } 0

done
