---
name: Bitácora cronológica del proyecto
description: Chronology append-only de eventos significativos del proyecto · cierres de PRP · decisiones grandes · incidentes · linting de memoria · directional changes
type: log
---

# Bitácora cronológica · `log.md`

> **Append-only · cero modificación retroactiva.** Fuente canónica de la regla: satélite [`log-chronology-append-only.md`](../rules/log-chronology-append-only.md). Consulta cronológica: `grep "^## \[" .claude/memory/log.md | tail -N`.

## Cómo usar este archivo

**Quién agrega entradas:** el agente, al cierre de cada PRP del proyecto · al cerrar una decisión grande · al detectar un incidente · al ejecutar el lint de memoria periódico.

**Cuándo agrega entradas (triggers):**

- Al cerrar un PRP (cualquier modo C del producto · cualquier mini-PRP) → 1 entrada `prp-close`.
- Al firmar una decisión arquitectónica con tag 🔵 que afecta cómo trabaja el agente o la estructura del proyecto → 1 entrada `decision`.
- Al detectar un incidente en producción o durante validación → 1 entrada `incident`.
- Al ejecutar el lint de memoria periódico (regla [`lint-memory-periodic.md`](../rules/lint-memory-periodic.md)) → 1 entrada `lint`.
- Al cambiar de dirección estratégica del proyecto (rename de módulos · pivote de scope · rama nueva del flujo) → 1 entrada `directional`.
- Al alcanzar un hito mayor (PR mergeado · suite de tests verde por primera vez · onboarding de nuevo colaborador) → 1 entrada `milestone`.

**Formato canónico de cada entrada:** un h2 con prefijo de fecha entre corchetes + tipo de evento + título corto, seguido de líneas Resumen + Detalle (opcional) + Refs. Estructura literal (indent con 4 espacios para que la consulta `grep "^## \["` NO matchee este ejemplo):

    [encabezado h2 con la sintaxis exacta:] ## [YYYY-MM-DD] <op> | <título corto>

    **Resumen:** 1-2 frases describiendo qué pasó.
    **Detalle:** opcional · 2-5 líneas si el evento amerita.
    **Refs:** commit `<hash>` · PRP-NNN · memoria `<path>` · ticket `<id>` (al menos 1 ref operativa).

**Tipos `<op>` válidos:**

| `<op>` | Cuándo usarlo |
|---|---|
| `prp-close` | Cierre de un PRP (modo C del producto · mini-PRP) |
| `decision` | Decisión arquitectónica firmada con tag 🔵 + justificación 1-frase del user |
| `incident` | Bug en producción · regresión detectada en validación · CI roto · bloqueo de flujo |
| `directional` | Cambio de dirección del proyecto (pivote · rename de módulos · rama nueva del flujo) |
| `milestone` | Hito mayor (PR mergeado · primer release · onboarding) |
| `lint` | Ejecución del lint de memoria periódico |

**Reglas operativas firmes:**

- ✅ **Append-only** · cero modificación retroactiva · cero borrado de entradas pasadas.
- ✅ **Orden cronológico estricto** · entradas nuevas se agregan al final del archivo.
- ✅ **1 entrada por evento** · cada `prp-close` · `decision` · etc., genera 1 sola entrada · NO duplicar.
- ❌ **NO backfill** · el pasado pre-adopción de este archivo NO se reconstruye acá · queda en git log + memorias project/.
- ❌ **NO modificar** entradas pasadas (excepto fix de typo en el commit que las creó · NO post-hoc).

---

<!-- Las entradas reales empiezan acá. Ejemplo de la primera entrada cuando arranca el proyecto (indent con 4 espacios para que `grep "^## \[" log.md` NO matchee este ejemplo · paridad con el ejemplo del § "Cómo usar este archivo" arriba):

    ## [YYYY-MM-DD] milestone | Boot del proyecto · pack workflow-base adoptado

    **Resumen:** Repo inicial creado con el pack universal workflow-base (rules + skills + memoria + infra + gobernanza). Adaptación al stack del proyecto pendiente.

    **Refs:** commit inicial · pack [`github.com/leandrohrusso/workflow-base`](https://github.com/leandrohrusso/workflow-base).

-->
