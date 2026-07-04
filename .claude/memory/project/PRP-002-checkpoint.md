---
name: PRP-002 checkpoint · paso 3 cerrado (4/4 fases) · 2026-07-03
description: Estado del PRP-002 al cerrar el paso 3 /implementar (4 fases · G1–G10 verde). Próximo: paso 4 /revisar.
metadata:
  type: project
---

# PRP-002 · checkpoint · paso 3 cerrado (4/4 fases) · 2026-07-03

> **Próxima acción:** paso 4 del flujo · `/revisar` (multi-agent code review del diff de PRP-002 vs main).
> **Nota para `/revisar`:** confirmar con el user si el MVP necesita multi-owner/transferencia (SD-cos-11 firmó Owner único · opción A) · revisar el diseño de RBAC + los guards `requireMembership`/`requireRole`.
> **Cargar entorno si se corre algo:** `.env.local` (`set -a; . ./.env.local; set +a`).

## Estado al cierre del paso 3 (Fase 4 · validación final verde)

**G1–G10 todos verdes** (ver PRP § Criterios de Éxito + Aprendizajes 2026-07-03 Fase 4): guard #10 (0 `SERVICE_ROLE` en `src/`) · G1 idempotencia · G2/G3 SQL 7/7 · G4–G8 e2e 8/8 · G9 (`TEST_DATABASE_URL`) · G10 ~17 tests · typecheck+build. Smoke visual (Playwright runner + screenshots · MCP no conectado) OK en login/select-org/dashboard/members. Fix Fase 4: `getOrgMembers` ordenaba por columna enum (orden de declaración, no alfabético) → orden explícito en JS.

## Estado al cierre de Fase 3

**DoD Fase 3 verde (application-layer · sin DDL nuevo):**
- **Org context:** `(org)/[orgSlug]/layout.tsx` (`requireMembership` → `/login` sin sesión · `notFound()` si no es miembro) + `dashboard/page.tsx` (shell · destino real del redirect de onboarding/login).
- **Nav:** `src/components/nav/app-nav.tsx` (server · link Miembros solo Owner) + `org-switcher.tsx` (client · `<select>` + `useRouter`, solo con ≥2 orgs).
- **Selección de org:** `(auth)/select-organization/page.tsx` (chooser · reusa `resolvePostLoginRedirect` para 0/1).
- **Miembros:** `(org)/[orgSlug]/members/page.tsx` (`requireRole(['owner'])`) + `actions.ts` (`addMember`/`changeRole`/`removeMember` · patrón Zod→sesión→RLS owner-gated→exec + `isManageableTarget`) + `members-manager.tsx` (client).
- **Helpers:** `org.ts` (`requireMembership`/`requireRole`/`getOrgMembers`) · `session.ts` envuelto en `cache()` · `schemas.ts` (`assignableRoleSchema`/`addMemberSchema`/`changeRoleSchema`/`removeMemberSchema`) · `slug.ts` (`RESERVED_SLUGS`/`isReservedSlug`) · `roles.ts` (`roleLabel` · client-safe) · onboarding aplica guard de slug reservado.
- **Tests:** e2e `PRP-002-rbac-and-orgs.spec.ts` (G6/G7/G8 + CRUD · 4) + unit `PRP-002-slug.test.ts` (4) + helpers de setup en `tests/e2e/auth-session.ts` (`createOrganizationDirect`/`addActiveMember`/`addPendingMember`/`getOrgMembership`).
- **Verde:** `typecheck` + `build` · e2e **8/8** (incluye G4/G5 sin regresión) · SQL **7/7** · unit **5/5**.

## Decisiones de Fase 3 (ver PRP § Aprendizajes 2026-07-03)

1. **Owner inmutable vía UI + roles asignables acotados a admin|staff** (anti-lockout · SD-cos-11 · 🔵 **firmada user opción A · 2026-07-03** · multi-owner/transferencia descartados para el MVP).
2. **`requireRole` bloquea con redirect al dashboard** (no 403 literal · evita `forbidden()` experimental). `requireMembership` no-miembro → `notFound()` (asimetría deliberada).
3. **`cache()`** en `getSessionUser`/`getActiveMemberships` (dedup por request · layout + page).
4. **Guard de slugs reservados** (colisión `/{orgSlug}` con rutas estáticas · fix in-scope + unit test).

**DTs:** sin DTs nuevas en Fase 3 (el fix de slug reservado fue in-scope). Activas heredadas: DT-002 (ensure_rls) · DT-003 (magic-link real) · DT-004 (rate-limit login) · DT-005 (contraste tokens tema claro).

## Setup del entorno (crítico para retomar)

- `.env.local` (gitignored) con 4 vars · `TEST_DATABASE_URL` = Session pooler IPv4 (WSL2).
- SQL: `set -a; . ./.env.local; set +a` antes. e2e: `global-setup` carga `.env.local` + webServer `npm run dev` (reuseExistingServer).
- Matar `next dev`/`next-server` colgados antes de `typecheck` (race `.next/dev/types`).

## Fase 4 · cerrada (validación final)

- ✅ Suite completo verde (SQL 7/7 · e2e 8/8 · unit 5/5) · G1 idempotencia · guard #10 (0 `SERVICE_ROLE` en `src/`) · smoke visual (login/select-org/dashboard/members).
- ✅ G1..G10 confirmados · contador ~17 tests (meta 10-20) · COVERAGE.md actualizado (rbac-and-orgs + slug).
- Pendiente del flujo: **paso 4 `/revisar`** → paso 5 `/validar` → paso 6 `/entregar`.

## Refs

- PRP: `.claude/PRPs/PRP-002-auth-organizations-memberships-rls.md`
- Commit Fase 3: (ver `git log` · `feat(PRP-002): fase 3`)
- Checkpoint previo: Fase 2 (este archivo lo reemplaza).
