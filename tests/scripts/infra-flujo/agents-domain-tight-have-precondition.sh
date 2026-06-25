#!/usr/bin/env bash
# =====================================================================
# agents-domain-tight-have-precondition.sh
# Invariante mecánico · sub-agentes domain-tight de skills multi-agente
# (típicamente /revisar y /revisar-main) cumplen el mecanismo Pieza 4
# de la regla firme #35 (agents-conditional-by-domain.md):
#
#   (4a) Banner top inmediato post-`# Agent: <nombre>` con texto canónico
#        "Domain-conditional agent" + cita a regla #35 + flag específico.
#   (4b) Pre-condition check al INICIO del § Process con matriz 3-way
#        (no / unknown / yes) + backup defensivo (config no disponible).
#
# Si un agente domain-tight pierde el banner o el Pre-condition check,
# o si el texto del banner diverge entre los 3 agentes (cero uniformidad,
# regla #8 quality-standard-senior), el mecanismo de opt-in/opt-out queda
# parcialmente roto · regresión silenciosa de la doctrina firme.
#
# Severidad: 🔴 ABORT en job `lint` · paridad con
# `rules-shape-p8.sh` y `skip-ci-not-in-pr-head.sh`.
# Convención firmada upstream post-implementación A+B (regla #35).
#
# Memoria fuente: .claude/rules/agents-conditional-by-domain.md
# § Process (Pieza 4a + Pieza 4b) + § Verification.
#
# Uso:
#   bash tests/scripts/infra-flujo/agents-domain-tight-have-precondition.sh
#
# Exit 0 si todos los agentes domain-tight cumplen invariante · exit 1
# al primer fallo acumulado.
# =====================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

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

# ─────────────────────────────────────────────────────────────────────
# Lista canónica de agentes domain-tight (3 agentes × 2 SKILLs = 6 archivos)
# Si el pack agrega agentes domain-tight nuevos al config
# `.claude/config/agents-applicability.yml`, sumar acá las paths
# correspondientes en /revisar/agents/ y /revisar-main/agents/.
# ─────────────────────────────────────────────────────────────────────
DOMAIN_TIGHT_AGENTS=(
  ".claude/skills/revisar/agents/multi-tenant.md"
  ".claude/skills/revisar/agents/atomicity.md"
  ".claude/skills/revisar/agents/migration-safety.md"
  ".claude/skills/revisar-main/agents/multi-tenant.md"
  ".claude/skills/revisar-main/agents/atomicity.md"
  ".claude/skills/revisar-main/agents/migration-safety.md"
)

# ─────────────────────────────────────────────────────────────────────
# Pieza 4a · Banner top "Domain-conditional agent"
# ─────────────────────────────────────────────────────────────────────
# Marker canónico que cada agente domain-tight DEBE tener en el banner
# post-`# Agent:`. Si falta, el lector no sabe que el agente es
# condicional · regla #35 § Pieza 4a violada.

BANNER_MARKER='\*\*⚠️ Domain-conditional agent\.\*\*'
RULE_35_LINK='agents-conditional-by-domain\.md'

# ─────────────────────────────────────────────────────────────────────
# Pieza 4b · Pre-condition check al INICIO del § Process
# ─────────────────────────────────────────────────────────────────────
# 3 marcadores canónicos · matriz 3-way + backup defensivo. Si falta
# alguno, el early-exit es incompleto y el agente puede ejecutar análisis
# silencioso de fallback (regla #35 § Anti-rationalization #6).

PRECONDITION_HEADER='^## Pre-condition check'
PRECONDITION_MARKER_NO='agent skipped (proyecto declara'
PRECONDITION_MARKER_UNKNOWN='agent skipped (proyecto NO declaró'
PRECONDITION_MARKER_BACKUP='agent skipped (config no disponible)'

check_agent() {
  local agent_path="$1"
  local agent_full="$REPO_ROOT/$agent_path"
  local agent_name
  agent_name="$(basename "$agent_path")"
  local skill_dir
  skill_dir="$(dirname "$(dirname "$agent_path")")"

  if [[ ! -f "$agent_full" ]]; then
    fail_check "$skill_dir/$agent_name: archivo NO existe · agente domain-tight ausente del pack"
    return
  fi

  local agent_missing=()

  # 4a · Banner "Domain-conditional agent" presente
  if ! grep -qE "$BANNER_MARKER" "$agent_full"; then
    agent_missing+=("Pieza 4a banner '⚠️ Domain-conditional agent.' ausente")
  fi

  # 4a · Link a regla #35 presente en banner
  if ! grep -qE "$RULE_35_LINK" "$agent_full"; then
    agent_missing+=("Pieza 4a cita a regla #35 (agents-conditional-by-domain.md) ausente")
  fi

  # 4b · Header § Pre-condition check presente
  if ! grep -qE "$PRECONDITION_HEADER" "$agent_full"; then
    agent_missing+=("Pieza 4b § 'Pre-condition check' header ausente")
  fi

  # 4b · Branching `no` presente
  if ! grep -qF "$PRECONDITION_MARKER_NO" "$agent_full"; then
    agent_missing+=("Pieza 4b branching 'enabled: no' (output 'agent skipped · proyecto declara') ausente")
  fi

  # 4b · Branching `unknown` presente
  if ! grep -qF "$PRECONDITION_MARKER_UNKNOWN" "$agent_full"; then
    agent_missing+=("Pieza 4b branching 'enabled: unknown' (output 'agent skipped · proyecto NO declaró') ausente")
  fi

  # 4b · Backup defensivo presente
  if ! grep -qF "$PRECONDITION_MARKER_BACKUP" "$agent_full"; then
    agent_missing+=("Pieza 4b backup defensivo 'agent skipped (config no disponible)' ausente")
  fi

  if [[ ${#agent_missing[@]} -gt 0 ]]; then
    fail_check "$skill_dir/$agent_name: ${#agent_missing[@]} invariante(s) roto(s):"
    for issue in "${agent_missing[@]}"; do
      echo "    · $issue" >&2
    done
    return
  fi

  ok "$skill_dir/$agent_name: Pieza 4a (banner + link #35) + Pieza 4b (matriz 3-way + backup) OK"
}

echo
echo "Verificando mecanismo Pieza 4 de regla #35 en ${#DOMAIN_TIGHT_AGENTS[@]} agentes domain-tight..."
echo

for agent in "${DOMAIN_TIGHT_AGENTS[@]}"; do
  check_agent "$agent"
done

# ─────────────────────────────────────────────────────────────────────
# Uniformidad del banner entre los 3 pares hermanos (/revisar ↔ /revisar-main)
# ─────────────────────────────────────────────────────────────────────
# Cada par de agentes hermanos (multi-tenant en /revisar y /revisar-main · etc)
# debe compartir la línea exacta del banner "Domain-conditional agent" · solo
# varían `<flag>` y `<descripción>` (regla #8 quality-standard-senior · cero
# hardcode divergente). Verificable extrayendo la línea del banner de cada par
# y comparando: si ambos contienen el mismo flag, el banner debe ser idéntico.

check_pair_uniformity() {
  local agent_name="$1"
  local revisar_path="$REPO_ROOT/.claude/skills/revisar/agents/$agent_name"
  local revisar_main_path="$REPO_ROOT/.claude/skills/revisar-main/agents/$agent_name"

  if [[ ! -f "$revisar_path" ]] || [[ ! -f "$revisar_main_path" ]]; then
    return
  fi

  local revisar_banner
  local revisar_main_banner
  revisar_banner="$(grep -E "$BANNER_MARKER" "$revisar_path" | head -1)"
  revisar_main_banner="$(grep -E "$BANNER_MARKER" "$revisar_main_path" | head -1)"

  if [[ "$revisar_banner" != "$revisar_main_banner" ]]; then
    fail_check "Banner divergente entre /revisar/agents/$agent_name y /revisar-main/agents/$agent_name (regla #8 · cero hardcode divergente)"
    echo "    /revisar:      $revisar_banner" >&2
    echo "    /revisar-main: $revisar_main_banner" >&2
  else
    ok "Banner uniforme entre pares hermanos: $agent_name"
  fi
}

echo
echo "Verificando uniformidad del banner entre pares hermanos..."
echo

check_pair_uniformity "multi-tenant.md"
check_pair_uniformity "atomicity.md"
check_pair_uniformity "migration-safety.md"

echo
if [[ $VIOLATIONS -eq 0 ]]; then
  ok "Los ${#DOMAIN_TIGHT_AGENTS[@]} agentes domain-tight cumplen mecanismo Pieza 4 de regla #35 · cero degeneración detectada"
  exit 0
else
  echo "${YELLOW}Total: $VIOLATIONS violación(es) del mecanismo de regla #35.${RESET}"
  echo "Doctrina: .claude/rules/agents-conditional-by-domain.md § Process Pieza 4a + 4b"
  echo "Plantilla: copiar banner + Pre-condition check de un agente conforme (ej: multi-tenant.md)"
  exit 1
fi
