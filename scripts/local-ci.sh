#!/usr/bin/env bash
# =====================================================================
# local-ci.sh · Reproduce los jobs del CI remoto en local
# =====================================================================
# Política "1 push = 1 PR = 1 CI" (regla #27 .claude/rules/push-and-ci-policy.md):
# este script es el GATE LOCAL del paso 6 del flujo Modo C, justo antes
# del push único a `origin/dev`. Pasa al primer intento porque las
# validaciones se distribuyen durante pasos 3-5 (typecheck+build por fase,
# suite-spec-de-la-fase, etc.).
#
# Si rompe en paso 6 · ALTERNATIVA PRAGMÁTICA:
#   1. Fix local del bug detectado.
#   2. Re-correr SOLO el job que rompió aislado (--only=<job>).
#   3. Iterar hasta verde.
#   4. Re-correr el RUN COMPLETO una última vez (sin args) como red de
#      seguridad final.
#   5. Documentar el gap del flujo como memoria nueva en
#      .claude/memory/feedback/<gotcha>.md.
#
# Uso:
#   bash scripts/local-ci.sh                      # todos los jobs
#   bash scripts/local-ci.sh --only=typecheck     # solo typecheck
#   bash scripts/local-ci.sh --exclude=e2e        # todos menos e2e
#
# También accesible vía npm:
#   npm run ci:local
#   npm run ci:local -- --only=lint
#
# ─────────────────────────────────────────────────────────────────────
# INVARIANTE DE PARIDAD CON .github/workflows/ci.yml
# ─────────────────────────────────────────────────────────────────────
# El orden de ALL_JOBS abajo debe matchear el orden de jobs en
# .github/workflows/ci.yml (con sus `needs:` correspondientes). Si cambia
# el orden o se agregan jobs, actualizar AMBOS archivos en el mismo commit.
# El smoke `tests/scripts/infra-flujo/<job-order-parity>.sh` (si lo
# agregás) verifica esta invariante.
# =====================================================================

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────
# Definición de jobs · template universal
# Adaptar el array ALL_JOBS al stack del proyecto. Los 6 jobs canónicos
# del pack workflow-base son:
#   - typecheck      → tsc --noEmit (o equivalente)
#   - lint           → ESLint/Prettier/etc + smokes infra-flujo
#   - build          → next build (o equivalente)
#   - unit           → vitest/jest run (si aplica)
#   - e2e            → playwright test (si aplica)
#   - sql            → tests SQL contra TEST DB (si stack tiene BD)
# ─────────────────────────────────────────────────────────────────────

ALL_JOBS=(typecheck lint build unit e2e sql)

ONLY=""
EXCLUDE=""

for arg in "$@"; do
  case $arg in
    --only=*) ONLY="${arg#--only=}" ;;
    --exclude=*) EXCLUDE="${arg#--exclude=}" ;;
    *)
      echo "❌ Unknown arg: $arg"
      echo "Uso: bash scripts/local-ci.sh [--only=<job>] [--exclude=<job>]"
      echo "Jobs disponibles: ${ALL_JOBS[*]}"
      exit 1
      ;;
  esac
done

# ─────────────────────────────────────────────────────────────────────
# Pre-condiciones — verificar setup local antes de empezar
# ─────────────────────────────────────────────────────────────────────
# TODO · adaptar al stack del proyecto. Ejemplos:
#   - .env.local debe apuntar a TEST DB (no PROD).
#   - tests/manual/.credentials.local.json debe matchear seed de TEST DB.
#   - node_modules instalado (npm ci ya corrió).
# ─────────────────────────────────────────────────────────────────────

echo "▶ Verificando pre-condiciones..."

# Preflight environment · stack Postgres + Supabase
# Skipea cleanly si TEST_DATABASE_URL no está exportada (cero falso positivo
# al boot del template). Si el stack no es Postgres+Supabase, comentar o
# reemplazar por el preflight del propio stack.
bash tests/scripts/infra-flujo/preflight-environment.sh

# TODO: agregar checks adicionales del proyecto · ejemplo:
# if [ -f .env.local ]; then
#   if ! grep -q "TEST_DB_PROJECT_REF_PLACEHOLDER" .env.local; then
#     echo "⚠️  .env.local NO apunta a TEST DB. Local CI corre contra TEST."
#     exit 1
#   fi
# fi

echo "✓ Pre-condiciones OK"
echo ""

# ─────────────────────────────────────────────────────────────────────
# Helper: should_run · decide si un job entra al run actual
# ─────────────────────────────────────────────────────────────────────

should_run() {
  local job="$1"
  if [[ -n "$ONLY" && "$job" != "$ONLY" ]]; then return 1; fi
  if [[ -n "$EXCLUDE" && "$job" == "$EXCLUDE" ]]; then return 1; fi
  return 0
}

# ─────────────────────────────────────────────────────────────────────
# Runner: run_job · ejecuta 1 job con header + check de exit
# ─────────────────────────────────────────────────────────────────────

run_job() {
  local job="$1"
  shift
  echo "▶▶▶ Job: $job"
  echo "    Comando: $*"
  if "$@"; then
    echo "✓ $job VERDE"
    echo ""
  else
    echo "❌ $job FAIL · abortando"
    exit 1
  fi
}

# ─────────────────────────────────────────────────────────────────────
# Jobs · adaptar comandos al stack del proyecto
# ─────────────────────────────────────────────────────────────────────

if should_run typecheck; then
  # TODO: reemplazar con comando de typecheck del proyecto · ej: tsc --noEmit
  run_job typecheck npm run typecheck
fi

if should_run lint; then
  # TODO: reemplazar con comando de lint del proyecto · ej: eslint .
  run_job lint npm run lint
  # Smokes infra-flujo · invariantes firmes (ABORT en fallo) · paridad con
  # job `lint` de .github/workflows/ci.yml (regla #27 push-and-ci-policy +
  # regla #34 husky-hooks-smoke-tests · invariante de paridad local-remoto).
  run_job "lint · smoke rules-shape-p8" bash tests/scripts/infra-flujo/rules-shape-p8.sh
  run_job "lint · smoke skip-ci-not-in-pr-head" bash tests/scripts/infra-flujo/skip-ci-not-in-pr-head.sh
  run_job "lint · smoke agents-domain-tight-have-precondition" bash tests/scripts/infra-flujo/agents-domain-tight-have-precondition.sh
  run_job "lint · smoke job-order-parity" bash tests/scripts/infra-flujo/job-order-parity.sh
  run_job "lint · smoke sync-dev-pre-check-tree-comparison" bash tests/scripts/infra-flujo/sync-dev-pre-check-tree-comparison.sh
  run_job "lint · smoke sync-dev-guards-local-commits-ahead" bash tests/scripts/infra-flujo/sync-dev-guards-local-commits-ahead.sh
  run_job "lint · smoke fresh-install-canonical-state" bash tests/scripts/infra-flujo/fresh-install-canonical-state.sh
  run_job "lint · smoke preflight-environment" bash tests/scripts/infra-flujo/preflight-environment.sh
fi

if should_run build; then
  # TODO: reemplazar con comando de build del proyecto · ej: next build
  run_job build npm run build
fi

if should_run unit; then
  # TODO: reemplazar con comando de unit tests · ej: vitest run
  # Si el stack no tiene unit tests separados de e2e, sumar EXCLUDE+="unit"
  run_job unit npm run test:unit
fi

# Crear baseline de state Postgres ANTES del primer job que pueda mutar schema
# (e2e o sql). Single invocación · single proceso comparte /tmp entre jobs.
# Skipea cleanly si TEST_DATABASE_URL no está exportada (cero falso positivo
# al boot del template). Si tu stack no es Postgres+Supabase, comentar.
if should_run e2e || should_run sql; then
  bash tests/scripts/infra-flujo/state-baseline-post-migrations.sh
fi

if should_run e2e; then
  # Assertion pre-e2e · detecta drift de state vs baseline (spec previo que
  # dropeó/alteró schema y no restauró). ABORT con mensaje específico por
  # categoría · evita cascada de minutos de e2e fail sin pista de root cause.
  bash tests/scripts/infra-flujo/state-assertion.sh
  # TODO: reemplazar con comando de E2E · ej: playwright test
  # Pre-condición: dev server + TEST DB seedeada (ver doc del proyecto).
  run_job e2e npm run test:e2e
fi

# TODO: reemplazar con comando de tests SQL contra TEST DB del proyecto.
#
# Si el stack NO tiene BD, eliminar el bloque sql abajo Y remover "sql" del
# array ALL_JOBS de la línea 53. Ejemplo de stack sin BD:
#
#   ALL_JOBS=(typecheck lint build unit e2e)   # sin "sql"
#   # ...sin el bloque `if should_run sql; then ... fi` abajo.
#
if should_run sql; then
  # Assertion pre-sql · detecta drift de state vs baseline (spec previo que
  # dropeó/alteró schema y no restauró). Mismo baseline consumido por ambos
  # asserts gracias a /tmp compartido entre jobs en local.
  bash tests/scripts/infra-flujo/state-assertion.sh
  run_job sql bash scripts/run-sql-tests.sh
fi

echo ""
echo "✅ Local CI VERDE · listo para push (gate paso 6 cumplido)"
