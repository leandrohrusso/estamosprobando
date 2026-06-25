#!/usr/bin/env bash
# =====================================================================
# Invariante mecánico: scripts/sync-dev-after-squash-merge.sh preserva
# guard anti-pérdida de commits locales ahead-of-main
# =====================================================================
# Problema que el guard previene:
#
# Si `dev` local tiene commits que NO están en `origin/main` (típico
# escenario: hook post-commit auto-pushea backup a `origin/dev-backup`
# pero el commit no llegó al PR), el force-reset `dev → origin/main`
# del script de sync los destruye silenciosamente. El chequeo
# `origin/main..origin/dev` (remoto vs remoto) NO atrapa el caso
# porque está vacío post-squash; solo `origin/main..dev` (LOCAL ref)
# expone los commits en riesgo.
#
# Fix del script: agrega guard que ABORTA si
# `git rev-list --count origin/main..dev > 0`, ofreciendo path de
# rescate al user (backup-pre-sync branch + gh pr create con los
# commits perdidos · paridad con --force-with-lease).
#
# Este smoke defiende que el guard NO desaparezca silenciosamente en
# refactors futuros del script. Si alguien lo elimina por inercia, CI
# rompe inmediato en el job `lint` (severidad ABORT).
#
# Severidad: 🔴 ABORT en job `lint`.
#
# Memoria fuente:
#   .claude/memory/feedback/sync-dev-after-squash-destroys-unpushed-local-commits.md
#
# Pedigrí: detectado en proyecto upstream post-incidente
# real · commits casi se perdieron. Codificado como smoke universal
# del template porque el invariante aplica a cualquier proyecto que
# use `scripts/sync-dev-after-squash-merge.sh`.
#
# Uso:
#   bash tests/scripts/infra-flujo/sync-dev-guards-local-commits-ahead.sh
#
# Exit 0 si guard OK · exit 1 si guard ausente o degenerado.
# =====================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/sync-dev-after-squash-merge.sh"

fail() { echo "❌ $1" >&2; exit 1; }
ok()   { echo "✓ $1"; }

[[ -f "$SCRIPT" ]] || fail "script no encontrado: $SCRIPT"

# ---------------------------------------------------------------------
# 1. Guard verifica LOCAL dev ahead-of-origin/main (no solo remoto vs remoto).
#    El patrón canónico es `git rev-list --count origin/main..dev`
#    (dev sin prefijo origin/ · LOCAL ref).
# ---------------------------------------------------------------------
if ! grep -qE "rev-list --count origin/main\.\.dev\b" "$SCRIPT"; then
    fail "Guard ausente: el script NO verifica \`origin/main..dev\` (local dev) · solo el chequeo remoto vs remoto NO atrapa commits locales pusheados a origin/dev-backup. Memoria: feedback/sync-dev-after-squash-destroys-unpushed-local-commits.md"
fi
ok "Guard presente · script verifica \`origin/main..dev\` (local dev)"

# ---------------------------------------------------------------------
# 2. El guard tiene path de ABORT (exit 1) cuando detecta commits locales.
#    Sin exit 1, el guard es decorativo y el sync sigue de todos modos.
# ---------------------------------------------------------------------
# Extraer las ~30 líneas alrededor del guard local + verificar que
# contiene `exit 1` y mensaje de rescate accionable.
guard_block="$(awk '/rev-list --count origin\/main\.\.dev/,/^fi$/' "$SCRIPT")"
if ! echo "$guard_block" | grep -qE "\bexit 1\b"; then
    fail "Guard degenerado: detecta commits locales pero NO aborta (\`exit 1\` ausente en el bloque del guard)"
fi
ok "Guard aborta con \`exit 1\` · cero degeneración"

# ---------------------------------------------------------------------
# 3. El mensaje de rescate ofrece path accionable al user
#    (push a PR nuevo · backup a branch local). Sin esto, el ABORT deja
#    al user sin pista de qué hacer.
# ---------------------------------------------------------------------
if ! echo "$guard_block" | grep -qE "backup-pre-sync"; then
    fail "Guard sin path de rescate visible: falta sugerencia \`backup-pre-sync\` en el mensaje de ABORT"
fi
ok "Guard ofrece path de rescate accionable (backup-pre-sync · gh pr create)"

echo
echo "✅ Guard verificado · scripts/sync-dev-after-squash-merge.sh defiende contra pérdida de commits locales ahead-of-main."
exit 0
