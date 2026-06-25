---
name: PRPs grandes acumulan comment noise (banners filename + JSX narration)
description: Durante un bucle agéntico de muchas fases (PRP-NNN tuvo 6+ commits con ~10K líneas insertadas), tendemos a escribir banners explicativos al inicio de cada archivo + comentarios `{/* Hero */}`, `{/* CTA */}` etc. dentro del JSX. Cleanup en Paso 5 (auditoría + /simplify) eliminó ~441 líneas netas en 29 archivos. Este patrón es prevenible si el agente se autocontiene durante el bucle.
type: feedback
---

# Comment noise bulk cleanup en PRPs grandes

> **Nota de adaptación cross-stack:** los ejemplos abajo asumen stack típico del pack (JSX/React/Next.js) · si tu proyecto usa otro stack (Vue · Svelte · Astro · plantillas server-side · etc), adaptá la sintaxis de los comentarios narration (ej: `<!-- Hero -->` en Vue/HTML · `{/* */}` en JSX · `# Section` en plantillas Python). El principio universal (no narrar lo que el código bien nombrado ya dice) aplica a cualquier framework.

**Regla:** durante el bucle agéntico, **NO escribir banners explicativos al inicio de cada archivo nuevo**. El filename + el código bien nombrado ya dicen qué hace. **NO escribir `{/* Topbar */}`, `{/* Hero */}`, `{/* CTA */}` en JSX** — eso narra lo que el código siguiente hace.

**Why:** PRP-NNN generó 33 archivos TS/TSX nuevos con headers banner típicos:

```ts
// =====================================================================
// XYZComponent — descripción larga del PRP-NNN Fase N.
// =====================================================================
// Lee X, hace Y, navega a Z. Mobile-first con safe-area...
// Constraint heredado A1/A2/A3 del adendum...
// =====================================================================
```

Multiplicado por 33 archivos = ~330+ líneas de banners. Más los `{/* Section */}` adentro del JSX = otras ~150 líneas. **Total: ~480 líneas eliminadas en Paso 5.**

Regla firme [`simplicity-first.md`](../../rules/simplicity-first.md) § "cero código basura" ya tiene el principio: *"Default to writing no comments. Only add one when the WHY is non-obvious"*. Pero durante un bucle largo, el agente tiende a escribir banners "para documentar el work" — pattern que NO es necesario porque el git log + el PR description + el PRP ya cuentan eso.

**How to apply:**

1. **Durante el bucle**: si vas a empezar un archivo nuevo, **escribir SOLO** el código. Si necesitás capturar una decisión clave (ej. "DNI regex 7-8 dígitos: A5 del adendum"), **una línea sola** justo antes del statement relevante.
2. **NO escribir** comentarios tipo `{/* Hero */}`, `{/* CTA */}`, `{/* Footer */}` dentro de JSX. El componente arriba ya dice de qué se trata.
3. **NO escribir banners de header** de 5-15 líneas explicando qué hace el archivo. Si el reader necesita contexto profundo, va al PRP.
4. **SÍ escribir comentarios** cuando explican un *WHY no obvio*: gotchas, invariantes ocultos, workarounds, decisiones contraintuitivas. Ejemplos válidos:
   - `// pending_until comes from RPC return (A4); when reached, redirect to fallo as backstop to server-side cron`
   - `// Defense: orden debe pertenecer al event_date_id del path; UUID v4 + this check`
   - `// PostgREST FK shape gotcha (lección postgrest-fk-arrays.md): pickOne aplana`
5. **Test antes de mergear**: si removés el comentario, ¿el reader entiende menos? Si NO → el comentario sobra.

**Cleanup masivo en Paso 5 (recomendado al cierre del bucle):**

```bash
# Identificar JSX narration borrable
grep -rn "{/\* " src/ | grep -E "{/\* [A-ZÁÉÍÓÚ][^*]*\*/}"

# Identificar headers banner
grep -B1 -A5 "^// =====" src/ | head -40

# Bulk delete líneas que solo son JSX narration
sed -i -E '/^[[:space:]]*\{\/\* [^*]+\*\/\}[[:space:]]*$/d' file.tsx
```

**Caso histórico (PRP-NNN, branch dev):**

- Auditoría manual + 3 agentes /simplify reportaron comment noise como hallazgo #1.
- Fix aplicado en commit `<hash>`: -441 líneas netas, +120 (los reuse fixes).
- 29 archivos modificados.

**Aplicación en PRPs futuros:**

- PRPs grandes (typically los que tocan múltiples capas del producto · ej: integraciones con providers externos · módulos nuevos · refactors estructurales del frontend) tienden a generar muchos archivos. Aplicar esta disciplina **desde el inicio**, no esperar al cleanup.
- Pre-commit hook (futuro): podría detectar headers banner > N líneas + bloquear.

## Documentación cruzada

- Regla firme [`simplicity-first.md`](../../rules/simplicity-first.md) § "cero código basura" (regla original que codifica el principio "default to no comments unless WHY non-obvious").
- Commit `<hash>` (cleanup masivo PRP-NNN).
- 3 agentes /simplify de Paso 5 PRP-NNN — el agente Quality reportó esto como hallazgo #1.
