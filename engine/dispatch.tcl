# Matchday - engine/dispatch.tcl
# Routes engine events to channels and subscribed users according to
# their interests and event filters; generates kick-off reminders.

namespace eval ::md::dispatch {
    variable reminded
    array set reminded {}
    variable recent {}
}

# Event type -> filter category (what users/channels toggle)
proc ::md::dispatch::category {ev} {
    switch -- [dict get $ev type] {
        goal - scorer - disallowed - score - set { return goals }
        card {
            if {[dict get $ev ctype] eq "yellow"} { return cards }
            return reds
        }
        penmiss - shootout - so { return pens }
        kickoff - 2h - et - ot { return start }
        ht - period_end { return ht }
        ft { return ft }
        postponed - cancelled - abandoned - suspended - delayed - resumed { return status }
        close - leader { return alerts }
        reminder { return reminders }
        hot { return hot }
        video { return videos }
    }
    return other
}

proc ::md::dispatch::all_categories {} {
    return {goals reds cards pens start ht ft status alerts reminders hot videos}
}

# Team keys for interest matching: "sport:teamid"
proc ::md::dispatch::team_keys {m} {
    set s [dict get $m sport]
    set out {}
    foreach side {home away} {
        set id [dict get $m $side id]
        if {$id ne ""} { lappend out "$s:$id" }
    }
    return $out
}

proc ::md::dispatch::emit {m evs} {
    variable recent
    foreach ev $evs {
        if {[dict get $ev type] ne "so"} {
            set delivered [deliver_channels $ev $m]
            deliver_users $ev $m $delivered
            set recent [lrange [linsert $recent 0 [list [clock seconds] $ev [dict get $m uid]]] 0 49]
        }
        # then global hooks: narrator, predictions (after the FT line), ...
        ::md::hook::run event $ev $m
    }
}

proc ::md::dispatch::deliver_channels {ev m} {
    set got {}
    set cat [category $ev]
    foreach chan [::md::chan::active] {
        if {[::md::hook::collect suppress_chan $chan [dict get $m uid]] ne ""} continue
        if {![::md::chan::wants $chan $m $cat]} continue
        set lang [::md::chan::lang $chan]
        if {[catch {::md::render::event $lang $ev $m} text]} {
            ::md::log error "render [dict get $ev type]: $text"
            continue
        }
        if {$text eq ""} continue
        ::md::out::live $chan $text
        lappend got $chan
    }
    return $got
}

proc ::md::dispatch::deliver_users {ev m chans} {
    set cat [category $ev]
    foreach r [::md::subs::recipients $m $ev $cat] {
        lassign $r ukey nick
        # don't duplicate what the user already sees in a channel
        if {[::md::subs::pref $ukey dedupe] && [llength $chans]} {
            set seen 0
            foreach c $chans { if {[onchan $nick $c]} { set seen 1; break } }
            if {$seen} continue
        }
        set lang [::md::subs::pref $ukey lang]
        if {[catch {::md::render::event $lang $ev $m} text] || $text eq ""} continue
        ::md::out::live $nick $text [expr {[::md::subs::pref $ukey delivery] eq "notice"}]
    }
}

# Kick-off reminders for followed teams / channels that enable them.
proc ::md::dispatch::reminders {lkey matches} {
    variable reminded
    set now [clock seconds]
    foreach m $matches {
        if {[dict get $m state] ne "pre" || [dict get $m code] ne "scheduled"} continue
        set uid [dict get $m uid]
        set left [expr {[dict get $m start] - $now}]
        if {$left <= 0 || $left > 3600} continue
        # channels
        foreach chan [::md::chan::active] {
            set mins [::md::chan::get $chan remind]
            if {$mins eq "" || $mins <= 0 || $left > $mins * 60} continue
            if {[info exists reminded($uid,$chan)]} continue
            if {![::md::chan::interested $chan $m]} continue
            set reminded($uid,$chan) $now
            set ev [dict create type reminder uid $uid mins [expr {($left + 59) / 60}] tz [::md::chan::get $chan tz]]
            ::md::out::live $chan [::md::render::event [::md::chan::lang $chan] $ev $m]
        }
        # users
        foreach r [::md::subs::recipients $m [dict create type reminder] reminders] {
            lassign $r ukey nick
            set mins [::md::subs::pref $ukey remind]
            if {$mins <= 0 || $left > $mins * 60} continue
            if {[info exists reminded($uid,u:$ukey)]} continue
            set reminded($uid,u:$ukey) $now
            set ev [dict create type reminder uid $uid mins [expr {($left + 59) / 60}] tz [::md::subs::pref $ukey tz]]
            ::md::out::live $nick [::md::render::event [::md::subs::pref $ukey lang] $ev $m] \
                [expr {[::md::subs::pref $ukey delivery] eq "notice"}]
        }
    }
    # forget old reminder marks
    foreach k [array names reminded] {
        if {$now - $reminded($k) > 7200} { unset reminded($k) }
    }
}

::md::hook::add scoreboard ::md::dispatch::reminders
