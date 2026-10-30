# Matchday - lib/http.tcl
# Non-blocking HTTP client for Eggdrop.
#
#  * Transport: Tcl http + tls when available, otherwise an asynchronous
#    curl subprocess (very common on shells without tcltls), otherwise
#    plain http only.
#  * Response cache with per-request TTL and stale fallback on errors.
#  * Coalescing: concurrent requests for the same URL share one fetch.
#  * Concurrency limit, per-host exponential backoff on 429/5xx/timeouts.
#  * Offline/fixture mode for tests: http.offline + md::http::fixture.
#
# Callback signature:  {*}$cb status data meta
#   status: ok | error ; data: body (or decoded JSON) or error text
#   meta:   dict {code url cached age headers}

package require http

namespace eval ::md::http {
    variable transport ""
    variable seq 0
    variable queue {}
    variable active 0
    variable req
    variable cache
    variable inflight
    variable hostfail
    variable stats
    variable fixtures
    array set req {}
    array set cache {}
    array set inflight {}
    array set hostfail {}
    array set stats {requests 0 errors 0 bytes 0 cachehits 0 coalesced 0 started 0}
    array set fixtures {}
}

proc ::md::http::init {} {
    variable transport
    variable stats
    set stats(started) [clock seconds]
    set want [::md::cfg http.transport auto]
    set transport ""
    if {[::md::cfg http.offline 0]} {
        set transport offline
    } elseif {$want in {auto tls}} {
        if {![catch {package require tls} v]} {
            # SNI is required by most CDNs (ESPN included)
            if {[package vsatisfies $v 1.7-]} {
                ::http::register https 443 [list ::tls::socket -autoservername 1]
            } else {
                ::http::register https 443 [list ::md::http::_tlssock]
            }
            set transport tls
            ::md::log info "HTTP transport: tls $v"
        }
    }
    if {$transport eq "" && $want in {auto curl}} {
        if {[auto_execok curl] ne ""} {
            set transport curl
            ::md::log info "HTTP transport: curl (tcltls not available)"
        }
    }
    if {$transport eq ""} {
        set transport plain
        ::md::log warn "No tls package and no curl found: only plain http:// will work. Install tcltls (package 'tcl-tls') or curl."
    }
    ::http::config -useragent [::md::cfg http.useragent "Mozilla/5.0 (X11; Linux x86_64) Matchday-Eggdrop/$::md::version"]
    ::md::every http.gc 300000 ::md::http::gc
}

proc ::md::http::_tlssock {args} {
    set host [lindex $args end-1]
    ::tls::socket -servername $host {*}$args
}

# get url cb ?-ttl s? ?-headers {k v ...}? ?-timeout ms? ?-json 1? ?-tag name?
proc ::md::http::get {url cb args} {
    variable cache
    variable inflight
    variable req
    variable seq
    variable queue
    variable stats
    set o [dict merge {-ttl 0 -headers {} -timeout 0 -json 0 -tag ""} $args]
    set ttl [dict get $o -ttl]
    set now [clock seconds]

    if {$ttl > 0 && [info exists cache($url)]} {
        lassign $cache($url) ts body meta parsed
        if {$now - $ts < $ttl} {
            incr stats(cachehits)
            dict set meta cached 1
            dict set meta age [expr {$now - $ts}]
            after 0 [list ::md::http::_deliver $url $cb ok $body $meta [dict get $o -json]]
            return
        }
    }
    if {[info exists inflight($url)]} {
        incr stats(coalesced)
        set id $inflight($url)
        dict lappend req($id) waiters [list $cb [dict get $o -json]]
        return
    }
    set id [incr seq]
    set timeout [dict get $o -timeout]
    if {$timeout <= 0} { set timeout [expr {[::md::cfg http.timeout 20] * 1000}] }
    set req($id) [dict create url $url headers [dict get $o -headers] timeout $timeout \
        waiters [list [list $cb [dict get $o -json]]] tag [dict get $o -tag] ttl $ttl t0 0]
    set inflight($url) $id
    lappend queue $id
    _pump
}

# Convenience: GET + JSON decode
proc ::md::http::json {url cb args} {
    get $url $cb {*}$args -json 1
}

proc ::md::http::_pump {} {
    variable queue
    variable active
    variable req
    variable hostfail
    variable transport
    set max [::md::cfg http.maxconcurrent 4]
    while {$active < $max && [llength $queue]} {
        set id [lindex $queue 0]
        set queue [lrange $queue 1 end]
        if {![info exists req($id)]} continue
        set url [dict get $req($id) url]
        set host [_host $url]
        if {[info exists hostfail($host)] && [clock seconds] < [lindex $hostfail($host) 1]} {
            _finish $id error "backoff: $host temporarily disabled after errors" 0 {}
            continue
        }
        incr active
        dict set req($id) t0 [clock milliseconds]
        set t $transport
        if {$t eq "curl" && [string match http://* $url]} { set t plain }
        if {$t eq "tls" || $t eq "plain"} {
            _start_http $id
        } elseif {$t eq "curl"} {
            _start_curl $id
        } else {
            _start_offline $id
        }
    }
}

proc ::md::http::_host {url} {
    if {[regexp {^https?://([^/:?#]+)} $url -> h]} { return [string tolower $h] }
    return ""
}

# ---------------------------------------------------------------- http/tls

proc ::md::http::_start_http {id} {
    variable req
    set r $req($id)
    set hdr [list Accept application/json]
    foreach {k v} [dict get $r headers] { lappend hdr $k $v }
    if {[catch {
        ::http::geturl [dict get $r url] -binary 1 -timeout [dict get $r timeout] \
            -headers $hdr -command [list ::md::http::_done_http $id]
    } tok]} {
        _finish $id error "connect: $tok" 0 {}
    } else {
        dict set req($id) token $tok
    }
}

proc ::md::http::_done_http {id tok} {
    set st [::http::status $tok]
    set code [::http::ncode $tok]
    set body [::http::data $tok]
    set meta [::http::meta $tok]
    set err [::http::error $tok]
    ::http::cleanup $tok
    set hdrs {}
    foreach {k v} $meta { dict set hdrs [string tolower $k] $v }
    if {$st ne "ok"} {
        if {$err eq ""} { set err $st }
        _finish $id error "$st: $err" 0 $hdrs
        return
    }
    # follow one level of redirect
    if {$code in {301 302 303 307 308} && [dict exists $hdrs location]} {
        variable req
        set loc [dict get $hdrs location]
        if {![dict exists $req($id) redirected]} {
            dict set req($id) redirected 1
            dict set req($id) url $loc
            _start_http $id
            return
        }
    }
    if {[catch {encoding convertfrom utf-8 $body} txt]} { set txt $body }
    _finish $id [expr {$code >= 200 && $code < 300 ? "ok" : "error"}] $txt $code $hdrs
}

# ---------------------------------------------------------------- curl

proc ::md::http::_start_curl {id} {
    variable req
    set r $req($id)
    set secs [expr {max(1, [dict get $r timeout] / 1000)}]
    set cmd [list curl -s -S -L --max-redirs 3 --compressed -m $secs -D - \
        -A [::md::cfg http.useragent "Mozilla/5.0 (X11; Linux x86_64) Matchday-Eggdrop/$::md::version"] \
        -H "Accept: application/json"]
    foreach {k v} [dict get $r headers] { lappend cmd -H "$k: $v" }
    lappend cmd [dict get $r url]
    if {[catch {open |[concat $cmd [list 2>@1]] r} fh]} {
        _finish $id error "curl: $fh" 0 {}
        return
    }
    fconfigure $fh -translation binary -blocking 0
    dict set req($id) fh $fh
    dict set req($id) buf ""
    fileevent $fh readable [list ::md::http::_curl_read $id]
    # watchdog in case curl hangs
    ::md::timer http.curl.$id [expr {[dict get $r timeout] + 5000}] [list ::md::http::_curl_kill $id]
}

proc ::md::http::_curl_read {id} {
    variable req
    if {![info exists req($id)]} return
    set fh [dict get $req($id) fh]
    set chunk [read $fh]
    dict append req($id) buf $chunk
    if {![eof $fh]} return
    ::md::cancel http.curl.$id
    fileevent $fh readable {}
    fconfigure $fh -blocking 1
    set failed [catch {close $fh} cerr]
    set raw [dict get $req($id) buf]
    # strip header blocks (possibly several because of redirects / 100-continue)
    set code 0
    set hdrs {}
    while {[regexp {^HTTP/[\d.]+ (\d+)[^\r\n]*\r?\n} $raw -> c]} {
        set end [string first "\r\n\r\n" $raw]
        set skip 4
        if {$end < 0} { set end [string first "\n\n" $raw]; set skip 2 }
        if {$end < 0} break
        set code $c
        set hdrs {}
        foreach line [lrange [split [string range $raw 0 $end] \n] 1 end] {
            if {[regexp {^([^:]+):\s*(.*?)\r?$} $line -> k v]} { dict set hdrs [string tolower $k] $v }
        }
        set raw [string range $raw [expr {$end + $skip}] end]
    }
    if {$code == 0} {
        set msg [string trim [encoding convertfrom utf-8 $raw]]
        if {$msg eq ""} { set msg $cerr }
        _finish $id error "curl: [::md::trunc $msg 200]" 0 {}
        return
    }
    if {[catch {encoding convertfrom utf-8 $raw} txt]} { set txt $raw }
    _finish $id [expr {$code >= 200 && $code < 300 ? "ok" : "error"}] $txt $code $hdrs
}

proc ::md::http::_curl_kill {id} {
    variable req
    if {![info exists req($id)]} return
    catch {
        set fh [dict get $req($id) fh]
        catch {exec kill {*}[pid $fh]}
        close $fh
    }
    _finish $id error "timeout (curl)" 0 {}
}

# ---------------------------------------------------------------- offline

# Register canned responses: glob pattern -> body (or {file path})
proc ::md::http::fixture {pattern body {code 200}} {
    variable fixtures
    set fixtures($pattern) [list $code $body]
}

proc ::md::http::clear_fixtures {} {
    variable fixtures
    array unset fixtures
}

proc ::md::http::_start_offline {id} {
    variable req
    variable fixtures
    set url [dict get $req($id) url]
    foreach pat [lsort -decreasing [array names fixtures]] {
        if {[string match $pat $url]} {
            lassign $fixtures($pat) code body
            if {[llength $body] == 2 && [lindex $body 0] eq "file"} {
                set body [::md::readfile [lindex $body 1]]
            }
            after 1 [list ::md::http::_finish $id [expr {$code < 300 ? "ok" : "error"}] $body $code {}]
            return
        }
    }
    after 1 [list ::md::http::_finish $id error "offline: no fixture for $url" 404 {}]
}

# ---------------------------------------------------------------- finish

proc ::md::http::_finish {id status body code hdrs} {
    variable req
    variable active
    variable inflight
    variable cache
    variable stats
    variable hostfail
    if {![info exists req($id)]} return
    set r $req($id)
    unset req($id)
    set url [dict get $r url]
    if {[info exists inflight($url)] && $inflight($url) == $id} { unset inflight($url) }
    if {[dict get $r t0] > 0} { incr active -1 }
    incr stats(requests)
    set tag [dict get $r tag]
    if {$tag ne ""} {
        if {![info exists stats(tag:$tag)]} { set stats(tag:$tag) 0 }
        incr stats(tag:$tag)
    }
    set host [_host $url]
    set ms [expr {[dict get $r t0] ? [clock milliseconds] - [dict get $r t0] : 0}]
    set meta [dict create code $code url $url cached 0 age 0 headers $hdrs ms $ms]

    if {$status eq "ok"} {
        incr stats(bytes) [string length $body]
        unset -nocomplain hostfail($host)
        set cache($url) [list [clock seconds] $body $meta "" [dict get $r ttl]]
    } else {
        incr stats(errors)
        set stats(lasterror) "[clock format [clock seconds] -format %H:%M:%S] $url -> $body"
        ::md::log debug "http error $url: $body"
        # back off on throttling, server errors and network failures (not on 4xx)
        if {$code == 0 && [string match backoff:* $body]} {
            # already blocked, don't extend
        } elseif {$code == 0 || $code == 429 || $code >= 500} {
            set n [expr {[info exists hostfail($host)] ? [lindex $hostfail($host) 0] + 1 : 1}]
            if {$n >= [::md::cfg http.backoff_after 3]} {
                set wait [expr {min(600, 15 * (1 << min($n - 1, 6)))}]
            } else {
                set wait 0
            }
            set hostfail($host) [list $n [expr {[clock seconds] + $wait}]]
            if {$wait > 0} { ::md::log warn "HTTP: backing off $host for ${wait}s after $n errors" }
        }
        # serve stale data rather than nothing
        set maxstale [::md::cfg http.stale_max 1800]
        if {[info exists cache($url)] && [clock seconds] - [lindex $cache($url) 0] < $maxstale} {
            lassign $cache($url) ts sbody smeta
            dict set smeta cached 1
            dict set smeta stale 1
            dict set smeta age [expr {[clock seconds] - $ts}]
            dict set smeta error $body
            set status ok
            set body $sbody
            set meta $smeta
        }
    }
    foreach w [dict get $r waiters] {
        lassign $w cb isjson
        _deliver $url $cb $status $body $meta $isjson
    }
    _pump
}

proc ::md::http::_deliver {url cb status body meta isjson} {
    variable cache
    if {$status eq "ok" && $isjson} {
        # parse once per cached body
        set parsed ""
        if {[info exists cache($url)] && [lindex $cache($url) 1] eq $body && [lindex $cache($url) 3] ne ""} {
            set parsed [lindex $cache($url) 3]
        } else {
            if {[catch {::md::json::parse $body} parsed]} {
                set status error
                set body "invalid JSON: $parsed"
                set parsed ""
            } elseif {[info exists cache($url)] && [lindex $cache($url) 1] eq $body} {
                lset cache($url) 3 $parsed
            }
        }
        if {$status eq "ok"} { set body $parsed }
    }
    if {[catch {uplevel #0 [linsert $cb end $status $body $meta]} err opts]} {
        ::md::log error "http callback for $url: $err"
        ::md::log debug [dict get $opts -errorinfo]
    }
}

# Drop expired cache entries (keeps stale window), cap cache size.
proc ::md::http::gc {} {
    variable cache
    set now [clock seconds]
    set maxstale [::md::cfg http.stale_max 1800]
    foreach url [array names cache] {
        lassign $cache($url) ts body meta parsed ttl
        if {$now - $ts > max($ttl, $maxstale)} { unset cache($url) }
    }
    set max [::md::cfg http.cache_max 400]
    if {[array size cache] > $max} {
        set all {}
        foreach url [array names cache] { lappend all [list [lindex $cache($url) 0] $url] }
        foreach e [lrange [lsort -integer -index 0 $all] 0 end-$max] { unset cache([lindex $e 1]) }
    }
}

proc ::md::http::flush_cache {{pattern *}} {
    variable cache
    array unset cache $pattern
}

proc ::md::http::shutdown {} {
    variable req
    variable queue
    variable active
    variable inflight
    foreach id [array names req] {
        catch {::http::reset [dict get $req($id) token]}
        catch {close [dict get $req($id) fh]}
        ::md::cancel http.curl.$id
    }
    array unset req
    array unset inflight
    set queue {}
    set active 0
}

proc ::md::http::status {} {
    variable stats
    variable transport
    variable cache
    variable hostfail
    variable active
    variable queue
    set blocked {}
    foreach h [array names hostfail] {
        set until [lindex $hostfail($h) 1]
        if {$until > [clock seconds]} { lappend blocked "$h ([expr {$until - [clock seconds]}]s)" }
    }
    dict create transport $transport requests $stats(requests) errors $stats(errors) \
        bytes $stats(bytes) cachehits $stats(cachehits) coalesced $stats(coalesced) \
        cached [array size cache] active $active queued [llength $queue] blocked $blocked \
        lasterror [expr {[info exists stats(lasterror)] ? $stats(lasterror) : ""}]
}
