# `.claude/references/external-doctrine/` · Snapshots inmutables de fuentes externas de doctrina

> **Qué es:** carpeta con snapshots fechados de las fuentes externas que dieron origen a la doctrina codificada en `.claude/rules/` y `.claude/skills/` de este pack. Cada archivo es **inmutable** · refleja el contenido en el momento del snapshot original · NO la fuente actual.
>
> **Por qué se creó:** disponibilidad offline para cuando una regla firme o un skill cite un principio específico (ej: P4 "Think Before Coding" · P9 "anti-rationalization tables") · trazabilidad permanente ("¿de dónde sale este principio?" → archivo exacto local) · inmutabilidad (si la fuente original cambia · la doctrina codificada sigue verificable contra el snapshot).
>
> **Para qué sirve:** servir de fuente verificable cuando una regla o skill referencia un principio específico · evitar dependencia de fuentes externas (repos · gists · videos) que pueden cambiar o desaparecer.

## Convención

- **Inmutables por contrato:** cero edits post-creación. Si la fuente original cambió significativamente · agregar archivo nuevo `<nombre>-update-YYYY-MM-DD.md` al lado · NO sobrescribir el viejo.
- **Naming:** kebab-case con prefijo de origen (`karpathy-*` · `addyosmani-*` · `vibe-coding-*`) + descriptor del archivo fuente.
- **Cero credenciales · cero PII:** snapshots de docs públicas y charlas de YouTube · NO contenido privado.

## Archivos actuales

| Archivo | Origen | Doctrina derivada (principios) |
|---|---|---|
| [`karpathy-claude-md.md`](./karpathy-claude-md.md) | <https://github.com/forrestchang/andrej-karpathy-skills> (CLAUDE.md) | P4 · P5 · P6 · P7 (think-before-coding · simplicity-first · surgical-changes · goal-driven-execution) |
| [`karpathy-examples.md`](./karpathy-examples.md) | <https://github.com/forrestchang/andrej-karpathy-skills> (EXAMPLES.md) | P4 · P5 · P6 · P7 (ejemplos antes/después · base de anti-rationalization tables P9) |
| [`addyosmani-readme.md`](./addyosmani-readme.md) | <https://github.com/addyosmani/agent-skills> (README.md) | P8 · P9 · P10 (shape canónico de skills · anti-rationalization tables · red flags) |
| [`addyosmani-agents.md`](./addyosmani-agents.md) | <https://github.com/addyosmani/agent-skills> (AGENTS.md) | P8 (shape estándar) + validación de diseño multi-agent paralelo |
| [`vibe-coding-schluntz.md`](./vibe-coding-schluntz.md) | Charla Erik Schluntz (Anthropic) · resumen de la charla | P1 · P2 · P3 (PM hat · 6 preguntas · verify behavior not LoC · checkpoints verificables) |
| [`karpathy-llm-wiki.md`](./karpathy-llm-wiki.md) | <https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f> | P11 · P12 (indexing & logging · operación lint periódico de memoria) |
| [`karpathy-llm-wiki-video.md`](./karpathy-llm-wiki-video.md) | <https://www.youtube.com/watch?v=p5YgvC6yzCs> (tutorial práctico Obsidian + Claude Code) | P11 · P12 (complemento práctico del gist) |

**Referencias complementarias** (NO como snapshots porque son herramientas evolutivas · solo link de referencia):

- **[Obsidian](https://obsidian.md/)** — cliente markdown wiki gratuito que Karpathy y el creador del video usan para navegar el patrón llm-wiki. Compatible con stack open · free local. Opcional · evaluable como visualizador de la memoria persistente del proyecto.

## Reglas de uso

- ❌ **NO modificar** ninguno de estos archivos · son snapshots inmutables.
- ✅ **SÍ consultar** cuando una regla o skill cite un principio específico y necesites verificar la fuente original.
- ✅ **SÍ actualizar** un snapshot si la fuente original cambió significativamente · agregar archivo nuevo `<nombre>-update-YYYY-MM-DD.md` al lado · NO sobrescribir el viejo.

## Cuándo se consultan

- Cuando refinás una regla firme y querés verificar la fuente original del principio.
- Cuando creás un skill nuevo y querés revisar el shape canónico de addyosmani (P8).
- Cuando refinás un checklist (ej: 6 preguntas PM hat) y querés verificar la formulación original de Schluntz.
- Cuando aparece una duda sobre cómo se interpretó originalmente un principio (P1-P12).

## Carpetas hermanas

- [`.claude/rules/`](../../rules/) — reglas firmes del flujo (~31) · varias citan estos snapshots como fuente del principio codificado (ej: `think-before-coding.md` → `karpathy-claude-md.md` § 1 · `simplicity-first.md` → `karpathy-claude-md.md` § 2 · etc).
- [`.claude/skills/`](../../skills/) — skills del flujo · inspirados en el shape canónico de `addyosmani-agents.md` (P8) y embeben las 6 preguntas PM hat de `vibe-coding-schluntz.md`.

## Reglas firmes asociadas

- [`no-suponer-fuente-de-verdad.md`](../../rules/no-suponer-fuente-de-verdad.md) — orden B (cosas externas) · docs oficiales son prioridad 1 · estos snapshots son referencia secundaria fechada cuando la fuente original puede haber cambiado.
- [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) — al cerrar trabajo que codificó un principio · cross-reference al snapshot fuente cuando aplique.

---

*Convención de README según regla [`folder-creation-with-readme.md`](../../rules/folder-creation-with-readme.md).*
