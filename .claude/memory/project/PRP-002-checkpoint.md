---
name: PRP-002 checkpoint · Fase 3 cerrada · 2026-07-03
description: Estado del bucle /implementar de PRP-002 al cerrar Fase 3 (org context + RBAC + gestión de miembros). Próximo: Fase 4 (validación final G1–G10).
metadata:
  type: project
---

# PRP-002 · checkpoint · Fase 3 cerrada · 2026-07-03

> **Próxima acción:** arrancar Fase 4 (validación final · G1–G10 + guard service_role + smoke visual + COVERAGE.md) del PRP-002.
> **Skill a invocar:** `/implementar` (última fase) tras cargar `.env.local` (`set -a; . ./.env.local; set +a`).

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

1. **Owner inmutable vía UI + roles asignables acotados a admin|staff** (anti-lockout · SD-cos-11 · **a confirmar con user en paso 4:** ¿MVP necesita multi-owner/transferencia?).
2. **`requireRole` bloquea con redirect al dashboard** (no 403 literal · evita `forbidden()` experimental). `requireMembership` no-miembro → `notFound()` (asimetría deliberada).
3. **`cache()`** en `getSessionUser`/`getActiveMemberships` (dedup por request · layout + page).
4. **Guard de slugs reservados** (colisión `/{orgSlug}` con rutas estáticas · fix in-scope + unit test).

**DTs:** sin DTs nuevas en Fase 3 (el fix de slug reservado fue in-scope). Activas heredadas: DT-002 (ensure_rls) · DT-003 (magic-link real) · DT-004 (rate-limit login) · DT-005 (contraste tokens tema claro).

## Setup del entorno (crítico para retomar)

- `.env.local` (gitignored) con 4 vars · `TEST_DATABASE_URL` = Session pooler IPv4 (WSL2).
- SQL: `set -a; . ./.env.local; set +a` antes. e2e: `global-setup` carga `.env.local` + webServer `npm run dev` (reuseExistingServer).
- Matar `next dev`/`next-server` colgados antes de `typecheck` (race `.next/dev/types`).

## Qué falta (Fase 4 · validación final)

- Correr suite completo (`tests/sql/*` + `tests/e2e/regression/*`) · smoke visual Playwright MCP (login · onboarding · dashboard · members gate · switcher · incl. happy-path magic-link G5/DT-003).
- Guard constraint #10: `grep -r "SERVICE_ROLE" src/` → 0 matches.
- Confirmar G1..G10 · contador tests-vs-meta 10-20.
- COVERAGE.md ya actualizado en Fase 3 (filas rbac-and-orgs + slug).

## Refs

- PRP: `.claude/PRPs/PRP-002-auth-organizations-memberships-rls.md`
- Commit Fase 3: (ver `git log` · `feat(PRP-002): fase 3`)
- Checkpoint previo: Fase 2 (este archivo lo reemplaza).
