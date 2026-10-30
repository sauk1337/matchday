# Matchday - features/subs.tcl
# Personal subscriptions and preferences.
#
# Identity: "h:<handle>" for Eggdrop users, "a:<account>" for
# services-identified users (Eggdrop 1.9+ getaccount), else "n:<nick>".
#
# Follow refs:  team:<sport>:<id>  league:<lkey>  player:<normalised name>
#               match:<uid>

namespace eval ::md::subs {
    variable idx
    variable idxok 0
    array set idx {}
}

proc ::md::subs::defaults {} {
    dict create \
        lang     [::md::cfg lang.default en] \
        tz       [::md::cfg tz.default UTC] \
        delivery [::md::cfg users.delivery notice] \
        events   [::md::cfg users.events {goals reds pens start ht ft status alerts reminders hot videos}] \
        remind   15 \
        quiet    "" \
        dnd      0 \
        dedupe   1 \
        style    [::md::cfg out.style full] \
        symbols  [::md::cfg out.symbols unicode] \
        digest   "" \
        missed   1 \
        home     ""
}

proc ::md::subs::pref_names {} {
    return {lang tz delivery events remind quiet dnd dedupe style symbols digest missed home}
}

# ---------------------------------------------------------------- identity

proc ::md::subs::ukey {nick {hand "*"}} {
    if {$hand ne "*" && $hand ne "" && [::md::cfg users.by_handle 1]} { return "h:$hand" }
    if {[::md::cfg users.by_account 1] && [info commands getaccount] ne ""} {
        if {![catch {getaccount $nick} acc] && $acc ne "" && $acc ne "*"} {
            return "a:[string tolower $acc]"
        }
    }
    return "n:[::md::ircl $nick]"
}

proc ::md::subs::touch {ukey nick} {
    if {[::md::db_get users $ukey nick] ne $nick} {
        ::md::db_set users $ukey nick $nick
    }
}

# Current nick for a user key, "" if not online
proc ::md::subs::nick_of {ukey} {
    switch -glob -- $ukey {
        h:* {
            set n [hand2nick [string range $ukey 2 end]]
            if {$n ne ""} { return $n }
            set n [::md::db_get users $ukey nick]
        }
        a:* {
            set n [::md::db_get users $ukey nick]
            if {$n ne "" && [info commands getaccount] ne ""} {
                if {[catch {getaccount $n} acc] || [string tolower $acc] ne [string range $ukey 2 end]} { return "" }
            }
        }
        default {
            set n [::md::db_get users $ukey nick]
            if {$n eq ""} { set n [string range $ukey 2 end] }
        }
    }
    if {$n ne "" && [onchan $n]} { return $n }
    return ""
}

# ---------------------------------------------------------------- prefs

proc ::md::subs::pref {ukey name} {
    if {[::md::db_exists users $ukey prefs $name]} { return [::md::db_get users $ukey prefs $name] }
    ::md::dg [defaults] "" $name
}

proc ::md::subs::setpref {ukey name value} {
    ::md::db_set users $ukey prefs $name $value
}

proc ::md::subs::has_pref {ukey name} {
    ::md::db_exists users $ukey prefs $name
}

proc ::md::subs::style_for_nick {nick} {
    set ukey [::md::subs::find_ukey $nick]
    if {$ukey eq ""} { return [list [::md::cfg out.style full] [::md::cfg out.symbols unicode]] }
    list [pref $ukey style] [pref $ukey symbols]
}

# Best-effort reverse lookup nick -> stored user key
proc ::md::subs::find_ukey {nick} {
    set k [ukey $nick [nick2hand $nick]]
    if {[::md::db_exists users $k]} { return $k }
    set k "n:[::md::ircl $nick]"
    if {[::md::db_exists users $k]} { return $k }
    return ""
}

# ---------------------------------------------------------------- follows

proc ::md::subs::follows {ukey} {
    ::md::db_get users $ukey follows
}

proc ::md::subs::follow {ukey ref label} {
    set f [follows $ukey]
    if {[dict exists $f $ref]} { return 0 }
    if {[dict size $f] >= [::md::cfg users.max_follows 30]} { return -1 }
    dict set f $ref [dict create label $label ts [clock seconds]]
    ::md::db_set users $ukey follows $f
    _dirty
    return 1
}

proc ::md::subs::unfollow {ukey ref} {
    set f [follows $ukey]
    if {![dict exists $f $ref]} { return 0 }
    dict unset f $ref
    ::md::db_set users $ukey follows $f
    _dirty
    return 1
}

proc ::md::subs::_dirty {} {
    variable idxok
    set idxok 0
}

proc ::md::subs::_index {} {
    variable idx
    variable idxok
    if {$idxok} return
    array unset idx
    if {[info exists ::md::db(users)]} {
        dict for {ukey u} $::md::db(users) {
            foreach ref [dict keys [::md::dg $u {} follows]] { lappend idx($ref) $ukey }
        }
    }
    set idxok 1
}

proc ::md::subs::followed_teams {} {
    variable idx
    _index
    set out {}
    foreach ref [array names idx team:*] { lappend out [string range $ref 5 end] }
    return $out
}

# leagues hook for the poller
proc ::md::subs::leagues {} {
    variable idx
    _index
    set out {}
    foreach ref [array names idx league:*] { lappend out [string range $ref 7 end] }
    foreach ref [array names idx team:*] {
        lappend out {*}[::md::teams::upcoming_leagues [string range $ref 5 end]]
    }
    foreach ref [array names idx match:*] {
        set m [::md::poll::match [string range $ref 6 end]]
        if {$m ne "" && [dict get $m state] ne "post"} { lappend out [dict get $m lkey] }
    }
    return $out
}
::md::hook::add leagues ::md::subs::leagues

proc ::md::subs::quiet_now {ukey} {
    set q [pref $ukey quiet]
    if {![regexp {^(\d{1,2}:?\d{0,2})-(\d{1,2}:?\d{0,2})$} $q -> a b]} { return 0 }
    set from [::md::hm2min $a]; set to [::md::hm2min $b]
    if {$from eq "" || $to eq ""} { return 0 }
    set now [::md::tfmt [clock seconds] %H:%M [pref $ukey tz]]
    set n [::md::hm2min $now]
    if {$from <= $to} { return [expr {$n >= $from && $n < $to}] }
    expr {$n >= $from || $n < $to}
}

# Who should get this event privately: list of {ukey nick}
proc ::md::subs::recipients {m ev cat} {
    variable idx
    _index
    set refs [list "league:[dict get $m lkey]" "match:[dict get $m uid]"]
    foreach tk [::md::dispatch::team_keys $m] { lappend refs "team:$tk" }
    set cands {}
    foreach r $refs {
        if {[info exists idx($r)]} { lappend cands {*}$idx($r) }
    }
    # player follows only fire for that player's own events
    set p [::md::dg $ev "" player]
    if {$p ne ""} {
        set r "player:[::md::norm $p]"
        if {[info exists idx($r)]} { lappend cands {*}$idx($r) }
        # also match by surname-only follows
        set last [lindex [::md::norm $p] end]
        if {[info exists idx(player:$last)]} { lappend cands {*}$idx(player:$last) }
    }
    set out {}
    foreach ukey [::md::luniq $cands] {
        if {$cat ni [pref $ukey events] && $cat ne "reminders"} continue
        if {$cat eq "reminders" && "reminders" ni [pref $ukey events]} continue
        if {[pref $ukey dnd] || [quiet_now $ukey]} continue
        set nick [nick_of $ukey]
        if {$nick eq ""} {
            if {[dict get $ev type] eq "ft"} { _missed $ukey $m }
            continue
        }
        lappend out [list $ukey $nick]
    }
    return $out
}

# ---------------------------------------------------------------- missed results

proc ::md::subs::_missed {ukey m} {
    if {![pref $ukey missed]} return
    set l [::md::db_get users $ukey missed]
    lappend l [dict get $m uid]
    ::md::db_set users $ukey missed [lrange [::md::luniq $l] end-9 end]
}

# join hook: deliver results the user missed while away
proc ::md::subs::on_join {nick uhost hand chan} {
    if {[isbotnick $nick]} return
    set ukey [ukey $nick $hand]
    if {![::md::db_exists users $ukey]} return
    set l [::md::db_get users $ukey missed]
    if {![llength $l]} return
    ::md::db_set users $ukey missed {}
    touch $ukey $nick
    set lang [pref $ukey lang]
    set tz [pref $ukey tz]
    set lines {}
    foreach uid $l {
        set m [::md::poll::match $uid]
        if {$m eq ""} continue
        lappend lines [::md::render::line $lang $m $tz 1]
    }
    if {![llength $lines]} return
    set notice [expr {[pref $ukey delivery] eq "notice"}]
    ::md::out::send $nick [::md::t $lang missed.header n [llength $lines]] -notice $notice
    foreach l $lines { ::md::out::send $nick $l -notice $notice }
}

# ---------------------------------------------------------------- digests

# Called every minute: daily digest for users and channels
proc ::md::subs::digest_tick {} {
    set now [clock seconds]
    if {[info exists ::md::db(users)]} {
        dict for {ukey u} $::md::db(users) {
            set at [::md::dg $u "" prefs digest]
            if {$at eq ""} continue
            set tz [pref $ukey tz]
            set today [::md::tfmt $now %Y%m%d $tz]
            if {[::md::dg $u "" lastdigest] eq $today} continue
            set mins [::md::hm2min $at]
            set cur [::md::hm2min [::md::tfmt $now %H:%M $tz]]
            if {$mins eq "" || $cur < $mins || $cur > $mins + 30} continue
            set nick [nick_of $ukey]
            if {$nick eq ""} continue
            ::md::db_set users $ukey lastdigest $today
            _user_digest $ukey $nick
        }
    }
    foreach chan [::md::chan::active] {
        set at [::md::chan::get $chan digest]
        if {$at eq ""} continue
        set tz [::md::chan::get $chan tz]
        set today [::md::tfmt $now %Y%m%d $tz]
        if {[::md::db_get chans [::md::chan::key $chan] lastdigest] eq $today} continue
        set mins [::md::hm2min $at]
        set cur [::md::hm2min [::md::tfmt $now %H:%M $tz]]
        if {$mins eq "" || $cur < $mins || $cur > $mins + 30} continue
        ::md::chan::put $chan lastdigest $today
        ::md::cmd::today_digest $chan
    }
}

proc ::md::subs::_user_digest {ukey nick} {
    set lang [pref $ukey lang]
    set tz [pref $ukey tz]
    set today [::md::tfmt [clock seconds] %Y%m%d $tz]
    set lines {}
    set seen {}
    foreach m [::md::poll::matches] {
        if {[::md::tfmt [dict get $m start] %Y%m%d $tz] ne $today} continue
        set hit 0
        if {[dict exists [follows $ukey] "league:[dict get $m lkey]"]} { set hit 1 }
        foreach tk [::md::dispatch::team_keys $m] {
            if {[dict exists [follows $ukey] "team:$tk"]} { set hit 1 }
        }
        if {$hit && ![dict exists $seen [dict get $m uid]]} {
            dict set seen [dict get $m uid] 1
            lappend lines [::md::render::line $lang $m $tz 1]
        }
    }
    set notice [expr {[pref $ukey delivery] eq "notice"}]
    if {![llength $lines]} {
        ::md::out::send $nick [::md::t $lang digest.none] -notice $notice
        return
    }
    ::md::out::send $nick [::md::t $lang digest.header n [llength $lines]] -notice $notice
    foreach l [lrange $lines 0 14] { ::md::out::send $nick $l -notice $notice }
}

proc ::md::subs::init {} {
    ::md::store::load users
    ::md::every subs.digest 60000 ::md::subs::digest_tick
}
