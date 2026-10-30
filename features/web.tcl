# Matchday - features/web.tcl
# Tiny read-only HTTP server inside Eggdrop: live dashboard + JSON API.
#
#   GET /                     dashboard (web/index.html)
#   GET /api/live             live + today's matches
#   GET /api/ranking?chan=#c&period=season|month|week|all
#   GET /api/status           bot health
#   GET /api/events           recent engine events
#
# Binds to 127.0.0.1 by default; set web.token to require ?token=...
# Put a reverse proxy (nginx/caddy) in front if exposing it publicly.

namespace eval ::md::web {
    variable server ""
    variable conns
    variable page ""
    array set conns {}
}

proc ::md::web::init {} {
    variable server
    variable page
    set port [::md::cfg web.port 0]
    if {$port <= 0} return
    set f [file join $::md::base web index.html]
    if {[file exists $f]} { set page [::md::readfile $f] }
    set addr [::md::cfg web.bind 127.0.0.1]
    if {[catch {socket -server ::md::web::_accept -myaddr $addr $port} s]} {
        ::md::log error "web: cannot listen on $addr:$port: $s"
        return
    }
    set server $s
    ::md::log info "web dashboard on http://$addr:$port/"
}

proc ::md::web::shutdown {} {
    variable server
    variable conns
    if {$server ne ""} { catch {close $server}; set server "" }
    foreach c [array names conns] { catch {close $c} }
    array unset conns
}

proc ::md::web::_accept {sock addr port} {
    variable conns
    if {[array size conns] > [::md::cfg web.max_conns 20]} { catch {close $sock}; return }
    set conns($sock) [dict create buf "" t [clock seconds] addr $addr]
    fconfigure $sock -blocking 0 -translation binary -buffering full
    fileevent $sock readable [list ::md::web::_read $sock]
    after 10000 [list ::md::web::_timeout $sock]
}

proc ::md::web::_timeout {sock} {
    variable conns
    if {[info exists conns($sock)]} { _close $sock }
}

proc ::md::web::_close {sock} {
    variable conns
    unset -nocomplain conns($sock)
    catch {close $sock}
}

proc ::md::web::_read {sock} {
    variable conns
    if {![info exists conns($sock)]} return
    if {[catch {read $sock} chunk] || ([eof $sock] && $chunk eq "")} { _close $sock; return }
    dict append conns($sock) buf $chunk
    set buf [dict get $conns($sock) buf]
    if {[string length $buf] > 8192} { _respond $sock 413 text/plain "too large"; return }
    if {[string first "\r\n\r\n" $buf] < 0 && [string first "\n\n" $buf] < 0} return
    fileevent $sock readable {}
    set line [lindex [split $buf \n] 0]
    if {![regexp {^(GET|HEAD) (\S+) HTTP/1\.[01]} $line -> method target]} {
        _respond $sock 405 text/plain "method not allowed"
        return
    }
    set hdrs {}
    foreach l [lrange [split $buf \n] 1 end] {
        if {[regexp {^([^:]+):\s*(.*?)\r?$} $l -> k v]} { dict set hdrs [string tolower $k] $v }
    }
    set path $target
    set query ""
    regexp {^([^?#]*)(?:\?([^#]*))?} $target -> path query
    set q [_query $query]
    # auth
    set token [::md::cfg web.token ""]
    if {$token ne ""} {
        set given [::md::dg $q "" token]
        if {[dict exists $hdrs authorization]} { regexp {^Bearer\s+(.+)$} [dict get $hdrs authorization] -> given }
        if {$given ne $token} { _respond $sock 401 text/plain "unauthorized"; return }
    }
    if {[catch {_route $sock $path $q $method} err opts]} {
        ::md::log error "web: $err"
        ::md::log debug [dict get $opts -errorinfo]
        _respond $sock 500 text/plain "internal error"
    }
}

proc ::md::web::_query {s} {
    set d {}
    foreach kv [split $s &] {
        if {$kv eq ""} continue
        lassign [split $kv =] k v
        dict set d [_unesc $k] [_unesc $v]
    }
    return $d
}

proc ::md::web::_unesc {s} {
    set s [string map {+ " "} $s]
    set out ""
    set bytes ""
    while {[regexp -indices {%([0-9a-fA-F]{2})} $s all hex]} {
        append bytes [string range $s 0 [expr {[lindex $all 0] - 1}]]
        append bytes [format %c [scan [string range $s {*}$hex] %x]]
        set s [string range $s [expr {[lindex $all 1] + 1}] end]
    }
    append bytes $s
    if {[catch {encoding convertfrom utf-8 $bytes} out]} { set out $bytes }
    return $out
}

proc ::md::web::_respond {sock code ctype body {head 0}} {
    set reason [dict get {200 OK 401 Unauthorized 404 {Not Found} 405 {Method Not Allowed} 413 {Too Large} 500 {Internal Server Error}} $code]
    set data [encoding convertto utf-8 $body]
    set h "HTTP/1.0 $code $reason\r\nContent-Type: $ctype; charset=utf-8\r\nContent-Length: [string length $data]\r\nCache-Control: no-store\r\nX-Content-Type-Options: nosniff\r\nReferrer-Policy: no-referrer\r\nConnection: close\r\n\r\n"
    catch {
        puts -nonewline $sock $h
        if {!$head} { puts -nonewline $sock $data }
        flush $sock
    }
    _close $sock
}

proc ::md::web::_route {sock path q method} {
    variable page
    set head [expr {$method eq "HEAD"}]
    switch -- $path {
        / - /index.html {
            if {$page eq ""} { _respond $sock 404 text/plain "dashboard missing" $head; return }
            _respond $sock 200 text/html $page $head
        }
        /api/live    { _respond $sock 200 application/json [api_live $q] $head }
        /api/ranking { _respond $sock 200 application/json [api_ranking $q] $head }
        /api/status  { _respond $sock 200 application/json [api_status] $head }
        /api/events  { _respond $sock 200 application/json [api_events] $head }
        default      { _respond $sock 404 text/plain "not found" $head }
    }
}

# ---------------------------------------------------------------- JSON views

proc ::md::web::_side {s m side} {
    set reds 0
    foreach e [dict get $m events] {
        if {[dict get $e side] eq $side && [dict get $e type] in {red yred}} { incr reds }
    }
    ::md::json::obj name [::md::json::str [dict get $s name]] short [::md::json::str [dict get $s short]] \
        abbr [::md::json::str [dict get $s abbr]] score [::md::json::str [dict get $s score]] \
        so [::md::json::str [dict get $s so]] reds $reds ls [::md::json::strs [dict get $s ls]]
}

proc ::md::web::match_json {m} {
    set evs {}
    foreach e [dict get $m events] {
        if {[dict get $e type] eq "so"} continue
        lappend evs [::md::json::obj type [::md::json::str [dict get $e type]] min [::md::json::str [dict get $e min]] \
            side [::md::json::str [dict get $e side]] player [::md::json::str [dict get $e player]]]
    }
    set res {}
    foreach r [lrange [::md::dg $m {} results] 0 9] {
        lappend res [::md::json::obj pos [::md::json::str [dict get $r pos]] name [::md::json::str [dict get $r name]] extra [::md::json::str [dict get $r extra]]]
    }
    ::md::json::obj uid [::md::json::str [dict get $m uid]] league [::md::json::str [dict get $m lkey]] \
        lname [::md::json::str [dict get $m lname]] sport [::md::json::str [dict get $m sport]] \
        kind [::md::json::str [dict get $m kind]] state [::md::json::str [dict get $m state]] \
        code [::md::json::str [dict get $m code]] detail [::md::json::str [dict get $m detail]] \
        minute [::md::json::str [dict get $m minute]] start [dict get $m start] \
        note [::md::json::str [dict get $m note]] venue [::md::json::str [dict get $m venue]] \
        home [_side [dict get $m home] $m h] away [_side [dict get $m away] $m a] \
        events [::md::json::arr $evs] results [::md::json::arr $res] link [::md::json::str [dict get $m link]]
}

proc ::md::web::api_live {q} {
    set now [clock seconds]
    set out {}
    set filter [::md::dg $q "" league]
    foreach m [::md::poll::matches] {
        if {$filter ne "" && [dict get $m lkey] ne $filter} continue
        set keep [expr {[dict get $m state] eq "in" || abs([dict get $m start] - $now) < 20 * 3600}]
        if {$keep} { lappend out [match_json $m] }
    }
    ::md::json::obj updated $now matches [::md::json::arr $out]
}

proc ::md::web::api_ranking {q} {
    set chan [::md::dg $q "" chan]
    if {$chan eq ""} {
        set act [::md::chan::active]
        set chan [lindex $act 0]
    }
    set rows {}
    if {$chan ne ""} {
        foreach r [lrange [::md::preds::ranking [::md::chan::key $chan] [::md::dg $q season period]] 0 49] {
            lassign $r ukey nick pts ex n
            lappend rows [::md::json::obj nick [::md::json::str $nick] pts $pts exact $ex n $n]
        }
    }
    set chans {}
    foreach c [::md::chan::active] { lappend chans [::md::json::str $c] }
    ::md::json::obj chan [::md::json::str $chan] channels [::md::json::arr $chans] rows [::md::json::arr $rows]
}

proc ::md::web::api_status {} {
    set h [::md::http::status]
    set ls {}
    foreach l [::md::poll::league_status] {
        lappend ls [::md::json::obj league [::md::json::str [dict get $l lkey]] name [::md::json::str [::md::catalog::label [dict get $l lkey]]] \
            matches [dict get $l n] live [::md::json::bool [dict get $l live]] next [dict get $l next] fails [dict get $l fails]]
    }
    ::md::json::obj version [::md::json::str $::md::version] uptime [expr {[clock seconds] - $::md::started}] \
        transport [::md::json::str [dict get $h transport]] requests [dict get $h requests] errors [dict get $h errors] \
        cachehits [dict get $h cachehits] narrations [llength [::md::narr::sessions]] \
        leagues [::md::json::arr $ls]
}

proc ::md::web::api_events {} {
    set out {}
    foreach r $::md::dispatch::recent {
        lassign $r ts ev uid
        set m [::md::poll::match $uid]
        if {$m eq ""} continue
        set text [::md::out::strip [::md::out::render [::md::render::event [::md::cfg lang.default en] $ev $m] plain unicode]]
        if {$text eq ""} continue
        lappend out [::md::json::obj ts $ts type [::md::json::str [dict get $ev type]] text [::md::json::str $text] league [::md::json::str [dict get $m lkey]]]
    }
    ::md::json::arr $out
}
