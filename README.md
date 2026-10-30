# Matchday — deporte en directo para Eggdrop

Script para **Eggdrop** (Tcl puro) que convierte tu bot de IRC en un centro de
resultados deportivos en directo: avisos de goles al instante, narración de
partidos estilo radio, avisos personales, porra con clasificación,
clasificaciones, goleadores, alineaciones, estadísticas, fichas de jugadores,
probabilidad de victoria y un panel web.

**Autosuficiente**: no necesita ninguna clave de API (usa los datos públicos de
ESPN), ni servicios externos, ni base de datos. Opcionalmente se integra con
API-Football.

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

Narración en castellano (extracto real del Inter 3-4 Brujas):

```
♪ ➜ 26' ¡AL PALO! ¡Nicolo Tresoldi estrella el balón en la madera!
♪ ⚽ ¡GOOOL! Penalti transformado por Nicolo Tresoldi, 30'. Inter Milan 0-1 Club Brugge
♪ ⚽ ¡GOOOL! ¡Todo igualado! Lautaro Martínez pone las tablas (44'). Inter Milan 1-1 Club Brugge (asistencia de Federico Dimarco)
♪ ⚽ ¡GOOOL! ★ ¡HAT-TRICK de Nicolo Tresoldi! (74') Inter Milan 1-3 Club Brugge
♪ ⏰ Cinco minutos para el final y el Club Brugge ya acaricia la victoria. Inter Milan 2-3 Club Brugge
♪ ■ ¡FINAL DEL PARTIDO! Inter Milan 3-4 Club Brugge — ¡victoria del Club Brugge!
```

Ficha de jugador y probabilidad:

```
<usuario> !jugador mbappe
<Matchday> Kylian Mbappé · Real Madrid · Forward #10 · 27 y/o · France
<Matchday> 2026-27 LALIGA: 7 goals, 2 assists, 8 starts, 44 shots (24 on target), ▮1
<Matchday> Last 5: 4 G, 2 A · Next: Sevilla at Real Madrid (Sun 18/10 19:00, LALIGA)
<usuario> !prob real madrid
<Matchday> 19:00 AS Roma - Real Madrid [Champions League] · Win probability: AS Roma 26% · draw 24% · Real Madrid 50%
```

---

## Índice

- [Características](#características)
- [Requisitos](#requisitos)
- [Instalación paso a paso](#instalación-paso-a-paso)
- [Configuración rápida de un canal](#configuración-rápida-de-un-canal)
- [Comandos (resumen)](#comandos-resumen) · [Guía completa de comandos](docs/COMANDOS.md)
- [Configuración del script (`matchday.conf`)](#configuración-del-script-matchdayconf)
- [Narración automática de un equipo](#narración-automática-de-un-equipo)
- [Panel web](#panel-web)
- [API-Football (opcional)](#api-football-opcional)
- [Modelo de probabilidad](#modelo-de-probabilidad-fútbol)
- [Cómo funciona](#cómo-funciona)
- [Pruebas](#pruebas)
- [Añadir un idioma](#añadir-un-idioma)
- [Problemas frecuentes](#problemas-frecuentes)
- [Notas y licencia](#notas-y-licencia)

---

## Características

| Área | Qué hace |
|---|---|
| **Directo** | Goles con contexto (primer gol, empate, remontada, gol tardío, doblete, hat-trick, goleada), goles anulados por VAR, tarjetas, penaltis fallados, inicio, descanso, prórroga, tanda de penaltis, final, aplazado/suspendido. |
| **Otros deportes** | NBA/WNBA/NCAA, NFL, NHL, MLB, tenis ATP/WTA, F1/IndyCar/NASCAR, golf, UFC, rugby, AFL. **113 competiciones** en catálogo + cualquier liga de ESPN por su código (`soccer/por.2`). |
| **Narración** | Narrador con plantillas en 6 idiomas y cientos de variantes: paradas, palos, ocasiones, cambios, presión, tiempo añadido, tensión final, alineaciones, resumen de descanso y final. Estilos `full`, `normal`, `brief`. Al canal o por privado. **Automática** para los equipos que elijas. |
| **Personal** | Cada usuario sigue equipos, competiciones, jugadores o partidos y recibe avisos por notice/privado con su idioma, zona horaria, tipos de evento, recordatorios, horas de silencio, "no molestar", resumen diario y "lo que te perdiste". |
| **Información** | Clasificaciones, goleadores, próximos partidos, últimos resultados, detalle del partido, alineaciones, estadísticas, forma, cara a cara, partidos del día y en directo. |
| **Jugadores** | Ficha (equipo, posición, edad, nacionalidad), estadísticas de la temporada por competición, últimos 5 partidos y próximo partido. Cualquier deporte. |
| **Probabilidad** | Fútbol: modelo de Poisson ajustado a las cuotas previas y recalculado con marcador, minuto y expulsiones. NBA/NFL: probabilidad en directo de ESPN. |
| **Partido caliente** | Avisos de lluvia de goles, festival de goles, remontada, sorpresa en curso y campanada final. |
| **Vídeos** | Tras el final publica los vídeos de resumen (máx. 2 por partido). |
| **Porra** | Pronósticos por canal que se cierran al empezar y se resuelven solos; puntos configurables, partidos destacados, ranking semanal, mensual y de temporada. |
| **Idiomas** | Inglés por defecto + español, portugués, francés, italiano y alemán, por canal **y por usuario**. Los comandos funcionan en todos los idiomas (`!table`, `!clasificacion`, `!tabela`, `!classement`...). |
| **Panel web** | Servidor HTTP integrado: directo, partidos del día, feed de eventos, ranking de la porra y estado. API JSON. |
| **Robustez** | HTTP asíncrono (el bot nunca se bloquea), caché, backoff ante errores, datos persistentes con escritura atómica, recarga en caliente, antiflood, sin repetir eventos tras un reinicio. |

---

## Requisitos

- **Eggdrop 1.8.4 o superior** (recomendado 1.9 / 1.10) con **Tcl 8.6+**.
- Para HTTPS, **una** de estas dos (el script detecta cuál hay):
  - el paquete Tcl **tls** (recomendado), o
  - el programa **curl** (casi siempre instalado).

No hace falta nada más: el parser JSON va incluido.

---

## Instalación paso a paso

Las instrucciones son para Linux (Debian/Ubuntu). En otras distribuciones solo
cambia el gestor de paquetes.

### 1. Dependencias

```sh
sudo apt update
sudo apt install tcl tcl-tls curl
```

| Distribución | Paquete tls |
|---|---|
| Debian / Ubuntu | `sudo apt install tcl-tls` |
| Fedora / RHEL | `sudo dnf install tcltls` |
| Alpine | `apk add tcl-tls` |

`tcl` sirve para ejecutar las pruebas fuera de Eggdrop. Si no puedes instalar
`tls`, basta con `curl`.

### 2. Descargar el script

Dentro de la carpeta de tu Eggdrop (por ejemplo `~/eggdrop`):

```sh
cd ~/eggdrop/scripts
git clone https://github.com/TU_USUARIO/matchday.git
```

O descarga el ZIP desde GitHub y descomprímelo como `scripts/matchday`.
Lo importante es que exista `scripts/matchday/matchday.tcl`.

### 3. Comprobar que funciona (opcional, recomendado)

```sh
cd ~/eggdrop/scripts/matchday
tclsh tests/run_all.tcl          # pruebas sin conexión: debe acabar en "All tests passed."
tclsh tests/run_all.tcl live     # además, prueba real contra ESPN (1-2 minutos)
```

En la prueba `live`, la línea `HTTP: transport ...` del final indica si usa
`tls` o `curl`.

### 4. Configuración del script (opcional)

```sh
cp matchday.conf.example matchday.conf
nano matchday.conf
```

Todo tiene un valor por defecto. Lo más habitual es cambiar idioma y zona
horaria:

```tcl
set conf(lang.default)  es
set conf(tz.default)    Europe/Madrid
```

`matchday.conf` está en `.gitignore`: tus ajustes (y una posible clave de
API-Football) nunca se suben al repositorio.

### 5. Cargarlo en Eggdrop

Al final de `eggdrop.conf`:

```tcl
source scripts/matchday/matchday.tcl
```

La ruta es relativa a la carpeta desde la que arranca el bot. Después, en la
partyline (`/dcc chat TuBot`):

```
.rehash
```

En el log debe aparecer una línea de Matchday con la versión, el número de
competiciones y los idiomas cargados.

### 6. Activarlo en un canal

En la partyline:

```
.chanset #futbol +matchday
```

Y sigue con la [configuración rápida del canal](#configuración-rápida-de-un-canal).

### 7. Probarlo

```
!md demo            reproduce acelerado un partido ya jugado (requiere flag +m)
!hoy
!jugador mbappe
```

### Actualizar a una versión nueva

```sh
cd ~/eggdrop/scripts/matchday
git pull
```

y `.rehash` (o `!md reload`). Tu `matchday.conf` y la carpeta `data/` no se tocan.

---

## Configuración rápida de un canal

Como **op** en el canal:

```
!mdset lang es                              idioma del canal
!mdset tz Europe/Madrid                     zona horaria
!mdset leagues add laliga, champions        competiciones que se anuncian
!mdset                                      ver la configuración
```

Opcional:

```
!mdset events -videos +cards                qué avisos salen
!mdset remind 15                            aviso 15 min antes de cada partido
!mdset digest 10:00                         resumen diario de la jornada
!mdset teams add boca juniors               un equipo aunque su liga no esté
!mdset autonarr add athletic club           narrar SIEMPRE los partidos de ese equipo
!mdset narrstyle full                       estilo de esa narración automática
```

Para ver las competiciones disponibles: `!ligas` o `!ligas argentina`.

---

## Comandos (resumen)

Los comandos tienen nombre en inglés y alias en cada idioma; todos funcionan
siempre. Por privado al bot se escriben sin `!`.

| Inglés | Castellano | Qué hace |
|---|---|---|
| `!help` | `!ayuda` | Lista de comandos o ayuda de uno |
| `!live` | `!directo` | Partidos en juego |
| `!today` | `!hoy` | Partidos del día (`mañana`, `25/12`...) |
| `!match` | `!partido` | Detalle del partido de un equipo |
| `!next` / `!last` | `!proximo` / `!ultimo` | Próximos partidos / últimos resultados |
| `!table` | `!clasificacion` | Clasificación |
| `!scorers` | `!goleadores` | Goleadores o asistentes |
| `!lineup` / `!stats` | `!alineacion` / `!estadisticas` | Alineaciones / estadísticas |
| `!form` / `!h2h` | `!forma` / `!cara` | Racha / cara a cara |
| `!player` | `!jugador` | Ficha de un jugador |
| `!prob` | `!probabilidad` | Probabilidad de victoria |
| `!leagues` | `!ligas` | Competiciones disponibles |
| `!follow` / `!unfollow` / `!follows` | `!seguir` / `!dejar` / `!siguiendo` | Avisos personales |
| `!set` / `!prefs` / `!lang` / `!tz` | `!ajustar` / `!preferencias` / `!idioma` / `!zona` | Ajustes personales |
| `!narrate` | `!narrar` | Narración de un partido |
| `!predict` / `!preds` / `!porra` / `!ranking` | `!pronostico` / `!pronosticos` / `!quiniela` / `!clasificacionporra` | Porra |
| `!mdset` | `!configurar` | Configuración del canal (ops) |
| `!md` | | Administración (flag `+m`) |
| `!more` / `!about` | `!mas` / `!acerca` | Siguiente página / versión |

👉 **[Guía completa de comandos con ejemplos y todas las opciones](docs/COMANDOS.md)**

---

## Configuración del script (`matchday.conf`)

`matchday.conf.example` está comentado línea a línea. Las opciones más útiles:

| Opción | Por defecto | Para qué |
|---|---|---|
| `lang.default` | `en` | Idioma por defecto (`en es pt fr it de`) |
| `tz.default` | `UTC` | Zona horaria por defecto (`Europe/Madrid`) |
| `cmd.prefix` | `!` | Prefijo de comandos |
| `http.transport` | `auto` | `auto`, `tls` o `curl` |
| `poll.live` / `poll.idle` | `30` / `900` | Segundos entre consultas con partidos en juego / sin partidos |
| `chan.events` | todo menos `cards` | Avisos por defecto de un canal nuevo |
| `out.style` / `out.symbols` | `full` / `unicode` | Colores y símbolos |
| `out.max_per_minute` | `20` | Antiflood: líneas por minuto y destino |
| `narr.perm` | `op` | Quién puede narrar en un canal |
| `narr.auto_lead` | `3600` | Segundos antes del inicio en que arranca la narración automática |
| `hot.odds` | `1` | Descargar cuotas al inicio de cada partido de fútbol (probabilidad y avisos de sorpresa) |
| `videos.enabled` | `1` | Publicar vídeos de resumen |
| `preds.exact` / `diff` / `outcome` | `3` / `2` / `1` | Puntos de la porra |
| `web.port` | `0` | Puerto del panel web (0 = desactivado) |
| `apifootball.key` | vacío | Clave opcional de API-Football |
| `admin.flags` | `m\|-` | Flags de Eggdrop para `!md` |

Casi todo se puede cambiar también en caliente: `!md conf <clave> <valor>`.

---

## Narración automática de un equipo

```
!mdset autonarr add athletic club
!mdset narrstyle full
```

- Empieza sola `narr.auto_lead` segundos antes del inicio (1 h por defecto), con
  previa y alineaciones, en **todas** las competiciones del equipo.
- Mientras se narra un partido, sus avisos normales no se repiten en ese canal.
- Si un op escribe `!narrate off`, ese partido no se vuelve a narrar; el
  siguiente sí.
- Si el bot se reinicia durante el partido, retoma la narración.
- `!mdset autonarr del <equipo>` / `!mdset autonarr clear` para quitarlo.

---

## Panel web

En `matchday.conf`:

```tcl
set conf(web.port)  8088
set conf(web.bind)  127.0.0.1
set conf(web.token) "cambia-esto"     ;# opcional: http://host:8088/?token=cambia-esto
```

Pestañas: Directo, Hoy, Feed de eventos, Porra y Estado. Se actualiza cada 15 s,
tiene modo oscuro y funciona en el móvil. API JSON: `/api/live`,
`/api/ranking?chan=%23canal&period=season`, `/api/status`, `/api/events`.

Es de solo lectura. Para publicarlo en Internet, déjalo en `127.0.0.1` y ponlo
detrás de nginx o caddy con HTTPS.

---

## API-Football (opcional)

```tcl
set conf(apifootball.key)  "tu-clave"
set conf(apifootball.mode) extras    ;# o primary
```

- `extras` (recomendado): ESPN sigue siendo la fuente; API-Football añade el
  **cara a cara histórico**. Cabe en el plan gratuito (100 peticiones/día).
- `primary`: usa API-Football para los marcadores de fútbol (necesita plan de
  pago). Si falla, vuelve a ESPN.

La clave va solo en `matchday.conf`, que no se sube a GitHub.

---

## Modelo de probabilidad (fútbol)

1. Antes del partido se leen las cuotas 1X2, se quita el margen de la casa y se
   ajustan los goles esperados de cada equipo para que un modelo de Poisson
   reproduzca esas probabilidades.
2. Durante el partido, los goles esperados que quedan se escalan por el tiempo
   restante (con un añadido típico) y se corrigen por expulsiones (−28 % para el
   equipo con diez, +22 % para el rival).
3. Se combina con el marcador actual: P(local / empate / visitante).

Ejemplo real (Inter–Brujas, Inter favorito al 78 %): tras el penalti del Brujas
al 30' baja al 43 %; con el empate del 44' sube al 63 %. Sin cuotas se usan
valores neutros y se indica "sin cuotas".

---

## Cómo funciona

```
              ┌──────────────── providers ───────────────┐
 ESPN ─────▶  │ espn.tcl  apifootball.tcl  (normalizan)  │
              └──────────────────┬────────────────────────┘
                                 ▼
  poller.tcl  sondeo adaptativo: 30 s con partidos en juego, 60 s cerca del
              inicio, duerme hasta poco antes del siguiente partido
                                 ▼
  diff.tcl    compara instantáneas → eventos (gol, VAR, tarjeta, descanso...)
              con memoria persistente: nunca repite un gol tras un reinicio
                                 ▼
  dispatch    ─▶ canales (filtros por liga/equipo/evento)
              ─▶ usuarios (seguimientos, idioma, silencio, notice/privado)
              ─▶ hooks: narrador, porra, partido caliente, vídeos, panel web
                                 ▼
  out.tcl     colores por rol, unicode/ascii, troceo por bytes, fusión de
              eventos simultáneos, antiflood, !more
```

Solo se consultan las competiciones que alguien necesita (canales, usuarios,
equipos seguidos que juegan pronto, narraciones, porras abiertas).

### Estructura

```
matchday.tcl            cargador (recarga limpia con .rehash / !md reload)
matchday.conf.example   configuración comentada (copiar a matchday.conf)
lib/        util, json, http (tls/curl), store, i18n, out
engine/     catalog, poller, diff, render, dispatch, teams, prob
providers/  espn, apifootball
features/   commands, info, usercmds, admin, chan, subs, narrator,
            predictions, replay, player, hot, videos, web
lang/       en es pt fr it de
web/        index.html (panel)
tests/      simulador de Eggdrop + 157 pruebas con datos reales grabados
docs/       COMANDOS.md (guía completa de comandos)
data/       (se crea sola) usuarios, porra, estado, índice de equipos
```

---

## Pruebas

```sh
tclsh tests/run_all.tcl                          # batería completa sin conexión
tclsh tests/run_all.tcl live                     # + comprobación contra la API real
tclsh -encoding utf-8 tests/demo_output.tcl es   # ver un partido simulado en el canal
```

Las pruebas usan un simulador de Eggdrop (`tests/eggstub.tcl`) y respuestas
reales de ESPN grabadas en `tests/fixtures/`.

---

## Añadir un idioma

1. Copia `lang/en.tcl` a `lang/xx.tcl`.
2. Cambia la primera línea (`::md::i18n::lang xx Name NativeName`).
3. Traduce los textos y añade alias de comandos en `::md::i18n::cmds`.
4. `.rehash` y `!mdset lang xx`.

Lo que no traduzcas cae automáticamente al inglés. Los plurales se escriben
como `%{n} %{n:gol|goles}`.

---

## Problemas frecuentes

| Síntoma | Solución |
|---|---|
| `No tls package and no curl found` | Instala `tcl-tls` o `curl` |
| No anuncia nada | `.chanset #canal +matchday`, que `!mdset` muestre ligas y que `!md status` no tenga errores |
| `!md` no responde | Tu usuario necesita `+m`: `.chattr TuNick +m` |
| Las horas salen mal | `!mdset tz Europe/Madrid` (canal) o `!tz ...` (usuario) |
| El canal tiene modo `+c` | El bot lo detecta y envía sin colores; también `!mdset style bold` |
| Se ven símbolos raros | `!mdset symbols ascii` |
| `error reading package index file .../ttkthemes/...` al probar | Avisos de paquetes gráficos de Tk instalados en el sistema; inofensivos |
| Error al cargar | `.console +d` en la partyline, luego `.rehash`, y revisa el mensaje |

---

## Notas y licencia

- ESPN no publica una API oficial: el script usa los mismos endpoints públicos
  que su web, estables desde hace años pero que podrían cambiar. Toda la lectura
  está aislada en `providers/espn.tcl`. Este proyecto no está afiliado ni
  respaldado por ESPN ni por API-Football.
- La narración se basa en los eventos y jugadas que publica el proveedor; si una
  jugada no aparece en sus datos, no se narra.
- Licencia MIT: ver [LICENSE](LICENSE).
