# `tests/e2e/` · Tests end-to-end

> ⚙️ **Stack adaptation banner:** este README asume **Playwright** como herramienta E2E (convención `testDir: './tests'` + `**/*.spec.ts`). Si tu proyecto usa otro stack de E2E (Cypress · Puppeteer · Selenium · WebdriverIO · TestCafe · etc), adaptá: el principio (suite acumulativa · regresión por PRP · destino del paso 5 del flujo) es universal · la herramienta concreta cambia.

> **Qué es:** infra de tests E2E del producto. Aloja el setup compartido del runner + la suite acumulativa de regresión bajo `regression/` + (eventualmente) archivado de smokes legacy bajo `_archive/`.
>
> **Por qué se creó:** materializar la convención del runner E2E en una sub-jerarquía clara · separar specs E2E del producto de tests de capa BD (`sql/`) · tests bash de infra (`scripts/`) · y matriz manual del skill `/validar` (`manual/`).
>
> **Para qué sirve:** validar comportamiento end-to-end del producto vía browser · cubrir flujos completos del usuario final del producto · garantizar que los PRPs cerrados no rompen al implementar PRPs nuevos (regla [`pre-validation-inherited-regression`](../../.claude/rules/pre-validation-inherited-regression.md)).

## Convención

- **Naming:** `<scope>/prp-NNN-<feature>.spec.ts` (ej: `regression/prp-001-<feature>.spec.ts`).
- **Setup compartido (opcional):** si el proyecto necesita helpers reutilizables (login · selectors comunes · fixtures), van en `setup.ts` o módulo equivalente en esta raíz · cada adopter define su shape según la UI y flujo de auth real del producto. 3 convenciones universales para esos helpers (independientes del stack/UX):
  - **Helpers stateless · cero side effects.** Cualquier setup que necesite cleanup (fixtures BD · seeds · auth global) va en `globalSetup` / `globalTeardown` (ver [`../global-setup.ts`](../global-setup.ts) como ejemplo del shape) · NO dentro de helpers individuales que los specs importan.
  - **Selectors estables vs componentes UI.** Preferir `input[name="..."]` o `data-testid` antes que `getByLabel(...)` cuando el label puede colisionar con elementos interactivos del componente (ej: botón "Mostrar contraseña" dentro de un input password rompe `getByLabel('Contraseña')`).
  - **Helpers wrappean flujos · NO políticas.** Un helper `login()` puede hacer "llenar form + click + esperar redirect" (mecánica) · pero NO debe encapsular "qué pasa si el login falla" o "qué role usar por default" (esas decisiones viven en cada spec).
- **Race conditions / concurrency tests (opcional · típicamente cuando flag [`atomicity.enabled: yes`](../../.claude/config/agents-applicability.yml)):** specs que verifican comportamiento concurrente de helpers internos / RPCs bajo presión real (ej: 100 reservas paralelas vs stock=N) usando el runner Playwright pero **NO** atacando el browser · usan SDK admin (`createClient` con service_role) y llaman funciones internas directo. Convención naming sugerida: `race-<feature>.spec.ts` o subcarpeta dedicada (`tests/race/` · firma user antes de crear · paridad regla [`respect-existing-folder-structure`](../../.claude/rules/respect-existing-folder-structure.md)). 3 convenciones universales para esos specs (independientes del stack):
  - **Promise.all con N=100 default.** Cardinalidad estándar para race conditions · evaluar exactly N-ok / N-fail / final-state · mayor solo si el caso lo justifica (cuesta tiempo de CI).
  - **Cleanup obligatorio en `afterEach` / `afterAll`.** Race tests mutan TEST DB compartida con specs E2E del browser · sin cleanup contamina al siguiente spec.
  - **Atacan capa interna (helpers / RPCs / SDK admin) · NO browser · NO endpoints HTTP.** El caveat aclara qué se está testeando (concurrencia real del helper) vs qué NO (flujo end-to-end del usuario).
- **Suite acumulativo:** cada PRP del producto deja sus specs en `regression/` · NO se eliminan (solo se archivan a `_archive/` si la cobertura quedó solapada con un spec más completo).

## Subcarpetas

| Carpeta | Rol |
|---|---|
| [`regression/`](./regression/) | Suite heredado · acumulativo por PRP · `COVERAGE.md` como source of truth |
| `_archive/` (futuro) | Smokes legacy archivados cuando su cobertura quede solapada por specs `regression/` más completos · adopter la crea cuando aplique |

## Carpetas hermanas

- [`tests/sql/`](../sql/) — invariantes SQL (RLS · audit · atomicity) · cubre capas que E2E no atrapa.
- [`tests/manual/`](../manual/) — matriz CSV del skill [`/validar`](../../.claude/skills/validar/SKILL.md) (paso 5 del flujo) · runtime real con MCPs.
- [`tests/scripts/`](../scripts/) — smoke tests bash de la fábrica del proyecto · invariantes mecánicos del flujo.

## Cómo agregar un spec nuevo

1. **Naming canónico:** `regression/prp-NNN-<feature>.spec.ts`.
2. **Actualizar [`regression/COVERAGE.md`](./regression/COVERAGE.md)** con fila nueva: archivo/tabla cubierta · PRP origen · spec · tipo (e2e o sql).
3. **Verificar verde en CI** antes de mergear el PRP que lo agrega.
4. **Tests del DoD por fase** (regla [`tests-as-dod-per-phase`](../../.claude/rules/tests-as-dod-per-phase.md)) · cada fase del bucle del paso 3 cierra con sus specs codificados.

---

*Convención de README firmada 2026-05-25 (regla [`folder-creation-with-readme.md`](../../.claude/rules/folder-creation-with-readme.md)).*
