---
name: principios-desarrollo-flujo
description: Principios técnicos generales del desarrollo · menos es más · simplicidad · poca carga de datos · ahorro de queries · performance · seguridad. Parte FLUJO del split MIXTA principios-desarrollo.
type: rule
applies-to: cualquier acción de codeo · diseño de UI · diseño de schema · diseño de queries · endpoints
---

> ⚙️ **Stack adaptation banner:** la sección 6 (Seguridad valorada · abajo en § Process) asume stack con **BD relacional + RLS** (ej: PostgreSQL/Supabase). Si tu proyecto usa otro stack (Firebase · MongoDB · GraphQL · ORMs como Prisma/TypeORM/Drizzle), adaptá los mecanismos: el principio (defensa en capas · cero exposure cross-tenant · auditoría de acciones sensibles) es universal · la implementación (`RLS` · `organization_id`) es un patrón concreto · reemplazá por el equivalente de tu stack (ej: rules de Firestore · middleware de auth · row-level filtering en GraphQL resolvers).

## Overview

> **Principios técnicos firmes para todo el desarrollo:** menos es más · simplicidad · flujo simple · poca carga de datos en pantalla · ahorro de queries y recursos · performance valorada · seguridad valorada.

**Por qué firme:** cita textual del user (upstream): *"Como política: menos es más, simplicidad y flujo simple, poca carga de datos en pantalla, ahorro de querys y recursos en general, se valora performance y seguridad."* Estos 6 principios atraviesan toda decisión técnica del flujo de desarrollo · se aplican antes de escribir código y al revisar diff antes del commit.

**Nota:** este archivo es la parte FLUJO del split MIXTA del legacy `principios-desarrollo.md`. La parte PRODUCTO (regla de oro stock fundamental) vive en [docs/product/references/rules/principios-producto.md](../../docs/product/references/rules/principios-producto.md).

## When

**Aplica a:**

- Diseño de cualquier feature nueva (antes de implementar).
- Diseño de schema (tablas · campos · relaciones).
- Diseño de queries (SELECT · JOIN · indexes).
- Diseño de UI (cuántos KPIs · cuántas columnas · paginación · lazy loading).
- Endpoints públicos y de backoffice (rate limiting · validación · sanitización).
- Code review propio antes del commit.

**NO aplica a:**

- Decisiones del flujo del agente (esas viven en `.claude/rules/` separados como `surgical-changes` · `simplicity-first` · etc).
- Decisiones de scope de feature (esas siguen [`complejidad.md`](./complejidad.md) y [`decisiones-features.md`](./decisiones-features.md)).

## Process

**Los 6 principios técnicos generales:**

### 1. Menos es más

- En cada decisión: *"¿esto se puede hacer con menos? ¿se puede sacar algo?"*.
- Aplica a: features · código · UI · datos · opciones · configuración.

### 2. Simplicidad y flujo simple

- Flujos secuenciales claros · NO menús complejos.
- Cada acción tiene UN propósito principal.
- Si algo necesita explicación larga, está mal diseñado.

### 3. Poca carga de datos en pantalla

- Listas paginadas · NO infinitas.
- Solo mostrar las columnas/campos importantes por default.
- Detalle se ve al click · NO por default.
- Dashboards: 3-5 KPIs clave · NO 20.

### 4. Ahorro de queries y recursos

- Una query bien hecha > 10 queries pequeñas.
- Evitar N+1 queries (usar joins · includes apropiados).
- Caché razonable cuando aplique (ej: datos del cliente/owner que no cambian seguido).
- Lazy loading de imágenes y datos no críticos.
- Indexar columnas usadas en WHERE / JOIN.
- Limit en queries siempre (nunca `SELECT *` sin límite).

### 5. Performance valorada

- Tiempos de respuesta <1s en operaciones core.
- Página inicial del cliente final <2s.
- Optimización de imágenes (WebP · sizes apropiados).
- Bundle size razonable (code splitting con Next.js).
- Server components donde aplique.

### 6. Seguridad valorada

- Supabase RLS (Row Level Security) en TODAS las tablas — nada sin RLS.
- Validación con Zod en endpoints + frontend.
- Sanitización de inputs (especialmente texto rich y SVG).
- Rate limiting en endpoints públicos.
- HTTPS obligatorio.
- Variables de entorno para secretos (nunca en código).
- Auditoría: tabla `audit_log` para acciones sensibles (ej: operaciones financieras · modificaciones críticas · eliminaciones).
- No exponer datos de un tenant a otro nunca (ej: en un dominio ticketing sería "datos de un productor a otro" · RLS por `organization_id` o equivalente del stack).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Agrego N+1 queries · es más legible · refactoreamos después" | NO. N+1 escala mal · "después" no llega · y la performance se degrada silenciosamente. La regla es JOIN/include desde el día 1 cuando hay relación clara. |
| "Salto RLS en una tabla porque solo se accede via Server Action con auth check" | NO. RLS en TODAS las tablas — defensa en capas. Si la Server Action falla en un check (bug · refactor mal), RLS es la última red. Sin RLS, el bug expone datos cross-tenant. |
| "Mostrar 15 KPIs en el dashboard porque el cliente 'va a querer ver todo'" (ej: en un dominio ticketing sería el productor pidiendo ver todas las métricas a la vez) | NO. 3-5 KPIs clave · el resto en drill-down. La carga visual mata el foco · contradice "menos es más". |

## Red flags

- 🚩 Query nueva sin LIMIT y sin paginación.
- 🚩 Tabla nueva sin RLS habilitado.
- 🚩 Endpoint público sin rate limiting.
- 🚩 Dashboard con 10+ KPIs en pantalla inicial.
- 🚩 Lista en backoffice sin paginación (renderiza todo).
- 🚩 Imagen sin lazy loading o sin WebP.
- 🚩 Variable de entorno con secret hardcodeada en código.

## Verification

- [ ] RLS habilitado y con policies en cada tabla nueva.
- [ ] Validación Zod en cada endpoint nuevo (server-side · no solo cliente).
- [ ] Queries con LIMIT y paginación.
- [ ] Dashboards con 3-5 KPIs clave (no más).
- [ ] Audit log activo para acciones sensibles del PRP.
- [ ] Variables de entorno para secrets (cero secrets en código).
- [ ] Code review propio aplicó los 6 principios al diff antes del commit.

**Cross-reference firme:**

- Hermana: [docs/product/references/rules/principios-producto.md](../../docs/product/references/rules/principios-producto.md) (parte PRODUCTO del split · regla stock fundamental).
- Refuerza: [`simplicity-first.md`](./simplicity-first.md) · [`surgical-changes.md`](./surgical-changes.md) · [`complejidad.md`](./complejidad.md).
