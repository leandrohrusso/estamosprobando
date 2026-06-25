---
name: memory-manager
type: skill
description: |
  Sistema de memoria persistente POR PROYECTO. Guarda conocimiento en `.claude/memory/`
  dentro del repo, versionado con git, compartido con el equipo. Reemplaza la auto-memory
  de Claude Code (local · no viaja con el proyecto). 4 sub-comandos formales del paradigma
  Karpathy llm-wiki: `ingest <archivo>`, `query <pregunta>`, `lint`, `bulk-ingest <pattern>`.
  Activar PROACTIVAMENTE al inicio de sesión para cargar contexto, cuando el usuario corrige
  algo, cuando se descubre un patrón nuevo, cuando se resuelve un bug, o cuando dice
  recordar/recuerda/guarda esto/no olvides.
  Triggers conversacionales: recuerda, remember, guarda esto, no olvides, te acuerdas, recuerdas,
  memoria, en que quedamos, contexto anterior, que sabes de, conversacion pasada,
  sesion anterior.
  Triggers sub-comandos formales:
  - ingest <archivo> · incorporá memoria · incorpora memoria · agregá esta memoria · agrega esta memoria
  - query memoria <pregunta> · qué dice la memoria sobre · que dice la memoria sobre · búscame en la memoria · buscame en la memoria
  - lint memoria · corré el lint · corre el lint · auditá la memoria · audita la memoria · lint mensual de memoria · audit mensual de memoria · auditoría mensual memoria · auditoria mensual memoria (cadencia mensual recomendada · paridad regla #19 [`lint-memory-periodic.md`](../../rules/lint-memory-periodic.md))
  - bulk-ingest <pattern> · incorporá múltiples memorias · incorpora multiples memorias · procesá las memorias del PRP · procesa las memorias del PRP
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Skill: `/memory-manager` — Memoria persistente por proyecto

> **Skill custom autocontenido** (extendido en PRP-NNN Fase 4 con 4 sub-comandos formales del paradigma Karpathy llm-wiki · firma user 🔵 upstream).
>
> **Inspiración estructural:** las 4 ops empíricas (`ingest` · `query` · `lint` · `bulk-ingest`) derivan del **video tutorial Karpathy llm-wiki** ([snapshot inmutable en `.claude/references/external-doctrine/karpathy-llm-wiki-video.md`](../../references/external-doctrine/karpathy-llm-wiki-video.md)), que muestra implementación concreta del [gist de Karpathy llm-wiki](../../references/external-doctrine/karpathy-llm-wiki.md) con Obsidian + Claude Code.
>
> **Adaptación al proyecto:** las 4 ops operan sobre `.claude/memory/` (no `wiki/` + `raw/`) · el "índice" del paradigma es `MEMORY.md` · el `lint` se conecta al script bash `scripts/lint-memory.sh` (PRP-NNN Fase 2 · 6 criterios del lint mensual) · los tipos del proyecto (`feedback` · `reference` · `project` · `user`) reemplazan el dúo `raw/`+`wiki/` del paradigma.

## Overview

> **Propósito:** materializar la memoria persistente por proyecto como entidad de primera clase del flujo. La memoria vive en `.claude/memory/` DENTRO del repo · versionada en git · compartida con el equipo · el usuario tiene control total. Auto-memory de Claude Code está **DESACTIVADA** · este skill es el único mecanismo de memoria.
>
> **4 sub-comandos formales** (paridad con paradigma Karpathy llm-wiki · video tutorial citado arriba):
>
> 1. **`ingest <archivo>`** — incorporar 1 memoria nueva siguiendo los 4 tipos del proyecto (`feedback` · `reference` · `project` · `user`) + actualizar `MEMORY.md` (índice).
> 2. **`query <pregunta>`** — buscar en `MEMORY.md` + memorias relevantes para responder con contexto específico.
> 3. **`lint`** — invocar `bash scripts/lint-memory.sh` (read-only · 6 criterios del lint mensual · output Markdown · NO modifica archivos).
> 4. **`bulk-ingest <pattern>`** — procesar múltiples memorias en una sentada (ej: post-PRP cierre que generó 3-5 memorias nuevas).
>
> **Por qué firme:** sin memoria persistente, los aprendizajes mueren con la sesión. El agente entra en la siguiente conversación sin memoria del bug que cerró ayer · repite el mismo anti-pattern · descubre 3 meses después que el "nuevo" bug ya estaba resuelto pero la solución se perdió. La memoria persistente es el único canal donde el conocimiento sobrevive a la sesión y viaja con el repo.
>
> **Qué NO hace:** ❌ NO sustituye a `CLAUDE.md` ni a las reglas satélite (`.claude/rules/`) — esos son gobierno (cómo trabaja el agente) · la memoria es estado acumulado del proyecto. ❌ NO modifica memorias durante el `lint` (read-only contractual). ❌ NO duplica contenido derivable del código actual (leer el repo es mejor) ni de `git log` / `git blame`.

**Reglas firmes operativas del skill** (heredadas y reforzadas · aplican a todos los sub-comandos):

1. **Consultar es gratis · guardar es caro.** Lee memoria seguido. Escribe solo cuando el conocimiento sobrevive a la sesión actual.
2. **Fechas absolutas siempre.** *"Jueves"* → `2026-03-12`. Las memorias se leen semanas después.
3. **Un archivo por tema.** No mezclar. Si crece mucho, dividir.
4. **El usuario es el dueño.** Él puede borrar · editar · revertir cualquier memoria. Vos NO borrás sin que lo pida.
5. **Sin duplicados con `CLAUDE.md`.** Si algo ya está en el archivo principal del proyecto, NO repetir en memoria.
6. **Honestidad sobre límites.** Si no tenés algo en memoria, decílo. NO inventes.

## When

**Aplica:**

- **Inicio de sesión** — `/arrancar` lee `MEMORY.md` como parte de su Paso 1 (carga de contexto canónica). Este skill se invoca explícitamente para `ingest` · `query` · `lint` · `bulk-ingest` on-demand · NO se solapa con la lectura del boot.
- **Tema recurrente** — si el usuario menciona algo que suena a una corrección o decisión pasada, buscar en memoria antes de responder.
- **Antes de proponer arquitectura/flujo/decisión** — verificar que no contradiga una decisión guardada.
- **Cuando aparece trigger explícito** del user: *"recuerda"* · *"remember"* · *"guarda esto"* · *"no olvides"* · *"te acuerdas"* · *"en qué quedamos"* · *"qué sabes de..."* · *"contexto anterior"* · *"sesión anterior"*.
- **Cuando aparece trigger formal** del sub-comando: *"ingest <archivo>"* · *"query memoria <pregunta>"* · *"lint memoria"* · *"bulk-ingest <pattern>"* + alias documentados en frontmatter.
- **Cierre de PRP / fase / task** — REGLA DE ORO docs y memoria ([`.claude/rules/golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md)) ítem 4 obliga a sincronizar memorias nuevas con `MEMORY.md` antes de marcar `done`.

**NO aplica:**

- **Aprendizajes técnicos genéricos del lenguaje/framework** que no son específicos del proyecto (van a notas personales del user · NO acá).
- **Estado temporal de la conversación actual** (efímero · usar plan/tasks o el contexto de la sesión).
- **Cosas derivables del código actual** (leer el repo es mejor que cachear lectura).
- **Git history** (`git log` / `git blame` son la fuente de verdad).
- **Contenido ya documentado en `CLAUDE.md`** (no duplicar).
- **Soluciones de debugging triviales** (el fix está en el código · el commit message tiene el contexto).

## Process

> **Nota de shape:** este skill diverge legítimamente del canon `### Paso N` que siguen los otros 14 skills del pack. Razón: `/memory-manager` es skill multi-sub-comando (`ingest` · `query` · `lint` · `bulk-ingest`) · cada sub-comando es flujo independiente · NO secuencia lineal de pasos. La estructura `### Sub-comando X` refleja mejor el dispatch real · cero refactor a `Paso N` que distorsionaría la semántica.

### Arquitectura

```text
.claude/memory/
├── MEMORY.md              <- Índice mecánico (entries cortos con link markdown · se carga al inicio · sin tope rígido de líneas · paridad PRP-NNN SD-cos-N)
├── user/                  <- Sobre el usuario/equipo (preferencias · cómo trabajan)
├── feedback/              <- Correcciones del user (qué hacer/no hacer + POR QUÉ)
├── project/               <- Estado de iniciativas en curso (fechas absolutas)
├── reference/             <- Pointers a recursos externos · patrones · soluciones recurrentes
└── log.md                 <- Cronología append-only (regla `log-chronology-append-only.md`)
```

**La carpeta ES el tipo.** Sin frontmatter en archivos de memoria. Markdown plano. Empieza con `# Título`.

| Carpeta | Contenido | Ejemplo ilustrativo |
|---|---|---|
| `user/` | Sobre el usuario/equipo (perfil · tooling habitual · preferencias) | `user/<nombre>.md` — perfil completo del owner (tu proyecto lo genera) |
| `feedback/` | Correcciones del usuario (rule + **Why:** + **How to apply:**) | [`feedback/read-tool-token-limit-workaround.md`](../../memory/feedback/read-tool-token-limit-workaround.md) — gotcha del tooling con workaround canónico |
| `project/` | Estado de iniciativas + decisiones activas (fechas absolutas) | `project/PRP-NNN-checkpoint.md` — checkpoint del PRP en curso (tu proyecto lo genera) |
| `reference/` | Pointers a recursos externos (no contenido duplicado) | tracking de Linear/Slack/dashboards |

**Plus:** `log.md` en la raíz de `.claude/memory/` (no es carpeta · es archivo único) mantiene la cronología append-only del proyecto · gobernado por regla satélite [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md) (regla #20).

### Sub-comando `ingest <archivo>`

> **Paridad con paradigma Karpathy llm-wiki:** *"`ingest` viene siendo cada vez que creamos una nueva cosa. Es como digiérelo, interprételo, clasifícalo, categorízalo, créale las tags, hazle literalmente todo, crea su página, actualiza temas, etcétera"* (cita literal del [snapshot llm-wiki video](../../references/external-doctrine/karpathy-llm-wiki-video.md) § Capítulo 6). En el proyecto: 1 memoria nueva → archivo en la carpeta correcta + entrada en `MEMORY.md`.

**Procedimiento (5 pasos · obligatorio):**

1. **Verificar que NO existe duplicado.** Leer `MEMORY.md` (índice). Si ya hay archivo sobre el tema, **ACTUALIZAR** en vez de crear uno nuevo.
2. **Identificar el tipo correcto** (ver tabla en § Arquitectura). Si dudás entre `feedback` y `reference`: ¿es regla de comportamiento del agente con **Why:** y **How to apply:**? → `feedback`. ¿Es pointer a recurso externo o patrón técnico recurrente? → `reference`.
3. **Escribir el archivo de detalle** con `Write` o `Edit`:
   - Path: `.claude/memory/<tipo>/<slug-descriptivo>.md`.
   - Slug: `kebab-case` · 3-6 palabras · descriptivo del tema (ej: `psql-set-variables-not-in-do-blocks.md`).
   - Formato: Markdown plano · sin frontmatter · empieza con `# Título`.
   - Para `feedback/` y `project/`: incluir **Why:** y **How to apply:** explícitos (regla [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md)).
   - **Fechas absolutas siempre** (NO "ayer" / "el lunes pasado" / "hace 3 meses").
   - **Caso especial · entry en `log.md`** (refinamiento iterativo upstream): si la memoria nueva es entry cronológico del proyecto (cierre de PRP · decisión arquitectónica firmada · incidente · pivote estratégico · hito mayor · ejecución de lint) → NO es archivo en `<tipo>/<slug>.md` · es entry append-only en `.claude/memory/log.md` siguiendo shape canónico de regla [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md) (regla #20). Shape obligatorio: h2 con prefijo `## [YYYY-MM-DD] <op> | <título corto>` + secciones `**Resumen:**` (1-2 frases) + `**Detalle:**` (opcional · 2-5 líneas) + `**Refs:**` (≥1 ref operativa · commit hash · PRP-NNN · memoria path · ticket). Tipos `<op>` válidos (6 únicos · cero invención): `prp-close` · `decision` · `incident` · `directional` · `milestone` · `lint`. Append-only contractual · cero modificación retroactiva · cero backfill · entrada nueva siempre al final del archivo.
4. **Actualizar `MEMORY.md`** (índice) con `Edit` agregando 1 línea con link al archivo + descripción 1-frase. Mantener entries cortos (1 línea con link · NO resumen ejecutivo) · organizar por tema · NO cronológicamente · sin tope rígido de líneas (paridad PRP-NNN SD-cos-N · lo que importa es densidad legible, no conteo).
5. **Informar al user** qué se guardó y dónde. NO pedir permiso (lo verá en el `git diff`). Si el user revierte el cambio, respetar sin discutir.

**Anti-pattern frecuente:** crear memoria nueva sobre tema que ya tiene archivo (genera duplicado · futura sesión carga 2 archivos contradictorios). Antes de `Write` siempre `grep -l "<tema>" .claude/memory/feedback/ .claude/memory/reference/`.

### Sub-comando `query <pregunta>`

> **Paridad con paradigma Karpathy llm-wiki:** *"`query` es para consultar directamente. ... le hablo yo a Claude Code para buscar ciertas cosas"* + *"el modelo es muy bueno leyendo los índices ... va al índice y va a empezar a crear correlaciones"* (cita literal del [snapshot llm-wiki video](../../references/external-doctrine/karpathy-llm-wiki-video.md) § Capítulos 4 y 6). En el proyecto: navegar `MEMORY.md` (índice) → archivo de detalle → responder con contexto específico.

**Procedimiento (4 pasos):**

1. **Leer `MEMORY.md`** (siempre primero · es el índice central · paridad con la doctrina del video llm-wiki: el modelo navega el índice antes de explorar archivos).
2. **Identificar archivos relevantes** (matching por tema · ej: si user pregunta *"qué dice la memoria sobre Auth NULL"*, buscar entradas con "Auth" / "NULL" / términos relacionados en el índice).
3. **Leer los archivos identificados** (1-3 archivos típicamente · si son más, narrowar la query con el user antes de cargar todos).
4. **Responder con contexto específico** + citar paths (markdown links a los archivos · no copiar contenido ciego).

**Si NO hay match en memoria:** decirlo honestamente: *"No tengo eso en memoria"* + sugerir el sub-comando `ingest` si el user quiere agregarlo. **NO inventar.**

**Disparadores típicos del user:** *"te acuerdas de..."* · *"en qué quedamos con..."* · *"qué sabes de..."* · *"qué dice la memoria sobre..."* · *"búscame en la memoria..."*.

### Sub-comando `lint`

> **Paridad con paradigma Karpathy llm-wiki:** *"`lint` es algo clave, es una especie de mantenimiento donde va a tomar todos los archivos sueltos o los archivos solitarios que no tienen relación alguna ... los va a directamente marginar o los va a conectar con algo"* (cita literal del [snapshot llm-wiki video](../../references/external-doctrine/karpathy-llm-wiki-video.md) § Capítulo 6). En el proyecto: invocar el script bash `scripts/lint-memory.sh` (script bash dedicado · varias centenas de LoC) que ejecuta los 6 criterios del lint mensual · read-only por contrato.

**Procedimiento (3 pasos · sin código nuevo en este SKILL):**

1. **Invocar directo** el script de Fase 2:

   ```bash
   bash scripts/lint-memory.sh
   ```

2. **Capturar el output Markdown** (7 secciones · 6 criterios + Resumen) y presentárselo al user. NO interpretar agresivamente · el output ya está estructurado para lectura humana directa.

3. **Esperar decisión del user** caso por caso. El lint es **read-only por contrato** ([regla `lint-memory-periodic.md`](../../rules/lint-memory-periodic.md)) · NO modifica memorias automáticamente. Cada fix lo dispara el user con commit aparte (mensaje sugerido: `lint(memory): <criterio> · <fix corto>`).

**Los 6 criterios** (regla satélite [`lint-memory-periodic.md`](../../rules/lint-memory-periodic.md) define el detalle):

| # | Criterio | Tipo |
|---|---|---|
| 1 | Contradicciones entre 2+ memorias | Semántico (manual review · script da template) |
| 2 | Stale claims (memoria contradice estado real del repo) | Semántico + heurística mtime > 90 días |
| 3 | Orphan files (no en `MEMORY.md`) | Mecánico (cruce físico vs índice) |
| 4 | Conceptos sin página propia (3+ menciones cruzadas) | Semántico (manual review · script da `grep -lE`) |
| 5 | Cross-references rotos (link markdown a archivo inexistente) | Mecánico (regex + `test -e`) |
| 6 | Data gaps PRP (PRP COMPLETADO sin entrada `prp-close` en `log.md`) | Mecánico (cruce roadmap vs `log.md`) |

**Cadencia esperada:** mensual por default · trigger manual del user disponible en cualquier momento. Cierre del lint con entrada `lint` en `log.md` (formato canónico de [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md)).

### Sub-comando `bulk-ingest <pattern>`

> **Paridad con paradigma Karpathy llm-wiki:** *"`bulk-ingest` es para procesar también muchos archivos de una"* (cita literal del [snapshot llm-wiki video](../../references/external-doctrine/karpathy-llm-wiki-video.md) § Capítulo 6). En el proyecto: aplica al cierre de PRPs que generaron 3-5 memorias nuevas en una sola sentada · la REGLA DE ORO ítem 4 obliga a sincronizarlas con `MEMORY.md` (regla satélite [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) #9).

**Procedimiento (4 pasos · iteración de `ingest`):**

1. **Resolver el pattern** con `Glob` (ej: `bulk-ingest .claude/memory/feedback/PRP-NNN-*.md` o `bulk-ingest <lista de paths separados por espacios>`).
2. **Para cada archivo del match · iterar los 5 pasos del sub-comando `ingest`** (verificar duplicado · identificar tipo · escribir/actualizar · actualizar índice · informar).
3. **Actualizar `MEMORY.md` 1 sola vez al final** (no N veces · sumar todas las entradas en 1 `Edit` reduce ruido del diff).
4. **Reportar al user** el resumen del batch: cuántas memorias agregadas · cuántas actualizadas · cuántas saltadas (duplicado detectado).

**Cuándo usar bulk vs N llamadas a `ingest`:** si N ≥ 3 archivos o el user pidió procesar un set explícitamente, usar `bulk-ingest`. Para 1-2 archivos sueltos, llamar `ingest` N veces es más legible.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "El aprendizaje es chico, no necesita memoria" | NO. La memoria es donde el aprendizaje sobrevive a la sesión. Sin esa fila, en 3 meses el agente repite el bug porque "no se acordaba". Costo de la memoria: 30 segundos. Costo de no tenerla: re-debuggear el mismo problema. Regla heredada de [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md). |
| "Lo documento en la sesión que viene cuando tenga más tiempo" | NO. La sesión que viene NO va a tener más tiempo. Y el contexto exacto del aprendizaje se va a haber perdido. La memoria se escribe AHORA, mientras el contexto está fresco (regla universal del proyecto). |
| "Creo memoria nueva sobre el tema, después consolido los duplicados" | NO. Verificar duplicado ANTES con `grep -l "<tema>"` es contractual del paso 1 de `ingest`. Crear duplicado primero = futura sesión carga 2 archivos contradictorios = bug invisible. |
| "Modifico memorias automáticamente cuando corro `lint`" | NO. El lint es read-only por contrato (regla [`lint-memory-periodic.md`](../../rules/lint-memory-periodic.md)). Reporta · el user decide. Modificar sin OK introduce ruido y pérdida de contexto. |
| "Pongo `YYYY-MM-DD` en una memoria como 'la semana pasada' o 'hace poco'" | NO. Fechas absolutas siempre. Las memorias se leen semanas/meses después. Convertir relativas a absolutas en el momento del `ingest` (ej: *"el jueves pasado"* → `YYYY-MM-DD`). |
| "Si no encuentro el tema en memoria, infiero la respuesta" | NO. Regla de oro #6: honestidad sobre límites. Si no tenés algo en memoria, decilo. NO inventes. La inferencia silenciosa lleva a respuestas que el user toma como autoritativas y no lo son. |
| "Los aprendizajes del PRP los dejo en el commit message · no hace falta archivo en `feedback/`" | NO. Commit messages no son indexables fácilmente · `MEMORY.md` sí. Si el aprendizaje es genérico (aplica a futuros PRPs), va a `feedback/` con **Why:** y **How to apply:**. Si es específico al PRP en curso, va a `project/<PRP>-checkpoint.md`. |

## Red flags

- 🚩 Estás por ejecutar `Write` en `.claude/memory/<tipo>/` sin haber corrido `grep -l "<tema>"` primero (riesgo de duplicado).
- 🚩 Tu `ingest` agregó archivo nuevo pero NO actualizaste `MEMORY.md` (orphan file inmediato · el lint criterio 3 lo va a pescar).
- 🚩 Estás respondiendo *"sí, recuerdo que..."* sin haber leído `MEMORY.md` ni el archivo de detalle · es alucinación.
- 🚩 La memoria que estás escribiendo tiene fecha relativa (*"hace 3 semanas"* · *"el mes pasado"*) en lugar de absoluta (`YYYY-MM-DD`).
- 🚩 El `lint` reportó hallazgos y los estás "fixeando" sin OK explícito del user (rompe contrato read-only).
- 🚩 La memoria tiene contenido derivable del código (paths · nombres de funciones · línea de código sin razón) · debería ser pointer al archivo, no cache.
- 🚩 El cierre de un PRP marcó `done` pero `MEMORY.md` no tiene entradas para las memorias nuevas que el PRP dejó (REGLA DE ORO ítem 4 violada).
- 🚩 Tu `MEMORY.md` tiene entries que son resúmenes ejecutivos en vez de 1 línea con link markdown · o hay temas que merecen consolidación (cross-references densos · duplicados parciales). La medida NO es conteo de líneas (paridad PRP-NNN SD-cos-N · sin tope rígido) · es densidad legible y prolijidad del shape "entries cortos con link".

## Verification

Cómo confirmar que el sub-comando operó correctamente:

**Post `ingest <archivo>`:**

- [ ] Archivo nuevo existe en `.claude/memory/<tipo>/<slug>.md` con contenido (no vacío).
- [ ] `MEMORY.md` tiene 1 línea nueva con link markdown al archivo + descripción 1-frase.
- [ ] El tema NO existía previamente (verificable con `grep -l "<tema>" .claude/memory/{feedback,reference,project,user}/*.md` retorna solo el archivo nuevo).
- [ ] Fechas en el archivo son absolutas (`YYYY-MM-DD`) · cero relativas.
- [ ] Si tipo es `feedback` o `project`: contiene **Why:** y **How to apply:** explícitos.
- [ ] **Si la memoria fue entry en `log.md`** (refinamiento iterativo upstream): h2 cumple sintaxis exacta `## [YYYY-MM-DD] <op> | <título corto>` con uno de los 6 tipos válidos (`prp-close` · `decision` · `incident` · `directional` · `milestone` · `lint`) + Resumen + (Detalle opcional) + Refs presentes · entrada agregada al final del archivo (cronológico estricto) · cero modificación de entradas pasadas (verificable con `git diff` mostrando solo append).
- [ ] User informado del path del archivo nuevo.

**Post `query <pregunta>`:**

- [ ] `MEMORY.md` fue leído primero (verificable en transcript).
- [ ] Archivos de detalle leídos (1-3 archivos · si más, query fue narrowado con user).
- [ ] Respuesta cita paths con markdown links · no copia contenido ciego.
- [ ] Si NO había match: respuesta dice explícitamente *"no tengo eso en memoria"* + sugiere `ingest` si aplica.

**Post `lint`:**

- [ ] `bash scripts/lint-memory.sh` ejecutó EXIT=0 (script no fatal · pueden haber hallazgos · script termina OK).
- [ ] Output Markdown presentado al user con las 7 secciones (6 criterios + Resumen).
- [ ] Cero modificación automática de archivos (verificable con `git status` post-lint · debe estar igual que pre-lint).
- [ ] Si user decide fixear: cada fix queda en commit separado con mensaje `lint(memory): <criterio> · <fix corto>`.
- [ ] Cierre del lint con entrada `lint` en `.claude/memory/log.md` (formato canónico [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md)).

**Post `bulk-ingest <pattern>`:**

- [ ] Pattern resuelto con `Glob` · lista de archivos enumerada al user antes de iterar.
- [ ] Cada archivo del batch verificó duplicado antes de Write (paso 1 de `ingest`).
- [ ] `MEMORY.md` actualizado 1 sola vez al final (no N veces · 1 `Edit` con todas las entradas nuevas).
- [ ] Reporte final con count de memorias agregadas + actualizadas + saltadas (duplicado).

**Cross-reference firme:**

- Regla padre operativa: [`.claude/rules/golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) (REGLA DE ORO · ítem 4 obliga sincronizar memorias).
- Regla operativa del lint: [`.claude/rules/lint-memory-periodic.md`](../../rules/lint-memory-periodic.md) (6 criterios · operación read-only · cadencia mensual).
- Regla operativa del log cronológico: [`.claude/rules/log-chronology-append-only.md`](../../rules/log-chronology-append-only.md) (formato canónico de entradas en `log.md`).
- Snapshot doctrina (cita inline contractual · paridad con `/revisar` que cita addyosmani): [`.claude/references/external-doctrine/karpathy-llm-wiki-video.md`](../../references/external-doctrine/karpathy-llm-wiki-video.md) (4 ops empíricas: `ingest` · `query` · `lint` · `bulk-ingest`).
- Gist original Karpathy llm-wiki (teoría): [`.claude/references/external-doctrine/karpathy-llm-wiki.md`](../../references/external-doctrine/karpathy-llm-wiki.md) (3 capas + 4 ops · paradigma).
- Script bash invocado por sub-comando `lint`: [`scripts/lint-memory.sh`](../../../scripts/lint-memory.sh) (6 criterios del lint mensual · output Markdown · NO bloqueante).

---

## Appendix · Activación primera vez (histórico · 1 vez por proyecto · ya ejecutada en el proyecto)

> Esta sub-sección queda como referencia histórica · NO re-ejecutar. El proyecto tiene la memoria persistente activa desde hace meses (verificable: `test -d .claude/memory && test -f .claude/memory/MEMORY.md`).

**Paso 1 · Deshabilitar auto-memory** de Claude Code creando `.claude/settings.json` con `"autoMemoryEnabled": false`. Razón: la auto-memory guarda en `~/.claude/projects/` (local · no viaja con el repo · no es versionada · no es compartida).

**Paso 2 · Crear estructura de carpetas:**

```bash
mkdir -p .claude/memory/{user,feedback,project,reference}
```

**Paso 3 · Crear índice `MEMORY.md`** con template base (ver § Process > "Arquitectura").

**Paso 4 · Confirmar al usuario** que la memoria persistente está activa.
