# Matchday - Deutsch

::md::i18n::lang de German Deutsch

::md::i18n::cmds de {
    help     {hilfe}
    live     {liveticker}
    today    {heute ergebnisse}
    match    {spiel}
    next     {naechste nachste spielplan}
    last     {letzte}
    table    {tabelle}
    scorers  {torschuetzen torschutzen}
    lineup   {aufstellung}
    stats    {statistik}
    form     {formkurve}
    h2h      {direktvergleich bilanz}
    leagues  {ligen wettbewerbe}
    narrate  {kommentar kommentieren}
    follow   {folgen}
    unfollow {entfolgen}
    follows  {gefolgt meineteams}
    prefs    {einstellungen}
    set      {setzen}
    lang     {sprache}
    tz       {zeitzone}
    predict  {tipp tippen}
    preds    {tipps meinetipps}
    porra    {tippspiel}
    ranking  {rangliste}
    more     {mehr}
    about    {ueber}
    mdset    {konfig}
}

::md::i18n::msgs de {
    more.hint        "{c:dim}(%{n} weitere Zeilen: %{cmd}){/c}"
    more.none        "Nichts weiter anzuzeigen."
    word.tomorrow    "Morgen"
    word.referee     "Schiedsrichter"
    form.W "S" form.D "U" form.L "N"
    word.form        "Form"
    word.bench       "Bank"
    days.short       {- Mo Di Mi Do Fr Sa So}

    st.ht "HZ" st.ft "Ende" st.aet "n.V." st.pens "i.E." st.ppd "Verlegt" st.canc "Abges"
    st.aban "Abgebr" st.susp "Unterbr" st.delay "Verspätet" st.shootout "Elfmeterschießen" st.live "LIVE"

    tag.pen     " (E)"
    tag.og      " (ET)"
    tag.assist  "Vorlage: %{name}"

    ctx.poker      "Viererpack von %{player}!"
    ctx.hattrick   "Hattrick von %{player}!"
    ctx.comeback   "Was für eine Aufholjagd!"
    ctx.equaliser  "Ausgleich!"
    ctx.brace      "Doppelpack von %{player}!"
    ctx.latewinner "In letzter Minute!"
    ctx.lead       "Wieder in Führung!"

    period.half    "der %{n}. Halbzeit"
    period.q       "des %{n}. Viertels"
    period.p       "des %{n}. Drittels"
    period.ot      "der Verlängerung %{n}"
    period.inning  "des %{n}. Innings"

    ev.goal        "{s:goal} {c:goal}{b}TOR!{b}{/c} %{score}%{who}%{ctx} %{league}"
    ev.scorer      "{s:goal} Torschütze: %{player} %{min} (%{team}) {c:dim}—{/c} %{score} %{league}"
    ev.disallowed  "{s:var} {c:var}{b}Tor aberkannt{b}{/c} für %{team}! %{score} %{league}"
    ev.card.yellow "{s:yellow} Gelb: %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.card.yred   "{s:yred} {c:red}{b}Gelb-Rot!{b}{/c} %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.card.red    "{s:red} {c:red}{b}ROTE KARTE!{b}{/c} %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.penmiss     "{s:pen} Elfmeter verschossen von %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.kickoff     "{s:start} {c:start}Anpfiff:{/c} %{teams} %{league}"
    ev.start       "{s:start} {c:start}Begonnen:{/c} %{teams} %{league}"
    ev.race_start  "{s:race} {c:start}Gestartet:{/c} %{name} %{league}"
    ev.race_end    "{s:ft} {c:ft}Beendet:{/c} %{name} — {s:trophy} %{podium} %{league}"
    ev.ht          "{s:ht} {c:ht}Halbzeit:{/c} %{score}%{scorers} %{league}"
    ev.2h          "{s:start} Die zweite Halbzeit läuft: %{score} %{league}"
    ev.et          "{s:start} {c:hl}Verlängerung!{/c} %{score} %{league}"
    ev.shootout    "{s:pen} {c:pen}{b}Elfmeterschießen!{b}{/c} %{score} %{league}"
    ev.ft          "{s:ft} {c:ft}Abpfiff:{/c} %{score}%{scorers} %{league}"
    ev.ft.aet      "{s:ft} {c:ft}Abpfiff (nach Verlängerung):{/c} %{score}%{scorers} %{league}"
    ev.ft.pens     "{s:ft} {c:ft}Abpfiff:{/c} %{score} — {b}%{winner}{b} gewinnt %{so} im Elfmeterschießen %{league}"
    ev.ft.duel     "{s:ft} {c:ft}Beendet:{/c} %{score} — Sieg für {b}%{winner}{b} %{league}"
    ev.postponed   "{s:flag} {c:warn}Verlegt:{/c} %{teams} %{league}"
    ev.cancelled   "{s:flag} {c:warn}Abgesagt:{/c} %{teams} %{league}"
    ev.abandoned   "{s:flag} {c:warn}Abgebrochen:{/c} %{score} %{league}"
    ev.suspended   "{s:flag} {c:warn}Unterbrochen:{/c} %{score} %{league}"
    ev.delayed     "{s:flag} {c:warn}Verspätet:{/c} %{teams} %{league}"
    ev.resumed     "{s:start} Fortgesetzt: %{score} %{league}"
    ev.score       "{s:goal} {c:goal}%{label}{/c} %{team}: %{score} {c:dim}(%{detail}){/c} %{league}"
    ev.period_end  "{s:ht} Ende %{period}: %{score} %{league}"
    ev.ot          "{s:clock} {c:hl}Verlängerung!{/c} %{score} %{league}"
    ev.close       "{s:clock} {c:hl}Enges Spiel!{/c} Noch %{left}: %{score} %{league}"
    ev.set         "{s:dot} Satz %{n} an {b}%{player}{b} (%{games}) — %{score} %{league}"
    ev.leader      "{s:race} Neuer Führender in %{name}: {b}%{driver}{b} (vor %{prev}) %{league}"
    ev.reminder    "{s:clock} Beginnt in %{mins} Min: {b}%{teams}{b} (%{time}) %{league}%{tv}"

    score.goal "Tor" score.runs "Run(s) +%{n}" score.try "Versuch" score.penalty "Straftritt" score.points "+%{n}"

    err.perm            "Dafür hast du keine Berechtigung."
    err.internal        "Etwas ist schiefgelaufen. Der Fehler wurde protokolliert."
    err.usage           "Benutzung: {b}%{cmd}{b} %{usage}"
    err.ambiguous       "'%{query}' passt auf mehrere Teams: %{options} — bitte genauer."
    err.team_notfound   "Kein Team namens '%{query}' gefunden."
    err.league_notfound "Unbekannter Wettbewerb: '%{query}'. Versuche !ligen."
    err.nodata          "Dafür gibt es noch keine Daten."
    err.provider        "Der Datenanbieter antwortet gerade nicht. Bitte gleich nochmal."

    live.none       "Gerade keine Live-Spiele."
    live.none_next  "Nichts live. Als Nächstes: %{next}"
    live.team_none  "%{team} spielt gerade nicht. Versuche %{cmd}."
    today.none      "Keine Spiele am %{date} in diesen Wettbewerben."
    team.no_match_day "%{team} spielt an dem Tag nicht."
    team.no_match   "Kein aktuelles oder kommendes Spiel für %{team} gefunden."
    digest.chan     "{s:clock} {b}Die Spiele von heute{b} (%{n}):"
    digest.none     "Deine Tagesübersicht: heute spielt keines deiner Teams/Wettbewerbe."
    digest.header   "{s:clock} {b}Deine Spiele heute{b} (%{n}):"
    missed.header   "{s:dot} Willkommen zurück! Verpasste Ergebnisse (%{n}):"

    stat.possession "Ballbesitz" stat.shots "Schüsse(aufs Tor)" stat.on_target "Aufs Tor" stat.corners "Ecken"
    stat.fouls "Fouls" stat.yellows "Gelb" stat.reds "Rot" stat.offsides "Abseits"
    stat.saves "Paraden" stat.passes "Pässe" stat.pass_pct "Passquote"
    lineup.none     "Die Aufstellungen für %{teams} sind noch nicht da (~1h vorher)."
    stats.notyet    "%{teams} hat noch nicht begonnen."

    next.none   "Keine kommenden Spiele für %{what}."
    last.none   "Keine aktuellen Ergebnisse für %{what}."
    table.none  "Keine Tabelle für %{league} verfügbar."
    table.sent_priv "Ich habe dir die Details privat geschickt."
    table.row   "{c:rank}%{rank}.{/c}%{team} {c:dim}Sp%{gp} S%{w} U%{d} N%{l} TD%{gd}{/c} {b}%{pts}{b}"
    scorers.soccer_only "Torjäger gibt es nur für Fußball."
    scorers.title   "Torjäger %{league}:"
    scorers.assists "Vorlagengeber %{league}:"
    h2h.none   "Keine aktuellen Duelle zwischen %{a} und %{b}."
    h2h.title  "{b}%{a} - %{b}{b} ({c:win}%{w}S{/c} {c:draw}%{d}U{/c} {c:loss}%{l}N{/c}):"

    sport.soccer "Fußball" sport.basketball "Basketball" sport.football "American Football" sport.hockey "Eishockey"
    sport.baseball "Baseball" sport.racing "Motorsport" sport.tennis "Tennis" sport.mma "MMA" sport.golf "Golf"
    sport.rugby "Rugby" sport.australian-football "Australian Football"
    leagues.summary  "Wettbewerbe: %{sports}. Suche mit %{cmd} <Name|Sportart>."

    help.group.info "Ergebnisse & Infos"
    help.group.mine "Persönlich"
    help.group.fun  "Kommentar & Tippspiel"
    help.footer     "Details: %{cmd} <Befehl>. Befehle funktionieren auch privat."
    help.aliases    "Funktioniert auch als"
    help.live     "\[Liga|Sport|Team\] — Live-Spiele"
    help.today    "\[Liga|Sport|Team\] \[Datum\] — Spiele des Tages"
    help.match    "<Team> — aktuelles/letztes Spiel im Detail"
    help.table    "<Liga|Team> \[Gruppe\] \[komplett\] — Tabelle"
    help.narrate  "<Team> \[full|normal|kurz\] | off | liste — Live-Kommentar"
    help.follow   "<Team> | liga <Name> | spieler <Name> — private Benachrichtigungen"
    help.predict  "<Team> <Tore>-<Tore> — dein Tipp (schließt beim Anpfiff)"
    help.ranking  "\[woche|monat|saison|alle\] — Tippspiel-Rangliste"

    narr.stopped    "Kommentar zu %{teams} beendet."
    narr.none       "Hier läuft kein Kommentar."
    narr.limit      "Kommentar-Limit erreicht (%{n})."
    narr.nomatch    "%{team} spielt weder jetzt noch in den nächsten %{hours} Std."
    narr.already    "%{teams} wird hier schon kommentiert."
    narr.started    "{s:mic} Kommentar #%{id}: {b}%{teams}{b} (%{style}, %{when}). Stoppen: %{cmd}"
    narr.style.full "ausführlich" narr.style.normal "normal" narr.style.brief "kurz"
    narr.assist     " {c:dim}(Vorlage: %{name}){/c}"
    narr.lineups_in "{b}Die Aufstellungen sind da!{b}"
    narr.form       "Form — %{home}: %{hf} · %{away}: %{af}"
    narr.poss       "Ballbesitz %{home} %{ph}% – %{pa}% %{away}"
    narr.join_generic "Wir schalten zu %{league}: %{score} {c:dim}(%{detail}){/c}"
    narr.signoff    "{c:dim}Das war's von diesem Spiel. Danke fürs Mitlesen!{/c}"
    replay.banner   "WIEDERHOLUNG x%{speed}: %{teams} (aufgezeichnet, nicht live)"

    preds.noscope   "Welcher Channel? Nutze %{cmd} #channel ... oder: setzen home #channel"
    preds.disabled  "Das Tippspiel ist in diesem Channel deaktiviert."
    preds.nomatch   "%{team} hat in den nächsten %{days} Tagen kein Spiel zum Tippen."
    preds.saved     "{s:win} Tipp gespeichert: %{pred} {c:dim}(%{when}, %{league}){/c}"
    preds.updated   "{s:win} Tipp geändert: %{pred} {c:dim}(%{when}, %{league}){/c}"
    preds.void      "{s:flag} %{teams} findet nicht statt: %{n} %{n:Tipp|Tipps} annulliert."
    preds.exact     "{c:gold}exakt{/c} (+%{pts}): %{names}"
    preds.good      "{c:ok}Tendenz richtig{/c}: %{names}"
    preds.zero      "%{n} daneben"
    preds.leader    "{s:trophy} Spitze: {b}%{nick}{b} %{pts} Pkt"
    preds.settled   "{s:trophy} {b}Tippspiel{b} %{score}:"
    preds.empty     "Noch keine ausgewerteten Tipps. Versuche %{cmd}!"
    preds.you       "du: #%{pos} %{pts} Pkt (%{ex} exakt, %{n} %{n:Tipp|Tipps})"
    preds.ranking   "Tippspiel-Rangliste (%{period}):"
    preds.mine_none "Du hast keine offenen Tipps. Versuche %{cmd} <Team> 2-1"
    preds.mine      "Deine offenen Tipps"
    preds.hidden    "%{teams}: %{n} %{n:Tipp|Tipps} (sichtbar ab Anpfiff)."
    preds.featured  "{c:gold}{s:star}{/c} %{teams} ist das Topspiel: Punkte x%{mult}!"
    preds.open_none "Keine Spiele zum Tippen in den nächsten 48 Std."
    preds.open_header "{s:trophy} {b}Offen für Tipps{b} (%{cmd} <Team> 2-1):"
    period.week "letzte 7 Tage" period.month "letzte 30 Tage" period.season "Saison" period.all "gesamt"

    cfg.needchan  "Welcher Channel? Im Channel benutzen oder #channel angeben."
    follow.ok     "{s:win} Du folgst {b}%{what}{b}. Benachrichtigungen kommen privat; anpassen mit %{cmd}."
    follow.already "Du folgst %{what} bereits."
    follow.limit  "Du kannst bis zu %{n} Dingen folgen."
    unfollow.all  "Du folgst nichts mehr."
    unfollow.notfound "Du folgst nichts, was zu '%{query}' passt."
    unfollow.ok   "Du folgst %{what} nicht mehr."
    follows.none  "Du folgst noch nichts. Versuche %{cmd} <Team>."
    follows.header "Du folgst"
    follows.kind.team "Team" follows.kind.league "Wettbewerb" follows.kind.player "Spieler" follows.kind.match "Spiel"
    prefs.header  "Deine Einstellungen"
    prefs.hint    "Ändern mit %{cmd} <Name> <Wert> (z.B. setzen quiet 23:00-08:00 · setzen tz Europe/Berlin)"
    set.badlang   "Unbekannte Sprache. Verfügbar: %{langs}"
    set.badtz     "Unbekannte Zeitzone. Nutze Region/Stadt, z.B. Europe/Berlin."
    set.badvalue  "Ungültiger Wert für %{key}. Gültig: %{values}"
    set.unknown   "Unbekannte Einstellung '%{key}'. Gültig: %{keys}"
    lang.list     "Sprachen: %{langs}. Nutze %{cmd} <Code>."
    tz.current    "Deine Zeitzone: %{tz} (jetzt %{time})."
}

::md::i18n::vary de {
    narr.intro {
        "{s:mic} Guten Abend! Gleich geht's los: {b}%{teams}{b} in der %{league}, Anpfiff %{time}."
        "{s:mic} Wir sind live dabei bei {b}%{teams}{b} (%{league}), Anstoß um %{time}."
    }
    narr.join { "Wir schalten uns in der {c:minute}%{min}{/c} ein: %{score}%{scorers}" }
    narr.kickoff {
        "{s:start} {c:start}{b}Der Ball rollt!{b}{/c} %{home} gegen %{away} hat begonnen."
        "{s:start} {c:start}{b}Anpfiff!{b}{/c} %{home} - %{away} läuft."
    }
    narr.goal.goal {
        "{s:goal} {c:goal}{b}TOOOR!{b}{/c} {c:minute}%{min}{/c} {b}%{player}{b} trifft für %{team}! %{score}%{assist}"
        "{s:goal} {c:goal}{b}TOR!{b}{/c} %{player} schiebt ein ({c:minute}%{min}{/c}). %{score}%{assist}"
    }
    narr.goal.first { "{s:goal} {c:goal}{b}TOOOR!{b}{/c} %{player} bringt %{team} in Führung ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.equaliser { "{s:goal} {c:goal}{b}TOOOR!{b}{/c} {c:hl}Der Ausgleich!{/c} %{player} trifft für %{team} ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.comeback { "{s:goal} {c:goal}{b}TOOOR!{b}{/c} {c:hl}Das Spiel ist gedreht!{/c} %{player} für %{team} ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.latewinner { "{s:goal} {c:goal}{b}TOOOOR!{b}{/c} {c:hl}In letzter Minute!{/c} %{player}, {c:minute}%{min}{/c}. %{score}%{assist}" }
    narr.goal.brace { "{s:goal} {c:goal}{b}TOOOR!{b}{/c} Schon wieder %{player}! {c:hl}Doppelpack{/c} ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.hattrick { "{s:goal} {c:goal}{b}TOOOR!{b}{/c} {c:hl}{s:star} HATTRICK für %{player}!{/c} ({c:minute}%{min}{/c}) %{score}%{assist}" }
    narr.goal.pen { "{s:goal} {c:goal}{b}TOOOR!{b}{/c} %{player} verwandelt den Elfmeter ({c:minute}%{min}{/c}). %{score}" }
    narr.goal.og { "{s:goal} {c:goal}{b}EIGENTOR!{b}{/c} %{player} trifft ins eigene Netz ({c:minute}%{min}{/c}). %{score}" }
    narr.goal.rout { "{s:goal} {c:goal}{b}TOOOR!{b}{/c} %{player} legt nach — das wird ein Schützenfest ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.consolation { "{s:goal} {c:goal}{b}TOOOR!{b}{/c} %{player} verkürzt für %{team} ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.yellow {
        "{s:yellow} {c:minute}%{min}{/c} Gelb für %{player} (%{team})."
        "{s:yellow} {c:minute}%{min}{/c} %{player} sieht die Gelbe Karte."
    }
    narr.yred { "{s:yred} {c:minute}%{min}{/c} {c:red}{b}Gelb-Rot!{b}{/c} %{player} muss runter, %{team} nur noch zu zehnt." }
    narr.red { "{s:red} {c:minute}%{min}{/c} {c:red}{b}GLATT ROT!{b}{/c} %{player} (%{team}) fliegt vom Platz!" }
    narr.sub { "{s:sub} {c:minute}%{min}{/c} Wechsel bei %{team}: %{pin} kommt für %{pout}." }
    narr.penmiss { "{s:pen} {c:minute}%{min}{/c} {c:hl}VERSCHOSSEN!{/c} %{player} (%{team}) vergibt den Elfmeter!" }
    narr.pensaved { "{s:pen} {c:minute}%{min}{/c} {c:hl}GEHALTEN!{/c} Der Keeper pariert gegen %{player}!" }
    narr.save {
        "{s:chance} {c:minute}%{min}{/c} Chance für %{team}! %{player} zieht ab... %{keeper} hält."
        "{s:chance} {c:minute}%{min}{/c} Starke Parade von %{keeper} gegen %{player}!"
    }
    narr.shot { "{s:chance} {c:minute}%{min}{/c} %{player} (%{team}) prüft den Torwart." }
    narr.woodwork {
        "{s:chance} {c:minute}%{min}{/c} {c:hl}PFOSTEN!{/c} %{player} trifft nur Aluminium!"
        "{s:chance} {c:minute}%{min}{/c} {c:hl}Latte!{/c} So knapp für %{team} — %{player}."
    }
    narr.miss { "{s:chance} {c:minute}%{min}{/c} %{player} versucht's, knapp vorbei." }
    narr.corner { "{c:minute}%{min}{/c} Ecke für %{team}." }
    narr.added { "{s:clock} Nachspielzeit: {b}+%{n}'{b}." }
    narr.ht { "{s:ht} {c:ht}{b}Halbzeit!{b}{/c} %{score}%{scorers}" }
    narr.2h { "{s:start} {c:start}Weiter geht's mit der zweiten Hälfte!{/c} %{score}" }
    narr.end90 { "{s:ht} Die 90 Minuten sind um: %{score}." }
    narr.et { "{s:start} {c:hl}Die Verlängerung beginnt!{/c} %{score}" }
    narr.shootout { "{s:pen} {c:pen}{b}ELFMETERSCHIESSEN!{b}{/c} %{score}" }
    narr.so.scored { "{s:pen} %{player} (%{team}) {c:ok}trifft{/c}." }
    narr.so.missed { "{s:pen} %{player} (%{team}) {c:err}verschießt!{/c}" }
    narr.update { "{c:dim}{s:clock}{/c} {c:minute}%{min}{/c} %{score} {c:dim}%{poss}{/c}" }
    narr.pressure { "{s:chance} %{team} macht Druck: %{n} Schüsse in fünf Minuten!" }
    narr.tension.draw { "{s:clock} Schlussphase und alles offen: %{score}." }
    narr.tension.close { "{s:clock} Schlussphase: %{team} verteidigt die knappe Führung. %{score}" }
    narr.var { "{s:var} {c:minute}%{min}{/c} {c:var}VAR-Check...{/c} %{text}" }
    narr.delay { "{c:minute}%{min}{/c} Das Spiel ist unterbrochen." }
    narr.ft.win {
        "{s:ft} {c:ft}{b}ABPFIFF!{b}{/c} %{score} — Sieg für {b}%{winner}{b}!"
        "{s:ft} {c:ft}{b}Aus und vorbei!{b}{/c} %{winner} holt die drei Punkte. %{score}"
    }
    narr.ft.draw { "{s:ft} {c:ft}{b}ABPFIFF!{b}{/c} Unentschieden: %{score}." }
    narr.ft.pens { "{s:ft} {c:ft}{b}ES IST VORBEI!{b}{/c} %{score} — {b}%{winner}{b} gewinnt %{so} im Elfmeterschießen!" }
}

# --- players, probabilities, hot matches, videos
::md::i18n::cmds de { player {spieler} prob {wahrscheinlichkeit quoten} }

::md::i18n::msgs de {
    player.notfound    "Kein Spieler für '%{query}' gefunden."
    player.age         "%{n} Jahre"
    player.goals       "%{n} %{n:Tor|Tore}"
    player.assists     "%{n} %{n:Vorlage|Vorlagen}"
    player.starts      "%{n} Startelf"
    player.shots       "%{n} %{n:Schuss|Schüsse} (%{s} aufs Tor)"
    player.cleansheets "%{n} %{n:Spiel|Spiele} ohne Gegentor"
    player.last        "Letzte %{n}: %{goals} T, %{assists} V"
    player.next        "Nächstes: %{name} (%{when}, %{league})"
    player.also        "Auch: %{list}"
    prob.draw          "Remis"
    prob.model         "Siegwahrscheinlichkeit"
    prob.odds          "Quoten vor dem Spiel"
    prob.espn          "Siegwahrscheinlichkeit (ESPN)"
    prob.prior         "Siegwahrscheinlichkeit (ohne Quoten)"
    prob.none          "Keine Wahrscheinlichkeit für %{teams} verfügbar."
    hot.flurry         "{s:hot} {c:hl}{b}Heißes Spiel!{b}{/c} %{n} Tore in %{mins} Minuten: %{score} {c:minute}%{min}{/c} %{league}"
    hot.goalfest       "{s:hot} {c:hl}{b}Torfestival!{b}{/c} schon %{n} Tore: %{score} {c:minute}%{min}{/c} %{league}"
    hot.comeback       "{s:hot} {c:hl}{b}Aufholjagd läuft!{b}{/c} %{team} lag mit zwei Toren hinten: %{score} {c:minute}%{min}{/c} %{league}"
    hot.upset          "{s:hot} {c:hl}{b}Überraschung bahnt sich an!{b}{/c} %{team} (%{pct}% vor dem Spiel) führt: %{score} {c:minute}%{min}{/c} %{league}"
    hot.shock          "{s:hot} {c:hl}{b}Sensation!{b}{/c} %{team} (%{pct}% vor dem Spiel) gewinnt: %{score} %{league}"
    ev.video           "{s:tv} {c:info}Video:{/c} %{teams} {c:dim}—{/c} %{headline}%{dur} %{url}"
    help.player        "<Name> — Spielerprofil und Saisonstatistik"
    help.prob          "<Team> — Siegwahrscheinlichkeit"
}
