#!/usr/bin/env bash
# =====================================================================
# state-assertion.sh · Diff baseline vs current state (4 catalogs)
# =====================================================================
# ⚙️ STACK ADAPTATION BANNER
# Este smoke asume stack Postgres + Supabase (cliente `psql` + catálogos
# `pg_proc` · `pg_class` · `pg_policies` · `pg_trigger`). Forma par
# funcional inseparable con `state-baseline-post-migrations.sh` (consumidor↔
# productor): el baseline lo crea ese script en /tmp · este lo consume
# pre-jobs e2e + sql y aborta si detecta drift.
# Si tu proyecto NO usa BD relacional al boot del template, este smoke
# SKIPea cleanly cuando TEST_DATABASE_URL no está exportada O cuando el
# baseline file no existe (cero hard-fail si el productor aún no corrió).
#
# Por qué existe: drift silencioso de state entre jobs (un spec dropeó
# una función o policy y no restauró) genera cascada de fail downstream
# sin pista de root cause. Este smoke atrapa el drift ANTES de los jobs
# costosos (e2e típicamente minutos · sql segundos).
#
# Re-queries las mismas 4 catalogs que el productor · diff por categoría
# usando `comm -23` (líneas en baseline pero NO en current = "Missing")
# · ABORT con mensaje específico de faltantes cuando state drifteó.
#
# Severidad: 🔴 ABORT en jobs `e2e`+`sql` (CI remoto) · invocación inline
# pre-Job e2e + pre-Job sql en `scripts/local-ci.sh` (CI local).
#
# Consolidación: 1 smoke invocado 2× (pre-e2e + pre-sql) · misma lógica
# funcional · cero duplicación de archivo (paridad con
# `husky-hooks-not-degenerated.sh` que consolida 3 hooks).
#
# RUN_ID:
#   - LOCAL: heredado del `state-baseline-post-migrations.sh` previo
#     (mismo proceso · single shell).
#   - REMOTO: `$GITHUB_RUN_ID` provisto por GitHub Actions.
#
# Uso:
#   bash tests/scripts/infra-flujo/state-assertion.sh
#   RUN_ID=foo bash tests/scripts/infra-flujo/state-assertion.sh
#
# Exit codes:
#   0  state matches baseline · O skip cleanly (TEST DB no configurada O
#      baseline file no existe al boot del template)
#   1  drift detectado · mensaje específico de faltantes por categoría
# =====================================================================

set -euo pipefail

fail() { echo "❌ state-assertion: $1" >&2; exit 1; }
ok()   { echo "✓ state-assertion: $1"; }
skip() { echo "⚠ state-assertion: $1"; exit 0; }

# ---------------------------------------------------------------------
# Skip-safe al boot del template · cero falso positivo
# Adopter al boot aún no exportó TEST_DATABASE_URL · skipea cleanly.
# ---------------------------------------------------------------------
if [[ -z "${TEST_DATABASE_URL:-}" ]]; then
    skip "TEST_DATABASE_URL no exportada · SKIP (adopter configura cuando sume TEST DB · paridad regla #12 simplicity-first)"
fi

command -v psql >/dev/null 2>&1 || fail "psql no en PATH"

RUN_ID="${RUN_ID:-}"
if [[ -z "$RUN_ID" ]]; then
    skip "RUN_ID no exportada · SKIP (correr primero state-baseline-post-migrations.sh que la auto-genera · cero hard-fail si productor no corrió)"
fi

BASELINE_FILE="/tmp/ci-schema-baseline-${RUN_ID}.txt"
if [[ ! -f "$BASELINE_FILE" ]]; then
    skip "baseline file no encontrado: $BASELINE_FILE · SKIP (correr primero state-baseline-post-migrations.sh con mismo RUN_ID)"
fi

# ---------------------------------------------------------------------
# Helper · extraer sección del baseline file
# ---------------------------------------------------------------------
extract_section() {
    local section="$1"
    awk -v sec="## $section" '
        $0 == sec { in_section = 1; next }
        /^## / { in_section = 0 }
        in_section && NF > 0 { print }
    ' "$BASELINE_FILE"
}

# ---------------------------------------------------------------------
# Helper · diff baseline section vs current state · retorna líneas
# missing (presentes en baseline pero ausentes en current state)
# ---------------------------------------------------------------------
diff_section() {
    local section="$1"
    local current_query="$2"
    local baseline_tmp current_tmp
    baseline_tmp="$(mktemp)"
    current_tmp="$(mktemp)"
    # cleanup en cualquier exit del subshell (defense-in-depth /tmp)
    trap 'rm -f "$baseline_tmp" "$current_tmp"' RETURN

    extract_section "$section" | sort -u > "$baseline_tmp"

    psql "$TEST_DATABASE_URL" -tA -c "$current_query" 2>/dev/null \
        | grep -v '^$' \
        | sort -u \
        > "$current_tmp" \
        || { rm -f "$baseline_tmp" "$current_tmp"; fail "query $section actual falló"; }

    # líneas en baseline pero NO en current → drift detectado
    comm -23 "$baseline_tmp" "$current_tmp"

    rm -f "$baseline_tmp" "$current_tmp"
}

# ---------------------------------------------------------------------
# Diff por categoría · acumular missings con prefijo por sección
# Adopter con schema fuera de `public` (ej: multi-schema) ajusta los
# WHERE clauses según su layout (consistente con el productor).
# ---------------------------------------------------------------------
MISSING_FUNCTIONS="$(diff_section "functions" "
    SELECT proname || '(' || pg_get_function_identity_arguments(oid) || ')'
    FROM pg_proc
    WHERE pronamespace = 'public'::regnamespace
    ORDER BY 1
")"

MISSING_CLASSES="$(diff_section "classes" "
    SELECT relname || ' (' || relkind::text || ')'
    FROM pg_class
    WHERE relnamespace = 'public'::regnamespace
      AND relkind IN ('r','i','S','v')
      AND relname NOT LIKE 'pg_%'
    ORDER BY 1
")"

MISSING_POLICIES="$(diff_section "policies" "
    SELECT tablename || '.' || policyname
    FROM pg_policies
    WHERE schemaname = 'public'
    ORDER BY 1
")"

MISSING_TRIGGERS="$(diff_section "triggers" "
    SELECT c.relname || '.' || t.tgname
    FROM pg_trigger t
    JOIN pg_class c ON t.tgrelid = c.oid
    WHERE c.relnamespace = 'public'::regnamespace
      AND NOT t.tgisinternal
    ORDER BY 1
")"

# ---------------------------------------------------------------------
# Reporte · ABORT con mensaje específico por categoría si drift detectado
# ---------------------------------------------------------------------
DRIFT_DETECTED=0
DRIFT_MSG=""

if [[ -n "$MISSING_FUNCTIONS" ]]; then
    DRIFT_DETECTED=1
    DRIFT_MSG+="
Missing functions:
$(echo "$MISSING_FUNCTIONS" | sed 's/^/  - /')"
fi

if [[ -n "$MISSING_CLASSES" ]]; then
    DRIFT_DETECTED=1
    DRIFT_MSG+="
Missing classes (tables/indexes/sequences/views):
$(echo "$MISSING_CLASSES" | sed 's/^/  - /')"
fi

if [[ -n "$MISSING_POLICIES" ]]; then
    DRIFT_DETECTED=1
    DRIFT_MSG+="
Missing policies:
$(echo "$MISSING_POLICIES" | sed 's/^/  - /')"
fi

if [[ -n "$MISSING_TRIGGERS" ]]; then
    DRIFT_DETECTED=1
    DRIFT_MSG+="
Missing triggers:
$(echo "$MISSING_TRIGGERS" | sed 's/^/  - /')"
fi

if [[ $DRIFT_DETECTED -eq 1 ]]; then
    echo "❌ state-assertion: drift detectado vs baseline $BASELINE_FILE" >&2
    echo "$DRIFT_MSG" >&2
    echo "" >&2
    echo "Posibles causas: spec corrupted state (DROP / ALTER sin restore) · migration nueva sin aplicar · TEST DB compartida drifted entre runs." >&2
    exit 1
fi

ok "state matches baseline · 4 categorías verdes (functions · classes · policies · triggers)"
exit 0

# =====================================================================
# Pedigrí: sanitizado al template workflow-base 2026-05-25 desde upstream
# privado (gotcha empírico: spec Playwright durante e2e dropeó función y
# no restauró · cascada de minutos de e2e fail downstream sin pista).
# Refs upstream-specific reescritas como template universal Postgres+
# Supabase con banner ⚙️ stack adaptation + 3 skip-safe IF blocks al boot
# (TEST_DATABASE_URL · RUN_ID · baseline file) para cero falso positivo.
# Par funcional inseparable con state-baseline-post-migrations.sh
# (consumidor↔productor del baseline).
# =====================================================================
