# Matchday - features/info.tcl
# Information commands: live, today, match, next, last, table, scorers,
# lineup, stats, form, h2h, leagues, help, more, about.

namespace eval ::md::cmd {}

# ---------------------------------------------------------------- helpers

# Leagues relevant for a context when no filter is given
proc ::md::cmd::ctx_leagues {ctx} {
    set chan [dict get $ctx chan]
    if {$chan ne ""} {
        set l [::md::chan::get $chan leagues]
        if {[llength $l]} { return $l }
    }
    set out {}
    foreach ref [dict keys [::md::subs::follows [dict get $ctx ukey]]] {
        if {[string match league:* $ref]} { lappend out [string range $ref 7 end] }
    }
    if {[llength $out]} { return $out }
    return [::md::cfg leagues.default {esp.1 eng.1 ita.1 ger.1 fra.1 uefa.champions}]
}

proc ::md::cmd::_bylg {lang matches tz {maxper 99}} {
    # group lines by competition: "[LALIGA] a | b | c"
    set groups {}
    foreach m $matches { dict lappend groups [dict get $m lkey] $m }
    set lines {}
    dict for {lk ms} $groups {
        set parts {}
        foreach m [lrange $ms 0 [expr {$maxper - 1}]] { lappend parts [::md::render::line $lang $m $tz] }
        set extra [expr {[llength $ms] - $maxper}]
        set l "{c:league}{b}[::md::catalog::label $lk]{b}{/c} [join $parts " {c:dim}|{/c} "]"
        if {$extra > 0} { append l " {c:dim}(+$extra){/c}" }
        lappend lines $l
    }
    return $lines
}

# Fetch scoreboards for leagues (on demand), then call cb with matches
proc ::md::cmd::fetch_boards {lkeys date cb} {
    set st [dict create pending [llength $lkeys] out {} errors {}]
    set id [incr ::md::cmd::_fb]
    set ::md::cmd::_fbs($id) $st
    if {![llength $lkeys]} { after 0 [list {*}$cb {} {}]; unset ::md::cmd::_fbs($id); return }
    foreach lk $lkeys {
        ::md::prov::call scoreboard $lk $date [list ::md::cmd::_fb_got $id $lk $date $cb]
    }
}
set ::md::cmd::_fb 0

proc ::md::cmd::_fb_got {id lk date cb status data} {
    upvar #0 ::md::cmd::_fbs($id) st
    if {$status eq "ok"} {
        foreach m $data {
            ::md::poll::store $m
            dict lappend st out $m
            # live or imminent: keep watching this competition for a while
            if {[dict get $m state] eq "in" || ([dict get $m state] eq "pre" && [dict get $m start] - [clock seconds] < 1800)} {
                ::md::poll::watch $lk 7200
            }
        }
    } else {
        dict lappend st errors $lk
    }
    dict incr st pending -1
    if {[dict get $st pending] <= 0} {
        set out [::md::poll::sortm [dict get $st out]]
        set errs [dict get $st errors]
        unset ::md::cmd::_fbs($id)
        {*}$cb $out $errs
    }
}

# matches of a team (key "sport:id") among known snapshots
proc ::md::cmd::team_matches {tkey {states ""}} {
    set out {}
    foreach m [::md::poll::matches "" $states] {
        if {$tkey in [::md::dispatch::team_keys $m]} { lappend out $m }
    }
    return $out
}

# Best "current" match for a team: live > today > nearest
proc ::md::cmd::pick_match {ms} {
    set now [clock seconds]
    set best ""
    set bestd 1e12
    foreach m $ms {
        if {[dict get $m state] eq "in"} { return $m }
        set d [expr {abs([dict get $m start] - $now)}]
        # prefer recently finished over far-future
        if {[dict get $m state] eq "post"} { set d [expr {$d * 0.8}] }
        if {$d < $bestd} { set bestd $d; set best $m }
    }
    return $best
}

# ---------------------------------------------------------------- live / today

proc ::md::cmd::c_live {ctx argv} {
    set f [filter [join $argv]]
    set lang [dict get $ctx lang]
    set tz [dict get $ctx tz]
    switch -- [dict get $f type] {
        league {
            set lk [dict get $f value]
            fetch_boards [list $lk] "" [list ::md::cmd::_live_out $ctx $f]
            return
        }
        team {
            with_team $ctx [dict get $f value] [list ::md::cmd::_live_team $ctx]
            return
        }
    }
    set ms [::md::poll::matches "" in]
    if {[dict get $f type] eq "sport"} {
        set tmp {}
        foreach m $ms { if {[dict get $m sport] eq [dict get $f value]} { lappend tmp $m } }
        set ms $tmp
    } elseif {[dict get $f type] eq "none"} {
        set lks [ctx_leagues $ctx]
        set tmp {}
        foreach m $ms { if {[dict get $m lkey] in $lks} { lappend tmp $m } }
        # nothing in our leagues? show whatever is live
        if {[llength $tmp]} { set ms $tmp }
    }
    if {![llength $ms]} {
        if {[dict get $f type] eq "none"} {
            # we may not be polling those leagues: fetch them now
            fetch_boards [lrange [ctx_leagues $ctx] 0 7] "" [list ::md::cmd::_live_out $ctx $f]
            return
        }
        reply $ctx [::md::t $lang live.none]
        return
    }
    reply_lines $ctx [_bylg $lang $ms $tz]
}

proc ::md::cmd::_live_out {ctx f ms errs} {
    set lang [dict get $ctx lang]
    set live {}
    foreach m $ms { if {[dict get $m state] eq "in"} { lappend live $m } }
    if {![llength $live]} {
        # show what is next instead of a bare "nothing"
        set next {}
        foreach m $ms { if {[dict get $m state] eq "pre"} { lappend next $m } }
        if {[llength $next]} {
            reply $ctx [::md::t $lang live.none_next next [::md::render::line $lang [lindex $next 0] [dict get $ctx tz] 1]]
        } else {
            reply $ctx [::md::t $lang live.none]
        }
        return
    }
    reply_lines $ctx [_bylg $lang $live [dict get $ctx tz]]
}

proc ::md::cmd::_live_team {ctx tkey} {
    set ms [team_matches $tkey in]
    set lang [dict get $ctx lang]
    if {[llength $ms]} {
        reply_lines $ctx [_bylg $lang $ms [dict get $ctx tz]]
        return
    }
    reply $ctx [::md::t $lang live.team_none team [::md::teams::label $tkey] cmd [::md::cmdhint $lang next]]
}

proc ::md::cmd::c_today {ctx argv} {
    set lang [dict get $ctx lang]
    set tz [dict get $ctx tz]
    # optional trailing date word
    set date ""
    if {[llength $argv]} {
        set d [::md::parse_day [lindex $argv end] $tz]
        if {$d ne ""} { set date $d; set argv [lrange $argv 0 end-1] }
    }
    set f [filter [join $argv]]
    switch -- [dict get $f type] {
        league { set lks [list [dict get $f value]] }
        team {
            with_team $ctx [dict get $f value] [list ::md::cmd::_today_team $ctx $date]
            return
        }
        sport {
            set lks {}
            foreach lk [ctx_leagues $ctx] { if {[::md::catalog::get $lk sport] eq [dict get $f value]} { lappend lks $lk } }
            if {![llength $lks]} {
                foreach lk [::md::catalog::keys [dict get $f value]] {
                    if {[::md::catalog::get $lk tier] == 1} { lappend lks $lk }
                }
            }
        }
        default { set lks [ctx_leagues $ctx] }
    }
    set qdate $date
    if {$qdate eq ""} { set qdate [::md::ymd $tz 0] }
    fetch_boards [lrange $lks 0 9] $date [list ::md::cmd::_today_out $ctx $qdate]
}

proc ::md::cmd::_today_out {ctx day ms errs} {
    set lang [dict get $ctx lang]
    set tz [dict get $ctx tz]
    set sel {}
    foreach m $ms {
        if {[::md::tfmt [dict get $m start] %Y%m%d $tz] eq $day || [dict get $m state] eq "in"} { lappend sel $m }
    }
    if {![llength $sel]} {
        set when [::md::tfmt [clock scan $day -format %Y%m%d -timezone [::md::tzname $tz]] %d/%m $tz]
        reply $ctx [::md::t $lang today.none date $when]
        return
    }
    reply_lines $ctx [_bylg $lang $sel $tz]
}

proc ::md::cmd::_today_team {ctx date tkey} {
    ::md::teams::schedule $tkey 1 [list ::md::cmd::_today_team2 $ctx $date $tkey]
}

proc ::md::cmd::_today_team2 {ctx date tkey status data} {
    set lang [dict get $ctx lang]
    set tz [dict get $ctx tz]
    if {$date eq ""} { set date [::md::ymd $tz 0] }
    set ms [team_matches $tkey]
    if {$status eq "ok"} { lappend ms {*}$data }
    set sel {}
    set seen {}
    foreach m $ms {
        if {[dict exists $seen [dict get $m uid]]} continue
        dict set seen [dict get $m uid] 1
        if {[::md::tfmt [dict get $m start] %Y%m%d $tz] eq $date} {
            set fresh [::md::poll::match [dict get $m uid]]
            lappend sel [expr {$fresh ne "" ? $fresh : $m}]
        }
    }
    if {![llength $sel]} {
        reply $ctx [::md::t $lang team.no_match_day team [::md::teams::label $tkey]]
        return
    }
    foreach m $sel { reply $ctx [::md::render::line $lang $m $tz 1] }
}

proc ::md::cmd::today_digest {chan} {
    set lang [::md::chan::lang $chan]
    set tz [::md::chan::get $chan tz]
    set day [::md::ymd $tz 0]
    set sel {}
    foreach m [::md::poll::matches [::md::chan::get $chan leagues]] {
        if {[::md::tfmt [dict get $m start] %Y%m%d $tz] eq $day} { lappend sel $m }
    }
    if {![llength $sel]} return
    ::md::out::send $chan [::md::t $lang digest.chan n [llength $sel]] -queue help
    foreach l [_bylg $lang $sel $tz 8] { ::md::out::send $chan $l -queue help }
}

# ---------------------------------------------------------------- match detail

proc ::md::cmd::c_match {ctx argv} {
    with_team $ctx [join $argv] [list ::md::cmd::_match_team $ctx detail]
}

proc ::md::cmd::_match_team {ctx what tkey} {
    set ms [team_matches $tkey]
    set m [pick_match $ms]
    if {$m ne "" && ([dict get $m state] eq "in" || abs([dict get $m start] - [clock seconds]) < 86400)} {
        _match_go $ctx $what $m
        return
    }
    # look further: fixtures and results
    ::md::teams::schedule $tkey 1 [list ::md::cmd::_match_sched $ctx $what $tkey 1]
}

proc ::md::cmd::_match_sched {ctx what tkey fixture status data} {
    set ms [team_matches $tkey]
    if {$status eq "ok"} { lappend ms {*}$data }
    set m [pick_match $ms]
    if {$m eq "" && $fixture} {
        ::md::teams::schedule $tkey 0 [list ::md::cmd::_match_sched $ctx $what $tkey 0]
        return
    }
    if {$m eq ""} {
        err $ctx team.no_match team [::md::teams::label $tkey]
        return
    }
    _match_go $ctx $what $m
}

proc ::md::cmd::_match_go {ctx what m} {
    if {[dict get $m kind] ne "team" || [dict get $m state] eq "pre" && $what eq "detail"} {
        set lang [dict get $ctx lang]
        set l [::md::render::line $lang $m [dict get $ctx tz] 1]
        if {[dict get $m state] eq "pre"} {
            if {[dict get $m venue] ne ""} { append l " {c:dim}@ [dict get $m venue]{/c}" }
            if {[llength [dict get $m tv]]} { append l " {c:dim}{s:tv} [join [lrange [dict get $m tv] 0 2] ", "]{/c}" }
        }
        reply $ctx $l
        if {[dict get $m state] eq "pre" || [dict get $m kind] ne "team"} return
    }
    ::md::espn::summary [dict get $m lkey] [dict get $m eid] [list ::md::cmd::_match_sum $ctx $what $m]
}

proc ::md::cmd::_match_sum {ctx what m status s} {
    set lang [dict get $ctx lang]
    set tz [dict get $ctx tz]
    if {$status ne "ok"} {
        # fall back to the scoreboard snapshot
        reply $ctx [::md::render::line $lang $m $tz 1]
        if {$what ne "detail"} { err $ctx err.nodata }
        return
    }
    set sm [dict get $s match]
    # summary header has no minute/events beyond details; merge with snapshot
    if {[llength [dict get $m events]] > [llength [dict get $sm events]]} { dict set sm events [dict get $m events] }
    if {[dict get $sm minute] eq ""} { dict set sm minute [dict get $m minute] }
    dict set sm lkey [dict get $m lkey]
    dict set sm lname [dict get $m lname]
    switch -- $what {
        detail  {
            set lines [detail_lines $lang $sm $s $tz]
            set p [_prob_from_summary $sm $s]
            if {$p ne ""} { lappend lines [::md::prob::line $lang $sm $p] }
            reply_lines $ctx $lines 7
        }
        lineup  { reply_lines $ctx [lineup_lines $lang $sm $s] 6 }
        stats   { reply_lines $ctx [stats_lines $lang $sm $s] 4 }
    }
}

# win probability for !match: football model / ESPN live / pre-game odds
proc ::md::cmd::_prob_from_summary {m s} {
    if {[dict get $m state] eq "post"} { return "" }
    if {[dict get $m sport] eq "soccer"} {
        ::md::prob::prematch [dict get $m uid] [dict get $s odds]
        return [::md::prob::soccer $m]
    }
    if {[dict exists $s winprob] && [dict get $m state] eq "in"} {
        return [dict merge [dict get $s winprob] {src espn}]
    }
    set o [dict get $s odds]
    if {[dict size $o]} { return [dict create h [dict get $o h] d [dict get $o d] a [dict get $o a] src odds] }
    return ""
}

proc ::md::cmd::detail_lines {lang m s tz} {
    set lines [list [::md::render::line $lang $m $tz 1]]
    set g [::md::render::scorers_suffix $lang $m]
    if {$g ne ""} { lappend lines "{s:goal} [string trim [string map {"{c:dim}(" "" "){/c}" ""} $g]]" }
    set cards {}
    foreach e [dict get $m events] {
        set t [dict get $e type]
        if {$t in {yellow yred red}} {
            set sym [dict get {yellow {{s:yellow}} yred {{s:yred}} red {{s:red}}} $t]
            lappend cards "$sym [dict get $e player] [dict get $e min]"
        }
    }
    if {[llength $cards]} { lappend lines [join $cards ", "] }
    set st [stats_brief $lang $s]
    if {$st ne ""} { lappend lines $st }
    set extra {}
    if {[dict get $s venue] ne ""} { lappend extra "@ [dict get $s venue]" }
    foreach o [dict get $s officials] {
        if {[string match -nocase *referee* [lindex $o 1]] || [lindex $o 1] eq ""} {
            lappend extra "[::md::t $lang word.referee]: [lindex $o 0]"
            break
        }
    }
    set f [dict get $s form]
    if {[dict size $f] == 2} {
        lappend extra "[::md::t $lang word.form]: [::md::render::tn [dict get $m home]] [form_str [dict get $f h] $lang] / [::md::render::tn [dict get $m away]] [form_str [dict get $f a] $lang]"
    }
    if {[llength $extra]} { lappend lines "{c:dim}[join $extra " · "]{/c}" }
    return $lines
}

proc ::md::cmd::form_str {f {lang en}} {
    set out ""
    foreach ch [split $f ""] {
        switch -- $ch {
            W { append out "{c:win}[::md::t $lang form.W]{/c}" }
            L { append out "{c:loss}[::md::t $lang form.L]{/c}" }
            D { append out "{c:draw}[::md::t $lang form.D]{/c}" }
            default { append out $ch }
        }
    }
    return $out
}

proc ::md::cmd::_stat {s side name} {
    ::md::dg $s "" stats $side $name
}

proc ::md::cmd::stats_brief {lang s} {
    set ph [_stat $s h possessionPct]; set pa [_stat $s a possessionPct]
    if {$ph eq ""} { return "" }
    set parts [list "[::md::t $lang stat.possession] [expr {round($ph)}]%-[expr {round($pa)}]%"]
    set sh [_stat $s h totalShots]; set sa [_stat $s a totalShots]
    if {$sh ne ""} {
        lappend parts "[::md::t $lang stat.shots] ${sh}([_stat $s h shotsOnTarget])-${sa}([_stat $s a shotsOnTarget])"
    }
    set ch [_stat $s h wonCorners]
    if {$ch ne ""} { lappend parts "[::md::t $lang stat.corners] $ch-[_stat $s a wonCorners]" }
    return "{c:dim}[join $parts " · "]{/c}"
}

proc ::md::cmd::stats_lines {lang m s} {
    set rows {
        possessionPct possession totalShots shots shotsOnTarget on_target wonCorners corners
        foulsCommitted fouls yellowCards yellows redCards reds offsides offsides saves saves
        accuratePasses passes passPct pass_pct
    }
    set parts {}
    foreach {k label} $rows {
        set h [_stat $s h $k]; set a [_stat $s a $k]
        if {$h eq "" && $a eq ""} continue
        if {$k eq "passPct"} {
            catch {set h "[expr {round($h * 100)}]%"; set a "[expr {round($a * 100)}]%"}
        } elseif {$k eq "possessionPct"} {
            catch {set h "[expr {round($h)}]%"; set a "[expr {round($a)}]%"}
        }
        lappend parts "[::md::t $lang stat.$label] {b}$h{b}-{b}$a{b}"
    }
    if {![llength $parts]} { return [list [::md::t $lang err.nodata]] }
    list [::md::render::score $m] [join $parts " {c:dim}|{/c} "]
}

proc ::md::cmd::lineup_lines {lang m s} {
    set lu [dict get $s lineups]
    if {![dict size $lu]} { return [list [::md::t $lang lineup.none teams [::md::render::teams $m]]] }
    set lines {}
    foreach side {h a} key {home away} {
        if {![dict exists $lu $side]} continue
        set d [dict get $lu $side]
        set xi {}
        foreach p [dict get $d xi] {
            set n [dict get $p short]
            if {$n eq ""} { set n [dict get $p name] }
            lappend xi $n
        }
        set f [dict get $d formation]
        set head "{b}[::md::render::tn [dict get $m $key]]{b}"
        if {$f ne ""} { append head " ($f)" }
        lappend lines "$head: [join $xi ", "]"
        set bench {}
        foreach p [lrange [dict get $d bench] 0 11] {
            set n [dict get $p short]
            if {$n eq ""} { set n [dict get $p name] }
            lappend bench $n
        }
        if {[llength $bench]} { lappend lines "{c:dim}[::md::t $lang word.bench]: [join $bench ", "]{/c}" }
    }
    return $lines
}

proc ::md::cmd::c_lineup {ctx argv} {
    with_team $ctx [join $argv] [list ::md::cmd::_lineup $ctx]
}
proc ::md::cmd::_lineup {ctx tkey} {
    set m [pick_match [team_matches $tkey]]
    if {$m eq ""} {
        ::md::teams::schedule $tkey 1 [list ::md::cmd::_match_sched $ctx lineup $tkey 1]
        return
    }
    ::md::espn::summary [dict get $m lkey] [dict get $m eid] [list ::md::cmd::_match_sum $ctx lineup $m]
}

proc ::md::cmd::c_stats {ctx argv} {
    with_team $ctx [join $argv] [list ::md::cmd::_stats $ctx]
}
proc ::md::cmd::_stats {ctx tkey} {
    set m [pick_match [team_matches $tkey]]
    if {$m eq ""} {
        ::md::teams::schedule $tkey 0 [list ::md::cmd::_match_sched $ctx stats $tkey 0]
        return
    }
    if {[dict get $m state] eq "pre"} {
        err $ctx stats.notyet teams [::md::render::teams $m]
        return
    }
    ::md::espn::summary [dict get $m lkey] [dict get $m eid] [list ::md::cmd::_match_sum $ctx stats $m]
}

# ---------------------------------------------------------------- next / last / form

proc ::md::cmd::c_next {ctx argv} { _nextlast $ctx $argv 1 }
proc ::md::cmd::c_last {ctx argv} { _nextlast $ctx $argv 0 }

proc ::md::cmd::_nextlast {ctx argv fixture} {
    set f [filter [join $argv]]
    switch -- [dict get $f type] {
        league {
            set lk [dict get $f value]
            fetch_boards [list $lk] "" [list ::md::cmd::_nl_league $ctx $lk $fixture]
        }
        none - all - sport {
            fetch_boards [lrange [ctx_leagues $ctx] 0 5] "" [list ::md::cmd::_nl_list $ctx $fixture]
        }
        default {
            with_team $ctx [dict get $f value] [list ::md::cmd::_nl_team $ctx $fixture]
        }
    }
}

proc ::md::cmd::_nl_pick {ms fixture n} {
    set sel {}
    foreach m $ms {
        if {$fixture && [dict get $m state] eq "pre"} { lappend sel $m }
        if {!$fixture && [dict get $m state] eq "post"} { lappend sel $m }
    }
    set sel [::md::poll::sortm $sel]
    if {$fixture} { return [lrange $sel 0 [expr {$n - 1}]] }
    lreverse [lrange $sel end-[expr {$n - 1}] end]
}

proc ::md::cmd::_nl_league {ctx lk fixture ms errs} {
    set lang [dict get $ctx lang]
    set sel [_nl_pick $ms $fixture 10]
    if {![llength $sel]} {
        reply $ctx [::md::t $lang [expr {$fixture ? "next.none" : "last.none"}] what [::md::catalog::label $lk]]
        return
    }
    set lines {}
    foreach m $sel { lappend lines [::md::render::line $lang $m [dict get $ctx tz]] }
    reply_lines $ctx [list "{c:league}{b}[::md::catalog::label $lk]{b}{/c} [join $lines " {c:dim}|{/c} "]"]
}

proc ::md::cmd::_nl_list {ctx fixture ms errs} {
    set lang [dict get $ctx lang]
    set sel [_nl_pick $ms $fixture 12]
    if {![llength $sel]} {
        reply $ctx [::md::t $lang [expr {$fixture ? "next.none" : "last.none"}] what "-"]
        return
    }
    reply_lines $ctx [_bylg $lang $sel [dict get $ctx tz] 5]
}

proc ::md::cmd::_nl_team {ctx fixture tkey} {
    ::md::teams::schedule $tkey $fixture [list ::md::cmd::_nl_team2 $ctx $fixture $tkey]
}

proc ::md::cmd::_nl_team2 {ctx fixture tkey status data} {
    set lang [dict get $ctx lang]
    set tz [dict get $ctx tz]
    if {$status ne "ok"} { err $ctx err.provider; return }
    set sel [_nl_pick $data $fixture [expr {$fixture ? 3 : 5}]]
    set name [::md::teams::label $tkey]
    if {![llength $sel]} {
        reply $ctx [::md::t $lang [expr {$fixture ? "next.none" : "last.none"}] what $name]
        return
    }
    if {$fixture} {
        set parts {}
        foreach m $sel {
            set l [::md::render::line $lang $m $tz 1]
            if {[llength [dict get $m tv]] && $m eq [lindex $sel 0]} { append l " {c:dim}{s:tv} [join [lrange [dict get $m tv] 0 1] ", "]{/c}" }
            lappend parts $l
        }
        reply_lines $ctx [list "{b}$name{b}: [join $parts " {c:dim}|{/c} "]"]
    } else {
        set id [lindex [split $tkey :] 1]
        set parts {}
        set form ""
        foreach m $sel {
            append form [_result_letter $m $id]
            lappend parts "[form_str [_result_letter $m $id] $lang] [::md::render::score $m "" 0] {c:dim}[::md::tfmt [dict get $m start] %d/%m $tz]{/c}"
        }
        reply_lines $ctx [list "{b}$name{b} ([form_str $form $lang]): [join $parts " {c:dim}|{/c} "]"]
    }
}

proc ::md::cmd::_result_letter {m id} {
    set h [dict get $m home]; set a [dict get $m away]
    set hs [dict get $h score]; set as [dict get $a score]
    if {![string is integer -strict $hs] || ![string is integer -strict $as]} { return "?" }
    set mine [expr {[dict get $h id] eq $id ? "h" : "a"}]
    if {$hs == $as} {
        set so_h [dict get $h so]; set so_a [dict get $a so]
        if {$so_h ne "" && $so_a ne "" && $so_h != $so_a} {
            set w [expr {$so_h > $so_a ? "h" : "a"}]
            return [expr {$w eq $mine ? "W" : "L"}]
        }
        return D
    }
    set w [expr {$hs > $as ? "h" : "a"}]
    expr {$w eq $mine ? "W" : "L"}
}

proc ::md::cmd::c_form {ctx argv} {
    with_team $ctx [join $argv] [list ::md::cmd::_nl_team $ctx 0]
}

# ---------------------------------------------------------------- standings

proc ::md::cmd::c_table {ctx argv} {
    set lang [dict get $ctx lang]
    set full 0
    if {[llength $argv] && [::md::norm [lindex $argv end]] in {full all completa todo completo complete tutta komplett}} {
        set full 1
        set argv [lrange $argv 0 end-1]
    }
    set q [join $argv]
    if {$q eq ""} {
        set lk [lindex [ctx_leagues $ctx] 0]
        _table $ctx $lk "" $full
        return
    }
    set lk [::md::catalog::find $q]
    if {$lk ne ""} { _table $ctx $lk "" $full; return }
    # maybe "<league> <group>" e.g. "ucl A"
    if {[llength $argv] > 1} {
        set lk [::md::catalog::find [join [lrange $argv 0 end-1]]]
        if {$lk ne ""} { _table $ctx $lk [lindex $argv end] $full; return }
    }
    # a team: show its league around its position
    with_team $ctx $q [list ::md::cmd::_table_team $ctx $full]
}

proc ::md::cmd::_table_team {ctx full tkey} {
    set lk [::md::teams::main_league $tkey]
    if {$lk eq ""} { err $ctx err.nodata; return }
    _table $ctx $lk "" $full $tkey
}

proc ::md::cmd::_table {ctx lk group full {tkey ""}} {
    ::md::prov::call standings $lk [list ::md::cmd::_table_out $ctx $lk $group $full $tkey]
}

proc ::md::cmd::_table_out {ctx lk group full tkey status groups} {
    set lang [dict get $ctx lang]
    if {$status ne "ok" || ![llength $groups]} { err $ctx table.none league [::md::catalog::label $lk]; return }
    set sport [::md::catalog::get $lk sport]
    set tid [expr {$tkey ne "" ? [lindex [split $tkey :] 1] : ""}]
    # choose groups
    set sel {}
    if {$group ne ""} {
        foreach g $groups {
            set gn [::md::norm [dict get $g name]]
            if {[::md::norm $group] eq [lindex $gn end] || [string first [::md::norm $group] $gn] >= 0} { lappend sel $g }
        }
    } elseif {$tid ne ""} {
        foreach g $groups {
            foreach r [dict get $g rows] { if {[dict get $r id] eq $tid} { lappend sel $g; break } }
        }
    }
    if {![llength $sel]} { set sel $groups }
    set lines {}
    foreach g $sel {
        set rows [dict get $g rows]
        set title [::md::catalog::label $lk]
        if {[llength $groups] > 1} { append title " - [dict get $g name]" }
        if {$full} {
            lappend lines "{c:league}{b}$title{b}{/c}"
            foreach r $rows { lappend lines [_row_long $lang $sport $r $tid] }
            continue
        }
        # compact: top N, or window around the team
        set n [::md::cfg table.compact 10]
        if {$tid ne ""} {
            set pos 0
            set i 0
            foreach r $rows { if {[dict get $r id] eq $tid} { set pos $i }; incr i }
            set from [expr {max(0, $pos - 2)}]
            set win [lrange $rows $from [expr {$from + 4}]]
            set parts {}
            foreach r $win { lappend parts [_row_long $lang $sport $r $tid] }
            lappend lines "{c:league}{b}$title{b}{/c} [join $parts " {c:dim}|{/c} "]"
        } else {
            set parts {}
            foreach r [lrange $rows 0 [expr {$n - 1}]] { lappend parts [_row_short $sport $r $tid] }
            lappend lines "{c:league}{b}$title{b}{/c} [join $parts " "]"
        }
        if {[llength $lines] >= 6 && !$full} break
    }
    if {$full && [dict get $ctx chan] ne ""} {
        reply $ctx [::md::t $lang table.sent_priv]
        reply_priv $ctx $lines
        return
    }
    reply_lines $ctx $lines
}

proc ::md::cmd::_short {r} {
    set n [dict get $r short]
    if {$n eq ""} { set n [dict get $r name] }
    return $n
}

proc ::md::cmd::_row_short {sport r tid} {
    set n [_short $r]
    if {[dict get $r id] eq $tid} { set n "{u}$n{u}" }
    if {$sport in {soccer rugby australian-football}} {
        return "{c:rank}[dict get $r rank].{/c}$n {b}[dict get $r pts]{b}"
    }
    return "{c:rank}[dict get $r rank].{/c}$n {b}[dict get $r w]-[dict get $r l]{b}"
}

proc ::md::cmd::_row_long {lang sport r tid} {
    set n [_short $r]
    if {[dict get $r id] eq $tid} { set n "{u}$n{u}" }
    if {$sport in {soccer rugby australian-football}} {
        return [::md::t $lang table.row rank [dict get $r rank] team $n gp [dict get $r gp] w [dict get $r w] \
            d [dict get $r d] l [dict get $r l] gd [dict get $r gd] pts [dict get $r pts]]
    }
    set pct [dict get $r pct]
    set gb [dict get $r gb]
    return [::md::t $lang table.row_us rank [dict get $r rank] team $n w [dict get $r w] l [dict get $r l] pct $pct gb $gb]
}

# ---------------------------------------------------------------- scorers

proc ::md::cmd::c_scorers {ctx argv} {
    set what goals
    if {[llength $argv] && [::md::norm [lindex $argv end]] in {assists asistencias assistencias passes assist vorlagen}} {
        set what assists
        set argv [lrange $argv 0 end-1]
    }
    set q [join $argv]
    set lk [expr {$q eq "" ? [lindex [ctx_leagues $ctx] 0] : [::md::catalog::find $q]}]
    if {$lk eq ""} { err $ctx err.league_notfound query $q; return }
    if {[::md::catalog::get $lk sport] ne "soccer"} { err $ctx scorers.soccer_only; return }
    ::md::espn::leaders $lk [list ::md::cmd::_scorers_out $ctx $lk $what]
}

proc ::md::cmd::_scorers_out {ctx lk what status d} {
    set lang [dict get $ctx lang]
    if {$status ne "ok" || ![llength [::md::dg $d {} $what]]} { err $ctx err.nodata; return }
    set parts {}
    set i 0
    foreach p [lrange [dict get $d $what] 0 9] {
        incr i
        set t [dict get $p team]
        lappend parts "{c:rank}$i.{/c}[dict get $p name][expr {$t ne "" ? " {c:dim}($t){/c}" : ""}] {b}[dict get $p value]{b}"
    }
    set title [::md::t $lang [expr {$what eq "goals" ? "scorers.title" : "scorers.assists"}] league [::md::catalog::label $lk]]
    reply_lines $ctx [list "{c:league}{b}$title{b}{/c} [join $parts " "]"]
}

# ---------------------------------------------------------------- h2h

proc ::md::cmd::c_h2h {ctx argv} {
    set text [join $argv]
    set parts {}
    foreach sep {" vs " " v " " - " "," " x "} {
        set i [string first $sep [string tolower $text]]
        if {$i > 0} {
            set parts [list [string trim [string range $text 0 [expr {$i - 1}]]] [string trim [string range $text [expr {$i + [string length $sep]}] end]]]
            break
        }
    }
    if {[llength $parts] != 2 && [llength $argv] == 2} { set parts $argv }
    if {[llength $parts] != 2} { usage $ctx h2h; return }
    with_team $ctx [lindex $parts 0] [list ::md::cmd::_h2h1 $ctx [lindex $parts 1]]
}
proc ::md::cmd::_h2h1 {ctx q2 t1} {
    with_team $ctx $q2 [list ::md::cmd::_h2h2 $ctx $t1]
}
proc ::md::cmd::_h2h2 {ctx t1 t2} {
    if {[::md::cfg apifootball.key ""] ne "" && [info commands ::md::apifootball::h2h_teams] ne ""} {
        ::md::apifootball::h2h_teams [::md::teams::label $t1] [::md::teams::label $t2] [list ::md::cmd::_h2h_af $ctx $t1 $t2]
        return
    }
    ::md::teams::schedule $t1 0 [list ::md::cmd::_h2h_out $ctx $t1 $t2]
}
proc ::md::cmd::_h2h_af {ctx t1 t2 status ms} {
    if {$status ne "ok" || ![llength $ms]} {
        ::md::teams::schedule $t1 0 [list ::md::cmd::_h2h_out $ctx $t1 $t2]
        return
    }
    _h2h_reply $ctx $t1 $t2 $ms [lindex [split $t1 :] 1] 1
}
proc ::md::cmd::_h2h_out {ctx t1 t2 status data} {
    if {$status ne "ok"} { err $ctx err.provider; return }
    set id2 [lindex [split $t2 :] 1]
    set sel {}
    foreach m $data {
        if {[dict get $m state] ne "post"} continue
        if {[dict get $m home id] eq $id2 || [dict get $m away id] eq $id2} { lappend sel $m }
    }
    _h2h_reply $ctx $t1 $t2 $sel [lindex [split $t1 :] 1] 0
}
proc ::md::cmd::_h2h_reply {ctx t1 t2 ms id1 named} {
    set lang [dict get $ctx lang]
    if {![llength $ms]} {
        reply $ctx [::md::t $lang h2h.none a [::md::teams::label $t1] b [::md::teams::label $t2]]
        return
    }
    set w 0; set d 0; set l 0
    set parts {}
    foreach m [lrange [lsort -command {apply {{x y} {expr {[dict get $y start] - [dict get $x start]}}}} $ms] 0 5] {
        if {$named} {
            set r [::md::apifootball::result_for $m [::md::teams::label $t1]]
        } else {
            set r [_result_letter $m $id1]
        }
        switch -- $r { W { incr w } D { incr d } L { incr l } }
        lappend parts "[::md::render::score $m "" 0] {c:dim}[::md::tfmt [dict get $m start] %d/%m/%y [dict get $ctx tz]]{/c}"
    }
    reply_lines $ctx [list "[::md::t $lang h2h.title a [::md::teams::label $t1] b [::md::teams::label $t2] w $w d $d l $l] [join $parts " {c:dim}|{/c} "]"]
}

# ---------------------------------------------------------------- leagues / help / more / about

proc ::md::cmd::c_leagues {ctx argv} {
    set lang [dict get $ctx lang]
    set q [join $argv]
    if {$q eq ""} {
        set parts {}
        foreach sp [::md::catalog::sports] {
            lappend parts "{b}[::md::t $lang sport.$sp]{b} ([llength [::md::catalog::keys $sp]])"
        }
        reply $ctx [::md::t $lang leagues.summary sports [join $parts ", "] cmd [::md::cmdhint $lang leagues]]
        return
    }
    set keys [::md::catalog::search $q 20]
    if {![llength $keys]} {
        # sport word
        set f [filter $q]
        if {[dict get $f type] eq "sport"} { set keys [::md::catalog::keys [dict get $f value]] }
    }
    if {![llength $keys]} { err $ctx err.league_notfound query $q; return }
    set parts {}
    foreach k $keys { lappend parts "[::md::catalog::label $k] {c:dim}($k){/c}" }
    reply_lines $ctx [::md::wrap [join $parts ", "] 380]
}

proc ::md::cmd::c_help {ctx argv} {
    set lang [dict get $ctx lang]
    set p [dict get $ctx prefix]
    if {[llength $argv]} {
        set c [::md::i18n::resolve [lindex $argv 0]]
        if {$c ne ""} {
            set u [::md::t? $lang help.$c]
            set aliases {}
            foreach {a canon} [array get ::md::i18n::alias] {
                if {$canon eq $c && $a ne $c} { lappend aliases $a }
            }
            reply $ctx "{b}$p[::md::i18n::cmdname $lang $c]{b} $u"
            if {[llength $aliases]} { reply $ctx "{c:dim}[::md::t $lang help.aliases]: [join [lsort $aliases] ", "]{/c}" }
            return
        }
    }
    set groups {
        info  {live today match next last table scorers lineup stats form h2h player prob leagues}
        mine  {follow unfollow follows prefs set lang tz}
        fun   {narrate predict preds porra ranking}
    }
    set lines {}
    foreach {g cmds} $groups {
        set names {}
        foreach c $cmds { lappend names "$p[::md::i18n::cmdname $lang $c]" }
        lappend lines "{b}[::md::t $lang help.group.$g]{b}: [join $names " "]"
    }
    lappend lines [::md::t $lang help.footer cmd "$p[::md::i18n::cmdname $lang help]"]
    if {[dict get $ctx chan] ne ""} {
        reply_priv $ctx $lines
    } else {
        reply_lines $ctx $lines 10
    }
}

proc ::md::cmd::c_more {ctx argv} {
    set key "[string tolower [dict get $ctx nick]]|[string tolower [dict get $ctx target]]"
    if {![::md::out::more $key [dict get $ctx lang]]} {
        set key2 "[string tolower [dict get $ctx nick]]|[string tolower [dict get $ctx nick]]"
        if {![::md::out::more $key2 [dict get $ctx lang]]} {
            reply $ctx [::md::t [dict get $ctx lang] more.none]
        }
    }
}

proc ::md::cmd::c_about {ctx argv} {
    reply $ctx [::md::t [dict get $ctx lang] about version $::md::version transport [dict get [::md::http::status] transport]]
}

namespace eval ::md::cmd {
    def help    any ::md::cmd::c_help
    def live    any ::md::cmd::c_live
    def today   any ::md::cmd::c_today
    def match   any ::md::cmd::c_match 1
    def next    any ::md::cmd::c_next
    def last    any ::md::cmd::c_last
    def table   any ::md::cmd::c_table
    def scorers any ::md::cmd::c_scorers
    def lineup  any ::md::cmd::c_lineup 1
    def stats   any ::md::cmd::c_stats 1
    def form    any ::md::cmd::c_form 1
    def h2h     any ::md::cmd::c_h2h 2
    def leagues any ::md::cmd::c_leagues
    def more    any ::md::cmd::c_more 0 1
    def about   any ::md::cmd::c_about 0 1
}
