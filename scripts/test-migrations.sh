#!/usr/bin/env bash
# =====================================================================
# scripts/test-migrations.sh · Verificar idempotencia + determinismo
#   del schema BD (SoT contractual de regla #32 migrations-idempotency)
# =====================================================================
#
# Stack adaptation banner:
#   Este script asume stack Postgres/Supabase con migrations SQL planas
#   bajo db/migrations/*.sql + cliente psql + pg_dump. Si tu proyecto
#   usa otro schema manager (Prisma migrate · TypeORM migration:generate
#   · Drizzle drizzle-kit · Django migrations · Rails migrations),
#   reemplazá el cuerpo de apply_all_migrations + reset_schema +
#   dump_schema por equivalentes del stack. El approach (2× reset +
#   apply + dump diff) es universal · cambia solo la herramienta.
#
# Approach:
#   1. DROP SCHEMA public + recrear → estado vacío.
#   2. Aplicar todas las migraciones en orden lexicográfico
#      (db/migrations/*.sql).
#   3. Snapshot 1: pg_dump --schema-only.
#   4. Reset + aplicar de nuevo.
#   5. Snapshot 2.
#   6. diff snap1 snap2 · si difieren → alguna migración NO es
#      determinística (random() · now() · ON CONFLICT ordering ·
#      generación de UUIDs random sin seed · etc).
#
# Por qué este approach (NO per-migration idempotency check):
#   - Las migraciones iniciales típicamente usan CREATE TABLE sin
#     IF NOT EXISTS porque las tablas se crean una sola vez por diseño.
#     Aplicar 1 migración inicial 2× siempre falla → falso positivo.
#   - Lo que SÍ atrapa este script: drift causado por funciones
#     no-determinísticas (random · now · etc) · order-sensitivity ·
#     stage de schema sucio post-rollback parcial.
#   - Verificación a nivel del conjunto · no de archivo individual.
#
# Requiere:
#   - psql + pg_dump matching version del Postgres del adopter
#     (típicamente 14+ · Supabase corre 17.x al cierre del template).
#   - $TEST_DATABASE_URL apuntando a una BD de test efímera (NUNCA prod).
#
# Uso local:
#   export TEST_DATABASE_URL=postgres://postgres.<ref>:<pwd>@<host>:5432/postgres
#   bash scripts/test-migrations.sh
#
# Uso en CI:
#   Job dedicado en .github/workflows/ci.yml (adopter define nombre del job ·
#   típicamente `migrations` o `migrations-idempotency` · ABORT en fallo ·
#   paridad con job `lint` del flow de 6 pasos · regla #32).
#
# Cross-refs firmes:
#   - Regla #32 [migrations-idempotency.md](../.claude/rules/migrations-idempotency.md)
#     (SoT contractual · este script materializa el "verificación local
#     obligatoria al cierre de cualquier PRP que toca migrations").
#   - Regla #34 [push-and-ci-policy.md](../.claude/rules/push-and-ci-policy.md)
#     (invocado desde npm run ci:local en paso 6 antes del push único).
# =====================================================================

set -euo pipefail

# -----------------------------------------------------------------
# Pre-flight checks
# -----------------------------------------------------------------

if [ -z "${TEST_DATABASE_URL:-}" ]; then
  echo "::warning::TEST_DATABASE_URL no configurado. Skip migrations idempotency check."
  echo "Para correr localmente: export TEST_DATABASE_URL=postgres://...test..."
  exit 0
fi

if ! command -v psql &> /dev/null; then
  echo "::error::psql no instalado. Instalar postgresql-client (version matching del stack productivo)."
  exit 1
fi

if ! command -v pg_dump &> /dev/null; then
  echo "::error::pg_dump no instalado. Instalar postgresql-client (version matching del stack productivo)."
  exit 1
fi

# Verificación version pg_dump (opcional · adopter ajusta regex según stack productivo).
# Supabase 17.x → pg_dump < 17 falla con "server version mismatch".
# Adopter con Postgres 14/15/16 puede comentar este check o ajustar regex.
PG_DUMP_VERSION=$(pg_dump --version)
if ! echo "$PG_DUMP_VERSION" | grep -qE ' (14|15|16|17)\.'; then
  echo "::warning::pg_dump version inesperada: $PG_DUMP_VERSION (esperado 14.x-17.x)"
  echo "  Si tu stack productivo usa otra version, ajustá la regex en este script."
fi

# -----------------------------------------------------------------
# Setup workspace
# -----------------------------------------------------------------

MIGRATIONS_DIR="$(dirname "$0")/../db/migrations"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# Opcional · Supabase-specific · convertir transaction pooler (port 6543) →
# session pooler (port 5432) para evitar cache pg_namespace OIDs stale.
# El transaction pooler reusa backend connections con cache de pg_namespace
# OIDs. Tras DROP SCHEMA public + CREATE SCHEMA public, las conexiones
# reusadas mantienen el OID viejo de `public` y fallan determinísticamente
# en pasada 2 con `relation "public.X" does not exist`.
# El session pooler dedica un backend por psql client → no hay cache compartido.
# Adopter sin Supabase puede comentar este bloque.
if [[ "$TEST_DATABASE_URL" =~ :6543/ ]]; then
  TEST_DATABASE_URL="${TEST_DATABASE_URL/:6543\//:5432/}"
  echo "→ Supabase pooler fix: convertido a session pooler (port 5432) para evitar cache pg_namespace"
fi

echo "→ Workdir: $WORK_DIR"
echo "→ Migrations dir: $MIGRATIONS_DIR"
echo "→ pg_dump: $PG_DUMP_VERSION"

# -----------------------------------------------------------------
# Core functions
# -----------------------------------------------------------------

apply_all_migrations() {
  local pass="$1"
  echo ""
  echo "==================================================================="
  echo "Aplicando todas las migraciones (pasada $pass)"
  echo "==================================================================="

  # Guard: si no hay migrations dir o está vacío, skip (típico al boot del
  # template · cero migraciones existen hasta el primer PRP del producto).
  if [ ! -d "$MIGRATIONS_DIR" ] || ! ls "$MIGRATIONS_DIR"/*.sql >/dev/null 2>&1; then
    echo "::warning::No hay migraciones en $MIGRATIONS_DIR (esperado al boot del proyecto)"
    return 0
  fi

  for migration_file in "$MIGRATIONS_DIR"/*.sql; do
    local migration_name
    migration_name="$(basename "$migration_file")"
    echo "  → $migration_name"

    if ! psql "$TEST_DATABASE_URL" -v ON_ERROR_STOP=1 -f "$migration_file" \
         > "$WORK_DIR/${migration_name}.run${pass}.log" 2>&1; then
      echo "::error::Migración $migration_name falló en pasada $pass."
      cat "$WORK_DIR/${migration_name}.run${pass}.log"
      exit 1
    fi
  done

  echo "  ✅ Pasada $pass completa"
}

reset_schema() {
  echo "→ Reset schema public..."
  psql "$TEST_DATABASE_URL" -v ON_ERROR_STOP=1 <<'EOF' > "$WORK_DIR/reset.log" 2>&1
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
EOF
}

dump_schema() {
  local out="$1"
  # pg_dump 17+ emite \restrict/\unrestrict con un nonce random por dump
  # (feature anti prompt-injection · el client psql refuse loading si el
  # nonce no matchea). Eso hace que dos dumps consecutivos del MISMO schema
  # difieran en 2 líneas. Las filtramos para comparar el schema real.
  pg_dump "$TEST_DATABASE_URL" --schema-only --no-owner --no-privileges \
    --schema=public --exclude-schema=auth --exclude-schema=storage \
    | grep -vE '^\\(un)?restrict ' \
    > "$out"
}

# -----------------------------------------------------------------
# Main flow · 2× apply + dump diff
# -----------------------------------------------------------------

# Pasada 1
reset_schema
apply_all_migrations 1
dump_schema "$WORK_DIR/snap1.sql"

# Pasada 2
reset_schema
apply_all_migrations 2
dump_schema "$WORK_DIR/snap2.sql"

# Comparar
echo ""
echo "==================================================================="
echo "Comparando snapshots"
echo "==================================================================="
if diff -q "$WORK_DIR/snap1.sql" "$WORK_DIR/snap2.sql" > /dev/null; then
  echo "✅ Schema final idéntico entre las 2 pasadas → repo es determinístico."
  exit 0
else
  echo "::error::Schema difiere entre la 1ra y 2da pasada de las migraciones."
  echo "Diagnóstico: alguna migración NO es determinística (random() · now() ·"
  echo "order-sensitivity · generación de UUIDs sin seed · etc)."
  echo "Diff (primeras 50 líneas):"
  diff "$WORK_DIR/snap1.sql" "$WORK_DIR/snap2.sql" | head -50
  exit 1
fi
