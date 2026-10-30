# Prints what a channel would see for a scripted match (visual check).
# Usage: tclsh -encoding utf-8 tests/demo_output.tcl [lang]
source [file join [file dirname [info script]] testlib.tcl]
set lang [expr {[llength $argv] ? [lindex $argv 0] : "en"}]
::md::chan::put #futbol leagues {esp.1}
::md::chan::put #futbol lang $lang
::md::chan::put #futbol events {goals reds cards pens start ht ft status alerts}
set ::stub::verbose 1
fconfigure stdout -encoding utf-8

proc side {id name score {so ""}} {
    dict create id $id name $name short $name abbr [string toupper [string range $name 0 2]] score $score so $so winner false ls {} form "" ha "" order 0
}
proc ev {type side min player} {
    dict create k "$type:$side:$min:$player" type $type side $side min "$min'" clock [expr {$min * 60}] player $player assist "" pid $player scored [expr {$type in {goal pen og}}] text ""
}
proc mk {state code hs as events {minute ""} {period 1}} {
    dict create uid espn:esp.1:999 prov espn lkey esp.1 lname LALIGA sport soccer kind team eid 999 \
        start [expr {[clock seconds] - 3000}] state $state code $code sname "" \
        detail "" clock "" minute $minute period $period home [side 86 "Real Madrid" $hs] away [side 243 Sevilla $as] \
        events $events round "" venue "Bernabéu" link "" updated [clock seconds] note "" tv {}
}
proc feed {m} { ::md::poll::_got esp.1 ok [list $m]; ::sim::run 450 }
feed [mk pre scheduled "" "" {}]
feed [mk in live 0 0 {} "1'"]
set E [list [ev goal h 23 Mbappé]]
feed [mk in live 1 0 $E "23'"]
lappend E [ev yellow a 35 Gudelj]
feed [mk in live 1 0 $E "35'"]
lappend E [ev pen a 44 "En-Nesyri"]
feed [mk in live 1 1 $E "44'"]
feed [mk in ht 1 1 $E "45'"]
feed [mk in live 1 1 $E "46'" 2]
lappend E [ev red a 60 Ramos]
feed [mk in live 1 1 $E "60'" 2]
lappend E [ev goal h 70 Mbappé]
feed [mk in live 2 1 $E "70'" 2]
lappend E [ev goal h 81 Mbappé]
feed [mk in live 3 1 $E "81'" 2]
feed [mk post ft 3 1 $E "" 2]
done
