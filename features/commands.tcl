# Matchday - features/commands.tcl
# Command routing for channel (pubm), private (msgm) and partyline (dcc).
#
# Commands are registered with md::cmd::def; names are canonical English
# words and every language file adds localised aliases (e.g. !directo,
# !clasificacion, !tabelle). Handlers receive a context dict and the
# argument list:
#   ctx: nick uhost hand chan via lang tz ukey target notice prefix
#   via: pub | msg | dcc

namespace eval ::md::cmd {
    variable C          ;# canonical -> dict {perm handler min usage hidden}
    variable flood
    array set C {}
    array set flood {}
}

# perm: any | op | narr | admin
proc ::md::cmd::def {name perm handler {min 0} {hidden 0}} {
    variable C
    set C($name) [dict create perm $perm handler $handler min $min hidden $hidden]
    ::md::i18n::canon_register [list $name]
}

proc ::md::cmd::list_visible {} {
    variable C
    set out {}
    foreach n [lsort [array names C]] {
        if {![dict get $C($n) hidden]} { lappend out $n }
    }
    return $out
}

proc ::md::cmdhint {lang canon} {
    return "[::md::cfg cmd.prefix !][::md::i18n::cmdname $lang $canon]"
}

# ---------------------------------------------------------------- entry points

proc ::md::cmd::pub {nick uhost hand chan text} {
    if {![::md::chan::enabled $chan] || ![::md::chan::get $chan cmds]} return
    set prefix [::md::chan::get $chan prefix]
    if {$prefix eq "" || [string first $prefix $text] != 0} return
    set text [string range $text [string length $prefix] end]
    set words [_split $text]
    if {![llength $words]} return
    set canon [::md::i18n::resolve [lindex $words 0]]
    if {$canon eq ""} return
    set ctx [_ctx $nick $uhost $hand $chan pub]
    dict set ctx prefix $prefix
    run $ctx $canon [lrange $words 1 end]
}

proc ::md::cmd::msg {nick uhost hand text} {
    set text [string trim $text]
    set p [::md::cfg cmd.prefix !]
    set prefixed [expr {[string first $p $text] == 0}]
    if {$prefixed} { set text [string range $text [string length $p] end] }
    set words [_split $text]
    if {![llength $words]} return
    # Eggdrop's own /msg commands (help, info, op, pass...) keep working:
    # ours need the prefix for those words ("/msg bot !help")
    if {!$prefixed && [string tolower [lindex $words 0]] in [::md::cfg cmd.msg_reserved \
            {help info hello ident op halfop voice pass invite whois who status die rehash save reset jump memory key go addhost}]} {
        return
    }
    set canon [::md::i18n::resolve [lindex $words 0]]
    if {$canon eq ""} {
        # unknown private commands: only answer things that look like ours
        return
    }
    set ctx [_ctx $nick $uhost $hand "" msg]
    run $ctx $canon [lrange $words 1 end]
}

proc ::md::cmd::dcc {hand idx text} {
    set words [_split $text]
    if {![llength $words]} { set words help }
    set canon [::md::i18n::resolve [lindex $words 0]]
    set ctx [dict create nick $hand uhost "" hand $hand chan "" via dcc lang [::md::cfg lang.default en] \
        tz [::md::cfg tz.default UTC] ukey "h:$hand" target "dcc:$idx" notice 0 prefix "."]
    if {$canon eq ""} {
        # ".matchday <admin subcommand>"
        run $ctx admin $words
        return
    }
    run $ctx $canon [lrange $words 1 end]
}

proc ::md::cmd::_split {text} {
    # never echo CTCP/control bytes back to IRC; keep colour codes out too
    regsub -all {[\x00-\x1f\x7f]} $text "" text
    # tolerate unbalanced braces/quotes from IRC: split on whitespace
    set out {}
    foreach w [split [string trim $text] " \t"] {
        if {$w ne ""} { lappend out $w }
    }
    return $out
}

proc ::md::cmd::_ctx {nick uhost hand chan via} {
    set ukey [::md::subs::ukey $nick $hand]
    if {[::md::db_exists users $ukey]} { ::md::subs::touch $ukey $nick }
    set ulang [::md::subs::pref $ukey lang]
    set utz [::md::subs::pref $ukey tz]
    if {$chan ne ""} {
        set lang [::md::chan::lang $chan]
        set tz [::md::chan::get $chan tz]
        # a user's explicit timezone wins for times shown to them
        if {[::md::subs::has_pref $ukey tz]} { set tz $utz }
        set notice [expr {[::md::chan::get $chan replies] eq "notice"}]
        set target [expr {$notice ? $nick : $chan}]
    } else {
        set lang $ulang
        set tz $utz
        set notice [expr {[::md::subs::pref $ukey delivery] eq "notice"}]
        set target $nick
    }
    dict create nick $nick uhost $uhost hand $hand chan $chan via $via lang $lang ulang $ulang \
        tz $tz ukey $ukey target $target notice $notice prefix [::md::cfg cmd.prefix !]
}

# ---------------------------------------------------------------- dispatch

proc ::md::cmd::run {ctx canon args_} {
    variable C
    if {![info exists C($canon)]} return
    set def $C($canon)
    if {[dict get $ctx via] ne "dcc" && [_flooded $ctx]} return
    if {![allowed $ctx [dict get $def perm]]} {
        reply $ctx [::md::t [dict get $ctx lang] err.perm]
        return
    }
    if {[llength $args_] < [dict get $def min]} {
        usage $ctx $canon
        return
    }
    if {[catch {{*}[dict get $def handler] $ctx $args_} err opts]} {
        ::md::log error "command $canon: $err"
        ::md::log debug [dict get $opts -errorinfo]
        reply $ctx [::md::t [dict get $ctx lang] err.internal]
    }
}

proc ::md::cmd::_flooded {ctx} {
    variable flood
    set k [string tolower [dict get $ctx uhost]]
    if {[matchattr [dict get $ctx hand] m]} { return 0 }
    set now [clock seconds]
    set win {}
    if {[info exists flood($k)]} {
        foreach t $flood($k) { if {$now - $t < [::md::cfg cmd.flood_secs 15]} { lappend win $t } }
    }
    lappend win $now
    set flood($k) $win
    if {[llength $win] > [::md::cfg cmd.flood_count 5]} {
        if {[llength $win] == [::md::cfg cmd.flood_count 5] + 1} {
            ::md::log info "flood: ignoring [dict get $ctx nick] ([dict get $ctx uhost]) for a while"
        }
        return 1
    }
    return 0
}

proc ::md::cmd::is_admin {ctx} {
    set h [dict get $ctx hand]
    if {$h eq "*" || $h eq ""} { return 0 }
    matchattr $h [::md::cfg admin.flags m|-]
}

proc ::md::cmd::is_chanop {ctx {chan ""}} {
    if {$chan eq ""} { set chan [dict get $ctx chan] }
    if {[is_admin $ctx]} { return 1 }
    if {$chan eq "" || ![validchan $chan]} { return 0 }
    set h [dict get $ctx hand]
    if {$h ne "*" && $h ne "" && [matchattr $h o|o $chan]} { return 1 }
    set n [dict get $ctx nick]
    expr {[isop $n $chan] || [ishalfop $n $chan]}
}

proc ::md::cmd::allowed {ctx perm} {
    switch -- $perm {
        any   { return 1 }
        admin { return [is_admin $ctx] }
        op    {
            if {[dict get $ctx chan] eq ""} { return 1 } ;# checked by handler against a #chan argument
            return [is_chanop $ctx]
        }
        narr  {
            set chan [dict get $ctx chan]
            if {$chan eq ""} { return 1 }
            switch -- [::md::chan::get $chan narrperm] {
                any { return 1 }
                voice { return [expr {[is_chanop $ctx] || [isvoice [dict get $ctx nick] $chan]}] }
                default { return [is_chanop $ctx] }
            }
        }
    }
    return 0
}

# ---------------------------------------------------------------- replies

proc ::md::reply {ctx text} {
    ::md::out::send [dict get $ctx target] $text -notice [dict get $ctx notice]
}

# multi-line reply; long outputs in channels are paged with !more
proc ::md::reply_lines {ctx lines {first ""}} {
    if {![llength $lines]} return
    if {$first eq ""} {
        set first [expr {[dict get $ctx chan] ne "" ? [::md::cfg out.chan_lines 4] : [::md::cfg out.priv_lines 12]}]
    }
    set key "[string tolower [dict get $ctx nick]]|[string tolower [dict get $ctx target]]"
    ::md::out::paged [dict get $ctx target] $key $lines $first [dict get $ctx notice] [dict get $ctx lang]
}

# reply privately to the user (notice by default) whatever the source
proc ::md::reply_priv {ctx lines} {
    set notice [expr {[::md::subs::pref [dict get $ctx ukey] delivery] eq "notice"}]
    if {[dict get $ctx via] eq "dcc"} {
        foreach l $lines { ::md::out::send [dict get $ctx target] $l }
        return
    }
    set key "[string tolower [dict get $ctx nick]]|[string tolower [dict get $ctx nick]]"
    ::md::out::paged [dict get $ctx nick] $key $lines [::md::cfg out.priv_lines 12] $notice [dict get $ctx ulang]
}

proc ::md::cmd::reply {ctx text} { ::md::reply $ctx $text }
proc ::md::cmd::reply_lines {ctx lines {first ""}} { ::md::reply_lines $ctx $lines $first }
proc ::md::cmd::reply_priv {ctx lines} { ::md::reply_priv $ctx $lines }

proc ::md::cmd::usage {ctx canon} {
    set lang [dict get $ctx lang]
    set u [::md::t? $lang help.$canon]
    set name "[dict get $ctx prefix][::md::i18n::cmdname $lang $canon]"
    if {$u eq ""} {
        reply $ctx [::md::t $lang err.usage cmd $name usage ""]
    } else {
        reply $ctx [::md::t $lang err.usage cmd $name usage $u]
    }
}

proc ::md::cmd::err {ctx key args} {
    reply $ctx "{c:err}[::md::t [dict get $ctx lang] $key {*}$args]{/c}"
}

# ---------------------------------------------------------------- shared resolvers

# Resolve a team for a command, then call cb with the team key.
# Handles "not found" and "ambiguous" replies.
proc ::md::cmd::with_team {ctx query cb {sport ""}} {
    ::md::teams::resolve $query [list ::md::cmd::_with_team $ctx $query $cb] $sport
}

proc ::md::cmd::_with_team {ctx query cb status res} {
    set lang [dict get $ctx lang]
    switch -- $status {
        ok { {*}$cb $res }
        ambiguous {
            set opts {}
            foreach k [lrange $res 0 5] {
                set lk [::md::teams::main_league $k]
                set lab [::md::teams::label $k]
                if {$lk ne ""} { append lab " {c:dim}([::md::catalog::label $lk]){/c}" }
                lappend opts $lab
            }
            reply $ctx [::md::t $lang err.ambiguous query $query options [join $opts ", "]]
        }
        default { err $ctx err.team_notfound query $query }
    }
}

# Interpret a free-text filter: returns dict {type league|sport|team|all|none value}
proc ::md::cmd::filter {text} {
    set text [string trim $text]
    if {$text eq ""} { return {type none value ""} }
    set n [::md::norm $text]
    if {$n in {all todo todos tutto tous alle tudo}} { return {type all value ""} }
    # sport names (english + spanish/other common words)
    set sports {
        soccer soccer football soccer futbol soccer fussball soccer calcio soccer futebol soccer
        basketball basketball baloncesto basketball basket basketball nba basketball
        hockey hockey nhl hockey baseball baseball beisbol baseball
        tennis tennis tenis tennis f1 racing racing racing motor racing formula1 racing
        golf golf rugby rugby mma mma ufc mma nfl football americano football
    }
    if {[dict exists $sports $n]} {
        # "nba"/"nfl"/"ufc"/"f1" are also leagues; prefer the league
        set lk [::md::catalog::find $text]
        if {$lk ne "" && $n in {nba nhl nfl ufc f1}} { return [dict create type league value $lk] }
        return [dict create type sport value [dict get $sports $n]]
    }
    set lk [::md::catalog::find $text]
    if {$lk ne ""} { return [dict create type league value $lk] }
    return [dict create type team value $text]
}

# ---------------------------------------------------------------- binds

proc ::md::cmd::init {} {
    ::md::bind pubm - "* *" ::md::cmd::pub
    ::md::bind msgm - "*" ::md::cmd::msg
    foreach w [::md::cfg dcc.commands {matchday md}] {
        ::md::bind dcc [::md::cfg dcc.flags m] $w ::md::cmd::dcc
    }
    ::md::every cmd.floodgc 300000 ::md::cmd::_floodgc
}

proc ::md::cmd::_floodgc {} {
    variable flood
    set now [clock seconds]
    foreach k [array names flood] {
        if {$now - [lindex $flood($k) end] > 120} { unset flood($k) }
    }
}
