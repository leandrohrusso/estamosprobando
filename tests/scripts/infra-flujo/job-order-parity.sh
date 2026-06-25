#!/usr/bin/env bash
# =====================================================================
# job-order-parity.sh · invariante mecánico paridad ALL_JOBS ↔ ci.yml needs:
# =====================================================================
# `scripts/local-ci.sh` array `ALL_JOBS=(...)` y `.github/workflows/ci.yml`
# cadenas `needs:` deben mantener orden topológico paralelo. Si divergen,
# CI local y remoto corren en órdenes distintos · bugs detectables solo
# en CI remoto se filtran al merge silenciosamente.
#
# Invariante mecánica:
#   Para cada par (jobChild needs: [jobParent, ...]) declarado en ci.yml,
#   jobParent debe preceder a jobChild en el array ALL_JOBS=(...) del
#   `local-ci.sh`. Jobs CI-only (presentes solo en ci.yml · ej:
#   `infra-flujo-warnings`) se ignoran (no rompen la invariante).
#
# Regla fuente: #34 [`husky-hooks-smoke-tests.md`] § Reglas operativas:
#   "`local-ci.sh` y `ci.yml` son canales hermanos · cualquier cambio de
#    orden de jobs en uno obliga el cambio simétrico en el otro · cuando
#    el proyecto derivado defina jobs concretos, considerar smoke bash de
#    paridad encadenado al job `lint`."
#
# Diseño universal · cero hardcode de nombres de jobs:
#   - Parsea ALL_JOBS=(...) dinámicamente del local-ci.sh.
#   - Parsea jobs + needs: directamente del ci.yml con heurística grep
#     (shape canónico GitHub Actions: `^  <name>:$` para job names +
#     `needs: [a, b]` / `needs: a` debajo de cada job).
#   - Aplica a cualquier proyecto derivado del template sin modificación.
#
# Uso:
#   bash tests/scripts/infra-flujo/job-order-parity.sh
#
# CI: invocado por el job `lint` (severidad 🔴 ABORT · regla #34 violada
# = drift silencioso entre CI local y remoto).
#
# Exit 0 si invariante OK · exit 1 si rompe.
# =====================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
LOCAL_CI="$REPO_ROOT/scripts/local-ci.sh"
WORKFLOW="$REPO_ROOT/.github/workflows/ci.yml"

fail() { echo "❌ $1" >&2; exit 1; }
ok()   { echo "✓ $1"; }

# ---------------------------------------------------------------------
# 1. Validar archivos existen
# ---------------------------------------------------------------------

[[ -f "$LOCAL_CI" ]] || fail "scripts/local-ci.sh no encontrado: $LOCAL_CI"
[[ -f "$WORKFLOW" ]] || fail ".github/workflows/ci.yml no encontrado: $WORKFLOW"

# ---------------------------------------------------------------------
# 2. Parsear ALL_JOBS=(...) del local-ci.sh
# ---------------------------------------------------------------------

JOBS_LINE=$(grep -E '^ALL_JOBS=\(' "$LOCAL_CI" | head -1 || true)
[[ -z "$JOBS_LINE" ]] && fail "local-ci.sh: array ALL_JOBS=(...) no encontrado"

JOBS_LIST=$(echo "$JOBS_LINE" | sed -E 's/^ALL_JOBS=\((.*)\).*$/\1/')
# shellcheck disable=SC2206
LOCAL_JOBS=($JOBS_LIST)
[[ ${#LOCAL_JOBS[@]} -eq 0 ]] && fail "local-ci.sh: ALL_JOBS array vacío"

declare -A LOCAL_IDX
for i in "${!LOCAL_JOBS[@]}"; do
  LOCAL_IDX[${LOCAL_JOBS[$i]}]=$i
done

ok "local-ci.sh: ${#LOCAL_JOBS[@]} jobs en ALL_JOBS · ${LOCAL_JOBS[*]}"

# ---------------------------------------------------------------------
# 3. Parsear jobs + needs: del ci.yml (heurística grep · shape canónico)
# ---------------------------------------------------------------------
# Convención GitHub Actions: bajo `jobs:`, cada job name es una línea
# `^  <name>:$` (2 espacios exactos · alfanumérico + guiones/underscores).
# `needs:` puede aparecer como `needs: [a, b]` · `needs: a` · o bloque
# multi-línea YAML (este último NO soportado · usar formato inline en
# ci.yml para que el smoke funcione).
# ---------------------------------------------------------------------

CURRENT_JOB=""
declare -A NEEDS_PAIRS  # key "child:parent" · value 1
declare -A YML_JOBS     # set de jobs declarados en ci.yml

in_jobs_section=0
while IFS= read -r line; do
  if [[ "$line" =~ ^jobs:[[:space:]]*$ ]]; then
    in_jobs_section=1
    continue
  fi
  [[ $in_jobs_section -eq 0 ]] && continue

  # job name · `^  <name>:$` (exactamente 2 spaces de indent)
  if [[ "$line" =~ ^[[:space:]]{2}([a-zA-Z][a-zA-Z0-9_-]*):[[:space:]]*$ ]]; then
    CURRENT_JOB="${BASH_REMATCH[1]}"
    YML_JOBS[$CURRENT_JOB]=1
    continue
  fi

  # needs: inline · `needs: [a, b]` o `needs: a`
  if [[ -n "$CURRENT_JOB" ]] && [[ "$line" =~ ^[[:space:]]+needs:[[:space:]]*\[(.+)\][[:space:]]*$ ]]; then
    needs_value="${BASH_REMATCH[1]}"
    IFS=',' read -ra parents <<< "$needs_value"
    for p in "${parents[@]}"; do
      p_trimmed=$(echo "$p" | tr -d ' ')
      [[ -n "$p_trimmed" ]] && NEEDS_PAIRS["$CURRENT_JOB:$p_trimmed"]=1
    done
  elif [[ -n "$CURRENT_JOB" ]] && [[ "$line" =~ ^[[:space:]]+needs:[[:space:]]+([a-zA-Z][a-zA-Z0-9_-]*)[[:space:]]*$ ]]; then
    parent="${BASH_REMATCH[1]}"
    NEEDS_PAIRS["$CURRENT_JOB:$parent"]=1
  fi
done < "$WORKFLOW"

[[ ${#YML_JOBS[@]} -eq 0 ]] && fail "ci.yml: cero jobs detectados bajo 'jobs:' · shape inesperado"

ok "ci.yml: ${#YML_JOBS[@]} jobs detectados · ${#NEEDS_PAIRS[@]} dependencias 'needs:' parseadas"

# ---------------------------------------------------------------------
# 4. Verificar invariante de orden topológico
# ---------------------------------------------------------------------

errs=0
checked=0
for pair in "${!NEEDS_PAIRS[@]}"; do
  child="${pair%%:*}"
  parent="${pair##*:}"

  # Skip jobs CI-only (no en ALL_JOBS · ej: infra-flujo-warnings)
  [[ -z "${LOCAL_IDX[$child]:-}" ]] && continue
  [[ -z "${LOCAL_IDX[$parent]:-}" ]] && continue

  c_idx="${LOCAL_IDX[$child]}"
  p_idx="${LOCAL_IDX[$parent]}"

  checked=$((checked + 1))

  if [[ $p_idx -ge $c_idx ]]; then
    echo "❌ paridad rota: '$child' (ALL_JOBS idx $c_idx) needs '$parent' (idx $p_idx) · parent debe preceder child" >&2
    errs=$((errs + 1))
  else
    ok "'$parent' (idx $p_idx) precede '$child' (idx $c_idx)"
  fi
done

[[ $checked -eq 0 ]] && fail "cero pares (child needs: parent) chequeados · revisar parseo de ci.yml + ALL_JOBS"

[[ $errs -gt 0 ]] && fail "$errs paridades rotas entre ALL_JOBS y ci.yml needs: · regla #34"

echo ""
echo "✓ Paridad de orden de jobs OK · $checked pares verificados · regla #34 satisfecha"
exit 0
