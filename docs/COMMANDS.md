# Matchday — full command guide

**English** | [Español](COMANDOS.md) · [← Back to the README](../README.md)

## Basics

- In a channel, commands start with `!`. Each channel can change it with
  `!mdset prefix`.
- In a private message to the bot they work **without the prefix**:
  `/msg Bot today`. Words Eggdrop already uses in private (`help`, `info`, `op`,
  `pass`...) need the `!`: `/msg Bot !help`.
- Every command has an English name and aliases in the other languages; they all
  work everywhere (see [section 8](#8-aliases-in-other-languages)).
- Long answers are split: `!more` shows the rest.
- `!help <command>` explains any command.

**Leagues** can be typed naturally: `laliga`, `premier`, `championship`,
`champions`, `europa`, `serie a`, `bundesliga`, `ligue 1`, `mls`, `libertadores`,
`nba`, `nfl`, `nhl`, `f1`... `!leagues` lists them all. ESPN codes work too
(`eng.1`, `soccer/por.2`).

**Teams** are recognised by nicknames and short names (`man utd`, `spurs`,
`barça`, `psg`, `lakers`...) and any team in the world. If a name is
ambiguous, type it in full (`athletic club`).

---

## 1. Scores and information

Available to everyone.

| Command | What it does | Example |
|---|---|---|
| `!help [command]` | Command list or help for one | `!help match` |
| `!live [league\|sport\|team]` | Matches in play. Without arguments: the channel's leagues | `!live champions` |
| `!today [league\|team] [date]` | Matches of the day | `!today premier tomorrow` |
| `!match <team>` | Score, goals, cards, stats, venue, referee and win probability | `!match arsenal` |
| `!next <team\|league>` | Upcoming fixtures in every competition, with TV | `!next liverpool` |
| `!last <team\|league>` | Latest results and form | `!last chelsea` |
| `!table <league\|team> [group] [full]` | Standings: compact, around a team, or the full table in private | `!table premier` |
| `!scorers <league> [assists]` | Top scorers or top assists | `!scorers premier` |
| `!lineup <team>` | Starting XI and bench | `!lineup man city` |
| `!stats <team>` | Full match statistics | `!stats spurs` |
| `!form <team>` | Last 5 results | `!form newcastle` |
| `!h2h <team> vs <team>` | Head-to-head (historical with API-Football) | `!h2h arsenal vs spurs` |
| `!player <name>` | Profile, season stats, last 5 games and next game | `!player haaland` |
| `!prob <team>` | Win probability before or during the match | `!prob liverpool` |
| `!leagues [search]` | Available competitions | `!leagues brazil` |
| `!more` | Next page of a long answer | |
| `!about` | Version and HTTP transport | |

**Dates for `!today`**: `today`, `tomorrow`, `yesterday`, `+2`, `-1`, `25/12`,
`2026-12-25`.

---

## 2. Personal alerts

Each user sets up their own. Best done in private with the bot.

| Command | What it does | Example |
|---|---|---|
| `!follow <team>` | Private alerts for that team's matches, in any competition | `!follow arsenal` |
| `!follow league <league>` | Follow a whole competition | `!follow league premier` |
| `!follow player <name>` | Goal and card alerts for a player | `!follow player saka` |
| `!follow match <team>` | Only its next match | `!follow match chelsea` |
| `!unfollow <name\|number\|all>` | Stop following something | `!unfollow 2` |
| `!follows` | What you follow, numbered | |
| `!prefs` | Your settings | |
| `!lang <code>` | Your language: `en es pt fr it de` | `!lang en` |
| `!tz <Region/City>` | Your timezone | `!tz Europe/London` |
| `!set <setting> <value>` | See the table below | |

### `!set` settings

| Setting | Values | Example |
|---|---|---|
| `events` | Which alerts you get ([list](#7-alert-types)) | `!set events -start +cards` |
| `delivery` | `notice` or `msg` | `!set delivery msg` |
| `remind` | Minutes before kick-off (0 = off) | `!set remind 30` |
| `quiet` | Quiet hours | `!set quiet 00:00-08:00` |
| `dnd` | Do not disturb: `on` / `off` | `!set dnd on` |
| `digest` | Daily summary at that time (`off` = none) | `!set digest 09:00` |
| `dedupe` | Don't repeat in private what you already see in the channel | `!set dedupe off` |
| `missed` | Summary of what you missed when you come back | `!set missed on` |
| `style` | `full` (colours), `bold` or `plain` | `!set style bold` |
| `symbols` | `unicode` or `ascii` | `!set symbols ascii` |
| `home` | Your default channel for the prediction game | `!set home #football` |
| `lang` / `tz` | Same as `!lang` / `!tz` | `!set tz America/New_York` |

---

## 3. Live commentary

| Command | What it does |
|---|---|
| `!narrate <team> [full\|normal\|brief]` | Minute-by-minute commentary of the match. If it starts within the next 24 h, it is booked (preview and line-ups included) |
| `!narrate off [n]` | Stop the channel's commentary (or only number `n`) |
| `!narrate list` | Active commentaries |

- Styles: `full` (everything: chances, saves, substitutions, pressure...),
  `normal`, `brief` (only the key moments).
- In a channel, only ops can start commentary by default (`!mdset narrperm`).
- In private anyone can ask for it, and it goes only to that person.
- While a match is being commentated in a channel, its regular alerts are
  replaced by the commentary.
- To **always** commentate a team's matches, use `!mdset autonarr`
  (section 5).

---

## 4. Prediction game

| Command | What it does | Example |
|---|---|---|
| `!predict <team> <goals>-<goals> [opponent]` | Predict a score. The first number is for the team you name. With an opponent, that match is picked even if the team plays another one earlier. Can be changed until kick-off | `!predict arsenal 2-1 spurs` |
| `!preds [team]` | Your open predictions, or everyone's for a match (revealed at kick-off) | `!preds arsenal` |
| `!porra` | Matches open for predictions in the next 48 h | |
| `!ranking [week\|month\|season\|all]` | Leaderboard | `!ranking week` |

**Points** (configurable in `matchday.conf`):

- Exact score: **3**.
- Right winner and goal difference: **2**.
- Right winner (or draw) only: **1**.

Predictions settle automatically at full time. They are voided if the match is
called off.

**Op commands:**

| Command | What it does | Example |
|---|---|---|
| `!porra feature <team> [vs opponent] [x3]` | Featured match: points ×2 (or the multiplier you give) | `!porra feature arsenal vs spurs x3` |
| `!porra on` / `!porra off` | Turn the prediction game on or off in the channel | |
| `!porra reset` (admin) | Reset the leaderboard; the old one is archived | |

---

## 5. Channel configuration — `!mdset`

For channel ops (or users with the `o` flag on the bot). The channel must first
be enabled on the partyline: `.chanset #channel +matchday`.

From outside the channel (in private): `!mdset #channel <setting> <value>`.

| Command | What it does |
|---|---|
| `!mdset` | Show the channel configuration |
| `!mdset leagues add premier, champions` | Add competitions. Also `del`, `clear`, or a plain list to set them |
| `!mdset teams add boca juniors` | Follow a team even if its league isn't added (`del`, `clear`) |
| `!mdset autonarr add arsenal` | Automatically commentate every match of that team (`del`, `clear`) |
| `!mdset narrstyle full\|normal\|brief` | Style of the automatic commentary |
| `!mdset events -cards +videos` | Which alerts are posted in the channel ([list](#7-alert-types)) |
| `!mdset hotscope leagues\|all` | "Hot match" alerts only for the channel's leagues, or for every league the bot watches |
| `!mdset lang en` | Channel language |
| `!mdset tz Europe/London` | Channel timezone |
| `!mdset style full\|bold\|plain` | Colours, bold only or plain text |
| `!mdset symbols unicode\|ascii` | ⚽ ▮ symbols or text |
| `!mdset prefix .` | Command prefix (1-3 symbols) |
| `!mdset remind 15` | Reminder N minutes before each match (0 = off) |
| `!mdset digest 10:00` | Daily round-up of the day's matches (`off` = none) |
| `!mdset porra on\|off` | Prediction game in the channel |
| `!mdset narrperm op\|voice\|any` | Who may request commentary |
| `!mdset maxnarr 3` | Simultaneous commentaries in the channel |
| `!mdset replies chan\|notice` | Command replies in the channel or by notice |
| `!mdset quiet on\|off` | Mute automatic alerts (commands keep working) |
| `!mdset cmds on\|off` | Enable or disable commands in the channel |

### Example: Premier League and Champions League scores, commentary for Arsenal only

```
!mdset lang en
!mdset tz Europe/London
!mdset leagues add premier, champions
!mdset autonarr add arsenal
!mdset narrstyle full
```

---

## 6. Administration — `!md` in a channel or in private, `.matchday` on the partyline

Requires the `+m` flag on the bot (configurable with `admin.flags`).

| Command | What it does |
|---|---|
| `!md status` | Status: transport (tls/curl), requests, watched leagues, errors, API-Football quota |
| `!md reload` | Reload the script in place |
| `!md save` | Save data now |
| `!md enable #channel` / `!md disable #channel` | Enable or disable the bot in a channel |
| `!md alias add <nickname> <team>` | Custom nickname: `!md alias add gunners arsenal` |
| `!md alias del <nickname>` | Delete a nickname |
| `!md demo [#channel]` | Replay a finished match at high speed, for testing |
| `!md replay <league> <eventId> [speed] [#channel]` | Replay a specific ESPN match |
| `!md flush` | Clear the download cache |
| `!md debug on\|off` | Verbose logging |
| `!md conf <key> [value]` | Show or change a `matchday.conf` option at runtime |

---

## 7. Alert types

For `!mdset events` (channel) and `!set events` (user).

| Key | Alert |
|---|---|
| `goals` | Goals (and VAR-disallowed goals) |
| `reds` | Red cards |
| `cards` | Yellow cards (off by default) |
| `pens` | Missed penalties and shoot-outs |
| `start` | Kick-off |
| `ht` | Half-time |
| `ft` | Full-time |
| `status` | Postponed, suspended, delayed |
| `alerts` | Alerts for matches users follow |
| `reminders` | Reminder before kick-off (users only by default) |
| `hot` | Hot match: goal flurries, comebacks, upsets |
| `videos` | Highlight clips after full time |

How to combine them:

- `+key` adds and `-key` removes: `!mdset events -start +cards`.
- `all` turns everything on.
- A list sets them exactly: `!mdset events goals,reds,ft`.

---

## 8. Aliases in other languages

| English | Español | Português | Français | Italiano | Deutsch |
|---|---|---|---|---|---|
| `table` | `clasificacion` | `tabela` | `classement` | `classifica` | `tabelle` |
| `today` | `hoy` | `hoje` | `aujourdhui` | `oggi` | `heute` |
| `player` | `jugador` | `jogador` | `joueur` | `giocatore` | `spieler` |

The full alias list for each language is at the top of its file in `lang/`
(the `::md::i18n::cmds` block), and `!help` shows it in the channel's language.
