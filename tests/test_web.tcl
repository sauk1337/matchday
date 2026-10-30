# Web dashboard test: real sockets against the embedded HTTP server.
set ::md_web_port [expr {20000 + [pid] % 20000}]
source [file join [file dirname [info script]] testlib.tcl]
::md::cfgset web.port $::md_web_port
::md::cfgset web.token ""
::md::web::init

# a known match for /api/live
proc side {id name score} { dict create id $id name $name short $name abbr "" score $score so "" winner false ls {} form "" ha "" order 0 }
::md::poll::store [dict create uid espn:esp.1:5 prov espn lkey esp.1 lname LALIGA sport soccer kind team eid 5 \
    start [clock seconds] state in code live sname "" detail "" clock "" minute "55'" period 2 \
    home [side 1 "Real Madrid" 1] away [side 2 "Barcelona" 1] \
    events [list [dict create k x type goal side h min "12'" clock 720 player "Vini \"Jr\"" assist "" pid 1 scored 1 text ""]] \
    round "" venue "" link "" updated [clock seconds] note "" tv {}]

proc http {path} {
    set s [socket 127.0.0.1 $::md_web_port]
    fconfigure $s -translation binary
    puts -nonewline $s "GET $path HTTP/1.0\r\nHost: x\r\n\r\n"
    flush $s
    set ::_resp ""
    fileevent $s readable [list apply {{s} {
        append ::_resp [read $s]
        if {[eof $s]} { close $s; set ::_done 1 }
    }} $s]
    vwait ::_done
    set i [string first "\r\n\r\n" $::_resp]
    list [lindex [split $::_resp " "] 1] [encoding convertfrom utf-8 [string range $::_resp [expr {$i + 4}] end]]
}

lassign [http /] code body
test web.index { list $code [expr {[string first "Matchday" $body] >= 0}] } {200 1}

lassign [http /api/live] code body
set j [::md::json::parse $body]
test web.live { list $code [dict get [lindex [dict get $j matches] 0] home name] [dict get [lindex [dict get [lindex [dict get $j matches] 0] events] 0] player] } {200 {Real Madrid} {Vini "Jr"}}

lassign [http /api/status] code body
check web.status { expr {$code == 200 && [dict get [::md::json::parse $body] version] eq $::md::version} }

lassign [http /api/ranking?chan=%23futbol] code body
test web.ranking { list $code [dict get [::md::json::parse $body] chan] } {200 #futbol}

lassign [http /etc/passwd] code body
test web.404 { set code } 404

::md::cfgset web.token s3cret
lassign [http /api/live] code body
test web.auth_required { set code } 401
lassign [http /api/live?token=s3cret] code body
test web.auth_ok { set code } 200

done
