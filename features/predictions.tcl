# Matchday - features/predictions.tcl
# Prediction game ("porra"). Each channel is its own league table.
#
#   !predict madrid 2-1            first number = the team you named
#   !predict madrid 2-1 sevilla    explicit
#   !preds [team]                  your open predictions / a match's
#   !porra                         open matches (+ admin: feature/reset/on/off)
#   !ranking [week|month|season|all]
#
# Scoring (configurable): exact score 3, right result and goal
# difference 2, right result 1. Featured matches multiply points.
# Predictions lock at kick-off and settle automatically at full time.

namespace eval ::md::preds {}

proc ::md::preds::scope_of {ctx {explicit ""}} {
    if {$explicit ne ""} { return [::md::chan::key $explicit] }
    if {[dict get $ctx chan] ne ""} { return [::md::chan::key [dict get $ctx chan]] }
    set home [::md::subs::pref [dict get $ctx ukey] home]
    if {$home ne ""} { return [::md::chan::key $home] }
    set cands {}
    foreach c [::md::chan::active] {
        if {[::md::chan::get $c porra]} { lappend cands $c }
    }
    if {[llength $cands] == 1} { return [::md::chan::key [lindex $cands 0]] }
    return ""
}

proc ::md::preds::chan_of_scope {scope} {
    foreach c [channels] { if {[::md::chan::key $c] eq $scope} { return $c } }
    return ""
}

proc ::md::preds::points {ph pa rh ra} {
    if {$ph == $rh && $pa == $ra} { return [::md::cfg preds.exact 3] }
    set po [expr {$ph > $pa ? 1 : ($ph < $pa ? -1 : 0)}]
    set ro [expr {$rh > $ra ? 1 : ($rh < $ra ? -1 : 0)}]
    if {$po != $ro} { return 0 }
    if {$ph - $pa == $rh - $ra} { return [::md::cfg preds.diff 2] }
    return [::md::cfg preds.outcome 1]
}

proc ::md::preds::season_start {} {
    set s [::md::cfg preds.season_start ""]
    if {$s ne "" && ![catch {clock scan $s -format %Y-%m-%d -timezone :UTC} t]} { return $t }
    set y [clock format [clock seconds] -format %Y -timezone :UTC]
    set m [scan [clock format [clock seconds] -format %m -timezone :UTC] %d]
    if {$m < 8} { incr y -1 }
    clock scan "$y-08-01" -format %Y-%m-%d -timezone :UTC
}

# ---------------------------------------------------------------- predict

proc ::md::preds::parse_score {argv} {
    # returns {teamtext n1 n2 teamtext2} or ""
    set text [join $argv " "]
    if {[regexp {^(.*?)\s+(\d{1,2})\s*[-:x]\s*(\d{1,2})\s*(.*)$} $text -> t1 a b t2]} {
        return [list [string trim $t1] $a $b [string trim $t2]]
    }
    return ""
}

proc ::md::preds::c_predict {ctx argv} {
    set lang [dict get $ctx lang]
    set explicit ""
    if {[string index [lindex $argv 0] 0] eq "#"} {
        set explicit [lindex $argv 0]
        set argv [lrange $argv 1 end]
    }
    set scope [scope_of $ctx $explicit]
    if {$scope eq ""} { ::md::cmd::err $ctx preds.noscope cmd [::md::cmdhint $lang predict]; return }
    set ch [chan_of_scope $scope]
    if {$ch ne "" && ![::md::chan::get $ch porra]} { ::md::cmd::err $ctx preds.disabled; return }
    set p [parse_score $argv]
    if {$p eq ""} { ::md::cmd::usage $ctx predict; return }
    lassign $p t1 a b t2
    if {$t1 eq ""} { ::md::cmd::usage $ctx predict; return }
    ::md::cmd::with_team $ctx $t1 [list ::md::preds::_team1 $ctx $scope $a $b $t2]
}

proc ::md::preds::_team1 {ctx scope a b t2 tkey} {
    set ms [::md::cmd::team_matches $tkey pre]
    set m [_upcoming $ms $tkey $t2]
    if {$m ne ""} { _place $ctx $scope $a $b $tkey $m; return }
    ::md::teams::schedule $tkey 1 [list ::md::preds::_team2 $ctx $scope $a $b $tkey $t2]
}

proc ::md::preds::_team2 {ctx scope a b tkey t2 status data} {
    set ms [::md::cmd::team_matches $tkey pre]
    if {$status eq "ok"} { lappend ms {*}$data }
    set m [_upcoming $ms $tkey $t2]
    if {$m eq ""} {
        ::md::cmd::err $ctx preds.nomatch team [::md::teams::label $tkey] days [::md::cfg preds.window_days 7]
        return
    }
    _place $ctx $scope $a $b $tkey $m
}

# Next open match within the window; with a rival given ("madrid 2-1
# sevilla"), only matches against that rival count
proc ::md::preds::_upcoming {ms {tkey ""} {rival ""}} {
    set now [clock seconds]
    set best ""
    foreach m $ms {
        if {[dict get $m state] ne "pre" || [dict get $m code] ne "scheduled"} continue
        if {[dict get $m kind] ne "team"} continue
        set dt [expr {[dict get $m start] - $now}]
        if {$dt <= 0 || $dt > [::md::cfg preds.window_days 7] * 86400} continue
        if {$rival ne "" && ![_against $m $tkey $rival]} continue
        if {$best eq "" || [dict get $m start] < [dict get $best start]} { set best $m }
    }
    return $best
}

proc ::md::preds::_against {m tkey rival} {
    set keys [::md::dispatch::team_keys $m]
    foreach c [::md::teams::find $rival [dict get $m sport]] {
        lassign $c s k
        if {$s >= 60 && $k ne $tkey && $k in $keys} { return 1 }
    }
    # teams not in the local index yet: compare names
    set q [::md::norm $rival]
    foreach side {home away} {
        set t [dict get $m $side]
        set names [list [::md::norm [dict get $t name]] [::md::norm [dict get $t short]] [::md::norm [dict get $t abbr]]]
        if {[::md::mscore $q $names] >= 60} { return 1 }
    }
    return 0
}

proc ::md::preds::_place {ctx scope a b tkey m} {
    set lang [dict get $ctx lang]
    set uid [dict get $m uid]
    # first number belongs to the team the user named
    set tid [lindex [split $tkey :] 1]
    if {[dict get $m home id] eq $tid} { set h $a; set aw $b } else { set h $b; set aw $a }
    ::md::poll::store $m
    ::md::poll::watch [dict get $m lkey] 600
    set ukey [dict get $ctx ukey]
    ::md::subs::touch $ukey [dict get $ctx nick]
    ::md::db_set users $ukey nick [dict get $ctx nick]
    set had [::md::db_exists preds open $scope $uid $ukey]
    ::md::db_set preds open $scope $uid $ukey [dict create h $h a $aw ts [clock seconds] nick [dict get $ctx nick]]
    # remember the match snapshot for settlement even if it leaves the cache
    ::md::db_set preds matches $uid [dict create lkey [dict get $m lkey] eid [dict get $m eid] \
        start [dict get $m start] home [dict get $m home name] away [dict get $m away name]]
    set mult [::md::dg [::md::db_get preds featured $scope] 1 $uid]
    set fx [expr {$mult > 1 ? " {c:gold}x$mult{/c}" : ""}]
    set txt "[::md::render::tn [dict get $m home]] {b}$h-$aw{b} [::md::render::tn [dict get $m away]]"
    ::md::reply $ctx [::md::t $lang [expr {$had ? "preds.updated" : "preds.saved"}] pred $txt \
        when [::md::render::when $lang [dict get $m start] [dict get $ctx tz]] league [::md::catalog::label [dict get $m lkey]]]$fx
}

# ---------------------------------------------------------------- settle

proc ::md::preds::on_event {ev m} {
    set type [dict get $ev type]
    if {$type ni {ft postponed cancelled abandoned}} return
    set uid [dict get $m uid]
    set open [::md::db_get preds open]
    if {$open eq ""} return
    dict for {scope byuid} $open {
        if {![dict exists $byuid $uid]} continue
        if {$type ne "ft"} {
            _void $scope $uid $m
        } else {
            settle $scope $uid $m
        }
    }
}
::md::hook::add event ::md::preds::on_event

proc ::md::preds::_void {scope uid m} {
    set n [dict size [::md::db_get preds open $scope $uid]]
    ::md::db_unset preds open $scope $uid
    set ch [chan_of_scope $scope]
    if {$ch ne "" && [::md::chan::enabled $ch] && $n > 0} {
        ::md::out::live $ch [::md::t [::md::chan::lang $ch] preds.void teams [::md::render::teams $m] n $n]
    }
}

proc ::md::preds::settle {scope uid m} {
    set rh [dict get $m home score]; set ra [dict get $m away score]
    if {![string is integer -strict $rh] || ![string is integer -strict $ra]} return
    set preds [::md::db_get preds open $scope $uid]
    set mult [::md::dg [::md::db_get preds featured $scope] 1 $uid]
    set now [clock seconds]
    set exact {}; set good {}; set zero 0
    set ledger [::md::db_get preds ledger $scope]
    dict for {ukey p} $preds {
        set pts [expr {[points [dict get $p h] [dict get $p a] $rh $ra] * $mult}]
        lappend ledger [list $now $uid $ukey $pts [expr {$pts == [::md::cfg preds.exact 3] * $mult}]]
        set nick [dict get $p nick]
        if {$pts == [::md::cfg preds.exact 3] * $mult} {
            lappend exact "$nick"
        } elseif {$pts > 0} {
            lappend good "$nick (+$pts)"
        } else {
            incr zero
        }
    }
    ::md::db_set preds ledger $scope $ledger
    ::md::db_unset preds open $scope $uid
    ::md::db_set preds settled $scope $uid [dict create h $rh a $ra ts $now n [dict size $preds]]
    ::md::db_unset preds featured $scope $uid
    # announce
    set ch [chan_of_scope $scope]
    if {$ch eq "" || ![::md::chan::enabled $ch] || ![::md::chan::get $ch porra]} return
    set lang [::md::chan::lang $ch]
    set parts {}
    if {[llength $exact]} { lappend parts [::md::t $lang preds.exact names [join $exact ", "] pts [expr {[::md::cfg preds.exact 3] * $mult}]] }
    if {[llength $good]} { lappend parts [::md::t $lang preds.good names [join [lrange $good 0 9] ", "]] }
    if {$zero} { lappend parts [::md::t $lang preds.zero n $zero] }
    set top [lindex [ranking $scope season] 0]
    set lead ""
    if {$top ne ""} { set lead " {c:dim}|{/c} [::md::t $lang preds.leader nick [lindex $top 1] pts [lindex $top 2]]" }
    ::md::out::live $ch "[::md::t $lang preds.settled score [::md::render::score $m "" 0]] [join $parts " {c:dim}·{/c} "]$lead"
}

# ---------------------------------------------------------------- ranking

# list of {ukey nick pts exact n}
proc ::md::preds::ranking {scope period} {
    set now [clock seconds]
    switch -- $period {
        week   { set from [expr {$now - 7 * 86400}] }
        month  { set from [expr {$now - 30 * 86400}] }
        all    { set from 0 }
        default { set from [season_start] }
    }
    set tot {}
    foreach e [::md::db_get preds ledger $scope] {
        lassign $e ts uid ukey pts ex
        if {$ts < $from} continue
        if {![dict exists $tot $ukey]} { dict set tot $ukey [list 0 0 0] }
        lassign [dict get $tot $ukey] p x n
        dict set tot $ukey [list [expr {$p + $pts}] [expr {$x + ($ex ? 1 : 0)}] [expr {$n + 1}]]
    }
    set rows {}
    dict for {ukey v} $tot {
        set nick [::md::db_get users $ukey nick]
        if {$nick eq ""} { set nick [string range $ukey 2 end] }
        lappend rows [list $ukey $nick {*}$v]
    }
    # points desc, exact desc, fewer predictions first
    lsort -command {apply {{x y} {
        if {[lindex $x 2] != [lindex $y 2]} { return [expr {[lindex $y 2] - [lindex $x 2]}] }
        if {[lindex $x 3] != [lindex $y 3]} { return [expr {[lindex $y 3] - [lindex $x 3]}] }
        expr {[lindex $x 4] - [lindex $y 4]}
    }}} $rows
}

proc ::md::preds::c_ranking {ctx argv} {
    set lang [dict get $ctx lang]
    set explicit ""
    if {[string index [lindex $argv 0] 0] eq "#"} { set explicit [lindex $argv 0]; set argv [lrange $argv 1 end] }
    set scope [scope_of $ctx $explicit]
    if {$scope eq ""} { ::md::cmd::err $ctx preds.noscope cmd [::md::cmdhint $lang ranking]; return }
    set pmap {week week semana week semaine week settimana week woche week
              month month mes month mois month mese month monat month
              all all todo all total all tutto all alle all tous all
              season season temporada season saison season stagione season}
    set period season
    set w [::md::norm [lindex $argv 0]]
    if {[dict exists $pmap $w]} { set period [dict get $pmap $w] }
    set rows [ranking $scope $period]
    if {![llength $rows]} { ::md::reply $ctx [::md::t $lang preds.empty cmd [::md::cmdhint $lang predict]]; return }
    set parts {}
    set i 0
    set me ""
    foreach r $rows {
        incr i
        lassign $r ukey nick pts ex n
        if {$i <= 10} {
            set medal [expr {$i == 1 ? "{c:gold}{s:trophy}{/c}" : "{c:rank}$i.{/c}"}]
            lappend parts "$medal$nick {b}$pts{b}"
        }
        if {$ukey eq [dict get $ctx ukey]} { set me [::md::t $lang preds.you pos $i pts $pts ex $ex n $n] }
    }
    set title [::md::t $lang preds.ranking period [::md::t $lang period.$period]]
    set line "{b}$title{b} [join $parts " "]"
    if {$me ne "" && $i > 10} { append line " {c:dim}|{/c} $me" }
    ::md::reply_lines $ctx [list $line]
}

# ---------------------------------------------------------------- listing

proc ::md::preds::c_preds {ctx argv} {
    set lang [dict get $ctx lang]
    set scope [scope_of $ctx]
    if {$scope eq ""} { ::md::cmd::err $ctx preds.noscope cmd [::md::cmdhint $lang preds]; return }
    if {![llength $argv]} {
        # my open predictions
        set ukey [dict get $ctx ukey]
        set parts {}
        dict for {uid byu} [::md::db_get preds open $scope] {
            if {![dict exists $byu $ukey]} continue
            set p [dict get $byu $ukey]
            set mi [::md::db_get preds matches $uid]
            lappend parts "[dict get $mi home] {b}[dict get $p h]-[dict get $p a]{b} [dict get $mi away]"
        }
        if {![llength $parts]} { ::md::reply $ctx [::md::t $lang preds.mine_none cmd [::md::cmdhint $lang predict]]; return }
        ::md::reply_lines $ctx [list "[::md::t $lang preds.mine]: [join $parts " {c:dim}|{/c} "]"]
        return
    }
    ::md::cmd::with_team $ctx [join $argv] [list ::md::preds::_match_preds $ctx $scope]
}

proc ::md::preds::_match_preds {ctx scope tkey} {
    set lang [dict get $ctx lang]
    set open [::md::db_get preds open $scope]
    set id [lindex [split $tkey :] 1]
    dict for {uid byu} $open {
        set mi [::md::db_get preds matches $uid]
        set m [::md::poll::match $uid]
        set hit 0
        if {$m ne "" && $tkey in [::md::dispatch::team_keys $m]} { set hit 1 }
        if {!$hit} continue
        set n [dict size $byu]
        # hide picks until kick-off so nobody copies
        if {[dict get $m state] eq "pre"} {
            ::md::reply $ctx [::md::t $lang preds.hidden teams [::md::render::teams $m] n $n]
            return
        }
        set parts {}
        dict for {ukey p} $byu { lappend parts "[dict get $p nick] [dict get $p h]-[dict get $p a]" }
        ::md::reply_lines $ctx [list "[::md::render::teams $m]: [join $parts ", "]"]
        return
    }
    ::md::reply $ctx [::md::t $lang preds.match_none team [::md::teams::label $tkey]]
}

proc ::md::preds::c_porra {ctx argv} {
    set lang [dict get $ctx lang]
    set chan [dict get $ctx chan]
    set sub [::md::norm [lindex $argv 0]]
    if {$sub in {feature destacar destaque vedette evidenzia hervorheben on off reset}} {
        if {$chan eq "" || ![::md::cmd::is_chanop $ctx]} { ::md::cmd::err $ctx err.perm; return }
        set scope [::md::chan::key $chan]
        switch -- $sub {
            on - off {
                ::md::chan::put $chan porra [expr {$sub eq "on"}]
                ::md::reply $ctx [::md::t $lang cfg.set key porra value $sub]
            }
            reset {
                if {![::md::cmd::is_admin $ctx]} { ::md::cmd::err $ctx err.perm; return }
                set arch [::md::db_get preds archive $scope]
                lappend arch [list [clock seconds] [ranking $scope all]]
                ::md::db_set preds archive $scope $arch
                ::md::db_set preds ledger $scope {}
                ::md::reply $ctx [::md::t $lang preds.reset]
            }
            default {
                set mult 2
                set rest [lrange $argv 1 end]
                if {[string match {x[0-9]} [lindex $rest end]]} { set mult [string range [lindex $rest end] 1 end]; set rest [lrange $rest 0 end-1] }
                # optional rival: "madrid vs sevilla", "madrid - sevilla"
                set rival ""
                set t [join $rest]
                if {[regexp -nocase {^(.+?)\s+(?:vs?\.?|-)\s+(.+)$} $t -> t rival]} { set t [string trim $t] }
                ::md::cmd::with_team $ctx $t [list ::md::preds::_feature $ctx $scope $mult $rival]
            }
        }
        return
    }
    # list open matches in channel leagues for the next 48h
    set lks [::md::cmd::ctx_leagues $ctx]
    ::md::cmd::fetch_boards [lrange $lks 0 7] "" [list ::md::preds::_porra_list $ctx]
}

proc ::md::preds::_feature {ctx scope mult rival tkey} {
    set m [_upcoming [::md::cmd::team_matches $tkey pre] $tkey $rival]
    if {$m eq ""} { ::md::cmd::err $ctx preds.nomatch team [::md::teams::label $tkey] days [::md::cfg preds.window_days 7]; return }
    ::md::db_set preds featured $scope [dict get $m uid] $mult
    ::md::reply $ctx [::md::t [dict get $ctx lang] preds.featured teams [::md::render::teams $m] mult $mult]
}

proc ::md::preds::_porra_list {ctx ms errs} {
    set lang [dict get $ctx lang]
    set scope [scope_of $ctx]
    set now [clock seconds]
    set parts {}
    foreach m $ms {
        if {[dict get $m state] ne "pre" || [dict get $m kind] ne "team"} continue
        if {[dict get $m start] - $now > 48 * 3600} continue
        set n [dict size [::md::db_get preds open $scope [dict get $m uid]]]
        set mult [::md::dg [::md::db_get preds featured $scope] 1 [dict get $m uid]]
        set l "[::md::render::line $lang $m [dict get $ctx tz]]"
        if {$mult > 1} { append l " {c:gold}x$mult{/c}" }
        if {$n} { append l " {c:dim}($n){/c}" }
        lappend parts $l
    }
    if {![llength $parts]} { ::md::reply $ctx [::md::t $lang preds.open_none]; return }
    ::md::reply_lines $ctx [concat [list [::md::t $lang preds.open_header cmd [::md::cmdhint $lang predict]]] \
        [::md::wrap [join [lrange $parts 0 19] " {c:dim}|{/c} "] 380]]
}

# leagues with open predictions must keep being polled to settle them
proc ::md::preds::leagues {} {
    set out {}
    set now [clock seconds]
    dict for {scope byuid} [::md::db_get preds open] {
        foreach uid [dict keys $byuid] {
            set mi [::md::db_get preds matches $uid]
            if {$mi eq ""} continue
            set dt [expr {[dict get $mi start] - $now}]
            if {$dt < 1800 && $dt > -6 * 3600} { lappend out [dict get $mi lkey] }
        }
    }
    return $out
}
::md::hook::add leagues ::md::preds::leagues

proc ::md::preds::keep {} {
    set out {}
    dict for {scope byuid} [::md::db_get preds open] { lappend out {*}[dict keys $byuid] }
    return $out
}
::md::hook::add keep_uids ::md::preds::keep

# Settle matches whose result we missed (bot offline at full time)
proc ::md::preds::sweep {} {
    set now [clock seconds]
    dict for {scope byuid} [::md::db_get preds open] {
        foreach uid [dict keys $byuid] {
            set mi [::md::db_get preds matches $uid]
            if {$mi eq "" || $now - [dict get $mi start] < 3 * 3600} continue
            set m [::md::poll::match $uid]
            if {$m ne "" && [dict get $m state] eq "post"} {
                if {[dict get $m code] in {ft aet pens}} { settle $scope $uid $m } else { _void $scope $uid $m }
                continue
            }
            # ask the provider directly
            ::md::espn::summary [dict get $mi lkey] [dict get $mi eid] [list ::md::preds::_sweep_got $scope $uid] 300
        }
    }
}

proc ::md::preds::_sweep_got {scope uid status r} {
    if {$status ne "ok"} return
    set m [dict get $r match]
    if {[dict get $m state] ne "post"} return
    if {![::md::db_exists preds open $scope $uid]} return
    if {[dict get $m code] in {ft aet pens}} { settle $scope $uid $m } else { _void $scope $uid $m }
}

proc ::md::preds::init {} {
    ::md::store::load preds
    ::md::every preds.sweep 1800000 ::md::preds::sweep
}

namespace eval ::md::cmd {
    def predict any ::md::preds::c_predict 2
    def preds   any ::md::preds::c_preds
    def porra   any ::md::preds::c_porra
    def ranking any ::md::preds::c_ranking
}
