# Matchday - features/narrator.tcl
# Template-based live narration of a specific match, to a channel or
# privately to a user.
#
# Soccer sessions read ESPN's match summary (key events, commentary,
# lineups, stats) and turn it into radio-style lines with plenty of
# variety: goals in context (equaliser, comeback, late winner, brace...),
# saves, woodwork, cards, subs, added time, pressure spells, tension at
# the end, half-time and full-time reports. Other sports narrate the
# engine events (scores, periods, sets, leaders) plus the provider's
# last-play text when available.
#
# Styles: full | normal | brief

namespace eval ::md::narr {
    variable S          ;# session id -> dict
    variable seq 0
    array set S {}
}

# ---------------------------------------------------------------- sessions

proc ::md::narr::sessions {{target ""} {uid ""}} {
    variable S
    set out {}
    foreach id [array names S] {
        set s $S($id)
        if {$target ne "" && ![string equal -nocase [dict get $s target] $target]} continue
        if {$uid ne "" && [dict get $s uid] ne $uid} continue
        lappend out $id
    }
    lsort -integer $out
}

proc ::md::narr::start {target kind owner m style lang {replay 0}} {
    variable S
    variable seq
    set id [incr seq]
    set S($id) [dict create id $id target $target kind $kind owner $owner \
        uid [dict get $m uid] lkey [dict get $m lkey] eid [dict get $m eid] sport [dict get $m sport] \
        style $style lang $lang started [clock seconds] \
        seenk {} seenc {} score {h 0 a 0} scorers {} trailed {h 0 a 0} goals {} reds {h 0 a 0} \
        primed 0 lineups 0 intro 0 lastok 0 fails 0 lastbeat 0 lastpress 0 tension 0 \
        added {} shots {} lastplay "" ended 0 match $m stats {} snap $m replay $replay]
    if {$replay} { return $id }
    ::md::poll::watch [dict get $m lkey] 14400
    save
    # first poll right away
    ::md::timer narr.$id 500 [list ::md::narr::poll $id]
    return $id
}

proc ::md::narr::stop {id {announce 1}} {
    variable S
    variable last
    unset -nocomplain last($id)
    if {![info exists S($id)]} return
    set s $S($id)
    ::md::cancel narr.$id
    unset S($id)
    if {$announce} {
        say $s [::md::t [dict get $s lang] narr.stopped teams [::md::render::teams [dict get $s match]]]
    }
    save
}

proc ::md::narr::save {} {
    variable S
    set d {}
    foreach id [array names S] {
        set s $S($id)
        if {[::md::dg $s 0 replay]} continue
        # persist only what is needed to resume
        dict set d $id [dict filter $s key id target kind owner uid lkey eid sport style lang started seenk seenc score scorers trailed primed lineups intro added tension goals reds]
    }
    set ::md::db(narr) $d
    ::md::store::mark narr
}

proc ::md::narr::restore {} {
    variable S
    variable seq
    set d [::md::store::load narr]
    dict for {id s} $d {
        if {[clock seconds] - [dict get $s started] > 6 * 3600} continue
        set m [::md::poll::match [dict get $s uid]]
        if {$m eq ""} {
            set m [dict create uid [dict get $s uid] lkey [dict get $s lkey] eid [dict get $s eid] \
                sport [dict get $s sport] kind team state in code live home {name ? short ? id "" score 0 so ""} \
                away {name ? short ? id "" score 0 so ""} events {} start 0 lname "" minute "" detail "" period 0 note "" tv {} venue ""]
        }
        set S($id) [dict merge [dict create lastok 0 fails 0 lastbeat 0 lastpress 0 shots {} lastplay "" ended 0 reds {h 0 a 0} goals {} \
            match $m stats {} snap $m] $s]
        if {$id > $seq} { set seq $id }
        ::md::poll::watch [dict get $s lkey] 14400
        ::md::timer narr.$id [expr {2000 + $id * 300}] [list ::md::narr::poll $id]
    }
}

proc ::md::narr::say {s text} {
    variable S
    variable last
    set target [dict get $s target]
    set id [dict get $s id]
    # never repeat the exact same line twice in a row
    if {[info exists last($id)] && $last($id) eq $text} return
    set last($id) $text
    if {![string match "{s:mic}*" $text]} { set text "{c:dim}{s:mic}{/c} $text" }
    if {[dict get $s kind] eq "user"} {
        set ukey [::md::subs::ukey $target [nick2hand $target]]
        ::md::out::live $target $text [expr {[::md::subs::pref $ukey delivery] eq "notice"}] 0
    } else {
        ::md::out::live $target $text 0 0
    }
}

# suppress normal event lines on channels narrating this match
proc ::md::narr::suppress {chan uid} {
    if {[llength [sessions $chan $uid]]} { return [list 1] }
    return {}
}
::md::hook::add suppress_chan ::md::narr::suppress

proc ::md::narr::leagues {} {
    variable S
    set out {}
    foreach id [array names S] { lappend out [dict get $S($id) lkey] }
    return $out
}
::md::hook::add leagues ::md::narr::leagues

proc ::md::narr::keep {} {
    variable S
    set out {}
    foreach id [array names S] { lappend out [dict get $S($id) uid] }
    return $out
}
::md::hook::add keep_uids ::md::narr::keep

# ---------------------------------------------------------------- polling

proc ::md::narr::poll {id} {
    variable S
    if {![info exists S($id)]} return
    set s $S($id)
    if {[::md::dg $s 0 replay]} return
    set m [::md::poll::match [dict get $s uid]]
    if {$m ne ""} { dict set S($id) snap $m; dict set S($id) match $m }
    set m [dict get $S($id) match]
    set state [dict get $m state]
    if {[dict get $s sport] eq "soccer"} {
        ::md::espn::summary [dict get $s lkey] [dict get $s eid] [list ::md::narr::_sum $id] 5
    } else {
        _generic_tick $id
    }
    # schedule next poll
    set now [clock seconds]
    if {$state eq "in"} {
        set next [::md::cfg narr.poll 20]
    } elseif {$state eq "pre"} {
        set dt [expr {[dict get $m start] - $now}]
        set next [expr {$dt > 5400 ? 600 : ($dt > 900 ? 120 : 30)}]
    } else {
        set next 60
    }
    ::md::timer narr.$id [expr {$next * 1000}] [list ::md::narr::poll $id]
}

proc ::md::narr::_sum {id status r} {
    variable S
    if {![info exists S($id)]} return
    if {$status ne "ok"} {
        dict incr S($id) fails
        if {[dict get $S($id) fails] == 5} { ::md::log warn "narrator $id: summary failing ($r)" }
        return
    }
    dict set S($id) fails 0
    dict set S($id) lastok [clock seconds]
    set m [dict get $r match]
    # keep lkey/league name from our catalog
    dict set m lkey [dict get $S($id) lkey]
    dict set m lname [::md::catalog::label [dict get $S($id) lkey]]
    set snap [dict get $S($id) snap]
    if {[dict get $m minute] eq "" && [dict get $snap minute] ne ""} { dict set m minute [dict get $snap minute] }
    dict set S($id) match $m
    dict set S($id) stats [dict get $r stats]
    if {[dict exists $r odds]} { ::md::prob::prematch [dict get $S($id) uid] [dict get $r odds] }
    if {[catch {soccer $id $r} err opts]} {
        ::md::log error "narrator $id: $err"
        ::md::log debug [dict get $opts -errorinfo]
    }
}

# ---------------------------------------------------------------- soccer narration

# Chronological order key from the displayed minute ("90+5'") because
# ESPN caps the clock value at 45:00/90:00 during added time.
proc ::md::narr::ord {min clock} {
    if {[regexp {^(\d+)(?:\+(\d+))?} $min -> m x]} {
        if {$x eq ""} { set x 0 }
        return [expr {([scan $m %d] + [scan $x %d]) * 60 + $clock % 60}]
    }
    return $clock
}

proc ::md::narr::T {s key args} {
    ::md::t [dict get $s lang] $key {*}$args
}

proc ::md::narr::tn {m side} {
    ::md::render::tn [dict get $m [expr {$side eq "h" ? "home" : "away"}]]
}

proc ::md::narr::scoreline {s} {
    set m [dict get $s match]
    set sc [dict get $s score]
    return "[tn $m h] {b}[dict get $sc h]-[dict get $sc a]{b} [tn $m a]"
}

proc ::md::narr::soccer {id r} {
    variable S
    set s $S($id)
    set m [dict get $s match]
    set style [dict get $s style]
    set lang [dict get $s lang]

    # --- first contact: intro, or "joining at 67'" without replaying history
    if {![dict get $s primed]} {
        set seenk {}
        set seenc {}
        set started [expr {[dict get $m state] ne "pre"}]
        if {$started} {
            foreach k [dict get $r keyev] { dict set seenk [dict get $k id] 1 }
            foreach c [dict get $r comm] { dict set seenc [dict get $c seq] 1 }
            # rebuild score/scorers from key events silently
            set sc [dict create h 0 a 0]
            set goals {}
            foreach k [dict get $r keyev] {
                if {[dict get $k scoring] && ![dict get $k so]} {
                    set side [_goal_side $k $sc $m]
                    if {$side ne ""} {
                        dict incr sc $side
                        set gt [expr {[dict get $k type] eq "own-goal" ? "og" : ([dict get $k type] eq "penalty---scored" ? "pen" : "goal")}]
                        lappend goals [list $side [lindex [dict get $k players] 0] [dict get $k min] $gt]
                    }
                }
            }
            dict set S($id) goals $goals
            # trust the header score when available
            if {[string is integer -strict [dict get $m home score]]} {
                set sc [dict create h [dict get $m home score] a [dict get $m away score]]
            }
            dict set S($id) score $sc
            dict set S($id) seenk $seenk
            dict set S($id) seenc $seenc
            dict set S($id) intro 1
            dict set S($id) primed 1
            if {[dict get $m state] eq "in"} {
                say $S($id) [T $s narr.join min [dict get $m minute] score [scoreline $S($id)] \
                    league [::md::catalog::label [dict get $s lkey]] scorers [::md::render::scorers_suffix $lang $m]]
            }
        } else {
            dict set S($id) primed 1
        }
        set s $S($id)
    }

    # --- pre-match intro and lineups
    if {[dict get $m state] eq "pre"} {
        if {![dict get $s intro]} {
            dict set S($id) intro 1
            set tz [expr {[dict get $s kind] eq "chan" ? [::md::chan::get [dict get $s target] tz] : [::md::subs::pref [::md::subs::ukey [dict get $s target]] tz]}]
            set extra ""
            if {[dict get $r venue] ne ""} { append extra " {c:dim}@ [dict get $r venue]{/c}" }
            say $S($id) [T $s narr.intro teams [::md::render::teams $m] league [::md::catalog::label [dict get $s lkey]] \
                time [::md::render::when $lang [dict get $m start] $tz]]$extra
            if {[dict exists $r odds] && [dict size [dict get $r odds]]} {
                set o [dict get $r odds]
                say $S($id) [::md::prob::line $lang $m [dict create h [dict get $o h] d [dict get $o d] a [dict get $o a] src odds]]
            }
            set f [dict get $r form]
            if {[dict size $f] == 2} {
                say $S($id) [T $s narr.form home [tn $m h] away [tn $m a] \
                    hf [::md::cmd::form_str [dict get $f h] $lang] af [::md::cmd::form_str [dict get $f a] $lang]]
            }
        }
        if {![dict get $S($id) lineups] && [dict size [dict get $r lineups]] == 2} {
            dict set S($id) lineups 1
            say $S($id) [T $s narr.lineups_in]
            foreach l [::md::cmd::lineup_lines $lang $m $r] {
                if {[string match "{c:dim}*" $l] && $style ne "full"} continue
                say $S($id) $l
            }
        }
        return
    }

    # --- collect new key events and commentary, chronologically
    set items {}
    foreach k [dict get $r keyev] {
        if {[dict exists $S($id) seenk [dict get $k id]]} continue
        dict set S($id) seenk [dict get $k id] 1
        set pri [expr {[dict get $k type] in {halftime end-regular-time} ? 2 : 0}]
        lappend items [list [ord [dict get $k min] [dict get $k clock]] $pri k $k]
    }
    set skip {goal yellow-card red-card substitution penalty---scored penalty---missed penalty---saved own-goal halftime kickoff start-2nd-half end-regular-time}
    foreach c [dict get $r comm] {
        if {[dict exists $S($id) seenc [dict get $c seq]]} continue
        dict set S($id) seenc [dict get $c seq] 1
        if {[dict get $c ptype] in $skip} continue
        lappend items [list [ord [dict get $c min] [dict get $c clock]] 1 c $c]
    }
    set items [lsort -integer -index 0 [lsort -integer -index 1 $items]]
    set budget [::md::cfg narr.max_lines [expr {$style eq "full" ? 8 : 6}]]
    set minor 0
    foreach it $items {
        lassign $it clk pri kind x
        if {$kind eq "k"} {
            _keyev $id $x
        } else {
            if {$minor >= $budget} continue
            if {[_comm $id $x]} { incr minor }
        }
    }

    set m [dict get $S($id) match]
    # --- periodic update / pressure / tension (normal & full)
    if {$style ne "brief" && [dict get $m state] eq "in"} {
        _heartbeat $id
    }

    # --- end of match
    if {[dict get $m state] eq "post" && ![dict get $S($id) ended]} {
        dict set S($id) ended 1
        _fulltime $id $r
        set sid $id
        ::md::timer narr.end.$sid 5000 [list ::md::narr::stop $sid 0]
    }
    save
}

# which side scored a key event (parse "Goal! Home 1, Away 2." when present)
proc ::md::narr::_goal_side {k sc m} {
    # (\D+? avoids Tcl's greedy/non-greedy mixing pitfalls; handles "St. Pauli")
    if {[regexp {(?:Goal!|Own Goal by [^,]*,[^.]*(?:\.[^.]*)?\.)\s+(\D+?) (\d+), (\D+?) (\d+)\.} [dict get $k text] -> n1 s1 n2 s2]} {
        # map names to sides
        set h1 [::md::espn::_sidebyname $n1 [dict get $m home] [dict get $m away]]
        if {$h1 eq "a"} { lassign [list $s2 $s1] s1 s2 }
        if {$s1 > [dict get $sc h]} { return h }
        if {$s2 > [dict get $sc a]} { return a }
    }
    set side [dict get $k side]
    if {[dict get $k type] eq "own-goal" && $side ne ""} { return [expr {$side eq "h" ? "a" : "h"}] }
    return $side
}

proc ::md::narr::_keyev {id k} {
    variable S
    set s $S($id)
    set m [dict get $s match]
    set style [dict get $s style]
    set type [dict get $k type]
    set side [dict get $k side]
    set min [dict get $k min]
    set ps [dict get $k players]
    set p1 [lindex $ps 0]
    set p2 [lindex $ps 1]
    set team [expr {$side ne "" ? [tn $m $side] : ""}]
    set opp [expr {$side ne "" ? [tn $m [expr {$side eq "h" ? "a" : "h"}]] : ""}]

    if {[dict get $k so]} {
        set ok [dict get $k scoring]
        say $s [T $s [expr {$ok ? "narr.so.scored" : "narr.so.missed"}] player $p1 team $team]
        return
    }
    switch -glob -- $type {
        kickoff {
            say $s [T $s narr.kickoff home [tn $m h] away [tn $m a] league [::md::catalog::label [dict get $s lkey]]]
        }
        goal - penalty---scored - own-goal - goal---* {
            set sc [dict get $s score]
            set gs [_goal_side $k $sc $m]
            if {$gs eq ""} { set gs h }
            set before $sc
            dict incr sc $gs
            dict set S($id) score $sc
            set team [tn $m $gs]
            set opp [tn $m [expr {$gs eq "h" ? "a" : "h"}]]
            set og [expr {$type eq "own-goal" || [string match -nocase "*own goal*" [dict get $k text]]}]
            set pen [expr {$type eq "penalty---scored"}]
            set n 0
            if {!$og && $p1 ne ""} {
                set sco [dict get $S($id) scorers]
                dict incr sco $p1
                dict set S($id) scorers $sco
                set n [dict get $sco $p1]
            }
            # context
            set mine [dict get $sc $gs]
            set theirs [dict get $sc [expr {$gs eq "h" ? "a" : "h"}]]
            set bm [dict get $before $gs]
            set bt [dict get $before [expr {$gs eq "h" ? "a" : "h"}]]
            set mm 0
            regexp {^(\d+)} $min -> mm
            if {$theirs > $mine} { dict set S($id) trailed $gs 1 }
            set ctx goal
            if {$og} {
                set ctx og
            } elseif {$n == 3} {
                set ctx hattrick
            } elseif {$mine > $theirs && $bm <= $bt && [dict get $S($id) trailed $gs]} {
                set ctx comeback
            } elseif {$mm >= 85 && $mine > $theirs && $bm <= $bt} {
                set ctx latewinner
            } elseif {$mine == $theirs} {
                set ctx equaliser
            } elseif {$n == 2} {
                set ctx brace
            } elseif {$pen} {
                set ctx pen
            } elseif {$mine - $theirs >= 3} {
                set ctx rout
            } elseif {$bm == 0 && $bt == 0} {
                set ctx first
            } elseif {$mine > $theirs && $bm == $bt} {
                set ctx lead
            }
            if {$theirs > $mine} { set ctx consolation }
            if {$mine < $theirs} { dict set S($id) trailed $gs 1 }
            if {$theirs < $mine} { dict set S($id) trailed [expr {$gs eq "h" ? "a" : "h"}] 1 }
            dict lappend S($id) goals [list $gs $p1 $min [expr {$og ? "og" : ($pen ? "pen" : "goal")}]]
            set ast [expr {$p2 ne "" && !$og ? [T $s narr.assist name $p2] : ""}]
            set key narr.goal.$ctx
            if {![::md::i18n::has [dict get $s lang] $key]} { set key narr.goal.goal }
            say $s [T $s $key player $p1 team $team opp $opp min $min score [scoreline $S($id)] assist $ast n $n]
            if {$style ne "brief"} { _prob $id $min }
            # VAR checks sometimes follow; shown by "var" events
        }
        yellow-card {
            if {[string match -nocase "*second yellow*" [dict get $k text]] && $side ne ""} {
                dict set S($id) reds $side [expr {[dict get $S($id) reds $side] + 1}]
            }
            if {$style eq "brief"} return
            if {[string match -nocase "*second yellow*" [dict get $k text]]} {
                say $s [T $s narr.yred player $p1 team $team min $min]
            } else {
                say $s [T $s narr.yellow player $p1 team $team min $min]
            }
        }
        red-card {
            if {$side ne ""} { dict set S($id) reds $side [expr {[dict get $S($id) reds $side] + 1}] }
            if {[string match -nocase "*second yellow*" [dict get $k text]]} {
                say $s [T $s narr.yred player $p1 team $team min $min]
            } else {
                say $s [T $s narr.red player $p1 team $team min $min]
            }
        }
        substitution {
            if {$style eq "brief"} return
            say $s [T $s narr.sub pin $p1 pout $p2 team $team min $min]
        }
        penalty---missed - penalty---saved {
            say $s [T $s [expr {$type eq "penalty---saved" ? "narr.pensaved" : "narr.penmiss"}] player $p1 team $team min $min]
        }
        halftime {
            set m [dict get $S($id) match]
            say $s [T $s narr.ht score [scoreline $S($id)] scorers [::md::render::scorers_suffix [dict get $s lang] $m]]
            set st [::md::cmd::stats_brief [dict get $s lang] [dict create stats [dict get $S($id) stats]]]
            if {$st ne "" && $style ne "brief"} { say $s $st }
            if {$style ne "brief"} { _prob $id "45'" ht }
        }
        start-2nd-half {
            say $s [T $s narr.2h score [scoreline $S($id)]]
        }
        end-regular-time {
            set m [dict get $S($id) match]
            # only relevant when extra time follows (FT is handled separately)
            if {[dict get $m state] eq "in"} { say $s [T $s narr.end90 score [scoreline $S($id)]] }
        }
        start-delay {
            if {$style eq "full"} { say $s [T $s narr.delay min $min] }
        }
        *var* {
            say $s [T $s narr.var min $min text [dict get $k text]]
        }
        default {
            if {[string match -nocase "*extra*time*" [dict get $k ttext]] && [string match -nocase "start*" [dict get $k ttext]]} {
                say $s [T $s narr.et score [scoreline $S($id)]]
            } elseif {[string match -nocase "*shootout*" [dict get $k ttext]] || [string match -nocase "*penalt*shoot*" [dict get $k ttext]]} {
                say $s [T $s narr.shootout score [scoreline $S($id)]]
            }
        }
    }
}

# win probability line using the narrator's own score/reds
proc ::md::narr::_prob {id min {code live}} {
    variable S
    set s $S($id)
    set m [dict get $s match]
    set sc [dict get $s score]
    set mm [dict replace $m minute $min code $code state in \
        home [dict replace [dict get $m home] score [dict get $sc h]] \
        away [dict replace [dict get $m away] score [dict get $sc a]]]
    if {[catch {::md::prob::soccer $mm [dict get $s reds]} p]} return
    set text "{c:dim}[::md::prob::line [dict get $s lang] $mm $p]{/c}"
    # nothing new to say if the numbers did not move
    if {[::md::dg $s "" lastprob] eq $text} return
    dict set S($id) lastprob $text
    say $s $text
}

# commentary lines; returns 1 if something was said
proc ::md::narr::_comm {id c} {
    variable S
    set s $S($id)
    set m [dict get $s match]
    set style [dict get $s style]
    if {$style eq "brief"} { return 0 }
    set side [dict get $c side]
    set team [expr {$side ne "" ? [tn $m $side] : ""}]
    set p1 [lindex [dict get $c players] 0]
    set p2 [lindex [dict get $c players] 1]
    set min [dict get $c min]
    set text [dict get $c text]
    # remember shots for pressure detection
    if {[string match shot-* [dict get $c ptype]] && $side ne ""} {
        dict lappend S($id) shots [list [dict get $c clock] $side]
    }
    # added time announcements
    if {[regexp -nocase {(\d+) minutes? of added time} $text -> n]} {
        set key [dict get $c clock]
        if {![dict exists [dict get $S($id) added] $key]} {
            dict set S($id) added $key 1
            say $s [T $s narr.added n $n]
            return 1
        }
        return 0
    }
    switch -- [dict get $c ptype] {
        shot-on-target {
            if {$p1 eq ""} { return 0 }
            # saved shots: name the keeper when the text says so
            set keeper ""
            regexp {saved [^.]*?by ([^(]+?) \(} $text -> keeper
            if {$keeper ne ""} {
                say $s [T $s narr.save player $p1 team $team min $min keeper [string trim $keeper]]
            } else {
                say $s [T $s narr.shot player $p1 team $team min $min]
            }
            return 1
        }
        shot-hit-woodwork {
            say $s [T $s narr.woodwork player $p1 team $team min $min]
            return 1
        }
        shot-off-target {
            if {$style ne "full" || $p1 eq ""} { return 0 }
            # only "close" misses to avoid noise
            if {![regexp -nocase {close|just|narrowly|over the bar|wide of} $text]} { return 0 }
            say $s [T $s narr.miss player $p1 team $team min $min]
            return 1
        }
        corner-awarded {
            if {$style ne "full"} { return 0 }
            say $s [T $s narr.corner team $team min $min]
            return 1
        }
        offside { return 0 }
        default { return 0 }
    }
}

proc ::md::narr::_heartbeat {id} {
    variable S
    set s $S($id)
    set m [dict get $s match]
    set mm 0
    if {![regexp {^(\d+)} [dict get $m minute] -> mm]} {
        set snap [dict get $s snap]
        regexp {^(\d+)} [dict get $snap minute] -> mm
    }
    if {$mm == 0} return
    set sc [dict get $s score]
    set diff [expr {abs([dict get $sc h] - [dict get $sc a])}]
    # every 15 minutes (except 45/90 handled by ht/ft)
    set slot [expr {$mm / 15 * 15}]
    if {$slot > 0 && $slot ni {45 90} && $slot > [dict get $s lastbeat] && $mm - $slot < 5} {
        dict set S($id) lastbeat $slot
        set poss ""
        set ph [::md::dg $s "" stats h possessionPct]
        if {$ph ne ""} {
            set poss [T $s narr.poss home [tn $m h] ph [expr {round($ph)}] away [tn $m a] pa [expr {round([::md::dg $s 0 stats a possessionPct])}]]
        }
        say $S($id) [T $s narr.update min "$mm'" score [scoreline $S($id)] poss $poss]
    }
    # pressure: 3+ shots by one side within 5 minutes
    set recent {}
    set now [expr {$mm * 60}]
    foreach x [dict get $S($id) shots] {
        if {$now - [lindex $x 0] <= 300} { lappend recent [lindex $x 1] }
    }
    dict set S($id) shots [lrange [dict get $S($id) shots] end-20 end]
    foreach side {h a} {
        set n [llength [lsearch -all $recent $side]]
        if {$n >= 3 && $mm - [dict get $S($id) lastpress] >= 10} {
            dict set S($id) lastpress $mm
            say $S($id) [T $s narr.pressure team [tn $m $side] n $n]
            break
        }
    }
    # tension at the end of tight games
    if {$mm >= 85 && $diff <= 1 && ![dict get $S($id) tension]} {
        dict set S($id) tension 1
        set key [expr {$diff == 0 ? "narr.tension.draw" : "narr.tension.close"}]
        set lead [expr {[dict get $sc h] > [dict get $sc a] ? [tn $m h] : [tn $m a]}]
        say $S($id) [T $s $key score [scoreline $S($id)] team $lead]
    }
}

# " (Lautaro 44' 81' | Tresoldi 30' (pen) 63')" from the goals narrated
proc ::md::narr::_scorers {id} {
    variable S
    set lang [dict get $S($id) lang]
    set parts {}
    foreach side {h a} {
        set by {}
        foreach g [::md::dg $S($id) {} goals] {
            lassign $g gs p min gt
            # own goals are listed under the team that benefited
            if {$gs ne $side} continue
            if {$p eq ""} { set p "?" }
            set tag [expr {$gt eq "pen" ? [::md::t $lang tag.pen] : ($gt eq "og" ? [::md::t $lang tag.og] : "")}]
            dict lappend by $p "$min$tag"
        }
        set l {}
        dict for {p mins} $by { lappend l "$p [join $mins " "]" }
        if {[llength $l]} { lappend parts [join $l ", "] }
    }
    if {![llength $parts]} { return "" }
    return " {c:dim}([join $parts " | "]){/c}"
}

proc ::md::narr::_fulltime {id r} {
    variable S
    set s $S($id)
    set m [dict get $s match]
    set lang [dict get $s lang]
    set h [dict get $m home]; set a [dict get $m away]
    set hs [dict get $h score]; set as [dict get $a score]
    if {[string is integer -strict $hs]} { dict set S($id) score [dict create h $hs a $as] }
    set code [dict get $m code]
    if {$code eq "pens" || ([dict get $h so] ne "" && [dict get $h so] ne [dict get $a so] && [dict get $h so] ne "0")} {
        set w [expr {[dict get $h so] > [dict get $a so] ? [tn $m h] : [tn $m a]}]
        say $S($id) [T $s narr.ft.pens score [scoreline $S($id)] winner $w so "[dict get $h so]-[dict get $a so]"]
    } elseif {$hs == $as} {
        say $S($id) [T $s narr.ft.draw score [scoreline $S($id)]]
    } else {
        set w [expr {$hs > $as ? [tn $m h] : [tn $m a]}]
        set l [expr {$hs > $as ? [tn $m a] : [tn $m h]}]
        say $S($id) [T $s narr.ft.win score [scoreline $S($id)] winner $w loser $l]
    }
    set sc [_scorers $id]
    if {$sc eq ""} { set sc [::md::render::scorers_suffix $lang $m] }
    if {$sc ne ""} { say $S($id) "{s:goal}$sc" }
    set st [::md::cmd::stats_brief $lang $r]
    if {$st ne ""} { say $S($id) $st }
    say $S($id) [T $s narr.signoff]
}

# ---------------------------------------------------------------- other sports

proc ::md::narr::_generic_tick {id} {
    variable S
    set s $S($id)
    set m [dict get $s match]
    if {![dict get $s primed]} {
        dict set S($id) primed 1
        set lang [dict get $s lang]
        if {[dict get $m state] eq "pre"} {
            say $s [T $s narr.intro teams [::md::render::teams $m] league [::md::catalog::label [dict get $s lkey]] \
                time [::md::render::when $lang [dict get $m start] UTC]]
        } else {
            say $s [T $s narr.join_generic score [::md::render::score $m] detail [dict get $m detail] league [::md::catalog::label [dict get $s lkey]]]
        }
    }
    # relay last-play text (US sports) when it changes
    if {[dict get $s style] ne "brief" && [dict exists $m lastplay]} {
        set lp [dict get $m lastplay]
        if {$lp ne "" && $lp ne [dict get $s lastplay]} {
            dict set S($id) lastplay $lp
            if {[dict get $s style] eq "full" || [regexp -nocase {touchdown|field goal|interception|fumble|home run|homers|sacked|goal} $lp]} {
                say $S($id) "{c:dim}[dict get $m detail]{/c} $lp"
            }
        }
    }
    if {[dict get $m state] eq "post" && ![dict get $S($id) ended]} {
        dict set S($id) ended 1
        ::md::timer narr.end.$id 3000 [list ::md::narr::stop $id 0]
    }
}

# Engine events for narrated non-soccer matches (and soccer fallback)
proc ::md::narr::on_event {ev m} {
    variable S
    foreach id [sessions "" [dict get $m uid]] {
        set s $S($id)
        dict set S($id) match $m
        dict set S($id) snap $m
        if {[::md::dg $s 0 replay]} continue
        if {[dict get $s sport] eq "soccer"} {
            # fallback when the summary endpoint is unavailable
            if {[clock seconds] - [dict get $s lastok] < 90} continue
            if {[dict get $ev type] ni {goal disallowed card kickoff ht ft}} continue
            if {[dict get $ev type] eq "goal"} {
                dict set S($id) score [dict create h [dict get $ev h] a [dict get $ev a]]
            }
        }
        set text [::md::render::event [dict get $s lang] $ev $m]
        if {$text ne ""} { say $s $text }
        if {[dict get $ev type] eq "ft" && [dict get $s sport] ne "soccer"} {
            dict set S($id) ended 1
            say $s [T $s narr.signoff]
            ::md::timer narr.end.$id 3000 [list ::md::narr::stop $id 0]
        }
    }
}
::md::hook::add event ::md::narr::on_event

# ---------------------------------------------------------------- command

proc ::md::narr::c_narrate {ctx argv} {
    set lang [dict get $ctx lang]
    set chan [dict get $ctx chan]
    set target [expr {$chan ne "" ? $chan : [dict get $ctx nick]}]
    set kind [expr {$chan ne "" ? "chan" : "user"}]
    set w [::md::norm [lindex $argv 0]]
    if {![llength $argv] || $w in {list lista liste elenco}} {
        set ids [sessions [expr {$kind eq "chan" ? $chan : ""}]]
        if {$kind eq "user"} { set ids [sessions $target] }
        if {![llength $ids]} { ::md::reply $ctx [::md::t $lang narr.none]; return }
        set parts {}
        foreach id $ids {
            variable S
            lappend parts "#$id [::md::render::score [dict get $S($id) match]] ([dict get $S($id) style])"
        }
        ::md::reply $ctx [join $parts " | "]
        return
    }
    if {$w in {off stop parar para stopp arret fin ferma apagar aus}} {
        set ids [sessions $target]
        if {[llength $argv] > 1} {
            # stop a specific one by number
            set n [string trimleft [lindex $argv 1] #]
            if {[string is integer -strict $n] && $n in $ids} { set ids [list $n] }
        }
        if {![llength $ids]} { ::md::reply $ctx [::md::t $lang narr.none]; return }
        foreach id $ids { stop $id }
        return
    }
    # style as last word
    set style [::md::cfg narr.style normal]
    set last [::md::norm [lindex $argv end]]
    set smap {full full completa full completo full complet full komplett full
              normal normal normale normal
              brief brief breve brief corta brief court brief kurz brief resumen brief}
    if {[llength $argv] > 1 && [dict exists $smap $last]} {
        set style [dict get $smap $last]
        set argv [lrange $argv 0 end-1]
    }
    # limits
    if {$kind eq "chan"} {
        if {[llength [sessions $chan]] >= [::md::chan::get $chan maxnarr]} {
            ::md::cmd::err $ctx narr.limit n [::md::chan::get $chan maxnarr]
            return
        }
    } elseif {[llength [sessions $target]] >= [::md::cfg narr.max_per_user 1]} {
        ::md::cmd::err $ctx narr.limit n [::md::cfg narr.max_per_user 1]
        return
    }
    variable S
    if {[array size S] >= [::md::cfg narr.max_total 12]} {
        ::md::cmd::err $ctx narr.limit n [::md::cfg narr.max_total 12]
        return
    }
    set nlang [expr {$kind eq "chan" ? [::md::chan::lang $chan] : [dict get $ctx ulang]}]
    ::md::cmd::with_team $ctx [join $argv] [list ::md::narr::_found $ctx $target $kind $style $nlang]
}

proc ::md::narr::_found {ctx target kind style lang tkey} {
    set ms [::md::cmd::team_matches $tkey]
    set m [_pick $ms]
    if {$m ne ""} { _go $ctx $target $kind $style $lang $m; return }
    ::md::teams::schedule $tkey 1 [list ::md::narr::_found2 $ctx $target $kind $style $lang $tkey]
}

proc ::md::narr::_found2 {ctx target kind style lang tkey status data} {
    set ms [::md::cmd::team_matches $tkey]
    if {$status eq "ok"} { lappend ms {*}$data }
    set m [_pick $ms]
    if {$m eq ""} {
        ::md::cmd::err $ctx narr.nomatch team [::md::teams::label $tkey] hours [::md::cfg narr.ahead_hours 24]
        return
    }
    _go $ctx $target $kind $style $lang $m
}

# live, or starting within narr.ahead_hours
proc ::md::narr::_pick {ms} {
    set now [clock seconds]
    set best ""
    foreach m $ms {
        if {[dict get $m state] eq "in"} { return $m }
        if {[dict get $m state] eq "pre" && [dict get $m start] - $now < [::md::cfg narr.ahead_hours 24] * 3600 && [dict get $m start] - $now > -3 * 3600} {
            if {$best eq "" || [dict get $m start] < [dict get $best start]} { set best $m }
        }
    }
    return $best
}

proc ::md::narr::_go {ctx target kind style lang m} {
    variable S
    if {[llength [sessions $target [dict get $m uid]]]} {
        ::md::cmd::err $ctx narr.already teams [::md::render::teams $m]
        return
    }
    set id [start $target $kind [dict get $ctx nick] $m $style $lang]
    set tz [dict get $ctx tz]
    ::md::reply $ctx [::md::t [dict get $ctx lang] narr.started id $id teams [::md::render::teams $m] \
        style [::md::t [dict get $ctx lang] narr.style.$style] when [::md::render::status_tag [dict get $ctx lang] $m $tz] \
        cmd "[dict get $ctx prefix][::md::i18n::cmdname [dict get $ctx lang] narrate] off"]
}

# ---------------------------------------------------------------- automatic
# Channels can list teams whose matches are always narrated
# (!mdset autonarr add athletic). Sessions start narr.auto_lead seconds
# before kick-off (intro and line-ups) or as soon as a match is found live.
# Each match is started once per channel: "!narrate off" is respected.

proc ::md::narr::auto_tick {} {
    variable S
    set now [clock seconds]
    set lead [::md::cfg narr.auto_lead 3600]
    foreach chan [::md::chan::active] {
        set teams [::md::chan::get $chan autonarr]
        if {![llength $teams]} continue
        foreach tkey $teams {
            foreach m [::md::cmd::team_matches $tkey {pre in}] {
                if {[dict get $m kind] ne "team"} continue
                set uid [dict get $m uid]
                if {[dict get $m state] eq "pre"} {
                    set dt [expr {[dict get $m start] - $now}]
                    if {$dt > $lead || $dt < -3 * 3600} continue
                    if {[dict get $m code] ne "scheduled"} continue
                }
                if {[::md::db_exists narrauto "$chan $uid"]} continue
                if {[llength [sessions $chan $uid]]} continue
                if {[llength [sessions $chan]] >= [::md::chan::get $chan maxnarr]} continue
                if {[array size S] >= [::md::cfg narr.max_total 12]} return
                ::md::db_set narrauto "$chan $uid" $now
                _auto_start $chan $m
            }
        }
    }
}

proc ::md::narr::_auto_start {chan m} {
    set lang [::md::chan::lang $chan]
    set style [::md::chan::get $chan narrstyle]
    set id [start $chan chan auto $m $style $lang]
    ::md::log info "auto narration #$id in $chan: [::md::render::teams $m]"
    set cmd "[::md::chan::get $chan prefix][::md::i18n::cmdname $lang narrate] off"
    ::md::out::send $chan [::md::t $lang narr.started id $id teams [::md::render::teams $m] \
        style [::md::t $lang narr.style.$style] \
        when [::md::render::status_tag $lang $m [::md::chan::get $chan tz]] cmd $cmd]
}

proc ::md::narr::auto_gc {} {
    if {![info exists ::md::db(narrauto)]} return
    set cut [expr {[clock seconds] - 3 * 86400}]
    dict for {k ts} $::md::db(narrauto) {
        if {$ts < $cut} { ::md::db_unset narrauto $k }
    }
}

proc ::md::narr::init {} {
    restore
    ::md::store::load narrauto
    ::md::every narr.auto 60000 ::md::narr::auto_tick
    ::md::every narr.autogc 21600000 ::md::narr::auto_gc
    ::md::timer narr.autofirst 20000 ::md::narr::auto_tick
}

proc ::md::narr::shutdown {} {
    variable S
    save
    foreach id [array names S] { ::md::cancel narr.$id }
}

namespace eval ::md::cmd {
    def narrate narr ::md::narr::c_narrate
}
