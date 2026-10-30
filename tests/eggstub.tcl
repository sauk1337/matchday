# Minimal Eggdrop API emulation for running Matchday under plain tclsh.
# Provides binds, channel/user state, output queues and helpers to inject
# IRC traffic (sim::pub, sim::msg, sim::dcc, sim::join).

namespace eval ::stub {
    variable binds {}
    variable out {}
    variable udefs {}
    variable chans {}
    variable users {}      ;# handle -> {flags globalflags chanflags {#c flags}}
    variable accounts {}   ;# nick -> account
    variable verbose 0
    variable logs {}
}

set ::botnick Matchday
set ::nick Matchday
set ::version "1.10.0 1100000"

proc bind {type flags mask procname} {
    lappend ::stub::binds [list $type $flags $mask $procname]
    return $mask
}

proc unbind {type flags mask procname} {
    set new {}
    set found 0
    foreach b $::stub::binds {
        if {!$found && $b eq [list $type $flags $mask $procname]} { set found 1; continue }
        lappend new $b
    }
    if {!$found} { error "no such binding" }
    set ::stub::binds $new
}

proc binds {{mask ""}} {
    set r {}
    foreach b $::stub::binds {
        lassign $b t f m p
        if {$mask eq "" || $mask eq $t || [string match $mask $p]} { lappend r [list $t $f $m 0 $p] }
    }
    return $r
}

foreach q {putserv puthelp putquick putnow} {
    proc $q {text args} [string map [list QUEUE $q] {
        lappend ::stub::out [list QUEUE $text]
        if {$::stub::verbose} { puts "  >> [::stub::visible $text]" }
    }]
}

proc putlog {text} {
    lappend ::stub::logs $text
    if {$::stub::verbose > 1} { puts "  [log] $text" }
}
proc putdcc {idx text} {
    lappend ::stub::out [list dcc:$idx $text]
    if {$::stub::verbose} { puts "  dcc>> [::stub::visible $text]" }
}

proc unixtime {} { clock seconds }
proc isbotnick {n} { string equal -nocase $n $::botnick }

proc setudef {type name} { dict set ::stub::udefs $name $type }

proc channels {} { dict keys $::stub::chans }
proc validchan {c} {
    foreach k [dict keys $::stub::chans] { if {[string equal -nocase $k $c]} { return 1 } }
    return 0
}
proc ::stub::chankey {c} {
    foreach k [dict keys $::stub::chans] { if {[string equal -nocase $k $c]} { return $k } }
    error "invalid channel: $c"
}
proc channel {cmd chan args} {
    set c [::stub::chankey $chan]
    switch -- $cmd {
        get {
            set f [lindex $args 0]
            if {[dict exists $::stub::chans $c flags $f]} { return [dict get $::stub::chans $c flags $f] }
            if {[dict exists $::stub::udefs $f]} {
                return [expr {[dict get $::stub::udefs $f] eq "flag" ? 0 : ""}]
            }
            error "Unknown channel setting."
        }
        set {
            foreach s $args {
                if {[regexp {^([+-])(.+)$} $s -> sign name]} {
                    dict set ::stub::chans $c flags $name [expr {$sign eq "+"}]
                }
            }
        }
        info { return {} }
    }
}
proc onchan {nick {chan ""}} {
    foreach c [dict keys $::stub::chans] {
        if {$chan ne "" && ![string equal -nocase $c $chan]} continue
        foreach n [dict keys [dict get $::stub::chans $c users]] {
            if {[string equal -nocase $n $nick]} { return 1 }
        }
    }
    return 0
}
proc chanlist {chan args} { dict keys [dict get $::stub::chans [::stub::chankey $chan] users] }
proc ::stub::umode {nick chan m} {
    set c [::stub::chankey $chan]
    foreach n [dict keys [dict get $::stub::chans $c users]] {
        if {[string equal -nocase $n $nick]} { return [expr {[string first $m [dict get $::stub::chans $c users $n]] >= 0}] }
    }
    return 0
}
proc isop {nick {chan ""}} { ::stub::umode $nick $chan o }
proc ishalfop {nick {chan ""}} { ::stub::umode $nick $chan h }
proc isvoice {nick {chan ""}} { ::stub::umode $nick $chan v }
proc botisop {chan} { return 1 }
proc getchanhost {nick {chan ""}} { return "$nick@test.host" }

proc nick2hand {nick {chan ""}} {
    foreach h [dict keys $::stub::users] {
        if {[string equal -nocase [dict get $::stub::users $h nick] $nick]} { return $h }
    }
    return "*"
}
proc hand2nick {hand {chan ""}} {
    if {[dict exists $::stub::users $hand]} { return [dict get $::stub::users $hand nick] }
    return ""
}
proc matchattr {hand flags {chan ""}} {
    if {![dict exists $::stub::users $hand]} { return 0 }
    set mine [dict get $::stub::users $hand flags]
    foreach f [split [string map {| "" & ""} $flags] ""] {
        if {$f eq "-"} { return 1 }
        if {[string first $f $mine] >= 0} { return 1 }
    }
    return 0
}
proc validuser {hand} { dict exists $::stub::users $hand }
proc getaccount {nick args} {
    if {[dict exists $::stub::accounts $nick]} { return [dict get $::stub::accounts $nick] }
    return ""
}

# ---------------------------------------------------------------- helpers

proc ::stub::addchan {chan args} {
    dict set ::stub::chans $chan [dict create flags {} users {}]
    foreach f $args { channel set $chan $f }
}
proc ::stub::adduser {chan nick {modes ""}} {
    dict set ::stub::chans [::stub::chankey $chan] users $nick $modes
}
proc ::stub::addhand {hand nick flags} {
    dict set ::stub::users $hand [dict create nick $nick flags $flags]
}

proc ::stub::visible {text} {
    # strip IRC formatting for readable test output
    regsub -all {\x03(\d{1,2}(,\d{1,2})?)?} $text "" text
    string map [list \x02 "" \x1f "" \x0f "" \x1d "" \x16 ""] $text
}

# Returns and clears collected output; each element is {queue text}
proc ::stub::take {} {
    set o $::stub::out
    set ::stub::out {}
    return $o
}
proc ::stub::texts {} {
    set r {}
    foreach o [::stub::take] { lappend r [::stub::visible [lindex $o 1]] }
    return $r
}

namespace eval ::sim {}
proc ::sim::pub {nick chan text} {
    set hand [nick2hand $nick]
    foreach b $::stub::binds {
        lassign $b t f m p
        if {$t eq "pubm" && [string match -nocase $m "$chan $text"]} {
            $p $nick "$nick@test.host" $hand $chan $text
        }
        if {$t eq "pub" && [string equal -nocase $m [lindex [split $text] 0]]} {
            $p $nick "$nick@test.host" $hand $chan [join [lrange [split $text] 1 end]]
        }
    }
}
proc ::sim::msg {nick text} {
    set hand [nick2hand $nick]
    foreach b $::stub::binds {
        lassign $b t f m p
        if {$t eq "msgm" && [string match -nocase $m $text]} {
            $p $nick "$nick@test.host" $hand $text
        }
    }
}
proc ::sim::dcc {hand text} {
    set cmd [lindex [split $text] 0]
    foreach b $::stub::binds {
        lassign $b t f m p
        if {$t eq "dcc" && [string equal -nocase $m $cmd]} {
            $p $hand 1 [join [lrange [split $text] 1 end]]
        }
    }
}
proc ::sim::joinchan {nick chan} {
    ::stub::adduser $chan $nick
    foreach b $::stub::binds {
        lassign $b t f m p
        if {$t eq "join" && [string match -nocase $m "$chan $nick!$nick@test.host"]} {
            $p $nick "$nick@test.host" [nick2hand $nick] $chan
        }
    }
}
proc ::sim::evnt {type} {
    foreach b $::stub::binds {
        lassign $b t f m p
        if {$t eq "evnt" && $m eq $type} { $p $type }
    }
}

# Run the Tcl event loop for ms milliseconds (lets timers/http fire)
proc ::sim::run {ms} {
    set ::sim::_done 0
    after $ms {set ::sim::_done 1}
    vwait ::sim::_done
}
