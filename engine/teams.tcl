# Matchday - engine/teams.tcl
# Self-learning team index. Every scoreboard teaches it team names and
# the competitions they play in; ESPN's global search fills the gaps.
# Keys are "sport:teamid" (ESPN ids are unique per sport).
#
#   md::teams::find query ?sport? -> ranked list of {score key}
#   md::teams::resolve query cb ?sport? -> async; cb ok key | ambiguous {keys} | notfound | error msg

namespace eval ::md::teams {
    variable dirty 0
    variable sched     ;# key -> {ts matches}
    array set sched {}
    # common nicknames -> search text
    variable nick {
        barca barcelona  "barça" barcelona  atleti "atletico madrid"  atm "atletico madrid"
        "real" "real madrid"  merengues "real madrid"  "madrid" "real madrid"
        betis "real betis"  "la real" "real sociedad"  "athletic" "athletic club"
        "man utd" "manchester united"  "man united" "manchester united"  manu "manchester united"
        "man city" "manchester city"  city "manchester city"  spurs tottenham  gunners arsenal
        "wolves" "wolverhampton"  "toffees" everton  "villa" "aston villa"  "forest" "nottingham forest"
        juve juventus  "inter" internazionale  "inter milan" internazionale  "milan" "ac milan"
        "la roma" "as roma"  "lazio" lazio  "napoli" napoli
        bayern "bayern munich"  "bvb" "borussia dortmund"  dortmund "borussia dortmund"  "gladbach" "monchengladbach"
        leverkusen "bayer leverkusen"  "psg" "paris saint germain"  "om" marseille  "ol" lyon
        "benfica" benfica  "porto" "fc porto"  "sporting" "sporting cp"  "ajax" ajax  "psv" "psv eindhoven"
        "boca" "boca juniors"  "river" "river plate"  "flamengo" flamengo  "fla" flamengo  "palmeiras" palmeiras
        "galo" "atletico mg"  "colo colo" "colo colo"  "america" "club america"  "chivas" guadalajara
        "lakers" "los angeles lakers"  "celtics" "boston celtics"  "warriors" "golden state warriors"
        "knicks" "new york knicks"  "sixers" "philadelphia 76ers"  "cavs" "cleveland cavaliers"  "mavs" "dallas mavericks"
        "niners" "san francisco 49ers"  "pats" "new england patriots"  "yankees" "new york yankees"  "dodgers" "los angeles dodgers"
    }
}

proc ::md::teams::get {key {field ""}} {
    if {![::md::db_exists teams $key]} { return "" }
    if {$field eq ""} { return [::md::db_get teams $key] }
    ::md::db_get teams $key $field
}

proc ::md::teams::label {key} {
    set n [get $key name]
    if {$n eq ""} { return $key }
    return $n
}

proc ::md::teams::learn {sport id name short abbr lkey} {
    if {$id eq "" || $name eq ""} return
    set k "$sport:$id"
    if {[::md::db_exists teams $k]} {
        set t [::md::db_get teams $k]
        set changed 0
        if {$lkey ne "" && $lkey ni [dict get $t lkeys]} {
            dict lappend t lkeys $lkey
            set changed 1
        }
        if {[dict get $t name] ne $name} { dict set t name $name; set changed 1 }
        if {$changed} {
            dict set t norm [_norms $name $short $abbr]
            ::md::db_set teams $k $t
        }
        return
    }
    set lk {}
    if {$lkey ne ""} { set lk [list $lkey] }
    ::md::db_set teams $k [dict create name $name short $short abbr $abbr lkeys $lk \
        norm [_norms $name $short $abbr]]
}

proc ::md::teams::_norms {name short abbr} {
    ::md::luniq [list [::md::norm $name] [::md::norm $short] [::md::norm $abbr]]
}

# scoreboard hook: learn from every match seen
proc ::md::teams::on_scoreboard {lkey matches} {
    foreach m $matches {
        if {[dict get $m kind] ne "team"} continue
        foreach side {home away} {
            set s [dict get $m $side]
            learn [dict get $m sport] [dict get $s id] [dict get $s name] [dict get $s short] [dict get $s abbr] $lkey
        }
    }
}
::md::hook::add scoreboard ::md::teams::on_scoreboard

# Local ranked search
proc ::md::teams::find {query {sport ""} {limit 8}} {
    variable nick
    set q [::md::norm $query]
    if {$q eq ""} { return {} }
    # admin aliases point to exact teams
    set al [::md::db_get aliases $q]
    if {$al ne "" && [::md::db_exists teams $al]} { return [list [list 100 $al]] }
    # direct key "soccer:86"
    if {[::md::db_exists teams $query]} { return [list [list 100 $query]] }
    set qs [list $q]
    foreach {a full} $nick {
        if {[::md::norm $a] eq $q} { lappend qs [::md::norm $full] }
    }
    set res {}
    if {![info exists ::md::db(teams)]} { return {} }
    dict for {k t} $::md::db(teams) {
        if {$sport ne "" && ![string match "$sport:*" $k]} continue
        set best 0
        foreach qq $qs {
            set s [::md::mscore $qq [dict get $t norm]]
            if {$s > $best} { set best $s }
        }
        if {$best >= 50} {
            # prefer teams from top competitions / soccer on ties
            set bonus 0
            foreach lk [dict get $t lkeys] {
                set tier [::md::catalog::get $lk tier]
                if {$tier ne "" && 4 - $tier > $bonus} { set bonus [expr {4 - $tier}] }
            }
            # national youth/women sides rarely wanted unless asked for
            if {[regexp {\m(u\d\d|women|w)\M} [lindex [dict get $t norm] 0]] && ![regexp {u\d\d|women} $q]} { incr bonus -3 }
            lappend res [list [expr {$best * 10 + $bonus}] $k]
        }
    }
    set out {}
    foreach r [lrange [lsort -integer -decreasing -index 0 $res] 0 [expr {$limit - 1}]] {
        lappend out [list [expr {[lindex $r 0] / 10}] [lindex $r 1]]
    }
    return $out
}

# Decide if a ranked list has a clear winner
proc ::md::teams::_clear {cands} {
    if {![llength $cands]} { return "" }
    lassign [lindex $cands 0] s1 k1
    if {$s1 >= 100} { return $k1 }
    if {[llength $cands] == 1 && $s1 >= 60} { return $k1 }
    set s2 [lindex $cands 1 0]
    if {$s1 >= 75 && $s1 - $s2 >= 10} { return $k1 }
    if {$s1 >= 85 && $s1 > $s2} { return $k1 }
    return ""
}

proc ::md::teams::resolve {query cb {sport ""}} {
    set cands [find $query $sport]
    set k [_clear $cands]
    if {$k ne ""} { after 0 [linsert $cb end ok $k]; return }
    if {[::md::cfg teams.online_search 1]} {
        ::md::espn::search $query [list ::md::teams::_searched $query $sport $cb $cands]
        return
    }
    _finish $cb $cands
}

proc ::md::teams::_searched {query sport cb local status res} {
    if {$status eq "ok"} {
        foreach r $res {
            set sp [dict get $r sport]
            set slug [dict get $r slug]
            set lkey [::md::catalog::find $slug]
            if {$lkey eq "" && $sp ne "" && $slug ne ""} { set lkey [::md::catalog::find "$sp/$slug"] }
            learn $sp [dict get $r tid] [dict get $r name] [dict get $r name] "" $lkey
        }
    }
    set cands [find $query $sport]
    set k [_clear $cands]
    if {$k ne ""} { {*}$cb ok $k; return }
    # ESPN's own ordering is a good tie-breaker for its first hit
    if {$status eq "ok" && [llength $res]} {
        set r [lindex $res 0]
        set key "[dict get $r sport]:[dict get $r tid]"
        if {($sport eq "" || [dict get $r sport] eq $sport) && [llength $cands] && [lindex $cands 0 1] eq $key && [lindex $cands 0 0] >= 70} {
            {*}$cb ok $key
            return
        }
    }
    _finish $cb $cands
}

proc ::md::teams::_finish {cb cands} {
    if {![llength $cands]} { {*}$cb notfound ""; return }
    set keys {}
    foreach c [lrange $cands 0 5] { lappend keys [lindex $c 1] }
    if {[llength $keys] == 1} { {*}$cb ok [lindex $keys 0]; return }
    {*}$cb ambiguous $keys
}

# Main competition key for a team (for its sport/league paths)
proc ::md::teams::main_league {key} {
    set lks [get $key lkeys]
    set best ""
    set bt 9
    foreach lk $lks {
        set t [::md::catalog::get $lk tier]
        if {$t eq ""} continue
        # prefer domestic leagues over cups/continental for schedule paths
        if {$t < $bt} { set bt $t; set best $lk }
    }
    if {$best eq "" && [llength $lks]} { set best [lindex $lks 0] }
    if {$best eq ""} {
        # fall back to any league of the sport
        set sport [lindex [split $key :] 0]
        set best [lindex [::md::catalog::keys $sport] 0]
    }
    return $best
}

# ---------------------------------------------------------------- schedules

# Fetch (cached) team schedule. fixture: 1 upcoming, 0 results
proc ::md::teams::schedule {key fixture cb} {
    variable sched
    set ck "$key:$fixture"
    if {[info exists sched($ck)] && [clock seconds] - [lindex $sched($ck) 0] < 1800} {
        after 0 [linsert $cb end ok [lindex $sched($ck) 1]]
        return
    }
    lassign [split $key :] sport tid
    set lk [main_league $key]
    if {$lk eq ""} { after 0 [linsert $cb end error "no league for $key"]; return }
    ::md::espn::schedule $lk $tid $fixture [list ::md::teams::_sched $ck $cb]
}

proc ::md::teams::_sched {ck cb status data} {
    variable sched
    if {$status eq "ok"} {
        set sched($ck) [list [clock seconds] $data]
        foreach m $data {
            # keep snapshots fresh for commands (don't overwrite live data)
            if {[::md::poll::match [dict get $m uid]] eq ""} { ::md::poll::store $m }
        }
    }
    {*}$cb $status $data
}

# Leagues where this team plays within the next day (from cached fixtures)
proc ::md::teams::upcoming_leagues {key} {
    variable sched
    set now [clock seconds]
    set out {}
    if {[info exists sched($key:1)]} {
        foreach m [lindex $sched($key:1) 1] {
            set dt [expr {[dict get $m start] - $now}]
            if {$dt < 86400 && $dt > -4 * 3600} { lappend out [dict get $m lkey] }
        }
    }
    return $out
}

# Periodically refresh fixtures of all followed teams
proc ::md::teams::refresh_followed {} {
    variable sched
    set keys [::md::luniq [concat [::md::subs::followed_teams] [::md::chan_teams]]]
    set n 0
    foreach k $keys {
        if {[info exists sched($k:1)] && [clock seconds] - [lindex $sched($k:1) 0] < 6 * 3600} continue
        if {[incr n] > 25} break
        schedule $k 1 [list ::md::teams::_noop]
    }
}
proc ::md::teams::_noop {args} {}

proc ::md::chan_teams {} {
    set out {}
    foreach c [::md::chan::active] { lappend out {*}[::md::chan::get $c teams] {*}[::md::chan::get $c autonarr] }
    return $out
}

proc ::md::teams::init {} {
    ::md::store::load teams
    ::md::store::load aliases
    ::md::every teams.refresh 600000 ::md::teams::refresh_followed
    ::md::timer teams.first 15000 ::md::teams::refresh_followed
}
