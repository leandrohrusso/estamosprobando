# `.claude/memory/user/` · Perfil del user / equipo

> **Qué es:** memorias sobre el user (o equipo) del proyecto · rol · stack · responsabilidades · conocimiento previo · preferencias de comunicación · tooling habitual.
>
> **Por qué se creó:** sin esto, el agente trata a un senior con 10 años de Go igual que a un estudiante que codea por primera vez. Conocer el perfil permite tailorizar comunicación · ajustar nivel de explicación · sugerir tooling apropiado · respetar preferencias.
>
> **Para qué sirve:** que cualquier sesión nueva consulte el perfil ANTES de responder · que la comunicación se adapte al user · que el agente NO sugiera tooling que el user ya descartó.

## Convención

- **Naming:** kebab-case · `<scope>.md` (ej: `<nombre>.md` para perfil personal · `tooling.md` para stack y tooling habitual · `equipo.md` para perfil del equipo).
- **Frontmatter:** `name` · `description` · `type: user`.
- **Estructura sugerida:** quién es · rol · stack/conocimiento técnico · preferencias de comunicación · tooling habitual · qué NO sugerir. Ver [`_template.md`](./_template.md).
- **Indexar en MEMORY.md:** una línea por entry · descripción 1-frase con la info clave.

## Memorias seed (pack workflow-base)

> Vacío al boot del pack. Llenar con el perfil del user/equipo del proyecto en la primera sesión.

## Cómo agregar una memoria nueva

1. Detectar info relevante del user durante la sesión (rol · stack · preferencia explícita · corrección sobre tooling).
2. Copiar [`_template.md`](./_template.md) y renombrar a kebab-case con frontmatter + perfil + preferencias.
3. Sumar entry en [`../MEMORY.md`](../MEMORY.md) § `user/` con descripción 1-frase.
4. Cuando el user corrige al agente sobre cómo comunicarse (ej: "no me llenes de tablas") · capturar en `feedback/` (NO acá · acá es perfil estable · no correcciones puntuales).

## Carpetas hermanas

- [`.claude/memory/feedback/`](../feedback/) — correcciones puntuales del user (NO perfil estable).
- [`.claude/memory/project/`](../project/) — estado del proyecto (NO del user).
- [`.claude/memory/reference/`](../reference/) — referencias operativas (NO perfil).

## Reglas firmes asociadas

- [`conversation-style.md`](../../rules/conversation-style.md) — preferencia de estilo conversacional del user · puede vivir acá si es estable.
- [`metodologia-iteracion.md`](../../rules/metodologia-iteracion.md) — formato canónico de decisiones · paridad con perfil del user que decide.

---

*Convención de README firmada 2026-05-20 (regla [`folder-creation-with-readme.md`](../../rules/folder-creation-with-readme.md)).*
