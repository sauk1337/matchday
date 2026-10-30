# Tiny test framework + bootstrap: loads the Eggdrop stub and Matchday
# with an isolated data directory and offline (fixture) HTTP.

set ::T(dir) [file normalize [file dirname [info script]]]
set ::T(root) [file dirname $::T(dir)]
set ::T(pass) 0
set ::T(fail) 0
set ::T(failed) {}

source [file join $::T(dir) eggstub.tcl]

proc test {name body expected} {
    if {[catch {uplevel #0 $body} got opts]} {
        set got "ERROR: $got\n[dict get $opts -errorinfo]"
    }
    if {$got eq $expected} {
        incr ::T(pass)
        if {[info exists ::env(VERBOSE)]} { puts "PASS $name" }
    } else {
        incr ::T(fail)
        lappend ::T(failed) $name
        puts "FAIL $name"
        puts "   expected: $expected"
        puts "   got:      $got"
    }
}

# test whose body returns a boolean
proc check {name body} { test $name $body 1 }

proc done {} {
    if {[info exists ::env(VERBOSE)]} { foreach l $::stub::logs { if {[string match "*(error)*" $l]} { puts "LOG: $l" } } }
    puts "[file tail [info script]]: $::T(pass) passed, $::T(fail) failed"
    if {[info exists ::md::conf]} { catch {::md::shutdown} }
    exit [expr {$::T(fail) ? 1 : 0}]
}

# Load Matchday with a temporary data dir. Set ::T(noload) before sourcing
# testlib to skip (pure unit tests only need lib/).
if {![info exists ::T(noload)]} {
    set ::T(data) [file join $::T(dir) _data_[pid]]
    file delete -force $::T(data)
    file mkdir $::T(data)
    set ::md_test_conf [list data.dir $::T(data) http.offline 1 log.level warn web.port 0 out.coalesce_ms 100]
    source [file join $::T(root) matchday.tcl]
    ::stub::addchan #futbol +matchday
    ::stub::adduser #futbol Alice o
    ::stub::adduser #futbol Bob
    ::stub::adduser #futbol Carol v
    ::stub::addhand owner Owner n
    ::stub::adduser #futbol Owner o
    rename done _done
    proc done {} {
        catch {::md::shutdown}
        file delete -force $::T(data)
        _done
    }
}
