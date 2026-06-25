#!/usr/bin/env bash
# =====================================================================
# scripts/check-routing-english.sh · Lint automático de rutas del
#   framework en inglés industria-estándar (SoT contractual regla #31
#   `routing-paths-in-english.md`)
# =====================================================================
#
# Stack adaptation banner:
#   Por default este script asume stack Next.js App Router con routing
#   dir bajo `src/app/` + middleware en `src/middleware.ts`. Si tu
#   proyecto usa otro stack (Next.js Pages Router · Remix · Rails · Django
#   · Laravel · Express · Fastify · etc), ajustá las variables
#   ROUTING_DIRS + MIDDLEWARE_FILES al inicio del script. El principio
#   (path segments del framework SIEMPRE en inglés industria-estándar) es
#   universal · cambia solo el path concreto del routing dir.
#
#   Ejemplos por stack:
#     - Next.js App Router (default): ROUTING_DIRS=("src/app")
#     - Next.js Pages Router:          ROUTING_DIRS=("src/pages")
#     - Remix:                          ROUTING_DIRS=("app/routes")
#     - Rails:                          adapter grep sobre config/routes.rb
#     - Django:                         adapter grep sobre <app>/urls.py
#     - Express/Fastify:                routes file del proyecto
#
# Approach:
#   1. Check 1 · directorios con caracteres no-ASCII (acentos · ñ · ç)
#      en routing dir → siempre violación universal (cualquier framework
#      moderno espera ASCII en path segments).
#   2. Check 2 · directorios con nombre de path segment en español
#      (sin acentos · ej: `src/app/eventos/`) → cierra el gap más común
#      de la regla #31 (paths en idioma del producto sin acentos).
#   3. Check 3 · path segments en español hardcoded en contenido de
#      routing dir + middleware files → atrapa strings ej:
#      `redirect('/eventos')` · `router.push('/usuarios')`.
#   4. Whitelist · paths heredados que el adopter NO puede renombrar
#      todavía (DTs activas) · disparador objetivo para cerrar la DT.
#
# Por qué este approach (NO depender de eslint plugins):
#   - El template es stack-agnostic · cero asumir ESLint instalado.
#   - Bash + grep cubren el 90% del valor con cero deps.
#   - El adopter wirea al job `lint` de su CI con 1 línea (`bash
#     scripts/check-routing-english.sh`).
#
# Requiere:
#   - bash · find · grep (built-ins POSIX · cero deps externas).
#
# Uso local:
#   bash scripts/check-routing-english.sh
#   exit 0 = clean · exit 1 = violación detectada
#   exit 0 + skip silencioso si routing dirs no existen (boot del template
#   pre-bootstrap del producto del adopter).
#
# Uso en CI:
#   El adopter wirea este script al job `lint` de su CI (típicamente
#   `.github/workflows/ci.yml` job `lint` · ABORT en fallo · paridad con
#   otros smokes del flow).
#
# Cross-refs firmes:
#   - Regla #31 .claude/rules/routing-paths-in-english.md (SoT contractual)
#   - Agente i18n del skill /revisar (verificación complementaria de
#     consistencia routing inglés + copy en idioma del producto).
# =====================================================================

set -euo pipefail

VIOLATIONS=0
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
RESET=$'\033[0m'

# ─────────────────────────────────────────────────────────────────────
# Stack adaptation · paths del framework (adopter modifica acá)
# ─────────────────────────────────────────────────────────────────────
# Default: Next.js App Router. Ajustar para tu stack (ver banner arriba).
ROUTING_DIRS=("src/app")
MIDDLEWARE_FILES=("src/middleware.ts")

# ─────────────────────────────────────────────────────────────────────
# Whitelist · paths heredados de DTs activas (adopter expande)
# ─────────────────────────────────────────────────────────────────────
# Si tu proyecto tiene paths heredados que NO se pueden renombrar todavía
# (ej: rutas públicas con SEO indexado · contratos con terceros · paths
# de un PRP previo que dejó DT abierta), documentá la DT en
# `docs/logs/technical-debt.md` con disparador objetivo para cerrar el
# rename · y agregá los segments acá.
#
# Formato regex:  '/(path1|path2|path3)(/|$)'
# Vacío por default → cero excepciones al boot del template.
INHERITED_WHITELIST_REGEX=''

# ─────────────────────────────────────────────────────────────────────
# Guard · skip silencioso si routing dirs NO existen todavía
# ─────────────────────────────────────────────────────────────────────
# Al adoptar el template, el proyecto puede no tener `src/app/` creado
# todavía (pre-bootstrap del producto del adopter). Skip para no romper
# CI con `find: No such file or directory`.
EXISTING_ROUTING_DIRS=()
for dir in "${ROUTING_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    EXISTING_ROUTING_DIRS+=("$dir")
  fi
done

if [ ${#EXISTING_ROUTING_DIRS[@]} -eq 0 ]; then
  echo "${YELLOW}⊘ Routing dirs no existen todavía (${ROUTING_DIRS[*]}) · skip · cero violaciones${RESET}"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────
# Check 1: directorios con caracteres no-ASCII (acentos, ñ, ç)
# ─────────────────────────────────────────────────────────────────────
NON_ASCII_DIRS=$(find "${EXISTING_ROUTING_DIRS[@]}" -type d -regex '.*[áéíóúñÁÉÍÓÚÑçÇ].*' 2>/dev/null || true)
if [ -n "$NON_ASCII_DIRS" ]; then
  echo "${RED}✗ Directorios con caracteres no-ASCII en routing dir:${RESET}"
  echo "$NON_ASCII_DIRS"
  echo "  Fix: renombrar a inglés industria-estándar. Regla firme #31 [.claude/rules/routing-paths-in-english.md]."
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# ─────────────────────────────────────────────────────────────────────
# Patrones de palabras en español comunes en rutas SaaS LATAM (universales
# · NO stack-tight ni domain-tight). Adopter puede expandir el set según
# vocabulario del propio rubro (ej: ticketing sumaría 'funciones|cupones'
# · e-commerce sumaría 'carrito|envios' · CRM sumaría 'oportunidades').
# ─────────────────────────────────────────────────────────────────────
SPANISH_WORDS='eventos|usuarios|productos|clientes|pedidos|facturas|pagos|equipo|reportes|ventas|inicio|salir|entrar|registrar|recuperar|configuracion|configuración|ajustes|administracion|administración|panel|tablero|perfil|cuenta|nuevo|editar|eliminar|borrar'

# ─────────────────────────────────────────────────────────────────────
# Check 2: directorios con nombre de path segment en español (sin acentos)
# ─────────────────────────────────────────────────────────────────────
# Cierra el gap del Check 1: `src/app/eventos/` no tiene caracteres no-ASCII
# pero igual viola la regla #31 (path segment en idioma del producto).
SPANISH_DIRS=$(find "${EXISTING_ROUTING_DIRS[@]}" -type d 2>/dev/null \
  | grep -E "/($SPANISH_WORDS)(/|$)" || true)

# Aplicar whitelist heredada si está configurada
if [ -n "$SPANISH_DIRS" ] && [ -n "$INHERITED_WHITELIST_REGEX" ]; then
  SPANISH_DIRS=$(echo "$SPANISH_DIRS" | grep -vE "$INHERITED_WHITELIST_REGEX" || true)
fi

if [ -n "$SPANISH_DIRS" ]; then
  echo "${RED}✗ Directorios con nombre de path segment en español:${RESET}"
  echo "$SPANISH_DIRS"
  echo "  Fix: renombrar a inglés industria-estándar (ej: 'eventos' → 'events' · 'usuarios' → 'users')."
  echo "  Doctrina: .claude/rules/routing-paths-in-english.md"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# ─────────────────────────────────────────────────────────────────────
# Check 3: path segments en español hardcoded en contenido de archivos
# ─────────────────────────────────────────────────────────────────────
# Capturamos el segment completo (slash inicio + palabra + slash/fin/quote)
# para evitar falsos positivos sobre nombres de variables / clases.
SPANISH_SEGMENTS="/($SPANISH_WORDS)(/|$|\"|'|\`)"

# Buscar en routing dirs + middleware files (las únicas surfaces de routing).
SEARCH_TARGETS=("${EXISTING_ROUTING_DIRS[@]}")
for file in "${MIDDLEWARE_FILES[@]}"; do
  [ -f "$file" ] && SEARCH_TARGETS+=("$file")
done

if [ ${#SEARCH_TARGETS[@]} -gt 0 ]; then
  if [ -z "$INHERITED_WHITELIST_REGEX" ]; then
    SPANISH_HITS=$(
      grep -rEn "$SPANISH_SEGMENTS" "${SEARCH_TARGETS[@]}" 2>/dev/null \
        || true
    )
  else
    SPANISH_HITS=$(
      grep -rEn "$SPANISH_SEGMENTS" "${SEARCH_TARGETS[@]}" 2>/dev/null \
        | grep -vE "$INHERITED_WHITELIST_REGEX" \
        || true
    )
  fi

  if [ -n "$SPANISH_HITS" ]; then
    echo "${RED}✗ Path segments en español en routing dirs o middleware:${RESET}"
    echo "$SPANISH_HITS"
    if [ -z "$INHERITED_WHITELIST_REGEX" ]; then
      echo "  Fix: renombrar a inglés industria-estándar. Whitelist vacía (cero excepciones heredadas)."
    else
      echo "  Fix: renombrar a inglés. Whitelist heredada activa: '$INHERITED_WHITELIST_REGEX'."
    fi
    echo "  Doctrina: .claude/rules/routing-paths-in-english.md"
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
fi

# ─────────────────────────────────────────────────────────────────────
# Resultado final
# ─────────────────────────────────────────────────────────────────────
if [ "$VIOLATIONS" -eq 0 ]; then
  echo "${GREEN}✓ Routing en inglés · 0 violaciones${RESET}"
  exit 0
else
  echo
  echo "${YELLOW}Total: $VIOLATIONS check(s) violado(s).${RESET}"
  echo "Doctrina: .claude/rules/routing-paths-in-english.md"
  exit 1
fi
