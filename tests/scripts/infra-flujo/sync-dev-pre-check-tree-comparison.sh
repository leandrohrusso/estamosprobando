#!/usr/bin/env bash
# =====================================================================
# sync-dev-pre-check-tree-comparison.sh · invariante mecánico de la
# detección unificada de squash merge en sync-dev-after-squash-merge.sh
# =====================================================================
# El script `scripts/sync-dev-after-squash-merge.sh` tiene DOS guards
# estructuralmente equivalentes que cuentan commits "ahead" por historia
# y abortan si hay alguno:
#
#   - Guard 2.6.b · defense-in-depth contra pérdida de commits locales
#     no pusheados (DT-NNN). Usa `git rev-list origin/main..dev`.
#   - Guard sección 4 · check estándar que aborta si
#     `origin/dev` tiene commits no mergeados a `origin/main`. Usa
#     `git rev-list origin/main..origin/dev`.
#
# Pre-refinamiento iterativo upstream, AMBOS guards emitían FALSO POSITIVO en el happy path
# squash merge: post `gh pr merge --squash`, dev mantiene los N commits
# del PR con SHAs originales mientras origin/main tiene 1 squash commit
# con MISMO contenido pero distinta historia. Los 2 guards contaban N
# commits ahead y abortaban innecesariamente (cero pérdida real porque
# el contenido ya está en main vía squash).
#
# Refinamiento iterativo upstream (firma user): detección unificada de
# squash merge ARRIBA de los 2 guards · variable `SQUASH_DETECTED=true/
# false` calculada UNA vez comparando `dev^{tree}` con
# `origin/main^{tree}` · consumida en AMBOS guards como pre-check. Si
# trees coinciden → skipea los 2 guards (happy path). Si difieren →
# guards aplican intactos (protección DT-NNN + check estándar preservado).
#
# Este smoke defiende los 4 invariantes mecánicos del refinamiento:
#
#   1. Tree-comparison primitivas presentes · `git rev-parse "dev^{tree}"`
#      + `git rev-parse "origin/main^{tree}"` + comparación de igualdad.
#   2. Variable unificada `SQUASH_DETECTED` declarada (default `false`)
#      + seteada a `true` cuando trees coinciden · mensaje informativo
#      "Squash merge detectado" visible al user.
#   3. Guard 2.6.b (DT-NNN) consulta `[ "$SQUASH_DETECTED" = false ]`
#      como pre-condición + mantiene ABORT message + 2 paths de rescate.
#   4. Guard sección 4 (check estándar) consulta `[ "$SQUASH_DETECTED" =
#      false ]` como pre-condición + mantiene ABORT message con
#      `origin/dev tiene N commit(s) que NO están en origin/main`.
#
# Si un refactor remueve cualquiera de los 4 invariantes, el pre-check
# rompe silenciosamente (FP vuelve en uno o ambos guards · O DT-NNN
# desaparece · O guard sección 4 desaparece · O variable unificada se
# desincroniza). Sin este smoke, la regresión solo se atrapa cuando
# alguien sufre el FP en happy path o pierde commits locales en
# producción.
#
# Severidad: 🔴 ABORT en job `lint` · paridad con `rules-shape-p8.sh`
# y `skip-ci-not-in-pr-head.sh` · el script es infra crítica de la
# regla #27 push-and-ci-policy.
#
# Memoria fuente: .claude/memory/feedback/sync-dev-after-squash-destroys-unpushed-local-commits.md
# Regla firme: .claude/rules/push-and-ci-policy.md § "Re-sincronizar dev con main"
#
# Uso:
#   bash tests/scripts/infra-flujo/sync-dev-pre-check-tree-comparison.sh
#
# Exit 0 si los 4 invariantes presentes · exit 1 al primer fallo.
# =====================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/sync-dev-after-squash-merge.sh"

ok() { printf '\033[32m✓ %s\033[0m\n' "$*"; }
fail() { printf '\033[31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

# Pre-condición: el script existe.
[ -f "$SCRIPT" ] || fail "scripts/sync-dev-after-squash-merge.sh no existe en $SCRIPT"

# Assert 1 · Tree-comparison primitivas presentes.
# shellcheck disable=SC2016  # patrones literales · $dev_tree / $main_tree son nombres de variables del script bajo test, no expansiones de este smoke
grep -qF 'git rev-parse "dev^{tree}"' "$SCRIPT" \
    || fail "Tree-comparison roto · falta 'git rev-parse \"dev^{tree}\"' en el script"
# shellcheck disable=SC2016
grep -qF 'git rev-parse "origin/main^{tree}"' "$SCRIPT" \
    || fail "Tree-comparison roto · falta 'git rev-parse \"origin/main^{tree}\"' en el script"
# shellcheck disable=SC2016
grep -qF '[ "$dev_tree" = "$main_tree" ]' "$SCRIPT" \
    || fail "Tree-comparison roto · falta comparación '[ \"\$dev_tree\" = \"\$main_tree\" ]' en el script"
ok "Tree-comparison primitivas presentes (dev^{tree} + origin/main^{tree} + comparación igualdad)"

# Assert 2 · Variable unificada SQUASH_DETECTED declarada + seteada + mensaje.
grep -q "^SQUASH_DETECTED=false" "$SCRIPT" \
    || fail "Variable unificada rota · falta declaración 'SQUASH_DETECTED=false' al inicio del script"
grep -q "SQUASH_DETECTED=true" "$SCRIPT" \
    || fail "Variable unificada rota · falta asignación 'SQUASH_DETECTED=true' (post tree-comparison match)"
grep -q "Squash merge detectado" "$SCRIPT" \
    || fail "Mensaje informativo del happy path roto · falta 'Squash merge detectado' en el script"
ok "Variable unificada SQUASH_DETECTED presente (default false + asignación true + mensaje informativo)"

# Assert 3 · Guard 2.6.b (DT-NNN) consume SQUASH_DETECTED + mantiene ABORT + paths de rescate.
# shellcheck disable=SC2016
grep -qF '[ "$SQUASH_DETECTED" = false ] && git rev-parse --verify dev' "$SCRIPT" \
    || fail "Guard 2.6.b roto · falta pre-condición '[ \"\$SQUASH_DETECTED\" = false ]' + 'git rev-parse --verify dev'"
grep -q 'local_ahead_main=' "$SCRIPT" \
    || fail "Guard 2.6.b roto · falta variable 'local_ahead_main' en el script"
grep -q "ABORT: dev local tiene" "$SCRIPT" \
    || fail "Guard 2.6.b roto · falta mensaje 'ABORT: dev local tiene' en el script"
grep -q "Pusheá a un PR nuevo" "$SCRIPT" \
    || fail "Guard 2.6.b roto · falta path de rescate 'Pusheá a un PR nuevo' en el script"
grep -q "respaldá a una branch local" "$SCRIPT" \
    || fail "Guard 2.6.b roto · falta path de rescate 'respaldá a una branch local' en el script"
ok "Guard 2.6.b (DT-NNN) intacto · consume SQUASH_DETECTED + ABORT + 2 paths de rescate"

# Assert 4 · Guard sección 4 (check estándar) consume SQUASH_DETECTED + mantiene ABORT.
# shellcheck disable=SC2016
grep -qF '[ "$SQUASH_DETECTED" = false ] && [ "$ahead_main" -gt 0 ]' "$SCRIPT" \
    || fail "Guard sección 4 roto · falta pre-condición '[ \"\$SQUASH_DETECTED\" = false ] && [ \"\$ahead_main\" -gt 0 ]'"
grep -q "ABORT: origin/dev tiene" "$SCRIPT" \
    || fail "Guard sección 4 roto · falta mensaje 'ABORT: origin/dev tiene' en el script"
ok "Guard sección 4 (check estándar) intacto · consume SQUASH_DETECTED + ABORT preservado"

echo
ok "Detección unificada de squash merge del script cumple los 4 invariantes mecánicos · cero degeneración detectada"
