---
name: PRP-002 handoff · paso 4 /revisar cerrado · próximo /validar · 2026-07-03
description: Paso 4 (/revisar LR-002) cerrado con 10 normales in-scope fixeados (regression-first) + 3 DT · commit 085f506 · typecheck/unit/build/SQL verdes. Próxima sesión arranca el paso 5 /validar (CSV exhaustivo). Cierre por fatiga camino B (indicador #3 · acumulación).
metadata:
  type: project
---

# PRP-002 · handoff · paso 4 cerrado · 2026-07-03

> **Disparado por:** fatiga camino B firmado por el user (indicador #3 · trabajo grande en una sentada · `/revisar` completo + batch de 10 fixes) al arrancar el Paso 0 de `/validar`.
> **Próxima acción concreta:** correr el paso 5 `/validar` de PRP-002 (generar CSV exhaustivo → provisión → ejecución contra la app real → fix+spec por cada `Falla` → reporte 100% verde).
> **Skill a invocar:** `/validar` (paso 5 · CSV exhaustivo con Playwright MCP + Supabase MCP). El Paso 0 self-check de fatiga se re-corre fresh en la sesión nueva.

## Estado al cierre de esta sesión

**Commits de la sesión:**

| Commit | Resumen |
|---|---|
| `085f506` | fix(PRP-002): paso 4 /revisar LR-002 · 10 normales in-scope fixeados + 3 DT (regression-first FIRME) |
| `9a70250` | feat(PRP-002): fase 4 · validación final · paso 3 cerrado (G1-G10) — *(pre-sesión)* |

Working tree **limpio** (todo commiteado en `085f506`; lint-staged aplicó su `eslint --fix` dentro del commit).

**Flujo de 6 pasos:**
- [✓] 1-3. `/arrancar` · `/planificar` (APROBADO · 5 bif 🔵) · `/implementar` (4/4 fases)
- [✓] 4. `/revisar` — LR-001 + **LR-002** cerrados. LR-002: 9 agentes Opus, 0 critical · 13 normal · 13 nits descartados. **10 normales in-scope fixeados** con regression-first + **3 DT** (DT-006/007/008).
- [ ] 5. `/validar` ← **retomar acá**
- [ ] 6. `/entregar`

**Qué se construyó en el batch de fixes LR-002 (todos con spec de regresión):**
- `src/app/(org)/[orgSlug]/members/actions.ts` — `changeRole`/`removeMember`: predicado `.neq('role','owner')` plegado en el UPDATE/DELETE (atómico) + propagación del error (throw); se **eliminó** `isManageableTarget`.
- `db/migrations/0002_rls_and_helpers.sql` — `mbr_write` con `role <> 'owner'` en USING + WITH CHECK (Owner inmutable a nivel RLS).
- `db/migrations/0001_*.sql` + `0003_onboarding_rpcs.sql` — columna `idempotency_key` + índice único parcial + RPC `create_organization_with_owner` ahora **3 args** (`p_name, p_slug, p_request_id`) con fast-path idempotente. DROP de la firma vieja de 2 args (idempotente).
- `src/app/(auth)/onboarding/{actions.ts,onboarding-form.tsx}` + `src/lib/auth/schemas.ts` — `requestId` UUID generado en `useEffect` (hidratación-safe) + hidden field + validación Zod.
- `src/app/(auth)/select-organization/page.tsx` — session-gate + try/catch (paridad `onboarding`).
- `src/app/(auth)/login/actions.ts` — `emailRedirectTo` desde `NEXT_PUBLIC_SITE_URL` (fallback a `origin` en dev).
- `src/components/nav/org-switcher.tsx` + `members-manager.tsx` — selects con submit explícito (botón "Cambiar"/"Guardar") en vez de `onChange`.
- Helpers puros extraídos: `slugCandidate` (slug.ts) · `fetchActiveMemberships` uncached (session.ts) · `sortMembersPendingFirst` (org.ts).
- Specs nuevos: unit `PRP-002-rbac-invariants.test.ts` + `PRP-002-session-error-vs-empty.test.ts` + `slugCandidate` en `PRP-002-slug.test.ts`; SQL `G-write.8` (Owner inmutable) en `PRP-002-rls-isolation.sql` + `G4.idem` (idempotencia) en `PRP-002-helpers-and-rpcs.sql`; e2e G7/CRUD actualizados al nuevo flujo de selects. `vitest.config.ts` ganó alias `@/`→`./src`.

**Decisiones firmadas 🔵 en esta sesión:**
- **lr_bug_008 idempotencia = opción A** (token por `(user, request)` · preserva multi-org · NO gatea a "0 memberships").
- **3 DT out-of-scope** aceptadas: DT-006 (slug inmutable app-only · disparador: 1ra superficie de edición de org) · DT-007 (voseo vs neutro LATAM · decisión de vocabulario sin firmar) · DT-008 (touch target 44px · AA-compliant · decisión de sizing del DS).

**Verificación post-fix (toda verde):** `npm run typecheck` · 20 unit (4 files) · `npm run build` · `test-migrations.sh` (2 pasadas idénticas) · 7 SQL specs (incl. G-write.8 + G4.idem).

## Qué falta hacer en la próxima sesión

1. **Correr `/validar`** (paso 5). El Paso 0 (self-check fatiga) se re-evalúa fresh — con contexto liviano no debería disparar.
2. **Pre-condición de entorno de `/validar`** (verificar ANTES del Paso 2 provisión):
   - Dev server arriba: `curl -s -o /dev/null -w "%{http_code}" http://localhost:3000` → si no responde, pedir al user levantarlo (`npm run dev`).
   - MCPs Playwright + Supabase habilitados en la sesión.
   - Credenciales: `tests/manual/.credentials.local.json` (gitignored). Si no existe, pedir al user (template en `.claude/skills/validar/references/credentials-template.json`).
   - TEST DB: `TEST_DATABASE_URL` vive en `.env.local` (sourcear con `set -a; . ./.env.local; set +a` para los SQL). Re-aplicar `db/seeds/test/test-seed.sql` (UPSERT id fijo) antes del Setup para restaurar state canónico.
   - `tests/manual/` **no existe todavía** (primer `/validar` del proyecto) → el skill lo crea + README canónico en el mismo turno (excepción documentada · no requiere firma nueva).
3. **Generar el CSV** `tests/manual/PRP-002_auth-organizations-memberships-rls-validation.csv` cubriendo el 100% de comportamientos: schema/MIG (organizations · memberships · enums · índices · idempotency_key) · RLS (aislamiento cross-tenant read+write · Owner inmutable G-write.8) · helpers/RPCs (is_member_of · has_role · create_organization_with_owner **3 args + idempotencia** · link_pending_memberships) · magic link + `/auth/confirm` · onboarding (crear org + slug colisión `-n` + requestId) · sesión/redirect SD-cos-9 (0/1/≥2 memberships) · org context + RBAC gates (G6) · members CRUD (add/changeRole/remove con **botón Guardar** · Owner sin controles) · multi-org selector (**botón Cambiar**, no onChange) · casos negativos (anon · tenant ajeno · staff en /members).
4. **DoD del paso 5:** CSV 100% verde (`Funciona`/`Diferido` justificado) · cada `Falla` → fix calidad senior + spec PRINCIPIO 6 (gate mecánico `git log`+`git show|grep`) + 1-2 filas vecinas + COVERAGE.md sync · reporte final + REGLA DE ORO cierre validación.
5. **Ojo con los cambios de UX de LR-002** al ejecutar el CSV: los dos `<select>` **ya no auto-submitean** — el switcher de org y el cambio de rol requieren clic en botón explícito. El CSV debe reflejar ese flujo (no esperar navegación/mutación en el mero `selectOption`).

## Gotchas detectados

- **`crypto.randomUUID()` en client component + hidratación:** generarlo en `useState`/render produce hydration mismatch (server no puede reproducir el UUID). Patrón usado: `useState('')` + `useEffect(() => setRequestId(crypto.randomUUID()), [])` + `disabled={pending || !requestId}`. Candidato a `feedback/client-uuid-hydration-safe.md` si vuelve a aparecer.
- **`CREATE OR REPLACE FUNCTION` con firma distinta = overload nuevo**, NO reemplazo (Postgres identifica por nombre+tipos). Al cambiar `create_organization_with_owner(TEXT,TEXT)` → `(TEXT,TEXT,UUID)` hubo que agregar `DROP FUNCTION IF EXISTS ...(TEXT,TEXT)` explícito para no dejar la firma vieja huérfona en la TEST DB durable. Candidato a `feedback/rpc-signature-change-needs-drop.md`.
- **RLS `role <> 'owner'` en USING de `FOR ALL`** protege UPDATE/DELETE de la fila Owner (no solo INSERT/promote vía WITH CHECK) → cierra el self-delete lockout. El WITH CHECK viola con error 42501 (insufficient_privilege); el USING filtra a 0 filas sin error. El Escenario G-write.8 testea las 3 vías (INSERT 2º owner · promover · borrar owner).
- **`vitest` no resolvía el alias `@/`** → módulos con imports por alias (session.ts → `@/lib/supabase/server`) no se podían testear. Fix: `resolve.alias` en `vitest.config.ts`. Además `react`.cache se mockea a identidad para testear funciones envueltas en `cache()` fuera de RSC.

## Re-onboarding en sesión nueva

1. `Read` este handoff primero (ya tenés el estado completo · **no** hace falta re-leer el PRP entero).
2. Skim rápido del PRP solo para los **criterios de éxito G1-G10** (`.claude/PRPs/PRP-002-auth-organizations-memberships-rls.md` § Criterios de Éxito) — son la base de las filas del CSV.
3. Invocar **`/validar`** directamente (no `/arrancar` · el contexto operativo está acá).
4. Status tracker recomendado al boot:
   ```
   Flujo PRP-002:
   [✓] 1-4. arrancar · planificar · implementar · revisar (LR-002 · commit 085f506)
   [ ] 5. /validar (CSV exhaustivo · Playwright+Supabase MCP · 100% verde) ← in_progress
   [ ] 6. /entregar
   ```
5. Antes del CSV: verificar entorno (punto 2 de "Qué falta") · el Paso 0 fatiga se re-corre fresh.

## Refs

- **PRP:** [`.claude/PRPs/PRP-002-auth-organizations-memberships-rls.md`](../../PRPs/PRP-002-auth-organizations-memberships-rls.md) (Estado: EN PROGRESO · paso 4 cerrado · 5 + 6 pendientes).
- **Log de revisión:** [`docs/logs/revisar-log.md`](../../../docs/logs/revisar-log.md) § LR-002 (13 hallazgos · 10 fixeados · 3 a DT).
- **DT abiertas esta sesión:** DT-006 · DT-007 · DT-008 en [`docs/logs/technical-debt.md`](../../../docs/logs/technical-debt.md).
- **Commit clave:** `085f506` (fix LR-002 + specs).
- **Reglas firmes aplicadas:** #10 always-fix-all-bugs · #15 regression-first-on-fix · #17 tests-as-dod-per-phase · #24 register-out-of-scope-as-dt · #9 fatigue-self-evaluation (camino B) · #26 session-handoff.
- **Skill próximo:** [`/validar`](../../skills/validar/SKILL.md) (paso 5 · 6 PRINCIPIOS · gate mecánico regression-first).
