#!/usr/bin/env bash
# =====================================================================
# scripts/lint-memory.sh · lint mensual de memoria
# =====================================================================
# Lint mensual de `.claude/memory/` con los 6 criterios.
#
# Regla satélite (cita inline obligatoria):
#   .claude/rules/lint-memory-periodic.md
#
# Modalidad:
#   - Read-only · NO modifica archivos.
#   - NO bloqueante (warning · SD-cos-N) · exit 0 siempre que el script
#     corra sin error fatal · los hallazgos se reportan en stdout en
#     formato Markdown estructurado para que el user decida caso por caso.
#
# Uso:
#   bash scripts/lint-memory.sh                # output Markdown a stdout
#   bash scripts/lint-memory.sh > report.md    # archivar reporte
#
# Invocado desde:
#   - Manual del user (cadencia mensual default · trigger manual via
#     `/memory-manager lint`).
#   - NO invocado desde CI · NO bloqueante por diseño.
#
# Plantilla: scripts/check-routing-english.sh (shape bash + grep + EXIT
# codes claros).
# =====================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MEM_DIR="$REPO_ROOT/.claude/memory"
INDEX="$MEM_DIR/MEMORY.md"
DATE_UTC="$(date -u +%Y-%m-%d)"
# Path glob excluido en find · centralizado para evitar drift en 4 sites.
EXCLUDE_PATH='*/_archive/*'

# exit 2 = fatal config error (índice missing) · distinguible de exit 0 (OK
# con o sin hallazgos · script NO bloqueante por contrato).
[[ -f "$INDEX" ]] || { echo "❌ No se encontró $INDEX" >&2; exit 2; }

# Cache de MEMORY.md leído 1 vez · evita N×2 lecturas dentro del loop de orphans.
INDEX_CONTENT="$(<"$INDEX")"

# ─────────────────────────────────────────────────────────────────────
# Cabecera del reporte
# ─────────────────────────────────────────────────────────────────────
cat <<EOF
# Lint Memory Report · ${DATE_UTC}

> Output del lint de \`.claude/memory/\` · 6 criterios de [\`lint-memory-periodic.md\`](../.claude/rules/lint-memory-periodic.md).
> Modalidad: read-only · NO modifica archivos · NO bloqueante · el user decide caso por caso.

EOF

# ─────────────────────────────────────────────────────────────────────
# 1. Contradicciones (semantic · revisión manual)
# ─────────────────────────────────────────────────────────────────────
cat <<'EOF'
## 1. Contradicciones

Detección semántica · NO mecanizable. Indicador: 2+ memorias con afirmaciones opuestas sobre el mismo tema (ej: una "siempre X" y otra "nunca X" sin contexto que justifique).

**Sugerencia manual:** revisar pares conocidos del proyecto (ej: dos memorias que afirmen "siempre X" vs "nunca X" sobre la misma área · ambas verdaderas en distintos contextos · necesitan reconciliación o cross-reference explícito que aclare cuándo aplica cada una).

EOF

# ─────────────────────────────────────────────────────────────────────
# 2. Stale claims (heurística + manual)
# ─────────────────────────────────────────────────────────────────────
cat <<'EOF'
## 2. Stale claims

Detección semántica · NO mecanizable. Indicador: memorias que afirman estado del repo o BD que ya no es cierto post-cambios recientes.

**Sugerencia manual:** revisar archivos `feedback/` y `project/` modificados hace >90 días que afirman estado del código.
EOF
echo
echo "**Heurística mecánica:** archivos con mtime > 90 días (revisar manualmente):"
echo
echo "_NOTA: \`git clone\` resetea el mtime de todos los archivos al momento del clone · esta heurística solo es confiable después de que el repo lleva >90 días con actividad local sostenida sobre cada archivo. Post-clone reciente · esperar que devuelva vacío y revisar manualmente via \`git log\` cuando aplique._"
echo
STALE_LIST=$(find "$MEM_DIR/feedback" "$MEM_DIR/reference" "$MEM_DIR/project" -type f -name '*.md' -mtime +90 2>/dev/null \
  | sed "s|$REPO_ROOT/||" | sed 's|^|- |')
if [[ -z "$STALE_LIST" ]]; then
  echo "_(ninguno mecánicamente · revisar manualmente · NO implica que las memorias sean recientes si el repo fue clonado hace poco)_"
else
  echo "$STALE_LIST"
fi
echo

# ─────────────────────────────────────────────────────────────────────
# 3. Orphan files (mecánico)
# ─────────────────────────────────────────────────────────────────────
cat <<'EOF'
## 3. Orphan files

Archivos en `.claude/memory/<carpeta>/` que NO están referenciados en `MEMORY.md`. Si no aparecen en el índice, el agente no los carga al boot · contenido invisible.
EOF
echo

# Lista archivos físicos (excluye _archive/) y los compara contra MEMORY.md.
# INDEX_CONTENT se cargó 1 vez al top · grep contra string en memoria, no re-lectura del archivo.
ORPHANS=0
while IFS= read -r physical; do
  rel_path="${physical#"$MEM_DIR"/}"
  # Buscar el path o el file_basename en el índice (algunas entradas usan paths relativos cortos).
  file_basename="${rel_path##*/}"
  if ! grep -qF "$rel_path" <<<"$INDEX_CONTENT" && ! grep -qF "$file_basename" <<<"$INDEX_CONTENT"; then
    if [[ $ORPHANS -eq 0 ]]; then
      echo "**Encontrados:**"
      echo
    fi
    echo "- \`.claude/memory/${rel_path}\`"
    ORPHANS=$((ORPHANS + 1))
  fi
done < <(find "$MEM_DIR" -type f -name '*.md' -not -path "$EXCLUDE_PATH" \
  -not -name 'MEMORY.md' \
  -not -name 'log.md' \
  -not -name 'PRP-*-checkpoint.md' \
  -not -name 'PRP-*-handoff*.md' \
  2>/dev/null)
# Exclusiones de PRP-*-checkpoint.md y PRP-*-handoff*.md: son docs históricos
# de continuidad multi-sesión que el SKILL `/refactor` lee directo por nombre
# (modo `/refactor implementar` § Process · pasos 1-2 leen checkpoint+handoff
# del PRP en curso). NO requieren entrada en MEMORY.md por diseño · sino el
# índice se infla con docs efímeros que rotan cada PRP.

if [[ $ORPHANS -eq 0 ]]; then
  echo "_(ninguno · todos los archivos físicos están en el índice)_"
else
  echo
  echo "**Acción sugerida:** (a) agregar al índice si aplica · (b) eliminar si es obsoleto · (c) marginar a \`_archive/\` si tiene valor histórico."
fi
echo

# ─────────────────────────────────────────────────────────────────────
# 4. Conceptos sin página propia (heurística + manual)
# ─────────────────────────────────────────────────────────────────────
cat <<'EOF'
## 4. Conceptos sin página propia

Patrón / regla / decisión mencionada en 3+ memorias distintas pero SIN página dedicada en `feedback/` o `reference/` · candidato a extracción a satélite.

**Detección semántica · NO mecanizable.** Sugerencia manual: ejecutar `grep -lE "<concepto>" .claude/memory/feedback/*.md .claude/memory/reference/*.md` para conceptos sospechosos (ej: "RLS SECURITY DEFINER", "snapshot-historical", "regression-first").

EOF

# ─────────────────────────────────────────────────────────────────────
# 5. Cross-references rotos (mecánico)
# ─────────────────────────────────────────────────────────────────────
cat <<'EOF'
## 5. Cross-references rotos

Links markdown `[texto](path.md)` que apuntan a archivos inexistentes (movidos · renombrados · borrados · navegación rota).
EOF
echo

BROKEN=0
# Itera archivos en feedback/ reference/ project/ + MEMORY.md.
while IFS= read -r src; do
  src_dir="$(dirname "$src")"
  # Extrae targets relativos (.md · sin esquema http) del Markdown.
  while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    # Normaliza path relativo al archivo source.
    # Tres casos:
    #   1. Absolute path desde filesystem root (`/...`) → prefijar REPO_ROOT.
    #   2. Repo-root-relative (empieza con un top-level dir conocido como
    #      `.claude/`, `docs/`, `tests/`, `src/`, `db/`, `scripts/`,
    #      `.github/`, `.husky/`) → prefijar REPO_ROOT/. Convención de
    #      visores Markdown (VSCode · GitHub · Obsidian) que tratan paths
    #      empezando con TLD conocido como repo-root-relative aunque no
    #      tengan `/` inicial. Sin este caso, el script reportaba ~17
    #      falsos positivos en el lint mensual (paths `.claude/rules/foo.md`
    #      desde memorias en `.claude/memory/project/` se resolvían a
    #      `.claude/memory/project/.claude/rules/foo.md` · roto).
    #   3. Relative al archivo source (resto) → prefijar src_dir.
    if [[ "$target" = /* ]]; then
      abs_target="$REPO_ROOT$target"
    elif [[ "$target" =~ ^(\.claude|\.github|\.husky|docs|tests|src|db|scripts)/ ]]; then
      abs_target="$REPO_ROOT/$target"
    else
      abs_target="$src_dir/$target"
    fi
    abs_target="${abs_target%%#*}"  # remove anchor #section
    if [[ -n "$abs_target" && ! -e "$abs_target" ]]; then
      if [[ $BROKEN -eq 0 ]]; then
        echo "**Encontrados:**"
        echo
      fi
      echo "- \`${src#"$REPO_ROOT"/}\` → \`${target}\` (no existe)"
      BROKEN=$((BROKEN + 1))
    fi
  done < <(grep -oE '\]\(([^)]+\.md[^)]*)\)' "$src" 2>/dev/null \
            | sed -E 's/^\]\(//; s/\)$//' \
            | grep -vE '^https?://')
done < <(find "$MEM_DIR" -maxdepth 2 -type f -name '*.md' -not -path "$EXCLUDE_PATH" 2>/dev/null)

if [[ $BROKEN -eq 0 ]]; then
  echo "_(ninguno · todos los links resuelven a archivos existentes)_"
fi
echo

# ─────────────────────────────────────────────────────────────────────
# 6. Data gaps PRP (mecánico)
# ─────────────────────────────────────────────────────────────────────
cat <<'EOF'
## 6. Data gaps PRP

PRPs marcados COMPLETADO sin entrada `prp-close` en `log.md` · señal de cierre incompleto.
EOF
echo

LOG="$MEM_DIR/log.md"
GAPS=0
# Fecha de la primera entrada del log · usada para excluir PRPs cerrados
# antes de que log.md existiera (regla `log-chronology-append-only.md` exime
# backfill: el log arrancó append-only · cierres previos quedaron documentados
# en `git log` + memorias `project/*.md` + bitácora del refactor). Sin esta
# exclusión el script reportaba falsos positivos en el lint mensual.
FIRST_LOG_DATE=""
if [[ -f "$LOG" ]]; then
  FIRST_LOG_DATE="$(grep -m1 -oE '^## \[[0-9]{4}-[0-9]{2}-[0-9]{2}\]' "$LOG" \
    | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)"
fi
if [[ -f "$LOG" ]]; then
  for prp_file in "$REPO_ROOT/.claude/PRPs/"PRP-*.md; do
    [[ -f "$prp_file" ]] || continue
    grep -q '^> \*\*Estado\*\*:.*COMPLETADO' "$prp_file" || continue
    prp_id="$(basename "$prp_file" | grep -oE '^PRP-[0-9]+')"
    if grep -qE "prp-close.*${prp_id}" "$LOG"; then
      continue  # tiene entrada en log · OK
    fi
    # Sin entrada en log: chequear si el PRP es pre-fecha primera entrada
    # (exento por regla log-chronology-append-only).
    if [[ -n "$FIRST_LOG_DATE" ]]; then
      first_commit_date="$(git -C "$REPO_ROOT" log --format=%ad --date=short --reverse \
        -- "$prp_file" 2>/dev/null | head -1 || true)"
      if [[ -n "$first_commit_date" && "$first_commit_date" < "$FIRST_LOG_DATE" ]]; then
        continue  # PRP pre-existente · exento por regla log-chronology-append-only
      fi
    fi
    if [[ $GAPS -eq 0 ]]; then
      echo "**Encontrados:**"
      echo
    fi
    echo "- \`${prp_id}\` COMPLETADO sin entrada \`prp-close\` en \`log.md\`"
    GAPS=$((GAPS + 1))
  done
fi

if [[ $GAPS -eq 0 ]]; then
  echo "_(ninguno · todos los PRPs COMPLETADOS tienen entrada en log.md)_"
fi

# ─────────────────────────────────────────────────────────────────────
# Resumen
# ─────────────────────────────────────────────────────────────────────
cat <<EOF

---

## Resumen mecánico

| Criterio | Estado | Hallazgos |
|---|---|---|
| 3 · Orphan files | $([ $ORPHANS -eq 0 ] && echo "✓" || echo "🟡") | $ORPHANS |
| 5 · Cross-refs rotos | $([ $BROKEN -eq 0 ] && echo "✓" || echo "🟡") | $BROKEN |
| 6 · Data gaps PRP | $([ $GAPS -eq 0 ] && echo "✓" || echo "🟡") | $GAPS |

**Criterios 1, 2, 4** requieren revisión semántica manual · este script NO los detecta automáticamente.

**Próximo paso:** el user decide caso por caso si fixear (ahora o postergar) · cada fix es un commit aparte con mensaje \`lint(memory): <criterio> · <fix corto>\`. Después del lint, agregar entrada \`lint\` a [\`.claude/memory/log.md\`](../.claude/memory/log.md) (formato canónico de [\`log-chronology-append-only.md\`](../.claude/rules/log-chronology-append-only.md)).
EOF
