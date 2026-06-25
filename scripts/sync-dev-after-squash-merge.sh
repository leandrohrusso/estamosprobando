#!/usr/bin/env bash
# Re-alinea `dev` con `main` después de `gh pr merge <N> --squash`.
#
# Por qué existe: el squash merge colapsa N commits del PR en 1 solo
# commit sobre main. Pero dev mantiene los N commits originales con
# distinta historia. Resultado: aunque ambas ramas tienen el mismo
# CONTENIDO, git las ve como divergentes — el siguiente merge dev → main
# produce N conflictos sobre los mismos archivos. Cada PRP que sigue
# trabajando en dev sin re-sincronizar acumula más divergencia.
#
# Detectado en proyecto upstream: N conflictos al re-mergear,
# CI dispatch quedó bloqueado por mergeable_state=dirty hasta resolver.
#
# Fix: después de cada `gh pr merge <N> --squash`, correr este script
# desde local dev. Force-resetea dev a main (history rewrite) y push.
# Safe para solo-dev workflow (el user es el único que toca dev).
#
# Memoria: .claude/memory/feedback/squash-merge-dev-divergence.md.

set -euo pipefail

red() { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }

# 1. Working tree limpio
if ! git diff-index --quiet HEAD --; then
    red "ERROR: working tree con cambios sin commit. Commiteá o hacé stash primero."
    exit 1
fi

# 2. Fetch refs
git fetch origin --prune --quiet

# 2.5. Fast-forward local main a origin/main · cero "main local behind" tras squash merge.
# Guard: NO tocar si el user está en main (working tree quedaría en estado raro).
# La rama de trabajo del flujo es `dev`, así que en práctica no se dispara el guard.
current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [ "$current_branch" != "main" ]; then
    git fetch origin main:main --quiet 2>/dev/null || true
fi

# 2.6.a. Detección unificada de squash merge happy path (refinamiento iterativo upstream ·
# firma user). Compara `dev^{tree}` con `origin/main^{tree}`: si coinciden,
# dev tiene CONTENIDO equivalente al squash commit de main (solo difieren
# en SHA/historia). Cero pérdida real al force-resetear. La variable
# SQUASH_DETECTED se consume en DOS guards downstream que tienen el mismo
# FP estructural si se evalúan sin tree-comparison previo:
#   - Guard 2.6.b (defense-in-depth DT-NNN · `origin/main..dev` local).
#   - Guard sección 4 (chequeo `origin/main..origin/dev` pre-DT-NNN).
# Ambos cuentan commits "ahead" por historia · ambos abortan FP en happy
# path squash sin esta detección común.
SQUASH_DETECTED=false
if git rev-parse --verify dev >/dev/null 2>&1 && git rev-parse --verify origin/main >/dev/null 2>&1; then
    dev_tree="$(git rev-parse "dev^{tree}" 2>/dev/null || echo '')"
    main_tree="$(git rev-parse "origin/main^{tree}" 2>/dev/null || echo '')"
    if [ -n "$dev_tree" ] && [ "$dev_tree" = "$main_tree" ]; then
        SQUASH_DETECTED=true
        yellow "Squash merge detectado · dev^{tree} == origin/main^{tree} · cero pérdida real al re-sincronizar (skipea guards 2.6.b + sección 4)."
    fi
fi

# 2.6.b. Defense-in-depth · guard anti-pérdida de commits locales ahead-of-main.
# El check de la sección 4 compara `origin/main..origin/dev` (remoto vs remoto)
# pero NO atrapa commits locales que el hook post-commit ya pusheó solo a
# `origin/dev-backup`. Si los hay y reseteamos dev a main, el force-push final
# a dev-backup borra esos commits del único remoto que los preservaba.
#
# Detectado en sesión upstream (/auditar-dt · commits del análisis casi perdidos). DT-NNN.
# Memoria: .claude/memory/feedback/sync-dev-after-squash-destroys-unpushed-local-commits.md
#
# Skipeamos este guard si SQUASH_DETECTED=true (refinamiento iterativo upstream · happy path
# squash con contenido equivalente al squash commit · cero pérdida real).
if [ "$SQUASH_DETECTED" = false ] && git rev-parse --verify dev >/dev/null 2>&1; then
    local_ahead_main="$(git rev-list --count origin/main..dev 2>/dev/null || echo 0)"
    if [ "$local_ahead_main" -gt 0 ]; then
        red "ABORT: dev local tiene $local_ahead_main commit(s) ahead de origin/main que NO están en main ni en ningún PR mergeado."
        red ""
        red "Esos commits viven solo en local + origin/dev-backup. El sync los borra"
        red "del backup remoto (force-push dev:dev-backup = main). Si WSL2 muere ahora,"
        red "trabajo perdido sin rescate."
        red ""
        red "Rescate antes de continuar:"
        red "  1. Pusheá a un PR nuevo:  git push origin dev && gh pr create --base main"
        red "  2. O respaldá a una branch local:  git branch backup-pre-sync-\$(date +%s) dev"
        red ""
        red "Después de rescatar los commits, re-corré este script."
        exit 1
    fi
fi

# 3. Si origin/dev no existe (ej: gh pr merge --delete-branch la eliminó), recrearla.
if ! git rev-parse --verify origin/dev >/dev/null 2>&1; then
    yellow "origin/dev no existe (probablemente eliminada por --delete-branch). Recreando desde origin/main..."
    git checkout dev 2>/dev/null || git checkout -b dev origin/main
    git reset --hard origin/main
    git push origin dev
    git push origin dev:dev-backup --force-with-lease
    green "✓ origin/dev y origin/dev-backup recreadas desde origin/main. Listo."
    exit 0
fi

# 4. Diff dev vs main
local_main="$(git rev-parse origin/main)"
local_dev="$(git rev-parse origin/dev)"

if [ "$local_main" = "$local_dev" ]; then
    green "Ya en sync (origin/dev == origin/main). Nada que hacer."
    exit 0
fi

ahead_main="$(git rev-list --count origin/main..origin/dev)"
behind_main="$(git rev-list --count origin/dev..origin/main)"

yellow "origin/dev: $ahead_main commit(s) por delante de origin/main."
yellow "origin/main: $behind_main commit(s) por delante de origin/dev."
echo

# 4. Si dev tiene commits que main NO tiene, abortar — hay trabajo no mergeado.
# Skipeamos si SQUASH_DETECTED=true (refinamiento iterativo upstream · los commits "ahead"
# por historia tienen contenido equivalente al squash commit en main · cero
# pérdida real al force-resetear).
if [ "$SQUASH_DETECTED" = false ] && [ "$ahead_main" -gt 0 ]; then
    red "ABORT: origin/dev tiene $ahead_main commit(s) que NO están en origin/main."
    red "       Esos commits se perderían si reseteamos dev a main."
    red ""
    red "Si querés continuar igual (sabés que perdés esos commits), corré:"
    red "  git checkout dev && git reset --hard origin/main && git push origin dev --force-with-lease"
    exit 1
fi

# 5. Confirmar
yellow "El script va a:"
yellow "  1. Resetear dev local a origin/main."
yellow "  2. Force-push dev a origin (--force-with-lease)."
echo

# Detección TTY: en sesiones autónomas (Claude Code auto-mode · CI runners · pipes)
# `read -rp` bloquea indefinido esperando input que nunca llega. Auto-yes en ese caso.
# Workaround user-facing `echo "y" | bash ...` sigue funcionando porque pipe también
# retorna false en `[ -t 0 ]`.
if [ -t 0 ]; then
    read -rp "Continuar? [y/N] " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        red "Cancelado."
        exit 1
    fi
else
    yellow "Contexto non-interactive detectado (no TTY) · auto-yes."
fi

# 6. Ejecutar
git checkout dev
git reset --hard origin/main
git push origin dev --force-with-lease

# 7. Re-alinear origin/dev-backup también (regla operativa firme · backup automático
# debe seguir el linaje de dev). Sin esto, post-squash dev-backup queda en linaje
# muerto y el hook .husky/post-commit falla silenciosamente con non-fast-forward
# por días hasta que alguien lo nota. Memoria persistente:
# .claude/memory/feedback/squash-merge-dev-divergence.md (sección dev-backup).
yellow "Re-alineando origin/dev-backup también..."
git push origin dev:dev-backup --force-with-lease

green "✓ dev y origin/dev-backup re-alineados a main. Listo para arrancar próximo PRP sin divergencia heredada."
