# Matchday - providers/apifootball.tcl
# Optional API-Football (api-sports.io) provider. Needs apifootball.key.
#
# apifootball.mode:
#   extras  (default) ESPN stays primary; API-Football adds real
#           head-to-head history (!h2h). Cheap: a few calls per request.
#   primary use API-Football scoreboards for soccer competitions that
#           have an "af" id in the catalog (needs a paid plan for live
#           polling: the free plan allows 100 requests/day).
# Team ids differ from ESPN's, so in primary mode they are stored as
# "soccer:af<id>" to never collide with ESPN ids.

namespace eval ::md::apifootball {
    variable base "https://v3.football.api-sports.io"
    variable quota [dict create remaining "" limit "" ts 0]
}

proc ::md::apifootball::_get {path cb {ttl 30}} {
    variable base
    set key [::md::cfg apifootball.key ""]
    if {$key eq ""} { after 0 [linsert $cb end error "apifootball.key not set" {}]; return }
    ::md::http::json "$base$path" [list ::md::apifootball::_got $cb] -ttl $ttl -tag apifootball \
        -headers [list x-apisports-key $key]
}

proc ::md::apifootball::_got {cb status data meta} {
    variable quota
    set h [::md::dg $meta {} headers]
    if {[dict exists $h x-ratelimit-requests-remaining]} {
        set quota [dict create remaining [dict get $h x-ratelimit-requests-remaining] \
            limit [::md::dg $h "" x-ratelimit-requests-limit] ts [clock seconds]]
        if {[dict get $quota remaining] ne "" && [dict get $quota remaining] < 10} {
            ::md::log warn "API-Football: only [dict get $quota remaining] requests left today"
        }
    }
    if {$status ne "ok"} { {*}$cb error $data $meta; return }
    set errs [::md::dg $data {} errors]
    if {[llength $errs] && $errs ne "{}" && [dict size $errs] > 0} {
        {*}$cb error "api-football: [join [dict values $errs] "; "]" $meta
        return
    }
    {*}$cb ok [::md::dg $data {} response] $meta
}

proc ::md::apifootball::status {} {
    variable quota
    if {[dict get $quota ts] == 0} { return "API-Football: no calls yet (mode [::md::cfg apifootball.mode extras])" }
    return "API-Football: [dict get $quota remaining]/[dict get $quota limit] requests left (mode [::md::cfg apifootball.mode extras])"
}

# ---------------------------------------------------------------- normalise

proc ::md::apifootball::_status {st} {
    set s [::md::dg $st "" short]
    switch -- $s {
        TBD - NS { return {pre scheduled} }
        1H - 2H - ET - LIVE { return {in live} }
        HT - BT { return {in ht} }
        P { return {in shootout} }
        SUSP { return {in suspended} }
        INT { return {in delayed} }
        FT - AWD - WO { return {post ft} }
        AET { return {post aet} }
        PEN { return {post pens} }
        PST { return {post postponed} }
        CANC { return {post cancelled} }
        ABD { return {post abandoned} }
    }
    return {pre scheduled}
}

proc ::md::apifootball::norm_fixture {lkey f} {
    set fx [::md::dg $f {} fixture]
    lassign [_status [::md::dg $fx {} status]] state code
    set el [::md::dg $fx "" status elapsed]
    set ex [::md::dg $fx "" status extra]
    set minute ""
    if {$state eq "in" && $el ne ""} { set minute [expr {$ex ne "" && $ex > 0 ? "$el+$ex'" : "$el'"}] }
    set sides {}
    foreach s {home away} {
        set t [::md::dg $f {} teams $s]
        set g [::md::dg $f "" goals $s]
        set so [::md::dg $f "" score penalty $s]
        lappend sides [dict create id "af[::md::dg $t "" id]" name [::md::dg $t "" name] short [::md::dg $t "" name] \
            abbr [string toupper [string range [string map {" " ""} [::md::dg $t "" name]] 0 2]] \
            score $g so $so winner [::md::dg $t false winner] ls {} form "" ha $s order 0]
    }
    lassign $sides h a
    set fid [::md::dg $fx "" id]
    set m [dict create uid "af:$lkey:$fid" prov apifootball lkey $lkey lname [::md::catalog::label $lkey] \
        sport soccer kind team eid $fid start [::md::dg $fx 0 timestamp] state $state code $code \
        sname [::md::dg $fx "" status short] detail [::md::dg $fx "" status long] clock $minute minute $minute \
        period [expr {$code eq "ht" ? 1 : 0}] home $h away $a events {} round [::md::dg $f "" league round] \
        venue [::md::dg $fx "" venue name] tv {} link "" note [::md::dg $f "" league round] updated [clock seconds]]
    dict set m events [_events [::md::dg $f {} events] $h $a]
    return $m
}

proc ::md::apifootball::_events {evs h a} {
    set out {}
    set yellows {}
    foreach e $evs {
        set tid "af[::md::dg $e "" team id]"
        set side [expr {$tid eq [dict get $h id] ? "h" : ($tid eq [dict get $a id] ? "a" : "")}]
        set el [::md::dg $e 0 time elapsed]
        set ex [::md::dg $e "" time extra]
        set min [expr {$ex ne "" && $ex > 0 ? "$el+$ex'" : "$el'"}]
        set player [::md::dg $e "" player name]
        set pid [::md::dg $e "" player id]
        set det [::md::dg $e "" detail]
        switch -- [::md::dg $e "" type] {
            Goal {
                switch -glob -- $det {
                    "Own Goal" { set type og }
                    "Penalty" { set type pen }
                    "Missed Penalty" { set type penmiss }
                    default { set type goal }
                }
            }
            Card {
                if {[string match -nocase "*red*" $det]} {
                    set type [expr {$pid ne "" && $pid in $yellows ? "yred" : "red"}]
                } else {
                    set type yellow
                    lappend yellows $pid
                }
            }
            default { continue }
        }
        set clock [expr {$el * 60 + ($ex ne "" ? $ex * 60 : 0)}]
        lappend out [dict create k "$type:$side:$clock:$pid" type $type side $side min $min clock $clock \
            player $player assist [::md::dg $e "" assist name] pid $pid scored [expr {$type in {goal pen og}}] text $det]
    }
    return $out
}

# ---------------------------------------------------------------- API

proc ::md::apifootball::scoreboard {lkey date cb} {
    set lid [::md::catalog::get $lkey af]
    if {$lid eq ""} { ::md::espn::scoreboard $lkey $date $cb; return }
    if {$date eq ""} {
        set d [clock format [clock seconds] -format %Y-%m-%d -timezone :UTC]
    } else {
        set d "[string range $date 0 3]-[string range $date 4 5]-[string range $date 6 7]"
    }
    set season [::md::catalog::season $lkey]
    _get "/fixtures?league=$lid&season=$season&date=$d" [list ::md::apifootball::_sb $lkey $cb] [expr {$date eq "" ? 15 : 300}]
}

proc ::md::apifootball::_sb {lkey cb status data meta} {
    if {$status ne "ok"} {
        # degrade gracefully to ESPN
        ::md::log debug "api-football scoreboard $lkey failed ($data), using ESPN"
        ::md::espn::scoreboard $lkey "" $cb
        return
    }
    set out {}
    foreach f $data {
        if {[catch {lappend out [norm_fixture $lkey $f]} err]} { ::md::log debug "af fixture: $err" }
    }
    {*}$cb ok $out
}

proc ::md::apifootball::standings {lkey cb} {
    set lid [::md::catalog::get $lkey af]
    if {$lid eq ""} { ::md::espn::standings $lkey $cb; return }
    _get "/standings?league=$lid&season=[::md::catalog::season $lkey]" [list ::md::apifootball::_st $lkey $cb] 1800
}

proc ::md::apifootball::_st {lkey cb status data meta} {
    if {$status ne "ok" || ![llength $data]} { ::md::espn::standings $lkey $cb; return }
    set groups {}
    foreach g [::md::dg [lindex $data 0] {} league standings] {
        set rows {}
        set gname ""
        foreach r $g {
            set gname [::md::dg $r "" group]
            set all [::md::dg $r {} all]
            lappend rows [dict create id "af[::md::dg $r "" team id]" name [::md::dg $r "" team name] \
                short [::md::dg $r "" team name] abbr "" rank [::md::dg $r "" rank] gp [::md::dg $all "" played] \
                w [::md::dg $all "" win] d [::md::dg $all "" draw] l [::md::dg $all "" lose] \
                gf [::md::dg $all "" goals for] ga [::md::dg $all "" goals against] gd [::md::dg $r "" goalsDiff] \
                pts [::md::dg $r "" points] pct "" gb "" seed "" note [::md::dg $r "" description] stats {}]
        }
        lappend groups [dict create name $gname abbr "" rows $rows]
    }
    {*}$cb ok $groups
}

# Head-to-head by team names (works with ESPN-resolved teams)
proc ::md::apifootball::h2h_teams {name1 name2 cb} {
    set st [dict create n1 $name1 n2 $name2 id1 "" id2 "" cb $cb]
    _team_id $name1 [list ::md::apifootball::_h2h_id $st 1]
}

proc ::md::apifootball::_team_id {name cb} {
    # API-Football search wants >= 3 chars, letters/spaces only
    set q [::md::norm $name]
    regsub -all {\m(fc|cf|ac|sc|cd|ud|afc|ss|as)\M} $q "" q
    set q [string trim [regsub -all { +} $q " "]]
    if {[string length $q] < 3} { set q [::md::norm $name] }
    _get "/teams?search=[string range [::http::formatQuery x $q] 2 end]" [list ::md::apifootball::_team_got $name $cb] 86400
}

proc ::md::apifootball::_team_got {name cb status data meta} {
    if {$status ne "ok" || ![llength $data]} { {*}$cb ""; return }
    set best ""
    set bs -1
    set n [::md::norm $name]
    foreach t $data {
        set tn [::md::norm [::md::dg $t "" team name]]
        set s [::md::mscore $n [list $tn]]
        if {[string is false -strict [::md::dg $t true team national]]} { incr s 1 }
        if {$s > $bs} { set bs $s; set best [::md::dg $t "" team id] }
    }
    {*}$cb $best
}

proc ::md::apifootball::_h2h_id {st which id} {
    dict set st id$which $id
    if {$which == 1} {
        _team_id [dict get $st n2] [list ::md::apifootball::_h2h_id $st 2]
        return
    }
    if {[dict get $st id1] eq "" || [dict get $st id2] eq ""} { {*}[dict get $st cb] error {}; return }
    _get "/fixtures/headtohead?h2h=[dict get $st id1]-[dict get $st id2]&last=8" \
        [list ::md::apifootball::_h2h_got $st] 21600
}

proc ::md::apifootball::_h2h_got {st status data meta} {
    if {$status ne "ok"} { {*}[dict get $st cb] error {}; return }
    set out {}
    foreach f $data {
        set m [norm_fixture fifa.friendly $f]
        if {[dict get $m state] eq "post"} { lappend out $m }
    }
    {*}[dict get $st cb] ok $out
}

# W/D/L for a team (by name) in a normalised AF match
proc ::md::apifootball::result_for {m name} {
    set n [::md::norm $name]
    set hs [dict get $m home score]; set as [dict get $m away score]
    if {![string is integer -strict $hs] || ![string is integer -strict $as]} { return "?" }
    set hn [::md::mscore $n [list [::md::norm [dict get $m home name]]]]
    set an [::md::mscore $n [list [::md::norm [dict get $m away name]]]]
    set mine [expr {$hn >= $an ? "h" : "a"}]
    if {$hs == $as} { return D }
    set w [expr {$hs > $as ? "h" : "a"}]
    expr {$w eq $mine ? "W" : "L"}
}
