# Matchday - lib/json.tcl
# Self-contained JSON decoder/encoder (no tcllib needed).
#
# Decoding maps objects -> dicts, arrays -> lists, strings -> strings,
# numbers -> numbers, true/false -> "true"/"false" (valid Tcl booleans),
# null -> "". The tokenizer is a single regexp pass, which keeps it fast
# enough for the 50-500 KB payloads returned by sports APIs.

namespace eval ::md::json {
    variable T {}
    variable I 0
    variable N 0
    variable RE {"(?:[^"\\]|\\.)*"|-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|true|false|null|[\[\]{}:,]}
}

proc ::md::json::parse {text} {
    variable T; variable I; variable N; variable RE
    set T [regexp -all -inline -- $RE $text]
    set I 0
    set N [llength $T]
    if {$N == 0} { error "json: empty document" }
    try {
        set v [_val]
    } finally {
        set T {}
    }
    return $v
}

proc ::md::json::_val {} {
    variable T; variable I; variable N
    if {$I >= $N} { error "json: unexpected end of input" }
    set t [lindex $T $I]
    incr I
    switch -- [string index $t 0] {
        "\{" { return [_obj] }
        "\[" { return [_arr] }
        "\"" { return [_str $t] }
        "t"  { return true }
        "f"  { return false }
        "n"  { return "" }
        "\}" - "\]" - ":" - "," { error "json: unexpected '$t' at token $I" }
        default { return $t }
    }
}

proc ::md::json::_obj {} {
    variable T; variable I; variable N
    set d [dict create]
    if {[lindex $T $I] eq "\}"} { incr I; return $d }
    while {1} {
        if {$I + 2 >= $N} { error "json: unterminated object" }
        set k [lindex $T $I]
        if {[string index $k 0] ne "\""} { error "json: bad object key '$k'" }
        set k [_str $k]
        incr I 2 ;# key and ':'
        dict set d $k [_val]
        set t [lindex $T $I]
        incr I
        if {$t eq "\}"} { return $d }
        if {$t ne ","} { error "json: expected ',' or '\}' got '$t'" }
    }
}

proc ::md::json::_arr {} {
    variable T; variable I; variable N
    set l {}
    if {[lindex $T $I] eq "\]"} { incr I; return $l }
    while {1} {
        lappend l [_val]
        if {$I >= $N} { error "json: unterminated array" }
        set t [lindex $T $I]
        incr I
        if {$t eq "\]"} { return $l }
        if {$t ne ","} { error "json: expected ',' or '\]' got '$t'" }
    }
}

proc ::md::json::_str {t} {
    set s [string range $t 1 end-1]
    if {[string first "\\" $s] < 0} { return $s }
    # surrogate pairs: combine (Tcl 9) or replace (Tcl 8.6 BMP-only)
    # (never run subst with command substitution on remote data)
    while {[regexp -indices {\\u([dD][89abAB][0-9a-fA-F]{2})\\u([dD][c-fC-F][0-9a-fA-F]{2})} $s all hi lo]} {
        set rep [_pair [string range $s {*}$hi] [string range $s {*}$lo]]
        set s [string replace $s {*}$all $rep]
    }
    # escape anything that subst would otherwise interpret
    return [subst -nocommands -novariables $s]
}

proc ::md::json::_pair {hi lo} {
    set cp [expr {0x10000 + (([scan $hi %x] - 0xD800) << 10) + ([scan $lo %x] - 0xDC00)}]
    if {[package vsatisfies [info tclversion] 9-]} { return [format %c $cp] }
    return "�"
}

# ---------------------------------------------------------------- encode

proc ::md::json::str {s} {
    set s [string map {\\ \\\\ \" \\\" \n \\n \r \\r \t \\t \b \\b \f \\f} $s]
    # remaining control chars
    if {[regexp {[\x00-\x1f]} $s]} {
        set out ""
        foreach ch [split $s ""] {
            scan $ch %c c
            if {$c < 32} { append out [format "\\u%04x" $c] } else { append out $ch }
        }
        set s $out
    }
    return "\"$s\""
}

proc ::md::json::num {n} {
    if {[string is double -strict $n]} { return $n }
    return 0
}

proc ::md::json::bool {b} {
    expr {[string is true -strict $b] ? "true" : "false"}
}

# obj key value ?key value ...?  -- values must already be encoded
proc ::md::json::obj {args} {
    set parts {}
    foreach {k v} $args { lappend parts "[str $k]:$v" }
    return "\{[join $parts ,]\}"
}

# arr list-of-encoded-values
proc ::md::json::arr {items} {
    return "\[[join $items ,]\]"
}

# list of plain strings -> JSON array of strings
proc ::md::json::strs {items} {
    set out {}
    foreach i $items { lappend out [str $i] }
    arr $out
}
