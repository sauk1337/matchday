# Matchday - lib/i18n.tcl
# Message catalogs with English fallback, %{placeholder} interpolation,
# variant lists for narration (random pick without immediate repeats)
# and localised command aliases.
#
# Language files call:
#   md::i18n::lang  <code> <english name> <native name>
#   md::i18n::msgs  <code> { key text key text ... }
#   md::i18n::vary  <code> { key {variant variant ...} ... }
#   md::i18n::cmds  <code> { canonical {alias alias} ... }

namespace eval ::md::i18n {
    variable S         ;# S(lang,key) -> text
    variable V         ;# V(lang,key) -> list of variants
    variable names     ;# code -> {english native}
    variable alias     ;# alias -> canonical command
    variable cmdnames  ;# cmdnames(lang,canonical) -> preferred localised name
    variable last      ;# last(key) -> last picked index (anti-repeat)
    array set S {}
    array set V {}
    array set alias {}
    array set cmdnames {}
    array set last {}
    variable names {}
}

proc ::md::i18n::lang {code en native} {
    variable names
    dict set names $code [list $en $native]
}

proc ::md::i18n::msgs {code pairs} {
    variable S
    foreach {k v} $pairs { set S($code,$k) $v }
}

proc ::md::i18n::vary {code pairs} {
    variable V
    foreach {k v} $pairs { set V($code,$k) $v }
}

proc ::md::i18n::cmds {code pairs} {
    variable alias
    variable cmdnames
    foreach {canon list} $pairs {
        if {[llength $list]} { set cmdnames($code,$canon) [lindex $list 0] }
        foreach a $list {
            set a [string tolower $a]
            # never let an alias shadow a canonical command of another meaning
            if {![info exists alias($a)]} { set alias($a) $canon }
        }
    }
}

proc ::md::i18n::canon_register {list} {
    variable alias
    foreach c $list { set alias([string tolower $c]) $c }
}

proc ::md::i18n::resolve {word} {
    variable alias
    set w [string tolower $word]
    if {[info exists alias($w)]} { return $alias($w) }
    # accent-insensitive retry (e.g. "clasificación")
    set n [string map {" " ""} [::md::norm $w]]
    if {[info exists alias($n)]} { return $alias($n) }
    return ""
}

# Localised display name for a canonical command
proc ::md::i18n::cmdname {lang canon} {
    variable cmdnames
    if {[info exists cmdnames($lang,$canon)]} { return $cmdnames($lang,$canon) }
    return $canon
}

proc ::md::i18n::available {} {
    variable names
    dict keys $names
}

proc ::md::i18n::valid {code} {
    variable names
    dict exists $names $code
}

proc ::md::i18n::name {code} {
    variable names
    if {![dict exists $names $code]} { return $code }
    lindex [dict get $names $code] 1
}

proc ::md::i18n::has {lang key} {
    variable S
    variable V
    expr {[info exists S($lang,$key)] || [info exists V($lang,$key)] ||
          [info exists S(en,$key)] || [info exists V(en,$key)]}
}

# Raw template lookup with fallback chain lang -> en -> key
proc ::md::i18n::raw {lang key} {
    variable S
    variable V
    variable last
    foreach l [list $lang en] {
        if {[info exists V($l,$key)]} {
            set vs $V($l,$key)
            set n [llength $vs]
            if {$n == 1} { return [lindex $vs 0] }
            set i [expr {int(rand() * $n)}]
            if {[info exists last($l,$key)] && $last($l,$key) == $i} { set i [expr {($i + 1) % $n}] }
            set last($l,$key) $i
            return [lindex $vs $i]
        }
        if {[info exists S($l,$key)]} { return $S($l,$key) }
    }
    return ""
}

proc ::md::i18n::interp {tpl args} {
    if {[llength $args] == 1} { set args [lindex $args 0] }
    set map {}
    foreach {k v} $args { lappend map "%{$k}" $v }
    set tpl [string map $map $tpl]
    # plurals: %{n:goal|goals} picks the word for the value of n
    while {[regexp -indices {%\{([a-z]+):([^|{}]*)\|([^{}]*)\}} $tpl all ki si pi]} {
        set k [string range $tpl {*}$ki]
        set v ""
        if {[dict exists $args $k]} { set v [dict get $args $k] }
        set num ""
        regexp {\d+(?:\.\d+)?} $v num
        set w [expr {$num ne "" && $num == 1 ? [string range $tpl {*}$si] : [string range $tpl {*}$pi]}]
        set tpl [string replace $tpl [lindex $all 0] [lindex $all 1] $w]
    }
    return $tpl
}

# md::t lang key ?name value ...?
proc ::md::t {lang key args} {
    set tpl [::md::i18n::raw $lang $key]
    if {$tpl eq ""} { return "\[$key\]" }
    if {[llength $args]} { set tpl [::md::i18n::interp $tpl $args] }
    return $tpl
}

# Same but returns "" when the key does not exist anywhere
proc ::md::t? {lang key args} {
    set tpl [::md::i18n::raw $lang $key]
    if {$tpl eq ""} { return "" }
    if {[llength $args]} { set tpl [::md::i18n::interp $tpl $args] }
    return $tpl
}

proc ::md::i18n::load_all {} {
    set dir [file join $::md::base lang]
    foreach f [lsort [glob -nocomplain -directory $dir *.tcl]] {
        if {[catch {uplevel #0 [list source -encoding utf-8 $f]} err]} {
            ::md::log error "language file [file tail $f]: $err"
        }
    }
    ::md::log debug "languages: [available]"
}
