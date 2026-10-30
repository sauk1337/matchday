# Matchday - features/admin.tcl
# Channel configuration (!mdset, channel ops) and bot administration
# (!md / .matchday, Eggdrop +m users).

namespace eval ::md::adm {}

proc ::md::adm::chan_keys {} {
    return {leagues teams events hotscope lang tz style symbols prefix remind porra narrperm maxnarr autonarr narrstyle digest replies quiet cmds}
}

# ---------------------------------------------------------------- !mdset

proc ::md::adm::c_mdset {ctx argv} {
    set lang [dict get $ctx lang]
    set chan [dict get $ctx chan]
    if {[string index [lindex $argv 0] 0] in {# &}} {
        set chan [lindex $argv 0]
        set argv [lrange $argv 1 end]
    }
    if {$chan eq "" || ![validchan $chan]} { ::md::cmd::err $ctx cfg.needchan; return }
    if {![::md::cmd::is_chanop $ctx $chan]} { ::md::cmd::err $ctx err.perm; return }
    if {![llength $argv]} {
        _show $ctx $chan
        return
    }
    set key [string tolower [lindex $argv 0]]
    set kmap {ligas leagues ligues leagues campionati leagues equipos teams squadre teams equipes teams
              eventos events idioma lang langue lang lingua lang zona tz estilo style prefijo prefix
              recordatorio remind narrar narrperm resumen digest respuestas replies silencio quiet comandos cmds
              autonarrar autonarr narracionauto autonarr estilonarracion narrstyle}
    if {[dict exists $kmap $key]} { set key [dict get $kmap $key] }
    set rest [lrange $argv 1 end]
    set val [join $rest]
    switch -- $key {
        leagues {
            set cur [::md::chan::get $chan leagues]
            lassign [_listop $rest] op items
            set new $cur
            set bad {}
            set resolved {}
            foreach it [split [join $items " "] ","] {
                set it [string trim $it]
                if {$it eq ""} continue
                set k [::md::catalog::find $it]
                if {$k eq ""} {
                    # space separated keys ("esp.1 eng.1")
                    foreach w [split $it] {
                        if {$w eq ""} continue
                        set k2 [::md::catalog::find $w]
                        if {$k2 eq ""} { lappend bad $w } else { lappend resolved $k2 }
                    }
                } else {
                    lappend resolved $k
                }
            }
            if {[llength $bad]} { ::md::cmd::err $ctx err.league_notfound query [join $bad ", "]; return }
            switch -- $op {
                add { set new [::md::luniq [concat $cur $resolved]] }
                del { foreach k $resolved { set new [::md::lremove $new $k] } }
                clear { set new {} }
                default { set new [::md::luniq $resolved] }
            }
            ::md::chan::put $chan leagues $new
            set labels {}
            foreach k $new { lappend labels "[::md::catalog::label $k] ($k)" }
            ::md::reply $ctx [::md::t $lang cfg.set key leagues value [expr {[llength $labels] ? [join $labels ", "] : "-"}]]
        }
        teams {
            lassign [_listop $rest] op items
            if {$op eq "clear"} {
                ::md::chan::put $chan teams {}
                ::md::reply $ctx [::md::t $lang cfg.set key teams value "-"]
                return
            }
            if {![llength $items]} { ::md::cmd::usage $ctx mdset; return }
            ::md::cmd::with_team $ctx [join $items] [list ::md::adm::_team $ctx $chan $op]
        }
        autonarr {
            lassign [_listop $rest] op items
            if {$op eq "clear"} {
                ::md::chan::put $chan autonarr {}
                ::md::reply $ctx [::md::t $lang cfg.set key autonarr value "-"]
                return
            }
            if {![llength $items]} { ::md::cmd::usage $ctx mdset; return }
            ::md::cmd::with_team $ctx [join $items] [list ::md::adm::_autonarr $ctx $chan $op]
        }
        narrstyle {
            set smap {full full completa full completo full complet full komplett full
                      normal normal normale normal brief brief breve brief corta brief court brief kurz brief}
            set v [::md::norm $val]
            if {![dict exists $smap $v]} { ::md::cmd::err $ctx set.badvalue key narrstyle values "full, normal, brief"; return }
            ::md::chan::put $chan narrstyle [dict get $smap $v]
            ::md::reply $ctx [::md::t $lang cfg.set key narrstyle value [dict get $smap $v]]
        }
        events {
            if {[catch {::md::ucmd::parse_events [::md::chan::get $chan events] $val} ev]} {
                ::md::cmd::err $ctx set.badvalue key events values [join [::md::dispatch::all_categories] ", "]
                return
            }
            ::md::chan::put $chan events $ev
            ::md::reply $ctx [::md::t $lang cfg.set key events value [join $ev ","]]
        }
        lang {
            if {![::md::i18n::valid $val]} { ::md::cmd::err $ctx set.badlang langs [join [::md::i18n::available] ", "]; return }
            ::md::chan::put $chan lang $val
            ::md::reply $ctx [::md::t $val cfg.set key lang value $val]
        }
        tz {
            if {![::md::validtz $val]} { ::md::cmd::err $ctx set.badtz; return }
            ::md::chan::put $chan tz $val
            ::md::reply $ctx [::md::t $lang cfg.set key tz value "$val ([::md::tfmt [clock seconds] %H:%M $val])"]
        }
        style - symbols - replies - narrperm - hotscope {
            set allowed [dict get {style {full bold plain} symbols {unicode ascii} replies {chan notice} narrperm {op voice any} hotscope {leagues all}} $key]
            if {$val ni $allowed} { ::md::cmd::err $ctx set.badvalue key $key values [join $allowed ", "]; return }
            ::md::chan::put $chan $key $val
            ::md::reply $ctx [::md::t $lang cfg.set key $key value $val]
        }
        prefix {
            if {[string length $val] < 1 || [string length $val] > 3 || [string match {*[a-zA-Z0-9 ]*} $val]} {
                ::md::cmd::err $ctx set.badvalue key prefix values "! . @ ?"
                return
            }
            ::md::chan::put $chan prefix $val
            ::md::reply $ctx [::md::t $lang cfg.set key prefix value $val]
        }
        remind - maxnarr {
            set max [expr {$key eq "remind" ? 180 : 10}]
            if {![string is integer -strict $val] || $val < 0 || $val > $max} { ::md::cmd::err $ctx set.badvalue key $key values "0-$max"; return }
            ::md::chan::put $chan $key $val
            ::md::reply $ctx [::md::t $lang cfg.set key $key value $val]
        }
        porra - quiet - cmds {
            set v [::md::ucmd::onoff $val]
            if {$v eq ""} { ::md::cmd::err $ctx set.badvalue key $key values "on, off"; return }
            ::md::chan::put $chan $key $v
            ::md::reply $ctx [::md::t $lang cfg.set key $key value [expr {$v ? "on" : "off"}]]
        }
        digest {
            if {[::md::ucmd::onoff $val] eq "0"} { set val "" } elseif {[::md::hm2min $val] eq ""} {
                ::md::cmd::err $ctx set.badvalue key digest values "09:00, off"; return
            }
            ::md::chan::put $chan digest $val
            ::md::reply $ctx [::md::t $lang cfg.set key digest value [expr {$val eq "" ? "off" : $val}]]
        }
        default {
            ::md::cmd::err $ctx set.unknown key $key keys [join [chan_keys] ", "]
        }
    }
}

proc ::md::adm::_listop {words} {
    set op set
    set w [::md::norm [lindex $words 0]]
    if {$w in {add anadir agregar ajouter aggiungi hinzufugen adicionar +}} { set op add; set words [lrange $words 1 end] }
    if {$w in {del remove quitar borrar eliminar retirer rimuovi entfernen remover -}} { set op del; set words [lrange $words 1 end] }
    if {$w in {clear none ninguna limpiar vider pulisci leeren limpar}} { set op clear; set words {} }
    list $op $words
}

proc ::md::adm::_team {ctx chan op tkey} {
    set cur [::md::chan::get $chan teams]
    switch -- $op {
        del { set new [::md::lremove $cur $tkey] }
        default { set new [::md::luniq [concat $cur [list $tkey]]] }
    }
    ::md::chan::put $chan teams $new
    ::md::teams::schedule $tkey 1 [list ::md::teams::_noop]
    set labels {}
    foreach k $new { lappend labels [::md::teams::label $k] }
    ::md::reply $ctx [::md::t [dict get $ctx lang] cfg.set key teams value [expr {[llength $labels] ? [join $labels ", "] : "-"}]]
}

proc ::md::adm::_autonarr {ctx chan op tkey} {
    set cur [::md::chan::get $chan autonarr]
    switch -- $op {
        del { set new [::md::lremove $cur $tkey] }
        default { set new [::md::luniq [concat $cur [list $tkey]]] }
    }
    ::md::chan::put $chan autonarr $new
    # learn its fixtures now so the next match is found in time
    ::md::teams::schedule $tkey 1 [list ::md::teams::_noop]
    set labels {}
    foreach k $new { lappend labels [::md::teams::label $k] }
    ::md::reply $ctx [::md::t [dict get $ctx lang] cfg.set key autonarr value [expr {[llength $labels] ? [join $labels ", "] : "-"}]]
}

proc ::md::adm::_show {ctx chan} {
    set lang [dict get $ctx lang]
    set d [::md::chan::all $chan]
    set parts {}
    foreach k [chan_keys] {
        set v [dict get $d $k]
        switch -- $k {
            leagues { set v [join $v ","] }
            teams - autonarr { set t {}; foreach x $v { lappend t [::md::teams::label $x] }; set v [join $t ","] }
            events { set v [join $v ","] }
            porra - quiet - cmds { set v [expr {$v ? "on" : "off"}] }
        }
        if {$v eq ""} { set v "-" }
        lappend parts "{b}$k{b}=$v"
    }
    set en [expr {[::md::chan::enabled $chan] ? "{c:ok}ON{/c}" : "{c:err}OFF (.chanset $chan +matchday){/c}"}]
    ::md::reply_lines $ctx [::md::wrap "$chan $en: [join $parts " "]" 380]
}

# ---------------------------------------------------------------- !md (admin)

proc ::md::adm::c_admin {ctx argv} {
    set lang [dict get $ctx lang]
    set sub [string tolower [lindex $argv 0]]
    set rest [lrange $argv 1 end]
    switch -- $sub {
        "" - help {
            ::md::reply_lines $ctx [list "status | reload | save | enable #chan | disable #chan | alias add <alias> <team> | alias del <alias> | replay <league> <eventId> \[speed\] \[#chan\] | demo \[#chan\] | flush | debug on|off | conf <key> \[value\]"] 5
        }
        status { _status $ctx }
        reload {
            ::md::reply $ctx "Reloading Matchday..."
            after 100 [list ::md::reload]
        }
        save {
            ::md::poll::save
            ::md::store::flush
            ::md::reply $ctx "Saved."
        }
        enable - disable {
            set ch [lindex $rest 0]
            if {$ch eq "" && [dict get $ctx chan] ne ""} { set ch [dict get $ctx chan] }
            if {$ch eq "" || ![validchan $ch]} { ::md::cmd::err $ctx cfg.needchan; return }
            channel set $ch [expr {$sub eq "enable" ? "+matchday" : "-matchday"}]
            ::md::reply $ctx "$ch: [expr {$sub eq "enable" ? "+matchday" : "-matchday"}]"
        }
        alias {
            set op [string tolower [lindex $rest 0]]
            set alias [::md::norm [lindex $rest 1]]
            if {$op eq "del" && $alias ne ""} {
                ::md::db_unset aliases $alias
                ::md::reply $ctx "alias '$alias' removed"
                return
            }
            if {$op ne "add" || $alias eq "" || [llength $rest] < 3} {
                ::md::reply $ctx "alias add <alias> <team...> | alias del <alias>"
                return
            }
            ::md::cmd::with_team $ctx [join [lrange $rest 2 end]] [list ::md::adm::_alias $ctx $alias]
        }
        replay - demo {
            if {[info commands ::md::replay::c_replay] eq ""} { ::md::reply $ctx "replay module not loaded"; return }
            ::md::replay::c_replay $ctx $sub $rest
        }
        flush {
            ::md::http::flush_cache
            ::md::reply $ctx "HTTP cache flushed."
        }
        debug {
            set v [::md::ucmd::onoff [lindex $rest 0]]
            ::md::cfgset log.level [expr {$v eq "1" ? "debug" : "info"}]
            ::md::reply $ctx "log.level = [::md::cfg log.level]"
        }
        conf {
            set k [lindex $rest 0]
            if {$k eq ""} { ::md::reply $ctx "conf <key> \[value\]"; return }
            if {[llength $rest] > 1} {
                ::md::cfgset $k [join [lrange $rest 1 end]]
            }
            ::md::reply $ctx "$k = [::md::cfg $k <unset>]"
        }
        default { ::md::reply $ctx "unknown subcommand: $sub (try help)" }
    }
}

proc ::md::adm::_alias {ctx alias tkey} {
    ::md::db_set aliases $alias $tkey
    ::md::reply $ctx "alias '$alias' -> [::md::teams::label $tkey] ($tkey)"
}

proc ::md::adm::_status {ctx} {
    set h [::md::http::status]
    set up [expr {[clock seconds] - $::md::started}]
    set upt [format "%dd %02dh %02dm" [expr {$up / 86400}] [expr {$up % 86400 / 3600}] [expr {$up % 3600 / 60}]]
    set live [llength [::md::poll::matches "" in]]
    set total [llength [::md::poll::matches]]
    set lines {}
    lappend lines "{b}Matchday $::md::version{b} up $upt | transport [dict get $h transport] | requests [dict get $h requests] (errors [dict get $h errors], cache hits [dict get $h cachehits], coalesced [dict get $h coalesced]) | [format %.1f [expr {[dict get $h bytes] / 1048576.0}]] MB"
    set ls {}
    foreach l [::md::poll::league_status] {
        set s "[dict get $l lkey]:[dict get $l n]"
        if {[dict get $l live]} { append s "{c:live}*{/c}" }
        if {[dict get $l fails]} { append s "{c:err}!{/c}" }
        append s "{c:dim}([dict get $l next]s){/c}"
        lappend ls $s
    }
    lappend lines "Watching [llength $ls] competitions, $total matches cached, $live live: [join $ls " "]"
    set users [expr {[info exists ::md::db(users)] ? [dict size $::md::db(users)] : 0}]
    set teams [expr {[info exists ::md::db(teams)] ? [dict size $::md::db(teams)] : 0}]
    lappend lines "Channels: [join [::md::chan::active] " "] | users $users | teams indexed $teams | narrations [llength [::md::narr::sessions]] | langs [join [::md::i18n::available] ,]"
    if {[llength [dict get $h blocked]]} { lappend lines "{c:err}Backoff:{/c} [join [dict get $h blocked] ", "]" }
    if {[dict get $h lasterror] ne ""} { lappend lines "{c:dim}Last error: [::md::trunc [dict get $h lasterror] 200]{/c}" }
    if {[info commands ::md::apifootball::status] ne "" && [::md::cfg apifootball.key ""] ne ""} {
        lappend lines [::md::apifootball::status]
    }
    ::md::reply_lines $ctx $lines 8
}

namespace eval ::md::cmd {
    def mdset op ::md::adm::c_mdset
    def admin admin ::md::adm::c_admin
}
