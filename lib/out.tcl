# Matchday - lib/out.tcl
# Formatting (theme roles, symbols, styles) and IRC output with
# coalescing of live events, flood protection and a !more buffer.
#
# Template markup (used in language files and renderers):
#   {b} bold   {u} underline   {i} italic   {o} reset
#   {c:role} ... {/c}   colour by theme role (goal, red, live, ...)
#   {s:name}            symbol (unicode or ascii, per target)
#
# Styles per target: full (colours+bold), bold (no colours), plain.

namespace eval ::md::out {
    variable pending
    variable more
    variable theme
    variable sym
    variable sent
    array set pending {}
    array set more {}
    array set sent {}

    # role -> mIRC colour code
    variable theme [dict create \
        goal 03 yellow 08 red 04 live 04 ht 07 ft 14 league 10 minute 07 \
        info 12 dim 14 ok 03 err 04 hl 06 win 03 loss 04 draw 07 start 03 \
        var 13 team "" score "" pen 06 sub 10 warn 07 gold 08 rank 10]

    # symbol -> {unicode ascii}
    variable sym [dict create \
        goal   [list "⚽" "*"] \
        yellow [list "{c:yellow}▮{/c}" "{c:yellow}\[Y\]{/c}"] \
        red    [list "{c:red}▮{/c}" "{c:red}\[R\]{/c}"] \
        yred   [list "{c:yellow}▮{/c}{c:red}▮{/c}" "{c:red}\[Y/R\]{/c}"] \
        start  [list "▶" ">"] \
        ht     [list "⏸" "||"] \
        ft     [list "■" "#"] \
        var    [list "⚠" "!"] \
        sub    [list "⇄" "<>"] \
        clock  [list "⏰" "@"] \
        live   [list "●" "*"] \
        star   [list "★" "*"] \
        up     [list "▲" "+"] \
        down   [list "▼" "-"] \
        same   [list "■" "="] \
        mic    [list "♪" ">>"] \
        pen    [list "◎" "(P)"] \
        chance [list "➜" "->"] \
        flag   [list "⚑" "!"] \
        dot    [list "·" "-"] \
        win    [list "✔" "W"] \
        loss   [list "✖" "L"] \
        draw   [list "–" "D"] \
        tv     [list "▣" "TV:"] \
        race   [list "⚑" ">"] \
        trophy [list "♛" "#1"] \
        hot    [list "♨" "(!)"]]
}

proc ::md::out::init {} {
    variable theme
    # user overrides: conf(theme.<role>) = colour code
    foreach role [dict keys $theme] {
        set v [::md::cfg theme.$role ""]
        if {$v ne ""} { dict set theme $role $v }
    }
    ::md::every out.gc 600000 ::md::out::gc
}

# Render markup -> IRC bytes for a style (full|bold|plain), symbols (unicode|ascii)
proc ::md::out::render {text {style full} {symbols unicode}} {
    variable theme
    variable sym
    # symbols first (they may contain colour markup)
    if {[string first "\{s:" $text] >= 0} {
        set idx [expr {$symbols eq "ascii" ? 1 : 0}]
        set map {}
        dict for {k v} $sym { lappend map "\{s:$k\}" [lindex $v $idx] }
        set text [string map $map $text]
    }
    switch -- $style {
        plain {
            regsub -all {\{c:[a-z]+\}|\{/c\}|\{[buio]\}} $text "" text
        }
        bold {
            regsub -all {\{c:[a-z]+\}|\{/c\}} $text "" text
            set text [string map [list "{b}" \x02 "{u}" \x1f "{i}" \x1d "{o}" \x0f] $text]
        }
        default {
            # a bare colour reset followed by a digit ("{s:yellow}2") would
            # read the digit as a colour: pad it with bold-bold
            regsub -all {\{/c\}([0-9,])} $text "{/c}{b}{b}\\1" text
            set map [list "{b}" \x02 "{u}" \x1f "{i}" \x1d "{o}" \x0f "{/c}" \x03]
            dict for {role code} $theme {
                if {$code eq ""} {
                    lappend map "\{c:$role\}" ""
                } else {
                    lappend map "\{c:$role\}" "\x03$code"
                }
            }
            set text [string map $map $text]
            # unknown roles
            regsub -all {\{c:[a-z]+\}} $text "" text
            # a colour code followed by a digit would be misparsed: pad with bold-bold
            regsub -all {(\x03\d\d)(\d|,\d)} $text "\\1\x02\x02\\2" text
        }
    }
    return $text
}

proc ::md::out::strip {text} {
    regsub -all {\x03(\d{1,2}(,\d{1,2})?)?} $text "" text
    string map [list \x02 "" \x1f "" \x0f "" \x1d "" \x16 ""] $text
}

# Style for a target is resolved by the channel/user modules
proc ::md::out::style_of {target} {
    if {[info commands ::md::target_style] ne ""} {
        return [::md::target_style $target]
    }
    return [list [::md::cfg out.style full] [::md::cfg out.symbols unicode]]
}

proc ::md::out::_irc {queue cmd target line} {
    set raw "$cmd $target :$line"
    switch -- $queue {
        quick { putquick $raw }
        serv  { putserv $raw }
        default { puthelp $raw }
    }
}

# Immediate send (already-built text with markup)
#   send target text ?-notice 0|1? ?-queue help|serv|quick?
proc ::md::out::send {target text args} {
    set o [dict merge {-notice 0 -queue help -style ""} $args]
    if {[string match dcc:* $target]} {
        set idx [string range $target 4 end]
        foreach line [::md::wrap [render $text bold unicode] 450] { catch {putdcc $idx $line} }
        return
    }
    lassign [style_of $target] style symbols
    if {[dict get $o -style] ne ""} { set style [dict get $o -style] }
    set cmd [expr {[dict get $o -notice] ? "NOTICE" : "PRIVMSG"}]
    set max [expr {[::md::cfg out.maxbytes 400] - [string length $target]}]
    foreach line [::md::wrap [render $text $style $symbols] $max] {
        _irc [dict get $o -queue] $cmd $target $line
    }
}

# Live events: coalesced per target for a short window so simultaneous
# events (e.g. several goals at 15:00 kick-offs) can be merged.
proc ::md::out::live {target text {notice 0} {merge 1}} {
    variable pending
    lappend pending([list $target $notice $merge]) $text
    ::md::timer out.flush [::md::cfg out.coalesce_ms 400] ::md::out::flush
}

proc ::md::out::flush {} {
    variable pending
    variable sent
    set burst [::md::cfg out.max_burst 6]
    set joinat [::md::cfg out.join_threshold 3]
    foreach key [array names pending] {
        lassign $key target notice merge
        set lines $pending($key)
        unset pending($key)
        # per-target rate limit (lines per minute)
        set now [clock seconds]
        set win {}
        if {[info exists sent($target)]} {
            foreach t $sent($target) { if {$now - $t < 60} { lappend win $t } }
        }
        set budget [expr {[::md::cfg out.max_per_minute 20] - [llength $win]}]
        if {$merge && [llength $lines] >= $joinat} {
            # merge into as few lines as possible, measured as really sent
            lassign [style_of $target] tstyle tsym
            set merged {}
            set cur ""
            set max [expr {[::md::cfg out.maxbytes 400] - [string length $target] - 2}]
            foreach l $lines {
                if {$cur eq ""} {
                    set cur $l
                } elseif {[::md::bytes [render "$cur {c:dim}|{/c} $l" $tstyle $tsym]] <= $max} {
                    append cur " {c:dim}|{/c} " $l
                } else {
                    lappend merged $cur
                    set cur $l
                }
            }
            if {$cur ne ""} { lappend merged $cur }
            set lines $merged
        }
        set n 0
        set dropped 0
        foreach l $lines {
            if {$n >= $burst || $n >= $budget} { incr dropped; continue }
            send $target $l -notice $notice -queue serv
            lappend win $now
            incr n
        }
        if {$dropped > 0} {
            ::md::log debug "out: dropped $dropped lines to $target (flood control)"
        }
        set sent($target) $win
    }
}

# Paged reply with !more support.
#   paged target key lines ?first? ?-notice?
proc ::md::out::paged {target key lines {first 5} {notice 0} {lang en}} {
    variable more
    if {[llength $lines] <= $first + 1} {
        foreach l $lines { send $target $l -notice $notice }
        unset -nocomplain more($key)
        return
    }
    foreach l [lrange $lines 0 [expr {$first - 1}]] { send $target $l -notice $notice }
    set rest [lrange $lines $first end]
    set more($key) [list [clock seconds] $target $notice $rest $first]
    send $target [::md::t $lang more.hint n [llength $rest] cmd [::md::cmdhint $lang more]] -notice $notice
}

proc ::md::out::more {key lang} {
    variable more
    if {![info exists more($key)]} { return 0 }
    lassign $more($key) ts target notice rest first
    unset more($key)
    paged $target $key $rest $first $notice $lang
    return 1
}

proc ::md::out::gc {} {
    variable more
    variable sent
    set now [clock seconds]
    foreach k [array names more] {
        if {$now - [lindex $more($k) 0] > 600} { unset more($k) }
    }
    foreach k [array names sent] {
        set keep {}
        foreach t $sent($k) { if {$now - $t < 60} { lappend keep $t } }
        if {[llength $keep]} { set sent($k) $keep } else { unset sent($k) }
    }
}

proc ::md::out::shutdown {} {
    variable pending
    catch {flush}
    array unset pending
}

# Shorthands for markup
proc ::md::c {role text} { return "\{c:$role\}$text\{/c\}" }
proc ::md::b {text} { return "\{b\}$text\{b\}" }
