#!/usr/bin/env bash
# =====================================================================
# preflight-environment.sh · Preflight ENV antes de los jobs de ci:local
# =====================================================================
# ⚙️ STACK ADAPTATION BANNER
# Este smoke asume stack Postgres + Supabase (cliente `pg_dump` + `psql`).
# Si tu cluster corre versión distinta de Postgres (Supabase soporta 15
# o 17 según el cluster), exportá EXPECTED_PG_MAJOR=N antes de invocar.
# Si tu proyecto NO usa BD relacional al boot del template, este smoke
# SKIPea cleanly cuando TEST_DATABASE_URL no está exportada (cero falso
# positivo · ABORT solo dispara cuando el adopter ya configuró la TEST DB).
#
# Por qué existe: `ci:local` rompe silenciosamente cuando (a) PATH tiene
# cliente Postgres de versión distinta a la del servidor (server-version
# mismatch en jobs de migración · cascada de varios minutos), (b)
# TEST_DATABASE_URL apunta a DB distinta a la TEST canónica o no está
# exportada, (c) pool de connections heredado del run anterior bloquea
# el job de migraciones con error opaco, (d) connections idle del mismo
# usename contienden con DROP SCHEMA al re-aplicar migraciones.
#
# Este smoke ABORTA en <5s con mensaje específico por categoría, ANTES
# de que typecheck/lint/build/migrations corran y desperdicien tiempo.
#
# Severidad: 🔴 ABORT en job `lint` (CI remoto) · invocación inline
# pre-jobs en `scripts/local-ci.sh` (CI local · sección Pre-condiciones).
#
# Env vars overrideables:
#   EXPECTED_PG_MAJOR  (default 17)   versión major del servidor Postgres
#   POOL_THRESHOLD     (default 20)   máximo de connections del current_user
#
# Uso:
#   bash tests/scripts/infra-flujo/preflight-environment.sh
#   EXPECTED_PG_MAJOR=15 bash tests/scripts/infra-flujo/preflight-environment.sh
#   POOL_THRESHOLD=30 bash tests/scripts/infra-flujo/preflight-environment.sh
#
# Exit codes:
#   0  environment OK · listo para los jobs · O skip cleanly (TEST DB
#      no configurada al boot del template)
#   1  rompe alguno de los 4 invariantes (a/b/c/d) con mensaje específico
# =====================================================================

set -euo pipefail

fail() { echo "❌ preflight: $1" >&2; exit 1; }
ok()   { echo "✓ preflight: $1"; }
skip() { echo "⚠ preflight: $1"; exit 0; }

# ---------------------------------------------------------------------
# Skip-safe al boot del template · cero falso positivo
# Adopter al boot aún no exportó TEST_DATABASE_URL · el smoke skipea
# cleanly hasta que configure su TEST DB.
# ---------------------------------------------------------------------
if [[ -z "${TEST_DATABASE_URL:-}" ]]; then
    skip "TEST_DATABASE_URL no exportada · SKIP (adopter configura cuando sume TEST DB · paridad regla #12 simplicity-first)"
fi

EXPECTED_PG_MAJOR="${EXPECTED_PG_MAJOR:-17}"
POOL_THRESHOLD="${POOL_THRESHOLD:-20}"

# ---------------------------------------------------------------------
# (0) Cleanup baselines viejos de runs anteriores
#     Evita /tmp bloat cuando el operador corre ci:local N veces sin
#     reboot. mtime +1 = más de 24h · cero impacto sobre run en curso.
# ---------------------------------------------------------------------
find /tmp -maxdepth 1 -name 'ci-schema-baseline-*' -mtime +1 -delete 2>/dev/null || true

# ---------------------------------------------------------------------
# (a) PATH + versión cliente pg_dump match con servidor
#     Postgres exige cliente major == servidor major para pg_dump · usar
#     versión distinta falla con "server version mismatch". Verificar
#     AMBOS ubicación (ruta) Y versión.
# ---------------------------------------------------------------------
if ! command -v pg_dump >/dev/null 2>&1; then
    fail "pg_dump no encontrado en PATH. Instalá postgresql-client-${EXPECTED_PG_MAJOR} o exportá PATH=/usr/lib/postgresql/${EXPECTED_PG_MAJOR}/bin:\$PATH"
fi

PG_DUMP_PATH="$(command -v pg_dump)"
PG_DUMP_VERSION="$(pg_dump --version 2>&1)"

if ! echo "$PG_DUMP_VERSION" | grep -qE " ${EXPECTED_PG_MAJOR}\."; then
    fail "pg_dump versión incorrecta: $PG_DUMP_VERSION (servidor requiere ${EXPECTED_PG_MAJOR}.x EXACTO · ajustable vía EXPECTED_PG_MAJOR=N). Path actual: $PG_DUMP_PATH. Fix: instalar postgresql-client-${EXPECTED_PG_MAJOR} de tu OS (Linux: \`/usr/lib/postgresql/${EXPECTED_PG_MAJOR}/bin/\` · macOS Homebrew: \`/opt/homebrew/opt/postgresql@${EXPECTED_PG_MAJOR}/bin/\`) y exportar su path al inicio del PATH."
fi
ok "pg_dump ${EXPECTED_PG_MAJOR}.x verificado · $PG_DUMP_PATH"

# ---------------------------------------------------------------------
# (b) TEST DB reachable
#     Sin DB reachable el resto del preflight no aplica · short-circuit
#     acá evita errores opacos downstream en jobs migrations/sql/e2e.
# ---------------------------------------------------------------------
if ! psql "$TEST_DATABASE_URL" -tA -c "SELECT 1" >/dev/null 2>&1; then
    fail "TEST_DATABASE_URL no reachable (timeout / auth / network). Verificá la cadena de conexión y que el pooler responda."
fi
ok "TEST DB reachable"

# ---------------------------------------------------------------------
# (c) Pool threshold de connections del current_user
#     POOL_THRESHOLD env override-able (default 20 · heurístico inicial
#     calibrable empíricamente). Si count > threshold → pooler contention
#     probable · ABORT antes que jobs migrations/sql/e2e fallen con error
#     opaco.
# ---------------------------------------------------------------------
CURRENT_USER_NAME="$(psql "$TEST_DATABASE_URL" -tA -c "SELECT current_user" 2>/dev/null | tr -d '[:space:]')"
[[ -n "$CURRENT_USER_NAME" ]] || fail "no se pudo extraer current_user de TEST DB"

POOL_COUNT="$(psql "$TEST_DATABASE_URL" -tA -c "SELECT count(*) FROM pg_stat_activity WHERE usename = '$CURRENT_USER_NAME'" 2>/dev/null | tr -d '[:space:]')"
[[ -n "$POOL_COUNT" ]] || fail "no se pudo contar connections de '$CURRENT_USER_NAME' en pg_stat_activity"

if [[ "$POOL_COUNT" -gt "$POOL_THRESHOLD" ]]; then
    fail "pool de connections del user '$CURRENT_USER_NAME' = $POOL_COUNT > $POOL_THRESHOLD (threshold). Pooler contention probable · esperá a que las connections se cierren o ajustá vía POOL_THRESHOLD=N bash $0"
fi
ok "pool de connections OK · $POOL_COUNT/$POOL_THRESHOLD para user '$CURRENT_USER_NAME'"

# ---------------------------------------------------------------------
# (d) Cleanup idle connections del mismo usename
#     Mata SOLO state IN ('idle','idle in transaction') · NUNCA active
#     queries · NUNCA la propia connection (pid <> pg_backend_pid()).
#     Defense-in-depth: prevenir + recuperar deadlocks por idle stale.
# ---------------------------------------------------------------------
TERMINATED="$(psql "$TEST_DATABASE_URL" -tA -c "
    SELECT count(*)
    FROM (
        SELECT pg_terminate_backend(pid)
        FROM pg_stat_activity
        WHERE usename = '$CURRENT_USER_NAME'
          AND state IN ('idle','idle in transaction')
          AND pid <> pg_backend_pid()
    ) t
" 2>/dev/null | tr -d '[:space:]')"

if [[ -n "$TERMINATED" && "$TERMINATED" -gt 0 ]]; then
    ok "cleanup idle connections · $TERMINATED stale terminadas del user '$CURRENT_USER_NAME'"
else
    ok "cleanup idle connections · 0 stale (DB limpia)"
fi

echo
echo "✅ Preflight environment OK · listo para los jobs de ci:local."
exit 0

# =====================================================================
# Pedigrí: sanitizado al template workflow-base 2026-05-25 desde upstream
# privado (4 invariantes a/b/c/d empíricamente vividos en stack Postgres
# 17 + Supabase pooler). Refs upstream-specific reescritas como template
# universal Postgres+Supabase con banner ⚙️ stack adaptation + parametri-
# zación de versión via EXPECTED_PG_MAJOR + skip-safe IF al boot para
# cero falso positivo cuando TEST_DATABASE_URL no está exportada.
# =====================================================================
