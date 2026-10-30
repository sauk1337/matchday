# Matchday - features/chan.tcl
# Per-channel configuration. A channel is active when it has the
# Eggdrop channel flag +matchday (".chanset #chan +matchday").

namespace eval ::md::chan {}

proc ::md::chan::defaults {} {
    dict create \
        leagues   [::md::cfg chan.leagues {}] \
        teams     {} \
        events    [::md::cfg chan.events {goals reds pens start ht ft status alerts hot videos}] \
        hotscope  [::md::cfg chan.hotscope leagues] \
        lang      [::md::cfg lang.default en] \
        tz        [::md::cfg tz.default UTC] \
        style     [::md::cfg out.style full] \
        symbols   [::md::cfg out.symbols unicode] \
        prefix    [::md::cfg cmd.prefix "!"] \
        remind    0 \
        porra     1 \
        narrperm  [::md::cfg narr.perm op] \
        maxnarr   [::md::cfg narr.max_per_chan 2] \
        autonarr  {} \
        narrstyle [::md::cfg narr.style normal] \
        digest    "" \
        replies   chan \
        quiet     0 \
        cmds      1
}

proc ::md::chan::key {chan} { ::md::ircl $chan }

proc ::md::chan::get {chan field} {
    set k [key $chan]
    if {[::md::db_exists chans $k $field]} { return [::md::db_get chans $k $field] }
    ::md::dg [defaults] "" $field
}

proc ::md::chan::put {chan field value} {
    ::md::db_set chans [key $chan] $field $value
}

proc ::md::chan::all {chan} {
    set d [defaults]
    set k [key $chan]
    if {[::md::db_exists chans $k]} { set d [dict merge $d [::md::db_get chans $k]] }
    return $d
}

proc ::md::chan::enabled {chan} {
    if {$chan eq "" || ![validchan $chan]} { return 0 }
    if {[catch {channel get $chan matchday} v]} { return 0 }
    string is true -strict $v
}

proc ::md::chan::active {} {
    set out {}
    foreach c [channels] {
        if {[enabled $c] && ![get $c quiet]} { lappend out $c }
    }
    return $out
}

proc ::md::chan::lang {chan} { get $chan lang }

proc ::md::chan::wants {chan m cat} {
    if {$cat ni [get $chan events]} { return 0 }
    # hot-match alerts can cover every competition the bot watches
    if {$cat eq "hot" && [get $chan hotscope] eq "all"} { return 1 }
    interested $chan $m
}

# league/team interest only (no event filter)
proc ::md::chan::interested {chan m} {
    if {[dict get $m lkey] in [get $chan leagues]} { return 1 }
    set teams [get $chan teams]
    if {[llength $teams]} {
        foreach tk [::md::dispatch::team_keys $m] {
            if {$tk in $teams} { return 1 }
        }
    }
    return 0
}

# leagues hook for the poller
proc ::md::chan::leagues {} {
    set out {}
    foreach c [active] {
        lappend out {*}[get $c leagues]
        foreach tk [concat [get $c teams] [get $c autonarr]] { lappend out {*}[::md::teams::upcoming_leagues $tk] }
    }
    return $out
}
::md::hook::add leagues ::md::chan::leagues

# Style resolution used by md::out for any target
proc ::md::target_style {target} {
    if {[string index $target 0] in {# & + !}} {
        set style [::md::chan::get $target style]
        set sym [::md::chan::get $target symbols]
        # channel mode +c strips/blocks colours
        if {$style eq "full" && ![catch {getchanmode $target} modes] && [string match {*c*} [lindex $modes 0]]} {
            set style bold
        }
        return [list $style $sym]
    }
    ::md::subs::style_for_nick $target
}
