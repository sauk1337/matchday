# Matchday - Español

::md::i18n::lang es Spanish Español

::md::i18n::cmds es {
    help     {ayuda comandos}
    live     {directo envivo vivo}
    today    {hoy resultados marcadores}
    match    {partido}
    next     {proximo proximos siguiente calendario}
    last     {ultimo ultimos}
    table    {clasificacion tabla}
    scorers  {goleadores pichichi}
    lineup   {alineacion alineaciones once}
    stats    {estadisticas}
    form     {forma racha}
    h2h      {cara historial}
    leagues  {ligas competiciones}
    narrate  {narrar narra narracion}
    follow   {seguir}
    unfollow {dejar noseguir}
    follows  {siguiendo misequipos}
    prefs    {preferencias opciones}
    set      {ajustar poner}
    lang     {idioma}
    tz       {zona horario}
    predict  {pronostico pronosticar apostar}
    preds    {pronosticos mispronosticos}
    porra    {quiniela}
    ranking  {clasificacionporra}
    more     {mas}
    about    {acerca}
    mdset    {configurar}
}

::md::i18n::msgs es {
    more.hint        "{c:dim}(%{n} líneas más: %{cmd}){/c}"
    more.none        "No hay nada más que mostrar."
    word.tomorrow    "Mañana"
    word.referee     "Árbitro"
    form.W "V" form.D "E" form.L "D"
    word.form        "Forma"
    word.bench       "Banquillo"
    days.short       {- Lun Mar Mié Jue Vie Sáb Dom}

    st.ht       "Desc"
    st.ft       "Final"
    st.aet      "Prórr"
    st.pens     "Pen"
    st.ppd      "Aplaz"
    st.canc     "Canc"
    st.aban     "Susp"
    st.susp     "Interr"
    st.delay    "Retras"
    st.shootout "Penaltis"
    st.live     "VIVO"

    tag.pen     " (p)"
    tag.og      " (pp)"
    tag.assist  "asist: %{name}"

    ctx.poker      "¡Póker de %{player}!"
    ctx.hattrick   "¡Hat-trick de %{player}!"
    ctx.comeback   "¡Remontada!"
    ctx.equaliser  "¡Empate!"
    ctx.brace      "¡Doblete de %{player}!"
    ctx.latewinner "¡Gol in extremis!"
    ctx.lead       "¡Vuelve a mandar!"

    period.half    "%{n}º tiempo"
    period.q       "%{n}º cuarto"
    period.p       "%{n}º periodo"
    period.ot      "tiempo extra %{n}"
    period.inning  "%{n}º inning"

    ev.goal        "{s:goal} {c:goal}{b}¡GOL!{b}{/c} %{score}%{who}%{ctx} %{league}"
    ev.scorer      "{s:goal} Autor del gol: %{player} %{min} (%{team}) {c:dim}—{/c} %{score} %{league}"
    ev.disallowed  "{s:var} {c:var}{b}¡Gol anulado{b}{/c} a %{team}! %{score} %{league}"
    ev.card.yellow "{s:yellow} Amarilla: %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.card.yred   "{s:yred} {c:red}{b}¡Expulsado!{b}{/c} Segunda amarilla a %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.card.red    "{s:red} {c:red}{b}¡ROJA DIRECTA!{b}{/c} %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.penmiss     "{s:pen} Penalti fallado por %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.kickoff     "{s:start} {c:start}Comienza:{/c} %{teams} %{league}"
    ev.start       "{s:start} {c:start}En juego:{/c} %{teams} %{league}"
    ev.race_start  "{s:race} {c:start}En marcha:{/c} %{name} %{league}"
    ev.race_end    "{s:ft} {c:ft}Terminado:{/c} %{name} — {s:trophy} %{podium} %{league}"
    ev.ht          "{s:ht} {c:ht}Descanso:{/c} %{score}%{scorers} %{league}"
    ev.2h          "{s:start} Arranca la segunda parte: %{score} %{league}"
    ev.et          "{s:start} {c:hl}¡Prórroga!{/c} %{score} %{league}"
    ev.shootout    "{s:pen} {c:pen}{b}¡Tanda de penaltis!{b}{/c} %{score} %{league}"
    ev.ft          "{s:ft} {c:ft}Final:{/c} %{score}%{scorers} %{league}"
    ev.ft.aet      "{s:ft} {c:ft}Final (tras prórroga):{/c} %{score}%{scorers} %{league}"
    ev.ft.pens     "{s:ft} {c:ft}Final:{/c} %{score} — {b}%{winner}{b} gana %{so} en los penaltis %{league}"
    ev.ft.duel     "{s:ft} {c:ft}Final:{/c} %{score} — gana {b}%{winner}{b} %{league}"
    ev.postponed   "{s:flag} {c:warn}Aplazado:{/c} %{teams} %{league}"
    ev.cancelled   "{s:flag} {c:warn}Cancelado:{/c} %{teams} %{league}"
    ev.abandoned   "{s:flag} {c:warn}Suspendido definitivamente:{/c} %{score} %{league}"
    ev.suspended   "{s:flag} {c:warn}Interrumpido:{/c} %{score} %{league}"
    ev.delayed     "{s:flag} {c:warn}Retrasado:{/c} %{teams} %{league}"
    ev.resumed     "{s:start} Se reanuda: %{score} %{league}"
    ev.score       "{s:goal} {c:goal}%{label}{/c} %{team}: %{score} {c:dim}(%{detail}){/c} %{league}"
    ev.period_end  "{s:ht} Termina el %{period}: %{score} %{league}"
    ev.ot          "{s:clock} {c:hl}¡Prórroga!{/c} %{score} %{league}"
    ev.close       "{s:clock} {c:hl}¡Final apretado!{/c} Quedan %{left} en el %{period}: %{score} %{league}"
    ev.set         "{s:dot} Set %{n} para {b}%{player}{b} (%{games}) — %{score} %{league}"
    ev.leader      "{s:race} Nuevo líder en %{name}: {b}%{driver}{b} (por delante de %{prev}) %{league}"
    ev.reminder    "{s:clock} Empieza en %{mins} min: {b}%{teams}{b} (%{time}) %{league}%{tv}"

    score.td       "Touchdown"
    score.fg       "Field goal"
    score.safety   "Safety"
    score.points   "+%{n}"
    score.goal     "Gol"
    score.runs     "Carrera(s) +%{n}"
    score.try      "Ensayo"
    score.penalty  "Golpe de castigo"

    err.perm            "No tienes permiso para eso."
    err.internal        "Algo ha fallado, lo siento. El error ha quedado registrado."
    err.usage           "Uso: {b}%{cmd}{b} %{usage}"
    err.ambiguous       "'%{query}' coincide con varios equipos: %{options} — concreta un poco más."
    err.team_notfound   "No encuentro ningún equipo llamado '%{query}'."
    err.league_notfound "Competición desconocida: '%{query}'. Prueba !ligas."
    err.nodata          "Todavía no hay datos para eso."
    err.provider        "El proveedor de datos no responde ahora mismo. Inténtalo en un minuto."

    live.none       "No hay partidos en directo ahora mismo."
    live.none_next  "Nada en directo. Próximo: %{next}"
    live.team_none  "%{team} no está jugando ahora. Prueba %{cmd}."
    today.none      "No hay partidos el %{date} en esas competiciones."
    team.no_match_day "%{team} no juega ese día."
    team.no_match   "No encuentro un partido reciente o próximo de %{team}."
    digest.chan     "{s:clock} {b}Partidos de hoy{b} (%{n}):"
    digest.none     "Tu resumen diario: hoy no juega ninguno de tus equipos/competiciones."
    digest.header   "{s:clock} {b}Tus partidos de hoy{b} (%{n}):"
    missed.header   "{s:dot} ¡Bienvenido de vuelta! Resultados que te perdiste (%{n}):"

    stat.possession "Posesión"
    stat.shots      "Tiros(puerta)"
    stat.on_target  "A puerta"
    stat.corners    "Córners"
    stat.fouls      "Faltas"
    stat.yellows    "Amarillas"
    stat.reds       "Rojas"
    stat.offsides   "Fueras de juego"
    stat.saves      "Paradas"
    stat.passes     "Pases"
    stat.pass_pct   "% pase"
    lineup.none     "Aún no hay alineaciones de %{teams} (suelen salir ~1h antes)."
    stats.notyet    "%{teams} todavía no ha empezado."

    next.none   "No encuentro próximos partidos de %{what}."
    last.none   "No encuentro resultados recientes de %{what}."
    table.none  "No hay clasificación disponible para %{league}."
    table.sent_priv "Te lo he enviado por privado."
    table.row   "{c:rank}%{rank}.{/c}%{team} {c:dim}PJ%{gp} G%{w} E%{d} P%{l} DG%{gd}{/c} {b}%{pts}{b}"
    table.row_us "{c:rank}%{rank}.{/c}%{team} {b}%{w}-%{l}{b} {c:dim}%{pct} GB %{gb}{/c}"
    scorers.soccer_only "Los goleadores solo están disponibles para fútbol."
    scorers.title   "Goleadores %{league}:"
    scorers.assists "Asistentes %{league}:"
    h2h.none   "No encuentro enfrentamientos recientes entre %{a} y %{b}."
    h2h.title  "{b}%{a} vs %{b}{b} ({c:win}%{w}V{/c} {c:draw}%{d}E{/c} {c:loss}%{l}D{/c}):"

    sport.soccer     "Fútbol"
    sport.basketball "Baloncesto"
    sport.football   "Fútbol americano"
    sport.hockey     "Hockey hielo"
    sport.baseball   "Béisbol"
    sport.racing     "Motor"
    sport.tennis     "Tenis"
    sport.mma        "MMA"
    sport.golf       "Golf"
    sport.rugby      "Rugby"
    sport.australian-football "Fútbol australiano"
    leagues.summary  "Competiciones: %{sports}. Busca con %{cmd} <nombre|deporte>."

    help.group.info "Resultados e info"
    help.group.mine "Personal"
    help.group.fun  "Narración y porra"
    help.footer     "Detalle: %{cmd} <comando>. Los comandos también funcionan por privado."
    help.aliases    "También funciona como"
    help.help     "\[comando\] — lista de comandos o ayuda de uno"
    help.live     "\[liga|deporte|equipo\] — partidos en directo"
    help.today    "\[liga|deporte|equipo\] \[fecha\] — partidos del día (hoy, mañana, 25/12...)"
    help.match    "<equipo> — partido actual/último en detalle: goles, tarjetas, estadísticas"
    help.next     "<equipo|liga> — próximos partidos"
    help.last     "<equipo|liga> — últimos resultados"
    help.table    "<liga|equipo> \[grupo\] \[completa\] — clasificación"
    help.scorers  "<liga> \[asistencias\] — máximos goleadores"
    help.lineup   "<equipo> — alineaciones"
    help.stats    "<equipo> — estadísticas del partido"
    help.form     "<equipo> — últimos 5 resultados"
    help.h2h      "<equipo> vs <equipo> — cara a cara"
    help.leagues  "\[búsqueda\] — competiciones disponibles"
    help.narrate  "<equipo> \[completa|normal|breve\] | off | lista — narración en directo de un partido"
    help.follow   "<equipo> | liga <nombre> | jugador <nombre> | partido <equipo> — avisos por privado"
    help.unfollow "<nombre|número|todo> — dejar de seguir"
    help.follows  "— lo que sigues"
    help.prefs    "— tus preferencias"
    help.set      "<idioma|tz|entrega|eventos|recordatorio|silencio|dnd|resumen|estilo|simbolos|casa> <valor>"
    help.lang     "\[código\] — tu idioma"
    help.tz       "\[Región/Ciudad\] — tu zona horaria, p.ej. Europe/Madrid"
    help.predict  "<equipo> <goles>-<goles> \[rival\] — pronostica un resultado (se cierra al empezar)"
    help.preds    "\[equipo\] — tus pronósticos abiertos, o los de todos en un partido"
    help.porra    "— partidos abiertos para pronosticar (ops: destacar <equipo> \[x2\] | on | off)"
    help.ranking  "\[semana|mes|temporada|todo\] — clasificación de la porra"
    help.mdset    "\[#canal\] <leagues|teams|events|lang|tz|style|symbols|prefix|remind|porra|narrperm|maxnarr|autonarr|narrstyle|digest|replies|quiet|cmds> <valor>"
    help.admin    "status | reload | save | enable | disable | alias | replay | demo | flush | debug | conf"
    about         "{b}Matchday %{version}{b} — deporte en directo para Eggdrop · transporte: %{transport}"

    narr.stopped    "Fin de la narración de %{teams}."
    narr.none       "No hay ninguna narración en marcha aquí."
    narr.limit      "Límite de narraciones alcanzado (%{n})."
    narr.nomatch    "%{team} no juega ahora ni en las próximas %{hours}h."
    narr.already    "Ya estoy narrando %{teams} aquí."
    narr.started    "{s:mic} Narración #%{id} activada: {b}%{teams}{b} (%{style}, %{when}). Para pararla: %{cmd}"
    narr.style.full   "completa"
    narr.style.normal "normal"
    narr.style.brief  "breve"
    narr.assist     " {c:dim}(asistencia de %{name}){/c}"
    narr.lineups_in "{b}¡Ya hay alineaciones!{b}"
    narr.form       "Racha — %{home}: %{hf} · %{away}: %{af}"
    narr.poss       "posesión %{home} %{ph}% – %{pa}% %{away}"
    narr.join_generic "Conectamos con %{league}: %{score} {c:dim}(%{detail}){/c}"
    narr.signoff    "{c:dim}Hasta aquí la narración. ¡Gracias por acompañarnos!{/c}"
    replay.banner   "REPETICIÓN x%{speed}: %{teams} (partido grabado, no es en directo)"

    preds.noscope   "¿De qué canal es la porra? Usa %{cmd} #canal ... o fija tu canal: ajustar casa #canal"
    preds.disabled  "La porra está desactivada en ese canal."
    preds.nomatch   "%{team} no tiene partido para pronosticar en los próximos %{days} días."
    preds.saved     "{s:win} Pronóstico guardado: %{pred} {c:dim}(%{when}, %{league}){/c}"
    preds.updated   "{s:win} Pronóstico actualizado: %{pred} {c:dim}(%{when}, %{league}){/c}"
    preds.void      "{s:flag} %{teams} no se jugará: %{n} %{n:pronóstico anulado|pronósticos anulados}."
    preds.exact     "{c:gold}pleno{/c} (+%{pts}): %{names}"
    preds.good      "{c:ok}acertaron el signo{/c}: %{names}"
    preds.zero      "%{n} fallaron"
    preds.leader    "{s:trophy} líder: {b}%{nick}{b} %{pts} pts"
    preds.settled   "{s:trophy} {b}Porra{b} %{score}:"
    preds.empty     "Aún no hay pronósticos resueltos. ¡Prueba %{cmd}!"
    preds.you       "tú: #%{pos} %{pts} pts (%{ex} plenos, %{n} %{n:pronóstico|pronósticos})"
    preds.ranking   "Clasificación de la porra (%{period}):"
    preds.mine_none "No tienes pronósticos abiertos. Prueba %{cmd} <equipo> 2-1"
    preds.mine      "Tus pronósticos abiertos"
    preds.hidden    "%{teams}: %{n} %{n:pronóstico|pronósticos} (se revelan al empezar)."
    preds.match_none "No hay pronósticos abiertos para %{team}."
    preds.reset     "Clasificación archivada y reiniciada."
    preds.featured  "{c:gold}{s:star}{/c} ¡%{teams} es partido destacado: puntos x%{mult}!"
    preds.open_none "No hay partidos para pronosticar en las próximas 48h."
    preds.open_header "{s:trophy} {b}Abiertos para la porra{b} (%{cmd} <equipo> 2-1):"
    period.week     "últimos 7 días"
    period.month    "últimos 30 días"
    period.season   "temporada"
    period.all      "histórico"

    cfg.set       "{s:win} {b}%{key}{b} = %{value}"
    cfg.needchan  "¿Qué canal? Úsalo en el canal o indica #canal."
    follow.ok     "{s:win} Siguiendo a {b}%{what}{b}. Recibirás avisos por privado; ajústalos con %{cmd}."
    follow.already "Ya sigues a %{what}."
    follow.limit  "Puedes seguir hasta %{n} cosas."
    unfollow.all  "Ya no sigues nada."
    unfollow.notfound "No sigues nada que coincida con '%{query}'."
    unfollow.ok   "Has dejado de seguir a %{what}."
    follows.none  "Aún no sigues nada. Prueba %{cmd} <equipo>."
    follows.header "Sigues a"
    follows.kind.team   "equipo"
    follows.kind.league "competición"
    follows.kind.player "jugador"
    follows.kind.match  "partido"
    prefs.header  "Tus preferencias"
    prefs.hint    "Cámbialas con %{cmd} <nombre> <valor> (p.ej. ajustar events goals,reds,ft · ajustar quiet 23:00-08:00 · ajustar tz Europe/Madrid)"
    set.badlang   "Idioma desconocido. Disponibles: %{langs}"
    set.badtz     "Zona horaria desconocida. Usa Región/Ciudad, p.ej. Europe/Madrid, America/Mexico_City, America/Argentina/Buenos_Aires."
    set.badvalue  "Valor no válido para %{key}. Válidos: %{values}"
    set.unknown   "Ajuste '%{key}' desconocido. Válidos: %{keys}"
    lang.list     "Idiomas: %{langs}. Usa %{cmd} <código>."
    tz.current    "Tu zona horaria: %{tz} (ahora son las %{time})."
}

::md::i18n::vary es {
    narr.intro {
        "{s:mic} ¡Buenas! Muy pronto: {b}%{teams}{b} en %{league}, a las %{time}."
        "{s:mic} Estamos conectados para el {b}%{teams}{b} (%{league}). Pitido inicial a las %{time}. ¡No se vayan!"
        "{s:mic} Todo listo para el {b}%{teams}{b}. %{league}, %{time}."
    }
    narr.join {
        "Conectamos en el minuto {c:minute}%{min}{/c}: %{score}%{scorers}"
        "Nos unimos al partido en el {c:minute}%{min}{/c} — %{score}%{scorers}"
    }
    narr.kickoff {
        "{s:start} {c:start}{b}¡Rueda el balón!{b}{/c} Comienza el %{home} - %{away}."
        "{s:start} {c:start}{b}¡Arranca el partido!{b}{/c} %{home} contra %{away}."
        "{s:start} {c:start}{b}¡Pitido inicial!{b}{/c} Ya se juega el %{home} - %{away}."
    }
    narr.goal.goal {
        "{s:goal} {c:goal}{b}¡GOOOOL!{b}{/c} {c:minute}%{min}{/c} ¡Marca {b}%{player}{b} para el %{team}! %{score}%{assist}"
        "{s:goal} {c:goal}{b}¡GOL, GOL, GOL!{b}{/c} %{player} la manda a la red ({c:minute}%{min}{/c}). %{score}%{assist}"
        "{s:goal} {c:goal}{b}¡GOOOL del %{team}!{b}{/c} %{player} no perdona en el {c:minute}%{min}{/c}. %{score}%{assist}"
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} ¡Adentro! %{player} bate al portero en el {c:minute}%{min}{/c}. %{score}%{assist}"
    }
    narr.goal.first {
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} ¡Se rompe el empate! %{player} adelanta al %{team} en el {c:minute}%{min}{/c}. %{score}%{assist}"
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} Abre la lata %{player} para el %{team} ({c:minute}%{min}{/c}). %{score}%{assist}"
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} ¡Primer gol del partido! %{player}, {c:minute}%{min}{/c}. %{score}%{assist}"
    }
    narr.goal.lead {
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} ¡El %{team} vuelve a ponerse por delante! %{player}, {c:minute}%{min}{/c}. %{score}%{assist}"
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} %{player} devuelve la ventaja al %{team} ({c:minute}%{min}{/c}). %{score}%{assist}"
    }
    narr.goal.equaliser {
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} {c:hl}¡Empate!{/c} %{player} iguala para el %{team} en el {c:minute}%{min}{/c}. %{score}%{assist}"
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} ¡Todo igualado! %{player} pone las tablas ({c:minute}%{min}{/c}). %{score}%{assist}"
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} ¡El %{team} empata gracias a %{player}! {c:minute}%{min}{/c} %{score}%{assist}"
    }
    narr.goal.comeback {
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} {c:hl}¡REMONTADA!{/c} %{player} le da la vuelta al marcador para el %{team} ({c:minute}%{min}{/c}). %{score}%{assist}"
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} ¡El %{team} iba perdiendo y ahora gana! %{player}, {c:minute}%{min}{/c}. %{score}%{assist}"
    }
    narr.goal.latewinner {
        "{s:goal} {c:goal}{b}¡GOOOOOL!{b}{/c} {c:hl}¡EN EL ÚLTIMO SUSPIRO!{/c} %{player} en el {c:minute}%{min}{/c}. %{score}%{assist}"
        "{s:goal} {c:goal}{b}¡GOOOOOL!{b}{/c} {c:hl}¡Agónico!{/c} %{player} puede haber dado la victoria al %{team} ({c:minute}%{min}{/c}). %{score}%{assist}"
    }
    narr.goal.brace {
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} ¡Otra vez %{player}! {c:hl}Doblete{/c} ({c:minute}%{min}{/c}). %{score}%{assist}"
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} ¡Segundo de la cuenta de %{player}! {c:minute}%{min}{/c} %{score}%{assist}"
    }
    narr.goal.hattrick {
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} {c:hl}{s:star} ¡HAT-TRICK de %{player}!{/c} ({c:minute}%{min}{/c}) %{score}%{assist}"
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} ¡Tres! {c:hl}%{player} se lleva el balón a casa{/c} ({c:minute}%{min}{/c}). %{score}%{assist}"
    }
    narr.goal.pen {
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} %{player} no falla desde los once metros ({c:minute}%{min}{/c}). %{score}"
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} Penalti transformado por %{player}, {c:minute}%{min}{/c}. %{score}"
    }
    narr.goal.og {
        "{s:goal} {c:goal}{b}¡GOL EN PROPIA!{b}{/c} Desgracia para el %{opp}: %{player} la mete en su portería ({c:minute}%{min}{/c}). %{score}"
        "{s:goal} {c:goal}{b}¡AUTOGOL!{b}{/c} El %{team} se beneficia del error de %{player} en el {c:minute}%{min}{/c}. %{score}"
    }
    narr.goal.rout {
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} ¡%{player} hace otro! Esto es una goleada ({c:minute}%{min}{/c}). %{score}%{assist}"
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} El %{team} está en modo apisonadora — %{player}, {c:minute}%{min}{/c}. %{score}%{assist}"
    }
    narr.goal.consolation {
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} %{player} recorta distancias para el %{team} ({c:minute}%{min}{/c}). ¿Hay partido? %{score}%{assist}"
        "{s:goal} {c:goal}{b}¡GOOOL!{b}{/c} El %{team} se acerca gracias a %{player}, {c:minute}%{min}{/c}. %{score}%{assist}"
    }
    narr.yellow {
        "{s:yellow} {c:minute}%{min}{/c} Amarilla para %{player} (%{team})."
        "{s:yellow} {c:minute}%{min}{/c} El árbitro amonesta a %{player} del %{team}."
        "{s:yellow} {c:minute}%{min}{/c} Tarjeta amarilla: %{player}."
    }
    narr.yred {
        "{s:yred} {c:minute}%{min}{/c} {c:red}{b}¡Segunda amarilla!{b}{/c} %{player} se va a la calle; el %{team} se queda con diez."
        "{s:yred} {c:minute}%{min}{/c} {c:red}{b}¡A la ducha!{b}{/c} Doble amarilla para %{player} (%{team})."
    }
    narr.red {
        "{s:red} {c:minute}%{min}{/c} {c:red}{b}¡ROJA DIRECTA!{b}{/c} ¡Expulsado %{player}! El %{team} jugará con diez."
        "{s:red} {c:minute}%{min}{/c} {c:red}{b}¡EXPULSIÓN!{b}{/c} %{player} (%{team}) ve la roja."
    }
    narr.sub {
        "{s:sub} {c:minute}%{min}{/c} Cambio en el %{team}: entra %{pin}, sale %{pout}."
        "{s:sub} {c:minute}%{min}{/c} Mueve el banquillo el %{team} — %{pin} por %{pout}."
    }
    narr.penmiss {
        "{s:pen} {c:minute}%{min}{/c} {c:hl}¡PENALTI FALLADO!{/c} %{player} (%{team}) no acierta desde los once metros."
        "{s:pen} {c:minute}%{min}{/c} {c:hl}¡Fuera!{/c} %{player} desperdicia el penalti."
    }
    narr.pensaved {
        "{s:pen} {c:minute}%{min}{/c} {c:hl}¡PARADÓN!{/c} ¡El portero le detiene el penalti a %{player}!"
        "{s:pen} {c:minute}%{min}{/c} {c:hl}¡Penalti parado!{/c} A %{player} (%{team}) se lo adivinan."
    }
    narr.save {
        "{s:chance} {c:minute}%{min}{/c} ¡Ocasión del %{team}! Dispara %{player}... ¡y para %{keeper}!"
        "{s:chance} {c:minute}%{min}{/c} %{player} pone a prueba a %{keeper}, que responde bien."
        "{s:chance} {c:minute}%{min}{/c} ¡Paradón de %{keeper} a disparo de %{player}!"
    }
    narr.shot {
        "{s:chance} {c:minute}%{min}{/c} %{player} (%{team}) obliga a intervenir al portero."
        "{s:chance} {c:minute}%{min}{/c} Disparo a puerta de %{player}, pero no entra."
    }
    narr.woodwork {
        "{s:chance} {c:minute}%{min}{/c} {c:hl}¡AL PALO!{/c} ¡%{player} estrella el balón en la madera!"
        "{s:chance} {c:minute}%{min}{/c} {c:hl}¡Larguero!{/c} Cerquísima el %{team} — %{player}."
        "{s:chance} {c:minute}%{min}{/c} {c:hl}¡Uyyy, el poste!{/c} %{player} se queda a centímetros."
    }
    narr.miss {
        "{s:chance} {c:minute}%{min}{/c} %{player} lo intenta para el %{team}, pero se marcha rozando el palo."
        "{s:chance} {c:minute}%{min}{/c} ¡Uy! %{player} la manda fuera por muy poco."
    }
    narr.corner {
        "{c:minute}%{min}{/c} Córner para el %{team}."
        "{c:minute}%{min}{/c} Saque de esquina a favor del %{team}."
    }
    narr.added {
        "{s:clock} Tiempo añadido: {b}+%{n}'{b}."
        "{s:clock} El cuarto árbitro levanta el cartel: {b}+%{n}{b}."
    }
    narr.ht {
        "{s:ht} {c:ht}{b}¡Descanso!{b}{/c} %{score}%{scorers}"
        "{s:ht} {c:ht}{b}Se llega al descanso.{b}{/c} %{score}%{scorers}"
    }
    narr.2h {
        "{s:start} {c:start}¡Arranca la segunda parte!{/c} %{score}"
        "{s:start} {c:start}Vuelve a rodar el balón en la segunda mitad.{/c} %{score}"
    }
    narr.end90 {
        "{s:ht} Se cumplen los 90 minutos: %{score}."
    }
    narr.et {
        "{s:start} {c:hl}¡Comienza la prórroga!{/c} %{score}"
    }
    narr.shootout {
        "{s:pen} {c:pen}{b}¡Nos vamos a los PENALTIS!{b}{/c} %{score}"
        "{s:pen} {c:pen}{b}¡Tanda de penaltis!{b}{/c} Corazones en un puño. %{score}"
    }
    narr.so.scored {
        "{s:pen} %{player} (%{team}) {c:ok}marca{/c}."
        "{s:pen} %{player} (%{team}) {c:ok}✔ dentro{/c}."
    }
    narr.so.missed {
        "{s:pen} %{player} (%{team}) {c:err}¡falla!{/c}"
        "{s:pen} %{player} (%{team}) {c:err}✖ ¡parado o fuera!{/c}"
    }
    narr.update {
        "{c:dim}{s:clock}{/c} {c:minute}%{min}{/c} %{score} {c:dim}%{poss}{/c}"
        "{c:dim}{s:clock}{/c} Minuto {c:minute}%{min}{/c}, seguimos con %{score}. {c:dim}%{poss}{/c}"
    }
    narr.pressure {
        "{s:chance} ¡El %{team} aprieta! %{n} disparos en cinco minutos."
        "{s:chance} Asedio del %{team}: %{n} intentos en los últimos cinco minutos."
    }
    narr.tension.draw {
        "{s:clock} Últimos minutos y todo igualado: %{score}. ¿Quién parpadeará primero?"
        "{s:clock} Nervios a flor de piel — %{score} entrando en los cinco minutos finales."
    }
    narr.tension.close {
        "{s:clock} Últimos minutos: el %{team} defiende con uñas y dientes su ventaja. %{score}"
        "{s:clock} Cinco minutos para el final y el %{team} ya acaricia la victoria. %{score}"
    }
    narr.var {
        "{s:var} {c:minute}%{min}{/c} {c:var}Revisión del VAR...{/c} %{text}"
    }
    narr.delay {
        "{c:minute}%{min}{/c} El juego está detenido."
    }
    narr.ft.win {
        "{s:ft} {c:ft}{b}¡FINAL DEL PARTIDO!{b}{/c} %{score} — ¡victoria del {b}%{winner}{b}!"
        "{s:ft} {c:ft}{b}¡Se acabó!{b}{/c} Los tres puntos para el %{winner}. %{score}"
        "{s:ft} {c:ft}{b}¡Pitido final!{b}{/c} %{score}. Noche para recordar en el %{winner}."
    }
    narr.ft.draw {
        "{s:ft} {c:ft}{b}¡FINAL!{b}{/c} Reparto de puntos: %{score}."
        "{s:ft} {c:ft}{b}Se acabó con tablas.{b}{/c} %{score}"
    }
    narr.ft.pens {
        "{s:ft} {c:ft}{b}¡SE ACABÓ!{b}{/c} %{score} — ¡el {b}%{winner}{b} gana %{so} en los penaltis!"
    }
}

# --- players, probabilities, hot matches, videos
::md::i18n::cmds es { player {jugador} prob {probabilidad cuotas} }

::md::i18n::msgs es {
    player.notfound    "No encuentro ningún jugador llamado '%{query}'."
    player.age         "%{n} años"
    player.goals       "%{n} %{n:gol|goles}"
    player.assists     "%{n} %{n:asistencia|asistencias}"
    player.starts      "%{n} %{n:titularidad|titularidades}"
    player.shots       "%{n} %{n:tiro|tiros} (%{s} a puerta)"
    player.cleansheets "%{n} %{n:portería a cero|porterías a cero}"
    player.last        "Últimos %{n}: %{goals} G, %{assists} A"
    player.next        "Próximo: %{name} (%{when}, %{league})"
    player.also        "También: %{list}"
    prob.draw          "empate"
    prob.model         "Probabilidad"
    prob.odds          "Cuotas previas"
    prob.espn          "Probabilidad (ESPN)"
    prob.prior         "Probabilidad (sin cuotas)"
    prob.none          "No hay probabilidad disponible para %{teams}."
    hot.flurry         "{s:hot} {c:hl}{b}¡Partido caliente!{b}{/c} %{n} goles en %{mins} minutos: %{score} {c:minute}%{min}{/c} %{league}"
    hot.goalfest       "{s:hot} {c:hl}{b}¡Festival de goles!{b}{/c} ya van %{n} goles: %{score} {c:minute}%{min}{/c} %{league}"
    hot.comeback       "{s:hot} {c:hl}{b}¡Remontada en marcha!{b}{/c} el %{team} perdía por dos: %{score} {c:minute}%{min}{/c} %{league}"
    hot.upset          "{s:hot} {c:hl}{b}¡Sorpresa en curso!{b}{/c} gana el %{team} (%{pct}% antes del partido): %{score} {c:minute}%{min}{/c} %{league}"
    hot.shock          "{s:hot} {c:hl}{b}¡Campanada!{b}{/c} gana el %{team} (%{pct}% antes del partido): %{score} %{league}"
    ev.video           "{s:tv} {c:info}Vídeo:{/c} %{teams} {c:dim}—{/c} %{headline}%{dur} %{url}"
    help.player        "<nombre> — ficha y estadísticas de la temporada"
    help.prob          "<equipo> — probabilidad de victoria (modelo en vivo / cuotas)"
}
