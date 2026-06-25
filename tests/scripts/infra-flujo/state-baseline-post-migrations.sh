#!/usr/bin/env bash
# =====================================================================
# state-baseline-post-migrations.sh · Snapshot multi-catálogo Postgres
# =====================================================================
# ⚙️ STACK ADAPTATION BANNER
# Este smoke asume stack Postgres + Supabase (cliente `psql` + catálogos
# `pg_proc` · `pg_class` · `pg_policies` · `pg_trigger`). Forma par
# funcional inseparable con `state-assertion.sh` (productor↔consumidor):
# este script crea el baseline en /tmp · `state-assertion.sh` lo consume
# pre-jobs e2e + sql y aborta si detecta drift.
# Si tu proyecto NO usa BD relacional al boot del template, este smoke
# SKIPea cleanly cuando TEST_DATABASE_URL no está exportada.
#
# Por qué existe: un spec que muta schema (DROP función · ALTER policy ·
# CREATE trigger) y no restaura genera cascada de fail downstream en
# jobs e2e / sql sin pista de root cause hasta que se diff-ea manualmente
# pg_proc vs migration files. Tiempo perdido típico: minutos a horas.
#
# Este smoke captura el state canónico de la TEST DB POST-migrations (4
# catalogs) a un archivo efímero en /tmp (gitignored · regenera natural
# cada run · cero estado persistente entre sesiones).
#
# El smoke hermano `state-assertion.sh` consume este baseline pre-Job
# e2e + pre-Job sql · diff por categoría · ABORT con mensaje específico
# de faltantes cuando state drifteó entre jobs.
#
# Severidad: 🔴 ABORT en jobs `e2e`/`sql` (CI remoto) · invocación inline
# post-job migrations en `scripts/local-ci.sh` (CI local · single proceso
# comparte /tmp entre jobs).
#
# RUN_ID:
#   - LOCAL: auto-generado si no está exportado (paridad efímero por run).
#   - REMOTO: `$GITHUB_RUN_ID` provisto por GitHub Actions.
#
# Uso:
#   bash tests/scripts/infra-flujo/state-baseline-post-migrations.sh
#   RUN_ID=foo bash tests/scripts/infra-flujo/state-baseline-post-migrations.sh
#
# Exit codes:
#   0  baseline file creado OK · O skip cleanly (TEST DB no configurada
#      al boot del template)
#   1  pg queries fallan o ambiente roto
# =====================================================================

set -euo pipefail

fail() { echo "❌ state-baseline: $1" >&2; exit 1; }
ok()   { echo "✓ state-baseline: $1"; }
skip() { echo "⚠ state-baseline: $1"; exit 0; }

# ---------------------------------------------------------------------
# Skip-safe al boot del template · cero falso positivo
# Adopter al boot aún no exportó TEST_DATABASE_URL · skipea cleanly
# hasta que configure su TEST DB.
# ---------------------------------------------------------------------
if [[ -z "${TEST_DATABASE_URL:-}" ]]; then
    skip "TEST_DATABASE_URL no exportada · SKIP (adopter configura cuando sume TEST DB · paridad regla #12 simplicity-first)"
fi

command -v psql >/dev/null 2>&1 || fail "psql no en PATH"

# RUN_ID auto-genera si no está set (LOCAL paridad GITHUB_RUN_ID)
RUN_ID="${RUN_ID:-local-$(date +%s)-$$}"
export RUN_ID

BASELINE_FILE="/tmp/ci-schema-baseline-${RUN_ID}.txt"

# ---------------------------------------------------------------------
# 4 queries · 1 sección por catalog · cero hardcode (datos vienen del
# estado real de la DB · regenera cada run).
# Adopter con schema fuera de `public` (ej: multi-schema) ajusta los
# WHERE clauses según su layout.
# ---------------------------------------------------------------------
{
    echo "## functions"
    psql "$TEST_DATABASE_URL" -tA -c "
        SELECT proname || '(' || pg_get_function_identity_arguments(oid) || ')'
        FROM pg_proc
        WHERE pronamespace = 'public'::regnamespace
        ORDER BY 1
    " 2>/dev/null || fail "query pg_proc falló"

    echo ""
    echo "## classes"
    psql "$TEST_DATABASE_URL" -tA -c "
        SELECT relname || ' (' || relkind::text || ')'
        FROM pg_class
        WHERE relnamespace = 'public'::regnamespace
          AND relkind IN ('r','i','S','v')
          AND relname NOT LIKE 'pg_%'
        ORDER BY 1
    " 2>/dev/null || fail "query pg_class falló"

    echo ""
    echo "## policies"
    psql "$TEST_DATABASE_URL" -tA -c "
        SELECT tablename || '.' || policyname
        FROM pg_policies
        WHERE schemaname = 'public'
        ORDER BY 1
    " 2>/dev/null || fail "query pg_policies falló"

    echo ""
    echo "## triggers"
    psql "$TEST_DATABASE_URL" -tA -c "
        SELECT c.relname || '.' || t.tgname
        FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        WHERE c.relnamespace = 'public'::regnamespace
          AND NOT t.tgisinternal
        ORDER BY 1
    " 2>/dev/null || fail "query pg_trigger falló"
} > "$BASELINE_FILE"

# Validar que las 4 secciones quedaron escritas (sanity check)
for section in functions classes policies triggers; do
    grep -q "^## $section$" "$BASELINE_FILE" || fail "sección '## $section' ausente en $BASELINE_FILE"
done

LINES_TOTAL=$(wc -l < "$BASELINE_FILE")
ok "baseline creado · $BASELINE_FILE · $LINES_TOTAL líneas · 4 secciones (functions · classes · policies · triggers)"
exit 0

# =====================================================================
# Pedigrí: sanitizado al template workflow-base 2026-05-25 desde upstream
# privado (gotchas empíricos: spec que muta schema y no restaura · cascada
# de fail downstream en jobs e2e/sql sin pista de root cause). Refs
# upstream-specific reescritas como template universal Postgres+Supabase
# con banner ⚙️ stack adaptation + skip-safe IF al boot para cero falso
# positivo cuando TEST_DATABASE_URL no está exportada. Par funcional
# inseparable con state-assertion.sh (productor↔consumidor del baseline).
# =====================================================================
