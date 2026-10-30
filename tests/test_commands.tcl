# Command tests against recorded real ESPN payloads (offline fixtures).
source [file join [file dirname [info script]] testlib.tcl]
set F [file join $::T(dir) fixtures]
fconfigure stdout -encoding utf-8

::md::http::fixture "*/soccer/esp.1/scoreboard*"           [list file $F/soccer_board.json]
::md::http::fixture "*/soccer/uefa.champions/scoreboard*"  [list file $F/soccer_board.json]
::md::http::fixture "*/apis/v2/sports/soccer/esp.1/standings*" [list file $F/esp1_standings.json]
::md::http::fixture "*/soccer/esp.1/statistics*"           [list file $F/esp1_stats.json]
::md::http::fixture "*/soccer/all/teams/86/schedule?fixture=true" [list file $F/rm_fixtures.json]
::md::http::fixture "*/soccer/all/teams/86/schedule"       [list file $F/rm_results.json]
::md::http::fixture "*/search/v2*"                         [list file $F/search_sevilla.json]
::md::http::fixture "*summary?event=401915413*"            [list file $F/ucl_summary.json]
::md::http::fixture "*/basketball/nba/scoreboard*"         [list file $F/nba_board.json]

::md::chan::put #futbol leagues {esp.1 uefa.champions}
::md::cfgset cmd.flood_count 1000
# let the poller learn today's board (teams index + snapshots)
::md::poll::_got uefa.champions ok [::md::espn::norm_events uefa.champions [::md::json::parse [::md::readfile $F/soccer_board.json]]]
::md::teams::learn soccer 86 "Real Madrid" "Real Madrid" RMA esp.1
::stub::take

proc say {nick chan text {ms 300}} {
    if {$chan eq ""} { ::sim::msg $nick $text } else { ::sim::pub $nick $chan $text }
    ::sim::run $ms
    ::stub::texts
}
proc any {lines pattern} {
    foreach l $lines { if {[string match $pattern $l]} { return 1 } }
    return 0
}
proc show {lines} { if {[info exists ::env(VERBOSE)]} { foreach l $lines { puts "    | $l" } } }

set o [say Bob #futbol "!table laliga"]; show $o
check cmd.table { any $o "*LALIGA*1.Barcelona 24*" }
set o [say Bob #futbol "!clasificacion real madrid"]; show $o
check cmd.table_team { any $o "*Real Madrid*" }
set o [say Bob #futbol "!table laliga full"]; show $o
check cmd.table_full_priv { any $o "*Sent you the details privately*" }

set o [say Bob #futbol "!scorers laliga"]; show $o
check cmd.scorers { any $o "*LALIGA top scorers:*1.Raphinha*12*" }

set o [say Bob #futbol "!next real madrid"]; show $o
check cmd.next { any $o "*Real Madrid:*Roma*Real Madrid*" }
set o [say Bob #futbol "!last real madrid"]; show $o
check cmd.last { any $o "*Real Madrid (*" }

set o [say Bob #futbol "!match inter"]; show $o
check cmd.match_score { any $o "*Inter Milan*3-4*Club Brugge*" }
check cmd.match_scorers { any $o "*Lautaro*" }
check cmd.match_stats { any $o "*Poss 53%-47%*" }

set o [say Bob #futbol "!lineup inter"]; show $o
check cmd.lineup { any $o "*Inter Milan (3-5-2):*" }
set o [say Bob #futbol "!stats inter"]; show $o
check cmd.stats { any $o "*Shots(on)*" }

# the recorded board is from 13 Oct 2026: ask for that day explicitly
set o [say Bob #futbol "!today ucl 2026-10-13"]; show $o
check cmd.today { any $o "*Champions League*" }

set o [say Bob #futbol "!h2h real madrid vs sevilla"]; show $o
check cmd.h2h_reply { expr {[llength $o] >= 1} }

set o [say Bob #futbol "!leagues"]; show $o
check cmd.leagues { any $o "*Competitions:*Football*" }
set o [say Bob #futbol "!leagues spain"]; show $o
check cmd.leagues_search { any $o "*LALIGA (esp.1)*" }

# --- personal
set o [say Bob "" "follow real madrid"]; show $o
check cmd.follow { any $o "*Following Real Madrid*" }
set o [say Bob "" "follows"]; show $o
check cmd.follows { any $o "*1.Real Madrid (team)*" }
set o [say Bob "" "follow league laliga"]; show $o
check cmd.follow_league { any $o "*Following LALIGA*" }
set o [say Bob "" "set lang es"]; show $o
check cmd.setlang { any $o "*lang* = es*" }
set o [say Bob "" "siguiendo"]; show $o
check cmd.follows_es { any $o "*Sigues a*" }
set o [say Bob "" "ajustar tz America/Mexico_City"]; show $o
check cmd.settz { any $o "*tz* = America/Mexico_City*" }
set o [say Bob "" "ajustar tz Mars/Olympus"]; show $o
check cmd.badtz { any $o "*Zona horaria desconocida*" }
set o [say Bob "" "dejar 1"]; show $o
check cmd.unfollow { any $o "*Has dejado de seguir a Real Madrid*" }
set o [say Bob "" "ajustar events -cards +reminders"]; show $o
check cmd.events { any $o "*events* = *reminders*" }

# --- channel config (op only)
set o [say Bob #futbol "!mdset lang es"]; show $o
check cmd.mdset_perm { any $o "*permission*" }
set o [say Alice #futbol "!mdset leagues add premier, bundesliga"]; show $o
check cmd.mdset_leagues { any $o "*leagues* = *Premier League (eng.1)*Bundesliga (ger.1)*" }
set o [say Alice #futbol "!mdset lang es"]; show $o
check cmd.mdset_lang { any $o "*lang* = es*" }
set o [say Alice #futbol "!ayuda"]; show $o
check cmd.help_es { any $o "*Resultados e info*!directo*" }
set o [say Alice #futbol "!mdset"]; show $o
check cmd.mdset_show { any $o "*#futbol ON*leagues=*" }
::md::chan::put #futbol lang en

# --- predictions with a synthetic upcoming match
proc side {id name score} { dict create id $id name $name short $name abbr "" score $score so "" winner false ls {} form "" ha "" order 0 }
proc pm {state code hs as} {
    dict create uid espn:esp.1:777 prov espn lkey esp.1 lname LALIGA sport soccer kind team eid 777 \
        start [expr {[clock seconds] + 3 * 3600}] state $state code $code sname "" detail "" clock "" minute "" period 2 \
        home [side 86 "Real Madrid" $hs] away [side 243 Sevilla $as] events {} round "" venue "" link "" updated [clock seconds] note "" tv {}
}
::md::teams::learn soccer 243 Sevilla Sevilla SEV esp.1
::md::poll::_got esp.1 ok [list [pm pre scheduled "" ""]]
::stub::take
set o [say Bob #futbol "!predict sevilla 1-2"]; show $o
check preds.saved { any $o "*Prediction saved: Real Madrid 2-1 Sevilla*" }
set o [say Carol #futbol "!pronostico real madrid 2-1 sevilla"]; show $o
check preds.saved2 { any $o "*Real Madrid 2-1 Sevilla*" }
set o [say Alice #futbol "!predict real madrid 3-0 sevilla"]; show $o
set o [say Bob #futbol "!preds real madrid"]; show $o
check preds.hidden { any $o "*3 predictions (revealed at kick-off)*" }
set o [say Dave #futbol "!predict real madrid 1-0 boca juniors"]; show $o
check preds.rival_nomatch { any $o "*no match to predict*" }
set o [say Owner #futbol "!porra feature real madrid vs sevilla"]; show $o
check preds.featured { any $o "*featured match: points x2*" }
# kick-off then full time 2-1
::md::poll::_got esp.1 ok [list [pm in live 0 0]]
::md::poll::_got esp.1 ok [list [pm post ft 2 1]]
::sim::run 500
set o [::stub::texts]; show $o
check preds.settle { any $o "*Pool*Real Madrid 2-1 Sevilla*exact (+6): Bob, Carol*right result: Alice (+2)*leader*" }
set o [say Bob #futbol "!ranking"]; show $o
check preds.ranking { any $o "*Pool leaderboard (season):*Bob*6*" }

# --- flood protection
::md::cfgset cmd.flood_count 5
set n 0
for {set i 0} {$i < 10} {incr i} { incr n [llength [say Carol #futbol "!leagues" 20]] }
check flood.limited { expr {$n <= 6} }

# --- partyline admin + input sanitising
::md::cfgset cmd.flood_count 1000
::sim::dcc owner "matchday status"
::sim::run 100
set o [::stub::texts]; show $o
check dcc.status { any $o "*Matchday*up*transport*" }
set o [say Bob #futbol [format "!match %cACTION hax%c" 1 1]]; show $o
check ctcp.stripped { expr {[string first [format %c 1] [join $o]] < 0 && [llength $o] > 0} }
set o [say Bob #futbol "!h2h"]; show $o
check cmd.usage { any $o "*Usage:*!h2h*" }

done
