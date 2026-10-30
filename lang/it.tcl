# Matchday - Italiano

::md::i18n::lang it Italian Italiano

::md::i18n::cmds it {
    help     {aiuto}
    live     {diretta}
    today    {oggi risultati}
    match    {partita}
    next     {prossime prossima calendario}
    last     {ultime}
    table    {classifica}
    scorers  {marcatori capocannonieri}
    lineup   {formazione formazioni}
    stats    {statistiche}
    form     {forma}
    h2h      {precedenti}
    leagues  {campionati}
    narrate  {cronaca radiocronaca}
    follow   {segui}
    unfollow {smetti}
    follows  {seguiti}
    prefs    {preferenze}
    set      {imposta}
    lang     {lingua}
    tz       {fuso}
    predict  {pronostico}
    preds    {pronostici}
    porra    {schedina}
    ranking  {classificaschedina}
    more     {altro}
    about    {info}
    mdset    {configura}
}

::md::i18n::msgs it {
    more.hint        "{c:dim}(altre %{n} righe: %{cmd}){/c}"
    more.none        "Nient'altro da mostrare."
    word.tomorrow    "Domani"
    word.referee     "Arbitro"
    form.W "V" form.D "N" form.L "P"
    word.form        "Forma"
    word.bench       "Panchina"
    days.short       {- Lun Mar Mer Gio Ven Sab Dom}

    st.ht "Int" st.ft "Fine" st.aet "Dts" st.pens "Rig" st.ppd "Rinv" st.canc "Ann"
    st.aban "Sosp" st.susp "Sosp" st.delay "Ritardo" st.shootout "Rigori" st.live "LIVE"

    tag.pen     " (rig)"
    tag.og      " (aut)"
    tag.assist  "assist: %{name}"

    ctx.poker      "Poker di %{player}!"
    ctx.hattrick   "Tripletta di %{player}!"
    ctx.comeback   "Che rimonta!"
    ctx.equaliser  "Pareggio!"
    ctx.brace      "Doppietta di %{player}!"
    ctx.latewinner "Al fotofinish!"
    ctx.lead       "Di nuovo avanti!"

    period.half    "%{n}° tempo"
    period.q       "%{n}° quarto"
    period.p       "%{n}° periodo"
    period.ot      "supplementare %{n}"
    period.inning  "%{n}° inning"

    ev.goal        "{s:goal} {c:goal}{b}GOL!{b}{/c} %{score}%{who}%{ctx} %{league}"
    ev.scorer      "{s:goal} Marcatore: %{player} %{min} (%{team}) {c:dim}—{/c} %{score} %{league}"
    ev.disallowed  "{s:var} {c:var}{b}Gol annullato{b}{/c} al %{team}! %{score} %{league}"
    ev.card.yellow "{s:yellow} Ammonito: %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.card.yred   "{s:yred} {c:red}{b}Espulso!{b}{/c} Secondo giallo per %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.card.red    "{s:red} {c:red}{b}ROSSO DIRETTO!{b}{/c} %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.penmiss     "{s:pen} Rigore sbagliato da %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.kickoff     "{s:start} {c:start}Calcio d'inizio:{/c} %{teams} %{league}"
    ev.start       "{s:start} {c:start}Iniziata:{/c} %{teams} %{league}"
    ev.race_start  "{s:race} {c:start}Partiti:{/c} %{name} %{league}"
    ev.race_end    "{s:ft} {c:ft}Finita:{/c} %{name} — {s:trophy} %{podium} %{league}"
    ev.ht          "{s:ht} {c:ht}Intervallo:{/c} %{score}%{scorers} %{league}"
    ev.2h          "{s:start} Inizia il secondo tempo: %{score} %{league}"
    ev.et          "{s:start} {c:hl}Supplementari!{/c} %{score} %{league}"
    ev.shootout    "{s:pen} {c:pen}{b}Calci di rigore!{b}{/c} %{score} %{league}"
    ev.ft          "{s:ft} {c:ft}Finale:{/c} %{score}%{scorers} %{league}"
    ev.ft.aet      "{s:ft} {c:ft}Finale (dopo i supplementari):{/c} %{score}%{scorers} %{league}"
    ev.ft.pens     "{s:ft} {c:ft}Finale:{/c} %{score} — {b}%{winner}{b} vince %{so} ai rigori %{league}"
    ev.ft.duel     "{s:ft} {c:ft}Finale:{/c} %{score} — vince {b}%{winner}{b} %{league}"
    ev.postponed   "{s:flag} {c:warn}Rinviata:{/c} %{teams} %{league}"
    ev.cancelled   "{s:flag} {c:warn}Annullata:{/c} %{teams} %{league}"
    ev.abandoned   "{s:flag} {c:warn}Sospesa definitivamente:{/c} %{score} %{league}"
    ev.suspended   "{s:flag} {c:warn}Sospesa:{/c} %{score} %{league}"
    ev.delayed     "{s:flag} {c:warn}In ritardo:{/c} %{teams} %{league}"
    ev.resumed     "{s:start} Si riprende: %{score} %{league}"
    ev.score       "{s:goal} {c:goal}%{label}{/c} %{team}: %{score} {c:dim}(%{detail}){/c} %{league}"
    ev.period_end  "{s:ht} Fine del %{period}: %{score} %{league}"
    ev.ot          "{s:clock} {c:hl}Supplementari!{/c} %{score} %{league}"
    ev.close       "{s:clock} {c:hl}Finale punto a punto!{/c} Mancano %{left}: %{score} %{league}"
    ev.set         "{s:dot} Set %{n} a {b}%{player}{b} (%{games}) — %{score} %{league}"
    ev.leader      "{s:race} Nuovo leader in %{name}: {b}%{driver}{b} (davanti a %{prev}) %{league}"
    ev.reminder    "{s:clock} Inizia tra %{mins} min: {b}%{teams}{b} (%{time}) %{league}%{tv}"

    score.goal "Gol" score.runs "Punto/i +%{n}" score.try "Meta" score.penalty "Calcio piazzato" score.points "+%{n}"

    err.perm            "Non hai il permesso."
    err.internal        "Qualcosa è andato storto, scusa. L'errore è stato registrato."
    err.usage           "Uso: {b}%{cmd}{b} %{usage}"
    err.ambiguous       "'%{query}' corrisponde a più squadre: %{options} — sii più preciso."
    err.team_notfound   "Nessuna squadra trovata per '%{query}'."
    err.league_notfound "Competizione sconosciuta: '%{query}'. Prova !campionati."
    err.nodata          "Ancora nessun dato disponibile."
    err.provider        "Il fornitore dei dati non risponde. Riprova tra un minuto."

    live.none       "Nessuna partita in diretta ora."
    live.none_next  "Niente in diretta. Prossima: %{next}"
    live.team_none  "%{team} non sta giocando ora. Prova %{cmd}."
    today.none      "Nessuna partita il %{date} in queste competizioni."
    team.no_match_day "%{team} non gioca quel giorno."
    team.no_match   "Nessuna partita recente o prossima per %{team}."
    digest.chan     "{s:clock} {b}Le partite di oggi{b} (%{n}):"
    digest.none     "Il tuo riepilogo: oggi non gioca nessuna delle tue squadre/competizioni."
    digest.header   "{s:clock} {b}Le tue partite di oggi{b} (%{n}):"
    missed.header   "{s:dot} Bentornato! Risultati che ti sei perso (%{n}):"

    stat.possession "Possesso" stat.shots "Tiri(porta)" stat.on_target "In porta" stat.corners "Angoli"
    stat.fouls "Falli" stat.yellows "Gialli" stat.reds "Rossi" stat.offsides "Fuorigioco"
    stat.saves "Parate" stat.passes "Passaggi" stat.pass_pct "% passaggi"
    lineup.none     "Le formazioni di %{teams} non sono ancora uscite (~1h prima)."
    stats.notyet    "%{teams} non è ancora iniziata."

    next.none   "Nessuna prossima partita per %{what}."
    last.none   "Nessun risultato recente per %{what}."
    table.none  "Classifica non disponibile per %{league}."
    table.sent_priv "Ti ho mandato i dettagli in privato."
    table.row   "{c:rank}%{rank}.{/c}%{team} {c:dim}G%{gp} V%{w} N%{d} P%{l} DR%{gd}{/c} {b}%{pts}{b}"
    scorers.soccer_only "I marcatori sono disponibili solo per il calcio."
    scorers.title   "Marcatori %{league}:"
    scorers.assists "Assistman %{league}:"
    h2h.none   "Nessun precedente recente tra %{a} e %{b}."
    h2h.title  "{b}%{a} - %{b}{b} ({c:win}%{w}V{/c} {c:draw}%{d}N{/c} {c:loss}%{l}P{/c}):"

    sport.soccer "Calcio" sport.basketball "Basket" sport.football "Football americano" sport.hockey "Hockey su ghiaccio"
    sport.baseball "Baseball" sport.racing "Motori" sport.tennis "Tennis" sport.mma "MMA" sport.golf "Golf"
    sport.rugby "Rugby" sport.australian-football "Football australiano"
    leagues.summary  "Competizioni: %{sports}. Cerca con %{cmd} <nome|sport>."

    help.group.info "Risultati e info"
    help.group.mine "Personale"
    help.group.fun  "Cronaca e pronostici"
    help.footer     "Dettagli: %{cmd} <comando>. I comandi funzionano anche in privato."
    help.aliases    "Funziona anche come"
    help.live     "\[campionato|sport|squadra\] — partite in diretta"
    help.today    "\[campionato|sport|squadra\] \[data\] — partite del giorno"
    help.match    "<squadra> — partita in corso/ultima in dettaglio"
    help.table    "<campionato|squadra> \[gruppo\] \[completa\] — classifica"
    help.narrate  "<squadra> \[full|normal|breve\] | off | lista — cronaca in diretta"
    help.follow   "<squadra> | lega <nome> | giocatore <nome> — avvisi in privato"
    help.predict  "<squadra> <gol>-<gol> — il tuo pronostico (si chiude al calcio d'inizio)"
    help.ranking  "\[settimana|mese|stagione|tutto\] — classifica della schedina"

    narr.stopped    "Fine della cronaca di %{teams}."
    narr.none       "Nessuna cronaca attiva qui."
    narr.limit      "Limite di cronache raggiunto (%{n})."
    narr.nomatch    "%{team} non gioca ora né nelle prossime %{hours}h."
    narr.already    "Sto già raccontando %{teams} qui."
    narr.started    "{s:mic} Cronaca #%{id}: {b}%{teams}{b} (%{style}, %{when}). Per fermarla: %{cmd}"
    narr.style.full "completa" narr.style.normal "normale" narr.style.brief "breve"
    narr.assist     " {c:dim}(assist di %{name}){/c}"
    narr.lineups_in "{b}Ecco le formazioni ufficiali!{b}"
    narr.form       "Forma — %{home}: %{hf} · %{away}: %{af}"
    narr.poss       "possesso %{home} %{ph}% – %{pa}% %{away}"
    narr.join_generic "Ci colleghiamo con %{league}: %{score} {c:dim}(%{detail}){/c}"
    narr.signoff    "{c:dim}Per questa partita è tutto. Grazie per averci seguito!{/c}"
    replay.banner   "REPLICA x%{speed}: %{teams} (partita registrata, non in diretta)"

    preds.noscope   "Di quale canale? Usa %{cmd} #canale ... oppure: imposta home #canale"
    preds.disabled  "La schedina è disattivata in quel canale."
    preds.nomatch   "%{team} non ha partite da pronosticare nei prossimi %{days} giorni."
    preds.saved     "{s:win} Pronostico salvato: %{pred} {c:dim}(%{when}, %{league}){/c}"
    preds.updated   "{s:win} Pronostico aggiornato: %{pred} {c:dim}(%{when}, %{league}){/c}"
    preds.void      "{s:flag} %{teams} non si giocherà: %{n} %{n:pronostico annullato|pronostici annullati}."
    preds.exact     "{c:gold}risultato esatto{/c} (+%{pts}): %{names}"
    preds.good      "{c:ok}segno giusto{/c}: %{names}"
    preds.zero      "%{n} sbagliati"
    preds.leader    "{s:trophy} in testa: {b}%{nick}{b} %{pts} pt"
    preds.settled   "{s:trophy} {b}Schedina{b} %{score}:"
    preds.empty     "Nessun pronostico ancora risolto. Prova %{cmd}!"
    preds.you       "tu: #%{pos} %{pts} pt (%{ex} esatti, %{n} %{n:pronostico|pronostici})"
    preds.ranking   "Classifica della schedina (%{period}):"
    preds.mine_none "Non hai pronostici aperti. Prova %{cmd} <squadra> 2-1"
    preds.mine      "I tuoi pronostici aperti"
    preds.hidden    "%{teams}: %{n} %{n:pronostico|pronostici} (svelati al calcio d'inizio)."
    preds.featured  "{c:gold}{s:star}{/c} %{teams} è il big match: punti x%{mult}!"
    preds.open_none "Nessuna partita da pronosticare nelle prossime 48h."
    preds.open_header "{s:trophy} {b}Aperte ai pronostici{b} (%{cmd} <squadra> 2-1):"
    period.week "ultimi 7 giorni" period.month "ultimi 30 giorni" period.season "stagione" period.all "sempre"

    cfg.needchan  "Quale canale? Usalo nel canale o indica #canale."
    follow.ok     "{s:win} Segui {b}%{what}{b}. Riceverai avvisi in privato; personalizza con %{cmd}."
    follow.already "Segui già %{what}."
    follow.limit  "Puoi seguire fino a %{n} elementi."
    unfollow.all  "Non segui più nulla."
    unfollow.notfound "Non segui nulla che corrisponda a '%{query}'."
    unfollow.ok   "Non segui più %{what}."
    follows.none  "Non segui ancora nulla. Prova %{cmd} <squadra>."
    follows.header "Segui"
    follows.kind.team "squadra" follows.kind.league "competizione" follows.kind.player "giocatore" follows.kind.match "partita"
    prefs.header  "Le tue preferenze"
    prefs.hint    "Modifica con %{cmd} <nome> <valore> (es.: imposta quiet 23:00-08:00 · imposta tz Europe/Rome)"
    set.badlang   "Lingua sconosciuta. Disponibili: %{langs}"
    set.badtz     "Fuso orario sconosciuto. Usa Regione/Città, es.: Europe/Rome."
    set.badvalue  "Valore non valido per %{key}. Validi: %{values}"
    set.unknown   "Impostazione '%{key}' sconosciuta. Valide: %{keys}"
    lang.list     "Lingue: %{langs}. Usa %{cmd} <codice>."
    tz.current    "Il tuo fuso: %{tz} (ora sono le %{time})."
}

::md::i18n::vary it {
    narr.intro {
        "{s:mic} Buonasera! Tra poco: {b}%{teams}{b} in %{league}, calcio d'inizio alle %{time}."
        "{s:mic} Siamo collegati per {b}%{teams}{b} (%{league}), si comincia alle %{time}."
    }
    narr.join { "Ci colleghiamo al {c:minute}%{min}{/c}: %{score}%{scorers}" }
    narr.kickoff {
        "{s:start} {c:start}{b}Si parte!{b}{/c} Comincia %{home} - %{away}."
        "{s:start} {c:start}{b}Fischio d'inizio!{b}{/c} %{home} contro %{away}."
    }
    narr.goal.goal {
        "{s:goal} {c:goal}{b}GOOOL!{b}{/c} {c:minute}%{min}{/c} {b}%{player}{b} segna per il %{team}! %{score}%{assist}"
        "{s:goal} {c:goal}{b}RETE!{b}{/c} %{player} gonfia la rete al {c:minute}%{min}{/c}. %{score}%{assist}"
    }
    narr.goal.first { "{s:goal} {c:goal}{b}GOOOL!{b}{/c} %{player} sblocca il risultato per il %{team} ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.equaliser { "{s:goal} {c:goal}{b}GOOOL!{b}{/c} {c:hl}Pareggio!{/c} %{player} rimette in parità il %{team} ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.comeback { "{s:goal} {c:goal}{b}GOOOL!{b}{/c} {c:hl}RIMONTA COMPLETATA!{/c} %{player} porta avanti il %{team} ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.latewinner { "{s:goal} {c:goal}{b}GOOOOL!{b}{/c} {c:hl}All'ultimo respiro!{/c} %{player}, {c:minute}%{min}{/c}. %{score}%{assist}" }
    narr.goal.brace { "{s:goal} {c:goal}{b}GOOOL!{b}{/c} Ancora %{player}! {c:hl}Doppietta{/c} ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.hattrick { "{s:goal} {c:goal}{b}GOOOL!{b}{/c} {c:hl}{s:star} TRIPLETTA di %{player}!{/c} ({c:minute}%{min}{/c}) %{score}%{assist}" }
    narr.goal.pen { "{s:goal} {c:goal}{b}GOOOL!{b}{/c} %{player} trasforma il rigore ({c:minute}%{min}{/c}). %{score}" }
    narr.goal.og { "{s:goal} {c:goal}{b}AUTOGOL!{b}{/c} %{player} batte il proprio portiere ({c:minute}%{min}{/c}). %{score}" }
    narr.goal.rout { "{s:goal} {c:goal}{b}GOOOL!{b}{/c} %{player} cala il poker... è goleada ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.consolation { "{s:goal} {c:goal}{b}GOOOL!{b}{/c} %{player} accorcia le distanze per il %{team} ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.yellow {
        "{s:yellow} {c:minute}%{min}{/c} Giallo per %{player} (%{team})."
        "{s:yellow} {c:minute}%{min}{/c} %{player} finisce sul taccuino dell'arbitro."
    }
    narr.yred { "{s:yred} {c:minute}%{min}{/c} {c:red}{b}Secondo giallo!{b}{/c} %{player} espulso, %{team} in dieci." }
    narr.red { "{s:red} {c:minute}%{min}{/c} {c:red}{b}ROSSO DIRETTO!{b}{/c} %{player} (%{team}) espulso!" }
    narr.sub { "{s:sub} {c:minute}%{min}{/c} Cambio nel %{team}: entra %{pin}, esce %{pout}." }
    narr.penmiss { "{s:pen} {c:minute}%{min}{/c} {c:hl}RIGORE SBAGLIATO!{/c} %{player} (%{team}) fallisce dal dischetto!" }
    narr.pensaved { "{s:pen} {c:minute}%{min}{/c} {c:hl}PARATO!{/c} Il portiere ipnotizza %{player}!" }
    narr.save {
        "{s:chance} {c:minute}%{min}{/c} Occasione per il %{team}! Tira %{player}... para %{keeper}."
        "{s:chance} {c:minute}%{min}{/c} Grande intervento di %{keeper} su %{player}!"
    }
    narr.shot { "{s:chance} {c:minute}%{min}{/c} %{player} (%{team}) impegna il portiere." }
    narr.woodwork {
        "{s:chance} {c:minute}%{min}{/c} {c:hl}PALO!{/c} %{player} colpisce il legno!"
        "{s:chance} {c:minute}%{min}{/c} {c:hl}Traversa!{/c} Che occasione per il %{team} — %{player}."
    }
    narr.miss { "{s:chance} {c:minute}%{min}{/c} %{player} ci prova, di poco fuori." }
    narr.corner { "{c:minute}%{min}{/c} Calcio d'angolo per il %{team}." }
    narr.added { "{s:clock} Recupero: {b}+%{n}'{b}." }
    narr.ht { "{s:ht} {c:ht}{b}Fine primo tempo!{b}{/c} %{score}%{scorers}" }
    narr.2h { "{s:start} {c:start}Si riparte per il secondo tempo!{/c} %{score}" }
    narr.end90 { "{s:ht} Finiti i 90 minuti: %{score}." }
    narr.et { "{s:start} {c:hl}Iniziano i supplementari!{/c} %{score}" }
    narr.shootout { "{s:pen} {c:pen}{b}Si va ai RIGORI!{b}{/c} %{score}" }
    narr.so.scored { "{s:pen} %{player} (%{team}) {c:ok}segna{/c}." }
    narr.so.missed { "{s:pen} %{player} (%{team}) {c:err}sbaglia!{/c}" }
    narr.update { "{c:dim}{s:clock}{/c} {c:minute}%{min}{/c} %{score} {c:dim}%{poss}{/c}" }
    narr.pressure { "{s:chance} Il %{team} spinge: %{n} tiri in cinque minuti!" }
    narr.tension.draw { "{s:clock} Ultimi minuti e ancora parità: %{score}." }
    narr.tension.close { "{s:clock} Ultimi minuti: il %{team} difende il vantaggio. %{score}" }
    narr.var { "{s:var} {c:minute}%{min}{/c} {c:var}Controllo VAR...{/c} %{text}" }
    narr.delay { "{c:minute}%{min}{/c} Gioco fermo." }
    narr.ft.win {
        "{s:ft} {c:ft}{b}FINITA!{b}{/c} %{score} — vittoria del {b}%{winner}{b}!"
        "{s:ft} {c:ft}{b}Triplice fischio!{b}{/c} %{winner} porta a casa i tre punti. %{score}"
    }
    narr.ft.draw { "{s:ft} {c:ft}{b}FINITA!{b}{/c} Pareggio: %{score}." }
    narr.ft.pens { "{s:ft} {c:ft}{b}È FINITA!{b}{/c} %{score} — {b}%{winner}{b} vince %{so} ai rigori!" }
}

# --- players, probabilities, hot matches, videos
::md::i18n::cmds it { player {giocatore} prob {probabilita quote} }

::md::i18n::msgs it {
    player.notfound    "Nessun giocatore trovato per '%{query}'."
    player.age         "%{n} anni"
    player.goals       "%{n} gol"
    player.assists     "%{n} assist"
    player.starts      "%{n} da titolare"
    player.shots       "%{n} %{n:tiro|tiri} (%{s} in porta)"
    player.cleansheets "%{n} clean sheet"
    player.last        "Ultime %{n}: %{goals} G, %{assists} A"
    player.next        "Prossima: %{name} (%{when}, %{league})"
    player.also        "Anche: %{list}"
    prob.draw          "pareggio"
    prob.model         "Probabilità"
    prob.odds          "Quote pre-partita"
    prob.espn          "Probabilità (ESPN)"
    prob.prior         "Probabilità (senza quote)"
    prob.none          "Nessuna probabilità disponibile per %{teams}."
    hot.flurry         "{s:hot} {c:hl}{b}Partita infuocata!{b}{/c} %{n} gol in %{mins} minuti: %{score} {c:minute}%{min}{/c} %{league}"
    hot.goalfest       "{s:hot} {c:hl}{b}Pioggia di gol!{b}{/c} già %{n} gol: %{score} {c:minute}%{min}{/c} %{league}"
    hot.comeback       "{s:hot} {c:hl}{b}Rimonta in corso!{b}{/c} il %{team} era sotto di due: %{score} {c:minute}%{min}{/c} %{league}"
    hot.upset          "{s:hot} {c:hl}{b}Sorpresa in arrivo!{b}{/c} il %{team} (%{pct}% alla vigilia) è avanti: %{score} {c:minute}%{min}{/c} %{league}"
    hot.shock          "{s:hot} {c:hl}{b}Clamoroso!{b}{/c} vince il %{team} (%{pct}% alla vigilia): %{score} %{league}"
    ev.video           "{s:tv} {c:info}Video:{/c} %{teams} {c:dim}—{/c} %{headline}%{dur} %{url}"
    help.player        "<nome> — scheda e statistiche stagionali"
    help.prob          "<squadra> — probabilità di vittoria"
}
