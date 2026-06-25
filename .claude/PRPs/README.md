# `.claude/PRPs/` · Product Requirements Proposals del proyecto

> **Qué es:** carpeta donde viven los PRPs del proyecto · 1 archivo `.md` por PRP con shape canónico (Objetivo · Por Qué · Qué + Criterios de Éxito · Contexto · Blueprint · Aprendizajes / Self-Annealing).
>
> **Por qué se creó:** el skill [`/planificar`](../skills/planificar/SKILL.md) (paso 2 del flujo de 6 pasos) genera PRPs acá · el skill [`/implementar`](../skills/implementar/SKILL.md) (paso 3) los consume.
>
> **Para qué sirve:** trazabilidad de decisiones arquitectónicas · contexto compartido entre sesiones · DoD verificable por fase · base del bucle agéntico.

## Convención del pack

El pack workflow-base **incluye `prp-base.md` como template canónico opcional** (paridad shape con el `/planificar` skill que embebe el mismo shape inline). Cuando tu proyecto arranque el primer PRP, dos caminos válidos:

1. **Opción A · usar `/planificar` directo.** El skill embebe el shape canónico inline en su § Process · genera el archivo PRP-001-* nuevo sin necesitar referenciar `prp-base.md`. Recomendado para el primer PRP.
2. **Opción B · usar `prp-base.md` incluido en el pack.** Si preferís un template explícito para copiar/pegar, el archivo `.claude/PRPs/prp-base.md` viene en el pack al boot con el shape canónico completo · editar/usar directo sin pasos previos.

Ambas opciones convergen en el mismo shape canónico. La opción A es más simple (cero referenciar template externo) · la B es más explícita (template visible + editable).

## Naming

- **PRPs activos / cerrados:** `PRP-NNN-<descripcion-kebab>.md` (ej: `PRP-001-auth-foundations.md`).
- **Template opcional:** `prp-base.md` (incluido en el pack · usar si optás por Opción B).
- **README:** este archivo.

## Estados del PRP (header)

- `PENDIENTE` · escrito, sin firma del user.
- `APROBADO` · firmado por user en paso 2 (`/planificar` cerrado).
- `EN PROGRESO` · paso 3 (`/implementar`) en curso · checkpoints/handoffs en `.claude/memory/project/`.
- `EN PROGRESO (paso 3 cerrado · 4 + 5 + 6 pendientes)` · bucle agéntico cerrado · falta `/revisar` + `/validar` + `/entregar`.
- `EN PROGRESO (paso 4 cerrado · 5 + 6 pendientes)` · `/revisar` cerrado.
- `EN PROGRESO (paso 5 cerrado · 6 pendiente)` · `/validar` cerrado.
- `COMPLETADO` · `/entregar` cerrado (merge a `main`).
- `DIFERIDO con razón documentada` · bloqueado o postergado con justificación.

## Cómo agregar un PRP nuevo

1. Invocar `/planificar` con el contexto/idea inicial.
2. El skill ejecuta los 8 pasos canónicos (lectura template · investigación · preguntas PM hat · validación activa · firma user · generación del draft · spawn skeptic · firma APROBADO).
3. Archivo nuevo `.claude/PRPs/PRP-NNN-<descripcion>.md` queda en estado `APROBADO`.
4. Invocar `/implementar` para arrancar el bucle agéntico (paso 3).

## Subcarpetas

- [`./_archive/`](./_archive/) — archivado de PRPs y templates obsoletos del directorio activo · `git mv` preserva historia git · cero edits post-archivado. Ver [`./_archive/README.md`](./_archive/README.md) para convención.

## Carpetas hermanas

- [`.claude/skills/`](../skills/) — skills del flujo de 6 pasos · `/planificar` genera PRPs · `/implementar` los consume.
- [`.claude/memory/project/`](../memory/project/) — checkpoints y handoffs operativos del PRP en curso.
- [`docs/logs/technical-debt.md`](../../docs/logs/technical-debt.md) — DTs trackeadas · disparador binario "próximo PRP que toque <archivo>".

---

*Convención de README firmada (regla [`folder-creation-with-readme.md`](../rules/folder-creation-with-readme.md)).*
