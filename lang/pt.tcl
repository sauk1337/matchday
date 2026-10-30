# Matchday - Português

::md::i18n::lang pt Portuguese Português

::md::i18n::cmds pt {
    help     {ajuda}
    live     {aovivo direto}
    today    {hoje placar placares}
    match    {jogo}
    next     {proximos agenda}
    last     {ultimos}
    table    {tabela classificacao}
    scorers  {artilheiros artilharia}
    lineup   {escalacao escalacoes}
    stats    {estatisticas}
    form     {forma}
    h2h      {confronto retrospecto}
    leagues  {ligas campeonatos}
    narrate  {narrar}
    follow   {seguir}
    unfollow {deixar}
    follows  {seguindo meustimes}
    prefs    {preferencias}
    set      {definir}
    lang     {idioma}
    tz       {fuso}
    predict  {palpite palpitar}
    preds    {palpites meuspalpites}
    porra    {bolao}
    ranking  {rankingbolao}
    more     {mais}
    about    {sobre}
    mdset    {configurar}
}

::md::i18n::msgs pt {
    more.hint        "{c:dim}(mais %{n} linhas: %{cmd}){/c}"
    more.none        "Não há mais nada para mostrar."
    word.tomorrow    "Amanhã"
    word.referee     "Árbitro"
    form.W "V" form.D "E" form.L "D"
    word.form        "Forma"
    word.bench       "Banco"
    days.short       {- Seg Ter Qua Qui Sex Sáb Dom}

    st.ht "Int" st.ft "Fim" st.aet "Prorr" st.pens "Pên" st.ppd "Adiado" st.canc "Canc"
    st.aban "Aband" st.susp "Susp" st.delay "Atrasado" st.shootout "Pênaltis" st.live "AO VIVO"

    tag.pen     " (pên)"
    tag.og      " (contra)"
    tag.assist  "assist.: %{name}"

    ctx.poker      "Quatro de %{player}!"
    ctx.hattrick   "Hat-trick de %{player}!"
    ctx.comeback   "Virada!"
    ctx.equaliser  "Empate!"
    ctx.brace      "Doblete de %{player}!"
    ctx.latewinner "Gol no fim!"
    ctx.lead       "Volta à frente!"

    period.half    "o %{n}º tempo"
    period.q       "o %{n}º quarto"
    period.p       "o %{n}º período"
    period.ot      "a prorrogação %{n}"
    period.inning  "a entrada %{n}"

    ev.goal        "{s:goal} {c:goal}{b}GOL!{b}{/c} %{score}%{who}%{ctx} %{league}"
    ev.scorer      "{s:goal} Autor do gol: %{player} %{min} (%{team}) {c:dim}—{/c} %{score} %{league}"
    ev.disallowed  "{s:var} {c:var}{b}Gol anulado{b}{/c} do %{team}! %{score} %{league}"
    ev.card.yellow "{s:yellow} Amarelo: %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.card.yred   "{s:yred} {c:red}{b}Expulso!{b}{/c} Segundo amarelo para %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.card.red    "{s:red} {c:red}{b}VERMELHO DIRETO!{b}{/c} %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.penmiss     "{s:pen} Pênalti perdido por %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.kickoff     "{s:start} {c:start}Começa:{/c} %{teams} %{league}"
    ev.start       "{s:start} {c:start}Começou:{/c} %{teams} %{league}"
    ev.race_start  "{s:race} {c:start}Em andamento:{/c} %{name} %{league}"
    ev.race_end    "{s:ft} {c:ft}Terminou:{/c} %{name} — {s:trophy} %{podium} %{league}"
    ev.ht          "{s:ht} {c:ht}Intervalo:{/c} %{score}%{scorers} %{league}"
    ev.2h          "{s:start} Começa o segundo tempo: %{score} %{league}"
    ev.et          "{s:start} {c:hl}Prorrogação!{/c} %{score} %{league}"
    ev.shootout    "{s:pen} {c:pen}{b}Disputa de pênaltis!{b}{/c} %{score} %{league}"
    ev.ft          "{s:ft} {c:ft}Fim de jogo:{/c} %{score}%{scorers} %{league}"
    ev.ft.aet      "{s:ft} {c:ft}Fim (após prorrogação):{/c} %{score}%{scorers} %{league}"
    ev.ft.pens     "{s:ft} {c:ft}Fim de jogo:{/c} %{score} — {b}%{winner}{b} vence %{so} nos pênaltis %{league}"
    ev.ft.duel     "{s:ft} {c:ft}Final:{/c} %{score} — vitória de {b}%{winner}{b} %{league}"
    ev.postponed   "{s:flag} {c:warn}Adiado:{/c} %{teams} %{league}"
    ev.cancelled   "{s:flag} {c:warn}Cancelado:{/c} %{teams} %{league}"
    ev.abandoned   "{s:flag} {c:warn}Abandonado:{/c} %{score} %{league}"
    ev.suspended   "{s:flag} {c:warn}Interrompido:{/c} %{score} %{league}"
    ev.delayed     "{s:flag} {c:warn}Atrasado:{/c} %{teams} %{league}"
    ev.resumed     "{s:start} Reiniciado: %{score} %{league}"
    ev.score       "{s:goal} {c:goal}%{label}{/c} %{team}: %{score} {c:dim}(%{detail}){/c} %{league}"
    ev.period_end  "{s:ht} Fim d%{period}: %{score} %{league}"
    ev.ot          "{s:clock} {c:hl}Prorrogação!{/c} %{score} %{league}"
    ev.close       "{s:clock} {c:hl}Jogo apertado!{/c} Faltam %{left} n%{period}: %{score} %{league}"
    ev.set         "{s:dot} Set %{n} para {b}%{player}{b} (%{games}) — %{score} %{league}"
    ev.leader      "{s:race} Novo líder em %{name}: {b}%{driver}{b} (à frente de %{prev}) %{league}"
    ev.reminder    "{s:clock} Começa em %{mins} min: {b}%{teams}{b} (%{time}) %{league}%{tv}"

    score.goal "Gol" score.runs "Corrida(s) +%{n}" score.try "Try" score.penalty "Pênalti" score.points "+%{n}"

    err.perm            "Você não tem permissão para isso."
    err.internal        "Algo deu errado, desculpe. O erro foi registrado."
    err.usage           "Uso: {b}%{cmd}{b} %{usage}"
    err.ambiguous       "'%{query}' corresponde a vários times: %{options} — seja mais específico."
    err.team_notfound   "Não encontrei nenhum time chamado '%{query}'."
    err.league_notfound "Competição desconhecida: '%{query}'. Tente !ligas."
    err.nodata          "Ainda não há dados para isso."
    err.provider        "O provedor de dados não responde agora. Tente de novo em um minuto."

    live.none       "Nenhum jogo ao vivo agora."
    live.none_next  "Nada ao vivo. Próximo: %{next}"
    live.team_none  "%{team} não está jogando agora. Tente %{cmd}."
    today.none      "Nenhum jogo em %{date} nessas competições."
    team.no_match_day "%{team} não joga nesse dia."
    team.no_match   "Nenhum jogo recente ou próximo encontrado para %{team}."
    digest.chan     "{s:clock} {b}Jogos de hoje{b} (%{n}):"
    digest.none     "Seu resumo diário: nenhum dos seus times/competições joga hoje."
    digest.header   "{s:clock} {b}Seus jogos de hoje{b} (%{n}):"
    missed.header   "{s:dot} Bem-vindo de volta! Resultados que você perdeu (%{n}):"

    stat.possession "Posse" stat.shots "Chutes(gol)" stat.on_target "No gol" stat.corners "Escanteios"
    stat.fouls "Faltas" stat.yellows "Amarelos" stat.reds "Vermelhos" stat.offsides "Impedimentos"
    stat.saves "Defesas" stat.passes "Passes" stat.pass_pct "% passe"
    lineup.none     "As escalações de %{teams} ainda não saíram (~1h antes)."
    stats.notyet    "%{teams} ainda não começou."

    next.none   "Nenhum próximo jogo encontrado para %{what}."
    last.none   "Nenhum resultado recente encontrado para %{what}."
    table.none  "Sem classificação disponível para %{league}."
    table.sent_priv "Enviei os detalhes no privado."
    table.row   "{c:rank}%{rank}.{/c}%{team} {c:dim}J%{gp} V%{w} E%{d} D%{l} SG%{gd}{/c} {b}%{pts}{b}"
    scorers.soccer_only "Artilheiros só estão disponíveis para futebol."
    scorers.title   "Artilheiros %{league}:"
    scorers.assists "Garçons %{league}:"
    h2h.none   "Nenhum confronto recente entre %{a} e %{b}."
    h2h.title  "{b}%{a} x %{b}{b} ({c:win}%{w}V{/c} {c:draw}%{d}E{/c} {c:loss}%{l}D{/c}):"

    sport.soccer "Futebol" sport.basketball "Basquete" sport.football "Futebol americano" sport.hockey "Hóquei no gelo"
    sport.baseball "Beisebol" sport.racing "Automobilismo" sport.tennis "Tênis" sport.mma "MMA" sport.golf "Golfe"
    sport.rugby "Rúgbi" sport.australian-football "Futebol australiano"
    leagues.summary  "Competições: %{sports}. Busque com %{cmd} <nome|esporte>."

    help.group.info "Placar e informação"
    help.group.mine "Pessoal"
    help.group.fun  "Narração e bolão"
    help.footer     "Detalhes: %{cmd} <comando>. Os comandos também funcionam no privado."
    help.aliases    "Também funciona como"
    help.live     "\[liga|esporte|time\] — jogos ao vivo"
    help.today    "\[liga|esporte|time\] \[data\] — jogos do dia (hoje, amanhã, 25/12...)"
    help.match    "<time> — jogo atual/último em detalhe"
    help.next     "<time|liga> — próximos jogos"
    help.last     "<time|liga> — últimos resultados"
    help.table    "<liga|time> \[grupo\] \[completa\] — classificação"
    help.scorers  "<liga> — artilheiros"
    help.lineup   "<time> — escalações"
    help.stats    "<time> — estatísticas"
    help.form     "<time> — últimos 5 resultados"
    help.h2h      "<time> x <time> — confronto direto"
    help.narrate  "<time> \[completa|normal|breve\] | off | lista — narração ao vivo"
    help.follow   "<time> | liga <nome> | jogador <nome> — avisos no privado"
    help.predict  "<time> <gols>-<gols> — dê seu palpite (fecha no início)"
    help.ranking  "\[semana|mes|temporada|tudo\] — ranking do bolão"

    narr.stopped    "Fim da narração de %{teams}."
    narr.none       "Nenhuma narração em andamento aqui."
    narr.limit      "Limite de narrações atingido (%{n})."
    narr.nomatch    "%{team} não joga agora nem nas próximas %{hours}h."
    narr.already    "Já estou narrando %{teams} aqui."
    narr.started    "{s:mic} Narração #%{id}: {b}%{teams}{b} (%{style}, %{when}). Para parar: %{cmd}"
    narr.style.full "completa" narr.style.normal "normal" narr.style.brief "breve"
    narr.assist     " {c:dim}(assistência de %{name}){/c}"
    narr.lineups_in "{b}Saíram as escalações!{b}"
    narr.form       "Forma — %{home}: %{hf} · %{away}: %{af}"
    narr.poss       "posse %{home} %{ph}% – %{pa}% %{away}"
    narr.join_generic "Entramos em %{league}: %{score} {c:dim}(%{detail}){/c}"
    narr.signoff    "{c:dim}Fim da transmissão. Obrigado pela companhia!{/c}"
    replay.banner   "REPRISE x%{speed}: %{teams} (jogo gravado, não é ao vivo)"

    preds.noscope   "De qual canal é o bolão? Use %{cmd} #canal ... ou defina: definir home #canal"
    preds.disabled  "O bolão está desativado nesse canal."
    preds.nomatch   "%{team} não tem jogo para palpitar nos próximos %{days} dias."
    preds.saved     "{s:win} Palpite salvo: %{pred} {c:dim}(%{when}, %{league}){/c}"
    preds.updated   "{s:win} Palpite atualizado: %{pred} {c:dim}(%{when}, %{league}){/c}"
    preds.void      "{s:flag} %{teams} não será disputado: %{n} %{n:palpite anulado|palpites anulados}."
    preds.exact     "{c:gold}na mosca{/c} (+%{pts}): %{names}"
    preds.good      "{c:ok}acertaram o resultado{/c}: %{names}"
    preds.zero      "%{n} erraram"
    preds.leader    "{s:trophy} líder: {b}%{nick}{b} %{pts} pts"
    preds.settled   "{s:trophy} {b}Bolão{b} %{score}:"
    preds.empty     "Ainda não há palpites apurados. Tente %{cmd}!"
    preds.you       "você: #%{pos} %{pts} pts (%{ex} na mosca, %{n} %{n:palpite|palpites})"
    preds.ranking   "Ranking do bolão (%{period}):"
    preds.mine_none "Você não tem palpites abertos. Tente %{cmd} <time> 2-1"
    preds.mine      "Seus palpites abertos"
    preds.hidden    "%{teams}: %{n} %{n:palpite|palpites} (revelados no início)."
    preds.featured  "{c:gold}{s:star}{/c} %{teams} é jogo em destaque: pontos x%{mult}!"
    preds.open_none "Nenhum jogo para palpitar nas próximas 48h."
    preds.open_header "{s:trophy} {b}Abertos para palpite{b} (%{cmd} <time> 2-1):"
    period.week "últimos 7 dias" period.month "últimos 30 dias" period.season "temporada" period.all "geral"

    cfg.needchan  "Qual canal? Use no canal ou informe #canal."
    follow.ok     "{s:win} Seguindo {b}%{what}{b}. Você receberá avisos no privado; ajuste com %{cmd}."
    follow.already "Você já segue %{what}."
    follow.limit  "Você pode seguir até %{n} itens."
    unfollow.all  "Você não segue mais nada."
    unfollow.notfound "Você não segue nada parecido com '%{query}'."
    unfollow.ok   "Você deixou de seguir %{what}."
    follows.none  "Você ainda não segue nada. Tente %{cmd} <time>."
    follows.header "Você segue"
    follows.kind.team "time" follows.kind.league "competição" follows.kind.player "jogador" follows.kind.match "jogo"
    prefs.header  "Suas preferências"
    prefs.hint    "Altere com %{cmd} <nome> <valor> (ex.: definir quiet 23:00-08:00 · definir tz America/Sao_Paulo)"
    set.badlang   "Idioma desconhecido. Disponíveis: %{langs}"
    set.badtz     "Fuso horário desconhecido. Use Região/Cidade, ex.: America/Sao_Paulo, Europe/Lisbon."
    set.badvalue  "Valor inválido para %{key}. Válidos: %{values}"
    set.unknown   "Ajuste '%{key}' desconhecido. Válidos: %{keys}"
    lang.list     "Idiomas: %{langs}. Use %{cmd} <código>."
    tz.current    "Seu fuso: %{tz} (agora %{time})."
}

::md::i18n::vary pt {
    narr.intro {
        "{s:mic} Boa noite! Daqui a pouco: {b}%{teams}{b} pelo %{league}, às %{time}."
        "{s:mic} Estamos no ar para {b}%{teams}{b} (%{league}), bola rolando às %{time}."
    }
    narr.join {
        "Entramos no jogo aos {c:minute}%{min}{/c}: %{score}%{scorers}"
    }
    narr.kickoff {
        "{s:start} {c:start}{b}Bola rolando!{b}{/c} Começa %{home} x %{away}."
        "{s:start} {c:start}{b}Apita o árbitro!{b}{/c} %{home} e %{away} já estão em campo."
    }
    narr.goal.goal {
        "{s:goal} {c:goal}{b}GOOOOL!{b}{/c} {c:minute}%{min}{/c} {b}%{player}{b} marca para o %{team}! %{score}%{assist}"
        "{s:goal} {c:goal}{b}É GOL!{b}{/c} %{player} balança a rede aos {c:minute}%{min}{/c}. %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOOOL do %{team}!{b}{/c} %{player}, {c:minute}%{min}{/c}. %{score}%{assist}"
    }
    narr.goal.first {
        "{s:goal} {c:goal}{b}GOOOL!{b}{/c} %{player} abre o placar para o %{team} ({c:minute}%{min}{/c}). %{score}%{assist}"
    }
    narr.goal.equaliser {
        "{s:goal} {c:goal}{b}GOOOL!{b}{/c} {c:hl}Tudo igual!{/c} %{player} empata para o %{team} ({c:minute}%{min}{/c}). %{score}%{assist}"
    }
    narr.goal.comeback {
        "{s:goal} {c:goal}{b}GOOOL!{b}{/c} {c:hl}É A VIRADA!{/c} %{player} coloca o %{team} na frente ({c:minute}%{min}{/c}). %{score}%{assist}"
    }
    narr.goal.latewinner {
        "{s:goal} {c:goal}{b}GOOOOOL!{b}{/c} {c:hl}No apagar das luzes!{/c} %{player}, {c:minute}%{min}{/c}. %{score}%{assist}"
    }
    narr.goal.brace {
        "{s:goal} {c:goal}{b}GOOOL!{b}{/c} De novo %{player}! {c:hl}Doblete{/c} ({c:minute}%{min}{/c}). %{score}%{assist}"
    }
    narr.goal.hattrick {
        "{s:goal} {c:goal}{b}GOOOL!{b}{/c} {c:hl}{s:star} HAT-TRICK de %{player}!{/c} ({c:minute}%{min}{/c}) %{score}%{assist}"
    }
    narr.goal.pen {
        "{s:goal} {c:goal}{b}GOOOL!{b}{/c} %{player} converte o pênalti ({c:minute}%{min}{/c}). %{score}"
    }
    narr.goal.og {
        "{s:goal} {c:goal}{b}GOL CONTRA!{b}{/c} %{player} manda para a própria rede ({c:minute}%{min}{/c}). %{score}"
    }
    narr.goal.rout {
        "{s:goal} {c:goal}{b}GOOOL!{b}{/c} %{player} amplia! É goleada ({c:minute}%{min}{/c}). %{score}%{assist}"
    }
    narr.goal.consolation {
        "{s:goal} {c:goal}{b}GOOOL!{b}{/c} %{player} diminui para o %{team} ({c:minute}%{min}{/c}). %{score}%{assist}"
    }
    narr.yellow {
        "{s:yellow} {c:minute}%{min}{/c} Amarelo para %{player} (%{team})."
        "{s:yellow} {c:minute}%{min}{/c} %{player} é advertido."
    }
    narr.yred {
        "{s:yred} {c:minute}%{min}{/c} {c:red}{b}Segundo amarelo!{b}{/c} %{player} está fora; %{team} com dez."
    }
    narr.red {
        "{s:red} {c:minute}%{min}{/c} {c:red}{b}VERMELHO DIRETO!{b}{/c} %{player} (%{team}) expulso!"
    }
    narr.sub {
        "{s:sub} {c:minute}%{min}{/c} Substituição no %{team}: entra %{pin}, sai %{pout}."
    }
    narr.penmiss {
        "{s:pen} {c:minute}%{min}{/c} {c:hl}PERDEU!{/c} %{player} (%{team}) desperdiça o pênalti!"
    }
    narr.pensaved {
        "{s:pen} {c:minute}%{min}{/c} {c:hl}DEFENDEU!{/c} O goleiro pega o pênalti de %{player}!"
    }
    narr.save {
        "{s:chance} {c:minute}%{min}{/c} Chance do %{team}! %{player} chuta... e %{keeper} defende."
        "{s:chance} {c:minute}%{min}{/c} Grande defesa de %{keeper} no chute de %{player}!"
    }
    narr.shot {
        "{s:chance} {c:minute}%{min}{/c} %{player} (%{team}) obriga o goleiro a trabalhar."
    }
    narr.woodwork {
        "{s:chance} {c:minute}%{min}{/c} {c:hl}NA TRAVE!{/c} %{player} acerta o poste!"
        "{s:chance} {c:minute}%{min}{/c} {c:hl}No travessão!{/c} Quase do %{team} — %{player}."
    }
    narr.miss {
        "{s:chance} {c:minute}%{min}{/c} %{player} tenta, mas a bola sai raspando."
    }
    narr.corner { "{c:minute}%{min}{/c} Escanteio para o %{team}." }
    narr.added { "{s:clock} Acréscimos: {b}+%{n}'{b}." }
    narr.ht { "{s:ht} {c:ht}{b}Intervalo!{b}{/c} %{score}%{scorers}" }
    narr.2h { "{s:start} {c:start}Começa o segundo tempo!{/c} %{score}" }
    narr.end90 { "{s:ht} Terminam os 90 minutos: %{score}." }
    narr.et { "{s:start} {c:hl}Começa a prorrogação!{/c} %{score}" }
    narr.shootout { "{s:pen} {c:pen}{b}Vai para os PÊNALTIS!{b}{/c} %{score}" }
    narr.so.scored { "{s:pen} %{player} (%{team}) {c:ok}converte{/c}." }
    narr.so.missed { "{s:pen} %{player} (%{team}) {c:err}perde!{/c}" }
    narr.update { "{c:dim}{s:clock}{/c} {c:minute}%{min}{/c} %{score} {c:dim}%{poss}{/c}" }
    narr.pressure { "{s:chance} O %{team} pressiona: %{n} finalizações em cinco minutos!" }
    narr.tension.draw { "{s:clock} Minutos finais e tudo igual: %{score}." }
    narr.tension.close { "{s:clock} Minutos finais: o %{team} segura a vantagem. %{score}" }
    narr.var { "{s:var} {c:minute}%{min}{/c} {c:var}Checagem do VAR...{/c} %{text}" }
    narr.delay { "{c:minute}%{min}{/c} Jogo parado." }
    narr.ft.win {
        "{s:ft} {c:ft}{b}FIM DE JOGO!{b}{/c} %{score} — vitória do {b}%{winner}{b}!"
        "{s:ft} {c:ft}{b}Acabou!{b}{/c} %{winner} leva os três pontos. %{score}"
    }
    narr.ft.draw { "{s:ft} {c:ft}{b}FIM DE JOGO!{b}{/c} Empate: %{score}." }
    narr.ft.pens { "{s:ft} {c:ft}{b}ACABOU!{b}{/c} %{score} — {b}%{winner}{b} vence %{so} nos pênaltis!" }
}

# --- players, probabilities, hot matches, videos
::md::i18n::cmds pt { player {jogador} prob {probabilidade} }

::md::i18n::msgs pt {
    player.notfound    "Nenhum jogador encontrado para '%{query}'."
    player.age         "%{n} anos"
    player.goals       "%{n} %{n:gol|gols}"
    player.assists     "%{n} %{n:assistência|assistências}"
    player.starts      "%{n} %{n:jogo como titular|jogos como titular}"
    player.shots       "%{n} %{n:chute|chutes} (%{s} no gol)"
    player.cleansheets "%{n} %{n:jogo sem sofrer gol|jogos sem sofrer gol}"
    player.last        "Últimos %{n}: %{goals} G, %{assists} A"
    player.next        "Próximo: %{name} (%{when}, %{league})"
    player.also        "Também: %{list}"
    prob.draw          "empate"
    prob.model         "Probabilidade"
    prob.odds          "Odds pré-jogo"
    prob.espn          "Probabilidade (ESPN)"
    prob.prior         "Probabilidade (sem odds)"
    prob.none          "Sem probabilidade disponível para %{teams}."
    hot.flurry         "{s:hot} {c:hl}{b}Jogo pegando fogo!{b}{/c} %{n} gols em %{mins} minutos: %{score} {c:minute}%{min}{/c} %{league}"
    hot.goalfest       "{s:hot} {c:hl}{b}Chuva de gols!{b}{/c} já são %{n} gols: %{score} {c:minute}%{min}{/c} %{league}"
    hot.comeback       "{s:hot} {c:hl}{b}Virada em andamento!{b}{/c} o %{team} perdia por dois: %{score} {c:minute}%{min}{/c} %{league}"
    hot.upset          "{s:hot} {c:hl}{b}Zebra à vista!{b}{/c} o %{team} (%{pct}% antes do jogo) vence: %{score} {c:minute}%{min}{/c} %{league}"
    hot.shock          "{s:hot} {c:hl}{b}Zebra!{b}{/c} o %{team} (%{pct}% antes do jogo) venceu: %{score} %{league}"
    ev.video           "{s:tv} {c:info}Vídeo:{/c} %{teams} {c:dim}—{/c} %{headline}%{dur} %{url}"
    help.player        "<nome> — ficha e estatísticas da temporada"
    help.prob          "<time> — probabilidade de vitória"
}
