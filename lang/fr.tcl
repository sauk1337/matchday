# Matchday - Français

::md::i18n::lang fr French Français

::md::i18n::cmds fr {
    help     {aide}
    live     {direct}
    today    {aujourdhui resultats}
    match    {rencontre}
    next     {prochain prochains calendrier}
    last     {derniers}
    table    {classement}
    scorers  {buteurs}
    lineup   {compo compos}
    stats    {statistiques}
    form     {forme}
    h2h      {confrontations}
    leagues  {ligues championnats}
    narrate  {commenter commentaire}
    follow   {suivre}
    unfollow {nepassuivre}
    follows  {suivis mesequipes}
    prefs    {preferences}
    set      {regler}
    lang     {langue}
    tz       {fuseau}
    predict  {prono pronostiquer}
    preds    {pronos mespronos}
    porra    {concours}
    ranking  {rangconcours}
    more     {suite}
    about    {apropos}
    mdset    {configurer}
}

::md::i18n::msgs fr {
    more.hint        "{c:dim}(encore %{n} lignes : %{cmd}){/c}"
    more.none        "Plus rien à afficher."
    word.tomorrow    "Demain"
    word.referee     "Arbitre"
    form.W "V" form.D "N" form.L "D"
    word.form        "Forme"
    word.bench       "Remplaçants"
    days.short       {- Lun Mar Mer Jeu Ven Sam Dim}

    st.ht "MT" st.ft "Fin" st.aet "AP" st.pens "TAB" st.ppd "Reporté" st.canc "Annulé"
    st.aban "Arrêté" st.susp "Susp" st.delay "Retardé" st.shootout "TAB" st.live "DIRECT"

    tag.pen     " (sp)"
    tag.og      " (csc)"
    tag.assist  "passe : %{name}"

    ctx.poker      "Quadruplé de %{player} !"
    ctx.hattrick   "Triplé de %{player} !"
    ctx.comeback   "Quelle remontada !"
    ctx.equaliser  "Égalisation !"
    ctx.brace      "Doublé de %{player} !"
    ctx.latewinner "Dans les arrêts de jeu !"
    ctx.lead       "Ils repassent devant !"

    period.half    "%{n}e mi-temps"
    period.q       "%{n}e quart-temps"
    period.p       "%{n}e période"
    period.ot      "prolongation %{n}"
    period.inning  "%{n}e manche"

    ev.goal        "{s:goal} {c:goal}{b}BUT !{b}{/c} %{score}%{who}%{ctx} %{league}"
    ev.scorer      "{s:goal} Buteur : %{player} %{min} (%{team}) {c:dim}—{/c} %{score} %{league}"
    ev.disallowed  "{s:var} {c:var}{b}But refusé{b}{/c} pour %{team} ! %{score} %{league}"
    ev.card.yellow "{s:yellow} Carton jaune : %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.card.yred   "{s:yred} {c:red}{b}Expulsé !{b}{/c} Deuxième jaune pour %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.card.red    "{s:red} {c:red}{b}CARTON ROUGE !{b}{/c} %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.penmiss     "{s:pen} Penalty manqué par %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.kickoff     "{s:start} {c:start}Coup d'envoi :{/c} %{teams} %{league}"
    ev.start       "{s:start} {c:start}C'est parti :{/c} %{teams} %{league}"
    ev.race_start  "{s:race} {c:start}C'est parti :{/c} %{name} %{league}"
    ev.race_end    "{s:ft} {c:ft}Terminé :{/c} %{name} — {s:trophy} %{podium} %{league}"
    ev.ht          "{s:ht} {c:ht}Mi-temps :{/c} %{score}%{scorers} %{league}"
    ev.2h          "{s:start} Début de la seconde période : %{score} %{league}"
    ev.et          "{s:start} {c:hl}Prolongation !{/c} %{score} %{league}"
    ev.shootout    "{s:pen} {c:pen}{b}Tirs au but !{b}{/c} %{score} %{league}"
    ev.ft          "{s:ft} {c:ft}Fin du match :{/c} %{score}%{scorers} %{league}"
    ev.ft.aet      "{s:ft} {c:ft}Fin (après prolongation) :{/c} %{score}%{scorers} %{league}"
    ev.ft.pens     "{s:ft} {c:ft}Fin du match :{/c} %{score} — {b}%{winner}{b} s'impose %{so} aux tirs au but %{league}"
    ev.ft.duel     "{s:ft} {c:ft}Terminé :{/c} %{score} — victoire de {b}%{winner}{b} %{league}"
    ev.postponed   "{s:flag} {c:warn}Reporté :{/c} %{teams} %{league}"
    ev.cancelled   "{s:flag} {c:warn}Annulé :{/c} %{teams} %{league}"
    ev.abandoned   "{s:flag} {c:warn}Arrêté :{/c} %{score} %{league}"
    ev.suspended   "{s:flag} {c:warn}Interrompu :{/c} %{score} %{league}"
    ev.delayed     "{s:flag} {c:warn}Retardé :{/c} %{teams} %{league}"
    ev.resumed     "{s:start} Reprise : %{score} %{league}"
    ev.score       "{s:goal} {c:goal}%{label}{/c} %{team} : %{score} {c:dim}(%{detail}){/c} %{league}"
    ev.period_end  "{s:ht} Fin — %{period} : %{score} %{league}"
    ev.ot          "{s:clock} {c:hl}Prolongation !{/c} %{score} %{league}"
    ev.close       "{s:clock} {c:hl}Fin serrée !{/c} Il reste %{left} (%{period}) : %{score} %{league}"
    ev.set         "{s:dot} Set %{n} pour {b}%{player}{b} (%{games}) — %{score} %{league}"
    ev.leader      "{s:race} Nouveau leader de %{name} : {b}%{driver}{b} (devant %{prev}) %{league}"
    ev.reminder    "{s:clock} Début dans %{mins} min : {b}%{teams}{b} (%{time}) %{league}%{tv}"

    score.goal "But" score.runs "Point(s) +%{n}" score.try "Essai" score.penalty "Pénalité" score.points "+%{n}"

    err.perm            "Vous n'avez pas la permission."
    err.internal        "Une erreur s'est produite, désolé. Elle a été enregistrée."
    err.usage           "Usage : {b}%{cmd}{b} %{usage}"
    err.ambiguous       "'%{query}' correspond à plusieurs équipes : %{options} — soyez plus précis."
    err.team_notfound   "Aucune équipe trouvée pour '%{query}'."
    err.league_notfound "Compétition inconnue : '%{query}'. Essayez !ligues."
    err.nodata          "Pas encore de données pour cela."
    err.provider        "Le fournisseur de données ne répond pas. Réessayez dans une minute."

    live.none       "Aucun match en direct pour le moment."
    live.none_next  "Rien en direct. Prochain : %{next}"
    live.team_none  "%{team} ne joue pas en ce moment. Essayez %{cmd}."
    today.none      "Aucun match le %{date} dans ces compétitions."
    team.no_match_day "%{team} ne joue pas ce jour-là."
    team.no_match   "Aucun match récent ou à venir pour %{team}."
    digest.chan     "{s:clock} {b}Les matchs du jour{b} (%{n}) :"
    digest.none     "Votre résumé : aucune de vos équipes/compétitions ne joue aujourd'hui."
    digest.header   "{s:clock} {b}Vos matchs du jour{b} (%{n}) :"
    missed.header   "{s:dot} Bon retour ! Résultats manqués (%{n}) :"

    stat.possession "Possession" stat.shots "Tirs(cadrés)" stat.on_target "Cadrés" stat.corners "Corners"
    stat.fouls "Fautes" stat.yellows "Jaunes" stat.reds "Rouges" stat.offsides "Hors-jeu"
    stat.saves "Arrêts" stat.passes "Passes" stat.pass_pct "% passes"
    lineup.none     "Les compositions de %{teams} ne sont pas encore connues (~1h avant)."
    stats.notyet    "%{teams} n'a pas encore commencé."

    next.none   "Aucun match à venir pour %{what}."
    last.none   "Aucun résultat récent pour %{what}."
    table.none  "Pas de classement disponible pour %{league}."
    table.sent_priv "Je vous ai envoyé le détail en privé."
    table.row   "{c:rank}%{rank}.{/c}%{team} {c:dim}J%{gp} G%{w} N%{d} P%{l} Diff%{gd}{/c} {b}%{pts}{b}"
    scorers.soccer_only "Les buteurs ne sont disponibles que pour le football."
    scorers.title   "Buteurs %{league} :"
    scorers.assists "Passeurs %{league} :"
    h2h.none   "Aucune confrontation récente entre %{a} et %{b}."
    h2h.title  "{b}%{a} - %{b}{b} ({c:win}%{w}V{/c} {c:draw}%{d}N{/c} {c:loss}%{l}D{/c}) :"

    sport.soccer "Football" sport.basketball "Basket" sport.football "Football américain" sport.hockey "Hockey sur glace"
    sport.baseball "Baseball" sport.racing "Sport auto" sport.tennis "Tennis" sport.mma "MMA" sport.golf "Golf"
    sport.rugby "Rugby" sport.australian-football "Football australien"
    leagues.summary  "Compétitions : %{sports}. Cherchez avec %{cmd} <nom|sport>."

    help.group.info "Scores et infos"
    help.group.mine "Personnel"
    help.group.fun  "Commentaires et pronostics"
    help.footer     "Détail : %{cmd} <commande>. Les commandes marchent aussi en privé."
    help.aliases    "Fonctionne aussi avec"
    help.live     "\[ligue|sport|équipe\] — matchs en direct"
    help.today    "\[ligue|sport|équipe\] \[date\] — matchs du jour (aujourdhui, demain, 25/12...)"
    help.match    "<équipe> — match en cours/dernier en détail"
    help.next     "<équipe|ligue> — prochains matchs"
    help.table    "<ligue|équipe> \[groupe\] \[complet\] — classement"
    help.narrate  "<équipe> \[full|normal|court\] | off | liste — commentaire en direct"
    help.follow   "<équipe> | ligue <nom> | joueur <nom> — alertes en privé"
    help.predict  "<équipe> <buts>-<buts> — votre pronostic (fermé au coup d'envoi)"
    help.ranking  "\[semaine|mois|saison|tout\] — classement du concours"

    narr.stopped    "Fin du commentaire de %{teams}."
    narr.none       "Aucun commentaire en cours ici."
    narr.limit      "Limite de commentaires atteinte (%{n})."
    narr.nomatch    "%{team} ne joue pas maintenant ni dans les %{hours}h."
    narr.already    "Je commente déjà %{teams} ici."
    narr.started    "{s:mic} Commentaire #%{id} : {b}%{teams}{b} (%{style}, %{when}). Arrêter : %{cmd}"
    narr.style.full "complet" narr.style.normal "normal" narr.style.brief "court"
    narr.assist     " {c:dim}(passe de %{name}){/c}"
    narr.lineups_in "{b}Les compos sont tombées !{b}"
    narr.form       "Forme — %{home} : %{hf} · %{away} : %{af}"
    narr.poss       "possession %{home} %{ph}% – %{pa}% %{away}"
    narr.join_generic "Nous rejoignons %{league} : %{score} {c:dim}(%{detail}){/c}"
    narr.signoff    "{c:dim}C'est fini pour ce match. Merci de nous avoir suivis !{/c}"
    replay.banner   "REDIFFUSION x%{speed} : %{teams} (match enregistré, pas en direct)"

    preds.noscope   "Quel salon ? Utilisez %{cmd} #salon ... ou : regler home #salon"
    preds.disabled  "Le concours de pronostics est désactivé sur ce salon."
    preds.nomatch   "%{team} n'a pas de match à pronostiquer dans les %{days} jours."
    preds.saved     "{s:win} Prono enregistré : %{pred} {c:dim}(%{when}, %{league}){/c}"
    preds.updated   "{s:win} Prono modifié : %{pred} {c:dim}(%{when}, %{league}){/c}"
    preds.void      "{s:flag} %{teams} n'aura pas lieu : %{n} %{n:prono annulé|pronos annulés}."
    preds.exact     "{c:gold}score exact{/c} (+%{pts}) : %{names}"
    preds.good      "{c:ok}bon résultat{/c} : %{names}"
    preds.zero      "%{n} perdus"
    preds.leader    "{s:trophy} leader : {b}%{nick}{b} %{pts} pts"
    preds.settled   "{s:trophy} {b}Concours{b} %{score} :"
    preds.empty     "Aucun prono réglé pour l'instant. Essayez %{cmd} !"
    preds.you       "vous : #%{pos} %{pts} pts (%{ex} exacts, %{n} %{n:prono|pronos})"
    preds.ranking   "Classement du concours (%{period}) :"
    preds.mine_none "Aucun prono en cours. Essayez %{cmd} <équipe> 2-1"
    preds.mine      "Vos pronos en cours"
    preds.hidden    "%{teams} : %{n} %{n:prono|pronos} (révélés au coup d'envoi)."
    preds.featured  "{c:gold}{s:star}{/c} %{teams} est le match vedette : points x%{mult} !"
    preds.open_none "Aucun match à pronostiquer dans les 48h."
    preds.open_header "{s:trophy} {b}Ouverts aux pronos{b} (%{cmd} <équipe> 2-1) :"
    period.week "7 derniers jours" period.month "30 derniers jours" period.season "saison" period.all "général"

    cfg.needchan  "Quel salon ? Utilisez la commande sur le salon ou indiquez #salon."
    follow.ok     "{s:win} Vous suivez {b}%{what}{b}. Alertes en privé ; réglages avec %{cmd}."
    follow.already "Vous suivez déjà %{what}."
    follow.limit  "Vous pouvez suivre jusqu'à %{n} éléments."
    unfollow.all  "Vous ne suivez plus rien."
    unfollow.notfound "Vous ne suivez rien qui corresponde à '%{query}'."
    unfollow.ok   "Vous ne suivez plus %{what}."
    follows.none  "Vous ne suivez rien. Essayez %{cmd} <équipe>."
    follows.header "Vous suivez"
    follows.kind.team "équipe" follows.kind.league "compétition" follows.kind.player "joueur" follows.kind.match "match"
    prefs.header  "Vos préférences"
    prefs.hint    "Modifiez avec %{cmd} <nom> <valeur> (ex. : regler quiet 23:00-08:00 · regler tz Europe/Paris)"
    set.badlang   "Langue inconnue. Disponibles : %{langs}"
    set.badtz     "Fuseau inconnu. Utilisez Région/Ville, ex. : Europe/Paris, America/Montreal."
    set.badvalue  "Valeur invalide pour %{key}. Valeurs : %{values}"
    set.unknown   "Réglage '%{key}' inconnu. Valides : %{keys}"
    lang.list     "Langues : %{langs}. Utilisez %{cmd} <code>."
    tz.current    "Votre fuseau : %{tz} (il est %{time})."
}

::md::i18n::vary fr {
    narr.intro {
        "{s:mic} Bonsoir ! Bientôt : {b}%{teams}{b} en %{league}, coup d'envoi à %{time}."
        "{s:mic} Nous sommes en direct pour {b}%{teams}{b} (%{league}), début à %{time}."
    }
    narr.join { "Nous rejoignons le match à la {c:minute}%{min}{/c} : %{score}%{scorers}" }
    narr.kickoff {
        "{s:start} {c:start}{b}C'est parti !{b}{/c} %{home} - %{away} a commencé."
        "{s:start} {c:start}{b}Coup d'envoi !{b}{/c} %{home} face à %{away}."
    }
    narr.goal.goal {
        "{s:goal} {c:goal}{b}BUUUT !{b}{/c} {c:minute}%{min}{/c} {b}%{player}{b} marque pour %{team} ! %{score}%{assist}"
        "{s:goal} {c:goal}{b}BUT !{b}{/c} %{player} trouve le chemin des filets ({c:minute}%{min}{/c}). %{score}%{assist}"
    }
    narr.goal.first { "{s:goal} {c:goal}{b}BUT !{b}{/c} %{player} ouvre le score pour %{team} ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.equaliser { "{s:goal} {c:goal}{b}BUT !{b}{/c} {c:hl}Égalisation !{/c} %{player} remet %{team} à hauteur ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.comeback { "{s:goal} {c:goal}{b}BUT !{b}{/c} {c:hl}Quelle remontada !{/c} %{player} donne l'avantage à %{team} ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.latewinner { "{s:goal} {c:goal}{b}BUUUT !{b}{/c} {c:hl}Au bout du suspense !{/c} %{player}, {c:minute}%{min}{/c}. %{score}%{assist}" }
    narr.goal.brace { "{s:goal} {c:goal}{b}BUT !{b}{/c} Encore %{player} ! {c:hl}Doublé{/c} ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.hattrick { "{s:goal} {c:goal}{b}BUT !{b}{/c} {c:hl}{s:star} TRIPLÉ de %{player} !{/c} ({c:minute}%{min}{/c}) %{score}%{assist}" }
    narr.goal.pen { "{s:goal} {c:goal}{b}BUT !{b}{/c} %{player} transforme le penalty ({c:minute}%{min}{/c}). %{score}" }
    narr.goal.og { "{s:goal} {c:goal}{b}CONTRE SON CAMP !{b}{/c} %{player} trompe son propre gardien ({c:minute}%{min}{/c}). %{score}" }
    narr.goal.rout { "{s:goal} {c:goal}{b}BUT !{b}{/c} %{player} enfonce le clou ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.goal.consolation { "{s:goal} {c:goal}{b}BUT !{b}{/c} %{player} réduit l'écart pour %{team} ({c:minute}%{min}{/c}). %{score}%{assist}" }
    narr.yellow {
        "{s:yellow} {c:minute}%{min}{/c} Carton jaune pour %{player} (%{team})."
        "{s:yellow} {c:minute}%{min}{/c} %{player} est averti."
    }
    narr.yred { "{s:yred} {c:minute}%{min}{/c} {c:red}{b}Deuxième jaune !{b}{/c} %{player} est expulsé, %{team} à dix." }
    narr.red { "{s:red} {c:minute}%{min}{/c} {c:red}{b}ROUGE DIRECT !{b}{/c} %{player} (%{team}) est expulsé !" }
    narr.sub { "{s:sub} {c:minute}%{min}{/c} Changement pour %{team} : %{pin} remplace %{pout}." }
    narr.penmiss { "{s:pen} {c:minute}%{min}{/c} {c:hl}PENALTY MANQUÉ !{/c} %{player} (%{team}) rate sa tentative !" }
    narr.pensaved { "{s:pen} {c:minute}%{min}{/c} {c:hl}ARRÊTÉ !{/c} Le gardien repousse le penalty de %{player} !" }
    narr.save {
        "{s:chance} {c:minute}%{min}{/c} Occasion pour %{team} ! %{player} frappe... arrêt de %{keeper}."
        "{s:chance} {c:minute}%{min}{/c} Belle parade de %{keeper} devant %{player} !"
    }
    narr.shot { "{s:chance} {c:minute}%{min}{/c} %{player} (%{team}) oblige le gardien à s'employer." }
    narr.woodwork {
        "{s:chance} {c:minute}%{min}{/c} {c:hl}SUR LE POTEAU !{/c} %{player} trouve le montant !"
        "{s:chance} {c:minute}%{min}{/c} {c:hl}La barre !{/c} Si proche pour %{team} — %{player}."
    }
    narr.miss { "{s:chance} {c:minute}%{min}{/c} %{player} tente sa chance, juste à côté." }
    narr.corner { "{c:minute}%{min}{/c} Corner pour %{team}." }
    narr.added { "{s:clock} Temps additionnel : {b}+%{n}'{b}." }
    narr.ht { "{s:ht} {c:ht}{b}Mi-temps !{b}{/c} %{score}%{scorers}" }
    narr.2h { "{s:start} {c:start}C'est reparti pour la seconde période !{/c} %{score}" }
    narr.end90 { "{s:ht} Fin du temps réglementaire : %{score}." }
    narr.et { "{s:start} {c:hl}Début de la prolongation !{/c} %{score}" }
    narr.shootout { "{s:pen} {c:pen}{b}Séance de TIRS AU BUT !{b}{/c} %{score}" }
    narr.so.scored { "{s:pen} %{player} (%{team}) {c:ok}marque{/c}." }
    narr.so.missed { "{s:pen} %{player} (%{team}) {c:err}rate !{/c}" }
    narr.update { "{c:dim}{s:clock}{/c} {c:minute}%{min}{/c} %{score} {c:dim}%{poss}{/c}" }
    narr.pressure { "{s:chance} %{team} pousse : %{n} tirs en cinq minutes !" }
    narr.tension.draw { "{s:clock} Dernières minutes et toujours à égalité : %{score}." }
    narr.tension.close { "{s:clock} Dernières minutes : %{team} s'accroche à son avance. %{score}" }
    narr.var { "{s:var} {c:minute}%{min}{/c} {c:var}Vérification VAR...{/c} %{text}" }
    narr.delay { "{c:minute}%{min}{/c} Le jeu est arrêté." }
    narr.ft.win {
        "{s:ft} {c:ft}{b}FIN DU MATCH !{b}{/c} %{score} — victoire de {b}%{winner}{b} !"
        "{s:ft} {c:ft}{b}C'est terminé !{b}{/c} %{winner} l'emporte. %{score}"
    }
    narr.ft.draw { "{s:ft} {c:ft}{b}FIN DU MATCH !{b}{/c} Match nul : %{score}." }
    narr.ft.pens { "{s:ft} {c:ft}{b}C'EST FINI !{b}{/c} %{score} — {b}%{winner}{b} gagne %{so} aux tirs au but !" }
}

# --- players, probabilities, hot matches, videos
::md::i18n::cmds fr { player {joueur} prob {probabilite cotes} }

::md::i18n::msgs fr {
    player.notfound    "Aucun joueur trouvé pour '%{query}'."
    player.age         "%{n} ans"
    player.goals       "%{n} %{n:but|buts}"
    player.assists     "%{n} %{n:passe déc.|passes déc.}"
    player.starts      "%{n} %{n:titularisation|titularisations}"
    player.shots       "%{n} %{n:tir|tirs} (%{s} cadrés)"
    player.cleansheets "%{n} clean sheets"
    player.last        "%{n} derniers : %{goals} B, %{assists} PD"
    player.next        "Prochain : %{name} (%{when}, %{league})"
    player.also        "Aussi : %{list}"
    prob.draw          "nul"
    prob.model         "Probabilités"
    prob.odds          "Cotes d'avant-match"
    prob.espn          "Probabilités (ESPN)"
    prob.prior         "Probabilités (sans cotes)"
    prob.none          "Pas de probabilité disponible pour %{teams}."
    hot.flurry         "{s:hot} {c:hl}{b}Match bouillant !{b}{/c} %{n} buts en %{mins} minutes : %{score} {c:minute}%{min}{/c} %{league}"
    hot.goalfest       "{s:hot} {c:hl}{b}Festival de buts !{b}{/c} déjà %{n} buts : %{score} {c:minute}%{min}{/c} %{league}"
    hot.comeback       "{s:hot} {c:hl}{b}Remontada en cours !{b}{/c} %{team} était mené de deux buts : %{score} {c:minute}%{min}{/c} %{league}"
    hot.upset          "{s:hot} {c:hl}{b}Surprise en vue !{b}{/c} %{team} (%{pct}% avant-match) mène : %{score} {c:minute}%{min}{/c} %{league}"
    hot.shock          "{s:hot} {c:hl}{b}Énorme surprise !{b}{/c} %{team} (%{pct}% avant-match) gagne : %{score} %{league}"
    ev.video           "{s:tv} {c:info}Vidéo :{/c} %{teams} {c:dim}—{/c} %{headline}%{dur} %{url}"
    help.player        "<nom> — fiche et statistiques de la saison"
    help.prob          "<équipe> — probabilités de victoire"
}
