#!/usr/bin/env bash
# =====================================================================
# Invariante mecánico: shape P8 + frontmatter de los 15 skills del pack
# =====================================================================
# El pack workflow-base define 15 skills en este array (8 del flujo de
# 6 pasos con variantes simple · + 7 auxiliares).
# Todos deben mantener shape P8 (Overview · When · Process ·
# Anti-rationalization · Red flags · Verification) + frontmatter YAML
# obligatorio (`name` + `description`).
#
# Si un skill pierde alguna sección o el frontmatter, el flujo se
# degrada SILENCIOSAMENTE:
#
#   - Description vacío → el harness no carga el skill (triggers rotos).
#   - Sin Anti-rationalization → el agente justifica saltarse fases.
#   - Sin Verification → el cierre del paso queda subjetivo.
#   - Sin Process → no hay procedimiento canónico que seguir.
#
# Severidad: 🟡 warning · Job `infra-flujo-warnings` (`continue-on-error: true`)
# en `.github/workflows/ci.yml`. NO bloquea merge · el adopter puede tener
# skills en estado intermedio durante refactor sin que el CI rompa. Si más
# adelante se quiere endurecer a ABORT, mover el step al job `lint` del CI.
#
# Uso:
#   bash tests/scripts/infra-flujo/skills-shape.sh
#
# Exit 0 si los 15 skills cumplen invariante · exit 1 si alguno rompe.
# =====================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/.claude/skills"

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

# Los 15 skills del pack workflow-base en este array:
#   - 8 skills del flujo de 6 pasos (variantes simple incluidas: planificar-simple · revisar-simple).
#   - 7 skills auxiliares (fatiga · handoff · documentar · memory-manager ·
#     auditar-dt · revisar-main · consultor).
# Todos con misma exigencia de shape P8 + frontmatter para evitar
# regresión silenciosa del pack.
SKILLS=(
  "arrancar"
  "planificar"
  "planificar-simple"
  "implementar"
  "revisar"
  "revisar-simple"
  "validar"
  "entregar"
  "fatiga"
  "handoff"
  "documentar"
  "memory-manager"
  "auditar-dt"
  "revisar-main"
  "consultor"
)

# ─────────────────────────────────────────────────────────────────────
# Helper · verifica un skill (existencia + frontmatter + shape P8)
# ─────────────────────────────────────────────────────────────────────
check_skill() {
  local skill="$1"
  local skill_path="$SKILLS_DIR/$skill/SKILL.md"

  # 1. Existencia del archivo
  if [[ ! -f "$skill_path" ]]; then
    fail_check "$skill: SKILL.md no existe (esperado en .claude/skills/$skill/SKILL.md)"
    return
  fi

  # 2. Frontmatter YAML · primera línea '---'
  local first_line
  first_line=$(head -1 "$skill_path")
  if [[ "$first_line" != "---" ]]; then
    fail_check "$skill: primera línea NO es '---' (frontmatter ausente o malformado)"
    return
  fi

  # Extraer frontmatter (líneas entre primer y segundo '---')
  local frontmatter
  frontmatter=$(awk '/^---$/{c++; next} c==1' "$skill_path")
  if [[ -z "$frontmatter" ]]; then
    fail_check "$skill: frontmatter vacío entre delimitadores '---'"
    return
  fi

  # 3. Campo `name:` presente y no vacío
  local name_line
  name_line=$(echo "$frontmatter" | grep -E '^name:[[:space:]]*' || true)
  if [[ -z "$name_line" ]]; then
    fail_check "$skill: frontmatter sin campo 'name:'"
    return
  fi
  local name_value
  name_value=$(echo "$name_line" | sed -E 's/^name:[[:space:]]*//' | tr -d '"' | xargs || true)
  if [[ -z "$name_value" ]]; then
    fail_check "$skill: frontmatter campo 'name:' está vacío"
    return
  fi

  # 4. Campo `description:` presente y no vacío
  local description_line
  description_line=$(echo "$frontmatter" | grep -E '^description:[[:space:]]*' || true)
  if [[ -z "$description_line" ]]; then
    fail_check "$skill: frontmatter sin campo 'description:'"
    return
  fi
  local description_value
  description_value=$(echo "$description_line" | sed -E 's/^description:[[:space:]]*//' | tr -d '"' | xargs || true)
  if [[ -z "$description_value" ]]; then
    fail_check "$skill: frontmatter campo 'description:' está vacío"
    return
  fi

  # 5. Shape P8 · las 6 secciones canónicas presentes
  local missing=()
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -qE "^## ${section}$" "$skill_path"; then
      missing+=("$section")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    fail_check "$skill: shape P8 incompleto · faltan secciones: ${missing[*]}"
    return
  fi

  ok "$skill: frontmatter (name='$name_value') + shape P8 6/6 OK"
}

# ─────────────────────────────────────────────────────────────────────
# Ejecución
# ─────────────────────────────────────────────────────────────────────
echo "Verificando shape P8 + frontmatter de los 15 skills del pack..."
echo

for skill in "${SKILLS[@]}"; do
  check_skill "$skill"
done

echo
if [[ $VIOLATIONS -eq 0 ]]; then
  ok "Los ${#SKILLS[@]} skills cumplen shape P8 + frontmatter · cero degeneración detectada"
  exit 0
else
  echo "${YELLOW}Total: $VIOLATIONS skill(s) con shape P8 / frontmatter roto.${RESET}"
  echo "Convención: tests/scripts/infra-flujo/README.md"
  exit 1
fi
