---
name: routing-paths-in-english
description: Path segments y filenames del framework (Next.js App Router · equivalente) SIEMPRE en inglés · convención universal de la industria · facilita SEO i18n + evita bikeshedding por PR · slugs generados por usuarios siguen siendo libres
type: rule
applies-to: src/app/ + Server Actions + endpoints + filenames de page.tsx/route.ts (o equivalente del framework del proyecto)
---

## Overview

> ⚙️ **Stack adaptation banner:** esta regla es **stack-tight industria-estándar universal** · aplica a todo framework moderno de routing (Next.js · Rails · Django · Laravel · Sinatra · Express · etc) cuya documentación oficial y ecosistema de tutoriales viven en inglés. NO requiere adaptación per-stack · la convención es la misma a través de ecosistemas. Si tu proyecto usa un stack distinto, la regla SIGUE aplicando · solo cambia el path concreto del routing dir.

> **Path segments y filenames del framework: SIEMPRE en inglés.**
> **Slugs generados por usuarios: contenido libre (input del usuario final).**

**Por qué esta regla existe:** convención universal de la industria (Next.js · Rails · Django · Laravel · etc el routing canónico se documenta y se enseña en inglés) + facilita SEO i18n futuro + evita bikeshedding en cada PR + reduce errores cuando un módulo crece y aparecen rutas vecinas (la primera marca el patrón · si arranca en otro idioma, la consistencia se rompe a la segunda ruta).

> **Nota sobre el idioma de la UI:** esta regla cubre **solo el path/filename**. El idioma del **copy de UI** (labels · placeholders · mensajes de error · headings) lo define la regla de localización del proyecto — típicamente el idioma del producto (español · português · inglés · etc). Las dos reglas son ortogonales: routing en inglés industria-estándar + copy en idioma del producto. Ver agente `i18n` del skill `/revisar` para verificación de consistencia.

## When

**Aplica a:**

- Path segments del App Router (`src/app/<segment>/page.tsx` · o equivalente del framework).
- Filenames de `page.tsx` / `route.ts` / `layout.tsx` (o equivalente).
- Nombres de directorios bajo `src/app/` (o equivalente del routing dir del proyecto).
- Nombres de Route Handlers (`src/app/api/...` · `pages/api/...` · etc).
- Nombres de Server Actions exportadas y de archivos `actions.ts` (o equivalente).

**Ejemplos correctos (industria-estándar inglés):**

- `/login`, `/signup`, `/forgot-password`, `/update-password`, `/select-organization`
- `/events`, `/events/new`, `/events/[id]/edit` (sin importar que el copy de UI sea "Eventos" · "Nuevo evento" · "Editar")
- `/api/events/external/[id]/track-click`
- `/orders/[id]/refund`, `/team/invite`, `/coupons/new`

**Ejemplos incorrectos (NO HACER):**

- ❌ `/eventos/nuevo`, `/equipo/invitar`, `/cupones/nuevo` (path en idioma del producto).
- ❌ Mezclar idiomas en una misma ruta (`/events/nuevo`).
- ❌ Action namespaces en idioma del producto (`evento.creado` · usar `event.created` en `snake_case` inglés).

**NO aplica a (siguen en idioma del producto · regla ortogonal de localización):**

- Copy de UI: `<h1>Eventos</h1>`, `<button>Nuevo evento</button>`, `<p>Editar</p>` (idioma del producto).
- Labels de form, placeholders, hints, mensajes de error mostrados al usuario.
- Comentarios en código (idioma del producto · vos/voseo · usted · etc según el proyecto).
- Slugs generados por usuarios finales (ej: `productores/festival-de-verano` · contenido libre del usuario).

## Process

**Antes de crear una ruta nueva:**

1. Decidir el segment en inglés desde el primer commit (no como rename "para después").
2. Si encontrás un módulo histórico del repo con paths en otro idioma: renombrar el directorio + find/replace en strings de TS/TSX en el mismo PRP. Trabajo mecánico de minutos.
3. El copy del `<h1>` o `<button>` que apunta a esa ruta queda en el idioma del producto (regla ortogonal de localización): la ruta es inglés, el texto que el usuario ve es el idioma del producto.

**Si descubrís una ruta fuera de la regla durante un PRP:**

1. Frenar antes de agregar más rutas al módulo (cada nueva ruta amplifica el costo del rename).
2. Renombrar el directorio (`mv src/app/<idioma> src/app/<inglés>`).
3. `grep -rln "/<idioma>" src/` y reemplazar cada referencia.
4. Validar: typecheck + build + spec del módulo verde.
5. Documentar en el PRP § Aprendizajes que se hizo el rename.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "El módulo histórico está en otro idioma, lo dejo así por consistencia" | NO. La consistencia se logra renombrando el módulo histórico, no propagando el anti-pattern. Cada nueva ruta fuera del estándar aumenta el costo del rename futuro. |
| "Es una ruta interna del backoffice, no se ve" | NO. La regla aplica a TODO segment del App Router. Inconsistencia parcial es peor que estándar único · rompe predictibilidad para el próximo dev que toque el módulo. |
| "Ya escribí el feature, lo dejo y renombro en otro PRP" | NO. El "otro PRP" no llega. El rename cuesta minutos hoy y es bloqueante de cualquier feature que apunte a esa ruta mañana. |
| "Mi proyecto no es internacional, no necesito SEO i18n" | NO. La regla aplica igualmente por consistencia industria-estándar + onboarding de devs nuevos + tooling externo (Vercel · Sentry · etc) que asume inglés. El argumento SEO es UN motivo · no el único. |

## Red flags

- 🚩 Estás creando `/<segment-en-idioma-del-producto>` en lugar de `/<segment-inglés>` "porque suena natural en el idioma del producto".
- 🚩 Encontrás un directorio existente fuera del estándar y dudás si renombrarlo "para después".
- 🚩 Estás copiando una traducción del copy de UI a un filename `page.tsx` o un path segment.
- 🚩 Tu Server Action exportada se llama `crearEvento` en lugar de `createEvent`.

## Verification

- [ ] `find src/app -type d` retorna solo paths en inglés (cero segments en otro idioma).
- [ ] Path segments del PR cambian solo en inglés (`grep -E "src/app/<idioma-producto>" diff` → empty).
- [ ] Cada Server Action exportada nueva está en inglés (`createX`, `updateX`, `deleteX` · NO `crearX` · `actualizarX` · `borrarX`).
- [ ] Action namespaces de audit log en `snake_case` inglés (`event.created` · NO `evento.creado`).
- [ ] El copy de UI que apunta a esa ruta sigue en el idioma del producto (regla ortogonal · cero mezcla en filenames).

**Cross-reference firme:**

- Agente operativo: `i18n` del skill [`/revisar`](../skills/revisar/agents/i18n.md) (verificación de consistencia · routing inglés + copy en idioma del producto + naming técnico inglés).
- Hermana operativa: si el proyecto define una regla específica de **localización del copy** (idioma del producto · registro · variante regional) · esa regla vive en `.claude/rules/<copy-localization>.md` o equivalente y se combina con esta (ortogonales).
