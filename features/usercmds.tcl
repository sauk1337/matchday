# Matchday - features/usercmds.tcl
# Personal commands: follow, unfollow, follows, prefs, set, lang, tz.

namespace eval ::md::ucmd {}

proc ::md::ucmd::onoff {v} {
    set v [::md::norm $v]
    if {$v in {on 1 yes si sim oui ja true enable activar ativar attiva ein}} { return 1 }
    if {$v in {off 0 no nao non nein false disable desactivar desativar disattiva aus}} { return 0 }
    return ""
}

proc ::md::ucmd::parse_events {cur text} {
    set all [::md::dispatch::all_categories]
    set words [split [string map {, " "} [string tolower $text]]]
    set out $cur
    set absolute {}
    foreach w $words {
        if {$w eq ""} continue
        if {$w in {all todo todos tutto tous alle tudo}} { return $all }
        if {$w in {default defecto padrao defaut}} { return [::md::dg [::md::subs::defaults] {} events] }
        if {$w in {none ninguno nada nessuno aucun keine nenhum}} { return {} }
        set op ""
        if {[string index $w 0] in {+ -}} { set op [string index $w 0]; set w [string range $w 1 end] }
        set c [_cat $w]
        if {$c eq ""} { return -code error $w }
        switch -- $op {
            + { if {$c ni $out} { lappend out $c } }
            - { set out [::md::lremove $out $c] }
            default { lappend absolute $c }
        }
    }
    if {[llength $absolute]} { return [::md::luniq $absolute] }
    return $out
}

# category names in several languages
proc ::md::ucmd::_cat {w} {
    set map {
        goals goals goal goals goles goals gol goals gols goals buts goals tore goals
        reds reds red reds rojas reds rouges reds rosse reds vermelhos reds
        cards cards yellow cards amarillas cards tarjetas cards cartons cards gialli cards karten cards cartoes cards
        pens pens penalties pens penaltis pens penaltys pens rigori pens elfmeter pens penaltis pens
        start start kickoff start inicio start comienzo start debut start inizio start anpfiff start
        ht ht halftime ht descanso ht mitemps ht intervallo ht halbzeit ht intervalo ht
        ft ft fulltime ft final ft finales ft fin ft fine ft ende ft
        status status estado status statut status stato status
        alerts alerts alertas alerts alertes alerts avvisi alerts
        reminders reminders reminder reminders recordatorios reminders rappels reminders promemoria reminders erinnerung reminders lembretes reminders
        hot hot caliente hot calientes hot quente hot chaud hot caldo hot heiss hot
        videos videos video videos highlights videos resumenes videos resumos videos
    }
    if {[dict exists $map $w]} { return [dict get $map $w] }
    return ""
}

# ---------------------------------------------------------------- follow

proc ::md::ucmd::c_follow {ctx argv} {
    set lang [dict get $ctx lang]
    if {![llength $argv]} { c_follows $ctx {}; return }
    set first [::md::norm [lindex $argv 0]]
    set rest [join [lrange $argv 1 end]]
    if {$first in {league liga ligue lega competition competicion torneo} && $rest ne ""} {
        _follow_league $ctx $rest
        return
    }
    if {$first in {player jugador joueur giocatore spieler jogador} && $rest ne ""} {
        set n [::md::norm $rest]
        set r [::md::subs::follow [dict get $ctx ukey] "player:$n" $rest]
        _followed $ctx $r $rest
        return
    }
    if {$first in {match partido partita jogo spiel game} && $rest ne ""} {
        ::md::cmd::with_team $ctx $rest [list ::md::ucmd::_follow_match $ctx]
        return
    }
    set q [join $argv]
    set lk [::md::catalog::exact $q]
    if {$lk ne ""} { _follow_league $ctx $q; return }
    ::md::cmd::with_team $ctx $q [list ::md::ucmd::_follow_team $ctx]
}

proc ::md::ucmd::_followed {ctx r label} {
    set lang [dict get $ctx lang]
    ::md::subs::touch [dict get $ctx ukey] [dict get $ctx nick]
    switch -- $r {
        1 { ::md::reply $ctx [::md::t $lang follow.ok what $label cmd [::md::cmdhint $lang prefs]] }
        0 { ::md::reply $ctx [::md::t $lang follow.already what $label] }
        default { ::md::cmd::err $ctx follow.limit n [::md::cfg users.max_follows 30] }
    }
}

proc ::md::ucmd::_follow_league {ctx q} {
    set lk [::md::catalog::find $q]
    if {$lk eq ""} { ::md::cmd::err $ctx err.league_notfound query $q; return }
    _followed $ctx [::md::subs::follow [dict get $ctx ukey] "league:$lk" [::md::catalog::label $lk]] [::md::catalog::label $lk]
}

proc ::md::ucmd::_follow_team {ctx tkey} {
    set label [::md::teams::label $tkey]
    set r [::md::subs::follow [dict get $ctx ukey] "team:$tkey" $label]
    _followed $ctx $r $label
    # warm the fixtures cache so its competitions get polled in time
    ::md::teams::schedule $tkey 1 [list ::md::teams::_noop]
}

proc ::md::ucmd::_follow_match {ctx tkey} {
    set m [::md::cmd::pick_match [::md::cmd::team_matches $tkey]]
    if {$m eq "" || [dict get $m state] eq "post"} {
        ::md::cmd::err $ctx team.no_match team [::md::teams::label $tkey]
        return
    }
    set label [::md::render::teams $m]
    _followed $ctx [::md::subs::follow [dict get $ctx ukey] "match:[dict get $m uid]" $label] $label
}

proc ::md::ucmd::c_unfollow {ctx argv} {
    set lang [dict get $ctx lang]
    set ukey [dict get $ctx ukey]
    set f [::md::subs::follows $ukey]
    set q [join $argv]
    if {$q eq ""} { ::md::cmd::usage $ctx unfollow; return }
    if {[::md::norm $q] in {all todo todos tutto tous alle tudo}} {
        foreach ref [dict keys $f] { ::md::subs::unfollow $ukey $ref }
        ::md::reply $ctx [::md::t $lang unfollow.all]
        return
    }
    # by number from !follows, or by label match
    set refs [dict keys $f]
    set hit ""
    if {[string is integer -strict $q] && $q >= 1 && $q <= [llength $refs]} {
        set hit [lindex $refs [expr {$q - 1}]]
    } else {
        set n [::md::norm $q]
        set best 0
        foreach ref $refs {
            set s [::md::mscore $n [list [::md::norm [dict get $f $ref label]]]]
            if {$s > $best} { set best $s; set hit $ref }
        }
        if {$best < 60} { set hit "" }
    }
    if {$hit eq ""} { ::md::cmd::err $ctx unfollow.notfound query $q; return }
    set label [dict get $f $hit label]
    ::md::subs::unfollow $ukey $hit
    ::md::reply $ctx [::md::t $lang unfollow.ok what $label]
}

proc ::md::ucmd::c_follows {ctx argv} {
    set lang [dict get $ctx lang]
    set f [::md::subs::follows [dict get $ctx ukey]]
    if {![dict size $f]} {
        ::md::reply $ctx [::md::t $lang follows.none cmd [::md::cmdhint $lang follow]]
        return
    }
    set parts {}
    set i 0
    dict for {ref d} $f {
        incr i
        set kind [lindex [split $ref :] 0]
        lappend parts "{c:rank}$i.{/c}[dict get $d label] {c:dim}([::md::t $lang follows.kind.$kind]){/c}"
    }
    ::md::reply_lines $ctx [::md::wrap "[::md::t $lang follows.header]: [join $parts " "]" 380]
}

# ---------------------------------------------------------------- prefs

proc ::md::ucmd::c_prefs {ctx argv} {
    set lang [dict get $ctx lang]
    set ukey [dict get $ctx ukey]
    set parts {}
    foreach p [::md::subs::pref_names] {
        set v [::md::subs::pref $ukey $p]
        if {$p in {dnd dedupe missed}} { set v [expr {$v ? "on" : "off"}] }
        if {$v eq ""} { set v "-" }
        lappend parts "{b}$p{b}=$v"
    }
    set lines [::md::wrap "[::md::t $lang prefs.header]: [join $parts " "]" 380]
    lappend lines [::md::t $lang prefs.hint cmd [::md::cmdhint $lang set]]
    ::md::reply_priv $ctx $lines
    if {[dict get $ctx chan] ne ""} { ::md::reply $ctx [::md::t $lang table.sent_priv] }
}

proc ::md::ucmd::c_set {ctx argv} {
    set lang [dict get $ctx lang]
    set ukey [dict get $ctx ukey]
    if {[llength $argv] < 2} { c_prefs $ctx {}; return }
    set name [string tolower [lindex $argv 0]]
    set map {idioma lang language lang langue lang lingua lang sprache lang zona tz timezone tz
             entrega delivery eventos events avisos events recordatorio remind silencio quiet
             nomolestar dnd resumen digest estilo style simbolos symbols perdidos missed casa home canal home}
    if {[dict exists $map $name]} { set name [dict get $map $name] }
    set val [join [lrange $argv 1 end]]
    switch -- $name {
        lang {
            set v [string tolower $val]
            if {![::md::i18n::valid $v]} { ::md::cmd::err $ctx set.badlang langs [join [::md::i18n::available] ", "]; return }
            ::md::subs::setpref $ukey lang $v
            set lang $v
        }
        tz {
            if {![::md::validtz $val]} { ::md::cmd::err $ctx set.badtz; return }
            ::md::subs::setpref $ukey tz $val
        }
        delivery {
            set v [string tolower $val]
            if {$v in {msg privmsg query privado private}} { set v msg } elseif {$v in {notice notificacion}} { set v notice } else {
                ::md::cmd::err $ctx set.badvalue key $name values "notice, msg"; return
            }
            ::md::subs::setpref $ukey delivery $v
        }
        events {
            if {[catch {parse_events [::md::subs::pref $ukey events] $val} ev]} {
                ::md::cmd::err $ctx set.badvalue key $name values [join [::md::dispatch::all_categories] ", "]
                return
            }
            ::md::subs::setpref $ukey events $ev
            set val [join $ev ","]
        }
        remind {
            if {![string is integer -strict $val] || $val < 0 || $val > 180} { ::md::cmd::err $ctx set.badvalue key $name values "0-180"; return }
            ::md::subs::setpref $ukey remind $val
        }
        quiet {
            if {[onoff $val] eq "0" || $val eq "-"} { set val "" } elseif {![regexp {^\d{1,2}(:\d\d)?-\d{1,2}(:\d\d)?$} $val]} {
                ::md::cmd::err $ctx set.badvalue key $name values "23:00-08:00, off"; return
            }
            ::md::subs::setpref $ukey quiet $val
        }
        dnd - dedupe - missed {
            set v [onoff $val]
            if {$v eq ""} { ::md::cmd::err $ctx set.badvalue key $name values "on, off"; return }
            ::md::subs::setpref $ukey $name $v
        }
        style {
            if {$val ni {full bold plain}} { ::md::cmd::err $ctx set.badvalue key $name values "full, bold, plain"; return }
            ::md::subs::setpref $ukey style $val
        }
        symbols {
            if {$val ni {unicode ascii}} { ::md::cmd::err $ctx set.badvalue key $name values "unicode, ascii"; return }
            ::md::subs::setpref $ukey symbols $val
        }
        digest {
            if {[onoff $val] eq "0"} { set val "" } elseif {[::md::hm2min $val] eq ""} {
                ::md::cmd::err $ctx set.badvalue key $name values "09:00, off"; return
            }
            ::md::subs::setpref $ukey digest $val
        }
        home {
            if {$val ne "" && ![validchan $val]} { ::md::cmd::err $ctx set.badvalue key $name values "#channel"; return }
            ::md::subs::setpref $ukey home $val
        }
        default {
            ::md::cmd::err $ctx set.unknown key $name keys [join [::md::subs::pref_names] ", "]
            return
        }
    }
    ::md::subs::touch $ukey [dict get $ctx nick]
    ::md::reply $ctx [::md::t $lang cfg.set key $name value $val]
}

proc ::md::ucmd::c_lang {ctx argv} {
    if {![llength $argv]} {
        set parts {}
        foreach l [::md::i18n::available] { lappend parts "$l ([::md::i18n::name $l])" }
        ::md::reply $ctx [::md::t [dict get $ctx lang] lang.list langs [join $parts ", "] cmd [::md::cmdhint [dict get $ctx lang] lang]]
        return
    }
    c_set $ctx [list lang {*}$argv]
}

proc ::md::ucmd::c_tz {ctx argv} {
    if {![llength $argv]} {
        set tz [::md::subs::pref [dict get $ctx ukey] tz]
        ::md::reply $ctx [::md::t [dict get $ctx lang] tz.current tz $tz time [::md::tfmt [clock seconds] %H:%M $tz]]
        return
    }
    c_set $ctx [list tz {*}$argv]
}

namespace eval ::md::cmd {
    def follow   any ::md::ucmd::c_follow
    def unfollow any ::md::ucmd::c_unfollow 1
    def follows  any ::md::ucmd::c_follows
    def prefs    any ::md::ucmd::c_prefs
    def set      any ::md::ucmd::c_set
    def lang     any ::md::ucmd::c_lang
    def tz       any ::md::ucmd::c_tz
}
