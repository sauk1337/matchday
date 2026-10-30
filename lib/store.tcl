# Matchday - lib/store.tcl
# Tiny persistence layer: each "table" is a Tcl dict kept in memory in
# ::md::db(<name>) and written atomically to <datadir>/<name>.db when
# marked dirty. Files are plain UTF-8 Tcl dicts (human readable).

namespace eval ::md::store {
    variable dir ""
    variable dirty
    array set dirty {}
}

namespace eval ::md {
    variable db
    array set db {}
}

proc ::md::store::init {} {
    variable dir
    set dir [::md::cfg data.dir [file join $::md::base data]]
    file mkdir $dir
    ::md::every store.flush [expr {[::md::cfg data.save_interval 120] * 1000}] ::md::store::flush
}

proc ::md::store::path {name} {
    variable dir
    file join $dir $name.db
}

# Load a table into ::md::db(name). Missing file -> empty dict.
# Corrupt file -> renamed to .bad-<ts> and empty dict.
proc ::md::store::load {name} {
    set p [path $name]
    set data {}
    if {[file exists $p]} {
        if {[catch {
            set raw [::md::readfile $p]
            if {[catch {dict size $raw}]} { error "not a dict" }
            set data $raw
        } err]} {
            set bad "$p.bad-[clock seconds]"
            catch {file rename -force $p $bad}
            ::md::log error "data file $p is corrupt ($err); moved to $bad"
            set data {}
        }
    }
    set ::md::db($name) $data
    return $data
}

proc ::md::store::mark {name} {
    variable dirty
    set dirty($name) 1
}

proc ::md::store::save {name} {
    variable dirty
    if {![info exists ::md::db($name)]} return
    set p [path $name]
    set tmp "$p.tmp"
    set fh [open $tmp w]
    fconfigure $fh -encoding utf-8 -translation lf
    # one top-level key per line for readability/diffability
    dict for {k v} $::md::db($name) {
        puts $fh [list $k $v]
    }
    close $fh
    file rename -force $tmp $p
    unset -nocomplain dirty($name)
}

proc ::md::store::flush {} {
    variable dirty
    foreach name [array names dirty] {
        if {[catch {save $name} err]} {
            ::md::log error "saving $name: $err"
        }
    }
}

# --- convenience accessors on ::md::db tables

proc ::md::db_get {table args} {
    if {![info exists ::md::db($table)]} { return "" }
    ::md::dg $::md::db($table) "" {*}$args
}

proc ::md::db_exists {table args} {
    if {![info exists ::md::db($table)]} { return 0 }
    dict exists $::md::db($table) {*}$args
}

proc ::md::db_set {table args} {
    dict set ::md::db($table) {*}$args
    ::md::store::mark $table
}

proc ::md::db_unset {table args} {
    if {[::md::db_exists $table {*}$args]} {
        dict unset ::md::db($table) {*}$args
        ::md::store::mark $table
    }
}
