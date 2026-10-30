# Matchday - engine/render.tcl
# Localised one-line renderings of matches and events (markup output,
# turned into IRC codes by md::out per target style).

namespace eval ::md::render {}

proc ::md::render::sd {m side} {
    dict get $m [expr {$side eq "h" ? "home" : "away"}]
}

# team display name
proc ::md::render::tn {s} {
    if {[::md::cfg out.names short] eq "full"} { return [dict get $s name] }
    set n [dict get $s short]
    if {$n eq ""} { set n [dict get $s name] }
    return $n
}

proc ::md::render::reds {m side} {
    set n 0
    foreach e [dict get $m events] {
        if {[dict get $e side] eq $side && [dict get $e type] in {red yred}} { incr n }
    }
    if {$n == 0} { return "" }
    return " [string repeat "{s:red}" $n]"
}

proc ::md::render::teams {m} {
    return "[tn [dict get $m home]] - [tn [dict get $m away]]"
}

# "Real Madrid 2-1 Sevilla" with optional emphasis on a side
proc ::md::render::score {m {hl ""} {reds 1}} {
    set h [dict get $m home]; set a [dict get $m away]
    if {[dict get $m kind] eq "race"} { return [dict get $m note] }
    set hn [tn $h]; set an [tn $a]
    if {$hl eq "h"} { set hn "{b}$hn{b}" }
    if {$hl eq "a"} { set an "{b}$an{b}" }
    set hs [dict get $h score]; set as [dict get $a score]
    if {[dict get $m state] eq "pre" || ($hs eq "" && $as eq "")} {
        return "$hn - $an"
    }
    if {[dict get $m kind] eq "duel"} {
        return "$hn [_sets $m] $an"
    }
    set rh [expr {$reds ? [reds $m h] : ""}]
    set ra [expr {$reds ? [reds $m a] : ""}]
    set s "$hn$rh {b}$hs-$as{b} $an$ra"
    set hso [dict get $h so]; set aso [dict get $a so]
    if {$hso ne "" && $aso ne "" && ($hso > 0 || $aso > 0)} {
        append s " ($hso-$aso p)"
    }
    return $s
}

proc ::md::render::_sets {m} {
    set hl [dict get $m home ls]; set al [dict get $m away ls]
    set parts {}
    foreach x $hl y $al {
        if {$x eq "" && $y eq ""} continue
        lappend parts "$x-$y"
    }
    if {![llength $parts]} {
        return "{b}[dict get $m home score]-[dict get $m away score]{b}"
    }
    return "{b}[join $parts " "]{b}"
}

proc ::md::render::league {m} {
    set n [dict get $m lname]
    return "{c:league}\[$n\]{/c}"
}

# local kick-off time; includes weekday/date when not today
proc ::md::render::when {lang epoch tz} {
    if {$epoch == 0} { return "--:--" }
    set today [::md::tfmt [clock seconds] %Y%m%d $tz]
    set day [::md::tfmt $epoch %Y%m%d $tz]
    set hm [::md::tfmt $epoch %H:%M $tz]
    if {$day eq $today} { return $hm }
    if {$day eq [::md::ymd $tz 1]} { return "[::md::t $lang word.tomorrow] $hm" }
    set wd [lindex [::md::t $lang days.short] [::md::tfmt $epoch %u $tz]]
    set dd [::md::tfmt $epoch %d/%m $tz]
    return "$wd $dd $hm"
}

proc ::md::render::status_tag {lang m tz} {
    set code [dict get $m code]
    switch -- $code {
        scheduled { return "{c:dim}[when $lang [dict get $m start] $tz]{/c}" }
        ht        { return "{c:ht}[::md::t $lang st.ht]{/c}" }
        ft        { return "{c:ft}[::md::t $lang st.ft]{/c}" }
        aet       { return "{c:ft}[::md::t $lang st.aet]{/c}" }
        pens      { return "{c:ft}[::md::t $lang st.pens]{/c}" }
        postponed { return "{c:warn}[::md::t $lang st.ppd]{/c}" }
        cancelled { return "{c:warn}[::md::t $lang st.canc]{/c}" }
        abandoned { return "{c:warn}[::md::t $lang st.aban]{/c}" }
        suspended { return "{c:warn}[::md::t $lang st.susp]{/c}" }
        delayed   { return "{c:warn}[::md::t $lang st.delay]{/c}" }
        shootout  { return "{c:live}{s:live}{/c} {c:pen}[::md::t $lang st.shootout]{/c}" }
    }
    # live
    if {[dict get $m sport] eq "soccer" && [dict get $m minute] ne ""} {
        return "{c:live}{s:live}{/c} {c:minute}[dict get $m minute]{/c}"
    }
    set d [dict get $m detail]
    if {$d eq ""} { set d [::md::t $lang st.live] }
    return "{c:live}{s:live}{/c} {c:minute}$d{/c}"
}

# One line per match for listings
proc ::md::render::line {lang m tz {withleague 0}} {
    set tag [status_tag $lang $m $tz]
    if {[dict get $m kind] eq "race"} {
        set s "$tag [dict get $m note]"
        set res [::md::dg $m {} results]
        if {[dict get $m state] ne "pre" && [llength $res]} {
            set top {}
            foreach r [lrange $res 0 2] { lappend top "[dict get $r pos]. [dict get $r name]" }
            append s ": [join $top ", "]"
        }
    } else {
        set s "$tag [score $m]"
        if {[dict get $m kind] eq "duel" && [dict get $m note] ne "" && $withleague} {
            append s " {c:dim}([dict get $m note]){/c}"
        }
    }
    if {$withleague} { append s " [league $m]" }
    return $s
}

# "Mbappé 23' 67' (p), Isco 80'"
proc ::md::render::scorers {lang m {side ""}} {
    set by {}
    foreach e [dict get $m events] {
        set t [dict get $e type]
        if {$t ni {goal pen og}} continue
        set s [dict get $e side]
        if {$t eq "og"} {
            # own goals count for the opponent
            set s [expr {$s eq "h" ? "a" : "h"}]
            if {[dict get $e side] eq ""} { set s "" }
        }
        if {$side ne "" && $s ne $side} continue
        set p [dict get $e player]
        if {$p eq ""} { set p "?" }
        set tag ""
        if {$t eq "pen"} { set tag [::md::t $lang tag.pen] }
        if {$t eq "og"} { set tag [::md::t $lang tag.og] }
        dict lappend by $p "[dict get $e min]$tag"
    }
    set parts {}
    dict for {p mins} $by { lappend parts "$p [join $mins " "]" }
    join $parts ", "
}

proc ::md::render::scorers_suffix {lang m} {
    set hs [scorers $lang $m h]
    set as [scorers $lang $m a]
    if {$hs eq "" && $as eq ""} { return "" }
    set parts {}
    if {$hs ne ""} { lappend parts $hs }
    if {$as ne ""} { lappend parts $as }
    return " {c:dim}([join $parts " | "]){/c}"
}

# Pick the most remarkable goal context tag
proc ::md::render::goal_ctx {lang ev} {
    set ctx [dict get $ev ctx]
    foreach c {poker hattrick comeback equaliser brace} {
        if {$c in $ctx} {
            return " {c:hl}[::md::t $lang ctx.$c player [dict get $ev player]]{/c}"
        }
    }
    if {"late" in $ctx && "lead" in $ctx} { return " {c:hl}[::md::t $lang ctx.latewinner]{/c}" }
    if {"lead" in $ctx && "first" ni $ctx} { return " {c:hl}[::md::t $lang ctx.lead]{/c}" }
    return ""
}

proc ::md::render::period_name {lang sport n} {
    switch -- $sport {
        basketball - football {
            if {$n > 4} { return [::md::t $lang period.ot n [expr {$n - 4}]] }
            return [::md::t $lang period.q n $n]
        }
        hockey {
            if {$n > 3} { return [::md::t $lang period.ot n [expr {$n - 3}]] }
            return [::md::t $lang period.p n $n]
        }
        baseball { return [::md::t $lang period.inning n $n] }
        soccer - rugby { return [::md::t $lang period.half n $n] }
        default { return [::md::t $lang period.p n $n] }
    }
}

proc ::md::render::who {lang ev} {
    set p [dict get $ev player]
    set s ""
    if {$p ne ""} { set s " $p" }
    set min [::md::dg $ev "" min]
    if {$min ne ""} { append s " {c:minute}$min{/c}" }
    switch -- [::md::dg $ev "" gtype] {
        pen { append s [::md::t $lang tag.pen] }
        og  { append s [::md::t $lang tag.og] }
    }
    set as [::md::dg $ev "" assist]
    if {$as ne "" && [::md::dg $ev "" gtype] ne "og"} { append s " {c:dim}([::md::t $lang tag.assist name $as]){/c}" }
    if {$s ne ""} { set s " —$s" }
    return $s
}

# Render an engine event as a single line. Returns "" for events that
# have no standalone rendering (e.g. shootout kicks).
proc ::md::render::event {lang ev m} {
    set type [dict get $ev type]
    set lg [league $m]
    set tm ""
    if {[dict exists $ev side] && [dict get $ev side] in {h a}} {
        set tm [tn [sd $m [dict get $ev side]]]
    }
    switch -- $type {
        goal {
            set hl [dict get $ev side]
            set mm [dict replace $m home [dict replace [dict get $m home] score [dict get $ev h]] \
                                    away [dict replace [dict get $m away] score [dict get $ev a]]]
            return [::md::t $lang ev.goal score [score $mm $hl] who [who $lang $ev] ctx [goal_ctx $lang $ev] league $lg team $tm]
        }
        scorer {
            return [::md::t $lang ev.scorer player [dict get $ev player] min [dict get $ev min] team $tm score [score $m] league $lg]
        }
        disallowed {
            return [::md::t $lang ev.disallowed team $tm score [score $m] league $lg]
        }
        card {
            set ct [dict get $ev ctype]
            return [::md::t $lang ev.card.$ct player [dict get $ev player] team $tm min [dict get $ev min] score [score $m] league $lg]
        }
        penmiss {
            return [::md::t $lang ev.penmiss player [dict get $ev player] team $tm min [dict get $ev min] score [score $m] league $lg]
        }
        so { return "" }
        kickoff {
            if {[dict get $m kind] eq "race"} {
                return [::md::t $lang ev.race_start name [dict get $m note] league $lg]
            }
            if {[dict get $m sport] ne "soccer"} {
                return [::md::t $lang ev.start teams [teams $m] league $lg]
            }
            return [::md::t $lang ev.kickoff teams [teams $m] league $lg]
        }
        ht {
            return [::md::t $lang ev.ht score [score $m] scorers [scorers_suffix $lang $m] league $lg]
        }
        2h { return [::md::t $lang ev.2h score [score $m] league $lg] }
        et { return [::md::t $lang ev.et score [score $m] league $lg] }
        shootout { return [::md::t $lang ev.shootout score [score $m] league $lg] }
        ft {
            if {[dict get $m kind] eq "race"} {
                set top {}
                foreach r [lrange [::md::dg $m {} results] 0 2] { lappend top "[dict get $r pos]. [dict get $r name]" }
                return [::md::t $lang ev.race_end name [dict get $m note] podium [join $top ", "] league $lg]
            }
            set code [dict get $ev code]
            set key ev.ft
            set extra {}
            if {$code eq "aet"} { set key ev.ft.aet }
            if {$code eq "pens"} {
                set key ev.ft.pens
                set h [dict get $m home]; set a [dict get $m away]
                set w [expr {[dict get $h so] > [dict get $a so] ? [tn $h] : [tn $a]}]
                set extra [list winner $w so "[dict get $h so]-[dict get $a so]"]
            }
            if {[dict get $m kind] eq "duel"} {
                set h [dict get $m home]
                set w [expr {[string is true -strict [dict get $h winner]] ? [tn $h] : [tn [dict get $m away]]}]
                return [::md::t $lang ev.ft.duel score [score $m] winner $w league $lg]
            }
            return [::md::t $lang $key score [score $m] scorers [scorers_suffix $lang $m] league $lg {*}$extra]
        }
        postponed - cancelled - abandoned - suspended - delayed - resumed {
            return [::md::t $lang ev.$type teams [teams $m] score [score $m] league $lg]
        }
        score {
            set dh [dict get $ev dh]; set da [dict get $ev da]
            set side [expr {$dh > 0 ? "h" : "a"}]
            set d [expr {$dh > 0 ? $dh : $da}]
            set label [_score_label $lang [dict get $m sport] $d]
            set mm [dict replace $m home [dict replace [dict get $m home] score [dict get $ev h]] \
                                    away [dict replace [dict get $m away] score [dict get $ev a]]]
            return [::md::t $lang ev.score label $label team [tn [sd $m $side]] score [score $mm $side] detail [dict get $m detail] league $lg]
        }
        period_end {
            return [::md::t $lang ev.period_end period [period_name $lang [dict get $m sport] [dict get $ev period]] score [score $m] league $lg]
        }
        ot { return [::md::t $lang ev.ot score [score $m] league $lg] }
        close {
            return [::md::t $lang ev.close left [dict get $ev left] period [period_name $lang [dict get $m sport] [dict get $ev period]] score [score $m] league $lg]
        }
        set {
            return [::md::t $lang ev.set n [dict get $ev setno] player [tn [sd $m [dict get $ev side]]] games [dict get $ev games] score [score $m] league $lg]
        }
        leader {
            return [::md::t $lang ev.leader name [dict get $m note] driver [dict get $ev name] prev [dict get $ev prev] league $lg]
        }
        hot {
            set tm ""
            if {[dict exists $ev side]} { set tm [tn [sd $m [dict get $ev side]]] }
            return [::md::t $lang hot.[dict get $ev kind] score [score $m] team $tm \
                n [::md::dg $ev "" n] mins [::md::dg $ev "" mins] min [::md::dg $ev "" min] \
                pct [::md::dg $ev "" pct] league $lg]
        }
        video {
            set d [::md::vid::dur [dict get $ev duration]]
            if {$d ne ""} { set d " {c:dim}($d){/c}" }
            return [::md::t $lang ev.video teams [score $m "" 0] headline [dict get $ev headline] \
                dur $d url [dict get $ev url] league $lg]
        }
        reminder {
            set tv ""
            if {[llength [dict get $m tv]]} { set tv " {c:dim}{s:tv} [join [lrange [dict get $m tv] 0 2] ", "]{/c}" }
            return [::md::t $lang ev.reminder mins [dict get $ev mins] teams [teams $m] time [when $lang [dict get $m start] [::md::dg $ev UTC tz]] league $lg tv $tv]
        }
    }
    return ""
}

proc ::md::render::_score_label {lang sport d} {
    switch -- $sport {
        football {
            switch -- $d {
                6 - 7 - 8 { return [::md::t $lang score.td] }
                3 { return [::md::t $lang score.fg] }
                2 { return [::md::t $lang score.safety] }
                default { return [::md::t $lang score.points n $d] }
            }
        }
        hockey { return [::md::t $lang score.goal] }
        baseball { return [::md::t $lang score.runs n $d] }
        rugby {
            switch -- $d {
                5 - 7 { return [::md::t $lang score.try] }
                3 { return [::md::t $lang score.penalty] }
                default { return [::md::t $lang score.points n $d] }
            }
        }
    }
    ::md::t $lang score.points n $d
}
