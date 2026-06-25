# `.claude/logs/` · Logs operativos del agente

> **Qué es:** logs generados por hooks del agente Claude Code (`tool-usage.log` · etc). Outputs append-only para observabilidad del flujo del agente.
>
> **Por qué se creó:** persistir trazas operativas del agente en runtime · permitir auditoría retrospectiva (qué tools usó · cuándo · con qué parámetros).
>
> **Para qué sirve:** debugging de comportamiento del agente · análisis de patrones de uso · evidencia retrospectiva si surge alguna duda sobre qué hizo el agente en una sesión particular.

## Archivos actuales

| Archivo | Rol |
|---|---|
| `tool-usage.log` | Log append-only del hook `log-tool-usage.sh` · cada tool call queda registrado |

## Carpetas hermanas

- [`.claude/hooks/`](../hooks/) — hooks que generan estos logs.

---

*Convención de README firmada 2026-05-10 (regla [`folder-creation-with-readme.md`](../rules/folder-creation-with-readme.md)).*
