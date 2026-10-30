# Unit tests for lib/json.tcl and lib/util.tcl helpers
set ::T(noload) 1
source [file join [file dirname [info script]] testlib.tcl]
source -encoding utf-8 [file join $::T(root) lib util.tcl]
source -encoding utf-8 [file join $::T(root) lib json.tcl]

test json.basic {
    set d [md::json::parse {{"a":[1,2,{"b":"x"}],"t":true,"f":false,"n":null,"e":[],"o":{},"neg":-1.5e3}}]
    list [dict get $d a] [dict get $d t] [dict get $d f] [dict get $d n] [dict get $d e] [dict get $d o] [dict get $d neg]
} {{1 2 {b x}} true false {} {} {} -1.5e3}

test json.escapes {
    set d [md::json::parse {{"s":"q\"b\\s\/ é \t."}}]
    dict get $d s
} "q\"b\\s/ é \t."

test json.no_injection {
    set d [md::json::parse {{"s":"[set ::pwned 1] $::env(PATH) \\u0041"}}]
    list [info exists ::pwned] [string equal [dict get $d s] [string map {BS \\} {[set ::pwned 1] $::env(PATH) BSu0041}]]
} {0 1}

test json.surrogate {
    set d [md::json::parse [string map {BS \\} {{"s":"aBSud83dBSude00b"}}]]
    string length [dict get $d s]
} 3

test json.errors {
    list [catch {md::json::parse {{"a":}}}] [catch {md::json::parse {[1,2}}] [catch {md::json::parse ""}]
} {1 1 1}

test json.encode {
    md::json::obj a [md::json::str "q\"\\\n"] b [md::json::num 3] c [md::json::strs {x y}] d [md::json::bool 1]
} {{"a":"q\"\\\n","b":3,"c":["x","y"],"d":true}}

test json.roundtrip {
    set s "tab\there \"quoted\" back\\slash ñ"
    dict get [md::json::parse [md::json::obj k [md::json::str $s]]] k
} "tab\there \"quoted\" back\\slash ñ"

test util.norm {
    md::norm "Atlético  de Madrid!  München-Çelik"
} {atletico de madrid munchen celik}

test util.mscore {
    list [md::mscore "atletico" [list "atletico madrid" atm]] \
         [md::mscore "madrid" [list "real madrid"]] \
         [md::mscore "rma" [list "real madrid" rma]] \
         [md::mscore "barcelna" [list "barcelona"]] \
         [md::mscore "xyz" [list "barcelona"]]
} {85 80 100 50 0}

test util.iso {
    list [md::iso2epoch 2026-10-13T19:00Z] [md::iso2epoch 2026-10-13T21:00:00+02:00] [md::iso2epoch 2026-10-13T19:00:00.000+00:00]
} {1791918000 1791918000 1791918000}

test util.parse_day {
    list [md::parse_day 2026-12-25] [md::parse_day 25/12/2026] [string length [md::parse_day mañana]] [md::parse_day nonsense]
} {20261225 20261225 8 {}}

test util.wrap {
    set lines [md::wrap [string repeat "word " 100] 60]
    set ok 1
    foreach l $lines { if {[md::bytes $l] > 60} { set ok 0 } }
    list $ok [expr {[llength $lines] > 5}]
} {1 1}

test util.wrap_utf8 {
    set lines [md::wrap [string repeat "áéíóú " 40] 50]
    set ok 1
    foreach l $lines { if {[md::bytes $l] > 50} { set ok 0 } }
    set ok
} 1

test util.hm2min {
    list [md::hm2min 23:30] [md::hm2min 8] [md::hm2min 25:00]
} {1410 480 {}}

done
