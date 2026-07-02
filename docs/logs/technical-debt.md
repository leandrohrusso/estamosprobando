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
| DT-002 | El reset de `scripts/test-migrations.sh` (`DROP SCHEMA public CASCADE`) elimina el event-trigger Supabase `ensure_rls` + su función `rls_auto_enable` (viven en `public`) de la TEST DB. La red de seguridad de auto-habilitación de RLS desaparece tras cada corrida de test-migrations. | `scripts/test-migrations.sh` (reset_schema) + TEST DB Supabase | mini-PRP infra / ad-hoc futuro | normal | RLS explícito en cada tabla del PRP (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`) + invariante `tests/sql/rls-invariants.sql` verde atrapa tablas con policy sin RLS · el auto-enable era defensa redundante | Endurecer `test-migrations.sh` (excluir/recrear `ensure_rls` en el reset) · O cuando un PRP futuro dependa del auto-enable | PRP-002 · Fase 1 |

## DTs Resueltas

_(vacío al boot · mover filas acá cuando un PRP cierre la deuda · agregar commit hash de resolución)_

| ID | Síntoma | Resuelta por | Commit |
|---|---|---|---|
| DT-001 | Inconsistencia de var de conexión a TEST DB: `run-sql-tests.sh` leía `DATABASE_URL` mientras sus hermanos usaban `TEST_DATABASE_URL`. | PRP-002 Fase 1 · unificado a `TEST_DATABASE_URL` en `scripts/run-sql-tests.sh` (guard skip-safe + psql call + comentarios) | PRP-002 · commit fase 1 |

---

_Bitácora gestionada por reglas #24 [`register-out-of-scope-as-dt.md`](../../.claude/rules/register-out-of-scope-as-dt.md) + #18 [`golden-rule-docs-memory.md`](../../.claude/rules/golden-rule-docs-memory.md) ítem 4.6 + skill [`/auditar-dt`](../../.claude/skills/auditar-dt/SKILL.md)._
