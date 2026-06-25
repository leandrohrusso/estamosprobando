# `.claude/hooks/` · Hooks del agente Claude Code

> **Qué es:** carpeta de hooks ejecutables del agente Claude Code · scripts shell que el harness invoca en respuesta a eventos del agente (`PreToolUse` · `PostToolUse` · `Stop` · `Start` · etc). NO confundir con [`.husky/`](../../.husky/) (hooks de Git · canal completamente distinto).
>
> **Por qué se creó:** convención del harness Claude Code · permite agregar comportamientos side-effect al agente sin modificar el código del agente mismo. Los hooks viven acá y se referencian desde `.claude/settings.json` (cuando el adopter define wiring · ver [`update-config`](https://docs.claude.com/en/docs/claude-code/settings) en docs oficiales).
>
> **Para qué sirve:** observabilidad del agente · logging de uso de tools · validaciones automáticas en eventos · cualquier comportamiento side-effect que el harness debe disparar antes/después de tool calls del agente.

## Convención

- **Naming:** kebab-case en inglés · `<evento>-<acción>.sh` (ej: `log-tool-usage.sh` · `pre-edit-validate.sh`).
- **Shape:** scripts bash POSIX-compatible · ejecutables (`chmod +x`) · cero dependencias del proyecto (corren del lado del harness · NO del runtime del producto).
- **Output a stdout:** JSON `{}` por default · el harness lo interpreta como "no bloquear el tool" · si el hook decide bloquear, retornar JSON con `{"decision": "block", "reason": "..."}` (ver docs oficiales).
- **Logs runtime:** los outputs persistentes van a `.claude/logs/<archivo>.log` (carpeta gitignored · se crea al primer run del hook · cero pre-crear en el repo).
- **Wiring:** los hooks NO se ejecutan solos · necesitan declaración en `.claude/settings.json` bajo la clave `hooks` con el evento correspondiente. El adopter wirea cuando arma su settings.

## Archivos actuales

| Archivo | Evento | Rol |
|---|---|---|
| `log-tool-usage.sh` | `PostToolUse` | Loguea uso de tools del agente a `.claude/logs/tool-usage.log` con timestamp · útil para auditoría · cero contractual del flujo |

## Carpetas hermanas

- [`.husky/`](../../.husky/) — hooks de **Git** (corren en cada `commit` · `push` · etc del dev local). Canal distinto · `.husky/` opera en el repositorio · `.claude/hooks/` opera en eventos del agente Claude Code. Cero solapamiento.
- [`.claude/settings.json`](../) — config del harness donde se declara el wiring de los hooks de esta carpeta (al boot del pack este archivo puede no existir todavía · ver registro de baches del template).

## Cómo agregar un hook nuevo

1. Validar que el evento Claude Code corresponde (`PreToolUse` · `PostToolUse` · `Stop` · etc · consultar docs oficiales).
2. Crear archivo `<evento>-<acción>.sh` con shebang `#!/bin/bash` + `chmod +x`.
3. Output JSON a stdout · `{}` para no bloquear · `{"decision": "block", ...}` para bloquear.
4. Si el hook escribe outputs runtime · usar `.claude/logs/<archivo>.log` (gitignored · creado dinámicamente).
5. Wirear el hook en `.claude/settings.json` bajo la clave `hooks` (cuando el adopter tenga settings).
6. Sumar fila acá en § Archivos actuales con evento + rol 1-línea.

---

*Convención de README firmada 2026-05-24 (regla [`folder-creation-with-readme.md`](../rules/folder-creation-with-readme.md)).*
