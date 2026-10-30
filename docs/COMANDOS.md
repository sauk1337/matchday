# Matchday — guía completa de comandos

[English](COMMANDS.md) | **Español** · [← Volver al README](../README.es.md)

## Cómo se usan

- En el canal, los comandos llevan el prefijo `!`. Cada canal puede cambiarlo con
  `!mdset prefix`.
- Por privado al bot funcionan **sin prefijo**: `/msg Bot today`. Las palabras
  que Eggdrop ya usa por privado (`help`, `info`, `op`, `pass`...) necesitan el
  `!`: `/msg Bot !help`.
- Cada comando tiene un nombre en inglés y alias en otros idiomas, y todos
  funcionan siempre. En esta guía va el nombre en inglés y, entre paréntesis,
  el alias en castellano.
- Las respuestas largas se cortan: `!more` (`!mas`) muestra el resto.
- `!help <comando>` explica cualquier comando.

**Ligas**: se escriben de forma natural: `laliga`, `segunda`, `premier`,
`champions`, `europa`, `serie a`, `bundesliga`, `ligue 1`, `libertadores`,
`nba`, `nfl`, `nhl`, `f1`... `!leagues` las lista todas. También vale el código
de ESPN (`esp.1`, `soccer/por.2`).

**Equipos**: se reconocen apodos y nombres cortos (`barça`, `atleti`,
`man utd`, `psg`, `lakers`...) y cualquier equipo del mundo. Si un nombre es
ambiguo, escríbelo completo (`athletic club`).

---

## 1. Resultados e información

Disponibles para todo el mundo.

| Comando | Qué hace | Ejemplo |
|---|---|---|
| `!help [comando]` (`!ayuda`) | Lista de comandos o ayuda de uno | `!help match` |
| `!live [liga\|deporte\|equipo]` (`!directo`) | Partidos en juego. Sin nada: las ligas del canal | `!live champions` |
| `!today [liga\|equipo] [fecha]` (`!hoy`) | Partidos del día | `!today laliga tomorrow` |
| `!match <equipo>` (`!partido`) | Marcador, goles, tarjetas, estadísticas, estadio, árbitro y probabilidad | `!match betis` |
| `!next <equipo\|liga>` (`!proximo`) | Próximos partidos de todas sus competiciones, con TV | `!next atleti` |
| `!last <equipo\|liga>` (`!ultimo`) | Últimos resultados y racha | `!last barça` |
| `!table <liga\|equipo> [grupo] [full]` (`!clasificacion`) | Clasificación compacta, alrededor de un equipo, o completa por privado | `!table premier` |
| `!scorers <liga> [assists]` (`!goleadores`) | Máximos goleadores o asistentes | `!scorers laliga` |
| `!lineup <equipo>` (`!alineacion`) | Onces y banquillo | `!lineup madrid` |
| `!stats <equipo>` (`!estadisticas`) | Estadísticas completas del partido | `!stats sevilla` |
| `!form <equipo>` (`!forma`) | Últimos 5 resultados | `!form valencia` |
| `!h2h <equipo> vs <equipo>` (`!cara`) | Cara a cara (histórico con API-Football) | `!h2h madrid vs barça` |
| `!player <nombre>` (`!jugador`) | Ficha, estadísticas de la temporada, últimos 5 partidos y próximo | `!player lamine yamal` |
| `!prob <equipo>` (`!probabilidad`) | Probabilidad de victoria antes o durante el partido | `!prob madrid` |
| `!leagues [búsqueda]` (`!ligas`) | Competiciones disponibles | `!leagues argentina` |
| `!more` (`!mas`) | Siguiente página de una respuesta larga | |
| `!about` (`!acerca`) | Versión y transporte HTTP | |

**Fechas para `!today`**: `today`/`hoy`, `tomorrow`/`mañana`,
`yesterday`/`ayer`, `+2`, `-1`, `25/12`, `2026-12-25`.

---

## 2. Avisos personales

Cada usuario configura lo suyo. Mejor por privado al bot.

| Comando | Qué hace | Ejemplo |
|---|---|---|
| `!follow <equipo>` (`!seguir`) | Avisos privados de los partidos de ese equipo, en cualquier competición | `!follow real madrid` |
| `!follow league <liga>` | Sigue una competición entera | `!follow league laliga` |
| `!follow player <nombre>` | Avisos de goles y tarjetas de un jugador | `!follow player mbappe` |
| `!follow match <equipo>` | Solo su próximo partido | `!follow match betis` |
| `!unfollow <nombre\|número\|all>` (`!dejar`) | Deja de seguir algo | `!unfollow 2` |
| `!follows` (`!siguiendo`) | Lo que sigues, numerado | |
| `!prefs` (`!preferencias`) | Tus ajustes | |
| `!lang <código>` (`!idioma`) | Tu idioma: `en es pt fr it de` | `!lang es` |
| `!tz <Región/Ciudad>` (`!zona`) | Tu zona horaria | `!tz Europe/Madrid` |
| `!set <ajuste> <valor>` (`!ajustar`) | Ver tabla siguiente | |

### Ajustes de `!set`

| Ajuste | Valores | Ejemplo |
|---|---|---|
| `events` | Qué avisos recibes ([lista](#7-tipos-de-aviso)) | `!set events -start +cards` |
| `delivery` | `notice` o `msg` | `!set delivery msg` |
| `remind` | Minutos de antelación antes del inicio (0 = no) | `!set remind 30` |
| `quiet` | Horario de silencio | `!set quiet 00:00-08:00` |
| `dnd` | No molestar: `on` / `off` | `!set dnd on` |
| `digest` | Resumen diario a esa hora (`off` = no) | `!set digest 09:00` |
| `dedupe` | No repetir por privado lo que ya ves en el canal | `!set dedupe off` |
| `missed` | Resumen de lo que te perdiste al volver | `!set missed on` |
| `style` | `full` (colores), `bold` o `plain` | `!set style bold` |
| `symbols` | `unicode` o `ascii` | `!set symbols ascii` |
| `home` | Tu canal por defecto para la porra | `!set home #futbol` |
| `lang` / `tz` | Igual que `!lang` / `!tz` | `!set tz America/Mexico_City` |

---

## 3. Narración en directo

| Comando | Qué hace |
|---|---|
| `!narrate <equipo> [full\|normal\|brief]` (`!narrar`) | Narra el partido minuto a minuto. Si empieza en las próximas 24 h, lo reserva (previa y alineaciones incluidas) |
| `!narrate off [n]` | Para las narraciones del canal (o solo la número `n`) |
| `!narrate list` | Narraciones activas |

- Estilos: `full` (todo: ocasiones, paradas, cambios, presión...), `normal`, `brief`
  (solo lo importante). En castellano también `completa` y `breve`.
- En un canal, por defecto solo los ops pueden narrar (`!mdset narrperm`).
- Por privado lo puede pedir cualquiera, y la narración llega solo a esa persona.
- Mientras se narra un partido en un canal, sus avisos normales se sustituyen por
  la narración.
- Para narrar **siempre** los partidos de un equipo, usa `!mdset autonarr`
  (apartado 5).

---

## 4. Porra

| Comando | Qué hace | Ejemplo |
|---|---|---|
| `!predict <equipo> <goles>-<goles> [rival]` (`!pronostico`) | Pronostica un resultado. El primer número es para el equipo que nombras. Con rival, elige ese partido aunque el equipo juegue antes otro. Se puede cambiar hasta el inicio | `!predict madrid 2-1 sevilla` |
| `!preds [equipo]` (`!pronosticos`) | Tus pronósticos abiertos, o los de todos en un partido (se revelan al empezar) | `!preds madrid` |
| `!porra` (`!quiniela`) | Partidos abiertos en las próximas 48 h | |
| `!ranking [week\|month\|season\|all]` (`!clasificacionporra`) | Clasificación (`semana`, `mes`, `temporada`, `todo`) | `!ranking week` |

**Puntos** (configurables en `matchday.conf`):

- Resultado exacto: **3**.
- Ganador y diferencia de goles: **2**.
- Solo el ganador (o el empate): **1**.

Los pronósticos se resuelven solos al final del partido. Si se suspende, se anulan.

**Comandos de ops:**

| Comando | Qué hace | Ejemplo |
|---|---|---|
| `!porra feature <equipo> [vs rival] [x3]` (`destacar`) | Partido destacado: puntos ×2 (o lo que indiques) | `!porra feature madrid vs barça x3` |
| `!porra on` / `!porra off` | Activa o desactiva la porra en el canal | |
| `!porra reset` (admin) | Reinicia la clasificación; la anterior queda archivada | |

---

## 5. Configuración del canal — `!mdset` (`!configurar`)

Para ops del canal (o usuarios con flag `o` en el bot). El canal debe estar
activado antes en la partyline: `.chanset #canal +matchday`.

Desde fuera del canal (por privado): `!mdset #canal <ajuste> <valor>`.

| Comando | Qué hace |
|---|---|
| `!mdset` | Ver la configuración del canal |
| `!mdset leagues add laliga, premier` | Añadir competiciones. También `del`, `clear`, o una lista para fijarlas |
| `!mdset teams add boca juniors` | Seguir un equipo aunque su liga no esté (`del`, `clear`) |
| `!mdset autonarr add athletic club` | Narrar automáticamente todos los partidos de ese equipo (`del`, `clear`) |
| `!mdset narrstyle full\|normal\|brief` | Estilo de la narración automática |
| `!mdset events -cards +videos` | Qué avisos salen en el canal ([lista](#7-tipos-de-aviso)) |
| `!mdset hotscope leagues\|all` | Avisos de "partido caliente" solo de las ligas del canal o de todas las vigiladas |
| `!mdset lang es` | Idioma del canal |
| `!mdset tz Europe/Madrid` | Zona horaria del canal |
| `!mdset style full\|bold\|plain` | Colores, solo negrita o texto plano |
| `!mdset symbols unicode\|ascii` | Símbolos ⚽ ▮ o texto |
| `!mdset prefix .` | Prefijo de los comandos (1-3 símbolos) |
| `!mdset remind 15` | Aviso N minutos antes de cada partido (0 = no) |
| `!mdset digest 10:00` | Resumen diario de la jornada (`off` = no) |
| `!mdset porra on\|off` | Porra en el canal |
| `!mdset narrperm op\|voice\|any` | Quién puede pedir narraciones |
| `!mdset maxnarr 3` | Narraciones simultáneas en el canal |
| `!mdset replies chan\|notice` | Respuestas a comandos en el canal o por notice |
| `!mdset quiet on\|off` | Silenciar los avisos automáticos (los comandos siguen) |
| `!mdset cmds on\|off` | Activar o desactivar los comandos en el canal |

### Ejemplo: resultados de LaLiga y Champions, narración solo del Athletic

```
!mdset lang es
!mdset tz Europe/Madrid
!mdset leagues add laliga, champions
!mdset autonarr add athletic club
!mdset narrstyle full
```

---

## 6. Administración — `!md` en el canal o por privado, `.matchday` en la partyline

Requiere el flag `+m` en el bot (configurable con `admin.flags`).

| Comando | Qué hace |
|---|---|
| `!md status` | Estado: transporte (tls/curl), peticiones, ligas vigiladas, errores, cuota de API-Football |
| `!md reload` | Recarga el script en caliente |
| `!md save` | Guarda los datos ahora |
| `!md enable #canal` / `!md disable #canal` | Activa o desactiva el bot en un canal |
| `!md alias add <apodo> <equipo>` | Apodo propio: `!md alias add leones athletic club` |
| `!md alias del <apodo>` | Borrar un apodo |
| `!md demo [#canal]` | Reproduce acelerado un partido ya jugado, para probar |
| `!md replay <liga> <idPartido> [velocidad] [#canal]` | Reproduce un partido concreto de ESPN |
| `!md flush` | Vacía la caché de descargas |
| `!md debug on\|off` | Registro detallado |
| `!md conf <clave> [valor]` | Ver o cambiar una opción de `matchday.conf` en caliente |

---

## 7. Tipos de aviso

Para `!mdset events` (canal) y `!set events` (usuario).

| Clave | Aviso |
|---|---|
| `goals` | Goles (y goles anulados por VAR) |
| `reds` | Expulsiones |
| `cards` | Amarillas (desactivado por defecto) |
| `pens` | Penaltis fallados y tandas |
| `start` | Inicio del partido |
| `ht` | Descanso |
| `ft` | Final |
| `status` | Aplazados, suspendidos, retrasos |
| `alerts` | Avisos de partidos que siguen los usuarios |
| `reminders` | Recordatorio antes del inicio (por defecto solo usuarios) |
| `hot` | Partido caliente: lluvia de goles, remontadas, sorpresas |
| `videos` | Vídeos de resumen tras el final |

Cómo se combinan:

- `+clave` añade y `-clave` quita: `!mdset events -start +cards`.
- `all` activa todos.
- Una lista los fija exactamente: `!mdset events goals,reds,ft`.

---

## 8. Alias en otros idiomas

| Inglés | Castellano | Português | Français | Italiano | Deutsch |
|---|---|---|---|---|---|
| `table` | `clasificacion` | `tabela` | `classement` | `classifica` | `tabelle` |
| `today` | `hoy` | `hoje` | `aujourdhui` | `oggi` | `heute` |
| `player` | `jugador` | `jogador` | `joueur` | `giocatore` | `spieler` |

La lista completa de alias de cada idioma está al principio de su fichero en
`lang/` (bloque `::md::i18n::cmds`), y `!help` la muestra en el idioma del
canal.
