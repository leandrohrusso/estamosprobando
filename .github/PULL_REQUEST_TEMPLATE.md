# PR · `<descripción corta>`

> Plantilla para PRs `dev` → `main` (cierre de PRP del producto) y otros PRs hacia `main`.
> Ver [WORKFLOW.md § 6 Política de pushes y CI runs](../WORKFLOW.md) para el protocolo completo + regla #27 [`push-and-ci-policy.md`](../.claude/rules/push-and-ci-policy.md).
>
> ⚙️ **Stack adaptation banner:** los ejemplos del checklist asumen stack Node + Playwright + SQL del template (`npm run typecheck` · `tests/e2e/regression/*.spec.ts` · `tests/sql/`). Si tu stack difiere (Python · Rails · Go · etc) adaptá los comandos y paths · los principios (CI verde · diff quirúrgico · tests acumulativos · DTs trackeadas · docs cerradas) son universales.

## Tipo

- [ ] `feat(prp-NNN)` · cierre de PRP completo
- [ ] `fix(prp-NNN)` · fix puntual sobre PRP en curso
- [ ] `refactor` · refactor sin cambios funcionales
- [ ] `docs` · solo documentación
- [ ] `test` · solo tests
- [ ] `chore` · infra / dependencias / config

## PRP relacionado

`PRP-NNN-<feature-name>` · [link al PRP](../.claude/PRPs/PRP-NNN-<feature-name>.md)

(Si no aplica un PRP, justificar acá por qué.)

## Resumen

<!-- 2-3 frases en el idioma del producto (ver BUSINESS_LOGIC.md). Qué hace el PR + por qué importa. -->

## Cambios

<!-- Bullets de lo más relevante. -->

-

## Checklist obligatorio

### Implementación

- [ ] CI verde (todos los jobs bloqueantes del proyecto · ej stack Node + Supabase: typecheck · lint · build · e2e · sql · migrations-idempotency).
- [ ] Comandos del stack localmente verdes (ej Node: `npm run typecheck` + `npm run build`).
- [ ] Suite E2E localmente verde (ej Node: `npm run test:e2e` · al menos los specs base + nuevos del PRP).
- [ ] Diff respeta cambios quirúrgicos: cada línea trazable al PRP / fix solicitado (regla #11 [`surgical-changes.md`](../.claude/rules/surgical-changes.md)).

### Testing acumulativo (si el PR cierra un PRP)

- [ ] Tests codificados nuevos commiteados (ej stack Playwright: `tests/e2e/regression/prp-NNN-*.spec.ts` y/o `tests/sql/`).
- [ ] [`tests/e2e/regression/COVERAGE.md`](../tests/e2e/regression/COVERAGE.md) actualizado con specs nuevos (regla #16 [`pre-validation-inherited-regression.md`](../.claude/rules/pre-validation-inherited-regression.md)).
- [ ] CSV del paso 5 archivado en `tests/manual/PRP-NNN_*.csv` con 100% verde (Funciona o Diferido justificado).
- [ ] Specs vienen de PRINCIPIO 6 del skill [`/validar`](../.claude/skills/validar/SKILL.md) (cada Falla → Fix dejó un spec · regla #15 [`regression-first-on-fix.md`](../.claude/rules/regression-first-on-fix.md)).

### Deuda y bitácora

- [ ] [`docs/logs/technical-debt.md`](../docs/logs/technical-debt.md) actualizado: deudas nuevas abiertas + deudas resueltas marcadas con commit hash (regla #24 [`register-out-of-scope-as-dt.md`](../.claude/rules/register-out-of-scope-as-dt.md)).
- [ ] [`docs/logs/ultrareview-log.md`](../docs/logs/ultrareview-log.md) actualizado si se corrió `/ultrareview` durante el PRP.
- [ ] Memoria persistente en `.claude/memory/feedback/` actualizada con aprendizajes nuevos (con entry index en `MEMORY.md` · regla #18 [`golden-rule-docs-memory.md`](../.claude/rules/golden-rule-docs-memory.md)).

### Documentación

- [ ] [`docs/product/product-roadmap.md`](../docs/product/product-roadmap.md): tasks marcadas `[x]` con notas inline.
- [ ] PRP en `.claude/PRPs/PRP-NNN-*.md` cerrado con sección "Aprendizajes / Self-Annealing".
- [ ] Si afecta identidad / decisiones globales, actualizar `BUSINESS_LOGIC.md` o `CLAUDE.md`.

### Si toca áreas críticas del proyecto

> Las áreas críticas las define cada proyecto en [`BUSINESS_LOGIC.md § 8 Constraints no negociables`](../BUSINESS_LOGIC.md). Ejemplos típicos: pagos · RLS · multi-tenant · atomicity de stock · checkout · datos legales/sensibles. Si el diff toca alguna:

- [ ] `/ultrareview <PR-number>` ejecutado y resultado registrado en `docs/logs/ultrareview-log.md`.
- [ ] Hallazgos `🔴 pendiente` movidos a `docs/logs/technical-debt.md` o resueltos en este PR (regla #10 [`always-fix-all-bugs.md`](../.claude/rules/always-fix-all-bugs.md)).

## Test plan

<!-- Markdown checklist de qué probar antes de mergear (si aplica adicional al CI). -->

- [ ]
- [ ]
- [ ]

## Notas para el reviewer

<!-- Cualquier contexto que no está en el código: decisiones de diseño, alternativas consideradas, deuda nueva justificada, etc. -->
