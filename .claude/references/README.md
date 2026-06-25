# `.claude/references/` · Reference checklists adoptadas + snapshots de doctrina externa

> **Qué es:** carpeta de referencias externas estables del pack `workflow-base`. Aloja 2 tipos de archivo: (1) **reference checklists adoptadas bit-perfect** del repo [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) (4 archivos · `security-checklist.md` · `performance-checklist.md` · `accessibility-checklist.md` · `testing-patterns.md`) usadas como input por agentes del skill [`/revisar`](../skills/revisar/SKILL.md) + [`/revisar-main`](../skills/revisar-main/SKILL.md) · (2) **snapshots inmutables de doctrina externa** en subcarpeta [`external-doctrine/`](./external-doctrine/) que dieron origen a las reglas firmes del pack (Karpathy · Schluntz · addyosmani · llm-wiki).
>
> **Por qué se creó:** adoptar checklists externas validadas es bajo costo + alto valor (cero reinventar la rueda · cero fork mantenido) · y los snapshots de doctrina externa garantizan trazabilidad permanente ("¿de dónde sale este principio?" → archivo local exacto) + disponibilidad offline cuando la fuente original cambie o desaparezca.
>
> **Para qué sirve:** input firme para los agentes Opus paralelos del review multi-agent (cada checklist alimenta a su agente caller) · referencia consultable cuando una regla o skill cite un principio específico de la doctrina externa · checklist universal cuando el dev nuevo arranca con el pack.

## Convención

- **Bit-perfect del fuente:** los 4 checklists son copia inmutable del upstream addyosmani · cero modificación · header con SHA del snapshot + fecha de adopción + URL fuente.
- **Naming:** mismo del upstream addyosmani (paridad para facilitar discovery + cross-ref).
- **Cuándo se actualiza un checklist:** solo si el repo fuente publica cambio significativo · evaluar caso por caso · si se actualiza, dejar header con la nueva fecha + SHA + cita del cambio (paridad regla [`no-suponer-fuente-de-verdad.md`](../rules/no-suponer-fuente-de-verdad.md) · docs oficiales son autoridad final).
- **Cuándo se suma reference nueva:** SOLO cuando aparece agente caller real (regla #12 [`simplicity-first.md`](../rules/simplicity-first.md) · cero abstracción sin caller).

## Subcarpetas

| Carpeta | Rol |
|---|---|
| [`external-doctrine/`](./external-doctrine/) | Snapshots inmutables de fuentes externas (Karpathy · Schluntz · addyosmani · llm-wiki) que dieron origen a la doctrina codificada en `.claude/rules/` y `.claude/skills/`. README propio con shape canónico regla #22. |

## Archivos actuales

| Archivo | Rol | Consumido por |
|---|---|---|
| [`security-checklist.md`](./security-checklist.md) | OWASP-style security checklist | Agente [`security.md`](../skills/revisar/agents/security.md) de `/revisar` + `/revisar-main` |
| [`accessibility-checklist.md`](./accessibility-checklist.md) | WCAG-style a11y checklist | Agente [`a11y.md`](../skills/revisar/agents/a11y.md) de `/revisar` + `/revisar-main` |
| [`testing-patterns.md`](./testing-patterns.md) | Testing patterns universales | Agente [`tests.md`](../skills/revisar/agents/tests.md) de `/revisar` + `/revisar-main` |
| [`performance-checklist.md`](./performance-checklist.md) | Core Web Vitals · performance patterns | **Sin agente caller al boot del pack** · referencia doctrinal complementaria · agente operativo pendiente (ver [DT-001](../../docs/logs/technical-debt.md)) |

## Carpetas hermanas

- [`.claude/memory/reference/`](../memory/reference/) — punteros a recursos externos (NO contenido bit-perfect · son links a Linear · Slack · Grafana · docs externas · MCPs · servicios cloud). Esta carpeta = contenido inmutable adoptado · `memory/reference/` = punteros vivos.
- [`.claude/skills/revisar/agents/`](../skills/revisar/agents/) — 9 agentes Opus paralelos que consumen las checklists de acá. Carpeta paralela [`/revisar-main/agents/`](../skills/revisar-main/agents/) con los mismos 9 para modo holístico.
- [`.claude/rules/`](../rules/) — reglas firmes que citan los snapshots de [`external-doctrine/`](./external-doctrine/) como fuente del principio codificado (ej: [`think-before-coding.md`](../rules/think-before-coding.md) → `karpathy-claude-md.md` § 1).

## Cómo agregar reference nueva

1. Validá que existe **agente caller real** que la consume (regla #12 [`simplicity-first.md`](../rules/simplicity-first.md) · cero abstracción especulativa). Si no hay caller, NO sumar.
2. Si el contenido es **bit-perfect adoptado** (checklist externa estable): copiar 1:1 desde la fuente · header con SHA del snapshot + fecha de adopción + URL · cero edits.
3. Si el contenido es **snapshot de doctrina externa** (CLAUDE.md · gist · video · charla): va en [`external-doctrine/`](./external-doctrine/) · seguir convención de ese README.
4. Sumar fila a "Archivos actuales" (acá) con rol + agente caller · O a la tabla de `external-doctrine/README.md` según corresponda.
5. Sumar cross-ref desde el archivo del agente caller (`.claude/skills/revisar/agents/<nombre>.md` § "Read these references").

---

*Convención de README firmada 2026-05-24 (regla [`folder-creation-with-readme.md`](../rules/folder-creation-with-readme.md)).*
