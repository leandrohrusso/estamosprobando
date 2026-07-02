---
name: PRP-002 checkpoint · Fase 1 cerrada · 2026-07-01
description: Estado del bucle /implementar de PRP-002 al cerrar Fase 1 (BD schema + RLS + RPCs + seed + DT-001). Próximo: Fase 2 (magic link + sesión + onboarding).
metadata:
  type: project
---

# PRP-002 · checkpoint · Fase 1 cerrada · 2026-07-01

> **Próxima acción:** arrancar Fase 2 (magic link + sesión + middleware + onboarding) del PRP-002.
> **Skill a invocar:** `/implementar` (continuar bucle) tras cargar `.env.local`.

## Estado al cierre de Fase 1

**DoD Fase 1 verde:**
- 3 migraciones aplicadas a la TEST DB Supabase (organizations + memberships + enums + helpers SECURITY DEFINER + RLS + RPCs).
- Seed durable `db/seeds/test/test-seed.sql` (2 orgs, 4 users, 3 memberships incl. 1 pending).
- **G1** idempotencia: `bash scripts/test-migrations.sh` verde (schema determinístico 2 pasadas).
- **G2/G3/G8 (+G4 nivel SQL)**: `bash scripts/run-sql-tests.sh` → 7/7 specs verdes (mis 2 + 5 invariantes del pack).
- **G9** DT-001 cerrada: `run-sql-tests.sh` unificado a `TEST_DATABASE_URL`.
- `npm run typecheck` + `npm run build` verdes.

**Archivos Fase 1:** `db/migrations/000{1,2,3}_*.sql` · `db/seeds/test/test-seed.sql` · `tests/sql/PRP-002-{rls-isolation,helpers-and-rpcs}.sql` · `tests/sql/helpers-shape-invariants.sql` (whitelists llenadas) · `scripts/run-sql-tests.sh` (DT-001) · `docs/logs/technical-debt.md` (DT-001→Resuelta, DT-002 abierta).

**DT abierta:** DT-002 (`test-migrations.sh` DROP SCHEMA CASCADE dropea `ensure_rls` de Supabase · mitigado con RLS explícito · disparador: endurecer test-migrations).

## Setup del entorno (crítico para retomar)

- `psql`/`pg_dump` 18.4 instalados (postgresql-client).
- `.env.local` (gitignored) con 4 vars: `NEXT_PUBLIC_SUPABASE_URL` · `NEXT_PUBLIC_SUPABASE_ANON_KEY` · `SUPABASE_SERVICE_ROLE_KEY` (solo test) · `TEST_DATABASE_URL` (**Session pooler IPv4**, no conexión directa IPv6).
- Para correr scripts SQL: `set -a; . ./.env.local; set +a` antes.

## Qué falta (Fase 2 → 4)

- **Fase 2:** middleware thin (refresh sesión) · shadcn ui (`cn` + button/input/label/card) · `(auth)/login` + `sendMagicLink` · `auth/confirm/route.ts` (verifyOtp + `link_pending_memberships` + redirect SD-cos-9) · `(auth)/onboarding` + `createOrganization` (RPC) · `src/lib/auth/{session,org,slug,schemas}.ts` · helper de sesión de test (Admin API) · e2e G4/G5. **Verificar flujo magic link SSR contra docs Supabase (no-suponer).**
- **Fase 3:** `(org)/[orgSlug]/layout.tsx` (requireMembership) + dashboard shell · `select-organization` + org-switcher · `members` (Owner-only) + addMember/removeMember/changeRole · e2e G6/G7/G8.
- **Fase 4:** validación final G1–G10 + guard service_role (`grep -r SERVICE_ROLE src/` → 0).

## Gotchas detectados (ver PRP § Aprendizajes para detalle)

1. Conexión Supabase directa es IPv6-only → usar Session pooler (IPv4) en WSL2.
2. Funciones SECURITY DEFINER → declarar en `public_definer_whitelist` + `rls_canonical_helpers` del pack.
3. `test-migrations.sh` dropea `ensure_rls` de Supabase (DT-002).

## Refs

- PRP: `.claude/PRPs/PRP-002-auth-organizations-memberships-rls.md`
- Commit Fase 1: (ver `git log` · `feat(PRP-002): fase 1`)
- DT-002: `docs/logs/technical-debt.md § Activas`
