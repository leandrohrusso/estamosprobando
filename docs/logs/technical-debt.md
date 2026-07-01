# Technical Debt log · `docs/logs/technical-debt.md`

> **Bitácora viva de deudas técnicas del proyecto.** Cada deuda detectada fuera del scope del PRP/tarea/sesión actual se registra acá en el acto (regla #24 [`register-out-of-scope-as-dt.md`](../../.claude/rules/register-out-of-scope-as-dt.md) · 8 campos contractuales). El skill [`/auditar-dt`](../../.claude/skills/auditar-dt/SKILL.md) audita mensualmente las DTs activas cruzadas con el roadmap próximo.

## Formato de cada fila (8 campos contractuales)

```markdown
| ID | Síntoma | Archivo/área | PRP destino | Severidad | Mitigación | Disparador | Sesión |
|---|---|---|---|---|---|---|---|
| <DT-NNN> | <síntoma 1-2 frases> | <path/área> | <PRP-NNN o ad-hoc futuro> | critical/normal/nit | <workaround o "ninguna"> | <condición objetiva para cerrar> | <commit hash o referencia> |
```

## DTs Activas

_(vacío al boot · adopter llena conforme detecte deudas fuera del scope del PRP/tarea/sesión actual · regla #24 [`register-out-of-scope-as-dt.md`](../../.claude/rules/register-out-of-scope-as-dt.md))_

| ID | Síntoma | Archivo/área | PRP destino | Severidad | Mitigación | Disparador | Sesión |
|---|---|---|---|---|---|---|---|
| DT-001 | Inconsistencia de nombre de var de conexión a TEST DB: `run-sql-tests.sh` lee `DATABASE_URL` mientras sus hermanos `state-baseline-post-migrations.sh` / `state-assertion.sh` usan `TEST_DATABASE_URL`. Al cablear la TEST DB habrá que exportar ambas o unificar el nombre. | `scripts/run-sql-tests.sh` vs `tests/scripts/infra-flujo/state-*.sh` | TASK-002 | normal | run-sql-tests skipea cleanly sin `DATABASE_URL` (PRP-001 Fase 3) · sin impacto hasta que haya TEST DB | Al cablear la TEST DB real (TASK-002) · unificar en `TEST_DATABASE_URL` | PRP-001 · commit fase 3 |

## DTs Resueltas

_(vacío al boot · mover filas acá cuando un PRP cierre la deuda · agregar commit hash de resolución)_

| ID | Síntoma | Resuelta por | Commit |
|---|---|---|---|
| _(vacío al boot)_ | — | — | — |

---

_Bitácora gestionada por reglas #24 [`register-out-of-scope-as-dt.md`](../../.claude/rules/register-out-of-scope-as-dt.md) + #18 [`golden-rule-docs-memory.md`](../../.claude/rules/golden-rule-docs-memory.md) ítem 4.6 + skill [`/auditar-dt`](../../.claude/skills/auditar-dt/SKILL.md)._
