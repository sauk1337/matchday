# Matchday - features/player.tcl
# !player <name>: profile, season stats per competition, recent form and
# next game, for any sport ESPN covers.

namespace eval ::md::player {}

proc ::md::player::c_player {ctx argv} {
    set q [join $argv]
    ::md::espn::player_search $q [list ::md::player::_found $ctx $q]
}

proc ::md::player::_found {ctx q status res} {
    if {$status ne "ok" || ![llength $res]} { ::md::cmd::err $ctx player.notfound query $q; return }
    set n [::md::norm $q]
    # rank by name similarity, ESPN relevance order breaks ties
    set ranked {}
    set i 0
    foreach r $res {
        set nm [::md::norm [dict get $r name]]
        set s [::md::mscore $n [list $nm]]
        # surname-only queries ("mbappe") are fine, but ESPN's relevance
        # order matters more than an exact surname (lebron -> LeBron James)
        if {$n eq [lindex $nm end] && $s < 88} { set s 88 }
        lappend ranked [list [expr {$s - 5 * $i}] $r]
        incr i
    }
    set ranked [lsort -integer -decreasing -index 0 $ranked]
    set best [lindex $ranked 0 1]
    set alts {}
    foreach x [lrange $ranked 1 3] {
        set r [lindex $x 1]
        if {[lindex $x 0] >= [lindex $ranked 0 0] - 20} {
            lappend alts [expr {[dict get $r team] ne "" ? "[dict get $r name] ([dict get $r team])" : [dict get $r name]}]
        }
    }
    ::md::espn::player [dict get $best sport] [dict get $best slug] [dict get $best pid] \
        [list ::md::player::_show $ctx $best $alts]
}

proc ::md::player::_show {ctx best alts status p} {
    set lang [dict get $ctx lang]
    if {$status ne "ok"} { ::md::cmd::err $ctx err.provider; return }
    set sport [dict get $best sport]
    set head "{b}[dict get $p name]{b}"
    set team [dict get $p team]
    if {$team eq ""} { set team [dict get $best team] }
    set bits {}
    if {$team ne ""} { lappend bits $team }
    set pos [dict get $p pos]
    if {[dict get $p jersey] ne ""} { append pos " #[dict get $p jersey]" }
    if {[string trim $pos] ne ""} { lappend bits [string trim $pos] }
    if {[dict get $p age] ne ""} { lappend bits [::md::t $lang player.age n [dict get $p age]] }
    if {[dict get $p nat] ne ""} { lappend bits [dict get $p nat] }
    set lines [list [expr {[llength $bits] ? "$head {c:dim}·{/c} [join $bits " {c:dim}·{/c} "]" : $head}]]

    set labels [dict get $p labels]
    set names [dict get $p names]
    set splits [dict get $p splits]
    if {[llength $splits]} {
        set parts {}
        foreach s [lrange [_relevant $splits] 0 2] {
            set stats [dict create]
            foreach k $names l $labels v [dict get $s stats] {
                if {$k ne ""} { dict set stats $k [list $l $v] }
            }
            set f [_fmt $lang $sport $stats]
            if {$f ne "" && [dict get $s name] ne ""} { lappend parts "{c:league}[dict get $s name]{/c}: $f" }
        }
        if {[llength $parts]} { lappend lines [join $parts " {c:dim}|{/c} "] }
    } elseif {[dict exists $p summary]} {
        lassign [dict get $p summary] title sum
        set kv {}
        foreach x [lrange $sum 0 7] {
            if {[lindex $x 0] ne "" && [lindex $x 1] ne ""} { lappend kv "[lindex $x 0] {b}[lindex $x 1]{b}" }
        }
        if {[llength $kv]} { lappend lines "{c:league}$title{/c}: [join $kv " · "]" }
    }
    set extra {}
    set last [dict get $p last]
    if {[llength $last] && [dict get $last n] > 0 && $sport eq "soccer"} {
        set t [dict get $last totals]
        lappend extra [::md::t $lang player.last n [dict get $last n] \
            goals [expr {int([::md::dg $t 0 totalGoals])}] assists [expr {int([::md::dg $t 0 goalAssists])}]]
    }
    set nx [dict get $p next]
    if {[llength $nx]} {
        lappend extra [::md::t $lang player.next name [dict get $nx name] \
            when [::md::render::when $lang [dict get $nx start] [dict get $ctx tz]] league [dict get $nx league]]
    }
    if {[llength $alts]} { lappend extra "{c:dim}[::md::t $lang player.also list [join $alts ", "]]{/c}" }
    if {[llength $extra]} { lappend lines [join $extra " {c:dim}·{/c} "] }
    ::md::reply_lines $ctx $lines 4
}

# Current-season splits first (highest year in the name), then the rest
proc ::md::player::_relevant {splits} {
    set scored {}
    set i 0
    foreach s $splits {
        set y 0
        regexp {(\d{4})} [dict get $s name] -> y
        lappend scored [list [expr {$y * 100 - $i}] $s]
        incr i
    }
    set out {}
    foreach x [lsort -integer -decreasing -index 0 $scored] { lappend out [lindex $x 1] }
    return $out
}

proc ::md::player::_v {stats k} {
    if {[dict exists $stats $k]} { return [lindex [dict get $stats $k] 1] }
    return ""
}

proc ::md::player::_fmt {lang sport stats} {
    if {$sport eq "soccer"} {
        set parts {}
        set g [_v $stats totalGoals]
        set a [_v $stats goalAssists]
        set st [_v $stats starts]
        if {$st eq ""} { set st [_v $stats appearances] }
        if {$g ne ""} { lappend parts [::md::t $lang player.goals n "{b}$g{b}"] }
        if {$a ne ""} { lappend parts [::md::t $lang player.assists n "{b}$a{b}"] }
        if {$st ne ""} { lappend parts [::md::t $lang player.starts n $st] }
        set sh [_v $stats totalShots]
        if {$sh ne ""} { lappend parts [::md::t $lang player.shots n $sh s [_v $stats shotsOnTarget]] }
        set y [_v $stats yellowCards]; set r [_v $stats redCards]
        if {$y ne "" && $y > 0} { lappend parts "{s:yellow}$y" }
        if {$r ne "" && $r > 0} { lappend parts "{s:red}$r" }
        set cs [_v $stats cleanSheet]
        if {$cs ne "" && $cs > 0} { lappend parts [::md::t $lang player.cleansheets n $cs] }
        return [join $parts ", "]
    }
    # other sports: ESPN abbreviations, most relevant first
    set prefs {
        basketball {gamesPlayed avgPoints avgRebounds avgAssists fieldGoalPct threePointPct avgMinutes}
        hockey {gamesPlayed goals assists points plusMinus}
    }
    set parts {}
    if {[dict exists $prefs $sport]} {
        set want [dict get $prefs $sport]
    } else {
        set want [lrange [dict keys $stats] 0 7]
    }
    foreach k $want {
        if {![dict exists $stats $k]} continue
        lassign [dict get $stats $k] l v
        lappend parts "$l {b}$v{b}"
    }
    if {![llength $parts]} {
        foreach k [lrange [dict keys $stats] 0 7] {
            lassign [dict get $stats $k] l v
            lappend parts "$l {b}$v{b}"
        }
    }
    join $parts " · "
}

namespace eval ::md::cmd {
    def player any ::md::player::c_player 1
}
