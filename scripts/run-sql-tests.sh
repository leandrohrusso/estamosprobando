#!/usr/bin/env bash
# =====================================================================
# scripts/run-sql-tests.sh · ejecuta los specs SQL del proyecto
# =====================================================================
# Invocado por:
#   - .github/workflows/ci.yml · job `sql` (CI remoto).
#   - scripts/local-ci.sh · case `sql)` (CI local · paridad cruzada).
#
# Stack adaptation banner ⚙️:
# Este script asume stack con Postgres + psql. Si tu stack usa otra BD
# (MySQL · MongoDB · SQLite · etc), adaptá el binario y los flags (ej:
# `mysql -h ... < file.sql` · `mongosh file.js` · etc). Si tu proyecto
# NO tiene BD, eliminar este script + el job `sql` del ci.yml + remover
# "sql" de ALL_JOBS en local-ci.sh para mantener paridad cruzada.
#
# Comportamiento:
#   1. Si `tests/sql/` no tiene archivos .sql → skip con notice (cero ABORT).
#   2. Si `psql` no está instalado → ABORT con mensaje claro.
#   3. Si DATABASE_URL no está seteado → ABORT con mensaje claro.
#   4. Itera sobre tests/sql/*.sql · ejecuta con `psql -v ON_ERROR_STOP=1 -f`.
#   5. Reporta exit code agregado (1 si algún spec falló · 0 si todos verdes).
# =====================================================================

set -euo pipefail

# 1 · Detectar specs SQL (cero ABORT si la carpeta está vacía)
shopt -s nullglob
SQL_FILES=(tests/sql/*.sql)
shopt -u nullglob

if [ ${#SQL_FILES[@]} -eq 0 ]; then
  echo "::notice::tests/sql/ vacío (cero specs .sql) · skip"
  exit 0
fi

# 1.5 · Skip-safe si no hay TEST DB configurada todavía (paridad state-baseline.sh)
# Al boot los .sql invariantes existen pero NO hay TEST DB (→ TASK-002 · 🔵 Bif 1=A
# de PRP-001). Skipea cleanly · cuando TASK-002 exporte DATABASE_URL, corre real.
if [ -z "${DATABASE_URL:-}" ]; then
  echo "::notice::run-sql-tests · DATABASE_URL no seteada · TEST DB no configurada (specs SQL → TASK-002) · SKIP"
  exit 0
fi

# 2 · Verificar psql disponible
if ! command -v psql &> /dev/null; then
  echo "::error::psql no está instalado · ABORT"
  echo "  → en CI · instalar postgresql-client en el job."
  echo "  → en local · instalá psql del sistema (apt · brew · pacman · etc)."
  exit 1
fi

# 3 · Ejecutar cada spec con ON_ERROR_STOP (paridad regla #32 idempotencia)
#     DATABASE_URL ya garantizada por el guard skip-safe del paso 1.5.
EXIT_CODE=0
for sql_file in "${SQL_FILES[@]}"; do
  echo "→ ejecutando: $sql_file"
  if ! psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$sql_file"; then
    echo "::error::$sql_file falló"
    EXIT_CODE=1
  fi
done

# 5 · Exit agregado
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "✅ ${#SQL_FILES[@]} spec(s) SQL verde(s)"
else
  echo "❌ uno o más spec(s) SQL fallaron"
fi

exit "$EXIT_CODE"
