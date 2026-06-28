---
name: PRP-001 checkpoint
description: Estado vivo de la implementación de PRP-001 (scaffold + infra base) · paso 3 del flujo.
metadata:
  type: project
---

# PRP-001 · checkpoint (paso 3 · /implementar)

> **Última actualización:** 2026-06-26 · Fase 2 cerrada.

## Estado de fases

- [x] **Fase 1 · Deps reales + scaffold mínimo** — cerrada. Commit `6f79437`.
- [x] **Fase 2 · Cliente Supabase skeleton + env** — cerrada.
- [ ] **Fase 3 · Tests del DoD + wiring CI** — próxima.
- [ ] **Fase 4 · Validación final** — pendiente.

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
