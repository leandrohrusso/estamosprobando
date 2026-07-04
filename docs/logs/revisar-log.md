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
| PRP-002 | 2026-07-03 | SÍ | Área sensible: auth + multi-tenancy + RLS + RPCs SECURITY DEFINER (constraints del dominio en BUSINESS_LOGIC.md § 8). | LR-001 · LR-002 |

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
| LR-002 | 2026-07-03 | PRP-002 | `branch:dev` (diff vs `main`) | e4a9036 | 9a70250 | 48 | +3201/−24 | 0 / 13 / 0 | 13 | $0 (local Opus) | — | ✅ cerrado |

---

## Cobertura

### Por área del repo

> Mapa acumulado de qué áreas del repo YA pasaron por revisión local. El adopter define las filas según la estructura de su producto (típicamente paths bajo `src/` · `db/migrations/` · `tests/` · etc).

| Área | Último LR | Fecha | SHA cubierto | Notas |
|---|---|---|---|---|
| `src/app/(auth)/*` · `src/app/auth/confirm/*` · `src/lib/auth/*` | LR-002 | 2026-07-03 | 9a70250 | Login magic link · onboarding · sesión/redirect · select-organization · `org.ts` (requireRole/getOrgMembers/enum-sort) · `session.ts` · `slug.ts` · `roles.ts`. |
| `src/app/(org)/[orgSlug]/*` (dashboard · layout · members) | LR-002 | 2026-07-03 | 9a70250 | Fase 3: org context · RBAC gate · members CRUD (add/changeRole/remove). Área sensible multi-tenancy. |
| `src/components/nav/*` (app-nav · org-switcher) | LR-002 | 2026-07-03 | 9a70250 | Shell de navegación org + switcher (a11y select onChange → lr_bug_004). |
| `src/lib/supabase/*` · `src/proxy.ts` | LR-001 | 2026-07-03 | 647df90 | Cliente SSR + middleware/proxy de sesión. |
| `db/migrations/0001-0003` (organizations · memberships · RLS · helpers · RPCs) | LR-002 | 2026-07-03 | 9a70250 | Área sensible auth/multi-tenancy · re-revisión periódica justificada · RLS WITH CHECK owner-gate (lr_bug_002) · slug inmutable app-only (DT-006). |
| `src/components/ui/*` (button · input · card · label) | LR-002 | 2026-07-03 | 9a70250 | Primitivos UI (a11y contraste → DT-005 · touch target 44px → DT-008). |
| `tests/sql/*` · `tests/e2e/regression/PRP-002-*` · `tests/unit/PRP-002-*` | LR-002 | 2026-07-03 | 9a70250 | Specs SQL + e2e + unit del PRP · gaps de regresión detectados (lr_bug_001/009/010/011). |

### Por PRP

| PRP | Último LR | SHA cubierto | Status |
|---|---|---|---|
| PRP-002 | LR-002 | 9a70250 | Fases 1-4 revisadas (LR-001 = Fase 1+2 · LR-002 = full diff incl. Fase 3 org/RBAC/members + Fase 4 validación). |

### Por rango de commits

| Rango cubierto | Run | Cobertura | Notas |
|---|---|---|---|
| `e4a9036..647df90` | LR-001 | 100% | Commits Fase 1 (`22253a1`) + Fase 2 (`647df90`) del PRP-002. |
| `e4a9036..9a70250` | LR-002 | 100% | Full diff PRP-002 (Fase 1-4). Incremento vs LR-001: Fase 3 (`b982f4b` LR-001 fixes + `ad0c895` org/RBAC/members) + Fase 4 (`9a70250` validación). |

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
| lr_bug_001 | LR-002 | normal | **true** | architect · correctness · atomicity | `src/app/(org)/[orgSlug]/members/actions.ts:34-40,115-121,145-151` | `isManageableTarget` re-introduce swallow-error (solo `{data}`, ignora `error`→false→no-op) + `update`/`delete` de changeRole/removeMember no inspeccionan `error` ni `ROW_COUNT` → fallo real de escritura pasa desapercibido y `revalidatePath` da falsa sensación de éxito (regresión del patrón que LR-001 erradicó en helpers hermanos) | 🟢 fixeado | PRP-002 (fixeado LR-002 · regression-first FIRME) |
| lr_bug_002 | LR-002 | normal | **true** | multi-tenant · tests · atomicity | `db/migrations/0002_rls_and_helpers.sql:81-85` (mbr_write) + `tests/e2e/regression/PRP-002-rbac-and-orgs.spec.ts` | Invariante single-owner (SD-cos-11) vive SOLO en Server Actions: `mbr_write` WITH CHECK gatea solo dimensión tenant → Owner de A con su JWT puede INSERT/UPDATE membership `role='owner'` vía PostgREST (rompe single-owner) · y ningún spec reproduce Owner-inmutable (si se invierte el guard la suite sigue verde) | 🟢 fixeado | PRP-002 (fixeado LR-002 · regression-first FIRME) |
| lr_bug_003 | LR-002 | normal | false¹ | correctness | `src/app/(auth)/select-organization/page.tsx:20-25` | No gatea sesión ni maneja error de `getActiveMemberships` (que ahora hace throw post-LR-001), asimétrico con su hermano `onboarding/page.tsx` (getSessionUser→redirect + try/catch→/login?error=session): error real crashea la página (500) en vez de degradar · misma clase error-vs-vacío que LR-001 | 🟢 fixeado | PRP-002 (fixeado LR-002 · regression-first FIRME) |
| lr_bug_004 | LR-002 | normal | false¹ | a11y | `src/components/nav/org-switcher.tsx:23-28` · `src/app/(org)/[orgSlug]/members/members-manager.tsx:117-129` | Dos `<select>` con side-effect en onChange (org-switcher navega vía `router.push` · members-manager auto-submitea cambio de rol vía `form.requestSubmit()`) → usuario de teclado dispara la acción recorriendo opciones antes de confirmar (WCAG 3.2.2 On Input · el de members es mutación destructiva del rol de otra persona) | 🟢 fixeado | PRP-002 (fixeado LR-002 · regression-first FIRME) |
| lr_bug_005 | LR-002 | normal | false¹ | tests | `tests/e2e/regression/COVERAGE.md:53-54` | COVERAGE.md no mapea `tests/sql/helpers-shape-invariants.sql` (dejó de ser template vacío · ahora asserta shape de las 4 SECURITY DEFINER) → el próximo PRP (regla #16 pre-validation) no sabrá que ese invariante las cubre | 🟢 fixeado | PRP-002 (fixeado LR-002 · regression-first FIRME) |
| lr_bug_006 | LR-002 | normal | **true** | architect · multi-tenant | `db/migrations/0002_rls_and_helpers.sql:68-72` (org_update) | Slug inmutable (SD-cos-8) declarado "vía policy org_update" pero la policy es `FOR UPDATE` sin restricción de columna + `GRANT UPDATE` column-wide → una policy RLS no puede imponer inmutabilidad de columna · latente (sin caller UPDATE de organizations hoy) | ⚪ diferido | DT-006 (out-of-scope · sin caller · disparador: 1ra superficie de edición de org) |
| lr_bug_007 | LR-002 | normal | false¹ | security | `src/app/(auth)/login/actions.ts:27,35` | `emailRedirectTo` del magic link se construye desde el header `Origin` (client-controllable) → si la allow-list de Supabase fuese permisiva, el token viajaría a host atacante (account takeover A01). Mitigado hoy por same-origin de Server Actions + allow-list Supabase (defense-in-depth) | 🟢 fixeado | PRP-002 (fixeado LR-002 · `NEXT_PUBLIC_SITE_URL` con fallback dev · allow-list = config deploy) |
| lr_bug_008 | LR-002 | normal | false¹ | atomicity | `db/migrations/0003_onboarding_rpcs.sql:13-37` · `src/app/(auth)/onboarding/actions.ts:65-84` | `create_organization_with_owner` es atómica pero NO idempotente: double-submit/retry tras commit con respuesta perdida → 2da org mismo nombre (loop de slug reintenta con -2), ambas Owner activas → `/select-organization` con orgs duplicadas atascadas. `disabled={pending}` es mitigación solo client-side | 🟢 fixeado | PRP-002 (fixeado LR-002 · Bif A firmada user: token de idempotencia por (user, request) · preserva multi-org · spec G4.idem) |
| lr_bug_009 | LR-002 | normal | false¹ | tests | `tests/e2e/regression/PRP-002-auth-onboarding.spec.ts` | Fix de error-swallow de LR-001 (lr_bug_005/008) commiteado como "regression-first FIRME" sin spec que lo reproduzca: ningún test asserta que fallo de helper/RPC termine en `/login?error=` en vez de tratar al usuario como nuevo | 🟢 fixeado | PRP-002 (fixeado LR-002 · regression-first FIRME) |
| lr_bug_010 | LR-002 | normal | false¹ | tests | `src/lib/auth/org.ts:113-117` | Bug de orden por enum (Fase 4: `getOrgMembers` ordenaba `.order('status')` asumiendo alfabético; Postgres ordena enum por declaración pending<active; fix movió sort a JS pending-first) fixeado sin regression spec | 🟢 fixeado | PRP-002 (fixeado LR-002 · regression-first FIRME) |
| lr_bug_011 | LR-002 | normal | false¹ | tests | `tests/unit/PRP-002-slug.test.ts` · `src/app/(auth)/onboarding/actions.ts` | Unicidad de slug (sufijo -2/-3, reservados arrancan en -2) sin cobertura: el unit cubre `slugify()` puro + `isReservedSlug` bool pero no el comportamiento de resolución de colisión | 🟢 fixeado | PRP-002 (fixeado LR-002 · regression-first FIRME) |
| lr_bug_012 | LR-002 | normal | false¹ | a11y | `src/components/ui/button.tsx:19-22` · `input.tsx:13` · `members-manager.tsx:64,122` · `org-switcher.tsx:27` | Controles táctiles bajo la barra 44×44px del spec del proyecto (default h-10=40px · sm h-9=36px). Cumple WCAG AA 2.5.8 (≥24px) pero no la barra 44px (equivalente AAA 2.5.5) · cambio cross-cutting de sizing del DS | ⚪ diferido | DT-008 (out-of-scope · decisión DS/matriz Claude Design · AA-compliant) |
| lr_bug_013 | LR-002 | normal | false² | i18n | Copy de UI (login/onboarding/select-org/dashboard/members) · `src/lib/auth/roles.ts:9-12` | Todo el copy usa voseo rioplatense ("Revisá","Ingresá","Creá","Elegí","Pertenecés") aplicado consistentemente, pero NO existe regla que fije voseo (es-AR) vs neutro LATAM como canon (la convención "neutro" que asumió el agente NO está declarada en BUSINESS_LOGIC/rules) · decisión de voz de marca sin firmar | ⚪ diferido | DT-007 (out-of-scope · decisión de vocabulario del producto · requiere firma user) |

> ¹ `verified: false` = sin overlap cross-agente (1 detector · convención § "Marcado verified"). **Todos verificados contra fuente por el consolidator (sub-paso 6.5 · `Read` directo del archivo citado): coinciden con el código real.** El `false` refleja solo ausencia de confirmación por ≥2 agentes, no falta de verificación. Los **`verified: true`** (lr_bug_001/002/006 de LR-002) tienen ≥2 detectores cross-agente + source-verified.
> ² `verified: false` con matiz: la afirmación de lr_bug_013 sobre "convención neutro declarada" NO se verificó contra fuente (no existe tal declaración en BUSINESS_LOGIC ni `docs/product/references/rules/`) · el voseo en sí es real y consistente · por eso se rutea a DT-007 como decisión de producto, no como bug de código.

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

## LR-002 · 2026-07-03 · PRP-002

**Scope:** `branch:dev` · diff vs `main` (`e4a9036..9a70250`) · 48 archivos · +3201/−24 · full diff PRP-002 Fase 1-4 (incluye Fase 3 org context + RBAC + members `ad0c895` + Fase 4 validación `9a70250` + LR-001 fixes `b982f4b`).
**Preflight:** verde 6/6 · `tmp/local-ultrareview-preflight-2026-07-03T11-27-47Z.txt`.
**PRP:** `.claude/PRPs/PRP-002-auth-organizations-memberships-rls.md` (Fase 1-4 · paso 3 cerrado).

### Cobertura de agentes (9/9 corrieron · 0 timeout)

| Agente | Findings crudos | Con hallazgos |
|---|---|---|
| architect | 3 (2 normal · 1 nit) | sí |
| security | 3 (1 normal · 2 nit) | sí |
| multi-tenant | 2 (1 normal · 1 nit) | sí |
| atomicity | 3 (2 normal · 1 nit) | sí |
| tests | 6 (5 normal · 1 nit) | sí |
| correctness | 4 (2 normal · 2 nit) | sí |
| a11y | 5 (3 normal · 2 nit) + 1 no-finding (contraste ya en DT-005) | sí |
| i18n | 3 (1 normal · 2 nit) | sí |
| migration-safety | 1 (1 nit) | sí |

**Total findings crudos:** 30 (17 normal · 13 nit · excluye el no-finding a11y de contraste ya cubierto por DT-005).

**Dedupe (4 merges cross-agente · sube confianza):**
- **CF-A** (→ lr_bug_001): `architect:1` + `correctness:2` + `atomicity:2` → swallow-error/no-atómico en changeRole/removeMember (`members/actions.ts`). **3 detectores → verified:true.**
- **CF-C** (→ lr_bug_002): `multi-tenant:1`(owner) + `tests:1` + `atomicity:2`(TOCTOU) → single-owner solo en app + spec faltante. **3 detectores → verified:true.**
- **CF-B** (→ lr_bug_006): `architect:2` + `multi-tenant:1`(slug) → slug inmutable solo en app. **2 detectores → verified:true.**
- **Ay-selects** (→ lr_bug_004): `a11y:1` + `a11y:2` → dos `<select>` onChange (org-switcher + members-manager · mismo patrón WCAG 3.2.2). 1 detector (a11y) · 2 superficies.

> `multi-tenant:1` es 1 finding que abarca 2 invariantes (slug + single-owner) → alimenta CF-B y CF-C. `atomicity:2` abarca 2 concerns (error/ROW_COUNT + TOCTOU) → alimenta CF-A y CF-C. Detector-count por finding consolidado según qué agentes flaggearon ese concern específico (paridad guía del run).

### Filtrado Bif 6 = A

- **13 normal → PASAN** (severidad justifica el riesgo de FP independiente del count).
- **13 nit con 1 detector → DESCARTADOS** (cero confirmación cross-agente · filtro contractual · cero excepción por corazonada).

**`discarded_by_filter = 13`** (viven hasta que ≥2 agentes los detecten en un run futuro):

| # | Agente | Sev | Archivo:línea | Título | Motivo |
|---|---|---|---|---|---|
| 1 | architect | nit | `PRP-001-scaffold-infra-base.md:1-19` | Cierre admin de PRP-001 (header→COMPLETADO) incluido en el diff · scope-bleed docs-only impacto nulo | nit · 1 detector |
| 2 | security | nit | `src/app/auth/confirm/route.ts:17` | Route handler público pre-auth no valida `type` con Zod (casteado a EmailOtpType sin whitelist · verifyOtp valida aguas abajo) | nit · 1 detector |
| 3 | security | nit(low) | `onboarding/actions.ts:36-86` · `0003:22-24` | `createOrganization` sin gate "0 memberships" ni rate limit → usuario auth crea orgs ilimitadas (abuso recursos, no escalada) | nit · 1 detector |
| 4 | multi-tenant | nit(low) | `0002_rls_and_helpers.sql:76-79` (mbr_select) | Cualquier miembro activo (incl staff) lee todas las membership rows (incl emails PII) de su org vía API · intra-tenant aceptado por el skeptic del PRP | nit · 1 detector |
| 5 | atomicity | nit | `tests/sql/PRP-002-helpers-and-rpcs.sql:25-43` | Falta regression del path de colisión de slug/creación concurrente (23505 unique_violation + rollback atómico) | nit · 1 detector |
| 6 | tests | nit | `PRP-002-auth-onboarding.spec.ts:36-49` | Fila vecina del fix aria (LR-001 lr_bug_006) cubierta en login pero no en onboarding | nit · 1 detector |
| 7 | correctness | nit | `onboarding/actions.ts:53-57` | Colisión de slug puede emitir doble guión (`foo--2`) al truncar sobre un guión | nit · 1 detector (reincidente LR-001 #7) |
| 8 | correctness | nit(low) | `src/lib/auth/session.ts:61-72` | `getActiveMemberships` accede `org.slug/name` sin guard tras desempaque (array vacío → TypeError; `!inner` lo garantiza) | nit · 1 detector (reincidente LR-001 #8) |
| 9 | a11y | nit | `login/page.tsx:27-37` | Estado "Revisá tu email" sin live region ni gestión de foco (foco queda en submit inexistente) · WCAG 4.1.3 | nit · 1 detector |
| 10 | a11y | nit | `src/components/nav/app-nav.tsx:22` | `<nav>` del shell sin aria-label descriptivo · WCAG 1.3.1 | nit · 1 detector |
| 11 | i18n | nit | `src/lib/auth/roles.ts:9-12` | roleLabel mezcla idiomas ('Dueño'/'Administrador' vs 'Staff') · BUSINESS_LOGIC §4 usa "Org Staff" (puede ser deliberado) | nit · 1 detector (contexto agrupado en DT-007) |
| 12 | i18n | nit | `members-manager.tsx:96,120` · `members/actions.ts` | Tres verbos para la misma acción (botón "Agregar" · éxito "Invitaste a" · error "ya es miembro o está invitado") | nit · 1 detector |
| 13 | migration-safety | nit | `0002:17,32` · `0003:17,43` | 4 SECURITY DEFINER fijan `SET search_path = public` sin `pg_temp` explícito al final (Postgres lo inserta implícito primero) · riesgo bajo (schema-calificado) | nit · 1 detector |

> **Nota de calibración:** varios descartados son señalamientos legítimos (search_path pg_temp · least-privilege · slug 23505 rollback · PII intra-tenant · doble guión reincidente). El filtro Bif 6 = A los difiere por falta de confirmación cross-agente · reaparecen y pasan si ≥2 los detectan en un run futuro. Cero "salvar" señal débil por corazonada.

### Sub-paso 6.7 · grep doc obsoleta

`git diff main --name-only -- '*.md'` → 8 docs modificados · grep de `diferible|fix oportunista|para próximo PR|deferred|skipear por ahora|skip por ahora` → **1 match aparente** en `docs/logs/revisar-log.md:231` que es la propia entrada LR-001 documentando literalmente la lista de patrones del grep ("grep de `diferible|...` → 0 matches"), **NO** una frase que normalice diferimiento de bugs → **falso positivo del grep contra su propia documentación de patrones · 0 findings genuinos agregados** (paridad regla #1 · el gate busca doc que normalice diferir bugs, no la documentación del gate mismo).

### Hallazgos consolidados · detalle por bug (13 · todos `normal` · mini-checklist quality-senior 6 puntos)

**lr_bug_001 · normal · confidence high · detectores: [architect, correctness, atomicity] · verified:true**
- **Archivo:** `src/app/(org)/[orgSlug]/members/actions.ts:34-40,115-121,145-151`
- **Descripción:** `isManageableTarget` desestructura solo `{data}` e ignora `error` → colapsa a `false` → no-op silencioso (regresión del patrón que LR-001 erradicó en helpers hermanos que hacen `throw`). Además `changeRole`/`removeMember` no capturan `{error}` del `update`/`delete` ni chequean `ROW_COUNT` → fallo real de escritura pasa desapercibido y `revalidatePath` da falsa sensación de éxito. TOCTOU latente (hoy no explotable por owner inmutable, sí cuando llegue transferencia de propiedad).
- **Suggested fix:** desestructurar `{data,error}` y propagar en el SELECT; plegar el predicado en el statement (`.update().eq('role','...')` con condición `role<>'owner'` o `UPDATE ... WHERE ... AND role<>'owner'`) + inspeccionar `error`/`count` antes de `revalidatePath`. Simétrico en changeRole+removeMember.
- **verified:true** (3 detectores) · source-verified ✅ (L34-40 solo `{data}` · L115-119/145-149 sin inspección de error confirmados). **quality_review: passed** — fix de causa raíz · simétrico entre los dos hermanos (punto 6).
- **Scope:** IN-SCOPE (archivo del propio PRP) → 🔴 pendiente.

**lr_bug_002 · normal · confidence high · detectores: [multi-tenant, tests, atomicity] · verified:true**
- **Archivo:** `db/migrations/0002_rls_and_helpers.sql:81-85` (mbr_write) + `tests/e2e/regression/PRP-002-rbac-and-orgs.spec.ts`
- **Descripción:** `mbr_write` WITH CHECK = `has_role(organization_id, ARRAY['owner'])` gatea solo que el ACTOR sea owner, NO restringe la columna `role` de la fila escrita → un Owner de A con su JWT legítimo puede INSERT/UPDATE membership `role='owner'` vía PostgREST directo (rompe single-owner SD-cos-11). El invariante vive SOLO en Server Actions (`assignableRoleSchema`). Además ningún spec reproduce Owner-inmutable: el CRUD ejercita staff, nunca Owner → si se invierte el guard `role!=='owner'` la suite sigue verde.
- **Suggested fix:** WITH CHECK con `role = ANY(ARRAY['admin','staff'])` en mbr_write (owner solo se setea vía RPC SECURITY DEFINER) + `DROP POLICY IF EXISTS` antes (migrations-idempotency) + regresión en `rls-isolation.sql` (owner A insertando `role='owner'` → rechazado) + spec e2e Owner-inmutable (removeMember/changeRole sobre Owner → sigue owner/active; addMember rechaza role='owner').
- **verified:true** (3 detectores) · source-verified ✅ (mbr_write WITH CHECK confirmado L84-85 sin restricción de columna). **quality_review: passed** — defensa en capas correcta ("RLS es la última red, no la única" · principios-desarrollo-flujo #6) · aplicar patrón idempotente al recrear la policy.
- **Scope:** IN-SCOPE (migración + specs del propio PRP · invariante SD-cos-11 del PRP) → 🔴 pendiente.

**lr_bug_003 · normal · confidence high · detectores: [correctness] · verified:false (source-verified ✅)**
- **Archivo:** `src/app/(auth)/select-organization/page.tsx:20-25`
- **Descripción:** no gatea sesión (sin `getSessionUser`) ni envuelve `getActiveMemberships` en try/catch, asimétrico con su hermano `onboarding/page.tsx:12-23` (que hace `getSessionUser`→`/login` + try/catch→`/login?error=session`). Como `getActiveMemberships` ahora hace `throw` ante error real (post-LR-001), un fallo transitorio crashea la página (500) en vez de degradar · usuario sin sesión da hop indirecto. Misma clase error-vs-vacío que LR-001.
- **Suggested fix:** alinear con onboarding: `const user = await getSessionUser(); if (!user) redirect('/login')` + try/catch alrededor de `getActiveMemberships` → `redirect('/login?error=session')`.
- **verified:false** (1 detector) · source-verified ✅ (select-organization sin guard confirmado L20-25 · onboarding con guard L12-23). **quality_review: passed** — patrón simétrico con el hermano ya existente.
- **Scope:** IN-SCOPE (página del propio PRP) → 🔴 pendiente.

**lr_bug_004 · normal · confidence high · detectores: [a11y] · verified:false (source-verified ✅)**
- **Archivo:** `src/components/nav/org-switcher.tsx:23-28` · `src/app/(org)/[orgSlug]/members/members-manager.tsx:117-129`
- **Descripción:** dos `<select>` con side-effect en onChange (org-switcher navega vía `router.push`; members-manager auto-submitea el cambio de rol vía `form.requestSubmit()` · confirmado L121). Usuario de teclado recorriendo opciones con flechas dispara la acción antes de confirmar (WCAG 3.2.2 On Input). El de members es mutación destructiva del rol de otra persona sin confirmación.
- **Suggested fix:** separar selección de acción con botón explícito ("Cambiar" en org-switcher · "Guardar rol" en members-manager) o menú/listbox ARIA con navegación solo en Enter/click. Fix simétrico en ambas superficies.
- **verified:false** (1 detector · 2 instancias) · source-verified ✅ (members-manager L121 `onChange requestSubmit` confirmado). **quality_review: passed** — patrón a11y estándar · simétrico.
- **Scope:** IN-SCOPE (ambos componentes en el diff) → 🔴 pendiente.

**lr_bug_005 · normal · confidence high · detectores: [tests] · verified:false (source-verified ✅)**
- **Archivo:** `tests/e2e/regression/COVERAGE.md:53-54`
- **Descripción:** COVERAGE.md no mapea `tests/sql/helpers-shape-invariants.sql`, que en este PRP dejó de ser template vacío (11KB · asserta shape de las 4 SECURITY DEFINER). El próximo PRP (regla #16 pre-validation) no sabrá que este invariante las cubre.
- **Suggested fix:** agregar fila en COVERAGE.md mapeando `helpers-shape-invariants.sql` → helpers `db/migrations/0002-0003` (SECURITY DEFINER shape).
- **verified:false** (1 detector) · source-verified ✅ (archivo existe con contenido real · `grep helpers-shape COVERAGE.md` → 0 → no mapeado). **quality_review: passed** — fix trivial de doc de cobertura.
- **Scope:** IN-SCOPE (doc de tests del propio PRP) → 🔴 pendiente.

**lr_bug_006 · normal · confidence medium · detectores: [architect, multi-tenant] · verified:true**
- **Archivo:** `db/migrations/0002_rls_and_helpers.sql:68-72` (org_update)
- **Descripción:** SD-cos-8 declara slug inmutable "vía policy org_update" pero `org_update` es `FOR UPDATE` con USING/WITH CHECK solo sobre `has_role owner` — sin restricción de columna + `GRANT UPDATE` column-wide → una policy RLS NO puede imponer inmutabilidad de columna. Un Owner con su JWT podría mutar `organizations.slug` vía PostgREST. Latente: no hay caller UPDATE de organizations hoy (INSERT solo vía RPC · cero superficie de edición de org en PRP-002).
- **Suggested fix:** al aparecer la primera superficie de edición de org → `GRANT UPDATE (col,...)` column-level sin `slug` o trigger `BEFORE UPDATE` que rechace cambios de slug + corregir la prosa SD-cos-8. No fixear ahora sin caller.
- **verified:true** (2 detectores) · source-verified ✅ (org_update L68-72 sin restricción de columna confirmado). **quality_review: passed** — la propuesta (trigger o column-level GRANT) es el mecanismo correcto; diferida por ausencia de caller.
- **Scope:** OUT-OF-SCOPE (sin caller UPDATE hoy · requiere diseño de la superficie de edición · disparador objetivo) → **DT-006**.

**lr_bug_007 · normal · confidence medium · detectores: [security] · verified:false (source-verified ✅)**
- **Archivo:** `src/app/(auth)/login/actions.ts:27,35`
- **Descripción:** `emailRedirectTo` del magic link se construye desde `headers().get('origin')` (client-controllable) → si la allow-list de Supabase fuese permisiva, el token viajaría a un host atacante (account takeover A01). Mitigado hoy por same-origin check de Server Actions + allow-list Supabase (defense-in-depth).
- **Suggested fix:** usar una constante server-side (`NEXT_PUBLIC_SITE_URL`) como base del redirect + mantener la allow-list de Supabase sin wildcards. El fix de código es surgical (swap del header por constante); el hardening de allow-list es config de deploy.
- **verified:false** (1 detector) · source-verified ✅ (L27 `origin=headers().get('origin')` → L35 `emailRedirectTo:\`${origin}/auth/confirm\`` confirmado). **quality_review: passed** — cero hardcode (constante nombrada) · nota: requiere que `NEXT_PUBLIC_SITE_URL` exista.
- **Scope:** IN-SCOPE (login/actions.ts en el diff · fix de código trazable) → 🔴 pendiente.

**lr_bug_008 · normal · confidence medium · detectores: [atomicity] · verified:false**
- **Archivo:** `db/migrations/0003_onboarding_rpcs.sql:13-37` · `src/app/(auth)/onboarding/actions.ts:65-84`
- **Descripción:** `create_organization_with_owner` es atómica pero NO idempotente: double-submit/retry tras commit con respuesta perdida → el loop de slug reintenta con `-2` y crea una SEGUNDA org con mismo nombre, ambas Owner activas → `resolvePostLoginRedirect` ve ≥2 y manda a `/select-organization` con orgs duplicadas atascadas (sin borrado por UI). `disabled={pending}` es mitigación solo client-side.
- **Suggested fix:** idempotencia por request (token de idempotencia o SELECT-existing-owner-org antes de crear).
- **verified:false** (1 detector) · agent-only (no source-read directo del RPC por el consolidator · recomendable Read antes de fixear). **quality_review: PENDING** — el fix requiere decisión de diseño: el producto SÍ soporta multi-org (existe `/select-organization` · SD-cos-9), por lo que "gatear a 0 memberships" (sugerencia de `security:3`) ROMPERÍA multi-org. El mecanismo correcto (token idempotencia vs dedup-por-nombre-en-ventana-corta) debe firmarse antes de codificar.
- **Scope:** IN-SCOPE (RPC + action del propio PRP · bug real) → 🔴 pendiente (quality PENDING).

**lr_bug_009 · normal · confidence medium · detectores: [tests] · verified:false (source-verified parcial)**
- **Archivo:** `tests/e2e/regression/PRP-002-auth-onboarding.spec.ts`
- **Descripción:** el fix de error-swallow de LR-001 (lr_bug_005/008) se commiteó como "regression-first FIRME" pero sin spec que lo reproduzca: ningún test asserta que un fallo de helper/RPC termine en `/login?error=` en vez de tratar al usuario como nuevo. La rama de error de `getActiveMemberships` (throw · session.ts L57-59) y `onboarding/page.tsx` (catch→`/login?error=session`) no tiene cobertura.
- **Suggested fix:** spec que fuerce el error (mock/RLS deny) y asserte redirect `/login?error=`, o extraer la rama a helper puro testeable.
- **verified:false** (1 detector) · source-verified ✅ parcial (throw en session.ts L57-59 + catch en onboarding/page.tsx L19-22 confirmados · gap de spec inferido). **quality_review: passed** — regression-first FIRME (regla #15) · cierra el gap del propio fix de LR-001.
- **Scope:** IN-SCOPE (spec del propio PRP) → 🔴 pendiente.

**lr_bug_010 · normal · confidence medium · detectores: [tests] · verified:false (source-verified ✅)**
- **Archivo:** `src/lib/auth/org.ts:113-117`
- **Descripción:** bug de orden por enum (Fase 4: `getOrgMembers` ordenaba `.order('status')` asumiendo alfabético; Postgres ordena enum por orden de declaración `pending<active`; el fix movió el sort a JS pending-first) fixeado sin regression spec.
- **Suggested fix:** spec con org con ≥1 pending + ≥1 active y assertar el orden de render (pending primero).
- **verified:false** (1 detector) · source-verified ✅ (sort JS pending-first en L113-117 confirmado). **quality_review: passed** — regression-first FIRME del fix ya aplicado.
- **Scope:** IN-SCOPE (spec del propio PRP) → 🔴 pendiente.

**lr_bug_011 · normal · confidence medium · detectores: [tests] · verified:false (source-verified parcial)**
- **Archivo:** `tests/unit/PRP-002-slug.test.ts` · `src/app/(auth)/onboarding/actions.ts`
- **Descripción:** la unicidad de slug (sufijo `-2`/`-3`, reservados arrancan en `-2`) no tiene cobertura: el unit cubre `slugify()` puro + `isReservedSlug` bool pero no el comportamiento de resolución de colisión bajo nombre repetido.
- **Suggested fix:** extraer `resolveUniqueSlug` como función pura + unit de resolución de colisión, o e2e de 2 orgs mismo nombre → slugs distintos.
- **verified:false** (1 detector) · source-verified ✅ parcial (`tests/unit/PRP-002-slug.test.ts` existe · gap de unicidad inferido). **quality_review: passed** — extraer helper puro testeable (cero copy-paste · punto 3).
- **Scope:** IN-SCOPE (test + action del propio PRP) → 🔴 pendiente.

**lr_bug_012 · normal · confidence medium · detectores: [a11y] · verified:false (source-verified ✅)**
- **Archivo:** `src/components/ui/button.tsx:19-22` · `input.tsx:13` · `members-manager.tsx:64,122` · `org-switcher.tsx:27`
- **Descripción:** controles táctiles bajo la barra 44×44px del spec del proyecto (button default h-10=40px · sm h-9=36px · botón "Quitar" sm 36px · selects h-9/h-10) en superficies que colapsan a mobile. El propio agente aclara: cumple WCAG AA 2.5.8 (≥24px) · el gap es contra la barra 44px del spec (equivalente AAA 2.5.5). Cambio cross-cutting del sizing del DS.
- **Suggested fix:** subir default a h-11=44px · evitar `sm` en botones táctiles (decisión de sizing del DS · matriz Claude Design).
- **verified:false** (1 detector) · source-verified ✅ (members-manager select h-9 confirmado L122). **quality_review: passed** — cambio mecánico de tokens/clases una vez que la sesión de DS decide (AA-compliant hoy · no bloquea).
- **Scope:** OUT-OF-SCOPE (decisión de sizing del DS · afecta botones app-wide · fuera del scope auth de PRP-002 · AA-compliant · paridad clase con DT-005) → **DT-008**.

**lr_bug_013 · normal · confidence medium · detectores: [i18n] · verified:false (premisa NO verificable)**
- **Archivo:** copy de UI (login/onboarding/select-org/dashboard/members) · `src/lib/auth/roles.ts:9-12`
- **Descripción:** todo el copy usa voseo rioplatense ("Revisá","Ingresá","Creá","Elegí","Pertenecés","Gestioná") aplicado consistentemente. El agente afirma que contradice "la convención declarada español neutro LATAM-friendly", **pero esa convención NO está declarada** en BUSINESS_LOGIC.md ni en `docs/product/references/rules/` (las menciones "AR-friendly/neutro/argentinismos" son solo ejemplos ilustrativos en READMEs). BUSINESS_LOGIC §4 usa "Org Staff" (roleLabel mezcla 'Dueño'/'Administrador' con 'Staff'). Sin regla copy-localization que fije el canon → decisión de voz de marca sin firmar.
- **Suggested fix:** confirmar con el user si el voseo es intencional (y codificar `docs/product/references/rules/vocabulario.md` con es-AR) o migrar a imperativos neutros · resolver 'Staff' vs español.
- **verified:false²** (1 detector) · la afirmación central ("convención neutro declarada") NO se verificó contra fuente porque no existe · el voseo en sí es real y consistente. **quality_review: passed** — cero bug de código · es decisión de producto.
- **Scope:** OUT-OF-SCOPE (decisión de vocabulario del producto · requiere firma user · no declarada · abarca todo el copy) → **DT-007**.

### Métricas agregadas (acumulado tras LR-002)

- **Runs totales:** 2 · **findings crudos LR-002:** 30 · **consolidados (post-filtro):** 13 · **descartados por filtro Bif 6:** 13 (43%).
- **Por severidad:** 0 critical · 13 normal · 0 nit-backlog.
- **Verified por overlap (≥2 detectores):** 3/13 (23%) — lr_bug_001 (3) · lr_bug_002 (3) · lr_bug_006 (2) · **source-verified por consolidator (6.5):** 12/13 leídos directo o parcial contra el código (la excepción es lr_bug_013, cuya premisa "convención declarada" es no-verificable porque no existe).
- **Calidad de suggested fixes (mini-checklist regla #8):** 12 `passed` · 1 `PENDING` (lr_bug_008 · mecanismo de idempotencia dado multi-org) · 0 `REJECTED`.
- **DTs abiertas en el acto:** 3 (DT-006 slug inmutable app-only · DT-007 voseo/vocabulario · DT-008 touch target 44px).
- **In-scope PRP-002 (🔴 pendiente · bloquean merge):** 10 (lr_bug_001·002·003·004·005·007·008·009·010·011).

### Próxima acción recomendada

**Resolver los 10 normales in-scope antes del merge** (regla #1 always-fix-all-bugs · regression-first FIRME · orden por severidad/confidence):

1. **lr_bug_001** (swallow-error/no-atómico en members · 3 detectores · regresión de LR-001 · alta prioridad).
2. **lr_bug_002** (single-owner solo en app · RLS WITH CHECK owner-gate + spec Owner-inmutable · área multi-tenancy sensible · migración idempotente).
3. **lr_bug_003** (asimetría de guard en select-organization vs onboarding · misma clase error-vs-vacío de LR-001).
4. **lr_bug_007** (emailRedirectTo desde header Origin · fix constante server-side).
5. **lr_bug_004** (dos `<select>` onChange · separar selección de acción · simétrico).
6. **lr_bug_009 · lr_bug_010 · lr_bug_011** (regression specs faltantes de fixes ya aplicados · regla #15).
7. **lr_bug_005** (COVERAGE.md mapear helpers-shape-invariants.sql · trivial).

**Antes de codificar lr_bug_008** el principal NO debe aplicar el fix sin firmar el mecanismo de idempotencia (multi-org está soportado → gatear a 0 memberships rompería el producto · `quality_review: PENDING`).

**DT-006 + DT-007 + DT-008** quedan registradas · las cierra su disparador (1ra superficie de edición de org · firma de convención de copy · sesión de sizing del DS). Los 13 nits descartados viven hasta un run futuro con ≥2 detectores.

---

*Log file inaugurado por el primer run del skill `/revisar` (LR-001 · 2026-07-03 · PRP-002). Shape canónico documentado en el header.*