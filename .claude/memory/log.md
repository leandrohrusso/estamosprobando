---
name: Bitácora cronológica del proyecto
description: Chronology append-only de eventos significativos del proyecto · cierres de PRP · decisiones grandes · incidentes · linting de memoria · directional changes
type: log
---

# Bitácora cronológica · `log.md`

> **Append-only · cero modificación retroactiva.** Fuente canónica de la regla: satélite [`log-chronology-append-only.md`](../rules/log-chronology-append-only.md). Consulta cronológica: `grep "^## \[" .claude/memory/log.md | tail -N`.

## Cómo usar este archivo

**Quién agrega entradas:** el agente, al cierre de cada PRP del proyecto · al cerrar una decisión grande · al detectar un incidente · al ejecutar el lint de memoria periódico.

**Cuándo agrega entradas (triggers):**

- Al cerrar un PRP (cualquier modo C del producto · cualquier mini-PRP) → 1 entrada `prp-close`.
- Al firmar una decisión arquitectónica con tag 🔵 que afecta cómo trabaja el agente o la estructura del proyecto → 1 entrada `decision`.
- Al detectar un incidente en producción o durante validación → 1 entrada `incident`.
- Al ejecutar el lint de memoria periódico (regla [`lint-memory-periodic.md`](../rules/lint-memory-periodic.md)) → 1 entrada `lint`.
- Al cambiar de dirección estratégica del proyecto (rename de módulos · pivote de scope · rama nueva del flujo) → 1 entrada `directional`.
- Al alcanzar un hito mayor (PR mergeado · suite de tests verde por primera vez · onboarding de nuevo colaborador) → 1 entrada `milestone`.

**Formato canónico de cada entrada:** un h2 con prefijo de fecha entre corchetes + tipo de evento + título corto, seguido de líneas Resumen + Detalle (opcional) + Refs. Estructura literal (indent con 4 espacios para que la consulta `grep "^## \["` NO matchee este ejemplo):

    [encabezado h2 con la sintaxis exacta:] ## [YYYY-MM-DD] <op> | <título corto>

    **Resumen:** 1-2 frases describiendo qué pasó.
    **Detalle:** opcional · 2-5 líneas si el evento amerita.
    **Refs:** commit `<hash>` · PRP-NNN · memoria `<path>` · ticket `<id>` (al menos 1 ref operativa).

**Tipos `<op>` válidos:**

| `<op>` | Cuándo usarlo |
|---|---|
| `prp-close` | Cierre de un PRP (modo C del producto · mini-PRP) |
| `decision` | Decisión arquitectónica firmada con tag 🔵 + justificación 1-frase del user |
| `incident` | Bug en producción · regresión detectada en validación · CI roto · bloqueo de flujo |
| `directional` | Cambio de dirección del proyecto (pivote · rename de módulos · rama nueva del flujo) |
| `milestone` | Hito mayor (PR mergeado · primer release · onboarding) |
| `lint` | Ejecución del lint de memoria periódico |

**Reglas operativas firmes:**

- ✅ **Append-only** · cero modificación retroactiva · cero borrado de entradas pasadas.
- ✅ **Orden cronológico estricto** · entradas nuevas se agregan al final del archivo.
- ✅ **1 entrada por evento** · cada `prp-close` · `decision` · etc., genera 1 sola entrada · NO duplicar.
- ❌ **NO backfill** · el pasado pre-adopción de este archivo NO se reconstruye acá · queda en git log + memorias project/.
- ❌ **NO modificar** entradas pasadas (excepto fix de typo en el commit que las creó · NO post-hoc).

---

<!-- Las entradas reales empiezan acá. Ejemplo de la primera entrada cuando arranca el proyecto (indent con 4 espacios para que `grep "^## \[" log.md` NO matchee este ejemplo · paridad con el ejemplo del § "Cómo usar este archivo" arriba):

    ## [YYYY-MM-DD] milestone | Boot del proyecto · pack workflow-base adoptado

    **Resumen:** Repo inicial creado con el pack universal workflow-base (rules + skills + memoria + infra + gobernanza). Adaptación al stack del proyecto pendiente.

    **Refs:** commit inicial · pack [`github.com/leandrohrusso/workflow-base`](https://github.com/leandrohrusso/workflow-base).

-->

## [2026-06-25] milestone | Bootstrap de PUERTITA · pack workflow-base adaptado al stack + PRD v1 como SoT

**Resumen:** Sesión inicial del proyecto. `/arrancar` detectó estado post-template (5/5 condiciones) y se ejecutó el bootstrap mecánico adaptando el pack workflow-base al stack de PUERTITA (SaaS multitenant de ticketing para eventos), a partir del PRD v1.0 provisto por el user.

**Detalle:** PRD commiteado en `docs/product/references/PRD.md` como SoT inmutable del bootstrap (encoding UTF-8 reconstruido del paste). Llenados: CLAUDE.md (nombre + one-liner), BUSINESS_LOGIC.md §1-§9 (incluye 12 constraints firmes), `package.json` (scripts del stack: tsc/eslint/next/vitest/playwright), `.claude/config/agents-applicability.yml` (3 flags domain-tight en `yes`: multi-tenant · atomicity · migration-safety), `scripts/local-ci.sh` + `.github/workflows/ci.yml` (limpieza de TODOs/guías ya decididas · 6 jobs · paridad intacta), `docs/product/product-roadmap.md` (15 tasks derivadas del PRD v1), `docs/logs/deadlines.md` (cadencias mensuales → 2026-07-25). Stack: Next.js App Router + Supabase (Postgres+RLS+Auth+Edge Functions) + Mercadopago/Mobbex + Resend + Vercel. Pendiente del primer PRP (TASK-001): scaffold real del app + wiring final del CI (deps, Playwright browsers, secrets, TEST DB).

**Refs:** PRD `docs/product/references/PRD.md` · `BUSINESS_LOGIC.md` · `docs/product/product-roadmap.md` · pack [`workflow-base`](https://github.com/leandrohrusso/workflow-base).

## [2026-06-26] decision | PRP-001 scaffold + infra base APROBADO · 2 bifurcaciones firmadas

**Resumen:** `/planificar` generó y aprobó PRP-001 (TASK-001 · scaffold real del app + wiring CI). Modo C complejo · 4 personas pre/post-draft (architect-planning · complexity 🟡 MEDIA · historical-precedent · skeptic).

**Detalle:** 🔵 Bif 1=A (frontera de scope: PRP-001 entrega deps + src/app mínimo + cliente Supabase skeleton + CI con typecheck/lint/build/unit verdes + e2e smoke sin DB + sql/state-baseline skip-safe · TEST DB real + specs e2e/sql con datos diferidos a TASK-002 donde nace el schema). 🔵 Bif 2=A (Tailwind v3 · respeta los stubs del template · cero reescritura · migración a v4 sería PRP propio). Claude Design SKIP firmado (matriz no dispara · página placeholder estática). Skeptic levantó 5 issues operativos + asunciones · todos refinados pre-firma (versiones del stack a documentar en `.claude/memory/reference/stack-versions-PRP-001.md` para que TASK-002 las herede · criterio para vitest.config · next-env.d.ts por convención oficial · nota regla #17 tests en Fase 3 por bootstrapping del harness). Commit local sin push (regla #27 · push reservado al paso 6).

**Refs:** PRP `.claude/PRPs/PRP-001-scaffold-infra-base.md` · roadmap TASK-001 · `BUSINESS_LOGIC.md §7`.

## [2026-07-01] prp-close | PRP-001 scaffold + infra base mergeado a main

**Resumen:** PRP-001 (TASK-001 · scaffold + infra base) entregado a `main` vía PR #1 `--squash` (`e4a9036`). Primer PRP del proyecto · trajo bootstrap + scaffold a `main` juntos (política del bootstrap fundacional).

**Detalle:** Flujo de 6 pasos completo: /planificar (2 bifurcaciones 🔵 + Claude Design SKIP) → /implementar (4 fases · ci:local 6/6) → /revisar-simple (0 critical · 0 normal · 1 nit fixeado) → /validar SKIP firmado (scaffold sin superficie validable) → /entregar (ci:local gate → push → PR #1 draft → decisión NO /ultrareview → gh pr ready → CI remoto 1 run verde → merge --squash → sync-dev). Entregó: Next 16.2.9 + React 19.2.7 + Tailwind v3.4.19 (Bif 2=A) + @supabase/ssr skeleton + eslint 9 (no 10 por compat) + TS 6 · `src/app` + globals.css con tokens DS · wiring CI (Playwright --with-deps · run-sql-tests skip-safe · job-order-parity). Gotchas: eslint 10 rompe install · Playwright system libs (sudo install-deps) · run-sql skip-safe. Sync post-squash: force-with-lease benigno (remoto ya en target) · invariante origin/dev==origin/main verificado. Scope 🔵 Bif 1=A: TEST DB + auth/RLS + specs con datos → TASK-002. DT-001 abierta.

**Refs:** PR #1 · commit `e4a9036` · PRP `.claude/PRPs/PRP-001-scaffold-infra-base.md` · roadmap TASK-001 · DT-001.

## [2026-07-01] decision | PRP-002 auth + organizaciones + memberships + RLS base APROBADO · 5 bifurcaciones firmadas

**Resumen:** PRP-002 (TASK-002) planificado y APROBADO. Complejidad 🟡 MEDIA · 4 fases (Fase 1 punto-de-no-retorno · DDL en TEST DB cloud). Cierra DT-001 (`DATABASE_URL`→`TEST_DATABASE_URL`).

**Detalle:** `/planificar` con 3 personas pre-draft (architect-planning · complexity MEDIA · historical-precedent) + skeptic post-draft (6 refinamientos incorporados: redirect explícito · gate TEST_DATABASE_URL · sesión de test vía Admin API · índice compuesto RLS · slug validado/inmutable · guard service_role). Bifurcaciones 🔵 user 2026-07-01: **Bif1=A** helper `SECURITY DEFINER` (`is_member_of`/`has_role`) para RLS · **Bif2=A** onboarding "crear org" un-paso → Owner · **Bif3=A** alta de miembro por email+rol → membership `pending` → vinculación al login, sin Resend · **Bif4=A** audit_log diferido a TASK-003 · **Claude Design SKIP** (backoffice convencional). Modelo: `organizations` + `memberships` (enums role/status) + helpers SECURITY DEFINER + RPCs `create_organization_with_owner`/`link_pending_memberships`. Routing path-based `/{org-slug}` (PRD §3.3). Superadmin/Resend/tablas de negocio fuera de scope.

**Refs:** PRP `.claude/PRPs/PRP-002-auth-organizations-memberships-rls.md` · roadmap TASK-002 · DT-001 (destino).

## [2026-07-04] prp-close | PRP-002 auth + organizaciones + memberships + RLS base mergeado a main

**Resumen:** PRP-002 (TASK-002) COMPLETADO · mergeado `--squash` a `main` (`80964f0`) · CI remoto 7/7 verde. Fundación de identidad + aislamiento multi-tenant: magic link, `organizations`/`memberships`, RLS por `organization_id` vía helpers `SECURITY DEFINER`, RBAC Owner/Admin/Staff, onboarding→Owner, selector multi-org. DT-001 cerrada.

**Detalle:** Flujo 6 pasos completo. Paso 4 `/revisar` (LR-001+LR-002 · 9 agentes · 15 normales fixeados + 5 DT). Paso 5 `/validar` · CSV 56 filas 55 Funciona/1 Diferido (AUTH3→DT-003 SMTP built-in) · 1 bug fixeado (locator e2e `exact` colisión aria-label superstring) + cobertura nueva (no-miembro→404 · Owner inmutable UI). Paso 6 `/entregar` (camino SIN `/ultrareview` · decisión NO firmada user): `ci:local` 6/6 → push único → CI remoto. **2 CI-red in-scope fixeados** (TASK-002 activa la TEST DB real en CI · el workflow lo anticipaba): (1) env secrets Supabase faltantes en jobs e2e/sql → cableado + 4 secrets cargados por user · (2) `Node.js 20 without native WebSocket` en el helper e2e (createClient eager RealtimeClient) → devDep `ws` + polyfill `globalThis.WebSocket`. Gotcha operativo: `sync-dev-after-squash-merge.sh` salió exit 1 (force-push rechazado porque `origin/dev` ya estaba en el squash SHA) pero el estado quedó correcto (todas las refs alineadas · 0 divergencia · verificado manual). Bootstrap tooling: se instaló `postgresql-client-17` (server PG 17.6 · preflight `ci:local` exige match exacto).

**Refs:** commit merge `80964f0` · PR #2 · `docs/logs/ultrareview-log.md` (decisión NO PRP-002) · CSV `tests/manual/PRP-002_auth-organizations-memberships-rls-validation.csv` · memorias `feedback/playwright-getbylabel-substring-collision.md` + `feedback/supabase-js-node20-websocket-polyfill.md` · DTs abiertas 003/006/007/008.
