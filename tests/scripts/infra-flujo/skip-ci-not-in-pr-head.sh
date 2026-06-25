#!/usr/bin/env bash
# =====================================================================
# PRP-NNN · invariante mecánico: [skip ci] no en HEAD del PR
# =====================================================================
# El último commit del PR (HEAD) NO puede tener `[skip ci]` (ni alias)
# en el subject. Si lo tiene, GitHub Actions skipea TODOS los workflows
# para `pull_request: opened/synchronize/ready_for_review` y la política
# firme "1 CI por PRP garantizado" se rompe SILENCIOSAMENTE.
#
# Memoria fuente:
#   .claude/memory/feedback/skip-ci-blocks-pr-head.md
#
# Caso histórico: PR #N (PRP-NNN) con subject de HEAD
# → PR abierto OPEN no-draft pero CI nunca disparó · checks rollup solo
# mostraron Vercel · merge pudo ejecutarse sin cobertura CI.
#
# Aliases que también skipean (mismo efecto en HEAD):
#   [skip ci] · [ci skip] · [no ci] · [skip actions] · [actions skip]
#   ***NO_CI*** (deprecated pero soportado por GH)
#
# Modo de operación:
#   - Local (sin env): inspecciona `git log -1 --format=%s HEAD`.
#   - CI (event pull_request): inspecciona el subject del head SHA del PR
#     (`PR_HEAD_SHA` env var inyectada por workflow). Si la SHA no está en
#     el clon local (caso default fetch-depth=1 con merge-commit), fetch
#     explícito antes de leer.
#
# Uso:
#   bash tests/scripts/infra-flujo/skip-ci-not-in-pr-head.sh
#
# CI: el job `lint` lo invoca (severidad 🔴 ABORT · regla operacional
# firme violada = regression del flujo).
#
# Exit 0 si invariante OK · exit 1 si rompe.
# =====================================================================

set -euo pipefail

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
RESET=$'\033[0m'

fail() { echo "${RED}❌ $1${RESET}" >&2; exit 1; }
ok()   { echo "${GREEN}✓ $1${RESET}"; }

# ─────────────────────────────────────────────────────────────────────
# 1. Resolver SHA target (HEAD local o PR head en CI)
# ─────────────────────────────────────────────────────────────────────

TARGET_SHA="${PR_HEAD_SHA:-}"

if [[ -n "$TARGET_SHA" ]]; then
  # Modo CI · GitHub Actions inyecta github.event.pull_request.head.sha.
  # Default fetch-depth=1 puede no incluir la SHA (clona solo merge commit).
  if ! git cat-file -e "${TARGET_SHA}^{commit}" 2>/dev/null; then
    echo "${YELLOW}ℹ${RESET}  PR_HEAD_SHA=${TARGET_SHA:0:7} no está en el clon local · fetch explícito"
    git fetch --quiet --depth=1 origin "$TARGET_SHA" 2>/dev/null || \
      fail "No pude fetch del PR head SHA ${TARGET_SHA:0:7} · revisar permisos checkout"
  fi
  SUBJECT=$(git log -1 --format=%s "$TARGET_SHA")
  CONTEXT="PR head SHA ${TARGET_SHA:0:7}"
else
  # Modo local · HEAD del branch actual.
  SUBJECT=$(git log -1 --format=%s HEAD)
  CONTEXT="HEAD local"
fi

# ─────────────────────────────────────────────────────────────────────
# 2. Pattern match · markers de skip CI
# ─────────────────────────────────────────────────────────────────────
# Lista exhaustiva según docs.github.com/en/actions/managing-workflow-runs/skipping-workflow-runs.
# Pattern case-insensitive con grep -i para atrapar variantes ([Skip CI], [SKIP CI], etc).
# `***NO_CI***` literal (sin variantes) según doc histórica.
# Una sola alternation regex evita 6 sub-shells redundantes (1 pipe en vez de 6).

SKIP_REGEX='\[skip ci\]|\[ci skip\]|\[no ci\]|\[skip actions\]|\[actions skip\]|\*\*\*NO_CI\*\*\*'

if MATCHED=$(echo "$SUBJECT" | grep -oiE "$SKIP_REGEX"); then
  echo
  fail "Subject del ${CONTEXT} contiene marker '$MATCHED' · GitHub Actions va a skipear el PR run.
   Subject: \"$SUBJECT\"
   Fix: agregá un commit nuevo SIN el marker · el HEAD final del PR NUNCA lleva [skip ci].
   Memoria: .claude/memory/feedback/skip-ci-blocks-pr-head.md"
fi

ok "${CONTEXT} sin markers de skip CI · subject: \"${SUBJECT}\""
