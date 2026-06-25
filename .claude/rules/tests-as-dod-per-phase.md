---
name: tests-as-dod-per-phase
description: Cada fase del bucle agéntico cierra con código + tests codificados que verifican los criterios de éxito · sin tests = fase no cerrada
type: rule
applies-to: todas las fases del paso 3 en Modo C, sin excepción
---

> ⚙️ **Stack adaptation banner:** esta regla asume stack con **comandos npm `typecheck` + `build`** (Next.js/TypeScript) + **BD relacional con RLS** (PostgreSQL/Supabase) en los ejemplos del § Process · Red flags · Verification (`npm run typecheck` · `npm run build` · tests SQL en `tests/sql/`). Si tu proyecto usa otro stack (Python/Django · Ruby/Rails · Go · Rust · etc), adaptá los mecanismos: el principio (cada fase del bucle cierra con tests codificados que verifican criterios de éxito · sin tests = fase no cerrada · 2-5 specs/queries por fase típica · typecheck + build verdes al cierre de cada fase) es universal · los comandos concretos (`npm run typecheck`/`build`) son ejemplos del stack · reemplazá por equivalentes (ej: `mypy` + `python -m build` · `bundle exec rspec` · `go build` + `go test` · `cargo build` + `cargo test` · etc).

## Overview

> **Cada fase del bucle agéntico (paso 3) cierra con código de producción + tests codificados que verifican los criterios de éxito de esa fase. Sin tests = fase no cerrada.**

**Por qué esta regla existe:** sin tests codificados, los criterios de éxito del PRP son declarativos. Un PRP siguiente que toca código heredado no tiene cómo detectar regresión. Los tests del DoD son el legado que cada fase deja al suite acumulativo de CI. La verificación runtime via MCPs durante el bucle valida que la feature funciona AHORA · los tests codificados garantizan que sigue funcionando dentro de 6 meses.

## When

**Aplica a:**

- Todas las fases del paso 3 (Modo C) sin excepción.
- Cierre de fase = commit local con código + tests + typecheck/build verde.

**NO aplica a:**

- Modo A (tasks triviales sin fases).
- Modo B (skills cerrados con su propia validación interna).

## Process

**Mapping de tipo de fase → test esperado:**

| Tipo de fase | Test esperado |
|---|---|
| Invariantes de seguridad (autorización · multi-tenant · permisos) | Test SQL o de integración que valida el invariante |
| Atomicidad de operaciones críticas (transacciones · concurrencia) | Spec E2E con asserts del estado final (`tests/e2e/regression/<prp-feature>.spec.ts`) |
| Audit trail / logs | Query contra tabla de auditoría después de la operación |
| Soft-delete / archivado + permisos por rol | Spec E2E + query SQL |
| Migración aplicada e idempotente | Aplicar la migración 2 veces y comparar dumps (o smoke automático que lo verifique) |
| Render de datos snapshot / históricos | Spec asegurando que el render lee del snapshot persistido y NO de tablas live |

**Cuántos tests por fase:** 2-5 specs/queries por fase típica. Total esperado por PRP: 10-20 tests nuevos.

**Coordinación con PRINCIPIO 6 del SKILL `/validar`:** los tests del DoD se escriben durante el bucle (paso 3). Los tests del paso 5 se escriben cuando una fila CSV `Falla` y se arregla. Ambos terminan en `tests/e2e/regression/` o `tests/sql/`, nombrados por PRP. Ambos corren en CI.

**`npm run typecheck` + `npm run build` verdes al cierre de cada fase.** El skill `/implementar` valida runtime via MCPs pero NO ejecuta typecheck ni build estáticamente. Sin esto, errores TS cross-archivo o errores de build prod (RSC, dynamic, edge) se acumulan entre fases. El agente los corre manualmente. Costo ~10-30s por fase. Sin esta validación per-fase, la próxima fase trabaja sobre base inestable.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Esta fase es solo refactor, no necesita tests" | NO. Refactor sin tests es indistinguible de regresión silenciosa. Mínimo: typecheck+build verde + spec heredado relevante (regla `pre-validation-inherited-regression`) corre sin caer. Si el refactor toca lógica de RPC/RLS, agregar test propio. |
| "Los tests los escribo en la última fase, junto" | NO. Cada fase tiene su DoD. Postergar tests a la última fase pierde la oportunidad de detectar bugs entre fases (cuando son baratos de aislar) y los acumula en una sentada de fatiga al final. |

## Red flags

- 🚩 Cerraste una fase sin commit de tests nuevos (verificable con `git log --stat` del commit de cierre).
- 🚩 typecheck o build rojo y "lo arreglo en la próxima fase".
- 🚩 La fase es de schema/RPC y no agregaste query SQL ni spec atomicity.
- 🚩 El PRP completo cerró con menos de 10 tests nuevos cuando tocó múltiples capas (UI + RPC + RLS).

## Verification

- [ ] La fase cerrada tiene 2-5 tests nuevos en `tests/e2e/regression/` o `tests/sql/`.
- [ ] `npm run typecheck` verde al cierre de la fase.
- [ ] `npm run build` verde al cierre de la fase.
- [ ] PRP completo terminó con 10-20 tests nuevos sumados al suite acumulativo.
- [ ] Cada test tiene assertion específica (no `expect(true).toBe(true)` placeholders).

**Cross-reference firme:**

- Hermana operativa: [`pre-validation-inherited-regression.md`](./pre-validation-inherited-regression.md) (specs heredados verdes pre-Fase 1 · esta regla cubre tests acumulativos por fase).
- Hermana operativa: [`regression-first-on-fix.md`](./regression-first-on-fix.md) (filas Falla del CSV generan tests en mismo destino · `tests/e2e/regression/` o `tests/sql/`).
