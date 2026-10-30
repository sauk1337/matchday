# =========================================================================
#  Matchday - live sports for Eggdrop
#  Live scores, alerts, narration, predictions and stats for football and
#  many other sports. Self-sufficient: no API key needed (ESPN public data),
#  optional API-Football integration.
#
#  Install:  add to eggdrop.conf ->   source scripts/matchday/matchday.tcl
#            copy matchday.conf.example to matchday.conf and edit it
#            .chanset #yourchannel +matchday
#  Requires: Eggdrop 1.8.4+ (1.9/1.10 recommended), Tcl 8.6+,
#            and either the tcltls package or the curl binary.
# =========================================================================

namespace eval ::md {
    variable version "1.0.0"
    variable base [file dirname [file normalize [info script]]]
    variable script [file normalize [info script]]
    variable binds {}
    variable started [clock seconds]
    variable conf
}

# Re-sourcing (".rehash" or "!md reload") cleanly replaces the old instance
if {[info exists ::md::loaded] && $::md::loaded} {
    catch {::md::shutdown}
}
set ::md::loaded 0
catch {array unset ::md::conf}
array set ::md::conf {}

proc ::md::_src {rel} {
    uplevel #0 [list source -encoding utf-8 [file join $::md::base $rel]]
}

foreach ::md::_f {
    lib/util.tcl lib/json.tcl lib/http.tcl lib/store.tcl lib/i18n.tcl lib/out.tcl
    engine/catalog.tcl engine/poller.tcl engine/diff.tcl engine/render.tcl engine/dispatch.tcl engine/teams.tcl
    providers/espn.tcl providers/apifootball.tcl
    features/chan.tcl features/subs.tcl features/commands.tcl features/info.tcl
    engine/prob.tcl features/player.tcl
    features/usercmds.tcl features/admin.tcl features/narrator.tcl features/predictions.tcl
    features/hot.tcl features/videos.tcl features/replay.tcl features/web.tcl
} {
    ::md::_src $::md::_f
}
unset ::md::_f

# ---------------------------------------------------------------- config

proc ::md::load_config {} {
    variable base
    set f [file join $base matchday.conf]
    if {[file exists $f]} {
        if {[catch {namespace eval ::md [list source -encoding utf-8 $f]} err]} {
            log error "matchday.conf: $err"
        }
    } else {
        log warn "matchday.conf not found, using defaults (copy matchday.conf.example to matchday.conf)"
    }
    # test harness / embedding overrides
    if {[info exists ::md_test_conf]} {
        foreach {k v} $::md_test_conf { cfgset $k $v }
    }
}

# ---------------------------------------------------------------- binds

proc ::md::bind {type flags mask proc} {
    variable binds
    ::bind $type $flags $mask $proc
    lappend binds [list $type $flags $mask $proc]
}

proc ::md::unbind_all {} {
    variable binds
    foreach b $binds {
        lassign $b type flags mask proc
        catch {::unbind $type $flags $mask $proc}
    }
    set binds {}
}

# ---------------------------------------------------------------- lifecycle

proc ::md::save_all {} {
    catch {::md::poll::save}
    catch {::md::narr::save}
    ::md::store::flush
}

proc ::md::on_evnt {type} {
    save_all
}

proc ::md::shutdown {} {
    catch {::md::replay::stop_all}
    catch {::md::narr::shutdown}
    catch {::md::web::shutdown}
    catch {::md::out::shutdown}
    save_all
    ::md::cancel_all
    catch {::md::http::shutdown}
    unbind_all
    set ::md::loaded 0
}

proc ::md::reload {} {
    variable script
    shutdown
    if {[catch {uplevel #0 [list source -encoding utf-8 $script]} err]} {
        putlog "Matchday: reload failed: $err"
    }
}

proc ::md::init {} {
    load_config
    if {[info commands ::setudef] ne ""} { setudef flag matchday }
    ::md::store::init
    ::md::i18n::load_all
    ::md::http::init
    ::md::out::init
    ::md::teams::init
    ::md::subs::init
    ::md::preds::init
    ::md::hot::init
    ::md::vid::init
    ::md::poll::restore
    ::md::narr::init
    ::md::cmd::init
    ::md::web::init
    ::md::poll::init
    ::md::bind evnt - prerehash ::md::on_evnt
    ::md::bind evnt - prerestart ::md::on_evnt
    ::md::bind evnt - sigterm ::md::on_evnt
    ::md::bind evnt - sighup ::md::on_evnt
    ::md::bind join - * ::md::subs::on_join
    ::md::every core.save [expr {[::md::cfg data.save_interval 120] * 1000}] ::md::save_all
    set ::md::loaded 1
    log info "v$::md::version loaded ([llength [::md::catalog::keys]] competitions, languages: [join [::md::i18n::available] ,])"
}

::md::init
