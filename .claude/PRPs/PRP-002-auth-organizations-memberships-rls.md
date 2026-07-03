# PRP-002 · Auth + organizaciones + memberships + RLS base

> **Estado**: APROBADO
> **Fecha**: 2026-07-01
> **Proyecto**: PUERTITA
> **Tipo**: feature producto
> **Modo**: C completo (6 pasos)
> **Cardinalidad de fases**: 4 fases · reversibles salvo Fase 1 (punto-de-no-retorno · DDL aplicado a TEST DB cloud)
> **Tarea del roadmap cubierta**: TASK-002
> **Riesgo**: 🟡 Medio · primera BD real + RLS multi-tenant + auth vivo · el aislamiento cross-tenant es game-over si falla (constraint #1)
> **Complejidad estimada**: 🟡 MEDIA · reconciliada por el agente principal (persona `complexity` estimó MEDIA · se sostiene MEDIA porque las dos señales de inflación se mitigaron por firma 🔵 user: alta de miembros sin Resend (Bif 3=A) + audit_log diferido a TASK-003 (Bif 4=A))

> **Progreso del flujo de 6 pasos:**
> 1. ☑ `/arrancar`
> 2. ☑ `/planificar` → APROBADO (2026-07-01 · 5 bifurcaciones firmadas 🔵 user)
> 3. ☐ `/implementar` (2/4 fases · Fase 2 cerrada)
> 4. ☐ `/revisar`
> 5. ☐ `/validar` (CSV)
> 6. ☐ `/entregar` (ci:local + push + CI remoto + merge --squash)

---

## Objetivo

Establecer la fundación de identidad y aislamiento multi-tenant de PUERTITA: login por magic link (organizadores y staff), las tablas `organizations` y `memberships`, RLS por `organization_id` en toda tabla de negocio leída vía `memberships`, RBAC Owner/Admin/Staff, onboarding autónomo (primer login → crear organización → Owner), selección de organización para usuarios con múltiples memberships, y routing path-based `/{org-slug}/...`. Cierra DT-001 cableando la TEST DB real con `TEST_DATABASE_URL` unificada.

**Métrica binaria de éxito:** el test SQL de aislamiento cross-tenant (`tests/sql/PRP-002-rls-isolation.sql`) retorna 0 filas de la org ajena bajo el rol `authenticated` de un usuario que no pertenece a ella · `bash scripts/test-migrations.sh` verde · `bash scripts/run-sql-tests.sh` corre real (no skip) con `TEST_DATABASE_URL`.

---

## Por Qué

| Problema | Solución |
|---|---|
| Sin auth ni tenancy, el producto no puede tener organizadores reales ni separar sus datos · cualquier feature siguiente (eventos, entradas, ventas) necesita saber "de qué org es esta fila" y "quién puede tocarla". Una fuga cross-tenant es game-over legal y de confianza (constraint #1). | Modelo pooled + RLS por `organization_id` derivado de la sesión/membership (nunca de input del cliente) + RBAC de 3 roles + magic link sin contraseñas. Es la base sobre la que se apoyan TASK-003+. |

**Valor de negocio:**
- Habilita el **onboarding autónomo** (KPI del PRD §6 / constraint #3): un organizador nuevo llega de cero a su organización sin intervención del equipo de plataforma.
- Materializa el **aislamiento estricto por RLS** (constraint #1) como línea de defensa principal · la seguridad deja de depender de que el código recuerde filtrar.

---

## Qué

### Criterios de Éxito (binarios verificables · prefijo G1...)

- [ ] **G1 · Schema + RLS aplicados e idempotentes** · `bash scripts/test-migrations.sh` verde (aplica migraciones 2× · dumps idénticos).
- [ ] **G2 · Aislamiento cross-tenant** · `tests/sql/PRP-002-rls-isolation.sql` verde: un usuario de la org A obtiene 0 filas de la org B en `organizations` y `memberships`.
- [ ] **G3 · Helpers RLS correctos** · `is_member_of(org)` y `has_role(org, roles)` retornan el booleano esperado según memberships `active` (test SQL).
- [x] **G4 · Onboarding** · e2e (Fase 2): usuario nuevo sin org → pantalla "crear organización" → al confirmar existe 1 fila `organizations` + 1 `memberships` con `role='owner'`, `status='active'` · slug determinístico validado.
- [~] **G5 · Magic link** · Fase 2 · **parcial**: el callback (`/auth/confirm`) establece sesión y redirige según membership → ✅ probado end-to-end por G4 vía el route real. El form de login (validación + estructura) ✅ probado. El happy-path "form→enviado" (envío real de email) → diferido a **DT-003** (SMTP built-in rate-limited · disparador TASK-008 Resend) · cubierto por smoke visual Fase 4 + manual.
- [ ] **G6 · RBAC gate** · e2e: un usuario `staff` que navega a la página de gestión de miembros es redirigido/bloqueado (403) · un `owner` la ve.
- [ ] **G7 · Selección de organización** · e2e: usuario con ≥2 memberships ve el selector y al cambiar de org cambia el contexto (`/{org-slug}/...`).
- [ ] **G8 · Alta de miembro por email** · e2e/SQL: Owner da de alta email+rol → `membership` `pending` (user_id NULL) → al hacer login esa persona, se vincula (`user_id` seteado, `status='active'`).
- [ ] **G9 · DT-001 cerrada** · `run-sql-tests.sh` usa `TEST_DATABASE_URL` (grep no encuentra `DATABASE_URL` como var de conexión) · suite SQL corre real.
- [ ] **G10 · Cobertura DoD** · 10-20 tests nuevos entre `tests/sql/` y `tests/e2e/regression/` (regla #17) · `npm run typecheck` + `npm run build` verdes.

### Comportamiento Esperado (Happy Paths)

**Happy path 1 (organizador nuevo):** entra a `/login` → ingresa email → recibe magic link → click → callback establece sesión → como no tiene membership, va a `/onboarding` → ingresa nombre de la organización (slug auto) → queda Owner → aterriza en `/{org-slug}/dashboard`.

**Happy path 2 (miembro invitado):** el Owner, en `/{org-slug}/members`, da de alta `staff@mail.com` con rol Staff → se crea `membership` `pending`. Esa persona entra a `/login` con ese email → magic link → al establecer sesión, `link_pending_memberships()` vincula la membership (`user_id` seteado, `status='active'`) → aterriza en `/{org-slug}/dashboard` con permisos Staff (sin acceso a `/members`).

**Happy path 3 (multi-org):** un usuario con memberships en 2 organizaciones entra → callback lo lleva a `/select-organization` → elige una → `/{org-slug}/dashboard`.

---

## Contexto

### Referencias del codebase (SoT)

- [`src/lib/supabase/server.ts`](../../src/lib/supabase/server.ts) · [`src/lib/supabase/client.ts`](../../src/lib/supabase/client.ts) — skeletons de PRP-001 con `@supabase/ssr` · se **extienden** (no se reescriben) con auth real. El comentario "si hay middleware refrescando la sesión" se materializa en `src/middleware.ts`.
- [`db/migrations/README.md`](../../db/migrations/README.md) — convención `00NN_<slug>.sql` idempotente · cero migraciones existentes (este PRP crea las primeras).
- [`scripts/run-sql-tests.sh`](../../scripts/run-sql-tests.sh) — usa `DATABASE_URL` (DT-001) · se unifica a `TEST_DATABASE_URL` (paridad `state-*.sh` + `test-migrations.sh`).
- [`docs/logs/technical-debt.md`](../../docs/logs/technical-debt.md) DT-001 — se cierra en Fase 1.
- [`.claude/memory/reference/stack-versions-PRP-001.md`](../../.claude/memory/reference/stack-versions-PRP-001.md) — versiones congeladas heredadas (Next 16.2.9 · React 19.2.7 · Tailwind v3.4.19 · eslint ^9.39.4 · TS 6.0.3) · cero upgrade sin PRP propio.
- [`docs/product/references/PRD.md`](../../docs/product/references/PRD.md) §3 (multitenant pooled+RLS), §4 (RBAC), §13 (modelo de datos orientativo).

### Patrones existentes a respetar (regla [`simplicity-first.md`](../rules/simplicity-first.md) · reusar > recrear)

- `@supabase/ssr` + cookies — reusar los skeletons `src/lib/supabase/{client,server}.ts`, no recrear el patrón de cookies.
- Server Actions con patrón `validate Zod → auth (sesión) → permission (RLS/rol) → exec → (audit diferido)` · el `organization_id` se resuelve del path/sesión, nunca de input del cliente.
- Migraciones SQL en `db/migrations/00NN_*.sql` · idempotentes ([`migrations-idempotency.md`](../rules/migrations-idempotency.md)).
- Seeds durables en `db/seeds/test/*.sql` con UPSERT id fijo ([`seed-upsert-with-fixed-id.md`](../rules/seed-upsert-with-fixed-id.md)).
- Stack confirmado: [`BUSINESS_LOGIC.md § 7`](../../BUSINESS_LOGIC.md).
- **Verificación contra las decisiones no negociables** [`BUSINESS_LOGIC.md § 8`](../../BUSINESS_LOGIC.md): constraints #1 (RLS/aislamiento), #10 (service_role solo server/Edge), #11 (audit — diferido a TASK-003 por Bif 4=A).

### Reglas firmes aplicables (`.claude/rules/`)

- [`principios-desarrollo-flujo.md`](../rules/principios-desarrollo-flujo.md) — RLS en TODAS las tablas · Zod en endpoints · ≤5 KPIs · defensa en capas.
- [`migrations-idempotency.md`](../rules/migrations-idempotency.md) — `CREATE TABLE IF NOT EXISTS` · `DROP POLICY IF EXISTS` antes de `CREATE POLICY` · bloque `DO $$ EXCEPTION WHEN duplicate_object` para enums.
- [`seed-upsert-with-fixed-id.md`](../rules/seed-upsert-with-fixed-id.md) — fixtures durables con UUID fijo + `ON CONFLICT (id) DO UPDATE`.
- [`routing-paths-in-english.md`](../rules/routing-paths-in-english.md) — segments en inglés (`login` · `onboarding` · `select-organization` · `members` · `dashboard` · `auth/confirm`) · el `[orgSlug]` es contenido del usuario (libre).
- [`tests-as-dod-per-phase.md`](../rules/tests-as-dod-per-phase.md) — 2-5 tests por fase · 10-20 totales · regression-first FIRME.
- [`quality-standard-senior.md`](../rules/quality-standard-senior.md) · [`surgical-changes.md`](../rules/surgical-changes.md) · [`simplicity-first.md`](../rules/simplicity-first.md) · [`no-suponer-fuente-de-verdad.md`](../rules/no-suponer-fuente-de-verdad.md) (verificar helper exacto de magic-link contra docs oficiales Supabase antes de codear) · [`ante-duda-preguntar-user.md`](../rules/ante-duda-preguntar-user.md) · [`status-tracker-visible.md`](../rules/status-tracker-visible.md) · [`folder-creation-with-readme.md`](../rules/folder-creation-with-readme.md) · [`husky-hooks-smoke-tests.md`](../rules/husky-hooks-smoke-tests.md) · [`register-out-of-scope-as-dt.md`](../rules/register-out-of-scope-as-dt.md).

Tabla canónica completa: [`CLAUDE.md § Reglas FIRMES`](../../CLAUDE.md).

### Decisiones cerradas (firmas 🔵 user · 2026-07-01)

- **🔵 Bif 1 · Lectura de membership en RLS — Opción A firmada por user · 2026-07-01** · *"a"* → helper SQL `SECURITY DEFINER` (`is_member_of` / `has_role`) invocado por las policies · evita recursión de RLS sobre `memberships` · frescura inmediata en cambios de rol · patrón oficial Supabase. JWT claims descartado (rol stale hasta refresh) · queda como optimización futura si aparece problema de performance real.
- **🔵 Bif 2 · Onboarding primer login — Opción A firmada por user · 2026-07-01** · *"A"* → pantalla "crear organización" de un paso (nombre → slug auto) · el usuario queda Owner y entra a su dashboard · sin auto-create silencioso.
- **🔵 Bif 3 · Alcance del alta de miembros — Opción A firmada por user · 2026-07-01** · *"A"* → Owner da de alta por email+rol → `membership` `pending` (sin `user_id`) → vinculación automática al login por email · **sin Resend** (link compartido a mano · el envío automático llega en TASK-008). Da RBAC multi-miembro real y testeable sin inflar a ALTA.
- **🔵 Bif 4 · audit_log — Opción A firmada por user · 2026-07-01** · *"A"* → diferido a TASK-003 (su primer caller natural: audit de publicar/cancelar). Gap conocido: alta/baja de miembros no auditada hasta TASK-003 (secuenciado del roadmap · no DT).
- **🔵 Claude Design SKIP firmado por user · 2026-07-01** · *"A"* → matriz dispara NO/CHICO para forms simples + shell de backoffice convencional · primitivos del DS directo (shadcn/ui + tokens, con criterio de layout) · el diferencial de diseño se reserva para las superficies consumer-facing (TASK-005+).

### Sub-decisiones cosméticas (cerradas con recomendación early · agente decide · firma 🔵 implícita al aprobar el PRP)

- **SD-cos-1 · Onboarding vía RPC `SECURITY DEFINER`:** la creación de org + membership Owner se hace con `create_organization_with_owner(name, slug)` (SECURITY DEFINER) para resolver atómicamente el chicken-and-egg de RLS (un usuario sin membership no puede insertar su propia membership Owner bajo la policy owner-gated). Única opción razonable dado Bif 1.
- **SD-cos-2 · Vinculación de pending vía RPC `link_pending_memberships()`:** SECURITY DEFINER · corre al establecer sesión · setea `user_id=auth.uid()` + `status='active'` en memberships `pending` cuyo `email = auth.email()`. Consecuencia mecánica de Bif 3.
- **SD-cos-3 · Enums Postgres para rol y estado:** `membership_role AS ENUM ('owner','admin','staff')` + `membership_status AS ENUM ('pending','active')` · KISS · scope de roles congelado (constraint #12). Evolución a tabla de permisos sería PRP propio.
- **SD-cos-4 · Split de migraciones:** `0001` (enums+tablas+índices) · `0002` (helpers+RLS+policies) · `0003` (RPCs de onboarding). Legibilidad + idempotencia por archivo.
- **SD-cos-5 · Route groups:** `(auth)` para login/onboarding/select-organization (sin org en el path) · `(org)/[orgSlug]/...` para superficies con tenant. Segments en inglés.
- **SD-cos-6 · shadcn/ui acotado:** inicializar solo los primitivos con caller real en este PRP (`button` · `input` · `label` · `card` + `cn` en `src/lib/utils.ts`). Cero componentes sin caller (simplicity-first).
- **SD-cos-7 · Middleware thin + layout heavy:** `src/middleware.ts` solo refresca la sesión Supabase (edge-safe · patrón `updateSession`) · la validación de membership/rol vive en `(org)/[orgSlug]/layout.tsx` (server component con acceso pleno). Evita las limitaciones del edge runtime.
- **SD-cos-8 · Slug de la org:** derivado del nombre en `slugify()` → `lowercase` + alfanumérico + guiones simples + `≤ 63` chars · unicidad garantizada por `UNIQUE(slug)` (reintentar con sufijo `-2`, `-3` en colisión) · **inmutable post-creación** (cambiarlo rompería URLs públicas · edición futura sería PRP propio). Owner puede editar `name`/`payment_account_ref`/`fee_*` (política `org_update`), nunca `slug`.
- **SD-cos-9 · Redirect post-login (algoritmo explícito):** en `auth/confirm`, tras `link_pending_memberships()`, contar memberships `active` del usuario → **0** → `/onboarding` · **1** → `/{org-slug}/dashboard` de esa org · **≥2** → `/select-organization`.
- **SD-cos-10 · Sesiones de test e2e:** las sesiones para specs e2e se generan con la **Supabase Admin API** (`service_role` key SOLO en el entorno de test/CI · nunca en `src/`) creando/confirmando un test user y estableciendo cookies de sesión · se verifica el helper exacto contra docs `@supabase/ssr` 0.12 en Fase 2 (regla no-suponer). Alternativa si Supabase expone helper de test nativo · se adopta el oficial.

### Modelo de datos

```sql
-- db/migrations/0001_organizations_and_memberships.sql
DO $$ BEGIN
  CREATE TYPE public.membership_role AS ENUM ('owner','admin','staff');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.membership_status AS ENUM ('pending','active');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS public.organizations (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                TEXT NOT NULL,
  slug                TEXT NOT NULL UNIQUE,
  payment_account_ref TEXT,
  fee_pct             NUMERIC(5,2) NOT NULL DEFAULT 0,
  fee_fixed           INTEGER      NOT NULL DEFAULT 0,
  created_at          TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.memberships (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE,  -- NULL mientras pending
  email           TEXT NOT NULL,
  role            public.membership_role   NOT NULL DEFAULT 'staff',
  status          public.membership_status NOT NULL DEFAULT 'pending',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (organization_id, email)
);
CREATE INDEX IF NOT EXISTS idx_memberships_user  ON public.memberships(user_id);
CREATE INDEX IF NOT EXISTS idx_memberships_org   ON public.memberships(organization_id);
CREATE INDEX IF NOT EXISTS idx_memberships_email ON public.memberships(lower(email));
-- hot-path de los helpers RLS is_member_of()/has_role() (org + user + status)
CREATE INDEX IF NOT EXISTS idx_memberships_org_user_status
  ON public.memberships(organization_id, user_id, status);
```

```sql
-- db/migrations/0002_rls_and_helpers.sql
-- Helpers SECURITY DEFINER (corren fuera de RLS · evitan recursión sobre memberships)
CREATE OR REPLACE FUNCTION public.is_member_of(org UUID)
RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.memberships m
    WHERE m.organization_id = org AND m.user_id = auth.uid() AND m.status = 'active'
  );
$$;

CREATE OR REPLACE FUNCTION public.has_role(org UUID, roles public.membership_role[])
RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.memberships m
    WHERE m.organization_id = org AND m.user_id = auth.uid()
      AND m.status = 'active' AND m.role = ANY(roles)
  );
$$;

ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.memberships   ENABLE ROW LEVEL SECURITY;

-- organizations
DROP POLICY IF EXISTS org_select ON public.organizations;
CREATE POLICY org_select ON public.organizations
  FOR SELECT TO authenticated USING (public.is_member_of(id));

DROP POLICY IF EXISTS org_update ON public.organizations;
CREATE POLICY org_update ON public.organizations
  FOR UPDATE TO authenticated USING (public.has_role(id, ARRAY['owner']::public.membership_role[]));

-- (INSERT de organizations se hace solo vía RPC create_organization_with_owner · sin policy INSERT abierta)

-- memberships
DROP POLICY IF EXISTS mbr_select ON public.memberships;
CREATE POLICY mbr_select ON public.memberships
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.is_member_of(organization_id));

DROP POLICY IF EXISTS mbr_write ON public.memberships;   -- INSERT/UPDATE/DELETE: solo Owner de la org
CREATE POLICY mbr_write ON public.memberships
  FOR ALL TO authenticated
  USING (public.has_role(organization_id, ARRAY['owner']::public.membership_role[]))
  WITH CHECK (public.has_role(organization_id, ARRAY['owner']::public.membership_role[]));
```

```sql
-- db/migrations/0003_onboarding_rpcs.sql
CREATE OR REPLACE FUNCTION public.create_organization_with_owner(p_name TEXT, p_slug TEXT)
RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE new_org UUID;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'no session'; END IF;
  INSERT INTO public.organizations (name, slug) VALUES (p_name, p_slug) RETURNING id INTO new_org;
  INSERT INTO public.memberships (organization_id, user_id, email, role, status)
  VALUES (new_org, auth.uid(), auth.email(), 'owner', 'active');
  RETURN new_org;
END; $$;

CREATE OR REPLACE FUNCTION public.link_pending_memberships()
RETURNS integer LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE n integer;
BEGIN
  IF auth.uid() IS NULL THEN RETURN 0; END IF;
  UPDATE public.memberships
     SET user_id = auth.uid(), status = 'active'
   WHERE user_id IS NULL AND lower(email) = lower(auth.email());
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END; $$;
```

> **Nota no-suponer:** el flujo exacto del magic link (route `/auth/confirm` con `verifyOtp({token_hash,type})` vs `/auth/callback` con `exchangeCodeForSession`) se **verifica contra docs oficiales Supabase `@supabase/ssr` 0.12** en Fase 2 antes de codear (regla [`no-suponer-fuente-de-verdad.md`](../rules/no-suponer-fuente-de-verdad.md)). El PRP asume `/auth/confirm` (patrón SSR vigente) pero no lo firma como inmutable.

### Claude Design handoff

**N/A · cero UI nueva que la matriz dispare** · primitivos directos del DS (shadcn/ui + tokens de `src/app/globals.css`) · firma 🔵 Claude Design SKIP (arriba). Superficies: forms de login/onboarding/alta-miembro + selector de org + shell de dashboard = backoffice convencional.

---

## Análisis pre-draft de las personas

> Outputs literales de las 4 personas (`/planificar` Pasos 2.5 + 7.5). Trazabilidad versionada en git.

### architect-planning

**Shape propuesto** (capas): BD (`db/migrations/0001..0003`), servicios (`src/lib/auth/{session,org,slug}.ts`, `src/lib/supabase/*`), UI (`src/app/(auth)/*`, `src/app/(org)/[orgSlug]/*`, `src/middleware.ts`, `src/components/*`), tests (`tests/sql/`, `tests/e2e/`).

**Patrones a reusar:** `@supabase/ssr`+cookies (skeletons existentes) · Server Actions `use server` con Zod · RLS como defensa en capas · path-based `[org-slug]` (PRD §3.3) · middleware de sesión (esqueleto advertido en `server.ts`).

**Riesgos arquitectónicos:**
- **#1 Recursión RLS al leer memberships (CRÍTICO):** policy sobre `memberships` que lee `memberships` → recursión. Mitigación: helper `SECURITY DEFINER` `is_member_of()`/`has_role()` (corre fuera de RLS). **[Cerrado por Bif 1=A.]**
- **#2 Service_role leakage (CRÍTICO · constraint #10):** anon key SIEMPRE en cliente/servidor · service_role NUNCA en `src/` · si aparece en review → halt. RLS hace toda la validación.
- **#3 org_id derivation (CRÍTICO · constraint #1):** `organization_id` de path/sesión, nunca de input del cliente · validar pertenencia explícita en cada Server Action.
- **#4 Magic link session persistence (ALTO):** callback debe intercambiar token y escribir sesión a cookies correctamente (verificar helper `@supabase/ssr` exacto).
- **#5 RLS incompleteness (ALTO):** cada tabla de negocio futura debe llevar policy · el agente `multi-tenant` de `/revisar` lo verifica.

**Simetrías cross-módulo:** N/A en este PRP (todavía no hay `events/tickets/orders`). Futuros PRPs copian el patrón `organization_id + policy is_member_of()` por tabla.

**Reglas firmes aplicables:** `principios-desarrollo-flujo` · `routing-paths-in-english` · `migrations-idempotency` · `seed-upsert-with-fixed-id` · `husky-hooks-smoke-tests` · `always-fix-all-bugs`. DT-001 se cierra al unificar `TEST_DATABASE_URL`.

**Alternativas superiores:** (a) RLS lookup: helper SECURITY DEFINER (recomendado) vs JWT claims hook (stale) → **A**. (b) Middleware: thin (sesión) + layout heavy (validación) por límites edge runtime → híbrido. (c) Roles: enum vs tabla → enum (KISS, scope congelado). (d) Onboarding: "crear org de un click" vs auto-create silencioso → click.

### complexity

**Estimación: 🟡 MEDIA.** Fundamento: modelo de datos 2 tablas nuevas + 2 enums (relaciones 1:N simples, sin polimorfismo); UI 4-5 pantallas simples (forms + selector + shell); lógica RBAC + resolución org_id + RLS (multi-nivel pero sin sincronizaciones remotas); tiempo 1-3 días con Claude Code; casos de borde mapeables (first login, multi-membership, miembro removido mid-sesión, 403). **Señales de inflación:** (1) invitación por email (Resend no está hasta TASK-008) → mitigar con alta manual/pending; (2) audit_log → postergar a TASK-003; (3) middleware+guard+slug → mantener thin; (4) RLS+helpers → 1-2 policies por tabla, tests SQL mínimos. **Sub-descomposición:** N/A · MEDIA cohesiva en 1 PRP (dividir en BAJA×3 crearía dependencias secuenciales estériles). **Reconciliación agente principal:** 🟡 MEDIA confirmada · las 2 señales principales quedan mitigadas por Bif 3=A + Bif 4=A.

### historical-precedent

**Precedente único:** PRP-001 (scaffold+infra base, 2026). Cero PRPs de feature previos.

**Decisiones firmadas que aplican:**
- **🔵 PRP-001 Bif 1=A · 2026-06-26** · *"TEST DB real + specs e2e/sql → TASK-002"* → PRP-002 hereda la obligación de cablear TEST DB + migraciones + seeds + specs vivos.
- **🔵 PRP-001 Bif 2=A · 2026-06-26** · *"firmo A"* (Tailwind v3) → stack congelado; no migrar.
- **SD-cos-6 PRP-001** · versiones en `.claude/memory/reference/stack-versions-PRP-001.md` → reusar íntegras (Next 16.2.9 · eslint ^9.39.4 · TS 6.0.3).

**Diferencias clave:** PRP-001 era infra sin datos/auth/RLS; PRP-002 mete BD real + auth vivo + policies. Superficie testeable grande → regla #17 (10-20 tests) aplica plena, no excepción de scaffold.

**Gotchas heredados:** DT-001 (`DATABASE_URL`→`TEST_DATABASE_URL`, cerrar acá) · eslint ^9.39.4 (no upgrade a 10, ERESOLVE) · Playwright `--with-deps` ya cableado · `run-sql-tests.sh` skip-safe hoy → correrá real cuando se exporte `TEST_DATABASE_URL` · regla #20 commit+push antes de `ci:local` · regla #27 sync-dev post-squash. `src/components/ui` + `cn` ahora entran (primer caller real).

### skeptic

**Issues detectados:**
- **normal · Fase 2 redirect:** `link_pending_memberships()` puede vincular ≥2 memberships de golpe · el draft no explicitaba a qué org redirigir. **→ refinado:** SD-cos-9 (0→onboarding · 1→dashboard · ≥2→select-organization).
- **normal · gate Fase 1:** `TEST_DATABASE_URL` era prerequisito pero sin gate ni validación de conexión. **→ refinado:** gate pre-Fase 1 (1a/1b/1c con `psql ... SELECT version()`).
- **normal · sesiones de test e2e:** G4/G5/G6/G7/G8 dependían de "sesión programática" sin método definido. **→ refinado:** SD-cos-10 (Supabase Admin API + `service_role` solo test) + acción 6 de Fase 2.
- **normal · magic link flow:** ruta `/auth/confirm` vs `/auth/callback` sin verificar. **→ ya cubierto:** nota no-suponer + verificación en Fase 2; G5 testea extremo-a-extremo agnóstico del flujo interno.
- **menor · slug:** G4 no validaba forma/unicidad del slug. **→ refinado:** SD-cos-8 (lowercase/alfanumérico/≤63/inmutable) + assert en spec.
- **menor · índice RLS:** hot-path `(organization_id, user_id, status)` sin índice compuesto. **→ refinado:** `idx_memberships_org_user_status`.

**Missing pieces:** redirect algorithm · gate TEST_DATABASE_URL · estrategia de sesión de test · índice compuesto → **todos incorporados** en esta iteración de refinamiento.

**Asunciones sin firmar:** flujo magic link (queda como verificación no-suponer en Fase 2 · no bifurcación) · guard service_role explicitado (constraint #10) en restricciones + DoD Fase 4.

**Contradicciones internas:** ninguna detectada.

**Anchor bias en bifurcaciones firmadas:** ninguna · las 5 bifurcaciones cierran con justificación robusta (helper SECURITY DEFINER = patrón oficial · onboarding un-paso = mejor UX · pending sin Resend = testeable sin dependencia · audit diferido = secuenciado del roadmap · Claude Design SKIP = backoffice convencional).

**No-issue descartado:** el `mbr_select` con `is_member_of` no es leak (visibilidad intra-tenant aceptable · la página de miembros está owner-gated en la capa app) · pending con `user_id NULL` no se ve a sí mismo hasta `active`, lo cual es correcto.

---

## Inventario de archivos afectados

| Acción | Archivo | Justificación |
|---|---|---|
| 🆕 | `db/migrations/0001_organizations_and_memberships.sql` | enums + tablas `organizations`/`memberships` + índices |
| 🆕 | `db/migrations/0002_rls_and_helpers.sql` | helpers SECURITY DEFINER + RLS enable + policies (Bif 1=A) |
| 🆕 | `db/migrations/0003_onboarding_rpcs.sql` | RPCs `create_organization_with_owner` + `link_pending_memberships` (SD-cos-1/2) |
| 🆕 | `db/seeds/test/test-seed.sql` | fixtures durables: 2 orgs + 2 users + memberships (UPSERT id fijo · para tests de aislamiento) |
| 🟡 | `scripts/run-sql-tests.sh` | **DT-001**: unificar `DATABASE_URL` → `TEST_DATABASE_URL` |
| 🟡 | `src/lib/supabase/server.ts` · `src/lib/supabase/client.ts` | extender skeletons con helpers de auth (no reescribir) |
| 🟢 | `src/middleware.ts` | refresco de sesión Supabase (thin · edge-safe · SD-cos-7) |
| 🟢 | `src/lib/utils.ts` | `cn` (shadcn) · primer caller real |
| 🟢 | `src/components/ui/{button,input,label,card}.tsx` | primitivos shadcn con caller real (SD-cos-6) |
| 🟢 | `src/lib/auth/{session,org,slug,schemas}.ts` | resolver sesión/memberships · `requireMembership`/`requireRole` · slugify · Zod |
| 🟢 | `src/app/(auth)/login/{page.tsx,actions.ts}` | form magic link + `sendMagicLink` action |
| 🟢 | `src/app/auth/confirm/route.ts` | callback magic link (verifyOtp) + `link_pending_memberships` + redirect |
| 🟢 | `src/app/(auth)/onboarding/{page.tsx,actions.ts}` | crear organización (Bif 2=A) + `createOrganization` action |
| 🟢 | `src/app/(auth)/select-organization/page.tsx` | selector multi-membership |
| 🟢 | `src/app/(org)/[orgSlug]/layout.tsx` | guard de membership + resolución de org activa (SD-cos-7) |
| 🟢 | `src/app/(org)/[orgSlug]/dashboard/page.tsx` | shell del dashboard del organizador (placeholder de contenido) |
| 🟢 | `src/app/(org)/[orgSlug]/members/{page.tsx,actions.ts}` | gestión de miembros (Owner-only) + `addMember`/`removeMember`/`changeRole` (Bif 3=A) |
| 🟢 | `src/components/org-switcher.tsx` · `src/components/app-nav.tsx` | selector de org + nav del shell |
| 🆕 | `tests/sql/PRP-002-rls-isolation.sql` | aislamiento cross-tenant (G2) |
| 🆕 | `tests/sql/PRP-002-helpers-and-rpcs.sql` | `is_member_of`/`has_role`/RPCs (G3, G4, G8) |
| 🆕 | `tests/e2e/regression/PRP-002-auth-onboarding.spec.ts` | login + onboarding + owner (G4, G5) |
| 🆕 | `tests/e2e/regression/PRP-002-rbac-and-orgs.spec.ts` | RBAC gate + selector + alta miembro (G6, G7, G8) |
| 🆕 | `tests/e2e/regression/COVERAGE.md` | índice de cobertura heredada (crear · primer PRP con suite viva) |
| 🟠 | `docs/logs/technical-debt.md` | mover DT-001 a Resueltas con commit hash |
| 🟠 | `docs/product/product-roadmap.md` | TASK-002 `[ ]`→`[x]` + ref PRP-002 al cierre del paso 6 |
| 🟠 | `.claude/memory/log.md` | entrada `decision` (cierre paso 2) + `prp-close` (cierre paso 6) |
| 🟣 | `tests/manual/PRP-002_auth-orgs-rls.csv` | **NO se crea en `/implementar`** · ownership del SKILL [`/validar`](../skills/validar/SKILL.md) paso 5 |
| ❌ | tablas `events`/`ticket_types`/`orders`/`tickets`/`promo_codes` · `audit_log` · integración Resend · páginas públicas del comprador | NO tocar · fuera de scope (regla [`surgical-changes.md`](../rules/surgical-changes.md)) |

**Restricciones de scope:**
- **Sin envío de emails** (Resend llega en TASK-008) · el alta de miembro genera `pending` + link compartido a mano.
- **Sin `audit_log`** (diferido a TASK-003 · Bif 4=A) · gap conocido: alta/baja de miembros no auditada hasta entonces.
- **Sin Platform Superadmin** (TASK-015) · solo roles intra-org owner/admin/staff.
- **Sin tablas de negocio** (events/tickets/orders/promo_codes) ni páginas públicas del comprador.
- **Guard constraint #10 (service_role):** `SUPABASE_SERVICE_ROLE_KEY` vive SOLO en entorno de test/CI (helper de sesión e2e) · **cero** referencias en `src/` · verificable con `grep -r "SERVICE_ROLE" src/` → 0 matches (check en DoD de Fase 4). Cliente/servidor usan siempre la anon key + RLS.
- **Prerrequisito operativo (fuera de código):** provisión de un proyecto Supabase Cloud real + carga de `NEXT_PUBLIC_SUPABASE_URL`/`ANON_KEY` en `.env.local` + `TEST_DATABASE_URL` para la TEST DB · lo aporta el user en el gate pre-Fase 1.

---

## Blueprint (Assembly Line · 4 fases)

> Cada fase cierra con código + tests del DoD + `npm run typecheck` + `npm run build` verdes + commit local. **NO push hasta paso 6.**
> **Pre-step regla #16:** suite de regresión vacío al boot (`tests/e2e/regression/` sin specs previos) · pre-validation no aplica · este PRP crea `COVERAGE.md` y la primera suite viva.

### Fase 1 — Provisión + BD schema + RLS + RPCs + DT-001

**Objetivo:** TEST DB real cableada · tablas + enums + helpers + RLS + RPCs aplicados e idempotentes · aislamiento cross-tenant verificado en SQL · DT-001 cerrada.

**Tipo:** 🔴 punto-de-no-retorno · DDL aplicado a TEST DB cloud.

**Gate pre-Fase 1 (bloqueante · el user aporta credenciales):**
- 1a. `.env.local` carga `NEXT_PUBLIC_SUPABASE_URL` + `NEXT_PUBLIC_SUPABASE_ANON_KEY` reales.
- 1b. `.env.local` carga `TEST_DATABASE_URL` (connection string full de la TEST DB) + `SUPABASE_SERVICE_ROLE_KEY` (solo test/CI · nunca en `src/`).
- 1c. Validar conexión: `psql "$TEST_DATABASE_URL" -c "SELECT version();"` exit 0. Si falla → parar y pedir credenciales (regla `ante-duda-preguntar-user`).

**Acción:**
2. Escribir `0001` (enums+tablas+índices), `0002` (helpers+RLS+policies), `0003` (RPCs) · aplicar contra TEST DB (Supabase MCP `apply_migration` o `psql`).
3. Escribir `db/seeds/test/test-seed.sql` con UPSERT id fijo: 2 orgs (A, B) + 2 auth users + memberships (user1→owner A, user2→owner B, +1 staff pending en A).
4. Unificar DT-001: `scripts/run-sql-tests.sh` usa `TEST_DATABASE_URL`.
5. Tests SQL: `PRP-002-rls-isolation.sql` (G2) + `PRP-002-helpers-and-rpcs.sql` (G3/G4/G8 core).

**DoD:**
- [ ] `bash scripts/test-migrations.sh` verde (idempotencia · aplica 2×).
- [ ] `bash scripts/run-sql-tests.sh` corre real con `TEST_DATABASE_URL` (no skip) · specs verdes.
- [ ] DT-001 movida a Resueltas en `docs/logs/technical-debt.md`.
- [ ] `npm run typecheck` + `npm run build` verdes.
- [ ] Commit `feat(PRP-002): fase 1 · schema + RLS + RPCs + DT-001 · TEST DB cableada`.

**Reversibilidad:** no (DDL en cloud) · mitigación: migraciones idempotentes + seed UPSERT · re-aplicables sin drift.

### Fase 2 — Magic link + sesión + middleware + onboarding

**Objetivo:** login por magic link funcional end-to-end + sesión persistida + onboarding "crear organización" → Owner.

**Tipo:** 🟢 reversible.

**Acción:**
1. Verificar contra docs oficiales Supabase el flujo SSR de magic link (regla no-suponer) → route `auth/confirm`.
2. `src/middleware.ts` (refresh de sesión · patrón `updateSession`).
3. shadcn: `cn` + primitivos (`button`/`input`/`label`/`card`).
4. `(auth)/login` (form + `sendMagicLink`) · `auth/confirm/route.ts` (verifyOtp + `link_pending_memberships` + **redirect por SD-cos-9**: 0 active→onboarding · 1→dashboard · ≥2→select-organization) · `(auth)/onboarding` (form + `createOrganization` vía RPC + `slugify` SD-cos-8).
5. `src/lib/auth/{session,org,slug,schemas}.ts`.
6. **Helper de sesión de test (SD-cos-10):** implementar utilidad Playwright que crea/confirma un test user vía Supabase Admin API (`service_role` de test) y setea cookies · verificar helper exacto contra docs `@supabase/ssr` 0.12.
7. e2e `PRP-002-auth-onboarding.spec.ts` (G5 login extremo-a-extremo agnóstico del flujo interno · G4 onboarding→owner con sesión de test · verifica slug válido lowercase/alfanumérico).

**DoD:** typecheck+build verdes · 3-5 tests · commit `feat(PRP-002): fase 2 · magic link + sesión + onboarding`.

**Reversibilidad:** sí · revertir archivos de app (schema intacto).

### Fase 3 — Org context + RBAC surfaces + gestión de miembros

**Objetivo:** shell `/{org-slug}/dashboard` con guard de membership · selección de org · gestión de miembros Owner-only · RBAC verificable.

**Tipo:** 🟢 reversible.

**Acción:**
1. `(org)/[orgSlug]/layout.tsx` (`requireMembership(slug)` → 404/redirect si no pertenece) + `dashboard/page.tsx` (shell).
2. `(auth)/select-organization` + `org-switcher` + `app-nav`.
3. `(org)/[orgSlug]/members` (`requireRole(slug, ['owner'])`) + actions `addMember`/`removeMember`/`changeRole` (Zod → sesión → RLS owner-gated → exec).
4. e2e `PRP-002-rbac-and-orgs.spec.ts` (G6 staff bloqueado en members · G7 selector switch · G8 alta pending → vinculación al login).

**DoD:** typecheck+build verdes · 4-6 tests · commit `feat(PRP-002): fase 3 · org context + RBAC + members`.

**Reversibilidad:** sí.

### Fase 4 — Validación Final

**Objetivo:** end-to-end · criterios G1..G10 cumplidos.

**Acción:**
1. Correr suite completo (`tests/sql/*` + `tests/e2e/regression/*`).
2. Smoke visual con Playwright MCP (login · onboarding · dashboard · members gate).
3. Completar `tests/e2e/regression/COVERAGE.md` (archivos↔specs).
4. Confirmar G1..G10.

**DoD:** typecheck+build verdes · suite global verde · G1..G10 marcados · `grep -r "SERVICE_ROLE" src/` → 0 matches (guard constraint #10) · commit `feat(PRP-002): fase 4 · validación final`.

---

## Aprendizajes / Self-Annealing

### [2026-07-01] Fase 1 · Conexión Supabase directa es IPv6-only (WSL2 no la alcanza)
- **Error:** `psql "$TEST_DATABASE_URL"` → `Network is unreachable` sobre `db.<ref>.supabase.co:5432` (IPv6).
- **Root cause:** el host directo de Supabase resuelve solo a IPv6; WSL2 no tiene ruta IPv6.
- **Fix:** usar el **Session pooler** (IPv4, puerto 5432) `postgresql://postgres.<ref>:<pwd>@aws-1-<region>.pooler.supabase.com:5432/postgres`. `test-migrations.sh` ya reescribe `:6543→:5432`.
- **Aplicar en:** cualquier acceso a la TEST DB desde WSL/CI · regression-first NO (gotcha de tooling/infra · nivel 2 → candidato a memoria `feedback/supabase-direct-conn-ipv6-use-session-pooler.md`).

### [2026-07-01] Fase 1 · Funciones SECURITY DEFINER deben declararse en las whitelists del pack
- **Error:** `helpers-shape-invariants.sql` INV-B falló: `is_member_of` SECURITY DEFINER con EXECUTE a authenticated sin estar en `public_definer_whitelist`.
- **Root cause:** el pack exige declarar toda función SECURITY DEFINER expuesta a `authenticated`/`anon` en `public_definer_whitelist` (con justificación) + los helpers RLS invocados desde policies en `rls_canonical_helpers` (deben ser STABLE). Es el punto de integración del adopter.
- **Fix:** lleno ambas whitelists en `tests/sql/helpers-shape-invariants.sql` (4 funciones + 2 helpers canónicos). Quité el grant sobrante a `anon` en `is_member_of` (least privilege · anon nunca evalúa policies `TO authenticated`).
- **Aplicar en:** todo PRP futuro que agregue funciones SECURITY DEFINER (TASK-003+ RPCs de stock/checkout) · regression-first: el invariante ya es el spec.

### [2026-07-01] Fase 1 · `test-migrations.sh` dropea el event-trigger `ensure_rls` de Supabase → DT-002
- **Error:** tras `test-migrations.sh`, `pg_proc` bajó de 5 a 4 SECURITY DEFINER · `ensure_rls` event-trigger + `rls_auto_enable` desaparecieron de la TEST DB.
- **Root cause:** `DROP SCHEMA public CASCADE` del reset cascadea al event-trigger global `ensure_rls` (depende de `rls_auto_enable`, que vive en `public`).
- **Fix:** out-of-scope (tooling del pack) → **DT-002** registrada. Mitigación en el PRP: RLS explícito por tabla + invariante `rls-invariants.sql` verde. Cero restauración de `ensure_rls` (objeto Supabase-managed sin fuente propia).
- **Aplicar en:** endurecer `test-migrations.sh` en un mini-PRP de infra futuro (disparador de DT-002).

### [2026-07-02] Fase 2 · Next 16 deprecó `middleware.ts` → convención `proxy.ts`
- **Error:** `next build` emitió `The "middleware" file convention is deprecated. Please use "proxy" instead.`
- **Root cause:** Next.js 16 renombró la convención `middleware` → `proxy` (misma semántica edge · [docs](https://nextjs.org/docs/messages/middleware-to-proxy)) · verificado contra docs oficiales (regla no-suponer).
- **Fix:** `src/middleware.ts` → `src/proxy.ts` + función `middleware` → `proxy` (behavior-preserving · SD-cos-7 thin session-refresh intacto). El helper interno `src/lib/supabase/middleware.ts` (nuestro `updateSession`) queda con ese nombre (no es archivo-convención de Next). El inventario del PRP dice `src/middleware.ts` (superado por la versión instalada de Next). Firmado implícito al aprobar el fix mecánico de versión.
- **Aplicar en:** cualquier PRP futuro que toque el proxy · gotcha de tooling nivel 1 (específico al stack de este proyecto).

### [2026-07-02] Fase 2 · `service_role` sin GRANT de tabla tras schema reset (rompe helper de test)
- **Error:** el helper de sesión e2e (rol `service_role`) recibía `permission denied for table memberships` (`42501`) al leer `memberships`/`organizations` · G4 fallaba con membership `null`.
- **Root cause:** en Supabase real `service_role` recibe privilegios por default privileges del schema `public` · el reset `DROP SCHEMA CASCADE` de `test-migrations.sh` (DT-002) los borra · la migración `0002` sólo re-otorgaba a `authenticated` (no a `service_role`). La app (rol `authenticated`) nunca se vio afectada · sólo el helper de test (constraint #10: `service_role` solo test/CI + Edge).
- **Fix:** `GRANT ALL ON public.{organizations,memberships} TO service_role` explícito en `0002` (idempotente · production-safe · robusto ante schema reset · no depende de default privileges implícitos). Re-aplicado a TEST DB · idempotencia (`test-migrations.sh`) + suite SQL 7/7 verdes.
- **Aplicar en:** toda tabla futura consumida por Edge Functions server-side (webhooks de pago · TASK-007) o por helpers de test admin → GRANT explícito a `service_role` en la migración, no confiar en default privileges. Regression-first: G4 e2e reproduce (fallaba pre-fix · pasa post-fix).

### [2026-07-03] Paso 4 `/revisar` LR-001 · 8 normales · 5 fixeados in-scope + 2 DT + 9 nits descartados
- **Review:** 9 agentes Opus paralelos sobre el diff Fase 1+2 (36 archivos). Consolidator: 0 critical · 8 normal · 9 nits descartados por filtro Bif 6=A (señal débil single-detector). i18n y migration-safety limpios. Log: `docs/logs/revisar-log.md § LR-001`.
- **5 normales in-scope fixeados (regression-first FIRME · firma 🔵 user opción A):**
  - **lr_bug_005 + lr_bug_008:** `getActiveMemberships` colapsaba error real a `[]` (indistinguible de "sin orgs" → usuario con org iba a `/onboarding`) y `confirm/route.ts` ignoraba el error de `link_pending_memberships`. Fix: `getActiveMemberships` propaga el error · el callback y el guard de onboarding capturan y redirigen a `/login?error=...` en vez de tratar cualquier fallo como usuario nuevo. (Este es el mismo patrón de swallow que ocultó el permission-denied del grant en Fase 2.)
  - **lr_bug_004:** asimetría de email (write crudo + `UNIQUE(org,email)` case-sensitive vs read/link/index en `lower()`). Fix: `UNIQUE INDEX (organization_id, lower(email))` idempotente (DROP constraint viejo + CREATE INDEX IF NOT EXISTS) en `0001` + `lower(auth.email())` en el INSERT de la RPC (`0003`). Regression: test case-insensitive en `PRP-002-helpers-and-rpcs.sql`. Cerrado antes de Fase 3 (`addMember`) para no cementar el path crudo.
  - **lr_bug_001:** aislamiento cross-tenant del lado WRITE sin invariante. Fix: 4 escenarios nuevos en `PRP-002-rls-isolation.sql` (owner de A no puede INSERT/UPDATE/DELETE cross-tenant a B · staff no-owner no puede escribir memberships de su propia org).
  - **lr_bug_006:** forms sin `aria-invalid`/`aria-describedby`. Fix: atributos + `id` del error en login/onboarding + assertion e2e.
- **2 diferidos a DT (out-of-scope · firma 🔵 user A):** **DT-004** (rate-limiting propio en `/login` · depende de edge/Resend TASK-008 · hoy defiende el rate-limit del proveedor) · **DT-005** (contraste de tokens del DS en `globals.css` · vive en PRP-001, cross-cutting · oscurecer `--primary` es decisión de la matriz Claude Design).
- **Verificación post-fix:** idempotencia (`test-migrations.sh`) verde · suite SQL 7/7 verde (write-side + case-insensitive nuevos) · e2e 4/4 verde (aria + G4 con error handling + lower email) · typecheck + build verdes.

### [2026-07-02] Fase 2 · G5 happy-path (envío real de magic link) no automatizable en CI → DT-003
- **Error:** el test de "form→Revisá tu email" fallaba: `signInWithOtp` rechaza el TLD `.test` (`email_address_invalid`) y el SMTP built-in de Supabase rate-limitea a ~2/hora (`429 over_email_send_rate_limit`).
- **Root cause:** el envío real de email depende del SMTP built-in de Supabase (bajo límite · sin SMTP propio hasta TASK-008/Resend) · no es un bug de código.
- **Fix:** **escalado al user** (regla `always-fix-all-bugs` § excepción · servicio externo no integrado) → firma 🔵 **opción A**: **DT-003**. Spec G5 automatizado queda determinístico (validación de form + estructura) · el pipeline de auth end-to-end lo prueba G4 vía el route real `/auth/confirm` · el happy-path "form→enviado" se cubre en el smoke visual de Fase 4 + manual · re-habilitación automatizada al integrar SMTP propio (TASK-008).
- **Aplicar en:** cualquier feature futura que dependa de envío de email transaccional (tickets · TASK-008) · no acoplar tests automatizados al SMTP built-in rate-limited.
