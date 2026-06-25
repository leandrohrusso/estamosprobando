#!/usr/bin/env bash
# =====================================================================
# local-ultrareview-preflight.sh · Gate liviano pre-spawn de los 9
# agentes Opus paralelos del skill /revisar (paso 4 del flujo de 6 pasos)
# =====================================================================
#
# QUÉ HACE:
#   Gate determinístico de 6 jobs secuenciales rápidos (~30s típico):
#   - Jobs 1-4: 4 invariantes pre-check del estado del repo
#     (working tree limpio · branch ≠ main · main existe · diff vs main).
#   - Jobs 5-6: 2 gates de código (typecheck + build).
#   Si algún job rompe, ABORTA con exit 1 + mensaje contextual con
#   acción concreta sugerida.
#
# POR QUÉ EXISTE:
#   El skill /revisar spawnea 9 agentes Opus paralelos (~5-10 min wall
#   time · ~$5/run en consolidator). Si typecheck o build rompe, NO
#   tiene sentido pagar el spawn de los agentes (revisarían código
#   roto · señal degradada). Este preflight aborta temprano si el
#   código no compila · ahorro neto ~$5/run.
#
# DIFERENCIA CRÍTICA CON local-ci.sh:
#   - local-ci.sh es el gate COMPLETO del paso 6 /entregar (typecheck
#     + lint + build + unit + e2e + sql · paridad con CI remoto · ~1-15
#     min wall time según tamaño de suite e2e del proyecto).
#   - Este script es el gate LIVIANO del paso 4 /revisar (typecheck +
#     build solamente · ~30s típico · cero e2e/lint/sql).
#   - Los 2 gates tienen scopes distintos del flujo de 6 pasos · NO se
#     mezclan · usar el script equivocado degrada el flujo (e2e lento
#     en preflight bloquea agentes Opus innecesariamente).
#
# CUÁNDO SE INVOCA:
#   skill /revisar paso 1 (después del Paso 0 self-check fatiga + 0.6
#   leer agents-applicability.yml).
#
# OUTPUT:
#   - stdout en vivo (visible durante ejecución).
#   - Archivo persistente: tmp/local-ultrareview-preflight-<TS>.txt
#     (path es contractual · referenciado por SKILL /revisar líneas 123
#     · 140 · 196 · 262 · NO renombrar sin actualizar el SKILL).
#   - Exit 0 si los 6 jobs verdes · exit 1 con mensaje contextual si
#     algún job rojo.
#
# ADAPTACIÓN AL STACK DEL PROYECTO:
#   Los jobs 5 (typecheck) y 6 (build) tienen comandos default para
#   Node/Next.js (`npm run typecheck` · `npm run build`). Si el stack
#   del proyecto es distinto (Python · Go · Rust · etc), adaptar los
#   comandos en las líneas marcadas con `TODO · adaptar al stack`.
#   Los jobs 1-4 son git-only · funcionan para CUALQUIER stack.
#
# INVARIANTE DE PARIDAD:
#   Este script NO duplica jobs de local-ci.sh · sus jobs 5-6 son
#   subset de los jobs de local-ci.sh (typecheck + build). Si cambia
#   el comando de typecheck o build en local-ci.sh, sincronizar acá
#   en el mismo commit (cero drift entre los 2 scripts).
#
# =====================================================================

set -euo pipefail

# ──────────────────────────────────────────────────────────────────────
# Helpers de output coloreado (paridad estructural con local-ci.sh)
# ──────────────────────────────────────────────────────────────────────

green() { echo -e "\033[0;32m$*\033[0m"; }
yellow() { echo -e "\033[0;33m$*\033[0m"; }
red() { echo -e "\033[0;31m$*\033[0m" >&2; }

# ──────────────────────────────────────────────────────────────────────
# Setup · directorio tmp/ + timestamp + redirección a archivo persistente
# ──────────────────────────────────────────────────────────────────────

mkdir -p tmp
TS=$(date -u +%Y-%m-%dT%H-%M-%SZ)
OUT="tmp/local-ultrareview-preflight-${TS}.txt"

# Redirige stdout + stderr a archivo (vía tee · sigue visible en consola).
exec > >(tee "$OUT") 2>&1

# ──────────────────────────────────────────────────────────────────────
# Header del preflight
# ──────────────────────────────────────────────────────────────────────

echo "======================================================================"
echo "/revisar preflight · gate liviano pre-spawn 9 agentes Opus"
echo "======================================================================"
echo "Timestamp:  ${TS}"
echo "Output:     ${OUT}"
echo "Branch:     $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
echo "HEAD:       $(git rev-parse --short HEAD 2>/dev/null || echo '?')"
echo ""

# ──────────────────────────────────────────────────────────────────────
# JOB 1 · Working tree limpio
# ──────────────────────────────────────────────────────────────────────

echo "▶▶▶ Job 1 · Working tree limpio"
if [ -z "$(git status --porcelain)" ]; then
    green "✓ Job 1 VERDE · cero archivos sin commitear"
    echo ""
else
    red "✗ Job 1 FAIL · working tree sucio (archivos sin commitear)"
    red ""
    red "Acción: cada fase del bucle del paso 3 cierra con commit local."
    red "        Commiteá los cambios pendientes antes de re-correr /revisar."
    red ""
    red "Output: ${OUT}"
    exit 1
fi

# ──────────────────────────────────────────────────────────────────────
# JOB 2 · Branch ≠ main
# ──────────────────────────────────────────────────────────────────────

echo "▶▶▶ Job 2 · Branch ≠ main"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    green "✓ Job 2 VERDE · branch actual: ${CURRENT_BRANCH}"
    echo ""
else
    red "✗ Job 2 FAIL · estás en branch main"
    red ""
    red "Acción: /revisar exige diff vs main · estar EN main no tiene scope."
    red "        Cambiá a la branch del PRP (típicamente dev) y re-correlo."
    red ""
    red "Output: ${OUT}"
    exit 1
fi

# ──────────────────────────────────────────────────────────────────────
# JOB 3 · Base SHA main existe
# ──────────────────────────────────────────────────────────────────────

echo "▶▶▶ Job 3 · Base SHA main existe"
if git rev-parse main >/dev/null 2>&1; then
    MAIN_SHA=$(git rev-parse --short main)
    green "✓ Job 3 VERDE · main resuelve a ${MAIN_SHA}"
    echo ""
else
    red "✗ Job 3 FAIL · main no existe localmente"
    red ""
    red "Acción: git fetch origin main:main"
    red "        Después re-correr /revisar."
    red ""
    red "Output: ${OUT}"
    exit 1
fi

# ──────────────────────────────────────────────────────────────────────
# JOB 4 · Diff vs main no vacío
# ──────────────────────────────────────────────────────────────────────

echo "▶▶▶ Job 4 · Diff vs main no vacío"
DIFF_COUNT=$(git diff main --name-only | wc -l)
if [ "$DIFF_COUNT" -ge 1 ]; then
    green "✓ Job 4 VERDE · ${DIFF_COUNT} archivo(s) en el diff vs main"
    echo ""
else
    red "✗ Job 4 FAIL · diff vs main vacío (cero archivos cambiados)"
    red ""
    red "Acción: /revisar no tiene scope · cero diff que revisar."
    red "        Avanzá con el bucle del paso 3 hasta tener cambios reales."
    red ""
    red "Output: ${OUT}"
    exit 1
fi

# ──────────────────────────────────────────────────────────────────────
# JOB 5 · Typecheck
# ──────────────────────────────────────────────────────────────────────
# TODO · adaptar al stack del proyecto · ejemplos:
#   - Node/TS:  npm run typecheck    (tsc --noEmit)
#   - Python:   mypy .
#   - Go:       go build ./...        (compile-only · sin output binario)
#   - Rust:     cargo check
# ──────────────────────────────────────────────────────────────────────

echo "▶▶▶ Job 5 · Typecheck"
if npm run typecheck; then
    green "✓ Job 5 VERDE · typecheck pasa"
    echo ""
else
    red "✗ Job 5 FAIL · typecheck rojo"
    red ""
    red "Acción: fixear errores de tipo · commitear el fix · re-correr /revisar."
    red ""
    red "Output: ${OUT}"
    exit 1
fi

# ──────────────────────────────────────────────────────────────────────
# JOB 6 · Build
# ──────────────────────────────────────────────────────────────────────
# TODO · adaptar al stack del proyecto · ejemplos:
#   - Next.js:  npm run build        (next build)
#   - Vite:     npm run build
#   - Rails:    bin/rails assets:precompile
#   - Go:       go build -o /dev/null ./...
# ──────────────────────────────────────────────────────────────────────

echo "▶▶▶ Job 6 · Build"
if npm run build; then
    green "✓ Job 6 VERDE · build pasa"
    echo ""
else
    red "✗ Job 6 FAIL · build rojo"
    red ""
    red "Acción: fixear errores de build · commitear el fix · re-correr /revisar."
    red ""
    red "Output: ${OUT}"
    exit 1
fi

# ──────────────────────────────────────────────────────────────────────
# Resumen final
# ──────────────────────────────────────────────────────────────────────

green "======================================================================"
green "✅ Preflight VERDE · 6/6 jobs OK"
green "======================================================================"
echo ""
echo "Próximo paso: /revisar Paso 2 · spawn 9 agentes Opus paralelos."
echo "Output completo del preflight: ${OUT}"
