# `.claude/memory/feedback/` · Anti-patterns · gotchas · correcciones

> **Qué es:** memorias técnicas que capturan correcciones del user al agente · anti-patterns descubiertos · gotchas universales aplicables a código futuro. Cada archivo cubre un patrón único · indexado en `MEMORY.md` § `feedback/`.
>
> **Por qué se creó:** sin esto, el agente repite los mismos errores cada sesión nueva. Los gotchas (race conditions · hydration mismatches · policies invisibles · skip-ci en HEAD del PR · etc) se descubren con costo · documentarlos los previene a futuro.
>
> **Para qué sirve:** capturar la lección · explicar el WHY · dejar la regla derivada · permitir que cualquier sesión nueva consulte el patrón antes de cometerlo de nuevo.

## Convención

- **Naming:** kebab-case · descriptivo · `<patron>.md` (ej: `dev-server-typecheck-race-during-ci-local.md` · `squash-merge-dev-divergence.md`).
- **Frontmatter:** `name` · `description` · `type: feedback`.
- **Estructura sugerida:** Overview con incident concreto · root cause · regla derivada · ejemplos del repo · cross-references. Ver [`_template.md`](./_template.md) (template canónico de la sub-carpeta).
- **Indexar en MEMORY.md:** una línea por entry · descripción 1-frase con el WHY del patrón.

## Memorias seed (pack workflow-base)

> El pack incluye un seed de **memorias universales** sanitizadas (gotchas del harness Claude Code + git/CI/GH Actions + meta-flujo) que aplican a cualquier proyecto que use el pack. Listadas en `MEMORY.md` § `feedback/`. Sumar memorias específicas del stack del proyecto conforme aparezcan.

## Cómo agregar una memoria nueva

1. Reproducir el patrón mentalmente · root cause claro.
2. Copiar [`_template.md`](./_template.md) y renombrar a kebab-case con frontmatter + Overview + ejemplos.
3. Sumar entry en [`../MEMORY.md`](../MEMORY.md) § `feedback/` con descripción 1-frase.
4. Cross-reference desde reglas firmes en [`.claude/rules/`](../../rules/) cuando aplique.

## Carpetas hermanas

- [`.claude/memory/project/`](../project/) — estado vivo de PRPs · checkpoints · handoffs (NO patrones técnicos).
- [`.claude/memory/reference/`](../reference/) — punteros y referencias operativas internas (tooling · debt log · helpers).
- [`.claude/memory/user/`](../user/) — perfil del user · preferencias de comunicación · stack.

## Reglas firmes asociadas

- [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) — al cerrar PRP · checklist 6 ítems incluye actualizar memoria persistente.
- [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md) — bug detectado · caso de regresión codificado ANTES del fix · memoria nueva en `feedback/` cuando aplica.
- [`surgical-changes.md`](../../rules/surgical-changes.md) — cero drive-by refactoring · gotchas históricos en `feedback/` justifican excepciones documentadas.
- [`lint-memory-periodic.md`](../../rules/lint-memory-periodic.md) — lint mensual de `.claude/memory/` con 6 criterios (incluye criterio 1 "contradicciones entre memorias" y criterio 2 "stale claims").

---

*Convención de README firmada upstream (regla [`folder-creation-with-readme.md`](../../rules/folder-creation-with-readme.md)).*
