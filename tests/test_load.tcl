# Smoke test: the whole bot loads under the Eggdrop stub, binds are in
# place, languages and commands are registered, reload is clean.
source [file join [file dirname [info script]] testlib.tcl]

check load.loaded { set ::md::loaded }
check load.binds { expr {[llength [::md::cmd::list_visible]] > 20} }
check load.pubm  { expr {[llength [binds pubm]] == 1} }
check load.langs { expr {[llength [::md::i18n::available]] >= 2 && "en" in [::md::i18n::available] && "es" in [::md::i18n::available]} }
test  load.alias_es { ::md::i18n::resolve clasificacion } table
test  load.alias_accent { ::md::i18n::resolve "clasificación" } table
test  load.alias_en { ::md::i18n::resolve standings } table
test  load.catalog { ::md::catalog::find laliga } esp.1
test  load.catalog2 { ::md::catalog::find "champions league" } uefa.champions
test  load.catalog3 { ::md::catalog::find "soccer/por.2" } soccer/por.2
test  load.catalog4 { ::md::catalog::find nba } nba
test  load.t { ::md::t es narr.stopped teams X } "Fin de la narración de X."
test  load.fallback { ::md::t xx narr.stopped teams X } "Narration of X ended."

test reload.clean {
    set before [llength $::stub::binds]
    ::md::reload
    list [set ::md::loaded] [expr {[llength $::stub::binds] == $before}]
} {1 1}

check render.markup {
    set s [::md::out::render "{b}x{b} {c:goal}y{/c} {s:goal}" full unicode]
    expr {[string first \x02 $s] >= 0 && [string first \x0303 $s] >= 0}
}
test render.plain { ::md::out::render "{b}x{b} {c:goal}y{/c} {s:yellow}" plain ascii } "x y \[Y\]"

check i18n.plural1 { string equal [::md::t en player.goals n 1] "1 goal" }
check i18n.plural2 { string equal [::md::t en player.goals n "{b}7{b}"] "{b}7{b} goals" }
check i18n.plural_es { string equal [::md::t es player.shots n 1 s 1] "1 tiro (1 a puerta)" }
check out.reset_digit { string equal [::md::out::strip [::md::out::render "{c:red}X{/c}2" full]] "X2" }
done
