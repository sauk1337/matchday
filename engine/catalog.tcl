# Matchday - engine/catalog.tcl
# Known competitions: key -> sport, ESPN path, display name, aliases and
# provider hints (API-Football league id, season style). Unknown ESPN
# league slugs ("soccer/por.2", "rugby/180659") are accepted dynamically.

namespace eval ::md::catalog {
    variable L       ;# key -> dict
    variable order {}
    array set L {}
}

# add key sport path name aliases ?opt value ...?
#   af <id>        API-Football league id
#   season cross|calendar  (European style 2026-27 vs calendar year)
#   tier 1|2|3     1 = indexed by default for team search
#   women 0|1
proc ::md::catalog::add {key sport path name aliases args} {
    variable L
    variable order
    set norm {}
    foreach a [concat [list $key $name] $aliases] { lappend norm [::md::norm $a] }
    set L($key) [dict merge [dict create key $key sport $sport path $path name $name \
        aliases $aliases norm [::md::luniq $norm] af "" season cross tier 3 women 0 dynamic 0] $args]
    if {$key ni $order} { lappend order $key }
}

proc ::md::catalog::exists {key} {
    variable L
    info exists L($key)
}

proc ::md::catalog::get {key {field ""}} {
    variable L
    if {![info exists L($key)]} {
        if {![dynamic $key]} { return "" }
    }
    if {$field eq ""} { return $L($key) }
    ::md::dg $L($key) "" $field
}

proc ::md::catalog::keys {{sport ""}} {
    variable L
    variable order
    set out {}
    foreach k $order {
        if {$sport eq "" || [dict get $L($k) sport] eq $sport} { lappend out $k }
    }
    return $out
}

proc ::md::catalog::sports {} {
    variable L
    variable order
    set s {}
    foreach k $order { lappend s [dict get $L($k) sport] }
    ::md::luniq $s
}

# Accept "sport/slug" paths and bare ESPN soccer slugs (por.2, eng.w.1)
# for competitions not in the built-in table.
proc ::md::catalog::dynamic {key} {
    variable L
    set k [string tolower $key]
    if {[regexp {^([a-z-]+)/([a-z0-9._-]+)$} $k -> sport slug]} {
        # existing entry with this path?
        foreach e [array names L] {
            if {[dict get $L($e) path] eq $k} { return 0 }
        }
        if {$sport ni {soccer basketball football hockey baseball racing tennis mma golf rugby australian-football lacrosse volleyball}} { return 0 }
        add $k $sport $k [string toupper $slug] {} dynamic 1
        return 1
    }
    if {[regexp {^[a-z]{3}(\.[a-z0-9_]+)+$} $k]} {
        add $k soccer soccer/$k [string toupper $k] {} dynamic 1
        return 1
    }
    return 0
}

# Resolve user input to a catalog key ("" if unknown)
proc ::md::catalog::find {query} {
    variable L
    set q [string trim $query]
    if {$q eq ""} { return "" }
    if {[info exists L($q)]} { return $q }
    set lq [string tolower $q]
    if {[info exists L($lq)]} { return $lq }
    foreach k [array names L] {
        if {[dict get $L($k) path] eq $lq} { return $k }
    }
    set n [::md::norm $q]
    set best ""
    set bestscore 0
    foreach k [keys] {
        set s [::md::mscore $n [dict get $L($k) norm]]
        # prefer higher tiers on ties
        set s [expr {$s * 10 + (4 - [dict get $L($k) tier])}]
        if {$s > $bestscore} { set bestscore $s; set best $k }
    }
    if {$bestscore >= 700} { return $best }
    if {[dynamic $lq]} { return $lq }
    return ""
}

# Exact key/name/alias match only ("" otherwise)
proc ::md::catalog::exact {query} {
    variable L
    set lq [string tolower [string trim $query]]
    if {[info exists L($lq)]} { return $lq }
    set n [::md::norm $query]
    foreach k [keys] {
        if {$n in [dict get $L($k) norm]} { return $k }
    }
    return ""
}

# Search: list of keys matching (for !leagues <text>)
proc ::md::catalog::search {query {limit 15}} {
    variable L
    set n [::md::norm $query]
    set res {}
    foreach k [keys] {
        set s [::md::mscore $n [dict get $L($k) norm]]
        if {$s == 0 && [string first $n [::md::norm [dict get $L($k) sport]]] == 0} { set s 50 }
        if {$s >= 50} { lappend res [list $s $k] }
    }
    set out {}
    foreach r [lrange [lsort -integer -decreasing -index 0 $res] 0 [expr {$limit - 1}]] { lappend out [lindex $r 1] }
    return $out
}

proc ::md::catalog::label {key} {
    set n [get $key name]
    if {$n eq ""} { return $key }
    return $n
}

# kind of competition by sport: team | duel | race
proc ::md::catalog::kind {sport} {
    switch -- $sport {
        tennis - mma { return duel }
        racing - golf { return race }
        default { return team }
    }
}

# Current season number for API-Football style providers
proc ::md::catalog::season {key {epoch ""}} {
    if {$epoch eq ""} { set epoch [clock seconds] }
    set y [clock format $epoch -format %Y -timezone :UTC]
    set m [scan [clock format $epoch -format %m -timezone :UTC] %d]
    if {[get $key season] eq "calendar"} { return $y }
    expr {$m >= 7 ? $y : $y - 1}
}

# ----------------------------------------------------------------- data
namespace eval ::md::catalog {
    # --- Soccer: Europe top flight
    add esp.1  soccer soccer/esp.1  "LALIGA" {"la liga" liga spain espana "primera division" primera} af 140 tier 1
    add eng.1  soccer soccer/eng.1  "Premier League" {premier epl england inglaterra "premier league" pl} af 39 tier 1
    add ita.1  soccer soccer/ita.1  "Serie A" {seriea "serie a" italy italia calcio} af 135 tier 1
    add ger.1  soccer soccer/ger.1  "Bundesliga" {bundesliga germany alemania deutschland buli} af 78 tier 1
    add fra.1  soccer soccer/fra.1  "Ligue 1" {ligue1 "ligue 1" france francia} af 61 tier 1
    add por.1  soccer soccer/por.1  "Liga Portugal" {portugal "primeira liga" "liga portugal"} af 94 tier 1
    add ned.1  soccer soccer/ned.1  "Eredivisie" {eredivisie netherlands holanda holland} af 88 tier 1
    add bel.1  soccer soccer/bel.1  "Belgian Pro League" {belgium belgica jupiler "pro league"} af 144 tier 2
    add tur.1  soccer soccer/tur.1  "Süper Lig" {turkey turquia "super lig" superlig} af 203 tier 2
    add sco.1  soccer soccer/sco.1  "Scottish Premiership" {scotland escocia spfl premiership} af 179 tier 2
    add gre.1  soccer soccer/gre.1  "Greek Super League" {greece grecia} af 197 tier 3
    add aut.1  soccer soccer/aut.1  "Austrian Bundesliga" {austria} af 218 tier 3
    add den.1  soccer soccer/den.1  "Danish Superliga" {denmark dinamarca superliga} af 119 tier 3
    add nor.1  soccer soccer/nor.1  "Eliteserien" {norway noruega eliteserien} af 103 season calendar tier 3
    add swe.1  soccer soccer/swe.1  "Allsvenskan" {sweden suecia allsvenskan} af 113 season calendar tier 3
    add rus.1  soccer soccer/rus.1  "Russian Premier League" {russia rusia rpl} af 235 tier 3
    # --- Europe second tiers
    add esp.2  soccer soccer/esp.2  "LALIGA 2" {segunda "la liga 2" laliga2 hypermotion "segunda division"} af 141 tier 2
    add eng.2  soccer soccer/eng.2  "EFL Championship" {championship efl} af 40 tier 2
    add eng.3  soccer soccer/eng.3  "EFL League One" {"league one"} af 41 tier 3
    add eng.4  soccer soccer/eng.4  "EFL League Two" {"league two"} af 42 tier 3
    add ita.2  soccer soccer/ita.2  "Serie B" {serieb "serie b"} af 136 tier 3
    add ger.2  soccer soccer/ger.2  "2. Bundesliga" {"2 bundesliga" bundesliga2} af 79 tier 3
    add fra.2  soccer soccer/fra.2  "Ligue 2" {ligue2} af 62 tier 3
    # --- Domestic cups
    add esp.copa_del_rey     soccer soccer/esp.copa_del_rey     "Copa del Rey" {copa "copa del rey" copadelrey} af 143 tier 2
    add esp.super_cup        soccer soccer/esp.super_cup        "Supercopa de España" {supercopa "supercopa espana"} af 556 tier 3
    add eng.fa               soccer soccer/eng.fa               "FA Cup" {"fa cup" facup} af 45 tier 2
    add eng.league_cup       soccer soccer/eng.league_cup       "Carabao Cup" {carabao "league cup" "efl cup"} af 48 tier 2
    add ita.coppa_italia     soccer soccer/ita.coppa_italia     "Coppa Italia" {coppa "coppa italia"} af 137 tier 2
    add ger.dfb_pokal        soccer soccer/ger.dfb_pokal        "DFB-Pokal" {pokal "dfb pokal" "german cup"} af 81 tier 2
    add fra.coupe_de_france  soccer soccer/fra.coupe_de_france  "Coupe de France" {"coupe de france"} af 66 tier 3
    add por.taca.portugal    soccer soccer/por.taca.portugal    "Taça de Portugal" {taca "taca de portugal"} af 96 tier 3
    add ned.cup              soccer soccer/ned.cup              "KNVB Beker" {knvb beker} af 90 tier 3
    # --- UEFA
    add uefa.champions       soccer soccer/uefa.champions       "Champions League" {ucl champions "champions league" "liga de campeones" uefa cl} af 2 tier 1
    add uefa.europa          soccer soccer/uefa.europa          "Europa League" {uel europa "europa league"} af 3 tier 1
    add uefa.europa.conf     soccer soccer/uefa.europa.conf     "Conference League" {uecl conference "conference league"} af 848 tier 1
    add uefa.super_cup       soccer soccer/uefa.super_cup       "UEFA Super Cup" {"super cup" supercup} af 531 tier 3
    add uefa.nations         soccer soccer/uefa.nations         "UEFA Nations League" {"nations league" nations} af 5 tier 2
    add uefa.euro            soccer soccer/uefa.euro            "EURO" {euro eurocopa "european championship"} af 4 tier 2
    add uefa.euroq           soccer soccer/uefa.euroq           "EURO Qualifying" {"euro qualifying" "clasificacion euro"} af 960 tier 3
    add uefa.champions_qual  soccer soccer/uefa.champions_qual  "UCL Qualifying" {"ucl qualifying" "previa champions"} tier 3
    add uefa.wchampions      soccer soccer/uefa.wchampions      "Women's Champions League" {uwcl "champions femenina"} women 1 tier 3
    # --- FIFA / national teams
    add fifa.world           soccer soccer/fifa.world           "FIFA World Cup" {"world cup" mundial wc copa "copa del mundo"} af 1 season calendar tier 1
    add fifa.wwc             soccer soccer/fifa.wwc             "Women's World Cup" {"mundial femenino" wwc} women 1 season calendar tier 3
    add fifa.cwc             soccer soccer/fifa.cwc             "FIFA Club World Cup" {"club world cup" "mundial de clubes" cwc} af 15 season calendar tier 2
    add fifa.friendly        soccer soccer/fifa.friendly        "International Friendlies" {friendlies amistosos friendly amistoso} af 10 season calendar tier 2
    add fifa.worldq.uefa     soccer soccer/fifa.worldq.uefa     "WC Qualifying UEFA" {"wcq uefa" "eliminatorias uefa"} af 32 season calendar tier 2
    add fifa.worldq.conmebol soccer soccer/fifa.worldq.conmebol "WC Qualifying CONMEBOL" {eliminatorias "eliminatorias sudamericanas" "wcq conmebol"} af 34 season calendar tier 2
    add fifa.worldq.concacaf soccer soccer/fifa.worldq.concacaf "WC Qualifying CONCACAF" {"wcq concacaf" octagonal} af 31 season calendar tier 3
    add fifa.worldq.afc      soccer soccer/fifa.worldq.afc      "WC Qualifying AFC" {"wcq afc"} af 30 season calendar tier 3
    add fifa.worldq.caf      soccer soccer/fifa.worldq.caf      "WC Qualifying CAF" {"wcq caf"} af 29 season calendar tier 3
    add fifa.wcq.ply         soccer soccer/fifa.wcq.ply         "WC Qualifying Playoffs" {"wcq playoff" repesca} season calendar tier 3
    add conmebol.america     soccer soccer/conmebol.america     "Copa América" {"copa america" america} af 9 season calendar tier 2
    add caf.nations          soccer soccer/caf.nations          "Africa Cup of Nations" {afcon can "copa africa"} af 6 season calendar tier 3
    add afc.asian.cup        soccer soccer/afc.asian.cup        "AFC Asian Cup" {"asian cup" "copa asia"} af 7 season calendar tier 3
    add concacaf.gold        soccer soccer/concacaf.gold        "Gold Cup" {"gold cup" "copa oro"} af 22 season calendar tier 3
    add concacaf.nations.league soccer soccer/concacaf.nations.league "CONCACAF Nations League" {"concacaf nations"} af 536 tier 3
    # --- Americas clubs
    add conmebol.libertadores soccer soccer/conmebol.libertadores "Copa Libertadores" {libertadores "copa libertadores" liberta} af 13 season calendar tier 1
    add conmebol.sudamericana soccer soccer/conmebol.sudamericana "Copa Sudamericana" {sudamericana "copa sudamericana"} af 11 season calendar tier 2
    add conmebol.recopa      soccer soccer/conmebol.recopa      "Recopa Sudamericana" {recopa} af 541 season calendar tier 3
    add concacaf.champions   soccer soccer/concacaf.champions   "CONCACAF Champions Cup" {"concachampions" "concacaf champions"} af 16 season calendar tier 3
    add concacaf.leagues.cup soccer soccer/concacaf.leagues.cup "Leagues Cup" {"leagues cup"} af 772 season calendar tier 3
    add usa.1                soccer soccer/usa.1                "MLS" {mls usa "major league soccer"} af 253 season calendar tier 1
    add usa.nwsl             soccer soccer/usa.nwsl             "NWSL" {nwsl} af 254 season calendar women 1 tier 3
    add mex.1                soccer soccer/mex.1                "Liga MX" {ligamx "liga mx" mexico} af 262 tier 1
    add bra.1                soccer soccer/bra.1                "Brasileirão" {brasileirao brazil brasil "serie a brasil"} af 71 season calendar tier 1
    add bra.2                soccer soccer/bra.2                "Brasileirão Série B" {"serie b brasil"} af 72 season calendar tier 3
    add bra.copa_do_brazil   soccer soccer/bra.copa_do_brazil   "Copa do Brasil" {"copa do brasil"} af 73 season calendar tier 3
    add arg.1                soccer soccer/arg.1                "Liga Profesional Argentina" {argentina lpf "liga argentina" "primera argentina"} af 128 season calendar tier 1
    add arg.copa             soccer soccer/arg.copa             "Copa Argentina" {"copa argentina"} af 130 season calendar tier 3
    add col.1                soccer soccer/col.1                "Liga BetPlay" {colombia betplay "primera a"} af 239 season calendar tier 2
    add chi.1                soccer soccer/chi.1                "Primera División Chile" {chile} af 265 season calendar tier 2
    add uru.1                soccer soccer/uru.1                "Liga AUF Uruguaya" {uruguay} af 268 season calendar tier 2
    add per.1                soccer soccer/per.1                "Liga 1 Perú" {peru} af 281 season calendar tier 2
    add ecu.1                soccer soccer/ecu.1                "LigaPro Ecuador" {ecuador ligapro} af 242 season calendar tier 2
    add par.1                soccer soccer/par.1                "Primera División Paraguay" {paraguay} af 250 season calendar tier 3
    add ven.1                soccer soccer/ven.1                "Liga FUTVE" {venezuela futve} af 299 season calendar tier 3
    add bol.1                soccer soccer/bol.1                "División Profesional Bolivia" {bolivia} af 344 season calendar tier 3
    add crc.1                soccer soccer/crc.1                "Liga FPD Costa Rica" {"costa rica"} af 162 tier 3
    add hon.1                soccer soccer/hon.1                "Liga Nacional Honduras" {honduras} af 234 tier 3
    add gua.1                soccer soccer/gua.1                "Liga Nacional Guatemala" {guatemala} af 339 tier 3
    add slv.1                soccer soccer/slv.1                "Primera División El Salvador" {"el salvador" salvador} af 370 tier 3
    # --- Rest of world
    add ksa.1                soccer soccer/ksa.1                "Saudi Pro League" {saudi "roshn" arabia} af 307 tier 2
    add jpn.1                soccer soccer/jpn.1                "J1 League" {japan japon jleague j1} af 98 season calendar tier 3
    add chn.1                soccer soccer/chn.1                "Chinese Super League" {china csl} af 169 season calendar tier 3
    add aus.1                soccer soccer/aus.1                "A-League" {australia aleague "a league"} af 188 tier 3
    add ind.1                soccer soccer/ind.1                "Indian Super League" {india isl} af 323 tier 3
    add rsa.1                soccer soccer/rsa.1                "South African Premiership" {"south africa" sudafrica psl} af 288 tier 3
    add afc.champions        soccer soccer/afc.champions        "AFC Champions League Elite" {"afc champions" acl} af 17 tier 3
    add caf.champions        soccer soccer/caf.champions        "CAF Champions League" {"caf champions"} af 12 tier 3
    # --- Women
    add esp.w.1              soccer soccer/esp.w.1              "Liga F" {"liga f" ligaf "liga femenina" "primera femenina"} af 142 women 1 tier 3
    add eng.w.1              soccer soccer/eng.w.1              "Women's Super League" {wsl "womens super league"} af 44 women 1 tier 3

    # --- Basketball
    add nba     basketball basketball/nba                     "NBA" {nba baloncesto basket basketball} season cross tier 1
    add wnba    basketball basketball/wnba                    "WNBA" {wnba} season calendar tier 2
    add ncaab   basketball basketball/mens-college-basketball "NCAA Basketball" {ncaab "college basketball" "march madness" ncaam} tier 2
    add ncaaw   basketball basketball/womens-college-basketball "NCAA Women's Basketball" {ncaaw "womens college basketball"} tier 3
    add fiba    basketball basketball/fiba                    "FIBA World Cup" {fiba "mundial baloncesto" "basketball world cup"} season calendar tier 3
    # --- American football
    add nfl     football football/nfl                         "NFL" {nfl "american football" "futbol americano" superbowl "super bowl"} tier 1
    add ncaaf   football football/college-football            "College Football" {ncaaf "college football" cfb} tier 2
    # --- Hockey / baseball
    add nhl     hockey hockey/nhl                             "NHL" {nhl hockey "ice hockey" "hockey hielo"} tier 1
    add mlb     baseball baseball/mlb                         "MLB" {mlb baseball beisbol "world series"} season calendar tier 1
    # --- Motorsport
    add f1      racing racing/f1                              "Formula 1" {f1 "formula 1" formula1 "formula one" "formula uno" gp} season calendar tier 1
    add indycar racing racing/irl                             "IndyCar" {indycar indy irl} season calendar tier 3
    add nascar  racing racing/nascar-premier                  "NASCAR Cup" {nascar} season calendar tier 3
    # --- Tennis
    add atp     tennis tennis/atp                             "ATP" {atp tenis tennis "tenis masculino"} season calendar tier 1
    add wta     tennis tennis/wta                             "WTA" {wta "tenis femenino"} season calendar tier 2
    # --- Combat
    add ufc     mma mma/ufc                                   "UFC" {ufc mma} season calendar tier 2
    # --- Golf
    add pga     golf golf/pga                                 "PGA Tour" {pga golf "pga tour"} season calendar tier 2
    add lpga    golf golf/lpga                                "LPGA" {lpga} season calendar tier 3
    # --- Rugby / Aussie rules
    add rugby.wc  rugby rugby/164205                          "Rugby World Cup" {"rugby world cup" "mundial rugby" rwc} season calendar tier 2
    add six.nations rugby rugby/180659                        "Six Nations" {"six nations" "seis naciones" "6 nations" 6n} season calendar tier 2
    add rugby.prem rugby rugby/267979                         "Premiership Rugby" {"premiership rugby" "gallagher prem"} tier 3
    add urc     rugby rugby/270557                            "United Rugby Championship" {urc "united rugby"} tier 3
    add afl     australian-football australian-football/afl  "AFL" {afl "aussie rules"} season calendar tier 3
}
