# `.claude/skills/planificar/agents/` · Sub-agentes pre-PRP del skill `/planificar`

> **Qué es:** carpeta de los 4 sub-agentes (personas) que el skill [`/planificar`](../SKILL.md) invoca durante la planificación de un PRP del producto · 3 paralelas pre-draft (`architect-planning` · `complexity` · `historical-precedent`) + 1 post-draft (`skeptic`). Cada archivo `.md` es un prompt/persona inyectado a `Task` con `subagent_type: "Explore"` · cero side effects · output structured leído directo por el agente principal de `/planificar` (sin consolidator · Bif 4 = B del PRP-NNN).
>
> **Por qué se creó:** materializar la mejora #1 del análisis 4 dimensiones del flujo (handoff histórico del proyecto upstream) · cierra el riesgo de "PRPs con asunciones invisibles" cuando las 6 preguntas PM hat se cierran solo con la investigación contextual del Paso 2 sin perspectivas paralelas previas. Codificada vía PRP-NNN (firma 🔵 user) · 4 bifurcaciones arquitectónicas firmadas + 7 SD-cos.
>
> **Para qué sirve:** las 3 personas pre-draft opinan sobre la feature pedida ANTES de que el agente principal cierre las 6 preguntas PM hat + bifurcaciones (Paso 2.5 del SKILL.md de `/planificar`) · la persona post-draft (`skeptic`) cuestiona el PRP generado en cohesión interna + missing pieces + asunciones sin firmar antes de presentarlo al user para aprobación final (Paso 7.5). Las 4 perspectivas se persisten en sección "Análisis pre-draft de las personas" dentro del PRP generado (versionado en git · cero log externo).

## Convención

- **Naming:** kebab-case en inglés · `<rol>.md` (ej: `architect-planning.md` · `historical-precedent.md` · `skeptic.md`). Paridad con [`/revisar/agents/`](../../revisar/agents/) y [`/revisar-main/agents/`](../../revisar-main/agents/) firmada Bif 1 = B del PRP-NNN (🔵 user *"paridad con revisar y revisar main"*).
- **Shape canónico** (SD-cos-N del PRP-NNN · paridad estructural con `/revisar/agents/architect.md`):
  - `## Role` — qué hace la persona · foco no-superpuesto con las demás · 4-8 líneas.
  - `## Input` — qué inyecta el agente principal al invocar (feature pedida · investigación contextual · path PRP · diff vs main · etc).
  - `## Read these references` — lectura obligatoria antes de generar output (PRPs históricos · reglas firmes · memoria persistente · etc).
  - `## Análisis a generar` — checklist de puntos que la persona evalúa (paralelo al "Verification checklist" de `/revisar/agents/architect.md` pero adaptado al dominio pre-PRP · cero findings code-line · cero severidad técnica).
  - `## Output format` — bloque markdown estructurado con campos propios por persona (Bif 5 = A del PRP-NNN · SD-cos-N).
- **Tools (SD-cos-N del PRP-NNN):** cada persona usa `Read` + `Bash` + `Grep` + `Glob` via `subagent_type: "Explore"` (read-only · cero `Write`/`Edit`). Modelo Opus heredado. Timeout 300s (más corto que `/revisar` 600s · personas pre-PRP son cualitativas y más rápidas).
- **Invocación (SD-cos-N del PRP-NNN):** las 4 personas se invocan SIEMPRE en cada corrida de `/planificar` (no opcional · cero flag `skip-personas`).
- **Resilience (SD-cos-N del PRP-NNN):** si una persona timeout/error, el agente principal registra en el PRP draft *"persona X no respondió · análisis incompleto"* y continúa con las restantes · cero ABORT del flujo (paridad `/revisar` Paso 3).

## Archivos actuales

| Archivo | Foco | Cuándo se invoca |
|---|---|---|
| [`architect-planning.md`](./architect-planning.md) | Shape arquitectónico propuesto · patrones a reusar · riesgos arquitectónicos · simetrías cross-módulo a considerar | Paso 2.5 de `/planificar/SKILL.md` (pre-draft · P10 fan-out · paralelo con `complexity` y `historical-precedent`) |
| [`complexity.md`](./complexity.md) | Estimación 🟢 BAJA / 🟡 MEDIA / 🔴 ALTA · fundamento · señales de inflación de scope · sub-descomposición sugerida si 🔴 | Paso 2.5 (pre-draft · paralelo) |
| [`historical-precedent.md`](./historical-precedent.md) | Precedentes relevantes en PRPs históricos · decisiones firmadas 🔵 que aplican por analogía · diferencias clave a contemplar | Paso 2.5 (pre-draft · paralelo) |
| [`skeptic.md`](./skeptic.md) | Issues detectados en el draft · missing pieces · asunciones sin firmar · contradicciones internas | Paso 7.5 de `/planificar/SKILL.md` (post-draft · 1 invocación con el draft completo como input) |

## Carpetas hermanas

- [`.claude/skills/revisar/agents/`](../../revisar/agents/) — 9 personas review post-código del paso 4 del flujo · invocadas por `/revisar` con P10 fan-out · output `### Finding N` con file:line + severity. Hermana funcional · misma estructura `agents/` (Bif 1 paridad ciega) · scope distinto (review post-código vs análisis pre-PRP).
- [`.claude/skills/revisar-main/agents/`](../../revisar-main/agents/) — 9 personas review holístico del estado completo de `main` · cadencia mensual · paridad arquitectónica con `/revisar` pero scope holístico (cero diff). Hermana funcional · misma estructura.

## Cómo agregar una persona nueva

1. **Validar duplicados:** ¿el foco que querés cubrir ya está cubierto por una de las 4 existentes (`architect-planning` · `complexity` · `historical-precedent` · `skeptic`)? Si SÍ, extender esa persona en lugar de crear nueva.
2. **Firma del user obligatoria:** sumar persona nueva es cambio arquitectónico (modifica el contrato de `/planificar`) · NO se hace silenciosamente · requiere PRP propio o decisión firmada 🔵 en el log.
3. **Shape canónico:** copiar shape de `architect-planning.md` (Role · Input · Read these references · Análisis a generar · Output format) · adaptar al foco específico de la persona nueva.
4. **Naming:** kebab-case en inglés · descriptivo · 1-3 palabras (`<rol>.md`).
5. **Integración en `/planificar/SKILL.md`:** actualizar Paso 2.5 o Paso 7.5 según corresponda (pre-draft o post-draft) · sumar `Task` call paralela o secuencial.
6. **Sumar fila a la tabla "Archivos actuales"** de este README.
7. **Actualizar el PRP-NNN § Aprendizajes / Self-Annealing** si el agregado revela patrón replicable o gotcha del flujo.

---

*Convención de README (regla [`folder-creation-with-readme.md`](../../../rules/folder-creation-with-readme.md) · subcarpeta nueva exige README en raíz con 3 secciones obligatorias + tabla de archivos + cross-refs a hermanas).*
