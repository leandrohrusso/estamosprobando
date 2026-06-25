---
name: <scope>-<contexto>-<YYYY-MM-DD>
description: <1 línea sobre qué estado captura · qué quedó cerrado · qué falta>
type: project
---

# <Título: scope · contexto · fecha>

> **Disparado por:** <razón del checkpoint · ej: cierre de fase 🔴 · handoff entre sesiones · pivote estratégico>.
> **Próxima acción concreta:** <1 frase con qué tiene que hacer la sesión nueva primero>.
> **Skill a invocar:** <skill exacto · ej: `/implementar PRP-NNN` · `/arrancar` si necesita boot completo>.

## Estado al cierre de esta sesión

- **Commits hechos:** `<SHA>` · `<SHA>` · ... con resumen 1-frase de cada uno.
- **Pasos / fases cerrados:** `[✓]` con marca + nota relevante.
- **Decisiones firmadas:** lista bullet con tag 🔵 cuando aplica.
- **Archivos clave tocados:** paths concretos.

## Qué falta hacer en la próxima sesión

1. **<Paso 1>:** <descripción concreta · paths exactos · DoD>.
2. **<Paso 2>:** <ídem>.
3. **<Paso 3>:** <ídem>.

## Gotchas detectados (única sección opcional)

<Aprendizajes técnicos descubiertos durante la sesión · candidatos a `feedback/<topic>.md` futuro · anti-patterns evitados>. Omitir si genuinamente no aplica.

## Re-onboarding en sesión nueva

1. **Cwd:** `<directorio>` (donde retoma la sesión).
2. **No invocar `/arrancar`** si este checkpoint cubre todo el contexto · leer directamente y arrancar la próxima acción.
3. **Status tracker recomendado al boot:**

   ```text
   Flujo PRP-NNN:
   [✓] <pasos cerrados>
   [~] <paso en curso>
   [ ] <pasos pendientes>
   ```

4. **Orden recomendado de continuación:** <1-2 frases con dependencias entre pasos pendientes>.

## Refs

- **PRP / scope:** [`<path al PRP o roadmap>`](../../PRPs/<archivo>.md).
- **DTs abiertas en esta sesión:** `DT-NNN` · `DT-NNN`.
- **Commits clave:** `<SHA>` · `<SHA>`.
- **Reglas firmes aplicadas:** [`<regla>`](../../rules/<regla>.md).

---

*Checkpoint / handoff creado <YYYY-MM-DD> · si es handoff entre sesiones, sigue shape canónico de regla [`session-handoff.md`](../../rules/session-handoff.md) (7 secciones).*
