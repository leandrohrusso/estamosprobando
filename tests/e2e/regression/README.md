# `tests/e2e/regression/` · Suite heredado de regresión

> ⚙️ **Stack adaptation banner:** este README asume **Playwright** como runner E2E. Si tu proyecto usa otro stack, adaptá: el principio (suite acumulativa por PRP · COVERAGE.md como SoT · pre-validación heredada antes de Fase 1) es universal · la herramienta concreta cambia.

> **Qué es:** colección acumulativa de specs E2E que cubren los PRPs cerrados del producto. Cada PRP que entrega código deja acá los specs que verifican su comportamiento canónico. **Al boot del template la carpeta arranca vacía (cero specs)** · cada adopter llena conforme cierra PRPs del producto.
>
> **Por qué se creó:** materializar la regla firme [`pre-validation-inherited-regression`](../../../.claude/rules/pre-validation-inherited-regression.md) · antes de arrancar Fase 1 del bucle de cualquier PRP nuevo, el agente cruza los archivos del PRP contra `COVERAGE.md` y corre los specs heredados que coincidan. Sin esto, los PRPs nuevos pueden romper código heredado silenciosamente.
>
> **Para qué sirve:** red de seguridad acumulativa contra regresiones · trazabilidad PRP → spec → archivo cubierto · gate de salud del repo en CI remoto.

## Convención

- **Naming:** `prp-NNN-<feature>.spec.ts` o `prp-NNN<letra>-<feature>.spec.ts` (ej: `prp-001-auth.spec.ts` · `prp-009B-event-dates.spec.ts`).
- **Cobertura source of truth:** [`COVERAGE.md`](./COVERAGE.md) es la tabla `archivo/tabla heredada → spec(s) que la cubre`. Mantenerla actualizada al cierre de cada PRP es contractual (regla [`pre-validation-inherited-regression`](../../../.claude/rules/pre-validation-inherited-regression.md) la lee como SoT).
- **Cero modificación de specs heredados** sin OK explícito del user · si un spec se vuelve obsoleto, se marca como tal en `COVERAGE.md` y se archiva (paridad con `tests/e2e/_archive/` cuando aplique).
- **Suite acumulativo:** una vez que un spec entra acá, sobrevive a los PRPs futuros · ese es el invariante que da la red de regresión.

## Archivos actuales (al boot del template)

| Archivo | Rol |
|---|---|
| [`COVERAGE.md`](./COVERAGE.md) | Mapa archivo/tabla → spec(s) · SoT de la regla pre-validación · tabla vacía al boot |

> Cada adopter suma sus specs `.spec.ts` conforme cierra PRPs del producto (paridad regla [`tests-as-dod-per-phase`](../../../.claude/rules/tests-as-dod-per-phase.md) · DoD por fase del paso 3).

## Carpetas hermanas

- [`tests/e2e/`](../) (carpeta padre) — setup compartido + smokes legacy archivados.
- [`tests/sql/`](../../sql/) — invariantes SQL que cubren la capa que E2E no atrapa (RLS · audit · atomicity).
- [`tests/manual/`](../../manual/) — matriz CSV exhaustiva del skill [`/validar`](../../../.claude/skills/validar/SKILL.md) que destila sus casos a estos specs vía PRINCIPIO 6.

## Cómo agregar un spec nuevo

1. **Naming canónico:** `prp-NNN-<feature>.spec.ts`.
2. **Actualizar [`COVERAGE.md`](./COVERAGE.md)** con fila nueva: archivo/tabla cubierta · PRP origen · spec · tipo (e2e o sql).
3. **Verificar verde en CI** antes de mergear el PRP que lo agrega.
4. **Tests del DoD por fase** (regla [`tests-as-dod-per-phase`](../../../.claude/rules/tests-as-dod-per-phase.md)) · cada fase del bucle del paso 3 cierra con sus specs codificados.

---

*Convención de README firmada 2026-05-25 (regla [`folder-creation-with-readme.md`](../../../.claude/rules/folder-creation-with-readme.md)).*
