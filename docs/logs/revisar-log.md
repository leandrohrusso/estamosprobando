# Revisar Log

> Registro de ejecuciones de **[`/revisar`](../../.claude/skills/revisar/SKILL.md)** (multi-agent local code review · 9 agentes Opus paralelos + consolidator) sobre el producto del adopter.
> **Propósito doble:**
> 1. **Bitácora de auditoría** — qué se revisó · cuándo · qué se encontró · qué se hizo con cada hallazgo.
> 2. **Mapa de cobertura** — qué código YA pasó por revisión local · para detectar áreas sistemáticamente sin revisar y evitar runs redundantes.
>
> **Diferencia con [`docs/logs/ultrareview-log.md`](./ultrareview-log.md) (cloud):**
> - **Cloud (`/ultrareview`)**: 3 agentes en VMs aisladas con verificación independiente · costo en dólares por run · selectivo (decisión user en sub-paso 6.◆ del flujo de 6 pasos · paso 6 [`/entregar`](../../.claude/skills/entregar/SKILL.md)).
> - **Local (`/revisar`)**: 9 agentes Opus en `Explore` subagent_type con verificación cruzada por overlap (≥2 detectores → `verified: true`) · gratis · default SÍ siempre en cada PRP del Modo C.
> - **Calibración**: cuando ambos corren sobre el mismo PRP, comparar outputs en § Calibración cross-reference (vs cloud).
>
> **Diferencia con [`docs/logs/revisar-main-log.md`](./revisar-main-log.md) (hermano holístico):**
> - **`/revisar` (este log · paso 4 del flujo del producto)**: 9 agentes auditan el **diff incremental** vs `main` del PRP en curso · contractual · default SÍ siempre en Modo C · scope acotado al cambio.
> - **`/revisar-main` (lint mensual)**: 9 agentes auditan el estado **completo de `main`** · cero diff · scope holístico por familia técnica con planning automático.
> - **Complementarios** · NO sustitutivos.

---

## Cómo se mantiene este archivo

### Cuándo se actualiza

- **Al lanzar `/revisar`** sobre un PRP en Modo C (paso 4 del flujo de 6 pasos · post-[`/implementar`](../../.claude/skills/implementar/SKILL.md) · pre-[`/validar`](../../.claude/skills/validar/SKILL.md)): el consolidator escribe entrada nueva en § Resumen de runs con metadata del run (LR-NNN · timestamp · base/head SHA · scope · counts por severidad) + filas en § Hallazgos consolidados (1 por bug que pasó el filtro Bif 6 = A).
- **Al fixear** un hallazgo (`🔴 pendiente` → `🟢 fixeado`): actualizar estado en § Hallazgos consolidados con commit SHA + link.
- **Al descartar** un hallazgo conscientemente (`🔴 pendiente` → `⚪ descartado`): actualizar estado con motivo (1 frase).
- **Al cierre de un PRP del producto** que tuvo run de `/revisar`: marcar la fila correspondiente en § Decisiones por PRP con resultado final (cuántos hallazgos cerrados antes del merge).
- **REGLA DE ORO docs y memoria** ([`golden-rule-docs-memory.md`](../../.claude/rules/golden-rule-docs-memory.md) ítem 4.7) aplica a este log con timing bidireccional · paridad con `docs/logs/ultrareview-log.md` cloud y `docs/logs/revisar-main-log.md` hermano holístico.

### Antes de correr `/revisar` nuevamente sobre el mismo scope

Revisar § Cobertura antes de invocar el skill. Reglas:

- **Si el rango propuesto está 100% incluido en un run anterior** sin cambios desde · NO re-ejecutar (cero valor marginal).
- **Si el rango se solapa parcialmente** · preferir limitar el nuevo scope a los commits NO cubiertos.
- **Si es un área sensible** (auth · multi-tenancy · pagos · checkout · validación crítica del dominio) · re-revisión periódica está justificada incluso si ya fue revisada · documentar cadencia en § Política de re-revisión.

---

## Convenciones

### Identificadores

- **Local Run ID:** `LR-NNN` ascendente sin reset (LR-001 · LR-002 · ...). Independiente del namespace `UR-NNN` del cloud y del `RM-NNN` de `/revisar-main`.
- **Bug ID:** `lr_bug_NNN` por run (reset a 001 cada run). Si hay ambigüedad cross-run, prefijar con el Run ID (`LR-001/lr_bug_001`).

### Severidades

| Severidad | Significado | Acción esperada |
|---|---|---|
| `critical` | Falla de seguridad · pérdida de datos · RCE · exposición de secretos · invariante quebrada (auth · multi-tenancy · atomicity · payments según constraints del dominio declarados en [`BUSINESS_LOGIC.md § 8`](../../BUSINESS_LOGIC.md)). | **Fix antes del merge** (prioridad 1). Bloquea el camino al paso 6 [`/entregar`](../../.claude/skills/entregar/SKILL.md). |
| `normal` | Bug funcional · regression latente · gap contra criterio del PRP · asimetría cross-módulo. | **Fix antes del merge** (prioridad 2). |
| `nit` | Inconsistencia menor · code smell · defense-in-depth gap · test que faltaba. | **Fix antes del merge** (prioridad 3) **solo si pasa el filtro Bif 6 = A** (≥2 detectores). |

> **Regla FIRME del proyecto** ([`always-fix-all-bugs.md`](../../.claude/rules/always-fix-all-bugs.md)): `critical`, `normal` y `nit` (que pasaron el filtro) se fixean SIEMPRE antes del merge a `main`, en orden de prioridad descendente, con estándar senior y regression-first FIRME (spec antes del fix · ver [`regression-first-on-fix.md`](../../.claude/rules/regression-first-on-fix.md)).

### Marcado `verified` (proxy del "independent verification" del cloud)

- Bug detectado por **≥2 agentes** del run → `verified: true` en metadata.
- El cloud `/ultrareview` reproduce cada bug en VM fresh (verificación independiente real). El local logra señal equivalente vía overlap cross-agent · NO es idéntico pero reduce falsos positivos drásticamente.
- Si solo 1 agente lo detectó y la severidad es `nit` → DESCARTADO (Bif 6 = A · § 4 del consolidator).

### Estados de hallazgo

| Símbolo | Estado | Significado |
|---|---|---|
| 🔴 | `pendiente` | No abordado · sin owner ni PRP asignado. |
| 🟡 | `trackeado` | Incorporado a scope de un PRP/task futuro · linkear PRP. |
| 🟠 | `en progreso` | Fix en desarrollo activo · linkear branch o PRP. |
| 🟢 | `fixeado` | Resuelto · linkear commit SHA + run que verificó (si aplica). |
| ⚪ | `descartado` | Decisión consciente de no fixear · incluir motivo (1 frase). |
| 🟤 | `backlog` | Nit con ≥2 detectores que pasó filtro pero queda diferido (poco frecuente · regla FIRME prefiere fixear todo · usar solo con justificación explícita). |
| ⚫ | `obsoleto` | Quedó sin sentido por refactor / feature removida. |

### Tipos de scope

Cómo se invocó `/revisar`:

- `branch:<rama>` — diff entre rama y `main` (típico · default del skill).
- `pr:<número>` — PR de GitHub (`/revisar 123`).
- `range:<base-sha>..<head-sha>` — rango explícito de commits.

---

## Política de re-revisión

> **Tabla vacía al boot del template.** El adopter llena las filas conforme define áreas sensibles del producto que merecen re-revisión periódica (paridad regla [`pre-validation-inherited-regression.md`](../../.claude/rules/pre-validation-inherited-regression.md) · ejemplos típicos: pagos · auth · multi-tenancy · validación crítica del dominio).

| Área | Cadencia esperada | Justificación |
|---|---|---|
| _(agregar fila cuando el adopter defina área sensible · paridad ejemplos del docstring arriba)_ | — | — |

---

## Decisiones por PRP

> Una fila por PRP del producto que pasa por el paso 4 del flujo de 6 pasos. Default SÍ siempre en Modo C · si se decide NO, justificar en columna "Justificación".

| PRP | Fecha decisión | Decisión | Justificación (1 frase) | Run asociado |
|---|---|---|---|---|
| PRP-002 | 2026-07-03 | SÍ | Área sensible: auth + multi-tenancy + RLS + RPCs SECURITY DEFINER (constraints del dominio en BUSINESS_LOGIC.md § 8). | LR-001 |

### Convenciones de la tabla

- **Decisión:** `SÍ` (camino CON `/revisar`) o `NO` (camino SIN). Default SÍ siempre en Modo C.
- **Justificación:** 1 frase. Si SÍ, qué área sensible disparó. Si NO, por qué se evaluó innecesario (ej: "PRP UI polish · sin BD/auth/dinero" · "área cubierta por LR-NNN sin cambios desde").
- **Run asociado:** LR-NNN si decisión = SÍ. Vacío o `—` si decisión = NO.

---

## Resumen de runs

> 1 fila por run de `/revisar` ejecutado.

| Run | Fecha | PRP | Scope | Base SHA | Head SHA | Archivos | LoC (+/−) | Bugs (C/N/Nit-bl) | Descartados (filtro Bif 6) | Costo est. | Duración | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| LR-001 | 2026-07-03 | PRP-002 | `branch:dev` (diff vs `main`) | e4a9036 | 647df90 | 36 | +1847/−17 | 0 / 8 / 0 | 9 | $0 (local Opus) | — | ✅ cerrado |

---

## Cobertura

### Por área del repo

> Mapa acumulado de qué áreas del repo YA pasaron por revisión local. El adopter define las filas según la estructura de su producto (típicamente paths bajo `src/` · `db/migrations/` · `tests/` · etc).

| Área | Último LR | Fecha | SHA cubierto | Notas |
|---|---|---|---|---|
| `src/app/(auth)/*` · `src/app/auth/confirm/*` · `src/lib/auth/*` | LR-001 | 2026-07-03 | 647df90 | Login magic link · onboarding · sesión/redirect. |
| `src/lib/supabase/*` · `src/proxy.ts` | LR-001 | 2026-07-03 | 647df90 | Cliente SSR + middleware/proxy de sesión. |
| `db/migrations/0001-0003` (organizations · memberships · RLS · helpers · RPCs) | LR-001 | 2026-07-03 | 647df90 | Área sensible auth/multi-tenancy · re-revisión periódica justificada. |
| `src/components/ui/*` (button · input · card · label) | LR-001 | 2026-07-03 | 647df90 | Primitivos UI nuevos (a11y contraste → DT-005). |
| `tests/sql/*` · `tests/e2e/regression/PRP-002-*` | LR-001 | 2026-07-03 | 647df90 | Specs SQL + e2e del PRP. |

### Por PRP

| PRP | Último LR | SHA cubierto | Status |
|---|---|---|---|
| PRP-002 | LR-001 | 647df90 | Fase 1+2 revisadas · Fase 3/4 pendientes por diseño (no en diff). |

### Por rango de commits

| Rango cubierto | Run | Cobertura | Notas |
|---|---|---|---|
| `e4a9036..647df90` | LR-001 | 100% | Commits Fase 1 (`22253a1`) + Fase 2 (`647df90`) del PRP-002. |

---

## Hallazgos consolidados

> 1 fila por bug que pasó el filtro Bif 6 = A del consolidator (`critical` y `normal` siempre · `nit` solo con ≥2 detectores). Los descartados por filtro NO entran a esta tabla pero se contabilizan en § Resumen de runs columna "Descartados".

| Bug ID | Run | Severidad | Verified | Detectores | Archivo:línea | Resumen | Estado | Owner/PRP |
|---|---|---|---|---|---|---|---|---|
| lr_bug_001 | LR-001 | normal | false¹ | multi-tenant | `tests/sql/PRP-002-rls-isolation.sql:8-57` | Aislamiento cross-tenant WRITE-side (mbr_write/org_update owner-gate) sin invariante SQL · solo se testea SELECT | 🟢 fixeado | PRP-002 (fixeado post-LR-001 · regression-first) |
| lr_bug_002 | LR-001 | normal | false¹ | a11y | `src/app/globals.css:78` (`--input`) | Borde del Input ~1.36:1 vs Card blanca (falla SC 1.4.11 UI-component 3:1) | ⚪ diferido | DT-005 (out-of-scope · firma user A) |
| lr_bug_003 | LR-001 | normal | false¹ | a11y | `src/app/globals.css:58` (`--primary`) | Texto del botón primario ~4.32:1 (bajo el 4.5:1 de SC 1.4.3 texto normal) | ⚪ diferido | DT-005 (out-of-scope · firma user A) |
| lr_bug_004 | LR-001 | normal | false¹ | architect | `db/migrations/0003_onboarding_rpcs.sql:31` · `0001:44` | Asimetría de normalización de email: write=raw (`auth.email()`) · read/link/index=`lower()` · dos memberships case-variant pueden coexistir | 🟢 fixeado | PRP-002 (fixeado post-LR-001 · regression-first) |
| lr_bug_005 | LR-001 | normal | false¹ | correctness | `src/lib/auth/session.ts:45` | `getActiveMemberships` swallow de error → `[]`, indistinguible de "sin orgs" → usuario con org puede ir a `/onboarding` ante fallo transitorio | 🟢 fixeado | PRP-002 (fixeado post-LR-001 · regression-first) |
| lr_bug_006 | LR-001 | normal | false¹ | a11y | `src/app/(auth)/login/page.tsx:51-63` · `onboarding-form.tsx:37-50` | Error no asociado al input (sin `aria-invalid`/`aria-describedby`/`id`) · SC 1.3.1/3.3.1 | 🟢 fixeado | PRP-002 (fixeado post-LR-001 · regression-first) |
| lr_bug_007 | LR-001 | normal | false¹ | security | `src/app/(auth)/login/actions.ts:33` (`sendMagicLink`) | Endpoint público de magic link sin rate limiting a nivel app (email-bombing / cuota SMTP) · mitigado por rate-limit del proveedor | ⚪ diferido | DT-004 (out-of-scope · firma user A) |
| lr_bug_008 | LR-001 | normal | false¹ | correctness | `src/app/auth/confirm/route.ts:37` | Resultado de `link_pending_memberships` no inspeccionado: ante fallo, invitado va a `/onboarding` en vez de a su org (hermano de lr_bug_005) | 🟢 fixeado | PRP-002 (fixeado post-LR-001 · regression-first) |

> ¹ `verified: false` = sin overlap cross-agente (cada finding tiene 1 detector · convención § "Marcado verified"). **Todos fueron verificados contra fuente por el consolidator (sub-paso 6.5 · `Read` directo del archivo citado): las 8 afirmaciones coinciden con el código real.** El `false` refleja solo la ausencia de confirmación por ≥2 agentes, no falta de verificación.

---

## Calibración cross-reference (vs cloud)

> Cuando un mismo PRP del producto tiene tanto run local (`/revisar`) como run cloud (`/ultrareview`), comparar outputs acá para calibrar overlap detection vs independent verification.

| PRP | Local Run (LR-NNN) | Cloud Run (UR-NNN) | Hallazgos coincidentes | Hallazgos solo-local | Hallazgos solo-cloud | Notas |
|---|---|---|---|---|---|---|
| _(agregar fila cuando un PRP tenga ambos runs simultáneos)_ | — | — | — | — | — | — |

---

## Apéndice · entradas detalladas por run

> El consolidator del skill agrega sub-secciones `## LR-NNN · YYYY-MM-DD · PRP-NNN` al final del archivo conforme se ejecutan los runs (paridad shape upstream del pack · cada sub-sección incluye Cobertura de agentes + Filtrado Bif 6 + Hallazgos consolidados detalle por bug + Próxima acción recomendada).
>
> **Al boot del template no hay sub-secciones** · el primer run las inaugura.

---

## LR-001 · 2026-07-03 · PRP-002

**Scope:** `branch:dev` · diff vs `main` (`e4a9036..647df90`) · 36 archivos · +1847/−17 · Fase 1 (`22253a1`) + Fase 2 (`647df90`).
**Preflight:** verde 6/6 · `tmp/local-ultrareview-preflight-2026-07-03T00-32-05Z.txt`.
**PRP:** `.claude/PRPs/PRP-002-auth-organizations-memberships-rls.md` (Fase 1+2 · Fase 3/4 pendientes por diseño).

### Cobertura de agentes (9/9 corrieron)

| Agente | Findings crudos | Con hallazgos |
|---|---|---|
| architect | 3 (1 normal · 2 nit) | sí |
| security | 2 (1 normal · 1 nit) | sí |
| multi-tenant | 2 (1 normal · 1 nit) | sí |
| atomicity | 1 (1 nit) | sí |
| tests | 1 (1 nit) | sí |
| correctness | 4 (2 normal · 2 nit) | sí |
| a11y | 4 (3 normal · 1 nit) | sí |
| i18n | 0 | `### No findings` |
| migration-safety | 0 | `### No findings` |

**Total findings crudos:** 17 (8 normal · 9 nit) · **dedupe:** 0 merges (cero solape exacto `file:line` cross-agente · pares vecinos como atomicity:1 L62 vs correctness:3 L64 son bugs distintos · NO match).

### Filtrado Bif 6 = A

- **8 normal → PASAN** (severidad justifica el riesgo de FP independiente del count).
- **9 nit con 1 detector → DESCARTADOS** (cero confirmación cross-agente · filtro contractual · cero excepción por corazonada).

**`discarded_by_filter = 9`** (detalle · viven hasta que ≥2 agentes los detecten en un run futuro):

| # | Agente | Sev | Archivo:línea | Título | Motivo descarte |
|---|---|---|---|---|---|
| 1 | architect | nit | `PRP-002.md:47-56` | G1/G2/G3/G9 cumplidos sin marcar `[x]` (marcado mixto) | nit · 1 detector |
| 2 | architect | nit | `src/app/auth/confirm/route.ts:26-29` | Rama `exchangeCodeForSession` (PKCE) sin caller ni cobertura | nit · 1 detector |
| 3 | security | nit | `db/migrations/0003_onboarding_rpcs.sql:13` | RPC DEFINER no valida forma de `p_slug` en el body (bypass de slugify/Zod vía PostgREST) | nit · 1 detector |
| 4 | multi-tenant | nit | `db/migrations/0002_rls_and_helpers.sql:45` | `GRANT INSERT, DELETE ON organizations` sin policy (desvío least-privilege · RLS default-deny lo bloquea) | nit · 1 detector |
| 5 | atomicity | nit | `src/app/(auth)/onboarding/actions.ts:62` | Retry de slug trata cualquier 23505 como colisión de slug (coupling al schema actual) | nit · 1 detector |
| 6 | tests | nit | specs `PRP-002-*` | Naming MAYÚSCULA divergente del canónico `prp-NNN-` (README + precedente `prp-001-scaffold`) | nit · 1 detector |
| 7 | correctness | nit | `src/app/(auth)/onboarding/actions.ts:64` | Reintento de slug puede generar doble guión (`nombre--2`) al truncar sobre un guión | nit · 1 detector |
| 8 | correctness | nit | `src/lib/auth/session.ts:53` | `org.slug as string` asume org definido (acceso potencial a undefined si el embed llega vacío) | nit · 1 detector |
| 9 | a11y | nit | `src/components/ui/button.tsx:20` · `input.tsx:13` | Altura 40px (h-10) bajo la guía de target táctil 44px (cumple AA 2.5.8) | nit · 1 detector |

> **Nota de calibración:** varios descartados son señalamientos legítimos (naming de specs · `p_slug` sin validar en el body · least-privilege de grants). El filtro Bif 6 = A los difiere por falta de confirmación cross-agente · si reaparecen en un run futuro con ≥2 detectores, pasan. Cero "salvar" señal débil por corazonada (doctrina del consolidator).

### Sub-paso 6.7 · grep doc obsoleta

`git diff main --name-only -- '*.md'` → 7 docs modificados · grep de `diferible|fix oportunista|para próximo PR|deferred|skip por ahora` → **0 matches**. Cero finding agregado.

### Hallazgos consolidados · detalle por bug (8 · todos `normal` · mini-checklist quality-senior 6 puntos)

**lr_bug_001 · normal · confidence high · detectores: [multi-tenant]**
- **Archivo:** `tests/sql/PRP-002-rls-isolation.sql:8-57`
- **Descripción:** el único spec de aislamiento valida solo SELECT (count orgs/memberships ajenas=0). La ruta WRITE (mbr_write/org_update owner-gate) no tiene invariante: no se prueba (a) owner de A escribiendo membership con `organization_id=B`, (b) staff/admin de A escribiendo memberships de su org (owner-gate niega), (c) no-owner UPDATE organizations de otra org.
- **Suggested fix:** agregar escenarios `SET LOCAL ROLE authenticated` + claims de owner A ejecutando `INSERT INTO memberships (organization_id=B)` / `UPDATE organizations WHERE id=B` esperando `ROW_COUNT=0` o error, + escenario miembro no-owner de A.
- **verified:** false (1 detector) · source-verified ✅ (spec solo cubre SELECT). **quality_review: passed** (UUIDs de fixture fijos son canónicos · regla seed-upsert-with-fixed-id · regression-first FIRME).
- **Scope:** IN-SCOPE (test file del propio PRP) → 🔴 pendiente.

**lr_bug_002 · normal · confidence high · detectores: [a11y]**
- **Archivo:** `src/app/globals.css:78` (`--input` #e6ddd3) · usado por `src/components/ui/input.tsx:13`
- **Descripción:** borde del input (único límite visual) vs Card `--card` #ffffff ≈1.36:1 · bajo el 3:1 de WCAG 1.4.11. Campo casi imperceptible en ambos forms.
- **Suggested fix:** oscurecer el token de borde de inputs a ≥3:1 vs `--card` (~#a99e8f o más oscuro).
- **verified:** false (1 detector) · source-verified ✅ (token #e6ddd3 confirmado). **quality_review: passed** (cambio de token · cero hardcode).
- **Scope:** OUT-OF-SCOPE → **DT-005** (`globals.css` vive en PRP-001, NO en el diff · cambio cross-cutting afecta toda la app).

**lr_bug_003 · normal · confidence high · detectores: [a11y]**
- **Archivo:** `src/app/globals.css:58` (`--primary` #c15c38) · usado por `src/components/ui/button.tsx:11`
- **Descripción:** texto blanco (`--primary-foreground` #fff) sobre `--primary` ≈4.32:1 · `text-sm` (14px) no califica como texto grande → aplica 4.5:1 (SC 1.4.3) y falla marginalmente. Afecta el CTA de ambos flujos en tema claro.
- **Suggested fix:** oscurecer `--primary` en light a ≥4.5:1 (el agente propone `--color-primary-hover` #a84b2b ≈5.4:1 como base).
- **verified:** false (1 detector) · source-verified ✅ (tokens confirmados). **quality_review: PENDING** — usar `#a84b2b` (hoy = `--color-primary-hover`) como base deja el hover sin headroom y cambia la identidad de marca app-wide + cascada a `--ring`/`--color-primary-soft`. Es decisión de diseño (matriz Claude Design), NO cambio mecánico. Re-validar impacto de marca/hover antes de codificar.
- **Scope:** OUT-OF-SCOPE → **DT-005**.

**lr_bug_004 · normal · confidence medium · detectores: [architect]**
- **Archivo:** `db/migrations/0003_onboarding_rpcs.sql:31` · `db/migrations/0001_*.sql:44` (UNIQUE)
- **Descripción:** write path almacena email crudo (`create_organization_with_owner` inserta `auth.email()` sin normalizar · UNIQUE(organization_id, email) case-sensitive). Read paths normalizan a lower (`link_pending_memberships` matchea `lower(email)`, index `idx_memberships_email ON memberships(lower(email))`). Dos memberships `Staff@x`/`staff@x` pueden coexistir y ambas activarse. Mitigado hoy (Supabase lowercasea auth emails) pero `addMember` de Fase 3 tomará email de input libre del Owner y cementará el path crudo. Fase 1 punto-de-no-retorno.
- **Suggested fix:** unificar sobre `lower(email)`: `UNIQUE(organization_id, lower(email))` como índice de expresión + normalizar en el INSERT del RPC (`lower(auth.email())`), o `citext`.
- **verified:** false (1 detector) · source-verified ✅ (write crudo L31 + read lower L54 confirmados). **quality_review: passed** — fix de causa raíz · simétrico write+read+index. Nota: elegir 1 de las 2 alternativas + aplicar patrón idempotente (`DROP INDEX IF EXISTS` antes de `CREATE`) por regla migrations-idempotency.
- **Scope:** IN-SCOPE (schema/RPC del propio PRP · decisión Fase 1 no-retorno · conviene cerrarla antes de Fase 3) → 🔴 pendiente.

**lr_bug_005 · normal · confidence medium · detectores: [correctness]**
- **Archivo:** `src/lib/auth/session.ts:45`
- **Descripción:** `if (error || !data) return []` colapsa dos estados opuestos: (a) usuario sin memberships, (b) query falló (permission-denied RLS · timeout · error del embed). Aguas abajo `resolvePostLoginRedirect([])` manda a `/onboarding`. Usuario que SÍ tiene org, ante fallo transitorio, es enviado a crear org nueva → segunda org/slug duplicado en vez de su dashboard.
- **Suggested fix:** distinguir error de vacío: si `error != null` propagar/loguear y que `confirm/route.ts` redirija a `/login?error=auth` en vez de `/onboarding`. Mínimo `console.error(error)` antes del `return []`.
- **verified:** false (1 detector) · source-verified ✅ (L45 confirmada). **quality_review: passed** — hermano de lr_bug_008 (mismo patrón "cualquier fallo → onboarding") · **fixear ambos juntos** (punto 6 simetría).
- **Scope:** IN-SCOPE → 🔴 pendiente.

**lr_bug_006 · normal · confidence medium · detectores: [a11y]**
- **Archivo:** `src/app/(auth)/login/page.tsx:51-63` · `src/app/(auth)/onboarding/onboarding-form.tsx:37-50`
- **Descripción:** el error se renderiza en `<p role="alert">` (lo anuncia al aparecer) pero el input no expone `aria-invalid` ni `aria-describedby` y el error no tiene `id`. Un usuario de lector de pantalla que vuelva al campo no recibe el estado inválido ni la relación campo↔error (SC 1.3.1/3.3.1).
- **Suggested fix:** dar `id="email-error"`/`id="name-error"` al `<p role="alert">` + `aria-invalid={state.status==='error'}` + `aria-describedby` condicional en el `<Input>` (el primitivo ya pasa `...props`).
- **verified:** false (1 detector) · source-verified ✅ (Input pasa props · forms en diff). **quality_review: passed** — patrón a11y estándar · simétrico en ambos forms.
- **Scope:** IN-SCOPE (forms + `input.tsx` en el diff) → 🔴 pendiente.

**lr_bug_007 · normal · confidence medium · detectores: [security]**
- **Archivo:** `src/app/(auth)/login/actions.ts:33` (`sendMagicLink` · `signInWithOtp`)
- **Descripción:** endpoint público pre-auth dispara `signInWithOtp` con cualquier email sin rate limit propio → vector de email-bombing / agotamiento de cuota SMTP. Mitigación: Supabase aplica rate limiting server-side propio (email+IP) · DT-003 ya documenta el límite del SMTP. Impacto acotado a la protección del proveedor.
- **Suggested fix:** al cablear rate limiting del edge/proxy (o al integrar Resend TASK-008) agregar límite por IP+email a `/login`.
- **verified:** false (1 detector) · source-verified ✅ (endpoint público confirmado). **quality_review: passed** (plan de fix sólido · depende de infra futura).
- **Scope:** OUT-OF-SCOPE (depende de edge/proxy o Resend TASK-008 no integrado) → **DT-004**.

**lr_bug_008 · normal · confidence low · detectores: [correctness]**
- **Archivo:** `src/app/auth/confirm/route.ts:37`
- **Descripción:** `await supabase.rpc('link_pending_memberships')` ignora el error. Usuario invitado (membership pending por email · Bif 3=A); si la RPC falla transitoriamente, sus memberships no se vinculan, `getActiveMemberships` devuelve `[]` y va a `/onboarding` a crear su propia org en vez de unirse. Combinado con lr_bug_005, la ruta post-login trata cualquier fallo como "usuario nuevo".
- **Suggested fix:** capturar `{error}` de la RPC y ante error loguear y/o redirigir a `/login?error=link`.
- **verified:** false (1 detector) · source-verified ✅ (L37 ignora resultado). **quality_review: passed** — hermano de lr_bug_005 · fixear juntos (simetría).
- **Scope:** IN-SCOPE → 🔴 pendiente.

### Métricas agregadas (acumulado tras LR-001)

- **Runs totales:** 1 · **findings crudos:** 17 · **consolidados (post-filtro):** 8 · **descartados por filtro Bif 6:** 9 (53%).
- **Por severidad:** 0 critical · 8 normal · 0 nit-backlog.
- **Verified por overlap (≥2 detectores):** 0/8 (0%) · **source-verified por consolidator (6.5):** 8/8 (100%).
- **Calidad de suggested fixes (mini-checklist regla #8):** 7 `passed` · 1 `PENDING` (lr_bug_003) · 0 `REJECTED`.
- **DTs abiertas en el acto:** 2 (DT-004 rate limiting · DT-005 contraste tokens).
- **In-scope PRP-002 (🔴 pendiente · bloquean merge):** 5 (lr_bug_001 · 004 · 005 · 006 · 008).

### Próxima acción recomendada

**Resolver los 5 normales in-scope antes del merge** (regla #1 always-fix-all-bugs · regression-first FIRME):

1. **lr_bug_005 + lr_bug_008 juntos** (simetría · patrón "cualquier fallo → onboarding" en `session.ts` + `confirm/route.ts`).
2. **lr_bug_004** (normalización email · decisión Fase 1 punto-de-no-retorno · cerrar antes de Fase 3 `addMember` · migración idempotente).
3. **lr_bug_001** (invariante SQL WRITE-side · área multi-tenancy sensible).
4. **lr_bug_006** (aria en inputs · ambos forms).

Antes de codificar **lr_bug_003** (queda como DT-005) el principal NO debe aplicar el fix sin re-validar el impacto de marca/hover (`quality_review: PENDING`). **DT-004 + DT-005** quedan registradas · las cierra su PRP destino (Resend/TASK-008 · sesión de tokens del DS). Los 9 nits descartados viven hasta un run futuro con ≥2 detectores.

---

*Log file inaugurado por el primer run del skill `/revisar` (LR-001 · 2026-07-03 · PRP-002). Shape canónico documentado en el header.*