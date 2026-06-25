---
name: planificar
type: skill
description: "Planificar una feature compleja antes de implementarla. Genera un PRP (Product Requirements Proposal) con objetivo, comportamiento, modelo de datos, y fases. Cierra bifurcaciones arquitectonicas con el user via patron de validacion activa (investigar, validar lo conocido, recomendar lo desconocido, user decide). Consulta la matriz Claude Design siempre que el PRP toque UI. Activar cuando el usuario dice: planificar, planea esto, planeá esto, planeemos, planear esto, arma un PRP, armá un PRP, necesito un sistema de X, disena una feature, diseñá una feature, quiero agregar algo grande, antes de implementar, diseño UI, diseño de UI, diseñá UI, disena UI, diseñar UI, disenar UI, consultar matriz, consultá matriz, consulta matriz, matriz claude design, matriz Claude Design, diseño nuevo, diseño de pantalla, pantalla nueva."
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task
---

> **⚙️ Stack adaptation banner.** Este SKILL es **template universal**. Los ejemplos concretos en el cuerpo asumen un stack típico (Next.js · Supabase · Playwright · GitHub Actions · Husky). Si tu proyecto usa otro stack, adaptá:
>
> - **MCP names** del frontmatter `allowed-tools` (`mcp__claude_ai_Supabase__*` · `mcp__playwright__*` · `mcp__next-devtools__*`) a los MCPs disponibles en tu proyecto.
> - **Patrones de código** mencionados en `## Process` (Server Actions · RLS policies · RPCs · revalidatePath · etc) al equivalente de tu framework.
> - **Tooling externo** (`npm run ci:local` · `bash scripts/local-ci.sh` · `gh pr merge`) a los comandos reales de tu proyecto.
>
> El **shape canónico P8** (Overview · When · Process · Anti-rationalization · Red flags · Verification) NO se altera · solo las referencias concretas a stack.

# Skill: `/planificar` — paso 2 · Planificación del flujo de 6 pasos

> **Skill custom autocontenido** (Bif 1 = C · 🔵 user). Skill del paso 2 del flujo de 6 pasos · paridad estructural con `/arrancar`.
>
> **Inspiración estructural:** [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills) · ver [doctrina estructural compartida](../README.md#doctrina-estructural-compartida) en `skills/README.md` para convención de adaptación.

## Overview

> **Propósito:** generar un PRP (Product Requirements Proposal) para una feature compleja del producto · cerrando bifurcaciones arquitectónicas con el user vía patrón de validación activa antes de pasar a implementación.

> **Sub-agentes pre-PRP (PRP-NNN · 🔵 user):** el skill invoca 4 personas vía `Task` con `subagent_type: "Explore"` (paridad estructural con `/revisar`): 3 paralelas pre-draft (`architect-planning` · `complexity` · `historical-precedent`) en el **Paso 2.5** + 1 post-draft (`skeptic`) en el **Paso 7.5**. Los 4 outputs se persisten en la sección "Análisis pre-draft de las personas" del PRP generado (cero log externo · trazabilidad versionada en git). Prompts MD canónicos en [`.claude/skills/planificar/agents/`](agents/).

**Cuándo invocar:**

- **Antes de `/implementar`** — toda feature de Modo C ([`WORKFLOW.md § 5`](../../../WORKFLOW.md)) requiere PRP firmado.
- **Feature compleja** — múltiples archivos · BD + código + UI coordinados · fases que dependen entre sí · decisiones arquitectónicas abiertas.
- **Triggers explícitos del user** — *"planificar"* · *"planeá esto"* · *"planeemos"* · *"armá un PRP"* · *"necesito un sistema de X"* · *"diseñá una feature"* · *"quiero agregar algo grande"* · *"antes de implementar"*.

**Qué NO hace:**

- ❌ NO implementa código (eso es paso 3 · skill `/implementar`).
- ❌ NO ejecuta migraciones ni tests reales (solo investiga schema vigente para informar el PRP).
- ❌ NO mergea ni pushea (eso es paso 6 · skill `/entregar`).
- ❌ NO decide bifurcaciones arquitectónicas solo · siempre con firma 🔵 del user (Bif 4 PRP-NNN · 🔵 user).

## When

| Caso | Aplica `/planificar` |
|---|---|
| El user dice *"planificar"* · *"planeá esto"* · *"planeemos"* · *"planear esto"* · *"armá un PRP"* · *"necesito un sistema de X"* · *"diseñá una feature"* · *"quiero agregar algo grande"* · *"antes de implementar"* | ✅ SÍ |
| Feature de **Modo C** del flujo ([`WORKFLOW.md § 5`](../../../WORKFLOW.md)) — múltiples archivos · multi-capa · decisiones arquitectónicas abiertas | ✅ SÍ |
| Refactor del **código de producto** con bifurcaciones reales (ej: extracción de helper compartido · cambio de patrón a través de N callers) | ✅ SÍ |
| Task de **Modo A** del flujo — task trivial · bien especificada en el roadmap (con files + notes) · sin decisiones de arquitectura | ❌ NO (ejecutar directo · marcar `[ ]` → `[x]` en el roadmap) |
| Task de **Modo B** del flujo — encaja en un skill ya existente con flujo cerrado (ej: `/validar`, `/security-review`) | ❌ NO (invocar el skill correspondiente) |
| Bug fix puntual con root cause claro y scope acotado a 1-2 archivos | ❌ NO (fix directo · regression-first FIRME [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md)) |
| PRP ya `APROBADO` en `.claude/PRPs/` · el user pide arrancar implementación | ❌ NO (invocar `/implementar` · `/planificar` ya cumplió su rol) |

## Process

> **Skill autocontenido.** El § Process embebe los 8 pasos canónicos del flujo de planificación · las 6 preguntas PM hat de Vibe Coding · el patrón de validación activa · y la consulta a `claude-design-matrix` sin requerir abrir WORKFLOW.md.
> **Cita inline de doctrina:** la sub-checklist canónica de las 6 preguntas PM hat vive en [`WORKFLOW.md § 3 Paso 2`](../../../WORKFLOW.md) (escrita por PRP-NNN · SoT). Este skill **referencia** esa doctrina y la **complementa** con el protocolo operativo de validación activa.
> **Reglas firmes que enmarcan el flujo** (leyenda+link · NO embebidas · doctrina vive en los satélites · refinamiento iterativo upstream):
>
> - [`think-before-coding.md`](../../rules/think-before-coding.md) — listar asunciones · presentar interpretaciones múltiples · push back con approach más simple antes de codear.
> - [`simplicity-first.md`](../../rules/simplicity-first.md) — mínimo código que resuelve el problema · cero abstracciones especulativas sin caller real.
> - [`goal-driven-execution.md`](../../rules/goal-driven-execution.md) — criterios de éxito binarios · loop hasta verificarlos · check binario por step.
> - [`surgical-changes.md`](../../rules/surgical-changes.md) — todo diff trazable al request · cero drive-by · matchear estilo del archivo destino.
> - [`decisiones-features.md`](../../rules/decisiones-features.md) — features de PRD/roadmap se deciden UNA POR UNA con el user · cero set cerrado masivo · aplica al scope del PRP cuando aparecen N features potenciales.
> - [`no-suponer-fuente-de-verdad.md`](../../rules/no-suponer-fuente-de-verdad.md) — cero suposición · al investigar contexto en Paso 2 ir a fuente correcta · NUNCA memoria del LLM como fuente única · auto-pregunta firme *"¿sé esto o lo supongo?"* antes de generar PRP draft.
> - [`respect-existing-folder-structure.md`](../../rules/respect-existing-folder-structure.md) — estructura actual = baseline · cuando el inventario de archivos afectados del PRP (Paso 7) propone paths con carpetas nuevas, marcar explícito en el draft + presentar al user para firma 🔵 ANTES de aprobar PRP · cero creación silenciosa durante la fase de implementación.
> - [`documentos-definitivos.md`](../../rules/documentos-definitivos.md) — los PRPs individuales son excepción explícita de la regla (siguen el flujo /planificar) · PERO si el scope del PRP **propone generar** un documento definitivo del producto (PRD final · roadmap consolidado · plan 90 días / 6 meses · resumen ejecutivo), avisar al user en Paso 3 (validación activa de las 6 preguntas) y esperar OK explícito ANTES de incluir esa generación en el draft · cero documentos definitivos auto-incluidos en el scope sin firma.
> - [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) — el PRP draft generado en Paso 7 debe llegar con todas las secciones canónicas (Objetivo · Por Qué · Qué + Criterios de Éxito · Contexto · Blueprint · Aprendizajes / Self-Annealing) para que el cierre del paso 2 del flujo de 6 pasos (PRP APROBADO) aplique el checklist GR sin gaps · bifurcaciones cerradas en Paso 6 quedan documentadas con firma 🔵 user inline en el PRP (pre-condición para ítem 2 del checklist · "criterios marcados + Aprendizajes con gotchas").

### Paso 1 · Lectura del template

Leer `.claude/PRPs/prp-base.md` (template del PRP de producto · si tu proyecto aún no lo creó, ver [`.claude/PRPs/README.md`](../../PRPs/README.md) para la convención del pack). Estructura canónica esperada: **Objetivo · Por Qué · Qué + Criterios de Éxito · Contexto · Blueprint · Aprendizajes / Self-Annealing**. El skill `/planificar` **genera** un archivo nuevo `.claude/PRPs/PRP-NNN-<descripcion-kebab>.md` rellenando este template.

### Paso 2 · Investigación contextual (read-only · ~5-15 min)

Antes de presentar nada al user, mapear silenciosamente:

- **Codebase:** estructura `src/app/` · features en `src/components/` · helpers en `src/lib/` · servicios relevantes a la feature pedida.
- **BD:** tablas relevantes vía Supabase MCP · schema vigente · RLS policies · RPCs activas (ej: Supabase MCP en stack típico del pack · adaptá al MCP / cliente / herramienta de inspección de schema de tu BD si el stack difiere).
- **Roadmap del producto:** [`docs/product/product-roadmap.md`](../../../docs/product/product-roadmap.md) — task del roadmap a la que el PRP responde · fase del roadmap · dependencias declaradas.
- **Memoria persistente:** [`.claude/memory/MEMORY.md`](../../memory/MEMORY.md) — feedback / reference / project con patrones aplicables al área tocada.
- **Reglas firmes aplicables:** [`.claude/rules/`](../../rules/) — satélites con shape P8 que enmarcan el área (ej: reglas específicas del stack del proyecto).
- **Deuda técnica:** [`docs/logs/technical-debt.md`](../../../docs/logs/technical-debt.md) — DT que el PRP destino podría cerrar (oportunidad de scope explícito ofrecida al user).
- **PRPs históricos:** glob `.claude/PRPs/*.md` para encontrar precedentes con shape similar (decisiones ya firmadas que aplican por analogía).
- **Cero suposición · ir a fuente correcta (regla [`no-suponer-fuente-de-verdad.md`](../../rules/no-suponer-fuente-de-verdad.md)):** durante la investigación del Paso 2, auto-pregunta firme por cada afirmación que el PRP va a incluir: *"¿sé esto efectivamente o lo estoy suponiendo?"*. Si "lo supongo" → ir a fuente correcta según orden: **(A) cosas del proyecto:** archivos del repo (`Read` directo · `grep`/`glob` cuando path desconocido) → memoria persistente (`feedback/` · `reference/` · `project/` + MEMORY.md índice) → MCPs (Supabase MCP para BD · Playwright MCP para state runtime). **(B) cosas externas (framework · API · servicio · convención):** docs oficiales (WebFetch URL canónica · MCPs `nextjs_docs` · `supabase search_docs` cuando existen) → memoria del proyecto como referencia (NO autoridad · criterioso si la memoria es >1 mes y el tema cambia frecuente). **NUNCA memoria del LLM como fuente única** · cualquier afirmación del PRP basada solo en eso es decisión arquitectónica con bug latente.
- **Numeración secuencial del PRP destino:** verificar próxima numeración disponible con `ls .claude/PRPs/PRP-*.md | sort | tail -3` antes de avanzar al Paso 2.5. Si el path placeholder del input del user (handoff · referencia previa · roadmap · mensaje del user) discrepa con la numeración real disponible, flag al user explícito con la corrección antes de spawn personas pre-draft.

### Paso 2.5 · Spawn de 3 personas pre-draft en paralelo (P10 fan-out)

> **Atribución:** patrón P10 fan-out derivado de [addyosmani/agent-skills](../../references/external-doctrine/addyosmani-readme.md) (orchestration paralela · 3 personas concurrentes · output estructurado).

> **PRP-NNN · 🔵 user:** materializa Bif 2 = A (4 personas: 3 paralelas pre-draft + 1 skeptic post-draft) · Bif 4 = B (sin consolidator · persistencia dentro del PRP) · Bif 5 = A (output estructurado por persona · campos SD-cos-N). Prompts MD canónicos en [`.claude/skills/planificar/agents/`](agents/).

**1 solo turno con 3 `Task` calls paralelas.** El runtime los ejecuta concurrentemente · ahorro ~3× sobre secuencial. Cada `Task` call:

- **`subagent_type: "Explore"`** (paridad `/revisar` Paso 2 · NO re-debatible).
- **Modelo:** Opus (heredado de la sesión · sin override).
- **`description` (3-5 palabras):** ej. *"Architect planning pre-PRP"* · *"Complexity estimate pre-PRP"* · *"Historical precedent pre-PRP"*.
- **`prompt`:** lee el archivo de la persona correspondiente (`.claude/skills/planificar/agents/<name>.md`) y le inyecta como contexto:
  - **Feature pedida** (literal del request del user).
  - **Investigación del Paso 2** (codebase · BD · roadmap · memoria · reglas firmes aplicables · DT relevantes · PRPs históricos identificados).
  - **Path del PRP** (`null` · todavía NO existe · será generado en Paso 7).
  - **Diff vs main** (`null` · pre-PRP · sin código todavía).
- **Timeout por persona:** 300s (5 min · personas pre-PRP son cualitativas y más rápidas que code review · SD-cos-N).

Lista canónica de las 3 personas pre-draft (orden libre · paralelas):

| # | Persona | Path | Foco |
|---|---|---|---|
| 1 | architect-planning | `agents/architect-planning.md` | Shape arquitectónico propuesto · patrones a reusar · riesgos · simetrías cross-módulo |
| 2 | complexity | `agents/complexity.md` | Estimación 🟢 BAJA / 🟡 MEDIA / 🔴 ALTA · fundamento · señales de inflación · sub-descomposición si 🔴 |
| 3 | historical-precedent | `agents/historical-precedent.md` | Precedentes en PRPs históricos · decisiones 🔵 firmadas que aplican por analogía · diferencias clave |

**Anti-pattern:** spawnear las 3 en turnos separados (1 turno por persona). Eso pierde el speedup paralelo y factura tokens redundantes en context refresh.

**Recolección de outputs (paridad `/revisar` Paso 3 + SD-cos-N resilience):**

Cada persona devuelve bloque markdown estructurado con los campos SD-cos-N propios de su rol (NO `### Finding N` con file:line · sino análisis cualitativo pre-PRP). El runtime emite notificación automática al completarse cada persona (cero polling activo).

- Si una persona termina con su output estructurado → registrar literal para integrar en sección "Análisis pre-draft" del Paso 7.
- Si una persona devuelve **timeout o error** → registrar literal `persona X no respondió · análisis incompleto · continuar con las restantes` en la sección "Análisis pre-draft" · **cero ABORT del flujo** · agente principal continúa Pasos 3-6 con las restantes (SD-cos-N · paridad `/revisar` Paso 3 resilience).

El agente principal **lee los 3 outputs** antes de avanzar al Paso 3 · informa las 6 preguntas PM hat + identificación de bifurcaciones con las 3 perspectivas paralelas previas (NO sustituyen al user · enriquecen el análisis del agente principal).

### Paso 3 · Las 6 preguntas PM hat · patrón "validación activa"

> **Doctrina canónica:** [`WORKFLOW.md § 3 Paso 2`](../../../WORKFLOW.md) — sub-checklist contractual · ninguna se omite.
> **Modo de aplicación · Bif 3 = C híbrido + matiz validación activa · 🔵 user:** cita literal del user *"las respuestas que ya tiene pueden ser con validación, es decir, lo responde con lo que ya está pero lo valida conmigo"*.

Por cada pregunta:

- **Si la investigación del Paso 2 ya respondió** → presentar al user lo encontrado + solicitar confirmación explícita: *"encontré X · ¿confirmás?"*. Cero asunción invisible.
- **Si la investigación NO respondió** → preguntar al user con recomendación early ([`conversation-style.md`](../../rules/conversation-style.md)): *"necesito decisión: A o B · recomendación A porque [razón 1-frase]"*. Cero round-trip vacío.

Las 6 preguntas:

1. **¿Qué construir, exactamente?** Estado final deseado · 1-2 oraciones.
2. **¿Cuál es el criterio de éxito?** Binario · verificable mecánicamente · alineado con [`goal-driven-execution.md`](../../rules/goal-driven-execution.md).
3. **¿Qué restricciones hay?** Performance · estilo · compatibilidad · seguridad · privacidad (PII) · multi-tenancy (RLS) · principios del producto (si tu proyecto codificó reglas de producto en [`docs/product/references/rules/`](../../../docs/product/references/rules/) · ej: stock fundamental en un dominio ticketing · stub vacío al boot del pack · el adopter las codifica cuando aplique).
4. **¿Qué patrones ya usa este codebase y hay que respetar?** Identificar reusables (componentes producción de `src/components/` · helpers de `src/lib/` · stores · RPCs canónicos). Alineado con [`simplicity-first.md`](../../rules/simplicity-first.md) (reusar > recrear).
5. **¿Qué archivos son relevantes? ¿Cuáles tocar y cuáles no?** Inventario explícito · alineado con [`surgical-changes.md`](../../rules/surgical-changes.md) (cero drive-by).
6. **¿Cómo voy a verificar que funciona sin leer toda la implementación?** Tests del DoD por fase ([`tests-as-dod-per-phase.md`](../../rules/tests-as-dod-per-phase.md)) + suite acumulativo + CSV manual del paso 5 / `/validar`.

> Si alguna pregunta queda sin respuesta confirmada por el user, el PRP NO avanza a APROBADO.

### Paso 4 · Consulta a `claude-design-matrix` (siempre · validación con user)

> **Bif 5 = A + matiz "siempre validar" · 🔵 user:** cita literal del user *"se tiene que acordar SIEMPRE y validar conmigo si pasamos por claude design, o no"*.

- **Si el PRP toca UI nueva** → leer [`claude-design-matrix.md`](../../rules/claude-design-matrix.md) · identificar disparadores aplicables (decisión estructural / nueva experiencia · primera impresión cliente final · UX especializada · microinteracción · form simple · variante · cambio menor) · presentar al user los disparadores + recomendación early (*"matriz dispara SÍ porque [razón] · recomiendo abrir sesión Claude Design"* o *"matriz dispara NO porque [razón] · recomiendo primitivos directo del DS"*) + solicitar decisión explícita.
- **Si el PRP NO toca UI nueva** → declarar 1-frase (*"PRP sin UI nueva · matriz no aplica · skip Claude Design"*) y avanzar al Paso 5.

Cero decisión silenciosa. El user firma SIEMPRE el camino (con Claude Design o sin).

### Paso 4.5 · Gate complejidad ALTA · OBLIGATORIO (regla #13 complejidad.md)

> **Refinamiento iterativo upstream · materializa regla [`complejidad.md`](../../rules/complejidad.md) como gate operativo del skill.** La persona `complexity` del Paso 2.5 ya emitió estimación 🟢 BAJA / 🟡 MEDIA / 🔴 ALTA · este paso lee esa estimación, la reconcilia con la investigación, y aplica el gate firme antes de avanzar a la identificación de bifurcaciones del Paso 5.

**Tabla de criterios (embebida de regla #13 § Process · NO re-derivar):**

| Nivel | Modelo de datos | UI | Lógica | Tiempo estimado | Casos de borde |
|---|---|---|---|---|---|
| **🟢 BAJA** | 1-2 tablas / campos nuevos | 1 pantalla simple · form plano | CRUD básico · sin reglas compuestas | < 1 día con Claude Code | Pocos · obvios |
| **🟡 MEDIA** | 3-5 tablas con relaciones simples | 1-3 pantallas · components reusables | Reglas con override · cálculos derivados · jerarquía de datos | 1-3 días | Mapeables · manejables |
| **🔴 ALTA** (PROHIBIDA por default) | 6+ tablas · relaciones polimórficas · herencias | Múltiples pantallas con interacciones complejas · estados anidados | Reglas multi-nivel · sincronizaciones · integraciones complejas | > 3 días | Muchos · no obvios |

**Protocolo del gate (binario · cero ambigüedad):**

1. **Leer estimación de la persona `complexity`** (Paso 2.5 output literal · sub-sección `### complexity` del análisis pre-draft).
2. **Reconciliar con investigación del Paso 2** · si el agente principal observa señales que contradicen la estimación de la persona (ej: persona dijo 🟡 MEDIA · pero el inventario sugiere 6+ tablas + 4 pantallas + RPC con sincronización = 🔴 ALTA real), el agente principal **corrige la estimación hacia arriba** (asimetría firme · NO se corrige hacia abajo · cero "lo bajo a MEDIA porque me parece").
3. **Si estimación final 🟢 BAJA o 🟡 MEDIA** → continuar al Paso 5 (identificación de bifurcaciones) · documentar la estimación en 1 línea dentro de la sub-sección `### complexity` con prefijo *"Estimación reconciliada por agente principal: 🟢/🟡 · razón"*.
4. **Si estimación final 🔴 ALTA** → **BLOQUEAR avance al Paso 5** · ejecutar las 4 preguntas obligatorias de regla #13 § Process:

   - **¿Se puede simplificar a 🟡 MEDIA?** Buscar versión reducida (ej: en vez de "drag-and-drop builder", usar "templates pre-armados").
   - **¿Es realmente esencial para el MVP?** Casi siempre la respuesta es NO.
   - **¿Se puede dividir en sub-features de complejidad 🟢 BAJA o 🟡 MEDIA?** Proponer split explícito en N PRPs secuenciales.
   - **¿Hay forma de hacerlo manualmente al inicio?** Operación manual con escalada futura a sistema completo.

5. **Presentar al user con formato canónico** (regla [`metodologia-iteracion.md`](../../rules/metodologia-iteracion.md)): estimación 🔴 ALTA + las 4 respuestas + recomendación early (default = simplificar a 🟡 MEDIA · postergar a V1.5+ · o split en N sub-features).
6. **Solicitar firma 🔵 user OBLIGATORIA** con tag `🔵 user · YYYY-MM-DD · "<justificación 1-frase>"` que firme **UNA** de las 3 salidas:
   - **A · Simplificación a 🟡 MEDIA** aplicada (con descripción de qué se recortó).
   - **B · Split en N PRPs** (con lista de los N PRPs sucesores · cada uno 🟢 BAJA o 🟡 MEDIA).
   - **C · Postergación a V1.5+** (PRP no avanza · roadmap actualizado con la decisión).
   - **D · Mantener 🔴 ALTA tal cual** (excepcional · requiere justificación FUERTE del user que sobreescribe el default PROHIBIDO de regla #13).

7. **Documentar las 4 respuestas + firma user en el PRP draft** en sub-sección nueva `### complexity-gate-alta` dentro de "Análisis pre-draft de las personas" (post-`### complexity` · pre-`### historical-precedent`).
8. **Cero avance silencioso** si la estimación final es 🔴 ALTA · cero firma implícita por silencio del user · cero "lo dejo 🔴 ALTA pero el user ya sabe".

**Por qué gate obligatorio (NO recomendación opcional · refinamiento iterativo upstream):** la regla #13 § Overview es FIRME (*"solo se admiten features de complejidad BAJA o MEDIA · ALTA PROHIBIDA por default"*). Sin gate operativo en el skill, la regla queda declarativa · la persona `complexity` del Paso 2.5 puede emitir 🔴 ALTA y el skill avanzar a Paso 5 silenciosamente · el PRP termina APROBADO con scope que va a inflar en el bucle agéntico y comprometer calidad (regla #13 § Anti-rationalization #2 *"Estimé MEDIA pero en el bucle se infló a ALTA · sigo igual"* es exactamente lo que este gate previene de raíz).

### Paso 5 · Identificación de bifurcaciones arquitectónicas

Identificar TODAS las decisiones del PRP con ≥2 opciones razonables y tradeoffs reales que afecten:

- Modelo de datos (qué tabla · qué columnas · qué relaciones · qué índices · qué RLS).
- Capa de servicios (Server Actions vs Route Handlers · RPCs vs queries directas · paginación · caché).
- UI (modal vs subform · multi-step vs lista plana · server-rendered vs client-rendered).
- Permisos / roles (qué role puede qué · gates de seguridad · audit log namespaces).
- Tests (qué cubrir en E2E `tests/e2e/regression/` · qué en SQL `tests/sql/` · qué en CSV manual).

Las decisiones **cosméticas** (naming menor · convención de formato · cardinalidad sin tradeoff real) NO son bifurcaciones arquitectónicas — el agente las cierra con recomendación early; el user puede objetar pero NO firma cada una.

#### Sub-paso 5.b · Features potenciales del scope se deciden UNA POR UNA (regla `decisiones-features`)

> **Refinamiento iterativo upstream · materializa regla [`decisiones-features.md`](../../rules/decisiones-features.md) como gate operativo del skill.** Distinto de bifurcaciones arquitectónicas (Paso 5/6 patrón "decide-quien-decide"). Acá: cuando aparecen **N features potenciales** durante la planificación del scope del PRP (ej: módulo grande tipo "membresías" o "marketplace" con sub-features evidentes), cada feature se presenta y firma **una por una** · cero set cerrado masivo · cero *"¿qué hacemos con las 5?"*.

**Patrón canónico de presentación de cada feature** (embebido de regla #5 § Process):

> **Feature X — [descripción 1-línea]**
>
> **Qué resuelve:** [problema · 1 frase]
> **Cómo la hace el referente del rubro** (o referencia): [resumen · 1-2 frases · o "no documentado públicamente"]
> **Trade-off:** [costo vs beneficio · 1 frase]
>
> **Mi recomendación: [SÍ a MVP / NO / V1.5+].** [Razón · 1 frase]
>
> ¿Qué te parece?

**Reglas operativas (4 puntos · cero excepciones):**

1. **Una feature por turno** · presentar · esperar firma user · pasar a la siguiente. NO agrupar 3+ features en una pregunta final tipo *"¿qué hacemos con cada una?"*.
2. **Módulos grandes** (membresías · marketplace · sistema X) → descomponer en sub-features y revisar cada una individualmente · NO mergear "X = SÍ/NO" en 1 sola decisión.
3. **Recomendación opinada early** está OK · pero la decisión final es del user.
4. **Excepción:** si el user da OK conjunto explícito (*"esas 3 las dejamos para V2"*), confirmarlo una sola vez en el resumen y avanzar · NO insistir con la regla cuando él dijo lo contrario.

**Cuándo aplica este sub-paso:** cuando el Paso 3 (6 preguntas PM hat) o el Paso 5 inventario reveló ≥2 features candidatas que NO son sub-tareas mecánicas de un único feature firmado, sino features discretas con decisión propia (entran al MVP · van a V1.5+ · se descartan).

**Cuándo NO aplica:** PRPs con scope monolítico ya firmado por el user al arrancar (1 feature core con sus dependencias técnicas) · acá el Paso 5 solo identifica bifurcaciones arquitectónicas del único feature.

### Paso 6 · Cierre de bifurcaciones · patrón "decide-quien-decide"

> **Bif 4 · 🔵 user:** cita literal del user *"firmar por pura burocracia me parece una estupidez, el punto es que cuando hay que decidir, no es mal plan que yo decida — con recomendación de la IA (si no hay decisión) o valide si es correcta cuando la hay"*.

Por cada bifurcación arquitectónica del Paso 5, aplicar el patrón **investigar → validar lo conocido → recomendar lo desconocido → user decide**:

- **Si la investigación del Paso 2 ya tiene respuesta clara** (precedente firmado en otro PRP · convención del codebase · patrón canónico de los satélites) → presentar al user lo encontrado + solicitar validación explícita (*"encontré X en PRP-NNN · aplica acá · ¿confirmás?"*). El user valida o pivotea.
- **Si NO hay respuesta clara** (decisión real con tradeoff abierto) → presentar opciones A/B/C con tradeoff 1-frase por opción + recomendación early con justificación 1-frase ([`metodologia-iteracion.md`](../../rules/metodologia-iteracion.md) formato canónico) + solicitar firma del user con tag `🔵 user · YYYY-MM-DD · "<justificación 1-frase>"`.
- **Si NO hay decisión real** (ejecución mecánica · 1 sola opción razonable) → el agente avanza solo · documenta la decisión como SD cosmética en el PRP (con razón 1-frase).

Cero burocracia con cardinalidad fija. Cero asunciones invisibles. Cero round-trips vacíos. El user decide cuando hay decisión real; el agente recomienda y valida en el resto.

### Paso 7 · Generación del PRP draft

Rellenar el template `.claude/PRPs/prp-base.md` (convención del pack documentada en [`.claude/PRPs/README.md`](../../PRPs/README.md)) con las respuestas firmadas/confirmadas de los Pasos 3-6:

- **Header:** estado `PENDIENTE` · fecha · capítulo del roadmap · task T-XX que cubre · sesiones estimadas · riesgo (🟢/🟡/🔴).
- **Objetivo:** 1-2 oraciones del Paso 3.1.
- **Por Qué:** problema/solución del Paso 3.2 (tabla del template).
- **Qué + Criterios de Éxito:** binarios verificables del Paso 3.2.
- **Contexto:** referencias canónicas del Paso 2 (codebase · BD · roadmap · memoria · reglas firmes aplicables) + decisiones firmadas del Paso 6 con tag `🔵 user · YYYY-MM-DD · "<justificación>"`.
- **Blueprint:** fases ([`tests-as-dod-per-phase.md`](../../rules/tests-as-dod-per-phase.md) · cada fase con tests del DoD · typecheck + build verdes al cierre · commit local).
- **Inventario de archivos afectados:** tabla con acción 🟢🟡🟠🆕 + justificación 1-frase + restricciones de scope. **Crítico anti-regresión:** si listás `tests/manual/PRP-NNN_*.csv` en el inventario, marcalo con emoji 🟣 (NO 🆕) + nota explícita *"NO se crea en `/implementar` paso 3 · ownership exclusivo del SKILL `/validar` paso 5"*. El emoji 🟣 distingue artefactos cuyo ownership pertenece a otro skill del flujo (NO a este PRP/skill que los lista). Cuando tu proyecto pesque este anti-pattern, codificarlo como memoria persistente `feedback/csv-is-validar-not-implementar.md`.
- **Cero creación silenciosa de carpetas en el inventario (regla [`respect-existing-folder-structure.md`](../../rules/respect-existing-folder-structure.md) · refinamiento iterativo upstream):** si el inventario incluye paths con **carpeta nueva** (path donde la carpeta padre directa NO existe en el repo actual), aplicar el protocolo de la regla #23 ANTES de aprobar el PRP. Procedimiento al armar el inventario: (1) por cada path nuevo, `test -d <carpeta-padre>` mecánico para detectar carpetas nuevas implícitas. (2) por cada carpeta nueva detectada, inventario de candidatas existentes que cubran el rol semánticamente (leer READMEs cuando aplica). (3) si ninguna existente cubre · sesgo FUERTE anti-raíz → buscar carpeta padre razonable para subcarpeta. (4) marcar las carpetas nuevas explícito en el inventario del PRP (sub-tabla "carpetas nuevas propuestas") con razón 1-frase + alternativas evaluadas y descartadas. (5) presentar al user para firma 🔵 explícita por cada carpeta nueva ANTES de avanzar al Paso 8. Cero asunción silenciosa · cero "mkdir cuando llegue el momento". La firma queda como referencia para `/implementar` Paso 3 (skill #regla #23 aplica también ahí · paridad).

  **Tabla "tipo de carpeta nueva → preguntas canónicas a hacer al user" (refinamiento iterativo upstream · materializa el sub-paso (5) del protocolo arriba como gate operativo del Paso 7):**

  Cuando el sub-paso (5) del protocolo dispara firma del user, las preguntas dependen del **tipo de carpeta nueva** detectada · usar esta tabla como guía operativa para NO improvisar preguntas y NO omitir verificaciones críticas:

  | Tipo de carpeta nueva | Preguntas canónicas al user (firma 🔵) | Default conservador |
  |---|---|---|
  | **Subcarpeta dentro de carpeta existente bien establecida** (ej: `src/components/<feature>/<sub>/` · `tests/e2e/regression/<scope>/`) | ¿Es sub-dominio nuevo del módulo padre · O agrupación organizativa de archivos hermanos que ya viven en el padre? · ¿`README.md` raíz aplicando regla #22 al crearla en `/implementar` Paso 3? | Confirmar sub-dominio + README · si solo es agrupación organizativa, evaluar si los archivos pueden vivir en el padre directo sin nueva subcarpeta |
  | **Carpeta nueva top-level (raíz)** (ej: `analytics/` · `integrations/` · directorio en `src/` o repo root sin padre obvio) | ¿Genuinamente nuevo dominio funcional que NO encaja en carpetas existentes? · ¿Contiene N archivos relacionados o singleton (1 archivo solo)? · ¿`README.md` esperado? · ¿Alternativa en carpeta padre razonable que descarte el sesgo anti-raíz? | Sesgo FUERTE anti-raíz · default = buscar subcarpeta dentro de padre razonable · top-level solo si user firma explícitamente que es dominio funcional nuevo |
  | **Carpeta de tests con scope no cubierto** (ej: `tests/integration/` · `tests/smoke/` cuando no existen) | ¿La regla del proyecto define tipos de tests con shape canónico (`tests/sql/` · `tests/e2e/regression/`)? · ¿Por qué los tests propuestos no caben en los tipos existentes? · ¿Convenciones de naming firmadas? | Confirmar que el tipo de test NO encaja en categorías existentes · sino reusar carpeta de tests preexistente con sub-paths internos |
  | **Carpeta de assets / docs / generated** (ej: `docs/<scope>/` · `assets/<scope>/` · paths generados por scripts) | ¿`docs/` ya tiene sub-bloques canónicos que cubren el scope? · ¿Es generación automática (NO es decisión humana · documentar en script generador)? · ¿README explica el ciclo de vida del contenido? | Reusar sub-bloque docs/ existente si encaja · si es generación automática, NO requiere firma del user pero SÍ documentación en script generador |

  **Por qué esta tabla NO sustituye el protocolo 5-step:** la regla #23 codifica el protocolo · esta tabla materializa el sub-paso (5) con preguntas específicas según tipo. Sin la tabla, el agente improvisa preguntas y arriesga (a) omitir preguntas críticas (README esperado · sesgo anti-raíz · alternativas evaluadas) · (b) firmar el user sin contexto suficiente. La tabla es el *"qué preguntar exactamente"* del sub-paso (5).

- **Validación final:** mecánica + Playwright/CSV cuando aplica · referenciada al paso 5 (`/validar`). **NO usar redacciones tipo "Fase N + CSV"** en el Blueprint del paso 3 (ambigüedad estructural que generó el error PRP-NNN SD-cos-N · resolverla a favor del paso 5 con nota explícita *"CSV pendiente del paso 5 `/validar`"*).
- **Aprendizajes / Self-Annealing:** sección vacía (se rellena durante implementación con gotchas detectados).

### Paso 7.5 · Spawn de skeptic post-draft

> **Bif 2 = A · 🔵 user:** después de generar el draft del PRP en Paso 7 · invocar la persona `skeptic` con el draft completo como input para cuestionar cohesión interna · missing pieces · asunciones sin firmar · contradicciones · ANTES de presentarlo al user para firma APROBADO.

**1 `Task` call con `subagent_type: "Explore"`.**

- **Modelo:** Opus (heredado).
- **`description` (3-5 palabras):** *"Skeptic post-draft review"*.
- **`prompt`:** lee `.claude/skills/planificar/agents/skeptic.md` y le inyecta como contexto:
  - **Path absoluto del PRP draft recién generado en Paso 7** (`.claude/PRPs/PRP-NNN-<descripcion-kebab>.md`).
  - **Feature pedida** (literal del request del user).
  - **Los 3 outputs pre-draft** de Paso 2.5 (ya persistidos en la sección "Análisis pre-draft de las personas" del PRP draft · sub-secciones `### architect-planning` · `### complexity` · `### historical-precedent`).
  - **Opcional · puntos sospechosos específicos del PRP** (guía heurística NO obligatoria · agente principal adapta según contexto del draft). Categorías típicas universales a considerar pasarle al skeptic como *"considera estos puntos específicos a verificar"*:
    1. **Asunciones del stack/tooling NO firmadas** vs constraints inmutables del PRD/BUSINESS_LOGIC § 7 (ej: versiones default de scaffolding tools que difieren del constraint del proyecto).
    2. **Pasos del Blueprint que asumen estado pre-bootstrap** · orden de install · activación de hooks · race conditions del scaffolding.
    3. **Configuraciones cross-archivo coordinadas** · paridad entre `package.json` + configs del framework + estilos globales + etc.
    4. **Smoke tests del DoD por fase** · coverage real vs declarado · anti-patterns típicos del framework usado (ej: Playwright `networkidle` con HMR).
    5. **Convenciones de archivos auto-generados** · qué commitear vs qué no (ej: `next-env.d.ts` · build artifacts · lockfiles).
    6. **Compatibilidad de versiones cross-dependency** · plugins compatibles con major version constraint (ej: <plugin@1.x> compatible major v3 vs v4 del framework).
    7. **CI gates específicos del job afectado** · paridad local↔remote · vars de entorno requeridas en runner.
    8. **Backup pre-cherry-pick si aplica** · preservar archivos del template upstream que tooling externo puede pisar (ej: `README.md` · `CLAUDE.md` · `.gitignore`).

    **Criterio operativo:** elegir 4-10 puntos según scope del PRP · NO prescriptivo · el agente principal evalúa cuáles aplican y cuáles ignorar (ej: PRP de feature UI no aplica "backup pre-cherry-pick"). Sin esta guía, agentes distintos improvisan listas distintas → criterio variable entre sesiones.

    **Lista NO exhaustiva · domain-specific:** las 8 categorías arriba son **universales** · PRPs domain-specific pueden requerir categorías adicionales según dominio (ej: para PRPs con BD · sumar *"migration rollback strategies"* + *"RLS policy interactions"*; para PRPs con auth · sumar *"auth boundary checks"* + *"session token storage"*; para PRPs multi-tenant · sumar *"tenant isolation invariants"*). El agente principal evalúa el dominio y agrega categorías cuando corresponde.
- **Timeout:** 300s (SD-cos-N).

**Recolección del output + refinamiento (SD-cos-N resilience):**

- Si skeptic devuelve output estructurado con issues + missing pieces + asunciones sin firmar + contradicciones internas → **el agente principal lee el output**, evalúa cada issue · refina el draft del PRP si los issues son válidos (loop hasta verde · **max 1 iteración antes del Paso 8**) · pega el output literal en la sub-sección `### skeptic` de "Análisis pre-draft de las personas".
- Si skeptic devuelve **timeout o error** → registrar literal `skeptic no respondió · análisis post-draft incompleto · PRP presentado al user sin refinamiento adicional` en la sub-sección `### skeptic` · **cero ABORT del flujo** · avanzar al Paso 8 con el draft tal cual (SD-cos-N).

**Edge case · skeptic detecta missing pieces por fallo de 2/3 o 3/3 personas pre-draft en Paso 2.5 (LR-NNN lr_bug_NNN):** el refinamiento `max 1 iteración antes del Paso 8` opera solo sobre prosa del draft · NO puede generar inputs reales de arquitecto/complejidad/precedentes que faltaron en Paso 2.5. Si skeptic devuelve missing pieces tipificadas como *"falta análisis architect-planning / complexity / historical-precedent"* + la sub-sección correspondiente de "Análisis pre-draft de las personas" tiene literal `persona X no respondió · análisis incompleto · continuar con las restantes` para **2/3 o 3/3** de las personas pre-draft → la 1 iteración de refinamiento NO alcanza · el agente principal **DEBE preguntar al user** (paridad regla [`ante-duda-preguntar-user.md`](../../rules/ante-duda-preguntar-user.md)) con 2 opciones explícitas + recomendación early:

- **A · re-lanzar Paso 2.5** completo (cero estimación adicional de costo · ~5 min · gana 3 outputs de calidad para el skeptic).
- **B · presentar al user en Paso 8** con riesgo 🔴 explícito en el header del PRP + nota *"personas pre-draft fallaron 2/3 (o 3/3) · skeptic detectó missing pieces estructurales · firmar APROBADO acepta el riesgo de perspectivas paralelas ausentes"*.

  **Rec early default = A** (re-lanzar Paso 2.5) cuando el PRP es complejidad MEDIA con BD + UI + multi-tenant (riesgo de missing pieces estructurales alto) · **Rec B** cuando el PRP es complejidad BAJA con scope acotado (riesgo bajo de perspectivas faltantes). Si 1/3 falla (resilience SD-cos-N estándar) → seguir con el refinamiento normal sin escalar al user (el output parcial alcanza).

**Anti-pattern:** ignorar issues genuinos del skeptic con la excusa "ya lo cierra el user en Paso 8". El skeptic existe para atrapar issues ANTES de la firma · saltarse el refinamiento delega esa carga al user (rompe contrato de "agente como ejecutor + analista").

### Paso 8 · Presentación al user para aprobación final

- Reportar al user el PRP completo: path del archivo creado · resumen de bifurcaciones cerradas · sesiones estimadas · riesgo · próximos pasos.
- Solicitar OK explícito: *"¿Aprobás el PRP-NNN para arrancar implementación?"*.
- **Al recibir OK** → cambiar estado del PRP a `APROBADO` en el header · actualizar [`docs/product/product-roadmap.md`](../../../docs/product/product-roadmap.md) con marca del PRP destino para la task asociada · agregar entrada en [`.claude/memory/log.md`](../../memory/log.md) tipo `decision` ([`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md) formato canónico) · **commit local de los 3 cambios SIN push** (regla [`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) reserva el push único para paso 6 `/entregar` · cero push intermedio en cierre del paso 2).
- **Al NO recibir OK** → ajustar el PRP según feedback del user · re-presentar · iterar hasta firma.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "El contexto del Paso 2 ya tiene la respuesta · salto la validación con el user y avanzo solo" | NO. El patrón es **validación activa** (Bif 3 = C matiz · 🔵 user): cuando la investigación responde, presentar al user lo encontrado + solicitar confirmación explícita. Saltarse la validación introduce asunciones invisibles que se cobran después con re-trabajo. Costo de la confirmación: 1 round-trip de segundos · costo de la asunción equivocada: re-hacer el PRP. |
| "Es solo un PRP chico · skip las 6 preguntas PM hat · cierro rápido" | NO. La sub-checklist de 6 preguntas es **contractual** ([`WORKFLOW.md § 3 Paso 2`](../../../WORKFLOW.md)) · ninguna se omite. "Chico" es subjetivo · el costo de las 6 preguntas es minutos · el costo de un PRP con scope ambiguo es horas de bucle improvisando decisiones que después cuesta rehacer. Si el PRP es genuinamente trivial (Modo A del flujo), no necesitás `/planificar` — ejecutalo directo sin PRP. |
| "El PRP no toca UI nueva · skip `claude-design-matrix` sin avisar al user" | NO. Bif 5 = A + matiz "siempre validar" (🔵 user): el camino con/sin Claude Design **siempre** se firma con el user, incluso cuando la matriz no aplica. La declaración 1-frase ("PRP sin UI nueva · matriz no aplica · skip Claude Design") es parte del contrato — el silencio no es luz verde. |
| "Identifiqué una bifurcación arquitectónica · cierro yo con la opción que me parece correcta" | NO. Bif 4 patrón "decide-quien-decide" (🔵 user): cuando hay decisión real con tradeoff abierto, **el user decide** con tag `🔵 user · YYYY-MM-DD · "<justificación>"`. El agente investiga + recomienda + valida; NUNCA cierra arquitectura solo. Si hay duda entre bifurcación arquitectónica y SD cosmética, es arquitectónica — frená y pedí firma. |
| "La persona `complexity` del Paso 2.5 dijo 🔴 ALTA pero el feature es necesario · skipeo las 4 preguntas y avanzo al Paso 5" | NO. El Paso 4.5 es **gate firme** (regla #13 [`complejidad.md`](../../rules/complejidad.md) PROHIBIDA por default). Las 4 preguntas son obligatorias antes de avanzar · la firma 🔵 user con UNA de las 4 salidas (A simplificar · B split · C postergar · D mantener ALTA con justificación FUERTE) es contractual. "Es necesario" NO autoriza saltarse el protocolo · es exactamente la racionalización que la regla atrapa (§ Anti-rationalization #1 *"Es ALTA pero la necesitamos para diferenciarnos"*). |
| "La persona dijo 🟡 MEDIA pero yo veo señales de 🔴 ALTA · acepto la estimación de la persona y avanzo" | NO. El Paso 4.5 punto 2 manda **reconciliar hacia arriba** cuando la investigación contradice la estimación de la persona. Asimetría firme: hacia arriba sí · hacia abajo NO. La persona pre-draft tiene scope acotado (5 min · Explore agent) · el agente principal tiene contexto completo del Paso 2 · si ve 6+ tablas + 4 pantallas + sincronización, la estimación real es 🔴 ALTA aunque la persona dijo 🟡 MEDIA · activar el gate. |
| "Termino el PRP draft sin generar el archivo en `.claude/PRPs/` · se lo paso por chat al user para confirmar" | NO. El Paso 7 genera el archivo `.claude/PRPs/PRP-NNN-<descripcion-kebab>.md` con estado `PENDIENTE`. Mostrar el draft en chat sin archivo persistente rompe la trazabilidad: el PRP queda sin SoT consultable por sesiones futuras · el roadmap no se puede actualizar · el estado `APROBADO` no tiene anclaje. El archivo SIEMPRE se materializa antes del Paso 8. |
| "El PRP necesita carpeta nueva chica · es trivial · creo la carpeta + README + skip firma user explícita" | NO. Regla #23 [`respect-existing-folder-structure.md`](../../rules/respect-existing-folder-structure.md) § Anti-rationalization #1 + regla #22 [`folder-creation-with-readme.md`](../../rules/folder-creation-with-readme.md) Paso 3: la firma user explícita es **contractual upfront** · cero "después" · cero "asumí que estaba OK" · cero "es chica · le aviso post-creación". El protocolo 5-step de regla #23 (inventario duplicados → subcarpeta dentro de padre razonable → análisis al user con A/B/C + rec early → firma OK explícito → crear con README) es atómico · skipear pasos 3-4 normaliza creación silenciosa. La tabla "tipo carpeta → preguntas canónicas al user" (Paso 7 sub-paso 5) materializa qué preguntar exactamente · si la tabla deja decisión genuinamente trivial (caso raro · subcarpeta dentro de padre obvio), igual presentar 1-líneas al user antes de crear · costo: 1 round-trip de segundos · costo de saltarlo: estructura caótica acumulativa que paga el orden a futuro. |

## Red flags

- 🚩 Estás por generar el PRP draft (Paso 7) sin haber confirmado las 6 preguntas PM hat con el user (alguna quedó como asunción invisible).
- 🚩 El PRP toca UI nueva y NO consultaste [`claude-design-matrix.md`](../../rules/claude-design-matrix.md) ni le presentaste los disparadores al user.
- 🚩 Identificaste una decisión con ≥2 opciones razonables y tradeoff real, y la cerraste con recomendación early sin firma 🔵 del user (la trataste como SD cosmética).
- 🚩 La persona `complexity` del Paso 2.5 estimó 🔴 ALTA y vas a avanzar al Paso 5 sin haber ejecutado las 4 preguntas obligatorias del Paso 4.5 (regla #13 [`complejidad.md`](../../rules/complejidad.md) gate firme · PROHIBIDA por default).
- 🚩 Tu investigación del Paso 2 muestra señales de 🔴 ALTA (6+ tablas · relaciones polimórficas · sincronizaciones · múltiples pantallas con estados anidados) pero aceptaste la estimación 🟡 MEDIA de la persona sin reconciliar hacia arriba (Paso 4.5 punto 2 violado).
- 🚩 Estimación final 🔴 ALTA + las 4 respuestas en el PRP draft, pero NO recibiste firma 🔵 user con UNA de las 4 salidas (A simplificar · B split · C postergar · D mantener ALTA con justificación FUERTE).
- 🚩 El draft del PRP tiene secciones del template `prp-base.md` vacías o con placeholders (`TBD`, `TODO`) — el PRP NO está listo para `APROBADO`.
- 🚩 Cambiaste el estado del PRP a `APROBADO` sin OK explícito del user en el Paso 8 (firma implícita por silencio).
- 🚩 No agregaste entrada en [`.claude/memory/log.md`](../../memory/log.md) tipo `decision` al cerrar la planificación (regla [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md)).
- 🚩 La task del [`docs/product/product-roadmap.md`](../../../docs/product/product-roadmap.md) que el PRP cubre NO quedó marcada con la referencia al PRP destino.

## Verification

- [ ] Paso 1 hecho: `.claude/PRPs/prp-base.md` leído (template canónico identificado).
- [ ] Paso 2 hecho: investigación contextual completada (codebase · BD · roadmap · memoria · reglas firmes aplicables · DT · PRPs históricos).
- [ ] **Cero suposición durante Paso 2 (regla [`no-suponer-fuente-de-verdad.md`](../../rules/no-suponer-fuente-de-verdad.md)):** auto-pregunta firme *"¿sé esto efectivamente o lo estoy suponiendo?"* aplicada por cada afirmación que el PRP draft va a incluir · fuente correcta consultada según orden (A=proyecto · B=externo) · cero memoria del LLM como fuente única en decisiones arquitectónicas que el PRP firma · si fuente NO aclaró, hermana [`ante-duda-preguntar-user.md`](../../rules/ante-duda-preguntar-user.md) invocada antes de generar draft (Paso 7) con duda específica + lo que sí encontré.
- [ ] **Cero creación silenciosa de carpetas en el inventario del PRP (regla [`respect-existing-folder-structure.md`](../../rules/respect-existing-folder-structure.md)):** por cada path nuevo del inventario `test -d <carpeta-padre>` mecánico aplicado · carpetas nuevas detectadas listadas explícito en sub-tabla "carpetas nuevas propuestas" del PRP con razón + alternativas evaluadas · firma 🔵 user por cada carpeta nueva recibida ANTES del Paso 8 (aprobación PRP) · cero asunción silenciosa que delega el `mkdir` al `/implementar` Paso 3.
- [ ] **Paso 2.5 hecho:** 3 personas pre-draft spawneadas en 1 turno P10 fan-out · 3 `Task` calls paralelas con `subagent_type: "Explore"` · timeout 300s · outputs estructurados con campos SD-cos-N recolectados (o literal `persona X no respondió · análisis incompleto · continuar con las restantes` cuando aplica resilience SD-cos-N).
- [ ] Paso 3 hecho: las 6 preguntas PM hat respondidas con confirmación explícita del user (validación activa) · ninguna omitida · informadas por los 3 outputs del Paso 2.5.
- [ ] Paso 4 hecho: matriz Claude Design consultada cuando el PRP toca UI nueva · O justificación 1-frase ("PRP sin UI · matriz no aplica") presentada al user · decisión del camino firmada.
- [ ] **Paso 4.5 hecho:** estimación complejidad reconciliada (output persona `complexity` + investigación Paso 2 · ajuste hacia arriba si aplica · NUNCA hacia abajo). **Si 🟢 BAJA o 🟡 MEDIA** → 1 línea documentada en `### complexity` con razón. **Si 🔴 ALTA** → las 4 preguntas respondidas en sub-sección nueva `### complexity-gate-alta` del PRP draft + firma `🔵 user · YYYY-MM-DD · "<justificación>"` con UNA de las 4 salidas (A simplificar a MEDIA · B split en N PRPs · C postergar V1.5+ · D mantener ALTA con justificación FUERTE). Cero avance silencioso al Paso 5 con estimación final 🔴 ALTA sin firma.
- [ ] **Sub-paso 5.b hecho** (cuando aplica · scope con ≥2 features candidatas): cada feature potencial presentada UNA POR UNA con patrón canónico (Qué resuelve · Cómo la hace el referente · Trade-off · Mi recomendación · ¿Qué te parece?) · firma user explícita por feature antes de avanzar a la siguiente · cero agrupación masiva *"¿qué hacemos con las 5?"* (regla [`decisiones-features.md`](../../rules/decisiones-features.md)).
- [ ] Paso 6 hecho: cada bifurcación arquitectónica con tradeoff real cerrada con firma `🔵 user · YYYY-MM-DD · "<justificación 1-frase>"` · SDs cosméticas documentadas en el PRP con razón 1-frase.
- [ ] Paso 7 hecho: archivo `.claude/PRPs/PRP-NNN-<descripcion-kebab>.md` generado con todas las secciones del template `prp-base.md` rellenas (cero placeholders) · sección "Análisis pre-draft de las personas" incluye sub-secciones `### architect-planning` · `### complexity` · `### historical-precedent` con outputs literales del Paso 2.5.
- [ ] **Paso 7.5 hecho:** skeptic spawneado post-draft con 1 `Task` call · `subagent_type: "Explore"` · timeout 300s · output estructurado pegado en sub-sección `### skeptic` (o literal `skeptic no respondió · análisis post-draft incompleto · PRP presentado al user sin refinamiento adicional` cuando aplica resilience SD-cos-N) · refinamiento del draft aplicado si skeptic detectó issues válidos (max 1 iteración antes del Paso 8).
- [ ] **Sección "Análisis pre-draft de las personas" del PRP generado tiene los 4 outputs literales** (3 pre-draft + 1 skeptic) en las sub-secciones canónicas correspondientes · trazabilidad versionada en git (cero log externo · Bif 4 = B firmada 🔵 user).
- [ ] Paso 8 hecho: OK explícito del user recibido · estado del PRP cambiado a `APROBADO` · [`docs/product/product-roadmap.md`](../../../docs/product/product-roadmap.md) actualizado con marca del PRP destino · entrada `decision` agregada en [`.claude/memory/log.md`](../../memory/log.md).

**Cross-reference firme:**

- SoT contractual: [`WORKFLOW.md § 3 Paso 2`](../../../WORKFLOW.md) (planificación · 6 preguntas PM hat + bifurcaciones cerradas con tag 🔵 user).
- Hermana operativa: [`claude-design-matrix.md`](../../rules/claude-design-matrix.md) (Paso 4 · consulta de la matriz cuando el PRP toca UI nueva · decisión SÍ/CHICO/NO documentada).
- Hermana operativa: [`decisiones-features.md`](../../rules/decisiones-features.md) (sub-paso 5.b · cada feature potencial presentada UNA POR UNA con firma user explícita · cero agrupación masiva).
- Hermana operativa: [`complejidad.md`](../../rules/complejidad.md) (Paso 4.5 · solo BAJA o MEDIA entran al scope · ALTA pasa por las 4 preguntas + firma 🔵).
- Hermana operativa: [`think-before-coding.md`](../../rules/think-before-coding.md) (Paso 6 bifurcaciones arquitectónicas · listar asunciones · presentar interpretaciones múltiples antes de firmar).
- Hermana operativa: [`ante-duda-preguntar-user.md`](../../rules/ante-duda-preguntar-user.md) (toda bifurcación con tradeoff real requiere firma `🔵 user · YYYY-MM-DD · "<justificación>"` antes de cerrar el draft).
- Hermana operativa: [`heuristica-referente-mercado.md`](../../rules/heuristica-referente-mercado.md) (anchor a referente del rubro en cada decisión de feature · "Cómo la hace el referente" en patrón canónico).
- Predecesor: skill [`/arrancar`](../arrancar/SKILL.md) (paso 1 · activa `/planificar` cuando el output template propone Modo C).
- Sucesor: skill [`/implementar`](../implementar/SKILL.md) (paso 3 · arranca cuando el PRP queda `APROBADO`).
