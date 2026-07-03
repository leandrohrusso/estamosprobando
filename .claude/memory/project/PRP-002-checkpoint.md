---
name: PRP-002 checkpoint · Fase 2 cerrada · 2026-07-02
description: Estado del bucle /implementar de PRP-002 al cerrar Fase 2 (magic link + sesión + proxy + onboarding). Próximo: Fase 3 (org context + RBAC + members).
metadata:
  type: project
---

# PRP-002 · checkpoint · Fase 2 cerrada · 2026-07-02

> **Próxima acción:** arrancar Fase 3 (org context + RBAC surfaces + gestión de miembros) del PRP-002.
> **Skill a invocar:** `/implementar` (continuar bucle) tras cargar `.env.local` (`set -a; . ./.env.local; set +a`).

## Estado al cierre de Fase 2

**DoD Fase 2 verde:**
- Auth por magic link end-to-end: `(auth)/login` (form + `sendMagicLink`) · `src/app/auth/confirm/route.ts` (verifyOtp/exchangeCode + `link_pending_memberships` + redirect SD-cos-9) · `(auth)/onboarding` (form + `createOrganization` vía RPC + slugify).
- `src/proxy.ts` (thin session-refresh · convención Next 16 · reemplaza `middleware.ts` deprecado) + `src/lib/supabase/middleware.ts` (`updateSession`).
- Helpers `src/lib/auth/{schemas,slug,session,org}.ts` · shadcn `cn` (`src/lib/utils.ts`) + primitivos `button/input/label/card` (sin `cva`).
- Helper de sesión de test `tests/e2e/auth-session.ts` (Admin API · pasa por el route real `/auth/confirm`).
- Deps nuevas: `zod` 4.4.3 · `clsx` 2.1.1 · `tailwind-merge` 3.6.0.
- **e2e 4/4 verdes** (`tests/e2e/regression/`): scaffold + G4 (onboarding→Owner) + G5 form-render + G5 email-inválido.
- `npm run typecheck` + `npm run build` verdes · idempotencia (`test-migrations.sh`) + suite SQL 7/7 verdes tras el fix del grant.

**Fix de Fase 1 aplicado en Fase 2:** `db/migrations/0002` ahora hace `GRANT ALL ... TO service_role` (schema reset borraba los grants por default · rompía el helper de test · ver PRP § Aprendizajes 2026-07-02).

**DTs:** DT-002 (ensure_rls · abierta, heredada) · **DT-003 nueva** (G5 envío real de magic link no automatizable · SMTP built-in rate-limited · disparador TASK-008 Resend · firma 🔵 user opción A).

## Setup del entorno (crítico para retomar)

- `.env.local` (gitignored) con 4 vars pobladas · `TEST_DATABASE_URL` = **Session pooler IPv4** (no IPv6 directo · WSL2).
- Para scripts SQL: `set -a; . ./.env.local; set +a` antes.
- Dev server de Playwright: matar `next dev`/`next-server` colgados antes de `typecheck` (evita el race `.next/dev/types`).

## Qué falta (Fase 3 → 4)

- **Fase 3:** `(org)/[orgSlug]/layout.tsx` (`requireMembership(slug)` → 404/redirect) + `dashboard/page.tsx` (shell · materializa el destino del redirect de onboarding) · `(auth)/select-organization` + `org-switcher` + `app-nav` · `(org)/[orgSlug]/members` (`requireRole(slug,['owner'])`) + `addMember`/`removeMember`/`changeRole` (Zod → sesión → RLS owner-gated) · e2e G6/G7/G8. Sumar `requireMembership`/`requireRole` a `src/lib/auth/org.ts` + `addMemberSchema` a `schemas.ts`.
- **Fase 4:** validación final G1–G10 + guard service_role (`grep -r SERVICE_ROLE src/` → 0) + smoke visual (incl. happy-path magic-link de G5/DT-003) + completar COVERAGE.md.

## Gotchas detectados en Fase 2 (ver PRP § Aprendizajes para detalle)

1. Next 16 deprecó `middleware.ts` → `proxy.ts` (función `middleware`→`proxy`).
2. `service_role` sin GRANT de tabla tras schema reset → GRANT explícito en la migración (no confiar en default privileges).
3. G5 envío real de email no automatizable (SMTP built-in rate-limited + rechaza `.test`) → DT-003.

## Refs

- PRP: `.claude/PRPs/PRP-002-auth-organizations-memberships-rls.md`
- Commit Fase 2: (ver `git log` · `feat(PRP-002): fase 2`)
- DT-002 · DT-003: `docs/logs/technical-debt.md § Activas`
