# `.claude/rules/` · Satélites de reglas FIRMES del flujo (shape P8)

> **Qué es:** carpeta de los satélites de reglas firmes del flujo del proyecto. Cada archivo `.md` codifica una regla operacional firme con shape P8 (6 secciones: Overview · When · Process · Anti-rationalization · Red flags · Verification) + frontmatter (`name` · `description` · `type: rule`). La lista canónica con leyenda + cross-refs vive en `CLAUDE.md` § Reglas FIRMES.
>
> **Por qué se creó:** materializar la externalización de reglas firmes en archivos individuales · `CLAUDE.md` indexa cada regla con leyenda + link a su satélite · el satélite contiene el detalle expandido (shape P8 · ejemplos · anti-rationalization). Sin esta separación, `CLAUDE.md` sería gigante y la IA tardaría más en cargarlo · y refinar una regla requeriría editar un archivo monolítico.
>
> **Para qué sirve:** cada regla firme vive en su propio archivo legible y mantenible · `CLAUDE.md` indexa todas en la tabla "Reglas FIRMES" · al detectar el trigger de una regla, la IA consulta el satélite correspondiente (NO inventa la regla · NO improvisa).

> **Nota sobre referencias históricas dentro de los satélites:** varios `.md` mencionan PRPs · DTs · fechas concretas (ej: `PRP-NNN · YYYY-MM-DD` · `DT-NNN`) como **contexto de ORIGEN** de la regla en el proyecto upstream donde se codificó. Esas referencias **NO aplican a tu proyecto** · son pedigrí ("anti-pattern detectado en sesión X · llevó a esta regla"). El principio descrito por cada regla es universal · la mención del PRP/DT/fecha es solo el "por qué" histórico. Tu repo generará sus propias referencias históricas cuando adopte/refine reglas durante un PRP del producto.

## Convención

- **Naming:** kebab-case en inglés · descriptivo · `<regla-corta>.md` (ej: `simplicity-first.md` · `regression-first-on-fix.md`).
- **Shape P8 obligatorio:** Overview · When · Process · Anti-rationalization · Red flags · Verification + frontmatter `type: rule`.
- **Verificación mecánica:** smoke test bash en `tests/scripts/infra-flujo/rules-shape-p8.sh` valida que todas las reglas mantienen shape P8 + frontmatter. Wireado al job `lint` del CI (local + remoto · ABORT en fallo).
- **Indexación en CLAUDE.md:** cada regla nueva suma fila a la tabla canónica de "Reglas FIRMES" con leyenda + link.

## Inventario inicial (universal · agnóstico de stack)

El pack arranca con un set de reglas universales que codifican principios del flujo de trabajo aplicables a cualquier proyecto SaaS asistido por agente (LLM/Claude Code). Inspiración doctrinal: Karpathy (think-before-coding · simplicity-first · surgical-changes · goal-driven-execution · llm-wiki indexing+logging) · Schluntz/Vibe Coding (PM hat · 6 preguntas · verify behavior not LoC) · addyosmani agent-skills (shape P8 · anti-rationalization · red flags). Snapshots fuente inmutables viven en [`.claude/references/external-doctrine/`](../references/external-doctrine/).

Categorías de las reglas firmes incluidas:

- **Calidad senior** · `quality-standard-senior` · `always-fix-all-bugs` · `regression-first-on-fix` · `fatigue-self-evaluation` · `tests-as-dod-per-phase`.
- **Pensar antes de codear** · `think-before-coding` · `simplicity-first` · `surgical-changes` · `goal-driven-execution` · `complejidad` · `principios-desarrollo-flujo`.
- **Trabajar con el user** · `metodologia-iteracion` · `decisiones-features` · `ante-duda-preguntar-user` · `no-suponer-fuente-de-verdad` · `conversation-style` · `repaso-features` · `heuristica-referente-mercado` · `documentos-definitivos`.
- **Docs & memoria** · `golden-rule-docs-memory` · `log-chronology-append-only` · `lint-memory-periodic` · `register-out-of-scope-as-dt` · `folder-creation-with-readme` · `respect-existing-folder-structure` · `claude-design-matrix`.
- **Flujo & continuidad** · `status-tracker-visible` · `session-handoff` · `pre-validation-inherited-regression` · `consultor-read-only`.
- **Infra del flujo** · `husky-hooks-smoke-tests` · `push-and-ci-policy`.

## Cómo agregar una regla nueva

1. **Validar duplicados:** ¿hay regla existente que ya cubra el patrón? Si SÍ, extender.
2. **Naming canónico:** kebab-case en inglés · descriptivo · 2-4 palabras.
3. **Shape P8:** copiar plantilla de regla existente (ej: `surgical-changes.md`) · 6 secciones + frontmatter.
4. **Wiring en `CLAUDE.md`:** sumar fila a la tabla "Reglas FIRMES" con número siguiente · leyenda + link + "Aplica a".
5. **Cross-references:** vincular con reglas hermanas relevantes en el footer del satélite (sección `**Cross-reference firme:**`).
6. **Verificación:** `bash tests/scripts/infra-flujo/rules-shape-p8.sh` debe pasar verde post-creación.

## Carpetas hermanas

- [`.claude/skills/`](../skills/) — skills del flujo de 6 pasos + skills auxiliares · cada uno con shape canónico inspirado en addyosmani.
- [`.claude/memory/`](../memory/) — memoria persistente del proyecto · feedback/reference/project/user · index en `MEMORY.md`.
- [`.claude/references/external-doctrine/`](../references/external-doctrine/) — snapshots inmutables de las fuentes doctrinales que dieron origen a estas reglas (Karpathy · Schluntz · addyosmani).

---

*Convención de README firmada durante el desarrollo del pack (regla [`folder-creation-with-readme.md`](./folder-creation-with-readme.md)).*
