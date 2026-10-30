# Matchday — live sports for Eggdrop

**English** | [Español](README.es.md)

A pure-Tcl script for **Eggdrop** that turns your IRC bot into a live sports
hub: instant goal alerts, radio-style match commentary, personal alerts,
a prediction game with leaderboards, standings, top scorers, line-ups, stats,
player profiles, win probabilities and a web dashboard.

**Self-sufficient**: no API key needed (it uses ESPN's public data), no
external services, no database. Optional API-Football integration.

```
<Matchday> ▶ Kick-off: Real Madrid - Sevilla [LALIGA]
<Matchday> ⚽ GOAL! Real Madrid 1-0 Sevilla — Mbappé 23' [LALIGA]
<Matchday> ⚽ GOAL! Real Madrid 1-1 Sevilla — En-Nesyri 44' (pen) Equaliser! [LALIGA]
<Matchday> ⏸ Half-time: Real Madrid 1-1 Sevilla (Mbappé 23' | En-Nesyri 44' (pen)) [LALIGA]
<Matchday> ▮ RED CARD! Ramos (Sevilla) 60' — Real Madrid 1-1 Sevilla ▮ [LALIGA]
<Matchday> ⚽ GOAL! Real Madrid 3-1 Sevilla ▮ — Mbappé 81' Hat-trick for Mbappé! [LALIGA]
<Matchday> ■ Full-time: Real Madrid 3-1 Sevilla ▮ (Mbappé 23' 70' 81' | En-Nesyri 44' (pen)) [LALIGA]
<Matchday> ♛ Pool Real Madrid 3-1 Sevilla: exact (+3): pepe · right result: ana (+1) | ♛ leader: pepe 24 pts
```

Live commentary (`!narrate inter`), real excerpt from Inter 3-4 Club Brugge:

```
♪ ➜ 26' WOODWORK! Nicolo Tresoldi hits the frame of the goal!
♪ ⚽ GOAL! Nicolo Tresoldi converts the penalty! 30' Inter Milan 0-1 Club Brugge
♪ ➜ Inter Milan are piling on the pressure: 3 shots in five minutes!
♪ ⚽ GOAL! Inter Milan are back on terms thanks to Lautaro Martínez! 44' Inter Milan 1-1 Club Brugge (assist: Federico Dimarco)
♪ ⚽ GOAL! Three! Nicolo Tresoldi takes the match ball home! 74' Inter Milan 1-3 Club Brugge
♪ · Win probability: Inter Milan 2% · draw 8% · Club Brugge 90%
♪ ⚽ GOAL! Lautaro Martínez pulls one back for Inter Milan (81'). Game on? Inter Milan 2-3 Club Brugge
♪ ⏰ Final minutes: Club Brugge are hanging on to a slender lead. Inter Milan 2-3 Club Brugge
```

Player profiles and win probability:

```
<user> !player mbappe
<Matchday> Kylian Mbappé · Real Madrid · Forward #10 · 27 y/o · France
<Matchday> 2026-27 LALIGA: 7 goals, 2 assists, 8 starts, 44 shots (24 on target), ▮1
<Matchday> Last 5: 4 G, 2 A · Next: Sevilla at Real Madrid (Sun 18/10 19:00, LALIGA)
<user> !prob real madrid
<Matchday> 19:00 AS Roma - Real Madrid [Champions League] · Win probability: AS Roma 26% · draw 24% · Real Madrid 50%
```

---

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Step-by-step installation](#step-by-step-installation)
- [Quick channel setup](#quick-channel-setup)
- [Commands (summary)](#commands-summary) · [Full command guide](docs/COMMANDS.md)
- [Script configuration (`matchday.conf`)](#script-configuration-matchdayconf)
- [Automatic commentary for a team](#automatic-commentary-for-a-team)
- [Web dashboard](#web-dashboard)
- [API-Football (optional)](#api-football-optional)
- [Win probability model](#win-probability-model-football)
- [How it works](#how-it-works)
- [Tests](#tests)
- [Adding a language](#adding-a-language)
- [Troubleshooting](#troubleshooting)
- [Notes and license](#notes-and-license)

---

## Features

| Area | What it does |
|---|---|
| **Live** | Goals in context (opener, equaliser, comeback, late winner, brace, hat-trick, rout), VAR-disallowed goals, cards, missed penalties, kick-off, half-time, extra time, shoot-outs, full-time, postponed/suspended. |
| **Other sports** | NBA/WNBA/NCAA, NFL, NHL, MLB, ATP/WTA tennis, F1/IndyCar/NASCAR, golf, UFC, rugby, AFL. **113 competitions** in the catalogue plus any ESPN league by its code (`soccer/por.2`). |
| **Commentary** | Template-based commentator in 6 languages with hundreds of variants: saves, woodwork, chances, substitutions, pressure spells, added time, late tension, line-ups, half-time and full-time reports. Styles `full`, `normal`, `brief`. To a channel or in private. **Automatic** for the teams you choose. |
| **Personal** | Each user follows teams, competitions, players or single matches and gets alerts by notice/private message in their own language and timezone, with event filters, reminders, quiet hours, do-not-disturb, a daily digest and "what you missed". |
| **Info** | Standings, top scorers, upcoming fixtures, latest results, match details, line-ups, stats, form, head-to-head, today's matches and live matches. |
| **Players** | Profile (team, position, age, nationality), season stats per competition, last 5 games and next game. Any sport. |
| **Probability** | Football: Poisson model fitted to pre-match odds and updated with score, minute and red cards. NBA/NFL: ESPN's live win probability. |
| **Hot matches** | Alerts for goal flurries, goal fests, comebacks, upsets in progress and shock results. |
| **Videos** | Posts highlight clips after full time (max. 2 per match). |
| **Prediction game** | Per-channel predictions that lock at kick-off and settle automatically; configurable points, featured matches, weekly/monthly/season leaderboards. |
| **Languages** | English by default plus Spanish, Portuguese, French, Italian and German, per channel **and per user**. Commands work in every language (`!table`, `!clasificacion`, `!tabela`, `!classement`...). |
| **Web dashboard** | Built-in HTTP server: live scores, today's matches, event feed, prediction leaderboard and bot status. JSON API. |
| **Robustness** | Fully asynchronous HTTP (the bot never blocks), caching, back-off on errors, persistent data with atomic writes, hot reload, flood protection, no repeated events after a restart. |

---

## Requirements

- **Eggdrop 1.8.4 or newer** (1.9 / 1.10 recommended) with **Tcl 8.6+**.
- For HTTPS, **one** of these (the script detects which one is available):
  - the Tcl **tls** package (recommended), or
  - the **curl** program (almost always installed).

Nothing else: the JSON parser is built in.

---

## Step-by-step installation

These instructions are for Linux (Debian/Ubuntu). On other distributions only
the package manager changes.

### 1. Dependencies

```sh
sudo apt update
sudo apt install tcl tcl-tls curl
```

| Distribution | tls package |
|---|---|
| Debian / Ubuntu | `sudo apt install tcl-tls` |
| Fedora / RHEL | `sudo dnf install tcltls` |
| Alpine | `apk add tcl-tls` |

`tcl` is only needed to run the tests outside Eggdrop. If you can't install
`tls`, `curl` is enough.

### 2. Download the script

Inside your Eggdrop folder (for example `~/eggdrop`):

```sh
cd ~/eggdrop/scripts
git clone https://github.com/sauk1337/matchday.git
```

Or download the ZIP from GitHub and extract it as `scripts/matchday`.
What matters is that `scripts/matchday/matchday.tcl` exists.

### 3. Check that it works (optional, recommended)

```sh
cd ~/eggdrop/scripts/matchday
tclsh tests/run_all.tcl          # offline tests: must end with "All tests passed."
tclsh tests/run_all.tcl live     # plus a real check against ESPN (1-2 minutes)
```

In the `live` check, the `HTTP: transport ...` line at the end tells you whether
it uses `tls` or `curl`.

### 4. Script configuration (optional)

```sh
cp matchday.conf.example matchday.conf
nano matchday.conf
```

Everything has a default. The usual changes are language and timezone:

```tcl
set conf(lang.default)  en
set conf(tz.default)    Europe/London
```

`matchday.conf` is in `.gitignore`: your settings (and an API-Football key, if
you add one) are never committed.

### 5. Load it in Eggdrop

At the end of `eggdrop.conf`:

```tcl
source scripts/matchday/matchday.tcl
```

The path is relative to the folder the bot starts from. Then, on the partyline
(`/dcc chat YourBot`):

```
.rehash
```

The log should show a Matchday line with the version, the number of
competitions and the loaded languages.

### 6. Enable it in a channel

On the partyline:

```
.chanset #football +matchday
```

Then continue with the [quick channel setup](#quick-channel-setup).

### 7. Try it

```
!md demo            replays a finished match at high speed (needs the +m flag)
!today
!player mbappe
```

### Updating to a new version

```sh
cd ~/eggdrop/scripts/matchday
git pull
```

and `.rehash` (or `!md reload`). Your `matchday.conf` and the `data/` folder are
left untouched.

---

## Quick channel setup

As a channel **op**:

```
!mdset lang en                              channel language
!mdset tz Europe/London                     timezone
!mdset leagues add premier, champions       competitions to announce
!mdset                                      show the configuration
```

Optional:

```
!mdset events -videos +cards                which alerts are posted
!mdset remind 15                            reminder 15 min before each match
!mdset digest 10:00                         daily round-up of the day's matches
!mdset teams add boca juniors               a team even if its league isn't added
!mdset autonarr add arsenal                 ALWAYS commentate that team's matches
!mdset narrstyle full                       style of the automatic commentary
```

To see the available competitions: `!leagues` or `!leagues argentina`.

---

## Commands (summary)

Every command has an English name plus aliases in each language, and they all
work everywhere. In private messages to the bot, drop the `!`.

| Command | What it does |
|---|---|
| `!help [command]` | Command list or help for one command |
| `!live` | Matches in play |
| `!today [league\|team] [date]` | Today's matches (`tomorrow`, `25/12`...) |
| `!match <team>` | Details of a team's match |
| `!next` / `!last` | Upcoming fixtures / latest results |
| `!table` | Standings |
| `!scorers` | Top scorers or assists |
| `!lineup` / `!stats` | Line-ups / match stats |
| `!form` / `!h2h` | Recent form / head-to-head |
| `!player <name>` | Player profile |
| `!prob <team>` | Win probability |
| `!leagues` | Available competitions |
| `!follow` / `!unfollow` / `!follows` | Personal alerts |
| `!set` / `!prefs` / `!lang` / `!tz` | Personal settings |
| `!narrate` | Live commentary of a match |
| `!predict` / `!preds` / `!porra` / `!ranking` | Prediction game |
| `!mdset` | Channel configuration (ops) |
| `!md` | Administration (`+m` flag) |
| `!more` / `!about` | Next page / version |

👉 **[Full command guide with examples and every option](docs/COMMANDS.md)**

---

## Script configuration (`matchday.conf`)

`matchday.conf.example` is commented line by line. The most useful options:

| Option | Default | Purpose |
|---|---|---|
| `lang.default` | `en` | Default language (`en es pt fr it de`) |
| `tz.default` | `UTC` | Default timezone (`Europe/London`) |
| `cmd.prefix` | `!` | Command prefix |
| `http.transport` | `auto` | `auto`, `tls` or `curl` |
| `poll.live` / `poll.idle` | `30` / `900` | Seconds between polls with live matches / with nothing on |
| `chan.events` | all but `cards` | Default alerts for a new channel |
| `out.style` / `out.symbols` | `full` / `unicode` | Colours and symbols |
| `out.max_per_minute` | `20` | Flood control: lines per minute per target |
| `narr.perm` | `op` | Who may start commentary in a channel |
| `narr.auto_lead` | `3600` | Seconds before kick-off when automatic commentary starts |
| `hot.odds` | `1` | Fetch odds at the start of each football match (probability and upset alerts) |
| `videos.enabled` | `1` | Post highlight clips |
| `preds.exact` / `diff` / `outcome` | `3` / `2` / `1` | Prediction points |
| `web.port` | `0` | Web dashboard port (0 = off) |
| `apifootball.key` | empty | Optional API-Football key |
| `admin.flags` | `m\|-` | Eggdrop flags for `!md` |

Almost everything can also be changed at runtime: `!md conf <key> <value>`.

---

## Automatic commentary for a team

```
!mdset autonarr add arsenal
!mdset narrstyle full
```

- It starts by itself `narr.auto_lead` seconds before kick-off (1 h by default),
  with the preview and line-ups, in **every** competition the team plays.
- While a match is being commentated, its regular alerts aren't repeated in that
  channel.
- If an op types `!narrate off`, that match won't be restarted; the next one will.
- If the bot restarts mid-match, the commentary resumes.
- `!mdset autonarr del <team>` / `!mdset autonarr clear` to remove it.

---

## Web dashboard

In `matchday.conf`:

```tcl
set conf(web.port)  8088
set conf(web.bind)  127.0.0.1
set conf(web.token) "change-me"     ;# optional: http://host:8088/?token=change-me
```

Tabs: Live, Today, Event feed, Predictions and Status. It refreshes every 15 s,
has a dark mode and works on mobile. JSON API: `/api/live`,
`/api/ranking?chan=%23channel&period=season`, `/api/status`, `/api/events`.

It is read-only. To publish it on the Internet, keep it on `127.0.0.1` and put it
behind nginx or caddy with HTTPS.

---

## API-Football (optional)

```tcl
set conf(apifootball.key)  "your-key"
set conf(apifootball.mode) extras    ;# or primary
```

- `extras` (recommended): ESPN stays the source; API-Football adds the
  **historical head-to-head**. Fits the free plan (100 requests/day).
- `primary`: uses API-Football for football scoreboards (needs a paid plan).
  Falls back to ESPN on errors.

The key only goes in `matchday.conf`, which is never committed.

---

## Win probability model (football)

1. Before the match, the 1X2 odds are read, the bookmaker margin is removed and
   each team's expected goals are fitted so that a Poisson model reproduces
   those probabilities.
2. During the match, the remaining expected goals are scaled by the time left
   (including typical added time) and adjusted for red cards (−28 % for the team
   down to ten, +22 % for the opponent).
3. This is combined with the current score: P(home / draw / away).

Real example (Inter–Club Brugge, Inter 78 % favourites): after Brugge's
30th-minute penalty it drops to 43 %; Inter's 44th-minute equaliser brings it back
to 63 %. Without odds, neutral values are used and the output says so.

---

## How it works

```
              ┌──────────────── providers ───────────────┐
 ESPN ─────▶  │ espn.tcl  apifootball.tcl  (normalise)   │
              └──────────────────┬────────────────────────┘
                                 ▼
  poller.tcl  adaptive polling: 30 s with live matches, 60 s near kick-off,
              sleeps until shortly before the next match
                                 ▼
  diff.tcl    compares snapshots → events (goal, VAR, card, half-time...)
              with persistent memory: never repeats a goal after a restart
                                 ▼
  dispatch    ─▶ channels (league/team/event filters)
              ─▶ users (follows, language, quiet hours, notice/private)
              ─▶ hooks: commentator, predictions, hot matches, videos, web
                                 ▼
  out.tcl     colours by role, unicode/ascii, byte-safe wrapping, merging of
              simultaneous events, flood control, !more
```

Only the competitions someone needs are polled (channels, users, followed teams
playing soon, commentary sessions, open predictions).

### Layout

```
matchday.tcl            loader (clean reload with .rehash / !md reload)
matchday.conf.example   commented configuration (copy to matchday.conf)
lib/        util, json, http (tls/curl), store, i18n, out
engine/     catalog, poller, diff, render, dispatch, teams, prob
providers/  espn, apifootball
features/   commands, info, usercmds, admin, chan, subs, narrator,
            predictions, replay, player, hot, videos, web
lang/       en es pt fr it de
web/        index.html (dashboard)
tests/      Eggdrop simulator + 157 tests with real recorded data
docs/       COMMANDS.md / COMANDOS.md (full command guide)
data/       (created at runtime) users, predictions, state, team index
```

---

## Tests

```sh
tclsh tests/run_all.tcl                          # full offline suite
tclsh tests/run_all.tcl live                     # + a check against the real API
tclsh -encoding utf-8 tests/demo_output.tcl en   # watch a simulated match in a channel
```

The tests use an Eggdrop simulator (`tests/eggstub.tcl`) and real ESPN responses
recorded in `tests/fixtures/`.

---

## Adding a language

1. Copy `lang/en.tcl` to `lang/xx.tcl`.
2. Change the first line (`::md::i18n::lang xx Name NativeName`).
3. Translate the strings and add command aliases in `::md::i18n::cmds`.
4. `.rehash` and `!mdset lang xx`.

Anything left untranslated falls back to English. Plurals are written as
`%{n} %{n:goal|goals}`.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `No tls package and no curl found` | Install `tcl-tls` or `curl` |
| Nothing is announced | Check `.chanset #channel +matchday`, that `!mdset` lists leagues and that `!md status` shows no errors |
| `!md` doesn't answer | Your user needs `+m`: `.chattr YourNick +m` |
| Wrong times | `!mdset tz Europe/London` (channel) or `!tz ...` (user) |
| The channel is `+c` | The bot detects it and sends without colours; also `!mdset style bold` |
| Odd symbols | `!mdset symbols ascii` |
| `error reading package index file .../ttkthemes/...` when testing | Warnings from graphical Tk packages installed on the system; harmless |
| Error on load | `.console +d` on the partyline, then `.rehash`, and read the message |

---

## Notes and license

- ESPN has no official public API: the script uses the same public endpoints as
  their website, stable for years but subject to change. All parsing is isolated
  in `providers/espn.tcl`. This project is not affiliated with or endorsed by
  ESPN or API-Football.
- Commentary is built from the events and plays the provider publishes; if a play
  isn't in their data, it isn't narrated.
- MIT license: see [LICENSE](LICENSE).
