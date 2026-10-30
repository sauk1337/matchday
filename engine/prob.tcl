# Matchday - engine/prob.tcl
# Win probabilities.
#
# Football: an independent-Poisson goals model. Expected goals for each
# side are fitted to the bookmakers' pre-match 1X2 prices (implied,
# overround removed); during the match the remaining expected goals are
# scaled by the time left and adjusted for red cards, then combined with
# the current score. Without odds, neutral priors are used.
#
# Other sports: ESPN's own live win probability (summary feed) or the
# implied probability of the pre-game moneyline.

namespace eval ::md::prob {
    variable pre        ;# uid -> {lh la src}
    array set pre {}
}

proc ::md::prob::pois {l kmax} {
    set p [expr {exp(-$l)}]
    set out [list $p]
    for {set k 1} {$k <= $kmax} {incr k} {
        set p [expr {$p * $l / $k}]
        lappend out $p
    }
    return $out
}

# P(home win, draw, away win) given remaining expected goals and score
proc ::md::prob::outcome {lh la {sh 0} {sa 0} {kmax 10}} {
    set ph [pois $lh $kmax]
    set pa [pois $la $kmax]
    set w 0.0; set d 0.0; set l 0.0
    set i 0
    foreach x $ph {
        set j 0
        foreach y $pa {
            set p [expr {$x * $y}]
            set fh [expr {$sh + $i}]
            set fa [expr {$sa + $j}]
            if {$fh > $fa} { set w [expr {$w + $p}] } elseif {$fh == $fa} { set d [expr {$d + $p}] } else { set l [expr {$l + $p}] }
            incr j
        }
        incr i
    }
    set s [expr {$w + $d + $l}]
    list [expr {$w / $s}] [expr {$d / $s}] [expr {$l / $s}]
}

# Fit (lh, la) to target 1X2 probabilities: coarse grid then refinement
proc ::md::prob::fit {th td ta} {
    set best {1.4 1.1}
    set be 1e9
    foreach step {0.2 0.04 0.01} span {4.0 0.2 0.04} {
        lassign $best ch ca
        if {$step == 0.2} { set h0 0.2; set h1 4.0; set a0 0.2; set a1 4.0 } else {
            set h0 [expr {max(0.05, $ch - $span)}]; set h1 [expr {$ch + $span}]
            set a0 [expr {max(0.05, $ca - $span)}]; set a1 [expr {$ca + $span}]
        }
        for {set h $h0} {$h <= $h1 + 1e-9} {set h [expr {$h + $step}]} {
            for {set a $a0} {$a <= $a1 + 1e-9} {set a [expr {$a + $step}]} {
                lassign [outcome $h $a 0 0 7] w d l
                set e [expr {($w - $th) ** 2 + ($d - $td) ** 2 + ($l - $ta) ** 2}]
                if {$e < $be} { set be $e; set best [list $h $a] }
            }
        }
    }
    return $best
}

# Remember the pre-match model for a match (from summary odds or priors)
proc ::md::prob::prematch {uid odds} {
    variable pre
    if {[info exists pre($uid)] && [lindex $pre($uid) 2] eq "odds"} { return $pre($uid) }
    if {[dict size $odds] && [dict get $odds d] > 0} {
        lassign [fit [dict get $odds h] [dict get $odds d] [dict get $odds a]] lh la
        set pre($uid) [list $lh $la odds]
    } elseif {![info exists pre($uid)]} {
        set pre($uid) [list [::md::cfg prob.prior_home 1.45] [::md::cfg prob.prior_away 1.15] prior]
    }
    return $pre($uid)
}

proc ::md::prob::_minute {m} {
    if {[regexp {^(\d+)(?:\+(\d+))?} [dict get $m minute] -> a b]} {
        return [expr {[scan $a %d] + ($b eq "" ? 0 : [scan $b %d])}]
    }
    if {[dict get $m code] eq "ht"} { return 45 }
    return 0
}

proc ::md::prob::_reds {m side} {
    set n 0
    foreach e [dict get $m events] {
        if {[dict get $e side] eq $side && [dict get $e type] in {red yred}} { incr n }
    }
    return $n
}

# In-play football probability: dict {h d a src}
#   reds: optional {h n a n} override (the narrator tracks its own)
proc ::md::prob::soccer {m {reds ""}} {
    variable pre
    set uid [dict get $m uid]
    if {![info exists pre($uid)]} { prematch $uid {} }
    lassign $pre($uid) lh la src
    set sh [dict get $m home score]; set sa [dict get $m away score]
    if {![string is integer -strict $sh]} { set sh 0 }
    if {![string is integer -strict $sa]} { set sa 0 }
    set state [dict get $m state]
    if {$state eq "post"} {
        set r [expr {$sh > $sa ? {1.0 0.0 0.0} : ($sh == $sa ? {0.0 1.0 0.0} : {0.0 0.0 1.0})}]
        return [dict create h [lindex $r 0] d [lindex $r 1] a [lindex $r 2] src [expr {$src eq "odds" ? "model" : "prior"}]]
    }
    set min [expr {$state eq "pre" ? 0 : [_minute $m]}]
    set et [expr {[string is integer -strict [dict get $m period]] && [dict get $m period] >= 3}]
    # expected length includes ~4' of added time; a few seconds always remain
    set end [expr {$et ? 122 : 94}]
    set f [expr {max(0.5, $end - $min) / 94.0}]
    # late goals are slightly more frequent
    if {$min >= 75} { set f [expr {$f * 1.1}] }
    if {$reds eq ""} { set reds [dict create h [_reds $m h] a [_reds $m a]] }
    set rh [dict get $reds h]; set ra [dict get $reds a]
    set lh [expr {$lh * $f * pow(0.72, $rh) * pow(1.22, $ra)}]
    set la [expr {$la * $f * pow(0.72, $ra) * pow(1.22, $rh)}]
    lassign [outcome $lh $la $sh $sa] w d l
    dict create h $w d $d a $l src [expr {$src eq "odds" ? "model" : "prior"}]
}

# Async: probability for any match. cb gets ok {h d a src} | none
proc ::md::prob::get {m cb} {
    if {[dict get $m kind] ne "team"} { after 0 [linsert $cb end none {}]; return }
    ::md::espn::summary [dict get $m lkey] [dict get $m eid] [list ::md::prob::_got $m $cb] \
        [expr {[dict get $m state] eq "in" ? 15 : 600}]
}

proc ::md::prob::_got {m cb status r} {
    if {$status ne "ok"} {
        if {[dict get $m sport] eq "soccer"} { {*}$cb ok [soccer $m]; return }
        {*}$cb none {}
        return
    }
    if {[dict get $m sport] eq "soccer"} {
        prematch [dict get $m uid] [dict get $r odds]
        {*}$cb ok [soccer $m]
        return
    }
    if {[dict exists $r winprob]} {
        {*}$cb ok [dict merge [dict get $r winprob] {src espn}]
        return
    }
    set o [dict get $r odds]
    if {[dict size $o] && [dict get $m state] eq "pre"} {
        {*}$cb ok [dict create h [dict get $o h] d [dict get $o d] a [dict get $o a] src odds]
        return
    }
    {*}$cb none {}
}

proc ::md::prob::pct {x} { expr {int(round($x * 100))} }

# "Real Madrid 72% · draw 19% · Sevilla 9%"
proc ::md::prob::line {lang m p} {
    set h [::md::render::tn [dict get $m home]]
    set a [::md::render::tn [dict get $m away]]
    set parts [list "$h {b}[pct [dict get $p h]]%{b}"]
    if {[dict get $p d] > 0.005} { lappend parts "[::md::t $lang prob.draw] {b}[pct [dict get $p d]]%{b}" }
    lappend parts "$a {b}[pct [dict get $p a]]%{b}"
    set key [dict get {model prob.model odds prob.odds espn prob.espn prior prob.prior} [dict get $p src]]
    return "{s:dot} [::md::t $lang $key]: [join $parts " {c:dim}·{/c} "]"
}

# probability that the given side wins before kick-off (from odds/prior)
proc ::md::prob::pre_win {uid side} {
    variable pre
    if {![info exists pre($uid)] || [lindex $pre($uid) 2] ne "odds"} { return "" }
    lassign $pre($uid) lh la
    lassign [outcome $lh $la 0 0] w d l
    expr {$side eq "h" ? $w : $l}
}

proc ::md::prob::gc {} {
    variable pre
    if {[array size pre] > 500} { array unset pre }
}

proc ::md::prob::c_prob {ctx argv} {
    ::md::cmd::with_team $ctx [join $argv] [list ::md::prob::_c1 $ctx]
}

proc ::md::prob::_c1 {ctx tkey} {
    set m [::md::cmd::pick_match [::md::cmd::team_matches $tkey]]
    if {$m eq "" || [dict get $m state] eq "post"} {
        ::md::teams::schedule $tkey 1 [list ::md::prob::_c2 $ctx $tkey]
        return
    }
    get $m [list ::md::prob::_c3 $ctx $m]
}

proc ::md::prob::_c2 {ctx tkey status data} {
    set m ""
    foreach x $data { if {[dict get $x state] eq "pre"} { set m $x; break } }
    if {$m eq ""} { ::md::cmd::err $ctx team.no_match team [::md::teams::label $tkey]; return }
    get $m [list ::md::prob::_c3 $ctx $m]
}

proc ::md::prob::_c3 {ctx m status p} {
    set lang [dict get $ctx lang]
    if {$status ne "ok"} { ::md::cmd::err $ctx prob.none teams [::md::render::teams $m]; return }
    ::md::reply $ctx "[::md::render::line $lang $m [dict get $ctx tz] 1] [line $lang $m $p]"
}

namespace eval ::md::cmd {
    def prob any ::md::prob::c_prob 1
}
