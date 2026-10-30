# Runs every test file in its own tclsh process.
# Usage: tclsh tests/run_all.tcl          (add "live" to include the network check)
set dir [file dirname [file normalize [info script]]]
set tclsh [info nameofexecutable]
set files {test_json.tcl test_load.tcl test_engine.tcl test_commands.tcl test_extras.tcl test_narrator.tcl test_web.tcl}
set failed 0
foreach f $files {
    set t0 [clock milliseconds]
    set rc [catch {exec $tclsh -encoding utf-8 [file join $dir $f] 2>@1} out]
    set last [lindex [split [string trim $out] \n] end]
    puts [format "%-20s %-40s %5d ms" $f $last [expr {[clock milliseconds] - $t0}]]
    if {$rc} {
        incr failed
        foreach l [split $out \n] { if {[string match "FAIL*" $l] || [string match "*expected*" $l] || [string match "*got*" $l]} { puts "    $l" } }
    }
}
if {[lindex $argv 0] eq "live"} {
    puts "\n--- live check (network, takes 1-2 minutes) ---"
    flush stdout
    if {[catch {exec $tclsh -encoding utf-8 [file join $dir live_check.tcl] >@stdout 2>@stderr} err]} {
        puts "live check failed: $err"
    }
}
puts [expr {$failed ? "\n$failed test file(s) FAILED" : "\nAll tests passed."}]
exit [expr {$failed ? 1 : 0}]
