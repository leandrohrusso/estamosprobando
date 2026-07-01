---
name: PRP-001 checkpoint
description: Estado vivo de la implementación de PRP-001 (scaffold + infra base) · paso 3 del flujo.
metadata:
  type: project
---

# PRP-001 · checkpoint (paso 3 · /implementar)

> **Última actualización:** 2026-06-26 · Fase 4 cerrada · **paso 3 completo**. PRP → EN PROGRESO (4+5+6 pendientes).

## Estado de fases

- [x] **Fase 1 · Deps reales + scaffold mínimo** — cerrada. Commit `6f79437`.
- [x] **Fase 2 · Cliente Supabase skeleton + env** — cerrada. Commit `e1c5059`.
- [x] **Fase 3 · Tests del DoD + wiring CI** — cerrada. Commit `bf4151f`.
- [x] **Fase 4 · Validación final** — cerrada. `npm run ci:local` VERDE (6/6 jobs · e2e ✓ · sql skip-safe).

## Próximo paso del flujo

Paso 4 `/revisar` (multi-agent review del diff). Diff acotado (scaffold · ~15 archivos · sin dominios domain-tight tocados) → evaluar `/revisar-simple` vs `/revisar`.

## Qué se hizo en Fase 3

- `vitest.config.ts` (scope `tests/unit/**/*.test.ts` · evita colisión con specs Playwright).
- `tests/unit/PRP-001-sanity.test.ts` (vitest · valida import del cliente Supabase) → verde 1/1.
- `tests/e2e/regression/prp-001-scaffold.spec.ts` (Playwright · home 200 + PUERTITA) → verde 1/1. Alineado a convención regression/ + lowercase (deviación de la ruta del inventario del PRP · refinada).
- `run-sql-tests.sh` skip-safe sin `DATABASE_URL` (paridad state-baseline · honra Bif 1=A · job sql verde-por-skip hasta TASK-002).
- `ci.yml` job e2e: step `npx playwright install --with-deps chromium` + comentario PENDIENTE eliminado + TEST DB seed → TASK-002.
- COVERAGE.md: fila scaffold spec. DT-001 abierta (inconsistencia DATABASE_URL vs TEST_DATABASE_URL → TASK-002).
- **Libs de sistema Chromium instaladas por el user** (sudo playwright install-deps) para correr e2e local.
- DoD: job-order-parity ✓ · typecheck ✓ · build ✓ · unit ✓ · e2e ✓.

## Gotcha Fase 3

- Playwright headless-shell requiere libs de sistema (`libnspr4` etc) · en local se instalan con `sudo npx playwright install-deps chromium` (o `sudo env "PATH=$PATH" npx ...` porque sudo pierde el PATH de node) · en CI lo cubre `--with-deps`. Candidato a memoria feedback si reaparece.

## Qué se hizo en Fase 2

- `src/lib/supabase/client.ts` (`createBrowserClient`) + `src/lib/supabase/server.ts` (`createServerClient` con cookies async de Next 16) · API verificada contra @supabase/ssr@0.12 instalado (getAll/setAll · cookies() Promise).
- `.env.example` con `NEXT_PUBLIC_SUPABASE_URL` + `NEXT_PUBLIC_SUPABASE_ANON_KEY` (+ comentados service-role + TEST_DATABASE_URL para TASK-002).
- Skeleton sin caller real todavía (Auth/RLS/organization_id → TASK-002). DoD: typecheck ✓ build ✓.

## Qué se hizo en Fase 1

- Versiones verificadas contra registry + documentadas en `.claude/memory/reference/stack-versions-PRP-001.md`.
- `package.json`: deps reales (Next 16.2.9 · React 19.2.7 · Tailwind 3.4.19 · @supabase/{supabase-js,ssr} · vitest 4 · playwright 1.61 · eslint 9 · typescript-eslint 8.62 · TS 6.0.3) + script `dev: next dev` + config `lint-staged`.
- `npm install` OK (429 paquetes · sin ERESOLVE · husky activado vía `prepare`).
- `src/app/{layout.tsx,page.tsx,globals.css}` + `src/README.md` creados (placeholder estático PUERTITA · tokens DS completos en globals.css).
- `.gitignore`: `next-env.d.ts` + `*.tsbuildinfo` agregados.
- **DoD verde:** `npm run build` ✓ · `npm run typecheck` ✓ · `npm run lint` ✓ · `npm run dev` sirve `/` HTTP 200 con "PUERTITA".

## Decisión de compat clave

- eslint **9.39.4** (NO 10): `eslint-plugin-react`/`eslint-plugin-import` no soportan eslint 10 todavía. Detalle en el reference.
- Tailwind **v3.4.19** (🔵 Bif 2=A) · compat con Next 16/React 19 confirmada.

## Próxima acción (Fase 2)

Cliente Supabase skeleton: `src/lib/supabase/client.ts` (`createBrowserClient`) + `src/lib/supabase/server.ts` (`createServerClient` con cookies Next) + `.env.example` con `NEXT_PUBLIC_SUPABASE_URL` + `NEXT_PUBLIC_SUPABASE_ANON_KEY`. DoD: typecheck + build verdes.

## Notas / gotchas

- Race dev-server↔hooks: verificar dev server SIEMPRE matar el proceso antes de commitear (Fase 1 lo respetó).
- Scope: TEST DB real + specs e2e/sql con datos → TASK-002 (🔵 Bif 1=A).
