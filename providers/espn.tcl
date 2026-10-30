# Matchday - providers/espn.tcl
# ESPN public JSON endpoints (no API key). Converts payloads into the
# provider-neutral match model used by the engine:
#
#   match dict:
#     uid prov lkey lname sport kind eid start state code sname detail
#     clock minute period home away events round venue tv link note
#   side (home/away) dict:
#     id name short abbr score so winner ls form red
#   event dict (in match "events"):
#     k type side min clock player assist pid
#     types: goal pen og penmiss yellow yred red so(scored 0/1)
#
# Every public proc takes a callback: {*}$cb ok|error result

namespace eval ::md::espn {
    variable base "https://site.api.espn.com"
    variable web  "https://site.web.api.espn.com"
}

proc ::md::espn::_u {path} {
    variable base
    return "$base/apis/site/v2/sports/$path"
}

# ---------------------------------------------------------------- status

proc ::md::espn::status {st sport} {
    set t [::md::dg $st {} type]
    set name [::md::dg $t "" name]
    set state [::md::dg $t pre state]
    switch -glob -- $name {
        STATUS_SCHEDULED - STATUS_TBD { set code scheduled }
        STATUS_HALFTIME - STATUS_HALFTIME_ET - STATUS_END_OF_EXTRATIME { set code ht }
        STATUS_END_PERIOD - STATUS_END_OF_PERIOD { set code break }
        STATUS_SHOOTOUT { set code shootout }
        STATUS_FINAL_AET - STATUS_FINAL_ET - STATUS_END_OF_EXTRA_TIME { set code aet }
        STATUS_FINAL_PEN - STATUS_FINAL_PENALTIES { set code pens }
        STATUS_FULL_TIME - STATUS_FINAL* - STATUS_FORFEIT* - STATUS_RETIRED - STATUS_WALKOVER { set code ft }
        STATUS_POSTPONED { set code postponed }
        STATUS_CANCELED - STATUS_CANCELLED { set code cancelled }
        STATUS_SUSPENDED { set code suspended }
        STATUS_ABANDONED { set code abandoned }
        STATUS_DELAYED - STATUS_RAIN_DELAY - STATUS_WEATHER_DELAY { set code delayed }
        default {
            switch -- $state {
                in { set code live }
                post { set code ft }
                default { set code scheduled }
            }
        }
    }
    if {$code in {postponed cancelled abandoned}} { set state post }
    if {$code eq "suspended" || $code eq "delayed"} {
        if {$state eq "pre"} { set state pre } else { set state in }
    }
    set disp [::md::dg $st "" displayClock]
    set minute ""
    if {$sport eq "soccer" && $state eq "in" && [regexp {^(\d+)'?(?:\+(\d+))?} $disp -> m x]} {
        set minute [expr {$x ne "" ? "$m+$x'" : "$m'"}]
    }
    dict create state $state code $code sname $name \
        detail [::md::dg $t "" shortDetail] desc [::md::dg $t "" description] \
        clock $disp minute $minute period [::md::dg $st 0 period]
}

# ---------------------------------------------------------------- competitors

proc ::md::espn::_score {c} {
    set s [::md::dg $c "" score]
    if {[llength $s] > 1 && [dict exists $s displayValue]} {
        set s [dict get $s displayValue]
    } elseif {[llength $s] > 1 && [dict exists $s value]} {
        set s [expr {int([dict get $s value])}]
    }
    if {[string is double -strict $s] && $s == int($s)} { set s [expr {int($s)}] }
    return $s
}

proc ::md::espn::side {c} {
    if {[dict exists $c team]} {
        set t [dict get $c team]
        set name [::md::dg $t "" displayName]
        set short [::md::dg $t $name shortDisplayName]
        set abbr [::md::dg $t "" abbreviation]
        set id [::md::dg $t [::md::dg $c "" id] id]
    } elseif {[dict exists $c athlete]} {
        set t [dict get $c athlete]
        set name [::md::dg $t "" displayName]
        set short [::md::dg $t $name shortName]
        set abbr [::md::dg $t "" flag alt]
        set id [::md::dg $t [::md::dg $c "" id] id]
    } elseif {[dict exists $c roster]} {
        # doubles teams
        set ns {}
        foreach a [::md::dg $c {} roster athletes] { lappend ns [::md::dg $a "" shortName] }
        set name [join $ns " / "]
        set short $name
        set abbr ""
        set id [::md::dg $c "" id]
    } else {
        set name [::md::dg $c "?" displayName]
        set short $name
        set abbr ""
        set id [::md::dg $c "" id]
    }
    if {$abbr eq ""} { set abbr [string toupper [string range [string map {" " ""} $short] 0 2]] }
    set ls {}
    foreach l [::md::dg $c {} linescores] {
        set v [::md::dg $l "" value]
        if {[string is double -strict $v] && $v == int($v)} { set v [expr {int($v)}] }
        lappend ls $v
    }
    dict create id $id name $name short $short abbr $abbr score [_score $c] \
        so [::md::dg $c "" shootoutScore] winner [::md::dg $c false winner] ls $ls \
        form [::md::dg $c "" form] ha [::md::dg $c "" homeAway] order [::md::dg $c 0 order]
}

# ---------------------------------------------------------------- events

proc ::md::espn::_min {disp} {
    # "90'+3'" -> "90+3'" ; "45'" -> "45'"
    if {[regexp {^(\d+)'?(?:\+(\d+)'?)?} $disp -> m x]} {
        if {$x ne ""} { return "$m+$x'" }
        return "$m'"
    }
    return $disp
}

proc ::md::espn::details {comp hid aid} {
    set out {}
    set yellows {}
    foreach d [::md::dg $comp {} details] {
        set tid [::md::dg $d "" team id]
        set side [expr {$tid eq $hid ? "h" : ($tid eq $aid ? "a" : "")}]
        set ath [::md::dg $d {} athletesInvolved]
        if {![llength $ath]} {
            # summary headers use participants[].athlete instead
            foreach p [::md::dg $d {} participants] { lappend ath [::md::dg $p {} athlete] }
        }
        set player ""
        set pid ""
        set assist ""
        if {[llength $ath]} {
            set player [::md::dg [lindex $ath 0] "" displayName]
            set pid [::md::dg [lindex $ath 0] "" id]
            if {[llength $ath] > 1} { set assist [::md::dg [lindex $ath 1] "" displayName] }
        }
        set tt [::md::dg $d "" type text]
        set cv [expr {int([::md::dg $d 0 clock value])}]
        set min [_min [::md::dg $d "" clock displayValue]]
        set so [string is true -strict [::md::dg $d false shootout]]
        set sp [string is true -strict [::md::dg $d false scoringPlay]]
        set pk [string is true -strict [::md::dg $d false penaltyKick]]
        if {$so} {
            set type so
        } elseif {$sp} {
            if {[string is true -strict [::md::dg $d false ownGoal]] || [string match -nocase "*own goal*" $tt]} {
                set type og
            } elseif {$pk} {
                set type pen
            } else {
                set type goal
            }
        } elseif {[string is true -strict [::md::dg $d false redCard]]} {
            set type red
            if {$pid ne "" && $pid in $yellows} { set type yred }
            if {[string match -nocase "*second yellow*" $tt]} { set type yred }
        } elseif {[string is true -strict [::md::dg $d false yellowCard]]} {
            set type yellow
            if {$pid ne ""} { lappend yellows $pid }
        } elseif {$pk || [string match -nocase "penalty*" $tt]} {
            set type penmiss
        } else {
            continue
        }
        set who [expr {$pid ne "" ? $pid : [::md::norm $player]}]
        set k "$type:$side:$cv:$who"
        lappend out [dict create k $k type $type side $side min $min clock $cv \
            player $player assist $assist pid $pid scored $sp text $tt]
    }
    # shootout kicks are listed first by ESPN; keep chronological order
    lsort -command {apply {{x y} {expr {[dict get $x clock] - [dict get $y clock]}}}} $out
}

# ---------------------------------------------------------------- events -> matches

proc ::md::espn::_tv {comp} {
    set tv {}
    foreach b [::md::dg $comp {} geoBroadcasts] {
        set n [::md::dg $b "" media shortName]
        if {$n ne ""} { lappend tv $n }
    }
    if {![llength $tv]} {
        foreach b [::md::dg $comp {} broadcasts] {
            foreach n [::md::dg $b {} names] { lappend tv $n }
        }
    }
    ::md::luniq $tv
}

proc ::md::espn::_note {comp ev} {
    set n ""
    foreach x [::md::dg $comp {} notes] {
        set h [::md::dg $x "" headline]
        if {$h ne ""} { set n $h; break }
    }
    if {$n eq ""} { set n [::md::dg $comp "" altGameNote] }
    return $n
}

proc ::md::espn::norm_events {lkey data} {
    set out {}
    foreach ev [::md::dg $data {} events] {
        if {[catch {lappend out {*}[norm_event $lkey $ev]} err opts]} {
            ::md::log debug "espn: skipping event [::md::dg $ev ? id] ($err)"
            ::md::log debug [dict get $opts -errorinfo]
        }
    }
    return $out
}

proc ::md::espn::norm_event {lkey ev} {
    set sport [::md::catalog::get $lkey sport]
    if {$sport eq ""} { set sport soccer }
    set kind [::md::catalog::kind $sport]
    switch -- $kind {
        duel { return [_duels $lkey $sport $ev] }
        race { return [_race $lkey $sport $ev] }
    }
    set comp [lindex [::md::dg $ev {} competitions] 0]
    list [_team_match $lkey $sport $ev $comp]
}

proc ::md::espn::_base {lkey sport eid ev comp} {
    set st [status [::md::dg $comp [::md::dg $ev {} status] status] $sport]
    set lname [::md::catalog::label $lkey]
    set link ""
    foreach l [::md::dg $ev {} links] {
        if {"summary" in [::md::dg $l {} rel] || "event" in [::md::dg $l {} rel]} { set link [::md::dg $l "" href]; break }
    }
    set m [dict create uid "espn:$lkey:$eid" prov espn lkey $lkey lname $lname sport $sport \
        kind [::md::catalog::kind $sport] eid $eid \
        start [::md::iso2epoch [::md::dg $comp [::md::dg $ev "" date] date]] \
        round [::md::dg $ev "" season slug] venue [::md::dg $comp "" venue fullName] \
        link $link updated [clock seconds] events {} note "" tv {}]
    if {[dict get $m venue] eq ""} { dict set m venue [::md::dg $ev "" venue displayName] }
    dict merge $m $st
}

proc ::md::espn::_team_match {lkey sport ev comp} {
    set eid [::md::dg $ev "" id]
    set m [_base $lkey $sport $eid $ev $comp]
    set h {}; set a {}
    foreach c [::md::dg $comp {} competitors] {
        set s [side $c]
        if {[dict get $s ha] eq "away"} { set a $s } elseif {[dict get $s ha] eq "home"} { set h $s } elseif {$h eq ""} { set h $s } else { set a $s }
    }
    if {$h eq "" || $a eq ""} { error "incomplete competitors" }
    dict set m home $h
    dict set m away $a
    if {$sport eq "soccer"} {
        dict set m events [details $comp [dict get $h id] [dict get $a id]]
    }
    dict set m tv [_tv $comp]
    dict set m note [_note $comp $ev]
    # live situation text for US sports (used by the narrator)
    set lp [::md::dg $comp "" situation lastPlay text]
    if {$lp ne ""} { dict set m lastplay $lp }
    set dd [::md::dg $comp "" situation downDistanceText]
    if {$dd ne ""} { dict set m situation $dd }
    return $m
}

proc ::md::espn::_tennis_sets {h a} {
    set hs 0; set as 0
    set hl [dict get $h ls]; set al [dict get $a ls]
    set n [llength $hl]
    for {set i 0} {$i < $n} {incr i} {
        set x [lindex $hl $i]; set y [lindex $al $i]
        if {![string is integer -strict $x] || ![string is integer -strict $y]} continue
        if {($x >= 6 && $x - $y >= 2) || $x == 7} { incr hs } elseif {($y >= 6 && $y - $x >= 2) || $y == 7} { incr as }
    }
    list $hs $as
}

proc ::md::espn::_duels {lkey sport ev} {
    set comps {}
    if {[dict exists $ev groupings]} {
        foreach g [dict get $ev groupings] {
            set gname [::md::dg $g "" grouping displayName]
            foreach c [::md::dg $g {} competitions] { lappend comps [list $gname $c] }
        }
    } else {
        foreach c [::md::dg $ev {} competitions] { lappend comps [list "" $c] }
    }
    set out {}
    set evname [::md::dg $ev "" shortName]
    if {$evname eq ""} { set evname [::md::dg $ev "" name] }
    foreach gc $comps {
        lassign $gc gname comp
        set cs [::md::dg $comp {} competitors]
        if {[llength $cs] < 2} continue
        set eid "[::md::dg $ev "" id]-[::md::dg $comp "" id]"
        set m [_base $lkey $sport $eid $ev $comp]
        set c1 [lindex $cs 0]; set c2 [lindex $cs 1]
        if {[::md::dg $c1 0 order] > [::md::dg $c2 0 order]} { lassign [list $c2 $c1] c1 c2 }
        set h [side $c1]; set a [side $c2]
        if {$sport eq "tennis"} {
            lassign [_tennis_sets $h $a] hs as
            dict set h score $hs
            dict set a score $as
        } else {
            dict set h score [expr {[string is true -strict [dict get $h winner]] ? "W" : ""}]
            dict set a score [expr {[string is true -strict [dict get $a winner]] ? "W" : ""}]
        }
        dict set m home $h
        dict set m away $a
        set rnd [::md::dg $comp "" round displayName]
        if {$rnd eq ""} { set rnd [::md::dg $comp "" type abbreviation] }
        dict set m note [string trim "$evname $gname $rnd"]
        lappend out $m
    }
    return $out
}

proc ::md::espn::_race {lkey sport ev} {
    set out {}
    set evname [::md::dg $ev "" shortName]
    if {$evname eq ""} { set evname [::md::dg $ev "" name] }
    foreach comp [::md::dg $ev {} competitions] {
        set eid "[::md::dg $ev "" id]-[::md::dg $comp "" id]"
        set m [_base $lkey $sport $eid $ev $comp]
        set sess [::md::dg $comp "" type abbreviation]
        set res {}
        set cs [::md::dg $comp {} competitors]
        set cs [lsort -command {apply {{x y} {
            expr {[::md::dg $x 999 order] - [::md::dg $y 999 order]}
        }}} $cs]
        foreach c [lrange $cs 0 19] {
            set name [::md::dg $c "" athlete displayName]
            if {$name eq ""} { set name [::md::dg $c "" team displayName] }
            set extra [_score $c]
            lappend res [dict create pos [::md::dg $c "" order] name $name extra $extra]
        }
        dict set m results $res
        dict set m session $sess
        dict set m home [dict create id "" name $evname short $evname abbr "" score "" so "" winner false ls {} form "" ha home order 0]
        dict set m away [dict create id "" name $sess short $sess abbr "" score "" so "" winner false ls {} form "" ha away order 1]
        dict set m note [string trim "$evname $sess"]
        lappend out $m
    }
    return $out
}

# ---------------------------------------------------------------- API

proc ::md::espn::scoreboard {lkey date cb} {
    set path [::md::catalog::get $lkey path]
    set url "[_u $path]/scoreboard?limit=300"
    if {$date ne ""} { append url "&dates=$date" }
    set ttl [expr {$date eq "" ? [::md::cfg espn.ttl_live 8] : 60}]
    ::md::http::json $url [list ::md::espn::_sb $lkey $cb] -ttl $ttl -tag espn
}

proc ::md::espn::_sb {lkey cb status data meta} {
    if {$status ne "ok"} { {*}$cb error $data; return }
    {*}$cb ok [norm_events $lkey $data]
}

# Match detail: key events, commentary, stats, lineups, form.
proc ::md::espn::summary {lkey eid cb {ttl 8}} {
    set path [::md::catalog::get $lkey path]
    set url "[_u $path]/summary?event=$eid"
    ::md::http::json $url [list ::md::espn::_sum $lkey $eid $cb] -ttl $ttl -tag espn
}

proc ::md::espn::_sum {lkey eid cb status data meta} {
    if {$status ne "ok"} { {*}$cb error $data; return }
    if {[catch {norm_summary $lkey $eid $data} res opts]} {
        ::md::log debug [dict get $opts -errorinfo]
        {*}$cb error "summary: $res"
        return
    }
    {*}$cb ok $res
}

proc ::md::espn::_sidebyname {name h a} {
    if {$name eq ""} { return "" }
    foreach s {h a} {
        set d [expr {$s eq "h" ? $h : $a}]
        if {$name eq [dict get $d name] || $name eq [dict get $d short]} { return $s }
    }
    set n [::md::norm $name]
    if {[::md::mscore $n [list [::md::norm [dict get $h name]] [::md::norm [dict get $h short]]]] >= 70} { return h }
    if {[::md::mscore $n [list [::md::norm [dict get $a name]] [::md::norm [dict get $a short]]]] >= 70} { return a }
    return ""
}

proc ::md::espn::norm_summary {lkey eid data} {
    set sport [::md::catalog::get $lkey sport]
    set hdr [::md::dg $data {} header]
    set comp [lindex [::md::dg $hdr {} competitions] 0]
    set ev [dict create id $eid date [::md::dg $comp "" date] links [::md::dg $hdr {} links]]
    set m [_team_match $lkey $sport $ev $comp]
    set h [dict get $m home]; set a [dict get $m away]
    set hid [dict get $h id]; set aid [dict get $a id]
    set r [dict create match $m]

    # key events
    set kev {}
    foreach k [::md::dg $data {} keyEvents] {
        set tid [::md::dg $k "" team id]
        set side [expr {$tid eq $hid ? "h" : ($tid eq $aid ? "a" : "")}]
        set ps {}
        foreach p [::md::dg $k {} participants] { lappend ps [::md::dg $p "" athlete displayName] }
        lappend kev [dict create id [::md::dg $k "" id] type [::md::dg $k "" type type] \
            ttext [::md::dg $k "" type text] text [::md::dg $k "" text] \
            min [_min [::md::dg $k "" clock displayValue]] clock [expr {int([::md::dg $k 0 clock value])}] \
            period [::md::dg $k 0 period number] side $side players $ps \
            scoring [string is true -strict [::md::dg $k false scoringPlay]] \
            so [string is true -strict [::md::dg $k false shootout]]]
    }
    dict set r keyev $kev

    # commentary (soccer)
    set com {}
    foreach c [::md::dg $data {} commentary] {
        set p [::md::dg $c {} play]
        set ps {}
        foreach x [::md::dg $p {} participants] { lappend ps [::md::dg $x "" athlete displayName] }
        lappend com [dict create seq [::md::dg $c 0 sequence] min [_min [::md::dg $c "" time displayValue]] \
            clock [expr {int([::md::dg $c 0 time value])}] \
            text [::md::dg $c "" text] ptype [::md::dg $p "" type type] pid [::md::dg $p "" id] \
            side [_sidebyname [::md::dg $p "" team displayName] $h $a] players $ps]
    }
    dict set r comm $com

    # team stats
    set stats [dict create h {} a {}]
    foreach t [::md::dg $data {} boxscore teams] {
        set tid [::md::dg $t "" team id]
        set s [expr {$tid eq $hid ? "h" : "a"}]
        set d {}
        foreach x [::md::dg $t {} statistics] {
            dict set d [::md::dg $x "" name] [::md::dg $x "" displayValue]
        }
        dict set stats $s $d
    }
    dict set r stats $stats

    # lineups
    set lu [dict create]
    foreach ro [::md::dg $data {} rosters] {
        set tid [::md::dg $ro "" team id]
        set s [expr {$tid eq $hid ? "h" : "a"}]
        set xi {}; set bench {}
        foreach p [::md::dg $ro {} roster] {
            set e [dict create name [::md::dg $p "" athlete displayName] \
                short [::md::dg $p "" athlete shortName] num [::md::dg $p "" jersey] \
                pos [::md::dg $p "" position abbreviation]]
            if {[string is true -strict [::md::dg $p false starter]]} { lappend xi $e } else { lappend bench $e }
        }
        if {[llength $xi]} {
            dict set lu $s [dict create formation [::md::dg $ro "" formation] xi $xi bench $bench]
        }
    }
    dict set r lineups $lu

    # recent form
    set form [dict create]
    foreach t [::md::dg $data {} lastFiveGames] {
        set tid [::md::dg $t "" team id]
        set s [expr {$tid eq $hid ? "h" : "a"}]
        set f ""
        foreach g [::md::dg $t {} events] { append f [::md::dg $g "" gameResult] }
        dict set form $s $f
    }
    dict set r form $form

    # venue / officials / attendance
    set gi [::md::dg $data {} gameInfo]
    set venue [::md::dg $gi "" venue fullName]
    set city [::md::dg $gi "" venue address city]
    if {$city ne ""} { append venue " ($city)" }
    dict set r venue $venue
    set offs {}
    foreach o [::md::dg $gi {} officials] {
        lappend offs [list [::md::dg $o "" displayName] [::md::dg $o "" position displayName]]
    }
    dict set r officials $offs
    dict set r attendance [::md::dg $gi 0 attendance]

    # head-to-head (when ESPN provides it)
    set h2h {}
    foreach g [::md::dg $data {} headToHeadGames] {
        foreach e [::md::dg $g {} events] {
            lappend h2h [dict create date [::md::iso2epoch [::md::dg $e "" gameDate]] \
                score [::md::dg $e "" score] home [::md::dg $e "" homeTeamId] away [::md::dg $e "" awayTeamId]]
        }
    }
    dict set r h2h $h2h

    # pre-match odds (moneylines) -> implied probabilities
    dict set r odds [_odds [lindex [::md::dg $data {} odds] 0] $hid $aid]
    if {![dict size [dict get $r odds]]} {
        dict set r odds [_odds [lindex [::md::dg $data {} pickcenter] 0] $hid $aid]
    }

    # live win probability (US sports): last entry of the series
    set wp [::md::dg $data {} winprobability]
    if {[llength $wp]} {
        set last [lindex $wp end]
        set ph [::md::dg $last "" homeWinPercentage]
        set pt [::md::dg $last 0 tiePercentage]
        if {[string is double -strict $ph]} {
            if {![string is double -strict $pt]} { set pt 0 }
            dict set r winprob [dict create h $ph d $pt a [expr {max(0.0, 1.0 - $ph - $pt)}]]
        }
    }

    # videos (highlights appear some time after the final whistle)
    set vids {}
    foreach v [::md::dg $data {} videos] {
        set url [::md::dg $v "" links web href]
        if {$url eq ""} continue
        lappend vids [dict create id [::md::dg $v "" id] headline [::md::dg $v "" headline] \
            duration [::md::dg $v 0 duration] url $url]
    }
    dict set r videos $vids
    return $r
}

# American moneyline -> decimal odds
proc ::md::espn::_dec {ml} {
    if {![string is double -strict $ml] || $ml == 0} { return "" }
    if {$ml > 0} { return [expr {1.0 + $ml / 100.0}] }
    return [expr {1.0 + 100.0 / abs($ml)}]
}

# odds dict {h d a provider details ou} with normalised implied probabilities
proc ::md::espn::_odds {o hid aid} {
    if {$o eq ""} { return {} }
    set dh [_dec [::md::dg $o "" homeTeamOdds moneyLine]]
    set da [_dec [::md::dg $o "" awayTeamOdds moneyLine]]
    set dd [_dec [::md::dg $o "" drawOdds moneyLine]]
    if {$dh eq "" || $da eq ""} { return {} }
    set ph [expr {1.0 / $dh}]
    set pa [expr {1.0 / $da}]
    set pd [expr {$dd ne "" ? 1.0 / $dd : 0.0}]
    set sum [expr {$ph + $pa + $pd}]
    dict create h [expr {$ph / $sum}] d [expr {$pd / $sum}] a [expr {$pa / $sum}] \
        provider [::md::dg $o "" provider name] details [::md::dg $o "" details] ou [::md::dg $o "" overUnder]
}

# ---------------------------------------------------------------- athletes

# Player search: list of {sport slug pid name team league}
proc ::md::espn::player_search {query cb} {
    variable web
    set q [::http::formatQuery query $query limit 8 type player]
    ::md::http::json "$web/apis/search/v2?$q" [list ::md::espn::_psearch $cb] -ttl 3600 -tag espn
}

proc ::md::espn::_psearch {cb status data meta} {
    if {$status ne "ok"} { {*}$cb error $data; return }
    set out {}
    foreach r [::md::dg $data {} results] {
        if {[::md::dg $r "" type] ne "player"} continue
        foreach c [::md::dg $r {} contents] {
            if {![regexp {~a:(\d+)} [::md::dg $c "" uid] -> pid]} continue
            lappend out [dict create sport [::md::dg $c "" sport] slug [::md::dg $c "" defaultLeagueSlug] \
                pid $pid name [::md::dg $c "" displayName] team [::md::dg $c "" subtitle] \
                league [::md::dg $c "" description]]
        }
    }
    {*}$cb ok $out
}

# Athlete profile + season splits + last games + next game
proc ::md::espn::player {sport slug pid cb} {
    variable web
    set path [expr {$sport eq "soccer" || $slug eq "" ? "$sport" : "$sport/$slug"}]
    set id [incr ::md::espn::_pseq]
    set ::md::espn::_p($id) [dict create cb $cb n 2 prof {} ov {}]
    ::md::http::json "$web/apis/common/v3/sports/$path/athletes/$pid" [list ::md::espn::_pgot $id prof] -ttl 1800 -tag espn
    ::md::http::json "$web/apis/common/v3/sports/$path/athletes/$pid/overview" [list ::md::espn::_pgot $id ov] -ttl 1800 -tag espn
}
set ::md::espn::_pseq 0

proc ::md::espn::_pgot {id part status data meta} {
    upvar #0 ::md::espn::_p($id) st
    if {$status eq "ok"} { dict set st $part $data }
    dict incr st n -1
    if {[dict get $st n] > 0} return
    set cb [dict get $st cb]
    set prof [dict get $st prof]
    set ov [dict get $st ov]
    unset st
    if {$prof eq "" && $ov eq ""} { {*}$cb error "no data"; return }
    if {[catch {norm_player $prof $ov} res]} { {*}$cb error $res; return }
    {*}$cb ok $res
}

proc ::md::espn::norm_player {prof ov} {
    set a [::md::dg $prof $prof athlete]
    set r [dict create name [::md::dg $a "" displayName] age [::md::dg $a "" age] \
        pos [::md::dg $a "" position displayName] jersey [::md::dg $a "" jersey] \
        nat [::md::dg $a "" citizenship] team [::md::dg $a "" team displayName] \
        status [::md::dg $a "" status type] splits {} last {} next {}]
    # season splits (per competition)
    set st [::md::dg $ov {} statistics]
    set labels [::md::dg $st {} labels]
    set names [::md::dg $st {} names]
    set splits {}
    foreach s [::md::dg $st {} splits] {
        lappend splits [dict create name [::md::dg $s "" displayName] stats [::md::dg $s {} stats]]
    }
    dict set r labels $labels
    dict set r names $names
    dict set r splits $splits
    # fallback: profile stats summary
    if {![llength $splits]} {
        set sum {}
        foreach x [::md::dg $a {} statsSummary statistics] {
            lappend sum [list [::md::dg $x "" abbreviation] [::md::dg $x "" displayValue]]
        }
        dict set r summary [list [::md::dg $a "" statsSummary displayName] $sum]
    }
    # last games totals
    set gl [lindex [::md::dg $ov {} gameLog statistics] 0]
    if {$gl ne ""} {
        set gnames [::md::dg $gl {} names]
        set tot {}
        set n 0
        foreach e [::md::dg $gl {} events] {
            incr n
            foreach k $gnames v [::md::dg $e {} stats] {
                if {[string is double -strict $v]} {
                    if {![dict exists $tot $k]} { dict set tot $k 0 }
                    dict set tot $k [expr {[dict get $tot $k] + $v}]
                }
            }
        }
        dict set r last [dict create n $n totals $tot]
    }
    set ne [lindex [::md::dg $ov {} nextGame league events] 0]
    if {$ne ne ""} {
        dict set r next [dict create name [::md::dg $ne "" name] start [::md::iso2epoch [::md::dg $ne "" date]] \
            league [::md::dg $ov "" nextGame league shortName]]
    }
    return $r
}

# Standings: list of groups {name rows}; row dict: rank id name abbr gp w d l gf ga gd pts note extra
proc ::md::espn::standings {lkey cb} {
    variable base
    set path [::md::catalog::get $lkey path]
    ::md::http::json "$base/apis/v2/sports/$path/standings" [list ::md::espn::_st $lkey $cb] -ttl 300 -tag espn
}

proc ::md::espn::_st {lkey cb status data meta} {
    if {$status ne "ok"} { {*}$cb error $data; return }
    set groups {}
    set children [::md::dg $data {} children]
    if {![llength $children] && [dict exists $data standings]} { set children [list $data] }
    foreach ch $children {
        set rows {}
        foreach e [::md::dg $ch {} standings entries] {
            set st {}
            foreach s [::md::dg $e {} stats] {
                set n [::md::dg $s "" name]
                if {$n eq ""} continue
                set v [::md::dg $s "" displayValue]
                if {$v eq ""} { set v [::md::dg $s "" value] }
                dict set st $n $v
            }
            set row [dict create \
                id [::md::dg $e "" team id] name [::md::dg $e "" team displayName] \
                short [::md::dg $e "" team shortDisplayName] abbr [::md::dg $e "" team abbreviation] \
                rank [::md::dg $st "" rank] gp [::md::dg $st "" gamesPlayed] \
                w [::md::dg $st "" wins] d [::md::dg $st "" ties] l [::md::dg $st "" losses] \
                gf [::md::dg $st "" pointsFor] ga [::md::dg $st "" pointsAgainst] \
                gd [::md::dg $st "" pointDifferential] pts [::md::dg $st "" points] \
                pct [::md::dg $st "" winPercent] gb [::md::dg $st "" gamesBehind] \
                seed [::md::dg $st "" playoffSeed] note [::md::dg $e "" note description] stats $st]
            lappend rows $row
        }
        # sort: rank if present, else points/win%
        set rows [lsort -command ::md::espn::_rowcmp $rows]
        set i 0
        set fixed {}
        foreach r $rows {
            incr i
            if {[dict get $r rank] eq "" || [dict get $r rank] == 0} { dict set r rank $i }
            lappend fixed $r
        }
        lappend groups [dict create name [::md::dg $ch "" name] abbr [::md::dg $ch "" abbreviation] rows $fixed]
    }
    {*}$cb ok $groups
}

proc ::md::espn::_rowcmp {x y} {
    set rx [dict get $x rank]; set ry [dict get $y rank]
    if {[string is integer -strict $rx] && [string is integer -strict $ry] && $rx > 0 && $ry > 0} {
        return [expr {$rx - $ry}]
    }
    set seedx [dict get $x seed]; set seedy [dict get $y seed]
    if {[string is double -strict $seedx] && [string is double -strict $seedy] && $seedx > 0 && $seedy > 0} {
        return [expr {$seedx < $seedy ? -1 : ($seedx > $seedy ? 1 : 0)}]
    }
    foreach f {pts pct} {
        set a [dict get $x $f]; set b [dict get $y $f]
        if {[string is double -strict $a] && [string is double -strict $b] && $a != $b} {
            return [expr {$a > $b ? -1 : 1}]
        }
    }
    return 0
}

# Team schedule (all competitions for soccer). fixture=1 -> upcoming
proc ::md::espn::schedule {lkey tid fixture cb} {
    set sport [::md::catalog::get $lkey sport]
    set path [::md::catalog::get $lkey path]
    if {$sport eq "soccer"} { set path soccer/all }
    set url "[_u $path]/teams/$tid/schedule"
    if {$fixture} { append url "?fixture=true" }
    ::md::http::json $url [list ::md::espn::_sched $lkey $cb] -ttl 900 -tag espn
}

proc ::md::espn::_sched {lkey cb status data meta} {
    if {$status ne "ok"} { {*}$cb error $data; return }
    set sport [::md::catalog::get $lkey sport]
    set out {}
    foreach ev [::md::dg $data {} events] {
        set k $lkey
        set slug [::md::dg $ev "" league slug]
        if {$slug ne "" && $sport eq "soccer"} {
            set f [::md::catalog::find $slug]
            if {$f ne ""} { set k $f }
        }
        if {[catch {lappend out {*}[norm_event $k $ev]} err]} {
            ::md::log debug "espn schedule: skip [::md::dg $ev ? id]: $err"
        }
    }
    {*}$cb ok [lsort -command {apply {{x y} {expr {[dict get $x start] - [dict get $y start]}}}} $out]
}

# Teams of a league: list of {id name short abbr}
proc ::md::espn::teams {lkey cb} {
    set path [::md::catalog::get $lkey path]
    ::md::http::json "[_u $path]/teams?limit=500" [list ::md::espn::_teams $lkey $cb] -ttl 86400 -tag espn
}

proc ::md::espn::_teams {lkey cb status data meta} {
    if {$status ne "ok"} { {*}$cb error $data; return }
    set out {}
    foreach s [::md::dg $data {} sports] {
        foreach l [::md::dg $s {} leagues] {
            foreach t [::md::dg $l {} teams] {
                set t [::md::dg $t {} team]
                lappend out [dict create id [::md::dg $t "" id] name [::md::dg $t "" displayName] \
                    short [::md::dg $t "" shortDisplayName] abbr [::md::dg $t "" abbreviation] \
                    nick [::md::dg $t "" nickname] loc [::md::dg $t "" location]]
            }
        }
    }
    {*}$cb ok $out
}

# Top scorers / assists: dict goals {list {name value detail}} assists {...}
proc ::md::espn::leaders {lkey cb} {
    set path [::md::catalog::get $lkey path]
    ::md::http::json "[_u $path]/statistics" [list ::md::espn::_leaders $cb] -ttl 1800 -tag espn
}

proc ::md::espn::_leaders {cb status data meta} {
    if {$status ne "ok"} { {*}$cb error $data; return }
    set r [dict create goals {} assists {}]
    foreach s [::md::dg $data {} stats] {
        set n [::md::dg $s "" name]
        set key [expr {$n eq "goalsLeaders" ? "goals" : ($n eq "assistsLeaders" ? "assists" : "")}]
        if {$key eq ""} continue
        set l {}
        foreach x [::md::dg $s {} leaders] {
            set team [::md::dg $x "" athlete team abbreviation]
            if {$team eq ""} { set team [::md::dg $x "" team abbreviation] }
            lappend l [dict create name [::md::dg $x "" athlete displayName] value [expr {int([::md::dg $x 0 value])}] \
                team $team detail [::md::dg $x "" displayValue]]
        }
        dict set r $key $l
    }
    {*}$cb ok $r
}

# Global team/athlete search: list of {sport slug tid name subtitle}
proc ::md::espn::search {query cb} {
    variable web
    set q [::http::formatQuery query $query limit 10 type team]
    ::md::http::json "$web/apis/search/v2?$q" [list ::md::espn::_search $cb] -ttl 3600 -tag espn
}

proc ::md::espn::_search {cb status data meta} {
    if {$status ne "ok"} { {*}$cb error $data; return }
    set out {}
    foreach r [::md::dg $data {} results] {
        if {[::md::dg $r "" type] ne "team"} continue
        foreach c [::md::dg $r {} contents] {
            set uid [::md::dg $c "" uid]
            if {![regexp {~t:(\d+)} $uid -> tid]} continue
            lappend out [dict create sport [::md::dg $c "" sport] slug [::md::dg $c "" defaultLeagueSlug] \
                tid $tid name [::md::dg $c "" displayName] subtitle [::md::dg $c "" subtitle]]
        }
    }
    {*}$cb ok $out
}
