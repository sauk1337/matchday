# Matchday - lib/util.tcl
# General helpers: config access, logging, timers, text normalisation,
# fuzzy matching, time parsing/formatting and byte-safe line splitting.

namespace eval ::md {
    variable conf
    variable timers
    array set timers {}
}

# ---------------------------------------------------------------- config

proc ::md::cfg {key {default ""}} {
    variable conf
    if {[info exists conf($key)]} { return $conf($key) }
    return $default
}

proc ::md::cfgset {key value} {
    variable conf
    set conf($key) $value
}

# ---------------------------------------------------------------- logging

proc ::md::log {level msg} {
    set levels {debug 0 info 1 warn 2 error 3}
    set want [cfg log.level info]
    if {![dict exists $levels $level]} { set level info }
    if {[dict get $levels $level] < [dict get $levels $want]} { return }
    set line "Matchday[expr {$level eq "info" ? "" : " ($level)"}]: $msg"
    if {[info commands ::putlog] ne ""} {
        catch {::putlog $line}
    } else {
        puts stderr $line
    }
}

# Run a script, logging (not propagating) any error. Used around callbacks
# so one broken handler never kills the event loop or other subscribers.
proc ::md::safe {script {what "callback"}} {
    if {[catch {uplevel 1 $script} err opts]} {
        ::md::log error "$what failed: $err"
        ::md::log debug [dict get $opts -errorinfo]
        return -code ok ""
    }
    return $err
}

# ---------------------------------------------------------------- time

proc ::md::now {} { clock seconds }

# Parse ISO-8601 timestamps as found in ESPN / API-Football payloads:
#   2026-10-13T19:00Z, 2026-10-13T19:00:00Z, 2026-10-13T19:00:00+00:00,
#   2026-10-13T19:00:00.000+02:00
proc ::md::iso2epoch {s} {
    if {$s eq ""} { return 0 }
    if {![regexp {^(\d{4})-(\d\d)-(\d\d)[T ](\d\d):(\d\d)(?::(\d\d))?(?:\.\d+)?(Z|[+-]\d\d:?\d\d)?$} $s -> y mo d h mi sec tz]} {
        if {[catch {clock scan $s} t]} { return 0 }
        return $t
    }
    if {$sec eq ""} { set sec 00 }
    set t [clock scan "$y-$mo-$d $h:$mi:$sec" -format "%Y-%m-%d %H:%M:%S" -timezone :UTC]
    if {$tz ne "" && $tz ne "Z"} {
        regexp {([+-])(\d\d):?(\d\d)} $tz -> sign oh om
        set off [expr {[scan $oh %d] * 3600 + [scan $om %d] * 60}]
        if {$sign eq "+"} { set t [expr {$t - $off}] } else { set t [expr {$t + $off}] }
    }
    return $t
}

proc ::md::tzname {tz} {
    if {$tz eq "" || [string equal -nocase $tz UTC]} { return :UTC }
    if {[string index $tz 0] ne ":" && [string match */* $tz]} { return ":$tz" }
    return $tz
}

proc ::md::validtz {tz} {
    expr {![catch {clock format 0 -timezone [tzname $tz]}]}
}

proc ::md::tfmt {epoch fmt {tz UTC}} {
    if {[catch {clock format $epoch -format $fmt -timezone [tzname $tz]} out]} {
        set out [clock format $epoch -format $fmt -timezone :UTC]
    }
    return $out
}

# YYYYMMDD of "now + days" in the given timezone
proc ::md::ymd {{tz UTC} {days 0}} {
    tfmt [expr {[now] + $days * 86400}] %Y%m%d $tz
}

# Accepts: today/hoy/..., tomorrow, yesterday, +N, -N, YYYY-MM-DD,
# YYYYMMDD, DD/MM, DD/MM/YYYY, DD-MM. Returns YYYYMMDD or "".
proc ::md::parse_day {word {tz UTC}} {
    set w [norm $word]
    set today  {today hoy hoje aujourdhui oggi heute ahora now}
    set tomor  {tomorrow manana amanha demain domani morgen}
    set yester {yesterday ayer ontem hier ieri gestern}
    if {$w in $today}  { return [ymd $tz 0] }
    if {$w in $tomor}  { return [ymd $tz 1] }
    if {$w in $yester} { return [ymd $tz -1] }
    if {[regexp {^([+-])(\d{1,2})$} $word -> s n]} {
        set n [scan $n %d]
        return [ymd $tz [expr {$s eq "-" ? -$n : $n}]]
    }
    if {[regexp {^(\d{4})-?(\d\d)-?(\d\d)$} $word -> y m d]} { return "$y$m$d" }
    if {[regexp {^(\d{1,2})[/.-](\d{1,2})(?:[/.-](\d{2,4}))?$} $word -> d m y]} {
        if {$y eq ""} { set y [tfmt [now] %Y $tz] }
        if {[string length $y] == 2} { set y "20$y" }
        return [format %04d%02d%02d [scan $y %d] [scan $m %d] [scan $d %d]]
    }
    return ""
}

# "15m" "2h" "90" (minutes) -> seconds
proc ::md::parse_dur {s} {
    if {[regexp {^(\d+)\s*(s|m|min|h|d)?$} [string tolower $s] -> n u]} {
        switch -- $u {
            s { return $n }
            h { return [expr {$n * 3600}] }
            d { return [expr {$n * 86400}] }
            default { return [expr {$n * 60}] }
        }
    }
    return ""
}

# HH:MM -> minutes since midnight, "" if invalid
proc ::md::hm2min {s} {
    if {[regexp {^(\d{1,2})[:.h]?(\d\d)?$} $s -> h m]} {
        if {$m eq ""} { set m 0 }
        set h [scan $h %d]; set m [scan $m %d]
        if {$h < 24 && $m < 60} { return [expr {$h * 60 + $m}] }
    }
    return ""
}

# ---------------------------------------------------------------- timers

# Named one-shot timer: rescheduling a name cancels the previous one.
proc ::md::timer {name ms script} {
    variable timers
    cancel $name
    set timers($name) [after $ms [list ::md::_fire $name $script]]
}

proc ::md::_fire {name script} {
    variable timers
    unset -nocomplain timers($name)
    if {[catch {uplevel #0 $script} err opts]} {
        log error "timer $name: $err"
        log debug [dict get $opts -errorinfo]
    }
}

# Repeating timer
proc ::md::every {name ms script} {
    timer $name $ms [list ::md::_every $name $ms $script]
}

proc ::md::_every {name ms script} {
    every $name $ms $script
    if {[catch {uplevel #0 $script} err opts]} {
        log error "periodic $name: $err"
        log debug [dict get $opts -errorinfo]
    }
}

proc ::md::cancel {name} {
    variable timers
    if {[info exists timers($name)]} {
        after cancel $timers($name)
        unset timers($name)
    }
}

proc ::md::cancel_all {} {
    variable timers
    foreach name [array names timers] { cancel $name }
}

# ---------------------------------------------------------------- dicts

# Safe nested dict get with default
proc ::md::dg {d default args} {
    if {[llength $args] == 0} { return $d }
    if {[catch {dict exists $d {*}$args} ok] || !$ok} { return $default }
    return [dict get $d {*}$args]
}

proc ::md::lfirst {list default} {
    if {[llength $list]} { return [lindex $list 0] }
    return $default
}

proc ::md::luniq {list} {
    set seen {}
    set out {}
    foreach x $list {
        if {![dict exists $seen $x]} { dict set seen $x 1; lappend out $x }
    }
    return $out
}

proc ::md::lremove {list value} {
    set out {}
    foreach x $list { if {$x ne $value} { lappend out $x } }
    return $out
}

proc ::md::pick {list} {
    if {![llength $list]} { return "" }
    lindex $list [expr {int(rand() * [llength $list])}]
}

proc ::md::clamp {v lo hi} {
    expr {$v < $lo ? $lo : ($v > $hi ? $hi : $v)}
}

proc ::md::isint {s} { string is integer -strict $s }

# ---------------------------------------------------------------- text

namespace eval ::md {
    # accent folding map (built once)
    variable foldmap {}
    foreach {from to} {
        á a à a â a ä a ã a å a ā a ă a ą a
        Á a À a Â a Ä a Ã a Å a
        ç c ć c č c Ç c Č c Ć c
        é e è e ê e ë e ē e ę e ě e
        É e È e Ê e Ë e
        í i ì i î i ï i ı i ī i Í i Ì i Î i Ï i İ i
        ñ n ń n ň n Ñ n
        ó o ò o ô o ö o õ o ø o ő o
        Ó o Ò o Ô o Ö o Õ o Ø o
        ú u ù u û u ü u ů u ű u ū u
        Ú u Ù u Û u Ü u
        ý y ÿ y Ý y
        ß ss æ ae Æ ae œ oe Œ oe
        ğ g Ğ g ş s Ş s š s Š s ś s
        ž z Ž z ź z ż z ł l Ł l ř r Ř r
        đ d Đ d ð d ţ t ț t ș s
    } { lappend foldmap $from $to }
}

# lowercase, accent-folded, punctuation -> space, collapsed spaces
proc ::md::norm {s} {
    variable foldmap
    set s [string tolower [string map $foldmap $s]]
    regsub -all {[^a-z0-9 ]+} $s " " s
    regsub -all { +} [string trim $s] " " s
    return $s
}

proc ::md::lev {a b} {
    set la [string length $a]; set lb [string length $b]
    if {$la == 0} { return $lb }
    if {$lb == 0} { return $la }
    set prev {}
    for {set j 0} {$j <= $lb} {incr j} { lappend prev $j }
    for {set i 1} {$i <= $la} {incr i} {
        set cur [list $i]
        set ca [string index $a [expr {$i - 1}]]
        for {set j 1} {$j <= $lb} {incr j} {
            set cost [expr {$ca eq [string index $b [expr {$j - 1}]] ? 0 : 1}]
            set v [expr {min([lindex $prev $j] + 1, [lindex $cur end] + 1, [lindex $prev [expr {$j - 1}]] + $cost)}]
            lappend cur $v
        }
        set prev $cur
    }
    lindex $prev end
}

# Score how well a (normalised) query matches a list of (normalised)
# candidate names. 0 = no match, 100 = exact.
proc ::md::mscore {q names} {
    set best 0
    if {$q eq ""} { return 0 }
    foreach n $names {
        if {$n eq ""} continue
        if {$n eq $q} { return 100 }
        set s 0
        if {[string first $q $n] == 0} {
            set s 85
        } elseif {[lsearch -exact $n [lindex $q 0]] >= 0 && [string first $q $n] >= 0} {
            set s 80
        } elseif {[string first " $q" " $n"] >= 0} {
            set s 75
        } elseif {[string length $q] >= 4 && [string first $q $n] >= 0} {
            set s 60
        } else {
            # every query word is a prefix of some name word
            set all 1
            foreach w $q {
                set hit 0
                foreach nw $n { if {[string first $w $nw] == 0} { set hit 1; break } }
                if {!$hit} { set all 0; break }
            }
            if {$all} {
                set s 70
            } elseif {[string length $q] >= 5} {
                set d [lev $q $n]
                if {$d <= 2 && $d < [string length $q] / 3} { set s [expr {55 - $d * 5}] }
            }
        }
        if {$s > $best} { set best $s }
    }
    return $best
}

proc ::md::bytes {s} { string length [encoding convertto utf-8 $s] }

# Split text into chunks of at most max UTF-8 bytes, preferring spaces
# (or " | " separators). IRC formatting codes are carried over.
proc ::md::wrap {text max} {
    set out {}
    while {[bytes $text] > $max} {
        # find character index where byte budget runs out
        set lo 0; set hi [string length $text]
        while {$lo < $hi} {
            set mid [expr {($lo + $hi + 1) / 2}]
            if {[bytes [string range $text 0 [expr {$mid - 1}]]] <= $max} { set lo $mid } else { set hi [expr {$mid - 1}] }
        }
        set cut $lo
        set sep [string last " | " [string range $text 0 [expr {$cut - 1}]]]
        if {$sep > $cut / 2} {
            set cut $sep
        } else {
            set sp [string last " " [string range $text 0 [expr {$cut - 1}]]]
            if {$sp > $cut / 2} { set cut $sp }
        }
        set head [string range $text 0 [expr {$cut - 1}]]
        lappend out [string trimright $head]
        set text [string trimleft [string range $text $cut end]]
        if {[string match "| *" $text]} { set text [string range $text 2 end] }
    }
    if {[string trim $text] ne ""} { lappend out $text }
    return $out
}

proc ::md::trunc {s n} {
    if {[string length $s] <= $n} { return $s }
    return "[string range $s 0 [expr {$n - 2}]]…"
}

proc ::md::pad {s n} {
    format "%-*s" $n [trunc $s $n]
}

proc ::md::ucfirst {s} {
    return [string toupper [string index $s 0]][string range $s 1 end]
}

# IRC case-insensitive key (rfc1459)
proc ::md::ircl {s} {
    string tolower [string map {\[ \{ \] \} \\ | ~ ^} $s]
}

proc ::md::readfile {path {enc utf-8}} {
    set fh [open $path r]
    fconfigure $fh -encoding $enc
    set data [read $fh]
    close $fh
    return $data
}
