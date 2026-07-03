# `tests/e2e/regression/COVERAGE.md` · Mapa de cobertura del suite de regresión heredada

> **Qué es:** mapa archivo/tabla heredada → spec(s) que la cubre. **Source of truth contractual** de la regla #16 [`pre-validation-inherited-regression.md`](../../../.claude/rules/pre-validation-inherited-regression.md) (pre-validación de regresión heredada antes de Fase 1 del bucle).
>
> **Por qué se creó:** sin este mapa, el agente al arrancar un PRP nuevo NO sabe qué specs heredados verifican los archivos/tablas que va a tocar · ergo NO puede correr la pre-validación de regla #16. La regla exige cruzar `git diff main --name-only` contra este archivo · este archivo es el cruce.
>
> **Para qué sirve:** input firme del paso 3 (`/implementar`) sub-paso 0 (pre-validación · regla #16) · cada PRP cierra sumando aquí las filas correspondientes a los specs heredados nuevos que generó (paridad regla #15 [`regression-first-on-fix.md`](../../../.claude/rules/regression-first-on-fix.md) + regla #17 [`tests-as-dod-per-phase.md`](../../../.claude/rules/tests-as-dod-per-phase.md)).

---

## Cómo se usa

### Al ARRANCAR un PRP nuevo (paso 3 del flujo · regla #16)

1. `git diff main --name-only` → listar archivos / tablas que el PRP va a tocar.
2. Cruzar con la tabla "Cobertura por archivo / tabla" de abajo.
3. Para cada match, ejecutar el spec heredado localmente:

   ```bash
   npm run test:e2e -- tests/e2e/regression/<spec-heredado>.spec.ts
   ```

   o el comando equivalente del stack del adopter (Vitest · Jest · pytest · etc).

4. **Si alguno falla pre-Fase 1** → bug heredado fuera del scope del PRP en curso · **DT en el acto** según regla #24 [`register-out-of-scope-as-dt.md`](../../../.claude/rules/register-out-of-scope-as-dt.md) (8 campos contractuales · disparador "próximo PRP que toque el archivo heredado") + abrir incidente al inicio del bucle. NO mezclar con trabajo del PRP. Excepción: si el user firma explícito que el fix entra al scope actual (paridad regla #6 [`ante-duda-preguntar-user.md`](../../../.claude/rules/ante-duda-preguntar-user.md)) → agregar caso vecino al CSV del paso 5 + fix con regression-first FIRME (regla #15).
5. **Si todos pasan** → arrancar Fase 1.

> **Refinamiento matriz "escenarios → gate level":** la regla #16 codifica 4 escenarios (A docs-only post-merge / B commits sobre código / C infra pura / D suite stale) que determinan si se corre suite completo · solo specs matching · o se skipea documentado. Ver § "Matriz" de la regla para detalle operativo.

### Al CERRAR un PRP nuevo (paso 5 `/validar` + paso 6 `/entregar`)

Cuando el CSV de `/validar` genera specs nuevos vía regression-first FIRME (regla #15) **O** las fases del paso 3 cierran con tests del DoD (regla #17), agregar fila acá con:

- **Archivo / Tabla:** el path heredado (código o tabla BD) que el spec verifica.
- **PRP origen:** el PRP que creó el spec (`PRP-NNN`).
- **Spec(s) que cubre:** nombre del archivo (`tests/e2e/regression/prp-NNN-<feature>.spec.ts` · O `tests/sql/prp-NNN-<feature>.sql`) + descriptor breve de qué cubre.
- **Tipo:** `e2e` (Playwright / Cypress / Vitest navegador) · `sql` (RLS · audit · atomicity · seeds) · `unit` (lógica pura) · `ci/script` (smoke bash · invariantes mecánicos).
- **Estado:** `✅ activo` · `🟡 quarantined` (flake · skip temporal · DT abierta) · `❌ deprecated` (archivo destino removido · spec preservado en `_archive/` o eliminado).

**Sin actualizar este archivo, el siguiente PRP no va a saber que existe el spec heredado y no lo va a correr en pre-validación** (regla #16 falla mecánicamente).

---

## Cobertura por archivo / tabla

> **🟢 Vacío al boot del pack.** Cada PRP del producto que cierra suma fila acá durante el paso 5 (`/validar`) o paso 6 (`/entregar`) · paridad checklist 6 ítems de regla #18 [`golden-rule-docs-memory.md`](../../../.claude/rules/golden-rule-docs-memory.md). Sin entries acumuladas, la pre-validación de regla #16 cae al escenario C (infra pura · skip documentado) o al escenario A (docs-only · skip) hasta que el primer PRP del producto sume fila.

| Archivo / Tabla | PRP origen | Spec(s) que cubre | Tipo | Estado |
|---|---|---|---|---|
| `src/app/layout.tsx` · `src/app/page.tsx` | PRP-001 | `tests/e2e/regression/prp-001-scaffold.spec.ts` — la home responde 200 y rinde el placeholder de PUERTITA (scaffold smoke · sin DB) | E2E | ✅ activo |
| `src/app/(auth)/login/*` · `src/app/auth/confirm/route.ts` · `src/app/(auth)/onboarding/*` · `src/lib/auth/*` · `src/proxy.ts` · `src/lib/supabase/middleware.ts` | PRP-002 | `tests/e2e/regression/PRP-002-auth-onboarding.spec.ts` — login (form magic link + validación) · onboarding vía route real `/auth/confirm` → Owner (G4/G5) | E2E | ✅ activo |
| tablas `organizations` · `memberships` (RLS + helpers + RPCs) | PRP-002 | `tests/sql/PRP-002-rls-isolation.sql` (aislamiento cross-tenant read+write · G2 · **Owner inmutable a nivel RLS** · LR-002 G-write.8) · `tests/sql/PRP-002-helpers-and-rpcs.sql` (`is_member_of`/`has_role`/RPCs · G3/G4/G8 · **idempotencia de `create_organization_with_owner`** · LR-002 G4.idem) | sql | ✅ activo |
| funciones `is_member_of` · `has_role` · `create_organization_with_owner` · `link_pending_memberships` (shape de `SECURITY DEFINER`) | PRP-002 | `tests/sql/helpers-shape-invariants.sql` — INV-A (search_path) · INV-B (EXECUTE-grant whitelist) · INV-C (STABLE en helpers RLS) · INV-D (sin huérfanos) sobre las 4 funciones del PRP (LR-002 lr_bug_005) | sql | ✅ activo |
| `src/app/(org)/[orgSlug]/*` · `src/app/(auth)/select-organization/*` · `src/components/nav/*` · helpers `requireMembership`/`requireRole`/`getOrgMembers`/`sortMembersPendingFirst` (`src/lib/auth/org.ts`) · actions de miembros | PRP-002 | `tests/e2e/regression/PRP-002-rbac-and-orgs.spec.ts` — RBAC gate (G6) · selector multi-org con submit explícito (G7) · alta pending → vinculación (G8) · CRUD de miembros (add/changeRole/remove con botón "Guardar") | E2E | ✅ activo |
| `src/lib/auth/slug.ts` (slugify + `slugCandidate` + slugs reservados) · `src/lib/auth/schemas.ts` (roles asignables) · `src/lib/auth/org.ts` (`sortMembersPendingFirst`) | PRP-002 | `tests/unit/PRP-002-slug.test.ts` — slugify + `slugCandidate` (colisión `-n` · sin doble guión) + `isReservedSlug` · `tests/unit/PRP-002-rbac-invariants.test.ts` — Owner no asignable (add/change) + `requestId` obligatorio + orden pending-first (LR-002) | unit | ✅ activo |
| `src/lib/auth/session.ts` (`fetchActiveMemberships` · error ≠ vacío) | PRP-002 | `tests/unit/PRP-002-session-error-vs-empty.test.ts` — un error real de la query se propaga (no se colapsa a `[]`) · sin sesión → `[]` (LR-002 lr_bug_005 · hermano LR-001) | unit | ✅ activo |

---

## Carpetas hermanas

- [`tests/scripts/infra-flujo/`](../../scripts/infra-flujo/README.md) — smoke tests bash de invariantes del flujo (paridad orden de jobs CI · shape de reglas P8 · etc). ABORT en CI job `lint` cuando fallan. Esta carpeta cubre invariantes mecánicos del flujo · `regression/` cubre invariantes funcionales del producto.
- _(opcional · al cierre del primer PRP del producto con specs SQL)_ `tests/sql/` — specs SQL de invariantes BD (RLS · audit · atomicity · enums · helpers shape). Adopter lo crea cuando aparezca el primer spec SQL.
- _(opcional · al cierre del primer paso 5 `/validar`)_ `tests/manual/` — CSVs de validación exhaustiva del paso 5 + credenciales template. Adopter lo crea cuando aparezca el primer `/validar` corrido.

## Notas para el adopter

- **READMEs de las carpetas `tests/e2e/` y `tests/e2e/regression/` pendientes** (workaround: adopter los agrega manualmente al crear cada carpeta · paridad regla #22 [`folder-creation-with-readme.md`](../../../.claude/rules/folder-creation-with-readme.md)).
- **Naming canónico de specs:** `prp-NNN-<feature>.spec.ts` para E2E · `prp-NNN-<feature>.sql` para SQL. Cero specs con nombre genérico (`auth.spec.ts` · `events.sql`) · cero trazabilidad al PRP origen.
- **Archivado de specs deprecated:** cuando un PRP del producto remueve archivos cubiertos por specs heredados (refactor estructural · feature deprecada) · el spec sigue en `tests/e2e/regression/_archive/` con sufijo de fecha (`<spec>-deprecated-YYYY-MM-DD.spec.ts`) + fila acá marcada `❌ deprecated` con commit hash del archivado. Paridad cronología append-only de regla #20 [`log-chronology-append-only.md`](../../../.claude/rules/log-chronology-append-only.md).

---

*Convención de `COVERAGE.md` firmada 2026-05-24 (SoT contractual de regla #16 [`pre-validation-inherited-regression.md`](../../../.claude/rules/pre-validation-inherited-regression.md) · shape inspirado en el upstream Ticketera · template arranca vacío al boot del pack `workflow-base`).*
