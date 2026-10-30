# Matchday - English (default / fallback language)

::md::i18n::lang en English English

::md::i18n::cmds en {
    help     {help commands}
    live     {live}
    today    {today scores results}
    match    {match game}
    next     {next fixtures}
    last     {last}
    table    {table standings}
    scorers  {scorers topscorers}
    lineup   {lineup lineups xi}
    stats    {stats}
    form     {form}
    h2h      {h2h vs}
    leagues  {leagues competitions}
    narrate  {narrate commentary}
    follow   {follow}
    unfollow {unfollow}
    follows  {follows myteams}
    prefs    {prefs settings}
    set      {set}
    lang     {lang language}
    tz       {tz timezone}
    predict  {predict bet}
    preds    {preds mypreds}
    porra    {porra pool}
    ranking  {ranking leaderboard}
    more     {more}
    about    {about version}
    mdset    {mdset chanset}
    admin    {md matchday}
}

::md::i18n::msgs en {
    more.hint        "{c:dim}(%{n} more lines: %{cmd}){/c}"
    more.none        "Nothing more to show."
    word.tomorrow    "Tomorrow"
    word.referee     "Referee"
    form.W "W" form.D "D" form.L "L"
    word.form        "Form"
    word.bench       "Bench"
    days.short       {- Mon Tue Wed Thu Fri Sat Sun}

    st.ht       "HT"
    st.ft       "FT"
    st.aet      "AET"
    st.pens     "Pens"
    st.ppd      "PPD"
    st.canc     "Canc"
    st.aban     "Aband"
    st.susp     "Susp"
    st.delay    "Delayed"
    st.shootout "Shootout"
    st.live     "LIVE"

    tag.pen     " (pen)"
    tag.og      " (o.g.)"
    tag.assist  "assist: %{name}"

    ctx.poker      "Four for %{player}!"
    ctx.hattrick   "Hat-trick for %{player}!"
    ctx.comeback   "What a comeback!"
    ctx.equaliser  "Equaliser!"
    ctx.brace      "Brace for %{player}!"
    ctx.latewinner "Late drama!"
    ctx.lead       "Back in front!"

    period.half    "half %{n}"
    period.q       "Q%{n}"
    period.p       "period %{n}"
    period.ot      "OT%{n}"
    period.inning  "inning %{n}"

    ev.goal        "{s:goal} {c:goal}{b}GOAL!{b}{/c} %{score}%{who}%{ctx} %{league}"
    ev.scorer      "{s:goal} Goal update: %{player} %{min} for %{team} {c:dim}—{/c} %{score} %{league}"
    ev.disallowed  "{s:var} {c:var}{b}Goal disallowed{b}{/c} for %{team}! %{score} %{league}"
    ev.card.yellow "{s:yellow} Yellow card: %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.card.yred   "{s:yred} {c:red}{b}Sent off!{b}{/c} Second yellow for %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.card.red    "{s:red} {c:red}{b}RED CARD!{b}{/c} %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.penmiss     "{s:pen} Penalty missed by %{player} (%{team}) {c:minute}%{min}{/c} {c:dim}—{/c} %{score} %{league}"
    ev.kickoff     "{s:start} {c:start}Kick-off:{/c} %{teams} %{league}"
    ev.start       "{s:start} {c:start}Underway:{/c} %{teams} %{league}"
    ev.race_start  "{s:race} {c:start}Underway:{/c} %{name} %{league}"
    ev.race_end    "{s:ft} {c:ft}Finished:{/c} %{name} — {s:trophy} %{podium} %{league}"
    ev.ht          "{s:ht} {c:ht}Half-time:{/c} %{score}%{scorers} %{league}"
    ev.2h          "{s:start} Second half underway: %{score} %{league}"
    ev.et          "{s:start} {c:hl}Extra time!{/c} %{score} %{league}"
    ev.shootout    "{s:pen} {c:pen}{b}Penalty shootout!{b}{/c} %{score} %{league}"
    ev.ft          "{s:ft} {c:ft}Full-time:{/c} %{score}%{scorers} %{league}"
    ev.ft.aet      "{s:ft} {c:ft}Full-time (after extra time):{/c} %{score}%{scorers} %{league}"
    ev.ft.pens     "{s:ft} {c:ft}Full-time:{/c} %{score} — {b}%{winner}{b} win %{so} on penalties %{league}"
    ev.ft.duel     "{s:ft} {c:ft}Final:{/c} %{score} — {b}%{winner}{b} wins %{league}"
    ev.postponed   "{s:flag} {c:warn}Postponed:{/c} %{teams} %{league}"
    ev.cancelled   "{s:flag} {c:warn}Cancelled:{/c} %{teams} %{league}"
    ev.abandoned   "{s:flag} {c:warn}Abandoned:{/c} %{score} %{league}"
    ev.suspended   "{s:flag} {c:warn}Suspended:{/c} %{score} %{league}"
    ev.delayed     "{s:flag} {c:warn}Delayed:{/c} %{teams} %{league}"
    ev.resumed     "{s:start} Resumed: %{score} %{league}"
    ev.score       "{s:goal} {c:goal}%{label}{/c} %{team}: %{score} {c:dim}(%{detail}){/c} %{league}"
    ev.period_end  "{s:ht} End of %{period}: %{score} %{league}"
    ev.ot          "{s:clock} {c:hl}Overtime!{/c} %{score} %{league}"
    ev.close       "{s:clock} {c:hl}Close game!{/c} %{left} left in %{period}: %{score} %{league}"
    ev.set         "{s:dot} Set %{n} to {b}%{player}{b} (%{games}) — %{score} %{league}"
    ev.leader      "{s:race} New leader in %{name}: {b}%{driver}{b} (ahead of %{prev}) %{league}"
    ev.reminder    "{s:clock} Starts in %{mins} min: {b}%{teams}{b} (%{time}) %{league}%{tv}"

    score.td       "Touchdown"
    score.fg       "Field goal"
    score.safety   "Safety"
    score.points   "+%{n}"
    score.goal     "Goal"
    score.runs     "Run(s) +%{n}"
    score.try      "Try"
    score.penalty  "Penalty"

    err.perm            "You don't have permission for that."
    err.internal        "Something went wrong, sorry. The error was logged."
    err.usage           "Usage: {b}%{cmd}{b} %{usage}"
    err.ambiguous       "'%{query}' matches several teams: %{options} — be more specific."
    err.team_notfound   "I couldn't find a team called '%{query}'."
    err.league_notfound "Unknown competition: '%{query}'. Try !leagues."
    err.nodata          "No data available for that yet."
    err.provider        "The data provider isn't answering right now. Try again in a minute."

    live.none       "No live matches right now."
    live.none_next  "Nothing live. Next up: %{next}"
    live.team_none  "%{team} isn't playing right now. Try %{cmd}."
    today.none      "No matches on %{date} in those competitions."
    team.no_match_day "%{team} doesn't play that day."
    team.no_match   "No recent or upcoming match found for %{team}."
    digest.chan     "{s:clock} {b}Today's matches{b} (%{n}):"
    digest.none     "Your daily digest: none of your teams/competitions play today."
    digest.header   "{s:clock} {b}Your matches today{b} (%{n}):"
    missed.header   "{s:dot} Welcome back! Results you missed (%{n}):"

    stat.possession "Poss"
    stat.shots      "Shots(on)"
    stat.on_target  "On target"
    stat.corners    "Corners"
    stat.fouls      "Fouls"
    stat.yellows    "Yellows"
    stat.reds       "Reds"
    stat.offsides   "Offsides"
    stat.saves      "Saves"
    stat.passes     "Passes"
    stat.pass_pct   "Pass %"
    lineup.none     "Line-ups for %{teams} aren't out yet (usually ~1h before kick-off)."
    stats.notyet    "%{teams} hasn't started yet."

    next.none   "No upcoming matches found for %{what}."
    last.none   "No recent results found for %{what}."
    table.none  "No standings available for %{league}."
    table.sent_priv "Sent you the details privately."
    table.row   "{c:rank}%{rank}.{/c}%{team} {c:dim}P%{gp} W%{w} D%{d} L%{l} GD%{gd}{/c} {b}%{pts}{b}"
    table.row_us "{c:rank}%{rank}.{/c}%{team} {b}%{w}-%{l}{b} {c:dim}%{pct} GB %{gb}{/c}"
    scorers.soccer_only "Top scorers are only available for football competitions."
    scorers.title   "%{league} top scorers:"
    scorers.assists "%{league} top assists:"
    h2h.none   "No recent meetings found between %{a} and %{b}."
    h2h.title  "{b}%{a} vs %{b}{b} ({c:win}%{w}W{/c} {c:draw}%{d}D{/c} {c:loss}%{l}L{/c}):"

    sport.soccer     "Football"
    sport.basketball "Basketball"
    sport.football   "American football"
    sport.hockey     "Ice hockey"
    sport.baseball   "Baseball"
    sport.racing     "Motorsport"
    sport.tennis     "Tennis"
    sport.mma        "MMA"
    sport.golf       "Golf"
    sport.rugby      "Rugby"
    sport.australian-football "Aussie rules"
    leagues.summary  "Competitions: %{sports}. Search with %{cmd} <name|sport>."

    help.group.info "Scores & info"
    help.group.mine "Personal"
    help.group.fun  "Narration & predictions"
    help.footer     "Details: %{cmd} <command>. Commands also work in private."
    help.aliases    "Also works as"
    help.help     "\[command\] — list commands or show help for one"
    help.live     "\[league|sport|team\] — live matches"
    help.today    "\[league|sport|team\] \[date\] — matches of the day (today, tomorrow, 25/12...)"
    help.match    "<team> — detailed current/last match: scorers, cards, stats"
    help.next     "<team|league> — upcoming fixtures"
    help.last     "<team|league> — latest results"
    help.table    "<league|team> \[group\] \[full\] — standings"
    help.scorers  "<league> \[assists\] — top scorers"
    help.lineup   "<team> — line-ups"
    help.stats    "<team> — match statistics"
    help.form     "<team> — last 5 results"
    help.h2h      "<team> vs <team> — head to head"
    help.leagues  "\[search\] — available competitions"
    help.narrate  "<team> \[full|normal|brief\] | off | list — live narration of a match"
    help.follow   "<team> | league <name> | player <name> | match <team> — get private alerts"
    help.unfollow "<name|number|all> — stop following"
    help.follows  "— what you follow"
    help.prefs    "— your preferences"
    help.set      "<lang|tz|delivery|events|remind|quiet|dnd|digest|style|symbols|home> <value>"
    help.lang     "\[code\] — your language"
    help.tz       "\[Region/City\] — your timezone, e.g. Europe/Madrid"
    help.predict  "<team> <goals>-<goals> \[rival\] — predict a result (locks at kick-off)"
    help.preds    "\[team\] — your open predictions, or everyone's for a match"
    help.porra    "— open matches to predict (ops: feature <team> \[x2\] | on | off)"
    help.ranking  "\[week|month|season|all\] — prediction leaderboard"
    help.mdset    "\[#chan\] <leagues|teams|events|lang|tz|style|symbols|prefix|remind|porra|narrperm|maxnarr|autonarr|narrstyle|digest|replies|quiet|cmds> <value>"
    help.admin    "status | reload | save | enable | disable | alias | replay | demo | flush | debug | conf"
    about         "{b}Matchday %{version}{b} — live sports for Eggdrop · transport: %{transport}"

    narr.stopped    "Narration of %{teams} ended."
    narr.none       "No narration running here."
    narr.limit      "Narration limit reached (%{n})."
    narr.nomatch    "%{team} has no live match or one starting in the next %{hours}h."
    narr.already    "Already narrating %{teams} here."
    narr.started    "{s:mic} Narration #%{id} on: {b}%{teams}{b} (%{style}, %{when}). Stop with %{cmd}"
    narr.style.full   "full"
    narr.style.normal "normal"
    narr.style.brief  "brief"
    narr.assist     " {c:dim}(assist: %{name}){/c}"
    narr.lineups_in "{b}Line-ups are in!{b}"
    narr.form       "Recent form — %{home}: %{hf} · %{away}: %{af}"
    narr.poss       "possession %{home} %{ph}% – %{pa}% %{away}"
    narr.join_generic "We join %{league}: %{score} {c:dim}(%{detail}){/c}"
    narr.signoff    "{c:dim}That's all from this match. Thanks for following!{/c}"
    replay.banner   "REPLAY x%{speed}: %{teams} (recorded match, not live)"

    preds.noscope   "Which channel's pool? Use %{cmd} #channel ... or set your home channel: set home #channel"
    preds.disabled  "The prediction game is disabled in that channel."
    preds.nomatch   "%{team} has no match to predict in the next %{days} days."
    preds.saved     "{s:win} Prediction saved: %{pred} {c:dim}(%{when}, %{league}){/c}"
    preds.updated   "{s:win} Prediction updated: %{pred} {c:dim}(%{when}, %{league}){/c}"
    preds.void      "{s:flag} %{teams} won't be played: %{n} %{n:prediction|predictions} voided."
    preds.exact     "{c:gold}exact{/c} (+%{pts}): %{names}"
    preds.good      "{c:ok}right result{/c}: %{names}"
    preds.zero      "%{n} missed"
    preds.leader    "{s:trophy} leader: {b}%{nick}{b} %{pts} pts"
    preds.settled   "{s:trophy} {b}Pool{b} %{score}:"
    preds.empty     "No settled predictions yet. Try %{cmd}!"
    preds.you       "you: #%{pos} %{pts} pts (%{ex} exact, %{n} %{n:pick|picks})"
    preds.ranking   "Pool leaderboard (%{period}):"
    preds.mine_none "You have no open predictions. Try %{cmd} <team> 2-1"
    preds.mine      "Your open predictions"
    preds.hidden    "%{teams}: %{n} %{n:prediction|predictions} (revealed at kick-off)."
    preds.match_none "No open predictions for %{team}."
    preds.reset     "Leaderboard archived and reset."
    preds.featured  "{c:gold}{s:star}{/c} %{teams} is a featured match: points x%{mult}!"
    preds.open_none "No matches to predict in the next 48h."
    preds.open_header "{s:trophy} {b}Open for predictions{b} (%{cmd} <team> 2-1):"
    period.week     "last 7 days"
    period.month    "last 30 days"
    period.season   "season"
    period.all      "all time"

    cfg.set       "{s:win} {b}%{key}{b} = %{value}"
    cfg.needchan  "Which channel? Use it in the channel or give #channel."
    follow.ok     "{s:win} Following {b}%{what}{b}. You'll get alerts privately; tune them with %{cmd}."
    follow.already "You already follow %{what}."
    follow.limit  "You can follow up to %{n} things."
    unfollow.all  "You no longer follow anything."
    unfollow.notfound "You don't follow anything matching '%{query}'."
    unfollow.ok   "Stopped following %{what}."
    follows.none  "You don't follow anything yet. Try %{cmd} <team>."
    follows.header "You follow"
    follows.kind.team   "team"
    follows.kind.league "competition"
    follows.kind.player "player"
    follows.kind.match  "match"
    prefs.header  "Your preferences"
    prefs.hint    "Change with %{cmd} <name> <value> (e.g. set events goals,reds,ft · set quiet 23:00-08:00 · set tz Europe/Madrid)"
    set.badlang   "Unknown language. Available: %{langs}"
    set.badtz     "Unknown timezone. Use Region/City, e.g. Europe/Madrid, America/Mexico_City, UTC."
    set.badvalue  "Invalid value for %{key}. Valid: %{values}"
    set.unknown   "Unknown setting '%{key}'. Valid: %{keys}"
    lang.list     "Languages: %{langs}. Use %{cmd} <code>."
    tz.current    "Your timezone: %{tz} (now %{time})."
}

# Narration: each key has several variants, picked at random (no repeats).
# Placeholders: %{player} %{team} %{opp} %{min} %{score} %{assist} %{n} ...
::md::i18n::vary en {
    narr.intro {
        "{s:mic} Good evening! Coming up: {b}%{teams}{b} in the %{league}, kick-off %{time}."
        "{s:mic} We're live for {b}%{teams}{b} (%{league}) — kick-off at %{time}. Stay tuned!"
        "{s:mic} Everything ready for {b}%{teams}{b}! %{league}, %{time}."
    }
    narr.join {
        "We join the action at {c:minute}%{min}{/c}: %{score}%{scorers}"
        "Picking it up at {c:minute}%{min}{/c} — %{score}%{scorers}"
    }
    narr.kickoff {
        "{s:start} {c:start}{b}And we're off!{b}{/c} %{home} vs %{away} is underway."
        "{s:start} {c:start}{b}Kick-off!{b}{/c} The ball is rolling: %{home} - %{away}."
        "{s:start} {c:start}{b}Here we go!{b}{/c} %{home} get us started against %{away}."
    }
    narr.goal.goal {
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} {c:minute}%{min}{/c} {b}%{player}{b} scores for %{team}! %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOOOAL!{b}{/c} %{player} finds the net for %{team} ({c:minute}%{min}{/c}). %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} It's in! %{player} beats the keeper at {c:minute}%{min}{/c}. %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOAL for %{team}!{b}{/c} %{player} with the finish, {c:minute}%{min}{/c}. %{score}%{assist}"
    }
    narr.goal.first {
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} The deadlock is broken! %{player} puts %{team} ahead at {c:minute}%{min}{/c}. %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} First blood to %{team}: %{player} ({c:minute}%{min}{/c}). %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} %{player} opens the scoring for %{team}! {c:minute}%{min}{/c} %{score}%{assist}"
    }
    narr.goal.lead {
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} %{team} are back in front! %{player}, {c:minute}%{min}{/c}. %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} %{player} restores the lead for %{team} ({c:minute}%{min}{/c}). %{score}%{assist}"
    }
    narr.goal.equaliser {
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} {c:hl}Level!{/c} %{player} equalises for %{team} at {c:minute}%{min}{/c}. %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} %{team} are back on terms thanks to %{player}! {c:minute}%{min}{/c} %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} All square! %{player} ({c:minute}%{min}{/c}). %{score}%{assist}"
    }
    narr.goal.comeback {
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} {c:hl}The comeback is complete!{/c} %{player} turns it around for %{team} ({c:minute}%{min}{/c}). %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} %{team} were behind and now they lead! %{player}, {c:minute}%{min}{/c}. %{score}%{assist}"
    }
    narr.goal.latewinner {
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} {c:hl}LATE DRAMA!{/c} %{player} at {c:minute}%{min}{/c}! %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} {c:hl}At the death!{/c} %{player} could have won it for %{team} ({c:minute}%{min}{/c}). %{score}%{assist}"
    }
    narr.goal.brace {
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} %{player} again! {c:hl}That's his brace{/c} ({c:minute}%{min}{/c}). %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} Two for %{player}! %{team} {c:minute}%{min}{/c}. %{score}%{assist}"
    }
    narr.goal.hattrick {
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} {c:hl}{s:star} HAT-TRICK for %{player}!{/c} ({c:minute}%{min}{/c}) %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} Three! {c:hl}%{player} takes the match ball home!{/c} {c:minute}%{min}{/c} %{score}%{assist}"
    }
    narr.goal.pen {
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} %{player} converts the penalty! {c:minute}%{min}{/c} %{score}"
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} Cool as you like from the spot: %{player} ({c:minute}%{min}{/c}). %{score}"
    }
    narr.goal.og {
        "{s:goal} {c:goal}{b}OWN GOAL!{b}{/c} Disaster for %{opp}: %{player} turns it into his own net ({c:minute}%{min}{/c}). %{score}"
        "{s:goal} {c:goal}{b}OWN GOAL!{b}{/c} %{team} benefit from %{player}'s mistake at {c:minute}%{min}{/c}. %{score}"
    }
    narr.goal.rout {
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} %{player} adds another! This is turning into a rout ({c:minute}%{min}{/c}). %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} %{team} are running riot — %{player} at {c:minute}%{min}{/c}. %{score}%{assist}"
    }
    narr.goal.consolation {
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} %{player} pulls one back for %{team} ({c:minute}%{min}{/c}). Game on? %{score}%{assist}"
        "{s:goal} {c:goal}{b}GOAL!{b}{/c} %{team} reduce the deficit through %{player}, {c:minute}%{min}{/c}. %{score}%{assist}"
    }
    narr.yellow {
        "{s:yellow} {c:minute}%{min}{/c} Booked: %{player} (%{team})."
        "{s:yellow} {c:minute}%{min}{/c} The referee shows yellow to %{player} of %{team}."
        "{s:yellow} {c:minute}%{min}{/c} %{player} goes into the book."
    }
    narr.yred {
        "{s:yred} {c:minute}%{min}{/c} {c:red}{b}Second yellow!{b}{/c} %{player} is off — %{team} down to ten."
        "{s:yred} {c:minute}%{min}{/c} {c:red}{b}Off he goes!{b}{/c} Second booking for %{player} (%{team})."
    }
    narr.red {
        "{s:red} {c:minute}%{min}{/c} {c:red}{b}STRAIGHT RED!{b}{/c} %{player} is sent off! %{team} will have to cope with ten."
        "{s:red} {c:minute}%{min}{/c} {c:red}{b}RED CARD!{b}{/c} %{player} (%{team}) is off!"
    }
    narr.sub {
        "{s:sub} {c:minute}%{min}{/c} Change for %{team}: %{pin} on, %{pout} off."
        "{s:sub} {c:minute}%{min}{/c} %{team} make a substitution — %{pin} replaces %{pout}."
    }
    narr.penmiss {
        "{s:pen} {c:minute}%{min}{/c} {c:hl}Penalty MISSED!{/c} %{player} (%{team}) fails from the spot!"
        "{s:pen} {c:minute}%{min}{/c} {c:hl}Off target!{/c} %{player} wastes the penalty."
    }
    narr.pensaved {
        "{s:pen} {c:minute}%{min}{/c} {c:hl}SAVED!{/c} The keeper stops %{player}'s penalty!"
        "{s:pen} {c:minute}%{min}{/c} {c:hl}Penalty saved!{/c} %{player} (%{team}) is denied."
    }
    narr.save {
        "{s:chance} {c:minute}%{min}{/c} Chance for %{team}! %{player} shoots... saved by %{keeper}."
        "{s:chance} {c:minute}%{min}{/c} %{player} tests %{keeper}, who is equal to it."
        "{s:chance} {c:minute}%{min}{/c} Great stop from %{keeper} to deny %{player}!"
    }
    narr.shot {
        "{s:chance} {c:minute}%{min}{/c} %{player} (%{team}) forces a save."
        "{s:chance} {c:minute}%{min}{/c} On target from %{player}, but no way through."
    }
    narr.woodwork {
        "{s:chance} {c:minute}%{min}{/c} {c:hl}WOODWORK!{/c} %{player} hits the frame of the goal!"
        "{s:chance} {c:minute}%{min}{/c} {c:hl}Off the post!{/c} So close for %{team} — %{player}."
        "{s:chance} {c:minute}%{min}{/c} {c:hl}The bar saves it!{/c} %{player} was inches away."
    }
    narr.miss {
        "{s:chance} {c:minute}%{min}{/c} %{player} goes close for %{team}, just wide."
        "{s:chance} {c:minute}%{min}{/c} Near miss! %{player} drags it past the post."
    }
    narr.corner {
        "{c:minute}%{min}{/c} Corner for %{team}."
        "{c:minute}%{min}{/c} %{team} win a corner."
    }
    narr.added {
        "{s:clock} Added time: {b}+%{n}'{b}."
        "{s:clock} The fourth official shows {b}+%{n}{b}."
    }
    narr.ht {
        "{s:ht} {c:ht}{b}Half-time!{b}{/c} %{score}%{scorers}"
        "{s:ht} {c:ht}{b}The referee blows for the break.{b}{/c} %{score}%{scorers}"
    }
    narr.2h {
        "{s:start} {c:start}Second half underway!{/c} %{score}"
        "{s:start} {c:start}We're back for the second half.{/c} %{score}"
    }
    narr.end90 {
        "{s:ht} The 90 minutes are up: %{score}."
    }
    narr.et {
        "{s:start} {c:hl}Extra time begins!{/c} %{score}"
    }
    narr.shootout {
        "{s:pen} {c:pen}{b}It goes to PENALTIES!{b}{/c} %{score}"
        "{s:pen} {c:pen}{b}Penalty shootout!{b}{/c} Nerves of steel needed. %{score}"
    }
    narr.so.scored {
        "{s:pen} %{player} (%{team}) {c:ok}scores{/c}."
        "{s:pen} %{player} (%{team}) {c:ok}✔ in{/c}."
    }
    narr.so.missed {
        "{s:pen} %{player} (%{team}) {c:err}misses!{/c}"
        "{s:pen} %{player} (%{team}) {c:err}✖ saved/missed!{/c}"
    }
    narr.update {
        "{c:dim}{s:clock}{/c} {c:minute}%{min}{/c} %{score} {c:dim}%{poss}{/c}"
        "{c:dim}{s:clock}{/c} {c:minute}%{min}{/c} and it's %{score}. {c:dim}%{poss}{/c}"
    }
    narr.pressure {
        "{s:chance} %{team} are piling on the pressure: %{n} shots in five minutes!"
        "{s:chance} Wave after wave from %{team} — %{n} attempts in the last five minutes."
    }
    narr.tension.draw {
        "{s:clock} Final minutes and it's all square: %{score}. Who blinks first?"
        "{s:clock} Nerves jangling — level at %{score} as we enter the last five minutes."
    }
    narr.tension.close {
        "{s:clock} Final minutes: %{team} are hanging on to a slender lead. %{score}"
        "{s:clock} Five minutes to go, %{team} can almost taste it. %{score}"
    }
    narr.var {
        "{s:var} {c:minute}%{min}{/c} {c:var}VAR check...{/c} %{text}"
    }
    narr.delay {
        "{c:minute}%{min}{/c} Play is stopped for a moment."
    }
    narr.ft.win {
        "{s:ft} {c:ft}{b}FULL-TIME!{b}{/c} %{score} — victory for {b}%{winner}{b}!"
        "{s:ft} {c:ft}{b}It's all over!{b}{/c} %{winner} take the points. %{score}"
        "{s:ft} {c:ft}{b}Final whistle!{b}{/c} %{score}. A night to remember for %{winner}."
    }
    narr.ft.draw {
        "{s:ft} {c:ft}{b}FULL-TIME!{b}{/c} Honours even: %{score}."
        "{s:ft} {c:ft}{b}It ends level.{b}{/c} %{score}"
    }
    narr.ft.pens {
        "{s:ft} {c:ft}{b}IT'S OVER!{b}{/c} %{score} — {b}%{winner}{b} win %{so} on penalties!"
    }
}

# --- players, probabilities, hot matches, videos
::md::i18n::cmds en { player {player} prob {prob probability odds} }

::md::i18n::msgs en {
    player.notfound    "No player found for '%{query}'."
    player.age         "%{n} y/o"
    player.goals       "%{n} %{n:goal|goals}"
    player.assists     "%{n} %{n:assist|assists}"
    player.starts      "%{n} %{n:start|starts}"
    player.shots       "%{n} %{n:shot|shots} (%{s} on target)"
    player.cleansheets "%{n} %{n:clean sheet|clean sheets}"
    player.last        "Last %{n}: %{goals} G, %{assists} A"
    player.next        "Next: %{name} (%{when}, %{league})"
    player.also        "Also: %{list}"
    prob.draw          "draw"
    prob.model         "Win probability"
    prob.odds          "Pre-match odds"
    prob.espn          "Win probability (ESPN)"
    prob.prior         "Win probability (no odds)"
    prob.none          "No probability available for %{teams}."
    hot.flurry         "{s:hot} {c:hl}{b}Hot match!{b}{/c} %{n} goals in %{mins} minutes: %{score} {c:minute}%{min}{/c} %{league}"
    hot.goalfest       "{s:hot} {c:hl}{b}Goal fest!{b}{/c} %{n} goals already: %{score} {c:minute}%{min}{/c} %{league}"
    hot.comeback       "{s:hot} {c:hl}{b}Comeback on!{b}{/c} %{team} were two goals down: %{score} {c:minute}%{min}{/c} %{league}"
    hot.upset          "{s:hot} {c:hl}{b}Upset alert!{b}{/c} %{team} (%{pct}% pre-match) lead: %{score} {c:minute}%{min}{/c} %{league}"
    hot.shock          "{s:hot} {c:hl}{b}Shock result!{b}{/c} %{team} (%{pct}% pre-match) win: %{score} %{league}"
    ev.video           "{s:tv} {c:info}Video:{/c} %{teams} {c:dim}—{/c} %{headline}%{dur} %{url}"
    help.player        "<name> — player profile and season stats"
    help.prob          "<team> — win probability (live model / odds)"
}
