# Live smoke test against the real ESPN API (needs network + curl or tls).
# Usage: tclsh -encoding utf-8 tests/live_check.tcl
set ::T(dir) [file normalize [file dirname [info script]]]
set ::T(root) [file dirname $::T(dir)]
source [file join $::T(dir) eggstub.tcl]
fconfigure stdout -encoding utf-8
set data [file join $::T(dir) _live_[pid]]
file mkdir $data
set ::md_test_conf [list data.dir $data log.level info web.port 0 cmd.flood_count 1000]
source -encoding utf-8 [file join $::T(root) matchday.tcl]
::stub::addchan #futbol +matchday
::stub::adduser #futbol Alice o
::md::chan::put #futbol leagues {esp.1 eng.1 uefa.champions}
set ::stub::verbose 1

proc ask {text {wait 6000}} {
    puts "\n<Alice> $text"
    ::sim::pub Alice #futbol $text
    ::sim::run $wait
    ::stub::take
}
ask "!about" 500
ask "!table laliga"
ask "!table premier"
ask "!scorers laliga"
ask "!next real madrid" 8000
ask "!last barcelona" 8000
ask "!today ucl"
ask "!live"
ask "!next lakers" 8000
ask "!table nba"
ask "!today f1"
ask "!match arsenal" 8000
ask "!player mbappe" 8000
ask "!jugador lamine yamal" 8000
ask "!player lebron" 8000
ask "!prob real madrid" 8000
ask "!prob lakers" 8000
puts "\nHTTP: [::md::http::status]"
foreach l $::stub::logs { if {[string match "*error*" $l] || [string match "*warn*" $l]} { puts "LOG: $l" } }
::md::shutdown
file delete -force $data
