# PRP-001 · Scaffold + infra base (Next.js + Tailwind + shadcn/ui + cliente Supabase + wiring CI)

> **Estado**: EN PROGRESO (paso 4 cerrado · 5 + 6 pendientes)
> **Fecha**: 2026-06-26
> **Proyecto**: PUERTITA
> **Tipo**: feature producto (scaffold fundacional)
> **Modo**: C completo (6 pasos)
> **Cardinalidad de fases**: 4 fases reversibles
> **Tarea del roadmap cubierta**: TASK-001
> **Riesgo**: 🟡 Medio · primer PRP con código real · toca deps + scaffold + infra CI coordinados, pero sin BD ni decisiones de modelado
> **Complejidad estimada**: 🟡 MEDIA · 0 tablas nuevas · 1 pantalla mínima · lógica = instalación/configuración · 1-2 días (gate Paso 4.5 pasado · sin reconciliación hacia arriba)

> **Progreso del flujo de 6 pasos:**
> 1. ☑ `/arrancar`
> 2. ☑ `/planificar` → APROBADO
> 3. ☑ `/implementar` (4/4 fases)
> 4. ☑ `/revisar-simple` (0 critical · 0 normal · 1 nit fixeado · override B scaffold)
> 5. ☐ `/validar` (CSV X/Y Funciona)
> 6. ☐ `/entregar` (ci:local + push + CI remoto + merge --squash)

---

## Objetivo

Convertir el repo recién bootstrapeado (configs stub del template + `package.json` con deps vacías + sin `src/`) en una app Next.js que arranca, compila y pasa el subset verde del CI. Se instalan las deps reales del stack, se crea el scaffold mínimo de `src/app/`, se declara el cliente Supabase skeleton (sin auth/RLS real), y se completa el wiring del CI que el bootstrap dejó pendiente. La BD real (schema, seed, specs e2e/sql con datos) queda diferida a TASK-002.

**Métrica binaria de éxito:** `npm run ci:local -- --only=typecheck --only=lint` (vía corridas separadas) + `npm run build` exit 0 · `npm run test:unit` exit 0 · spec e2e smoke `/` verde · jobs `sql` y state-baseline `e2e` skip-safe sin TEST_DATABASE_URL.

---

## Por Qué

| Problema | Solución |
|---|---|
| El repo tiene configs stub apuntando a `src/` inexistente y `package.json` con `dependencies: {}` · nada compila, nada corre, el CI no puede ejecutar jobs reales | Instalar deps reales + crear `src/app/` mínimo + cliente Supabase skeleton + cerrar el wiring CI · dejar la base lista para que TASK-002 (auth + orgs + RLS) arranque sobre terreno firme |

**Valor de negocio:**
- Habilita todo el roadmap de PUERTITA: sin scaffold + infra base verde, ningún PRP posterior (eventos, checkout, pagos, check-in) puede empezar.
- Materializa el stack confirmado en [`BUSINESS_LOGIC.md § 7`](../../BUSINESS_LOGIC.md) como código ejecutable + CI gate confiable (NFR "Calidad" del PRD §9: Vitest + Playwright + lint-staged + Husky + CI).

---

## Qué

### Criterios de Éxito (binarios verificables)

- [x] **G1 · Deps reales instaladas** · `package.json` con deps reales · `npm install` OK (429 paquetes · sin ERESOLVE).
- [x] **G2 · Scaffold mínimo** · `src/app/{layout,page,globals.css}` existen · `npm run build` exit 0.
- [x] **G3 · Cliente Supabase skeleton** · `src/lib/supabase/{client,server}.ts` con `@supabase/ssr` · typecheck exit 0 · `.env.example` con las vars.
- [x] **G4 · Script `dev` agregado** · `"dev": "next dev"` en scripts.
- [x] **G5 · Tests del DoD** · e2e smoke (`/` 200 + PUERTITA) verde · unit smoke (vitest) verde.
- [x] **G6 · Wiring CI** · job `e2e` con `npx playwright install --with-deps chromium` · job-order-parity exit 0 · `sql`/state-baseline skip-safe.
- [x] **G7 · CI subset verde local** · `npm run ci:local` exit 0 · typecheck/lint/build/unit verdes · e2e smoke verde · sql skip-safe.

### Comportamiento Esperado (Happy Paths)

**Happy path 1 (dev arranca):** `npm install` → `npm run dev` → `http://localhost:3000/` rinde la página mínima de PUERTITA sin errores de hidratación ni consola.

**Happy path 2 (CI gate):** `npm run ci:local` corre los 6 jobs · typecheck/lint/build/unit verdes · e2e corre el smoke spec verde · sql skip-safe (sin TEST_DATABASE_URL) · exit 0.

---

## Contexto

### Referencias del codebase (SoT)

- Stubs del template a adoptar/extender (NO regenerar): `next.config.ts`, `tsconfig.json` (`paths: @/* → ./src/*`), `tailwind.config.ts` (theme DS 160 líneas · content `./src/app` + `./src/components` · espera `src/app/globals.css`), `eslint.config.js` (flat config minimal · requiere typescript-eslint + react + import + @next plugin + globals), `playwright.config.ts` (webServer `npm run dev` · globalSetup `tests/global-setup.ts`), `postcss.config.js` (tailwindcss + autoprefixer · estilo v3), `components.json` (shadcn new-york · css `src/app/globals.css` · aliases `@/components` `@/lib` `@/components/ui`).
- `package.json` · scripts ya definidos (typecheck/lint/build/test:unit/test:e2e/ci:local/prepare) · **falta `dev`** · `dependencies: {}` a llenar.
- `tests/global-setup.ts` · carga `.env.local` vía `process.loadEnvFile` (Node 20.12+).
- `.github/workflows/ci.yml` · 8 jobs cableados · job `e2e` con PENDIENTE anotado (Playwright browsers + TEST DB seed).
- `scripts/local-ci.sh` · `ALL_JOBS=(typecheck lint build unit e2e sql)` · invariante paridad con `ci.yml`.
- `tests/e2e/regression/COVERAGE.md` · suite vacío al boot (pre-validación regla #16 no aplica · ver Blueprint pre-step).

### Patrones existentes a respetar (regla [`simplicity-first.md`](../rules/simplicity-first.md) · reusar > recrear)

- Adoptar los stubs del template tal cual · extender quirúrgicamente · cero reescritura del shape ni del theme DS (regla [`surgical-changes.md`](../rules/surgical-changes.md)).
- Paths del framework en inglés (regla [`routing-paths-in-english.md`](../rules/routing-paths-in-english.md)) · copy de UI en español.
- Cliente Supabase con `@supabase/ssr` (patrón canónico browser + server · SoT del stack en [`BUSINESS_LOGIC.md § 7`](../../BUSINESS_LOGIC.md)).
- Stack confirmado: [`BUSINESS_LOGIC.md § 7`](../../BUSINESS_LOGIC.md) (SoT única).
- **Verificación contra constraints no negociables** [`BUSINESS_LOGIC.md § 8`](../../BUSINESS_LOGIC.md): este PRP NO toca multi-tenancy/stock/RLS reales (skeleton only) · cero violación posible · las constraints se materializan en TASK-002+.

### Reglas firmes aplicables (`.claude/rules/`)

- [`respect-existing-folder-structure.md`](../rules/respect-existing-folder-structure.md) — `src/` es carpeta nueva · ya pre-declarada por los stubs (tsconfig paths · tailwind content · components.json aliases) · firma user en aprobación del PRP.
- [`folder-creation-with-readme.md`](../rules/folder-creation-with-readme.md) — README en `src/` explicando el layout.
- [`simplicity-first.md`](../rules/simplicity-first.md) — scaffold mínimo · cero `src/components/ui` ni `src/lib/utils.ts` hasta que haya caller real (TASK-002+).
- [`surgical-changes.md`](../rules/surgical-changes.md) — adoptar stubs sin reformateo · matchear estilo.
- [`no-suponer-fuente-de-verdad.md`](../rules/no-suponer-fuente-de-verdad.md) — verificar versiones estables actuales (Next/React/Tailwind v3/Supabase/Vitest/Playwright) contra docs/registry oficiales durante implementación · NUNCA memoria del LLM.
- [`tests-as-dod-per-phase.md`](../rules/tests-as-dod-per-phase.md) — cada fase cierra con tests del DoD + typecheck + build verdes.
- [`husky-hooks-smoke-tests.md`](../rules/husky-hooks-smoke-tests.md) — los hooks se activan con `npm install` (`prepare: husky`) · si se modifica un hook, actualizar su smoke.
- [`push-and-ci-policy.md`](../rules/push-and-ci-policy.md) — paridad `local-ci.sh` ↔ `ci.yml` · commit + push ANTES de arrancar `ci:local` (evitar race dev-server↔typecheck) · cero `[skip ci]` en HEAD del PR.
- [`status-tracker-visible.md`](../rules/status-tracker-visible.md) — Modo C · tracker de 6 pasos al inicio de cada respuesta.

Tabla canónica completa: [`CLAUDE.md § Reglas FIRMES`](../../CLAUDE.md).

### Decisiones cerradas (firmas 🔵 user)

- **🔵 Bif 1 · Frontera de scope "infra base lista" — Opción A firmada por user · 2026-06-26** · *"Firmo A y dejalo anotado explícito como restricción de scope (TEST DB real + specs e2e/sql → TASK-002) para que la próxima sesión lo agarre sin dudar."*. → PRP-001 entrega: deps + scaffold mínimo + cliente Supabase skeleton + wiring CI con typecheck/lint/build/unit verdes + e2e smoke (sin DB) + sql/state-baseline skip-safe. TEST DB real + seed + specs e2e/sql con datos → **TASK-002**.
- **🔵 Bif 2 · Versión de Tailwind — Opción A (v3) firmada por user · 2026-06-26** · *"firmo A"*. → Instalar Tailwind v3 · respeta los stubs (`tailwind.config.ts` + `postcss.config.js` + `tailwindcss-animate`) sin reescritura · migración a v4 sería PRP propio.
- **🔵 Claude Design SKIP firmado por user · 2026-06-26** · *"OK"* · matriz NO dispara · scaffold crea solo página mínima placeholder + `globals.css` con tokens que el `tailwind.config.ts` ya espera · cero decisión de UX · primitivos directos del DS.

### Sub-decisiones cosméticas (agente decide · firma 🔵 implícita al aprobar el PRP)

- **SD-cos-1 · Versión de Next.js/React:** instalar Next.js v16 estable (los stubs declaran "Next.js 16+" en `next.config.ts`) + React 19 compatible · verificar versión exacta contra registry oficial durante implementación.
- **SD-cos-2 · Cliente Supabase:** `@supabase/ssr` (patrón moderno) con `createBrowserClient` + `createServerClient` · skeleton sin lógica de auth todavía.
- **SD-cos-3 · Secrets:** `.env.example` versionado con placeholders · `.env.local` gitignored (cero secrets reales en git).
- **SD-cos-4 · Página raíz:** placeholder mínimo de PUERTITA en `/` (ruta inglés · copy español) · **100% estática · cero fetch/DB query** (consecuencia de Bif 1 = A skeleton) · por eso el e2e smoke no necesita TEST_DATABASE_URL · cero shadcn components todavía.
- **SD-cos-5 · Smokes del DoD:** 1 spec e2e (`/` 200 + render) + 1 unit test (vitest sanity) · creados en Fase 3 porque el harness de test (vitest + playwright + configs) se está bootstrapeando en este mismo PRP · NO se pueden escribir specs antes de que exista el runner (ver nota regla #17 en Blueprint).
- **SD-cos-6 · Versiones del stack documentadas:** las versiones exactas verificadas en Fase 1 se persisten en `.claude/memory/reference/stack-versions-PRP-001.md` para que TASK-002 las herede sin re-suponer (regla no-suponer · trazabilidad).
- **SD-cos-7 · `next-env.d.ts`:** decidir commitear vs gitignore según convención oficial de Next verificada en Fase 1 (el `.gitignore` actual NO lo cubre).

### Modelo de datos

N/A · cero schema · cero migraciones · cero RPC · cero RLS (skeleton del cliente Supabase only · BD real → TASK-002).

### Claude Design handoff

N/A · cero UI nueva con decisión de UX · matriz no dispara · página mínima placeholder con primitivos directos del DS.

---

## Análisis pre-draft de las personas

> Sección contractual · outputs literales de las 4 personas (3 pre-draft Paso 2.5 + skeptic Paso 7.5).

### architect-planning

**Shape arquitectónico propuesto:** `src/app/` (layout + page + globals.css con CSS vars del theme), `src/lib/` (helpers/services por dominio · `src/lib/supabase/{client,server}.ts`), `db/migrations/` (diferido), `.env.local` + `.env.example`, `tests/e2e/` + `tests/unit/`. **Patrones a reusar:** Server Actions + Zod + permission-gate desde sesión (futuro), RLS por organization_id (futuro), Supabase client singleton, shadcn/ui + tailwindcss-animate. **Riesgos:** (1) race npm install↔husky↔dev-server typecheck → mitigación: crear `src/` mínimo + `npm install` atómicos en un commit. (2) Playwright browsers no instalados → step explícito en job e2e. (3) TEST_DATABASE_URL secret no existe → documentar pendiente, diferenciar infra base vs DB real. (4) constraints §8 aplican a nivel scaffold → leer §8 al abrir RPCs. **Simetrías cross-módulo:** stock reserve (event↔ticket) simétrico futuro · publish event simétrico · webhook como único entry de QR. **Conclusión:** adoptar stubs íntegros, extender quirúrgico, orden (1) npm install + src/ mínimo atómico, (2) cliente Supabase, (3) CI wiring + Playwright install. Riesgos conocidos y documentables · no bloqueantes para "infra base".

### complexity

**Estimación: 🟡 MEDIA.** **Fundamento:** 0 tablas (BD diferida a TASK-002), 1 pantalla mínima (layout + page + globals.css con CSS vars), lógica = instalación/config pura (sin CRUD/reglas/sincronización), 1-2 días, casos de borde pocos y mapeables (Playwright install fallback, TEST DB env injection, paridad ci.yml↔local-ci.sh con smoke existente). **Señales de inflación:** (1) "TEST DB real seedeado para e2e" → CRÍTICO: limitar a Playwright browsers install + env template + e2e estructura verde, diferir seed durable a TASK-002 (db/migrations vacío hoy). (2) "Supabase ↔ Auth en vivo" → limitar a cliente declarado en código skeleton, Auth real es TASK-002. (3) "CI 6/6 verde" → redefinir como typecheck/lint/build/unit PASAN + e2e/sql SKIP-SAFE. **Sub-descomposición:** N/A · sin partición · con las clarificaciones de scope firmadas, se mantiene 🟡 MEDIA · 1-2 días · riesgo bajo. **Estimación reconciliada por agente principal: 🟡 MEDIA · razón: la investigación confirma 0 tablas + 1 pantalla + config pura · sin señales de 6+ tablas/pantallas anidadas/sincronización que justifiquen subir a ALTA · las clarificaciones de scope (Bif 1 = A) acotan el riesgo de inflación.**

### historical-precedent

**Precedentes relevantes:** ninguno · es el PRP-001 (sin PRPs históricos · solo template + milestone bootstrap 2026-06-25). Aplican precedentes doctrinales del pack: excepción "bootstrap fundacional" de [`push-and-ci-policy.md`](../rules/push-and-ci-policy.md) (ya consumida por el bootstrap-commit · PRP-001 NO la hereda · sigue "1 push = 1 PR = 1 CI" pleno), gate local CI confirmatorio. **Decisiones 🔵 por analogía:** PRP-001 sigue la regla general de push/CI con toda su fuerza (commit+push ANTES de ci:local). **Diferencias clave:** (a) PRP-001 enmarca convenciones de todos los PRPs futuros (énfasis especial en respect-existing-folder-structure), (b) toca scaffold + CI + hooks simultáneamente (no 1 dominio), (c) sin suite de regresión heredada (pre-validation regla #16 no aplica · suite vacío al boot), (d) scaffold fundacional DEBE incluir specs mínimas (regla #17 · no omitir tests "porque es solo init"). **Gotchas seed aplicables:** dev-server-typecheck-race (commit+push antes de ci:local), skip-ci-blocks-pr-head (cero `[skip ci]` en HEAD), squash-merge-dev-divergence (sync post-merge), husky-hooks-smoke-tests (smoke si se toca hook), tests-as-dod (scaffold con ≥1 spec).

### skeptic

**Issues detectados (todos refinados en el draft · ✅ aplicado):**
- 🔴 crítico · versiones a instalar vagas ("Next 16 estable") sin lugar de documentación para que TASK-002 las herede → ✅ agregado `.claude/memory/reference/stack-versions-PRP-001.md` (SD-cos-6) + DoD Fase 1.
- 🟡 `vitest.config.ts` condicional sin criterio (riesgo especulación) → ✅ "crear SOLO si `test:unit` falla por config".
- 🟡 plugins postcss implícitos → ✅ verificado: solo `tailwindcss` + `autoprefixer` (sin ocultos).
- 🟡 `job-order-parity.sh` ¿existe? → ✅ verificado: existe · path documentado en DoD Fase 3.
- 🟢 G6 línea ~110 PENDIENTE ambigua → ✅ DoD Fase 3 explícito "comentario eliminado · step activo".

**Missing pieces (todas resueltas):** documentación de versiones (✅ reference file) · smoke paridad (✅ existe) · criterio vitest.config (✅) · `next-env.d.ts` en git (✅ SD-cos-7 + DoD Fase 1 decide por convención oficial · `.gitignore` actual no lo cubre).

**Asunciones sin firmar (resueltas como SD del agente · NO requieren firma user adicional):**
- Página `/` 100% estática sin DB query → ✅ SD-cos-4 (consecuencia directa de Bif 1 = A skeleton) · por eso e2e smoke sin TEST_DATABASE_URL.
- Pre-commit hook en primer commit post-npm-install → ✅ Fase 1 paso 6: commit atómico garantiza src/ presente cuando corre el hook (estado consistente).
- CI e2e webServer pre-warm → ✅ Fase 3 paso 3: verificar si `reuseExistingServer:true` alcanza para el smoke o requiere pre-warm.

**Contradicciones internas (resueltas):**
- Fase 1/2 sin tests vs regla #17 → ✅ Nota explícita en Blueprint: harness se bootstrapea en este PRP · specs consolidados en Fase 3 · excepción legítima acotada al PRP-001 fundacional.

**Anchor-questions sobre bifurcaciones firmadas (invitación informada al user · NO reabren la firma salvo que el user quiera):**
- Bif 1: alternativa "DB mock/sqlite en PRP-001 para e2e más realista" vs el "cero DB" firmado. El user firmó explícito diferir a TASK-002 · queda como está salvo objeción.
- Bif 2: riesgo deprecation Tailwind v3 con Next 16/React 19 a 2026-06 → ✅ mitigado: Fase 1 paso 1 verifica compat cruzada · si v3 incompatible, escala al user (puede reabrir Bif 2).

**Veredicto skeptic:** draft SÓLIDO en estructura y arquitectura · issues operativos refinados pre-firma · listo para Paso 8.

---

## Inventario de archivos afectados

| Acción | Archivo | Justificación |
|---|---|---|
| 🟡 | `package.json` | Llenar `dependencies` + `devDependencies` reales · agregar script `dev: next dev` (G1, G4) |
| 🟢 | `src/app/layout.tsx` | Layout raíz Next.js App Router (G2) |
| 🟢 | `src/app/page.tsx` | Página raíz `/` placeholder mínimo PUERTITA (G2, SD-cos-4) |
| 🟢 | `src/app/globals.css` | CSS vars del theme DS que `tailwind.config.ts` ya espera (G2) |
| 🟢 | `src/lib/supabase/client.ts` | Cliente browser `@supabase/ssr` skeleton (G3, SD-cos-2) |
| 🟢 | `src/lib/supabase/server.ts` | Cliente server `@supabase/ssr` skeleton (G3, SD-cos-2) |
| 🟢 | `src/README.md` | Layout de `src/` (regla #22 · carpeta nueva con README) |
| 🟢 | `.env.example` | Placeholders `NEXT_PUBLIC_SUPABASE_URL` + `ANON_KEY` (G3, SD-cos-3) |
| 🆕 | `tests/e2e/PRP-001-scaffold.spec.ts` | Spec smoke `/` 200 + render · DoD Fase 3 (G5) |
| 🆕 | `tests/unit/PRP-001-sanity.spec.ts` | Unit test smoke vitest · DoD Fase 3 (G5) |
| 🟡 | `.github/workflows/ci.yml` | Step `npx playwright install --with-deps` en job `e2e` · **comentario PENDIENTE (línea ~110) ELIMINADO · step activo** (G6) |
| 🟢 | `vitest.config.ts` | Config vitest · **crear SOLO si `npm run test:unit` falla por falta de config** (simplicity-first · cero especulación) |
| 🟢 | `.claude/memory/reference/stack-versions-PRP-001.md` | Versiones exactas verificadas (SD-cos-6 · tabla: librería \| versión \| verificado contra \| fecha) · MEMORY.md actualizado |
| 🟡 | `.gitignore` | Sumar `next-env.d.ts` si la convención oficial de Next lo indica (SD-cos-7) |
| 🟠 | `docs/product/product-roadmap.md` | Marcar TASK-001 con referencia PRP-001 + `[x]` al cierre |
| 🟠 | `.claude/memory/log.md` | Entry `decision` al aprobar (Paso 2) + `prp-close` al cerrar (Paso 6) |
| 🟠 | `tests/e2e/regression/COVERAGE.md` | Sumar filas de los specs nuevos del scaffold |
| ❌ | `db/migrations/*` · `db/seeds/*` | NO tocar · schema real → TASK-002 |
| ❌ | `next.config.ts` · `tsconfig.json` · `tailwind.config.ts` · `eslint.config.js` · `playwright.config.ts` · `postcss.config.js` · `components.json` | NO reescribir · solo adoptar (extensión mínima solo si un build error lo exige) |

### Carpetas nuevas propuestas (regla #23 · firma 🔵 user en aprobación)

| Carpeta | Tipo | Justificación | Alternativas evaluadas |
|---|---|---|---|
| `src/` | top-level nueva | Carpeta canónica Next.js App Router · YA pre-declarada por stubs committeados (`tsconfig` paths `@/* → ./src/*` · `tailwind.config` content · `components.json` aliases) · README obligatorio | Ninguna · es la convención del framework que el template ya fijó |
| `src/app/` · `src/lib/` · `src/lib/supabase/` | subcarpetas dentro de `src/` | Estructura canónica Next.js (routing en `app/`, helpers en `lib/`) · sub-dominio supabase agrupa los 2 clients | Ninguna · convención estándar |

**Restricciones de scope:**

- **TEST DB real + specs e2e/sql con datos → TASK-002** (🔵 Bif 1 = A). PRP-001 deja e2e smoke sin DB + sql/state-baseline skip-safe.
- Cero `src/components/ui` ni `src/lib/utils.ts` (cn) hasta caller real (TASK-002+ · simplicity-first).
- Cero auth/RLS/migraciones reales · solo cliente Supabase skeleton.
- Cero reescritura de los stubs config (solo adopción · extensión mínima justificada por build error).

---

## Blueprint (Assembly Line · 4 fases)

> Cada fase cierra con: código + tests del DoD + `npm run typecheck` verde + `npm run build` verde + commit local. NO push hasta paso 6.
>
> **Pre-step Fase 1:** suite de regresión vacío al boot (`tests/e2e/regression/COVERAGE.md` sin filas) · pre-validación regla #16 NO aplica · documentado.
>
> **Nota regla #17 (tests-as-dod-per-phase):** Fases 1 y 2 cierran con verificación mecánica (`typecheck` + `build` + `dev` arranca) SIN specs codificadas porque el harness de test (vitest + playwright + sus configs) es parte de lo que este PRP bootstrapea · no existe runner para escribir specs antes de Fase 3. Los specs del DoD (e2e smoke + unit sanity) se consolidan en Fase 3 apenas el harness está vivo · excepción legítima y acotada al PRP-001 fundacional (NO se replica en PRPs de feature, que sí tienen harness desde el inicio).

### Fase 1 — Deps reales + scaffold mínimo (atómico)

**Objetivo:** la app instala, compila y arranca. Stubs adoptados.

**Tipo:** 🟢 reversible (revert del commit borra `src/` + deps).

**Acción:**
1. Verificar versiones estables actuales contra registry/docs oficiales (Next 16, React 19, Tailwind v3, @supabase/ssr, vitest, @playwright/test, typescript-eslint + eslint plugins referenciados en `eslint.config.js`, globals, tailwindcss-animate) · **verificar compat cruzada Tailwind v3 ↔ Next 16 ↔ React 19** (si v3 está deprecada/incompatible → escalar al user antes de seguir · puede reabrir Bif 2) · regla no-suponer · **documentar versiones exactas en `.claude/memory/reference/stack-versions-PRP-001.md`**.
2. Llenar `package.json` `dependencies` + `devDependencies` + agregar `"dev": "next dev"`. (postcss verificado: solo `tailwindcss` + `autoprefixer` · sin plugins ocultos.)
3. `npm install` (activa husky vía `prepare`).
4. Crear `src/app/layout.tsx` + `src/app/page.tsx` (placeholder PUERTITA estático) + `src/app/globals.css` (CSS vars que el theme de `tailwind.config.ts` consume) + `src/README.md`.
5. Decidir `next-env.d.ts` (commitear vs `.gitignore`) según convención oficial Next.
6. **Atómico:** deps + `src/` mínimo en un solo commit · el pre-commit hook (typecheck+lint) ve un estado consistente (src/ ya existe cuando corre) · evita el race husky/dev-server.

**DoD:**
- [ ] `.claude/memory/reference/stack-versions-PRP-001.md` creado con versiones verificadas + MEMORY.md actualizado.
- [ ] `npm run typecheck` verde.
- [ ] `npm run build` verde.
- [ ] `npm run dev` arranca y `/` rinde sin error de hidratación/consola.
- [ ] `next-env.d.ts` resuelto (committeado o en `.gitignore` según convención) · cero artefacto build en git.
- [ ] Commit local `feat(PRP-001): fase 1 · deps reales + scaffold src/app mínimo`.

**Reversibilidad:** sí · revert del commit.

### Fase 2 — Cliente Supabase skeleton + env

**Objetivo:** clientes Supabase declarados (browser + server) + template de env.

**Tipo:** 🟢 reversible.

**Acción:**
1. `src/lib/supabase/client.ts` (`createBrowserClient` de `@supabase/ssr`).
2. `src/lib/supabase/server.ts` (`createServerClient` con cookies de Next).
3. `.env.example` con `NEXT_PUBLIC_SUPABASE_URL` + `NEXT_PUBLIC_SUPABASE_ANON_KEY`.

**DoD:**
- [ ] `npm run typecheck` verde · `npm run build` verde.
- [ ] Commit local `feat(PRP-001): fase 2 · cliente Supabase skeleton + .env.example`.

**Reversibilidad:** sí.

### Fase 3 — Tests del DoD + wiring CI

**Objetivo:** smokes verdes + CI con Playwright browsers + paridad local↔remoto.

**Tipo:** 🟢 reversible.

**Acción:**
1. `tests/e2e/PRP-001-scaffold.spec.ts` · navegar a `/` → status 200 + render visible (sin DB · página estática). Evitar `networkidle` (HMR/Turbopack) · usar `waitForSelector` del contenido.
2. `tests/unit/PRP-001-sanity.spec.ts` · vitest sanity. Crear `vitest.config.ts` SOLO si `npm run test:unit` falla por config (simplicity-first).
3. Editar `ci.yml` job `e2e`: agregar step `npx playwright install --with-deps` post `npm ci` · **eliminar el comentario PENDIENTE (~línea 110) · step queda activo** (mantener e2e/sql skip-safe re TEST DB). Verificar si el job e2e en CI necesita pre-warm del dev server o si `reuseExistingServer:true` del `playwright.config` alcanza para el smoke.
4. Verificar paridad `local-ci.sh` ALL_JOBS ↔ `ci.yml` con el smoke YA existente `tests/scripts/infra-flujo/job-order-parity.sh`.
5. Sumar filas a `tests/e2e/regression/COVERAGE.md`.

**DoD:**
- [ ] `npm run test:e2e -- tests/e2e/PRP-001-scaffold.spec.ts` verde.
- [ ] `npm run test:unit` verde.
- [ ] `bash tests/scripts/infra-flujo/job-order-parity.sh` exit 0.
- [ ] `ci.yml` job `e2e`: comentario PENDIENTE eliminado · step Playwright install activo.
- [ ] `npm run typecheck` + `npm run build` verdes.
- [ ] Commit local `test(PRP-001): fase 3 · smokes e2e+unit + wiring CI Playwright`.

**Reversibilidad:** sí.

### Fase 4 — Validación final

**Objetivo:** subset verde del CI end-to-end · criterios G1...G7 cumplidos.

**Acción:**
1. `npm run ci:local` (commit + push antes si se valida en paso 6 · acá local) · verificar typecheck/lint/build/unit verdes + e2e smoke verde + sql skip-safe.
2. Confirmar G1...G7 marcados.

**DoD:**
- [ ] `npm run ci:local` exit 0 (con e2e smoke + sql skip-safe).
- [ ] Criterios G1...G7 marcados.
- [ ] Commit local `chore(PRP-001): fase 4 · validación final · CI subset verde`.

---

## Criterios de éxito (binarios)

1. ✅ G1 deps instaladas · `npm ci` exit 0.
2. ✅ G2 scaffold · `npm run build` exit 0.
3. ✅ G3 cliente Supabase · `npm run typecheck` exit 0 + `.env.example`.
4. ✅ G4 script `dev` presente.
5. ✅ G5 smokes e2e + unit verdes.
6. ✅ G6 wiring CI + paridad job-order verde.
7. ✅ G7 `npm run ci:local` subset verde (e2e smoke + sql skip-safe).
8. ✅ `git diff --stat` muestra solo archivos del Inventario (cero drive-by).

---

## Aprendizajes / Self-Annealing

### 1 · eslint 10 rompe el install (plugins no lo soportan)

eslint 10.6.0 es el latest pero `eslint-plugin-react@7.37.5` (peer `≤^9.7`) y `eslint-plugin-import@2.32.0` (peer `≤^9`) no lo soportan → ERESOLVE. Root cause: los plugins van detrás del release de eslint. Fix: fijar **eslint ^9.39.4** (compat con todos + typescript-eslint 8.62). Documentado en `.claude/memory/reference/stack-versions-PRP-001.md`.

### 2 · Playwright headless-shell requiere libs de sistema

El e2e local falló con `libnspr4.so: cannot open shared object file`. Root cause: Chromium necesita libs de sistema que no vienen con el browser. Fix local: `sudo npx playwright install-deps chromium` (ojo: `sudo npx` pierde el PATH de node → usar `sudo env "PATH=$PATH" npx ...`). En CI lo cubre `--with-deps`. Candidato a memoria `feedback/` si reaparece en otra máquina.

### 3 · run-sql-tests.sh no era skip-safe (rompía Bif 1=A)

Los 5 `.sql` invariantes del template existen desde el boot pero `run-sql-tests.sh` abortaba (exit 1) sin `DATABASE_URL` → el job `sql` no podía ser skip-safe como firmó Bif 1=A. Fix: skip-safe guard al top (paridad `state-baseline.sh`). Wrinkle out-of-scope detectado: inconsistencia `DATABASE_URL` (run-sql) vs `TEST_DATABASE_URL` (smokes hermanos) → **DT-001** para TASK-002.

### 4 · Contador de tests vs meta 10-20

PRP-001 entregó **2 tests** nuevos (1 e2e regression + 1 unit). La meta canónica 10-20 (regla #17) aplica a PRPs de feature con múltiples capas de código de producción. Un scaffold fundacional tiene superficie testeable mínima (página estática + cliente skeleton sin caller) · 2 smokes es lo apropiado · las capas reales (auth · RLS · checkout · pagos) y sus 10-20 tests llegan con los PRPs de feature desde TASK-002. Deviación justificada, NO gap del DoD.

### 5 · Grep cross-codebase del root cause · N/A

PRP-001 es scaffold, no fix de bug · cero patrón de root cause replicable que gripear en `src/`. Sub-paso omitido con justificación.

---

## Cierre

Al cerrar Fase 4, marcar PRP como **EN PROGRESO (paso 3 cerrado · 4 + 5 + 6 pendientes)** · NO `COMPLETADO` (reservado a post-merge paso 6). REGLA DE ORO checklist aplica al cierre del paso 3 · ítems 4.5 (CSV) y 4.7 (ultrareview log) pendientes de pasos 5 y 6.

---

*PRP-001 pendiente aprobación. No se ha modificado código todavía.*
