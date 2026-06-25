#!/usr/bin/env bash
# =====================================================================
# scripts/archive-log.sh · Archivado periódico del log.md (cada 14 días)
# =====================================================================
# Materializa los 6 pasos del procedimiento de archivado periódico
# codificados en la regla satélite #13.
#
# Regla satélite (cita inline obligatoria · SoT contractual):
#   .claude/rules/log-chronology-append-only.md § Archivado periódico
#
# Modalidad:
#   - Idempotente · pre-condición working tree limpio (ABORT si dirty).
#   - Revertible con git restore . post-fail (no commitea automáticamente).
#   - NO bloqueante por diseño · el user revisa diff y commitea.
#
# Uso:
#   bash scripts/archive-log.sh
#
# Disparador:
#   - Fila en docs/logs/deadlines.md cada 14 días.
#   - Auto-propuesta contractual del agente en /arrancar Paso 6 cuando
#     detecta vencimiento (regla #20 § Archivado periódico).
#
# Plantilla: scripts/lint-memory.sh (shape bash + cita inline a regla +
# pre-condiciones + exit codes claros).
# =====================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$REPO_ROOT/.claude/memory/log.md"
ARCHIVE_DIR="$REPO_ROOT/.claude/memory/_archive"
DEADLINES_FILE="$REPO_ROOT/docs/logs/deadlines.md"
TODAY="$(date -u +%Y-%m-%d)"
NEXT_DEADLINE="$(date -u -v +14d +%Y-%m-%d 2>/dev/null || date -u -d "+14 days" +%Y-%m-%d)"
ARCHIVE_FILE="$ARCHIVE_DIR/log-${TODAY}.md"

# Helpers de output legible (shape paridad scripts/lint-memory.sh)
ok()   { echo "  ✓ $*"; }
fail() { echo "  ✗ $*" >&2; }
info() { echo "  · $*"; }

echo "═══════════════════════════════════════════════════════════════════"
echo "  archive-log.sh · archivado periódico del log.md · ${TODAY}"
echo "═══════════════════════════════════════════════════════════════════"

# ─────────────────────────────────────────────────────────────────────
# Paso 1 · Pre-condición · working tree limpio
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "Paso 1 · pre-condición working tree limpio"
if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
    fail "Working tree sucio · commiteá o stash primero (la operación toca 3 archivos · necesita atomicidad)"
    exit 1
fi
ok "working tree limpio"

# ─────────────────────────────────────────────────────────────────────
# Paso 1.5 · validar pre-condiciones de archivos y carpetas
# ─────────────────────────────────────────────────────────────────────
[[ -f "$LOG_FILE" ]]       || { fail "No existe $LOG_FILE"; exit 2; }
[[ -d "$ARCHIVE_DIR" ]]    || { fail "No existe $ARCHIVE_DIR (crear con README.md primero · regla #22)"; exit 2; }
[[ -f "$DEADLINES_FILE" ]] || { fail "No existe $DEADLINES_FILE"; exit 2; }
[[ ! -f "$ARCHIVE_FILE" ]] || { fail "Archivo de archivo ya existe: $ARCHIVE_FILE · archivado idempotente por día (1 archivado/día)"; exit 3; }

# Detectar línea de la primera entry (## [YYYY-MM-DD]) en log.md
FIRST_ENTRY_LINE="$(grep -n '^## \[' "$LOG_FILE" | head -1 | cut -d: -f1)"
if [[ -z "$FIRST_ENTRY_LINE" ]]; then
    fail "log.md NO tiene entries (## [YYYY-MM-DD]) · nada para archivar"
    exit 4
fi
HEADER_LAST_LINE=$((FIRST_ENTRY_LINE - 1))
ENTRY_COUNT="$(grep -c '^## \[' "$LOG_FILE")"
TOTAL_LINES="$(wc -l < "$LOG_FILE")"

ok "log.md tiene ${ENTRY_COUNT} entries · ${TOTAL_LINES} líneas · header pre-entries: líneas 1-${HEADER_LAST_LINE}"

# ─────────────────────────────────────────────────────────────────────
# Paso 2 · Snapshot del log.md → _archive/log-YYYY-MM-DD.md
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "Paso 2 · snapshot del log.md → archivo"
cp "$LOG_FILE" "$ARCHIVE_FILE"
ok "snapshot creado: $ARCHIVE_FILE ($(wc -l < "$ARCHIVE_FILE") líneas)"

# ─────────────────────────────────────────────────────────────────────
# Paso 3 · Truncar log.md (header + cross-ref + entry lint nueva)
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "Paso 3 · truncar log.md · preservar header + agregar cross-ref + entry lint"

# Preservar líneas 1 a HEADER_LAST_LINE (todo lo pre-primera-entry)
TMP_LOG="$(mktemp)"
head -n "$HEADER_LAST_LINE" "$LOG_FILE" > "$TMP_LOG"

# Agregar cross-ref + entry lint nueva
cat >> "$TMP_LOG" <<EOF
> **Archivado periódico (${TODAY}):** entries previas archivadas en [\`_archive/log-${TODAY}.md\`](_archive/log-${TODAY}.md) (${ENTRY_COUNT} entries · cronología completa preservada · snapshot inmutable). Cross-ref vive solo acá · NO se modifica retroactivamente el archivo de archivo.

## [${TODAY}] lint | Archivado periódico ejecutado · ${ENTRY_COUNT} entries movidas a \`_archive/log-${TODAY}.md\`

**Resumen:** archivado periódico cada 14 días (regla #20 § Archivado periódico) ejecutado por \`scripts/archive-log.sh\` · ${ENTRY_COUNT} entries cronológicas movidas a \`.claude/memory/_archive/log-${TODAY}.md\` (snapshot inmutable) · \`log.md\` raíz queda con solo esta entry + cross-ref · próximo deadline: ${NEXT_DEADLINE} (auto-renovado en \`docs/logs/deadlines.md\`).
**Refs:** archivo de archivo \`.claude/memory/_archive/log-${TODAY}.md\` · regla [\`log-chronology-append-only.md § Archivado periódico\`](../rules/log-chronology-append-only.md) · script \`scripts/archive-log.sh\` · próximo deadline \`docs/logs/deadlines.md\` § Activos.
EOF

mv "$TMP_LOG" "$LOG_FILE"
NEW_LINES="$(wc -l < "$LOG_FILE")"
ok "log.md truncado: ${TOTAL_LINES} → ${NEW_LINES} líneas (header + cross-ref + entry lint)"

# ─────────────────────────────────────────────────────────────────────
# Paso 4 · Actualizar deadlines.md (mover fila vieja a Histórico · nueva a Activos)
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "Paso 4 · actualizar deadlines.md · auto-renovación a +14 días (${NEXT_DEADLINE})"

NEW_ACTIVE_ROW="| Archivado periódico de **log.md** | ${NEXT_DEADLINE} | Cada 14 días | \`bash scripts/archive-log.sh\` |"

# Detectar fila actual del archivado en § Activos (cualquier fecha · puede no ser TODAY si vencido)
# NEW_HIST_ROW se define abajo con ${ORIGINAL_DATE} real (NO con ${TODAY} · que sería falsa fecha de programación original).
CURRENT_ROW="$(grep -n "Archivado periódico de \*\*log.md\*\*" "$DEADLINES_FILE" | head -1)"
if [[ -z "$CURRENT_ROW" ]]; then
    fail "No se encontró fila de archivado en deadlines.md § Activos · revisar manualmente"
    exit 5
fi

CURRENT_ROW_NUM="$(echo "$CURRENT_ROW" | cut -d: -f1)"
ORIGINAL_DATE="$(echo "$CURRENT_ROW" | sed -E 's/^[0-9]+:\| ([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/')"
NEW_HIST_ROW="| ${ORIGINAL_DATE} | ${TODAY} | Archivado ejecutado · \`_archive/log-${TODAY}.md\` (${ENTRY_COUNT} entries) · próximo deadline ${NEXT_DEADLINE} |"

# Reemplazar la fila actual con la nueva (auto-renovada a +14 días)
# Uso perl -i en lugar de sed -i "${N}c\TEXTO" porque BSD sed (macOS) NO soporta
# la sintaxis `c\TEXTO` en un solo argumento · perl -i es portable cross-OS.
perl -i -pe "s|.*|${NEW_ACTIVE_ROW}| if \$. == ${CURRENT_ROW_NUM}" "$DEADLINES_FILE"

# Agregar fila al § Histórico (insertada después de la línea del header "| Deadline | Fecha ejecución | Resultado |")
HIST_HEADER_LINE="$(grep -n "^| Deadline | Fecha ejecución | Resultado |" "$DEADLINES_FILE" | head -1 | cut -d: -f1)"
if [[ -z "$HIST_HEADER_LINE" ]]; then
    fail "No se encontró header de § Histórico en deadlines.md · revisar manualmente"
    exit 6
fi
# Insertar después del separador de la tabla (línea siguiente al header · |---|---|)
# Uso perl -i en lugar de sed -i "${N}a\TEXTO" por la misma razón cross-OS.
INSERT_AFTER=$((HIST_HEADER_LINE + 1))
perl -i -pe "print \"${NEW_HIST_ROW}\n\" if \$. == ${INSERT_AFTER}" "$DEADLINES_FILE"

ok "deadlines.md actualizado · § Activos: ${ORIGINAL_DATE} → ${NEXT_DEADLINE} · § Histórico: fila nueva con resultado"

# ─────────────────────────────────────────────────────────────────────
# Paso 5 · Output al user · sugerir mensaje de commit
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  ✓ archivado completado · revisar diff y commitear"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Archivos modificados/creados (3):"
echo "  + .claude/memory/_archive/log-${TODAY}.md  (nuevo · ${ENTRY_COUNT} entries archivadas)"
echo "  ~ .claude/memory/log.md                    (truncado · ${TOTAL_LINES} → ${NEW_LINES} líneas)"
echo "  ~ docs/logs/deadlines.md                   (auto-renovación · ${ORIGINAL_DATE} → ${NEXT_DEADLINE})"
echo ""
echo "Sugerencia de commit (paridad regla #27 push-and-ci-policy · commit local · NO push):"
echo ""
cat <<EOF
git add .claude/memory/_archive/log-${TODAY}.md .claude/memory/log.md docs/logs/deadlines.md
git commit -m "chore(log): archivado periódico · ${ENTRY_COUNT} entries pre-${TODAY} a _archive/ · próximo deadline ${NEXT_DEADLINE}

Materializa el archivado periódico del log (regla #20 § Archivado periódico ·
cada 14 días · firma 🔵 user). Cero pérdida de información:
snapshot inmutable en _archive/log-${TODAY}.md preserva la cronología completa.
log.md raíz queda con header + cross-ref + 1 entry lint auto-documentando.
deadlines.md auto-renovado a ${NEXT_DEADLINE}.
"
EOF
echo ""
echo "Para revertir antes del commit: git restore . && rm .claude/memory/_archive/log-${TODAY}.md"
echo ""
