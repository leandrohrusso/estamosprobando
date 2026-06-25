#!/usr/bin/env bash
# =====================================================================
# rules-shape-p8.sh · invariante mecánico shape P8 de las reglas firmes
# =====================================================================
# Los satélites de `.claude/rules/*.md` codifican las reglas operacionales
# firmes del flujo del proyecto · indexadas en CLAUDE.md § "Reglas FIRMES
# → Reglas del flujo". Cada regla debe cumplir el shape canónico P8
# heredado de Karpathy CLAUDE.md:
#
#   1. Frontmatter YAML válido (--- + name + type: rule).
#   2. 6 secciones P8 obligatorias: Overview · When · Process ·
#      Anti-rationalization · Red flags · Verification.
#
# Si una regla pierde una sección P8 o el frontmatter, el satélite queda
# inconsistente con la convención · el agente la lee como contenido
# parcial · regression silenciosa de la doctrina firme.
#
# Severidad: 🔴 ABORT en job `lint` · paridad con
# `skills-shape.sh` (los 13 skills).
# Convención firmada en cleanup .claude/ Modo A · sustituye al
# smoke histórico archivado en `.claude/_archive/scripts/refactor/`
# (cumplió función específica del momento · este smoke vivo conserva
# solo los 3 invariantes core adaptados al estado actual del proyecto).
#
# Memoria fuente: .claude/rules/README.md § "Convención" + § "Cómo
# agregar una regla nueva".
#
# Uso:
#   bash tests/scripts/infra-flujo/rules-shape-p8.sh
#
# Exit 0 si todas las reglas cumplen invariante · exit 1 al primer fallo.
# =====================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
RULES_DIR="$REPO_ROOT/.claude/rules"

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
RESET=$'\033[0m'

VIOLATIONS=0

fail_check() {
  echo "${RED}❌ $1${RESET}" >&2
  VIOLATIONS=$((VIOLATIONS + 1))
}
ok() { echo "${GREEN}✓ $1${RESET}"; }

# Shape P8 · 6 secciones canónicas heredadas de Karpathy CLAUDE.md
REQUIRED_SECTIONS=(
  "Overview"
  "When"
  "Process"
  "Anti-rationalization"
  "Red flags"
  "Verification"
)

# ─────────────────────────────────────────────────────────────────────
# 1. Cardinalidad de `.claude/rules/`
# ─────────────────────────────────────────────────────────────────────
# Cuenta reglas (excluye README.md de la carpeta · que es meta-índice).
# MIN_RULES (declarado abajo) es 1 de las 2 SoTs de cardinalidad del proyecto
# (la otra es la tabla canónica de CLAUDE.md § Reglas FIRMES). Sumar regla
# nueva: actualizar tabla CLAUDE.md siempre · subir MIN_RULES solo en hitos
# notables (cada 5-10 reglas). El smoke acepta crecimiento (>= MIN_RULES) ·
# NO acepta regresión silenciosa.

RULES_COUNT=$(find "$RULES_DIR" -maxdepth 1 -name '*.md' -type f ! -name 'README.md' | wc -l)

MIN_RULES=37  # 37 reglas actuales · subir cuando el proyecto crezca 5+ reglas (paridad comentario arriba sobre hitos notables)
if [[ $RULES_COUNT -lt $MIN_RULES ]]; then
  fail_check ".claude/rules/: count=$RULES_COUNT < $MIN_RULES (cardinalidad mínima esperada · regression)"
else
  ok ".claude/rules/: count=$RULES_COUNT (>= $MIN_RULES esperado)"
fi

# ─────────────────────────────────────────────────────────────────────
# 2. Shape P8 + frontmatter en cada regla
# ─────────────────────────────────────────────────────────────────────

check_rule() {
  local rule_path="$1"
  local rule_name
  rule_name="$(basename "$rule_path")"

  # 2a. Frontmatter YAML · primera línea '---'
  local first_line
  first_line=$(head -1 "$rule_path")
  if [[ "$first_line" != "---" ]]; then
    fail_check "$rule_name: primera línea NO es '---' (frontmatter ausente o malformado)"
    return
  fi

  # 2b. Frontmatter contiene `name:` y `type: rule`
  local head_block
  head_block=$(head -15 "$rule_path")
  if ! echo "$head_block" | grep -qE '^name:'; then
    fail_check "$rule_name: frontmatter sin campo 'name:'"
    return
  fi
  if ! echo "$head_block" | grep -qE '^type:[[:space:]]+rule'; then
    fail_check "$rule_name: frontmatter sin 'type: rule'"
    return
  fi

  # 2c. Shape P8 · las 6 secciones canónicas presentes (## Heading)
  local missing=()
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -qE "^## ${section}$" "$rule_path"; then
      missing+=("$section")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    fail_check "$rule_name: shape P8 incompleto · faltan secciones: ${missing[*]}"
    return
  fi

  ok "$rule_name: frontmatter (name + type: rule) + shape P8 6/6 OK"
}

echo
echo "Verificando shape P8 + frontmatter de las $RULES_COUNT reglas firmes..."
echo

for rule_path in "$RULES_DIR"/*.md; do
  # Saltear README.md (meta-índice · NO regla)
  [[ "$(basename "$rule_path")" == "README.md" ]] && continue
  check_rule "$rule_path"
done

echo
if [[ $VIOLATIONS -eq 0 ]]; then
  ok "Las $RULES_COUNT reglas firmes cumplen shape P8 + frontmatter · cero degeneración detectada"
  exit 0
else
  echo "${YELLOW}Total: $VIOLATIONS regla(s) con shape P8 / frontmatter roto.${RESET}"
  echo "Convención: .claude/rules/README.md § Convención"
  echo "Plantilla:  copiar regla existente (ej: surgical-changes.md) como base"
  exit 1
fi
