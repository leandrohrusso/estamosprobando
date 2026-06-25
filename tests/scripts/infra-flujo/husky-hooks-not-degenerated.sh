#!/usr/bin/env bash
# =====================================================================
# PRP-NNN · invariante operativo: hooks Husky no degenerados
# =====================================================================
# Los 4 hooks de `.husky/` (`pre-commit` · `pre-push` · `post-commit` ·
# `commit-msg`) son infra crítica del flujo: garantizan typecheck/lint
# pre-commit, typecheck/lint pre-push, backup automático a
# `origin/dev-backup`, y firma user en cambios al config de aplicabilidad
# de sub-agentes domain-tight (regla #35).
#
# Si alguien degenera un hook (deshabilita · simplifica a stub vacío ·
# cambia comando por noop), las validaciones desaparecen y la regla
# "1 push por PRP con CI verde garantizado" se rompe sin alarma.
#
# Caso histórico relacionado: lint-staged con sesiones paralelas
# (memoria fuente lint-staged-parallel-sessions-corruption.md) que pone
# foco en por qué los hooks DEBEN seguir corriendo lint-staged completo.
#
# Severidad: 🟡 warning. Diferencia con skip-ci (ABORT):
#   - Un hook puede tener variante legítima (test mode · debugging · etc).
#   - Por eso este check va en job separado con `continue-on-error: true`.
#   - El warning aparece en el PR pero no bloquea merge · sirve como
#     señal al humano que revisa.
#
# Memoria fuente (cita inline):
#   .claude/memory/feedback/lint-staged-parallel-sessions-corruption.md
#
# Regla satélite asociada:
#   .claude/rules/husky-hooks-smoke-tests.md
#
# Uso:
#   bash tests/scripts/infra-flujo/husky-hooks-not-degenerated.sh
#
# Exit 0 si todos los hooks mantienen lógica activa · exit 1 si alguno
# degeneró.
# =====================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
HUSKY_DIR="$REPO_ROOT/.husky"

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
# Helper · verifica que un hook existe + es ejecutable + matchea patterns
# ─────────────────────────────────────────────────────────────────────

check_hook() {
  local hook_name="$1"
  shift
  local required_patterns=("$@")
  local hook_path="$HUSKY_DIR/$hook_name"

  if [[ ! -f "$hook_path" ]]; then
    fail_check "$hook_name: no existe en .husky/"
    return
  fi

  if [[ ! -x "$hook_path" ]]; then
    fail_check "$hook_name: existe pero NO es ejecutable (chmod +x)"
    return
  fi

  # Stub-detection: hook con < 2 líneas de contenido NO comentadas/shebang
  # es señal de degeneración a noop. Filtramos shebang + comentarios + vacías.
  # Threshold = 2: hook degenerado a `#!/bin/sh\nexit 0` queda con 1 línea
  # activa · catch al primer signo de noop sin falsos positivos en hooks reales.
  local active_lines
  active_lines=$(grep -cE '^[^#[:space:]]' "$hook_path" || true)
  if [[ $active_lines -lt 2 ]]; then
    fail_check "$hook_name: stub-like ($active_lines líneas activas · sospecha de degeneración)"
    return
  fi

  for pattern in "${required_patterns[@]}"; do
    # `--` antes del pattern · evita que grep interprete patterns con prefijo
    # `-` (ej: `--force-with-lease`) como flags propios. Robusto a futuros patterns.
    if ! grep -qE -- "$pattern" "$hook_path"; then
      fail_check "$hook_name: NO matchea pattern requerido /$pattern/ · hook puede haber degenerado"
      return
    fi
  done

  ok "$hook_name: $active_lines líneas activas · todos los patterns requeridos presentes"
}

# ─────────────────────────────────────────────────────────────────────
# 1. pre-commit · typecheck full + lint-staged
# ─────────────────────────────────────────────────────────────────────
check_hook "pre-commit" \
  '^npm run typecheck' \
  '^npx lint-staged'

# ─────────────────────────────────────────────────────────────────────
# 2. pre-push · typecheck full + lint full
# ─────────────────────────────────────────────────────────────────────
check_hook "pre-push" \
  '^npm run typecheck' \
  '^npm run lint'

# ─────────────────────────────────────────────────────────────────────
# 3. post-commit · backup automático a origin/dev-backup
# Auto-recovery non-FF (DT-NNN): el hook debe contener
# la lógica de detección de "non-fast-forward" y recuperación con
# --force-with-lease. Sin esto, el backup queda roto post-squash hasta
# intervención manual.
# ─────────────────────────────────────────────────────────────────────
check_hook "post-commit" \
  'git push.*origin HEAD:dev-backup' \
  'post-commit-backup\.log' \
  'non-fast-forward' \
  '--force-with-lease'

# ─────────────────────────────────────────────────────────────────────
# 4. commit-msg · firma user obligatoria al modificar agents-applicability.yml
# Regla #35 § Anti-rationalization #3: cambios al config requieren firma
# explícita 🔵 user · cero modificación silenciosa. El hook detecta cambio
# staged al config + valida firma canónica ("🔵" · "firma user" · "firma 🔵")
# en el commit message.
# ─────────────────────────────────────────────────────────────────────
check_hook "commit-msg" \
  'agents-applicability\.yml' \
  '🔵|firma user|firma 🔵'

# ─────────────────────────────────────────────────────────────────────
# Resultado final
# ─────────────────────────────────────────────────────────────────────
echo
if [[ $VIOLATIONS -eq 0 ]]; then
  ok "Los 4 hooks Husky mantienen lógica activa · cero degeneración detectada"
  exit 0
else
  echo "${YELLOW}Total: $VIOLATIONS hook(s) con sospecha de degeneración.${RESET}"
  echo "Memorias: .claude/memory/feedback/lint-staged-parallel-sessions-corruption.md"
  echo "Regla:    .claude/rules/husky-hooks-smoke-tests.md"
  exit 1
fi
