#!/usr/bin/env bash
# =====================================================================
# fresh-install-canonical-state.sh · invariante mecánico del estado
# canónico que el template workflow-base debe presentar a un proyecto
# recién clonado (via "Use this template" de GitHub o clone + reset).
# =====================================================================
# Cuando alguien adopta el pack workflow-base, espera encontrar un
# estado inicial canónico que el skill `/arrancar` sub-paso 1.b detecta
# como "post-template" para disparar el bootstrap mecánico. Si entre
# commits del workflow-base se filtra cualquier archivo work-in-progress
# (handoffs · PRPs reales · docs de producto · entries en logs · CSVs ·
# memorias específicas de un proyecto · etc), los adopters van a heredar
# polución del repo del template y la experiencia bootstrap rompe.
#
# Este smoke audita el estado canónico de TODAS las carpetas del pack
# en 11 bloques de invariantes mecánicos. Cualquier drift se detecta
# antes del merge a main del template.
#
# Severidad: 🔴 ABORT en job `lint` · paridad con `rules-shape-p8.sh` y
# `skip-ci-not-in-pr-head.sh` · el estado canónico del template es
# contrato público hacia proyectos derivados.
#
# Skip-safe en proyectos DERIVADOS: el smoke se auto-saltea (exit 0)
# cuando '<PROYECTO>' está ausente de CLAUDE.md (señal de bootstrap ya
# aplicado). Así el CI del primer PRP del adopter NO arranca rojo por
# diseño · y el smoke queda wireado al job `lint` sin des-cableo manual.
# En el repo template '<PROYECTO>' siempre está presente → corre full
# (11 bloques). Ver GUARD abajo + paridad con `preflight-environment.sh`.
#
# Memoria fuente: regla [`product-docs-as-bootstrap-sot.md`](../../../.claude/rules/product-docs-as-bootstrap-sot.md)
# § When · regla #22 [`folder-creation-with-readme.md`](../../../.claude/rules/folder-creation-with-readme.md)
# § "Convención de README firmada".
#
# Uso:
#   bash tests/scripts/infra-flujo/fresh-install-canonical-state.sh
#
# Exit 0 si todos los invariantes presentes (repo template) · O skip
# cleanly en repo derivado (bootstrap aplicado) · exit 1 al primer fallo.
# =====================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$REPO_ROOT"

ok() { printf '\033[32m✓ %s\033[0m\n' "$*"; }
fail() { printf '\033[31m✗ %s\033[0m\n' "$*" >&2; exit 1; }
section() { printf '\n\033[1m== %s ==\033[0m\n' "$*"; }
skip() { printf '\033[33m⚠ %s\033[0m\n' "$*"; exit 0; }

# =====================================================================
# Helper · auditar carpeta "vacía al boot del template": solo permite
# README.md y _template.md (cualquier otro archivo es intruso).
# =====================================================================
assert_folder_only_readme_and_template() {
    local folder="$1"
    local intrusos
    intrusos=$(find "$folder" -maxdepth 1 -type f -not -name "README.md" -not -name "_template.md" 2>/dev/null || true)
    if [ -n "$intrusos" ]; then
        fail "Carpeta '$folder' tiene archivos intrusos (solo se permite README.md + _template.md):
$intrusos"
    fi
}

# =====================================================================
# Helper · auditar carpeta con seed canónico exacto · count obligatorio
# =====================================================================
assert_folder_file_count_at_least() {
    local folder="$1"
    local min_count="$2"
    local label="$3"
    local actual
    actual=$(find "$folder" -maxdepth 1 -type f | wc -l)
    [ "$actual" -ge "$min_count" ] || fail "$label · '$folder' tiene $actual archivos · esperaba ≥$min_count"
}

# =====================================================================
# GUARD · skip-safe en proyectos DERIVADOS (bootstrap ya aplicado)
# =====================================================================
# Este smoke defiende el estado canónico que SOLO el repo template
# workflow-base debe mantener. En un proyecto derivado el bootstrap
# (skill `/arrancar` sub-paso 1.b) llena legítimamente los placeholders
# (<PROYECTO> → nombre real · BUSINESS_LOGIC.md · primeros PRPs · product
# docs · entries en log.md · etc), por lo que los 11 bloques fallarían
# POR DISEÑO. Para que el CI del PRIMER PRP del adopter NO arranque rojo,
# el smoke se auto-saltea al detectar estado derivado · queda wireado al
# job `lint` y se auto-gestiona (cero des-cableo manual por adopter).
#
# Heurística: el placeholder '<PROYECTO>' en CLAUDE.md (línea 1) es el
# mismo marcador de "estado post-template" que `/arrancar` sub-paso 1.b
# usa para detectar bootstrap pendiente (regla #36
# product-docs-as-bootstrap-sot.md). Lógica:
#   · '<PROYECTO>' PRESENTE → repo template (o derivado con bootstrap
#     INCOMPLETO) → corre full · flaggea cualquier drift · CORRECTO.
#   · '<PROYECTO>' AUSENTE  → bootstrap aplicado (repo derivado) → skip
#     cleanly con exit 0 · estado canónico es contrato del template.
#
# Paridad skip-safe con `preflight-environment.sh` (skip sin
# TEST_DATABASE_URL) · ver README.md de esta carpeta.
# =====================================================================
if [ ! -f CLAUDE.md ] || ! grep -q "<PROYECTO>" CLAUDE.md 2>/dev/null; then
    skip "skip · proyecto derivado (bootstrap aplicado · '<PROYECTO>' ausente de CLAUDE.md) · el estado canónico fresco es contrato del repo template workflow-base, NO del proyecto derivado"
fi

# =====================================================================
# BLOQUE A · Archivos root canónicos presentes
# =====================================================================
section "Bloque A · Archivos root canónicos"
ROOT_FILES=(
    "CLAUDE.md"
    "BUSINESS_LOGIC.md"
    "WORKFLOW.md"
    "README.md"
    ".gitignore"
    ".markdownlint.json"
    ".yamllint"
    "package.json"
)
for f in "${ROOT_FILES[@]}"; do
    [ -f "$f" ] || fail "Archivo root canónico falta: $f"
done
ok "Archivos root canónicos presentes (${#ROOT_FILES[@]} archivos)"

# =====================================================================
# BLOQUE B · Estado post-template detectable por sub-paso 1.b del /arrancar
# =====================================================================
section "Bloque B · Estado post-template (sub-paso 1.b)"

grep -q "<PROYECTO>" CLAUDE.md \
    || fail "Placeholder '<PROYECTO>' ausente de CLAUDE.md · sub-paso 1.b NO detectaría post-clone"

placeholders_business=$(grep -cE "<ej:|TODO|placeholder|<PROYECTO>" BUSINESS_LOGIC.md || true)
[ "$placeholders_business" -ge 3 ] \
    || fail "BUSINESS_LOGIC.md tiene $placeholders_business placeholders · esperaba ≥3"

prp_count=$(find .claude/PRPs -name "PRP-*.md" -not -name "_template.md" 2>/dev/null | wc -l)
[ "$prp_count" = "0" ] \
    || fail ".claude/PRPs/ tiene $prp_count PRPs reales · esperaba 0"

product_docs=$(find docs/product/references -maxdepth 1 -type f -name "*.md" -not -name "README.md" 2>/dev/null | wc -l)
[ "$product_docs" = "0" ] \
    || fail "docs/product/references/ tiene $product_docs docs reales · esperaba 0"

ok "Estado post-template canónico (4/4 invariantes · $placeholders_business placeholders · 0 PRPs · 0 product docs)"

# =====================================================================
# BLOQUE C · Carpetas "vacías al boot del template" (solo README + _template)
# =====================================================================
section "Bloque C · Carpetas vacías al boot del template"

FOLDERS_EMPTY=(
    ".claude/memory/project"
    ".claude/memory/reference"
    ".claude/memory/user"
)
for d in "${FOLDERS_EMPTY[@]}"; do
    assert_folder_only_readme_and_template "$d"
done
ok "Carpetas vacías al boot OK (${#FOLDERS_EMPTY[@]} carpetas · solo README + _template)"

# .claude/memory/_archive/ permite SOLO README.md (sin _template.md)
archive_intrusos=$(find .claude/memory/_archive -maxdepth 1 -type f -not -name "README.md" 2>/dev/null || true)
[ -z "$archive_intrusos" ] || fail ".claude/memory/_archive/ tiene archivos intrusos (solo se permite README.md al boot):
$archive_intrusos"
ok ".claude/memory/_archive/ solo tiene README.md (cero archivos archivados al boot)"

# .claude/PRPs/ permite README.md + prp-base.md (template canónico de PRP ·
# referenciado por /planificar y /planificar-simple · NO existe _template.md acá)
prps_intrusos=$(find .claude/PRPs -maxdepth 1 -type f -not -name "README.md" -not -name "prp-base.md" 2>/dev/null || true)
[ -z "$prps_intrusos" ] || fail ".claude/PRPs/ tiene archivos intrusos (solo se permite README.md + prp-base.md):
$prps_intrusos"
ok ".claude/PRPs/ solo tiene README.md + prp-base.md (template canónico) · cero PRPs reales"

# =====================================================================
# BLOQUE D · Carpetas con seed canónico (counts mínimos del pack)
# =====================================================================
section "Bloque D · Carpetas con seed canónico"

# .claude/memory/feedback/ · 15 memorias seed + README + _template = ≥17
assert_folder_file_count_at_least ".claude/memory/feedback" 17 "Seed feedback memorias"
# .claude/rules/ · 37 reglas firmes + README = ≥38
assert_folder_file_count_at_least ".claude/rules" 38 "Seed reglas firmes"
# .claude/references/external-doctrine/ · 7 doctrinales + README = ≥8
assert_folder_file_count_at_least ".claude/references/external-doctrine" 8 "Seed doctrinales"
# .claude/skills/ raíz · README ≥1
assert_folder_file_count_at_least ".claude/skills" 1 "Seed skills raíz"
# .claude/skills/revisar/agents/ · 9 agentes domain-tight + universales
assert_folder_file_count_at_least ".claude/skills/revisar/agents" 9 "Seed agentes /revisar"
# .claude/skills/revisar-main/agents/ · 9 agentes
assert_folder_file_count_at_least ".claude/skills/revisar-main/agents" 9 "Seed agentes /revisar-main"
# .claude/skills/planificar/agents/ · 4 agentes + README = ≥5
assert_folder_file_count_at_least ".claude/skills/planificar/agents" 5 "Seed agentes /planificar"
# .claude/skills/validar/references/ · 3 archivos
assert_folder_file_count_at_least ".claude/skills/validar/references" 3 "Seed references /validar"
# scripts/ · 5 scripts del pack
assert_folder_file_count_at_least "scripts" 5 "Seed scripts del pack"
# tests/scripts/infra-flujo/ · 1 README + N smokes (≥7 con el smoke nuevo)
assert_folder_file_count_at_least "tests/scripts/infra-flujo" 7 "Seed smokes infra-flujo"
# .husky/ · 4 hooks
assert_folder_file_count_at_least ".husky" 4 "Seed hooks Husky"
# .claude/config/ · README + agents-applicability.yml
assert_folder_file_count_at_least ".claude/config" 2 "Seed config del pack"
# docs/product/references/rules/ · README + 2 templates
assert_folder_file_count_at_least "docs/product/references/rules" 3 "Seed reglas del producto (templates)"

ok "Carpetas con seed canónico cumplen counts mínimos (13 carpetas verificadas)"

# =====================================================================
# BLOQUE E · Archivos seed obligatorios individuales
# =====================================================================
section "Bloque E · Archivos seed obligatorios"

SEED_FILES=(
    ".claude/memory/MEMORY.md"
    ".claude/memory/log.md"
    ".claude/memory/feedback/_template.md"
    ".claude/memory/feedback/README.md"
    ".claude/memory/project/_template.md"
    ".claude/memory/reference/_template.md"
    ".claude/memory/user/_template.md"
    ".claude/config/agents-applicability.yml"
    ".claude/PRPs/README.md"
    ".claude/skills/README.md"
    ".claude/rules/README.md"
    "docs/logs/deadlines.md"
    "docs/logs/technical-debt.md"
    "docs/logs/ultrareview-log.md"
    "docs/product/product-roadmap.md"
    "scripts/archive-log.sh"
    "scripts/lint-memory.sh"
    "scripts/local-ci.sh"
    "scripts/local-ultrareview-preflight.sh"
    "scripts/sync-dev-after-squash-merge.sh"
    ".husky/commit-msg"
    ".husky/post-commit"
    ".husky/pre-commit"
    ".husky/pre-push"
    ".github/workflows/ci.yml"
)
for f in "${SEED_FILES[@]}"; do
    [ -f "$f" ] || fail "Archivo seed obligatorio falta: $f"
done
ok "Archivos seed obligatorios presentes (${#SEED_FILES[@]} archivos)"

# =====================================================================
# BLOQUE F · Frontmatters de memorias seed (type: feedback)
# =====================================================================
section "Bloque F · Frontmatters memorias seed"

memorias_count=0
for f in .claude/memory/feedback/*.md; do
    bn=$(basename "$f")
    [ "$bn" = "_template.md" ] && continue
    [ "$bn" = "README.md" ] && continue
    head -1 "$f" | grep -q "^---$" \
        || fail "Memoria seed $bn falta apertura frontmatter '---' en línea 1"
    head -10 "$f" | grep -q "^type: feedback$" \
        || fail "Memoria seed $bn falta 'type: feedback' en frontmatter"
    head -10 "$f" | grep -q "^name: " \
        || fail "Memoria seed $bn falta 'name:' en frontmatter"
    head -10 "$f" | grep -q "^description: " \
        || fail "Memoria seed $bn falta 'description:' en frontmatter"
    memorias_count=$((memorias_count + 1))
done
[ "$memorias_count" -ge 15 ] \
    || fail "Conteo memorias seed insuficiente · $memorias_count · esperaba ≥15"
ok "Frontmatters memorias seed válidos ($memorias_count memorias · type=feedback + name + description)"

# =====================================================================
# BLOQUE G · log.md sin entries reales (template intacto)
# =====================================================================
section "Bloque G · log.md sin entries reales"

log_entries=$(grep -c "^## \[" .claude/memory/log.md || true)
[ "$log_entries" = "0" ] \
    || fail ".claude/memory/log.md tiene $log_entries entries reales (^## [YYYY-MM-DD]) · template debe arrancar sin cronología"
ok ".claude/memory/log.md sin entries reales · template intacto"

# =====================================================================
# BLOQUE H · docs/logs/* con tablas de datos vacías (scaffolding)
# =====================================================================
section "Bloque H · docs/logs/* tablas vacías"

# technical-debt.md · cero filas DT-NNN reales (excluir ejemplo dummy <DT-NNN> con angle brackets)
dt_real=$(grep -cE "^\| DT-[0-9]+ \|" docs/logs/technical-debt.md || true)
[ "$dt_real" = "0" ] \
    || fail "docs/logs/technical-debt.md tiene $dt_real DTs reales · template debe arrancar sin deudas"

# deadlines.md · § Histórico con cero filas de ejecuciones reales
deadlines_hist_lines=$(awk '/^## § Histórico/,0' docs/logs/deadlines.md | grep -cE "^\| (Lint|Audit|Archivado|/revisar)" || true)
[ "$deadlines_hist_lines" = "0" ] \
    || fail "docs/logs/deadlines.md § Histórico tiene $deadlines_hist_lines ejecuciones reales · template debe arrancar sin histórico"

# ultrareview-log.md · cero entradas UR-NNN reales
ur_entries=$(grep -cE "^### UR-[0-9]+" docs/logs/ultrareview-log.md || true)
[ "$ur_entries" = "0" ] \
    || fail "docs/logs/ultrareview-log.md tiene $ur_entries entradas UR-NNN reales · template debe arrancar sin ultrareviews"

ok "docs/logs/* con tablas de datos vacías (technical-debt: 0 DTs · deadlines histórico: 0 ejecuciones · ultrareview-log: 0 UR-NNN)"

# =====================================================================
# BLOQUE I · Permisos +x de scripts del pack
# =====================================================================
section "Bloque I · Permisos +x scripts"

missing_x=0
missing_files=()
for f in scripts/*.sh tests/scripts/infra-flujo/*.sh; do
    if [ ! -x "$f" ]; then
        missing_x=$((missing_x + 1))
        missing_files+=("$f")
    fi
done
if [ "$missing_x" -gt 0 ]; then
    fail "Scripts sin permiso +x: ${missing_files[*]}"
fi

# Husky hooks ejecutables
for hook in .husky/commit-msg .husky/post-commit .husky/pre-commit .husky/pre-push; do
    [ -x "$hook" ] || fail "Hook Husky sin +x: $hook"
done

ok "Permisos +x OK (scripts/ + tests/scripts/infra-flujo/ + .husky/)"

# =====================================================================
# BLOQUE J · READMEs de carpetas canónicas (regla #22)
# =====================================================================
section "Bloque J · READMEs de carpetas canónicas"

READMES=(
    ".claude/rules/README.md"
    ".claude/skills/README.md"
    ".claude/memory/README.md"
    ".claude/memory/feedback/README.md"
    ".claude/memory/project/README.md"
    ".claude/memory/reference/README.md"
    ".claude/memory/user/README.md"
    ".claude/memory/_archive/README.md"
    ".claude/PRPs/README.md"
    ".claude/config/README.md"
    ".claude/references/external-doctrine/README.md"
    ".claude/skills/planificar/agents/README.md"
    ".claude/skills/revisar-main/README.md"
    "tests/scripts/infra-flujo/README.md"
    "docs/product/references/README.md"
    "docs/product/references/rules/README.md"
)
for r in "${READMES[@]}"; do
    [ -f "$r" ] || fail "README de carpeta canónica falta: $r (regla #22)"
done
ok "READMEs de carpetas canónicas presentes (${#READMES[@]} READMEs · regla #22)"

# =====================================================================
# BLOQUE K · Workspace gitignored del agente (WIP del meta-work del template)
# =====================================================================
section "Bloque K · Workspace gitignored del agente"

# Carpeta existe + README presente
[ -d ".claude/_workspace" ] || fail "Carpeta .claude/_workspace/ falta (convención workspace gitignored)"
[ -f ".claude/_workspace/README.md" ] || fail ".claude/_workspace/README.md falta (regla #22 + convención workspace)"

# git ls-files retorna SOLO el README (cero archivos efímeros commiteados por error)
tracked_workspace=$(git ls-files .claude/_workspace/ 2>/dev/null || true)
expected_workspace=".claude/_workspace/README.md"
if [ "$tracked_workspace" != "$expected_workspace" ]; then
    fail ".claude/_workspace/ tiene archivos efímeros commiteados al template (solo se permite README.md tracked):
Tracked actual: $tracked_workspace
Esperado: $expected_workspace"
fi

# Verificar patrón .gitignore correcto
grep -qE '^\.claude/_workspace/\*' .gitignore \
    || fail ".gitignore falta patrón '.claude/_workspace/*' (sin esto el workspace NO está gitignored)"
grep -qE '^!\.claude/_workspace/README\.md' .gitignore \
    || fail ".gitignore falta excepción '!.claude/_workspace/README.md' (sin esto el README también queda ignorado)"

ok "Workspace gitignored OK (README seed canónico tracked + cero efímeros commiteados + patrón .gitignore correcto)"

# =====================================================================
# CIERRE
# =====================================================================
echo
ok "Estado canónico de instalación fresca del template OK · 11/11 bloques verdes (TODAS las carpetas auditadas + workspace gitignored)"
