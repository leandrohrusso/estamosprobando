---
name: arrancar
type: skill
description: "Cargar contexto del proyecto al inicio de una sesion del producto. Lee CLAUDE.md, BUSINESS_LOGIC.md, WORKFLOW.md, MEMORY.md, log.md, technical-debt.md, y mapea estado del repo. Activar cuando el usuario dice: arranca, arrancá, arranca la sesion, arrancá la sesión, dame contexto, que tenemos, qué tenemos, donde estamos, dónde estamos, resumime el proyecto, iniciar, iniciá."
allowed-tools: Read, Grep, Glob, Bash
---

> **⚙️ Stack adaptation banner.** Este SKILL es **template universal**. Los ejemplos concretos en el cuerpo asumen un stack típico (Next.js · Supabase · Playwright · GitHub Actions · Husky). Si tu proyecto usa otro stack, adaptá:
>
> - **MCP names** del frontmatter `allowed-tools` (`mcp__claude_ai_Supabase__*` · `mcp__playwright__*` · `mcp__next-devtools__*`) a los MCPs disponibles en tu proyecto.
> - **Patrones de código** mencionados en `## Process` (Server Actions · RLS policies · RPCs · revalidatePath · etc) al equivalente de tu framework.
> - **Tooling externo** (`npm run ci:local` · `bash scripts/local-ci.sh` · `gh pr merge`) a los comandos reales de tu proyecto.
>
> El **shape canónico P8** (Overview · When · Process · Anti-rationalization · Red flags · Verification) NO se altera · solo las referencias concretas a stack.

# Skill: `/arrancar` — paso 1 · Contexto del flujo de 6 pasos

> **Skill custom autocontenido**. Skill del paso 1 del flujo de 6 pasos · entry point del proyecto.
>
> **Inspiración estructural:** [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills) · ver [doctrina estructural compartida](../README.md#doctrina-estructural-compartida) en `skills/README.md` para convención de adaptación.

## Overview

> **Propósito:** cargar el contexto del proyecto al inicio de una sesión del producto · identificar la próxima task pendiente · proponer próximo paso al user en formato Modo A/B/C (ver [`WORKFLOW.md § 5`](../../../WORKFLOW.md)).

**Cuándo invocar:**

- **Boot de sesión** — primera respuesta del agente en una sesión nueva del producto.
- **Hand-off entre sesiones** — cuando una sesión nueva retoma trabajo de una previa (lectura de checkpoint + handoff si existen).
- **Re-orientación mid-sesión** — si el user dice *"dame contexto"* · *"qué tenemos"* · *"dónde estamos"* después de un cambio de tema o pausa larga.

**Qué NO hace:**

- ❌ NO ejecuta tasks (solo recomienda · espera OK del user).
- ❌ NO modifica archivos (read-only · `allowed-tools` excluye Edit/Write).

## When

| Caso | Aplica `/arrancar` |
|---|---|
| Primera respuesta del agente en sesión nueva del producto | ✅ SÍ |
| El user dice *"arranca"* · *"arranca la sesion"* · *"dame contexto"* · *"qué tenemos"* · *"dónde estamos"* · *"resumime el proyecto"* · *"iniciar"* | ✅ SÍ |
| Sesión nueva que retoma trabajo previo (existe checkpoint o handoff de PRP en `.claude/memory/project/`) | ✅ SÍ (incluir checkpoint/handoff en lectura) |
| Re-orientación mid-sesión después de cambio de tema o pausa larga | ✅ SÍ |
| Continuación inmediata de una task ya en ejecución dentro de la misma sesión | ❌ NO (contexto ya cargado · re-invocación es ruido) |
| Tasks triviales del Modo A que el user pide directamente sin necesidad de orientación | ❌ NO (el user ya sabe qué quiere · `/arrancar` no aporta) |

## Process

> **Skill autocontenido.** El § Process embebe los 6 pasos del Protocolo de auto-orient para ejecutar la carga de contexto sin abrir CLAUDE.md (consolidación 7→6 firmada user · plegado del "mapeo silencioso del repo" como sub-paso final del Paso 1 · paridad cardinalidad con `/revisar` y `/validar`).
> **Cita inline de doctrina:** la lista canónica de "archivos de entrada del proyecto" vive en [`CLAUDE.md` § "Archivos de entrada del proyecto"](../../../CLAUDE.md). Este skill **referencia** esa lista (1 fuente de verdad) y la **complementa** con extensiones operativas que el flujo ya consume al boot (`MEMORY.md` índice · `log.md` últimas 5 entradas · `technical-debt.md`).
> **Reglas firmes que enmarcan el boot** (leyenda+link · NO embebidas · doctrina vive en los satélites · refinamiento iterativo upstream):
>
> - [`heuristica-referente-mercado.md`](../../rules/heuristica-referente-mercado.md) — anchor de mercado: cuando hay duda de feature/UX/arquitectura, mirar primero cómo lo hace el referente del rubro · aplica al recomendar tasks de feature en Paso 2/5.
> - [`repaso-features.md`](../../rules/repaso-features.md) — síntesis pre-recomendación: antes de proponer próximo paso al user en el output template, sintetizar el estado del proyecto (próxima task · PRPs activos · DTs urgentes · deadlines) en bloque claro · cero recomendación basada en lectura suelta · paridad con el patrón "repaso sintético antes de avanzar" del flujo de discusión.
> - [`conversation-style.md`](../../rules/conversation-style.md) — formato del output template del Paso 5: español neutro coloquial · tope blando ~12 líneas · tablas cuando ayudan a comparar · recomendación early con justificación 1-frase en § Próximo paso recomendado · cero jerga de implementación cuando hay equivalente claro.
> - [`status-tracker-visible.md`](../../rules/status-tracker-visible.md) — cuando el modo recomendado en Paso 5 es Modo C (PRP + bucle de 6 pasos), señalar al user en el output template § Próximo paso recomendado que la próxima sesión va a mantener el status tracker visible al inicio de cada respuesta principal hasta cerrar el paso 6 · contrato del bookkeeping del flujo · tracker NO se imprime en Modo A/B.
> - [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) — el estado del proyecto leído en Paso 1 (`log.md` últimas 5 entradas · `technical-debt.md` DTs activas · `MEMORY.md` índice) es la cara visible de la GR aplicada en cierres previos · si la lectura detecta gap del checklist 6-ítems (PRP COMPLETADO sin entry `prp-close` en `log.md` · DT cerrada sin commit hash · memoria nueva sin entry en `MEMORY.md`), agregar aviso en output template § Estado del roadmap como señal para auditar el cierre previo antes de avanzar.

### Paso 1 · Lectura de archivos canónicos (en orden)

> **Short-circuit · sesión reciente (Modo A):** si `git log -1 --format="%cr" HEAD` retorna `<30 minutes ago` Y la sesión actual heredó el contexto de la previa (typeahead obvio · el agente tiene presente el último PRP en curso) → **skip puntos 2-7 abajo + mapeo silencioso** · solo correr `git status --short` + `grep "^## \[" .claude/memory/log.md | tail -3` para detectar cambios desde el último cierre. Re-orientación liviana · cero re-lectura de archivos canónicos. Pasar directo al Paso 4 (determinar modo) con el contexto cacheado. **NO aplica** si la sesión es genuinamente fresca (modelo sin contexto previo · primera invocación del día).

1. [`CLAUDE.md`](../../../CLAUDE.md) — **ya cargado en el system prompt automáticamente** (cero re-lectura · evita gastar tokens). Solo confirmar mentalmente que se respetan las 35 reglas firmes de la tabla canónica (`grep "^| [0-9]" CLAUDE.md | wc -l` debería retornar ≥35).
2. [`BUSINESS_LOGIC.md`](../../../BUSINESS_LOGIC.md) — identidad del proyecto · 22 decisiones críticas · mapa de los 56 archivos en `docs/`.
3. [`WORKFLOW.md`](../../../WORKFLOW.md) — flujo de sesión (6 pasos del flujo nuevo · modos A/B/C · decisiones cerradas · mantenimiento periódico).
4. [`.claude/memory/MEMORY.md`](../../memory/MEMORY.md) — índice de memoria persistente (feedback / reference / project). **Workaround tool `Read` limit (>25K tokens · empírico con 241 líneas / 38K tokens):** leer con `Read` + `limit: 50` para header + glosario + carpetas principales · O `head -50 .claude/memory/MEMORY.md` para overview rápido · O `grep "^- \[" .claude/memory/MEMORY.md | head -30` para listar entries sin leer descripciones (DT-NNN va a resolver esto estructuralmente con multi-level index cuando dispare su threshold).
5. Últimas 5 entradas de [`.claude/memory/log.md`](../../memory/log.md) vía `grep "^## \[" .claude/memory/log.md | tail -5` — cronología de cierres de PRPs · decisiones · incidentes · directional · milestones recientes.
6. [`docs/logs/technical-debt.md`](../../../docs/logs/technical-debt.md) — deudas técnicas activas por PRP destino · identificar (a) si es buen momento para corregir alguna y (b) si la sesión cruza con alguna DT vinculada. **Workaround tool `Read` limit (>25K tokens · empírico con 355 líneas / 72K tokens):** NO leer entero · estructura del archivo (verificable con `grep -nE "^## |^### " docs/logs/technical-debt.md | head -40`): líneas 1-22 header + reglas A/B/C · líneas 23+ § Deudas activas (¡leer esto!) · líneas 276+ § Deudas resueltas (skip al boot · histórico) · líneas 336+ § Bitácora histórica (skip al boot). Patrón canónico: `Read offset=1 limit=100` para header + primeras DTs activas · o `sed -n '23,275p' docs/logs/technical-debt.md` para solo § Activas · NUNCA leer entero al boot.
7. [`docs/logs/deadlines.md`](../../../docs/logs/deadlines.md) § Activos — recordatorios fechados · para cada fila correr `date -d <fecha> +%s` y comparar con `date -d "+7 days" +%s`: si la fecha ya pasó o entra en los próximos 7 días, sumar aviso al output template § Deadlines. SoT del contenido vive en el link (DT · regla · memoria) · este archivo es solo índice operativo.

**Matriz "tipo de archivo canónico → pregunta del estado que responde" · orden estricto NO improvisable (refinamiento iterativo upstream · materializa la doctrina *"docs y memoria son INDISPENSABLE de cada task"* de regla #18 [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) como orden secuencial firme al boot):**

El orden 1→7 arriba NO es arbitrario · cada archivo responde a una pregunta específica del estado del proyecto · saltarse uno deja al agente sin la dimensión correspondiente:

| # | Archivo | Pregunta del estado que responde | Si lo saltás te perdés |
|---|---|---|---|
| 1 | `CLAUDE.md` (auto-cargado al system prompt) | *"¿Qué reglas firmes rigen mi trabajo en este proyecto?"* | Las 35+ reglas firmes · el agente improvisa criterios que ya están codificados |
| 2 | `BUSINESS_LOGIC.md` | *"¿Qué construimos · qué identidad tiene el producto?"* | Identidad · decisiones críticas · mapa de `docs/` · sin esto la sesión confunde features del producto con primitives genéricos |
| 3 | `WORKFLOW.md` | *"¿Cómo trabajamos · cuál es el flujo de los 6 pasos · cuáles son los modos A/B/C?"* | El proceso · el agente puede saltarse pasos del flujo o aplicarlos en orden equivocado |
| 4 | `.claude/memory/MEMORY.md` (índice) | *"¿Qué aprendizajes técnicos ya están codificados y cómo los encuentro?"* | Catálogo de gotchas / patterns · el agente paga gotchas ya resueltos por sesiones previas |
| 5 | `log.md` últimas 5 entradas (`grep tail -5`) | *"¿Qué pasó recientemente · qué se cerró · qué se decidió?"* | Cronología reciente · el agente arranca como si el último mes no hubiera ocurrido |
| 6 | `docs/logs/technical-debt.md` § Activas | *"¿Qué deudas técnicas viven sin cerrar · cuáles cruzan con la próxima task?"* | Deudas activas · el agente arranca trabajo que cruza con una DT sin saberlo · costo: mezcla scope + re-trabajo |
| 7 | `docs/logs/deadlines.md` § Activos | *"¿Hay alguna fecha vencida o ≤7 días · saneamiento periódico pendiente?"* | Deadlines · el agente NO propone proactivamente saneamiento mensual cuando corresponde (lint memoria · audit DTs · `/revisar-main`) |

**Por qué el orden es secuencial · NO se reordena:** la matriz es **diagnóstico acumulativo** · cada archivo enriquece el contexto del siguiente. Leer `log.md` (#5) sin haber leído `WORKFLOW.md` (#3) deja sin marco a *"¿qué se cerró del paso 6?"*. Leer `technical-debt.md` (#6) sin haber leído `MEMORY.md` (#4) deja sin contexto a *"¿qué patrón replicable hay detrás de esta DT?"*. Reordenar = perder estructura · saltar = perder dimensión · ambos rompen el contrato de la GR ítem 4 ("memoria persistente actualizada al cierre" presupone que al boot se lee en orden para detectar gaps del checklist 6-ítems).

**Excepciones al orden codificadas (NO improvisar otras):** (a) short-circuit por sesión reciente <30 min · cubierto en intro del Paso 1 arriba · skip #2-7 + mapeo silencioso. (b) Workarounds tool `Read` limit para #4 y #6 · cubiertos inline en cada bullet (`head -N` · `grep` targeted · `sed -n 'A,Bp'`) · NUNCA leer entero archivos >25K tokens al boot. (c) #1 ya cargado al system prompt automáticamente · solo confirmar conteo de reglas firmes (`grep "^| [0-9]" CLAUDE.md | wc -l`).

**Mapeo silencioso del repo (sub-paso final · 5 checks mecánicos · sin output al user salvo sorpresa):**

- ¿Existe `package.json`? (si no, repo pre-bootstrap · avisar al user antes de seguir).
- ¿Estructura `src/app/` o `app/`? ¿Features en `src/components/`?
- ¿Migraciones en `db/migrations/` o `supabase/migrations/`?
- ¿PRPs en `.claude/PRPs/`?
- `git status --short` para confirmar working tree limpio.

#### Sub-paso 1.b · Detección de estado post-template (regla `product-docs-as-bootstrap-sot`)

> **Materializa regla [`product-docs-as-bootstrap-sot.md`](../../rules/product-docs-as-bootstrap-sot.md) como gate operativo del boot.** Si el mapeo silencioso detecta estado "post-template" (proyecto recién creado desde `workflow-base` · BUSINESS_LOGIC.md con placeholders · cero PRPs · `docs/product/references/` sin docs del user), el skill **salta el flujo normal** (Pasos 2-5 no aplican porque el roadmap también está en placeholders) y entra a la rama dedicada de bootstrap descrita abajo.

**Disparador binario (5 condiciones · todas deben cumplirse):**

**Cómo determinar las 5 condiciones:** ejecutar el bash check explícito abajo (preferido · trazable en logs + reproducible) **O** por **inspección visual** de los archivos canónicos ya leídos en Paso 1 (legítima si el agente llega a la misma conclusión binaria · ej: BUSINESS_LOGIC.md visualmente llena → C2 FAIL · CLAUDE.md sin `<PROYECTO>` → C1 FAIL). Ambos caminos llegan al mismo destino · cero double-work. **Cuándo preferir bash:** auditoría posterior · trazabilidad en logs · sesión muy fresh sin contexto previo. **Cuándo es OK visual:** archivos canónicos ya cargados en contexto del Paso 1 · concluyente sin ambigüedad.

```bash
# 1. CLAUDE.md línea 1 sin reemplazar
grep -q "<PROYECTO>" CLAUDE.md && echo "C1-OK"

# 2. BUSINESS_LOGIC.md con placeholders del template sin llenar (≥3 matches del patrón canónico `<...>`)
[ "$(grep -cE '<' BUSINESS_LOGIC.md)" -ge 3 ] && echo "C2-OK"

# 3. Cero PRPs reales · matchea solo archivos con prefijo PRP- (ignora README.md y _template.md de la carpeta)
[ "$(find .claude/PRPs -name 'PRP-*.md' 2>/dev/null | wc -l)" = "0" ] && echo "C3-OK"

# 4. Historial git ≤5 commits (template + bootstrap inicial)
[ "$(git log --oneline | wc -l)" -le 5 ] && echo "C4-OK"

# 5. Cero docs de producto del user en references/
[ "$(find docs/product/references -maxdepth 1 -type f -name '*.md' -not -name 'README.md' | wc -l)" = "0" ] && echo "C5-OK"
```

**Si NO se cumplen las 5:** proyecto ya en curso · continuar con flujo normal al Paso 2.

**Si se cumplen las 5 (post-template confirmado):** ejecutar las 4 sub-acciones abajo en orden estricto · cero salto al Paso 2 · cero output template del Paso 5 todavía.

##### Sub-acción 1.b.1 · Solicitar docs de producto al user (output bloqueante)

Emitir el siguiente output al user · esperar respuesta antes de cualquier acción adicional:

```markdown
🌱 **Estado post-template detectado · sesión inicial del proyecto.**

Antes de arrancar el bootstrap mecánico (Pasos 1-7 del README), necesito los **docs de producto** que vas a usar como SoT (regla [`product-docs-as-bootstrap-sot`](.claude/rules/product-docs-as-bootstrap-sot.md)). Las 3 variantes válidas:

- **Mínimo · solo PRD:** 1 archivo con requisitos del producto.
- **Medio · PRD + 1 más:** PRD + (`product-vision.md` OR `product-roadmap.md`).
- **Máximo · los 3:** PRD + `product-vision.md` + `product-roadmap.md`.

Los archivos van en `docs/product/references/` (path canónico · contractual). Naming flexible · formato `.md` obligatorio (cero `pdf` · `docx` · binarios).

¿Cómo procedemos?
- **A:** Te pego los docs en este chat · vos los creas en `docs/product/references/`.
- **B:** Los pongo yo en `docs/product/references/` desde mi máquina local · te aviso cuando estén.
```

##### Sub-acción 1.b.2 · Leer docs íntegros

Cuando el user firma A o B y los docs están en `docs/product/references/`:

- **Limpieza WSL2 (idempotente · cero output esperado):** `find docs -name '*:Zone.Identifier' -delete` antes de listar · si el user copió docs desde Windows host, el filesystem conserva archivos `<doc>:Zone.Identifier` adyacentes (`.gitignore` los ignora pero quedan visibles en `ls`).
- `ls docs/product/references/*.md` para listar archivos del user (excluir `README.md`).
- `Read` íntegro de cada uno. **Workaround tool `Read` limit (>25K tokens)** para PRDs grandes: usar `Read offset=0 limit=400` para primera mitad + `Read offset=400 limit=400` para segunda · O `head -200 docs/product/references/PRD.md` para overview rápido + `Read` targeted de secciones clave (vía `grep -nE "^## " docs/product/references/PRD.md` para mapa de secciones primero).
- Identificar contenido por categoría: identidad · stack · constraints del dominio · features core · roadmap por fases · referente del mercado · vocabulario canónico del rubro.
- **Tensión doc ↔ regla firme del flujo → DT en el acto · cero dejarla solo en el chat.** Si la lectura detecta una tensión entre un doc de producto y una regla firme del flujo (ej: PRD con rutas en español vs regla #31 `routing-paths-in-english` · 15 KPIs en un dashboard vs poca-carga de #30 `principios-desarrollo-flujo` · feature complejidad ALTA vs regla #13 `complejidad`), registrala durable como DT en `docs/logs/technical-debt.md` con disparador *"al planificar el módulo afectado"* (el bootstrap no es un PRP → es hallazgo out-of-scope · 8 campos contractuales en la regla #24 [`register-out-of-scope-as-dt`](../../rules/register-out-of-scope-as-dt.md)) · NO editar el PRD para "resolverla" (docs inmutables post-bootstrap). Doctrina: regla #36 [`product-docs-as-bootstrap-sot`](../../rules/product-docs-as-bootstrap-sot.md) § Process.

##### Sub-acción 1.b.3 · Resumen 5-7 bullets + ¿OK?

Emitir resumen al user con shape:

```markdown
📋 **Docs de producto leídos · resumen extraído:**

- **Identidad:** [nombre · dominio · one-liner · founder · magic moment del producto].
- **Stack confirmado:** [frontend · backend · BD · auth · pagos · hosting · tooling según docs].
- **Constraints del dominio:** [multi-tenancy · stock atomicity · BD relacional con migrations · pagos · etc · según docs].
- **Features core (MVP):** [3-5 features clave del PRD].
- **Fases del roadmap:** [si hay `product-roadmap.md` · listar fases · sino "sin roadmap formal · derivar de PRD"].
- **Referente del mercado:** [si docs mencionan competidor/referente · sino "no documentado · planificar sin anchor explícito"].
- **Vocabulario del rubro:** [términos canónicos del dominio que el user usa en el PRD · útiles para `i18n` agent del `/revisar`].

¿OK firmás el resumen? Si **SÍ**, arranco el bootstrap (Pasos 1-7 del README) con los docs como input. Si **NO**, decime qué corregir antes de avanzar.
```

##### Sub-acción 1.b.4 · Arrancar bootstrap mecánico con docs como input

Cuando el user firma OK al resumen, ejecutar los Pasos 1-7 del README (configuración del bootstrap) + el Paso 0.5 del README (push fundacional · materializado acá como acción #8) usando los docs como SoT · cero improvisación · cada llenado de placeholder trazable a contenido del doc fuente. El orden recomendado (paridad README § Checklist de bootstrap):

> **Nota operativa pre-Edit (guard del harness):** cada archivo del template que vas a tocar con `Edit` o `Write` requiere `Read` previo del tool dedicado · si lo inspeccionaste antes solo con `cat` via Bash, NO cuenta para el guard del harness y el primer `Edit`/`Write` va a fallar con *"File has not been read yet"*. Hacer `Read` del tool dedicado antes del primer `Edit`/`Write` sobre cada archivo del template (`CLAUDE.md` · `BUSINESS_LOGIC.md` · `package.json` · `agents-applicability.yml` · `local-ci.sh` · `ci.yml` · `product-roadmap.md` · `deadlines.md` · `log.md`).

1. Reemplazar `<PROYECTO>` en CLAUDE.md línea 1 + sumar one-liner desde el PRD.
2. Llenar BUSINESS_LOGIC.md § 1 Identidad · § 7 Stack · § 8 Constraints del dominio (los 3 constraints del § 8: `multi_tenant` · `stock_atomicity` · `relational_db_with_migrations` · cada uno `yes`/`no` según PRD).
3. Reflejar los 3 constraints del § 8 en `.claude/config/agents-applicability.yml` con el mapeo 1:1 documentado en BUSINESS_LOGIC.md § 8 (ej: `multi_tenant: yes` → `multi-tenant.enabled: yes`) · reemplazar `unknown` por el valor decidido.
4. Actualizar `package.json` scripts del stack real (reemplazar `echo TODO`) + `scripts/local-ci.sh` + `.github/workflows/ci.yml` · al adaptar `local-ci.sh` y `ci.yml`, **limpiar comentarios `TODO` y guías condicionales inline** (ej: `# Si el stack NO tiene BD, eliminar el bloque sql...`) cuando ya tomaste la decisión · cero residuos guía post-adaptación · mantener paridad job order entre ambos archivos.
5. Crear `docs/product/product-roadmap.md` operativo con fases del `product-roadmap.md` de referencia (si vino) O derivado del PRD.
6. Setear fechas iniciales en `docs/logs/deadlines.md` § Activos.
7. Sumar entry `milestone` en `.claude/memory/log.md` referenciando los docs como fuente del bootstrap (los docs todavía están untracked en este punto · van al commit del bootstrap que firma el user en un solo batch con todo el resto de los archivos modificados).
8. **Push fundacional del bootstrap-commit** (única excepción contractual a regla [`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) § Excepción · bootstrap fundacional): al cierre del commit del user, el agente propone (o ejecuta si el user firma) `git push origin dev` + `git push origin dev:dev-backup` para sincronizar las 3 ramas remotas al SHA del bootstrap. Cero CI remoto (workflow `pull_request` only · cero trigger en push) · cero PR · 1 push por proyecto en toda su vida. **Crítico:** los hooks Husky están dormidos hasta TASK-002 (`npm install` activa el script `prepare: husky` del `package.json`) · el backup automático del `post-commit` hook NO va a correr durante el bootstrap · por eso este push manual de las 2 ramas es contractual (sin él, `dev-backup` queda en `Initial commit` y cualquier crash de la máquina antes de TASK-002 pierde el work del bootstrap).

Al cierre · emitir el output template canónico del Paso 5 con estado "bootstrap completado · proyecto listo para primer PRP".

### Paso 2 · Encontrar próxima task pendiente

Leer [`docs/product/product-roadmap.md`](../../../docs/product/product-roadmap.md) y ubicar la primera task con `- [ ]` sin marcar. Capturar ID, título, fase, files y notes.

**Caso "trabajo emergente sin task del roadmap"** (Modo A): si NO hay task pendiente del roadmap O si hay **backlog emergente prioritario** (resultados de `/revisar-main` · `/auditar-dt` · run RM-NNN del lint mensual · cluster de DTs críticas formalizadas), reconocer la fuente como próxima dirección de trabajo · NO ignorar el roadmap pero proponer el backlog emergente si tiene firma 🔵 user previa. Fuentes canónicas a chequear:

- [`.claude/memory/project/rm-NNN-backlog-priorizado.md`](../../memory/project/) — backlog de los runs `/revisar-main` (cluster crítico priorizado · ej RM-NNN backlog `<N> PRPs` firmados).
- `docs/logs/revisar-main-log.md` § último run — findings consolidados del lint mensual (tu proyecto lo genera la primera vez que corras `/revisar-main`).
- Reporte directo del último `/auditar-dt` (memoria de la sesión previa o log si quedó persistido).
- DTs nuevas con severidad `critical` o `bloqueante` en `docs/logs/technical-debt.md` § Activas (filtro: PRP destino "próximo PRP de gobierno" sin asignación firme).

Si hay roadmap task pendiente **Y** backlog emergente, presentar **ambos** al user en el output template (Paso 5) · dejar que el user decida prioridad. Cero asunción silenciosa.

#### Sub-paso 2.b · Anchor de mercado · referente del rubro (regla `heuristica-referente-mercado`)

> **Refinamiento iterativo upstream · materializa regla [`heuristica-referente-mercado.md`](../../rules/heuristica-referente-mercado.md) como gate operativo del boot.** El skill `/arrancar` carga contexto del proyecto · si la próxima task identificada en Paso 2 (o el backlog emergente) **toca decisión de feature / UX / arquitectura del producto**, el agente debe identificar el referente del mercado (descrito en `BUSINESS_LOGIC.md`) y mencionarlo en el output template como **anchor implícito** para la próxima sesión de planificación.

**Cuándo aplica:**

- Próxima task pendiente del roadmap es de tipo **feature** (NO técnica · NO setup · NO test infra). Ej: "TASK-NNN · Agregar módulo de membresías" → aplica · "TASK-NNN · Setup CI remoto" → NO aplica.
- Próxima task tiene **decisión de UX abierta** (modal vs subform · listado plano vs cards · paginación vs scroll · etc).
- La task implica **decisión arquitectónica del producto** (multi-tenancy · pagos · roles · permisos).

**Cuándo NO aplica:**

- Próxima task es trivial técnica (rename · adoption · refactor sin decisión abierta) → cero anchor de mercado · skip.
- Próxima task es PRP del refactor/saneamiento del flujo (esas se rigen por reglas del flujo · NO por mercado).
- `BUSINESS_LOGIC.md` no documenta referente claro · O explícitamente dice "sin referente directo · innovación de nicho" → mencionar "anchor de mercado no documentado · planificar con `decisiones-features` puro".

**Cómo aplicar (1-2 líneas en output template):**

Si aplica · agregar al § Próximo paso recomendado del output template una línea de anchor:

> **Anchor de mercado** (regla `heuristica-referente-mercado`): la task toca [feature / UX / arquitectura] · el referente del rubro identificado en `BUSINESS_LOGIC.md` es **[NOMBRE]** · al planificar (paso 2 del flujo `/planificar`), aplicar las 5 preguntas de la heurística antes de inventar.

Cero análisis profundo del referente acá (eso pertenece a `/planificar` Paso 2 investigación). El skill `/arrancar` solo deja la **bandera levantada** para que la próxima sesión arranque con anchor explícito en lugar de descubrir el sesgo del implementador a mitad del PRP.

### Paso 3 · Verificar PRPs existentes

Glob `.claude/PRPs/*.md` y leer header de cada uno (línea `> **Estado**:`):

- Si hay un PRP en estado **APROBADO** o **EN PROGRESO** sin completar → **priorizarlo** sobre la próxima task del roadmap.
- Si hay un PRP en estado **PENDIENTE** → recordarle al usuario que falta su revisión antes de poder ejecutar.
- Si hay 2+ PRPs en estado APROBADO/EN PROGRESO → reportar inconsistencia.

### Paso 4 · Determinar modo de ejecución (A/B/C)

Aplicar el árbol de decisión de [`WORKFLOW.md` § 5 "Modos A/B/C"](../../../WORKFLOW.md):

- **Modo A · Ejecución directa** → task trivial · bien especificada en el roadmap (con files + notes) · sin decisiones de arquitectura.
- **Modo B · Skill especializado** → la task encaja en un skill ya existente con flujo interno cerrado.
- **Modo C · PRP + Bucle Agéntico (los 6 pasos del flujo)** → feature que requiere PRP firmado. **2 variantes según complejidad** (el agente auto-orienta con heurística + propone con rec early · user firma A/B antes de invocar el skill · override explícito gana siempre):
  - **C-simple → [`/planificar-simple`](../planificar-simple/SKILL.md)** · feature acotada · ≤2 capas tocadas · ≤5 archivos · sin decisiones arquitectónicas abiertas · sin features candidatas múltiples. Ejemplos: refactor mecánico con scope conocido · bug fix con scope >1 archivo pero root cause claro · feature single-layer con DoD binario verificable.
  - **C-complejo → [`/planificar`](../planificar/SKILL.md)** · feature multi-capa · >5 archivos · ≥1 decisión arquitectónica abierta · disparadores: BD + código + UI coordinados · fases dependientes · features candidatas múltiples · UI nueva no trivial.
  - **Heurística firme de auto-orient** (cualquiera de las 4 señales activa → complejo · default si ninguna activa → simple): >2 capas · ≥1 decisión arquitectónica abierta · >5 archivos · complejidad estimada MEDIA o ALTA según regla #13 [`complejidad.md`](../../rules/complejidad.md).
  - **Override explícito del user gana siempre:** si el user dice triggers explícitos de una variante (*"planificá simple"* / *"mini-PRP"* → simple · *"armá un PRP"* / *"planeá esto bien"* → complejo) en el turno de invocación, el agente respeta sin re-proponer ni re-evaluar heurística.
  - **Cero auto-spawn silencioso:** siempre 1 round-trip de firma user A/B antes del Paso 1 del skill elegido · paridad regla #6 [`ante-duda-preguntar-user.md`](../../rules/ante-duda-preguntar-user.md) + regla #2 [`metodologia-iteracion.md`](../../rules/metodologia-iteracion.md) (rec early + user decide).
  - **Gate de escalación mid-skill:** si arrancaste con `/planificar-simple` y aparecen señales de complejidad durante el proceso, el propio skill simple aborta + propone escalar a `/planificar` completo (Paso 2.5 del [`/planificar-simple`](../planificar-simple/SKILL.md) · red defensiva contra invocación equivocada · cero degradación silenciosa de calidad del PRP).

Cruzar con [`WORKFLOW.md` § 7 "Decisiones cerradas sobre el flujo"](../../../WORKFLOW.md) (ej upstream: TASK-NNN → modo C aunque sea auth, porque ya se decidió no usar un skill auth pre-construido del flujo).

### Paso 4.5 · Síntesis pre-recomendación (regla `repaso-features` · refinamiento iterativo upstream)

> **Materializa regla [`repaso-features.md`](../../rules/repaso-features.md) como gate operativo del boot.** Antes de emitir el output template del Paso 5, el agente sintetiza mentalmente lo encontrado en Pasos 1-4 en bloque claro · paridad operativa con el patrón canónico "✅ FEATURE: [nombre] · Decisión core · Modelo · Incluye · NO incluye · Notas técnicas · ¿OK?" pero adaptado a boot (cero feature en discusión · síntesis de estado del proyecto).

**Reglas operativas del Paso 4.5:**

1. **Síntesis obligatoria** antes del output template · cero "tiro la próxima task sin contexto previo".
2. **Bloque sintético cubre 4 ejes** (paridad con el patrón canónico de la regla `repaso-features`):
   - **Estado actual:** roadmap (qué fase · cuántas tasks pendientes) + PRPs activos (cuántos · estado).
   - **Próxima dirección recomendada:** task del roadmap O backlog emergente (con razón 1-frase).
   - **NO incluye en esta sesión:** lo que el agente descarta como próximo paso + razón (ej: "DT-NNN urgente pero requiere PRP separado · próximo PRP toca otro área").
   - **Avisos críticos:** deadlines vencidos · DTs nuevas que cruzan con la próxima task · gotchas detectados durante mapeo silencioso.
3. **Síntesis NO se emite literal al user** (eso sería ruido) · se materializa en el output template del Paso 5 con la estructura fija (Estado del roadmap · Backlog emergente si aplica · PRPs existentes · Próximo paso recomendado · Deadlines · ¿Arrancamos?).
4. **Si la síntesis detecta contradicción** entre fuentes (roadmap dice X · memoria dice Y · DT cruza · etc.) → reportar inconsistencia al user en el output template antes de proponer próximo paso · cero asunción silenciosa.

**Por qué obligatoria (NO opcional):** sin síntesis previa, el output template Paso 5 puede recomendar próximo paso ignorando señales débiles (DT que cruza · deadline que vence · PRP activo no priorizado). La síntesis es el paso intermedio entre "leí 7 archivos" y "te propongo X" · cero saltos.

### Paso 5 · Output template (formato fijo · español neutro LATAM-friendly)

```markdown
## Estado del roadmap
[Listar fases reales del proyecto leídas de `docs/product/product-roadmap.md` · 1 línea por fase con shape "- <Nombre fase> — <descripción corta>: <completed>/<total> completed" · derivar de los headings `## § Fase actual` · `## § Próxima fase` · `## § Backlog` · `## § Cerradas` + tasks `- [ ]` / `- [x]` dentro de cada uno. Si el roadmap está vacío al boot (estado post-template recién bootstrapeado), emitir: "_Roadmap sin fases definidas todavía · llenar `docs/product/product-roadmap.md` con la fase inicial del proyecto_".]

**Próxima task pendiente:** TASK-NNN — [título] · O *"ninguna · roadmap al día"* + indicación de backlog emergente si aplica.

## Backlog emergente (CONDICIONAL · si aplica)
[Solo presente si hay backlog priorizado activo de `/revisar-main` (RM-NNN) · `/auditar-dt` · o cluster de DTs críticas firmadas. Listar con prioridad + DT origen + path al backlog.
 Ejemplo: "RM-NNN backlog · <N> PRPs firmados 🔵 user · próximo: PRP-NNN <descripción-cluster> · ver `.claude/memory/project/rm-NNN-backlog-priorizado.md`"]

## PRPs existentes
[Lista de `.claude/PRPs/` con estado, o "ninguno todavía"]

## Próximo paso recomendado
**Modo [A/B/C]:** [explicación 1 línea]
**Acción concreta:** [ver formato según modo en WORKFLOW.md § 5]

## Deadlines
[Si hay vencimientos ≤7 días o vencidos: "⚠️ DT-NNN · YYYY-MM-DD · <qué hay que hacer>"
 Si NO hay: "Cero deadlines próximos"]

[Si algún deadline activo tiene comando ejecutable en su columna "Qué pasa" Y está vencido o ≤7 días:
 AGREGAR línea de auto-propuesta contractual: "🤖 Auto-propuesta: ¿corro `<comando exacto>` ahora?"
 Cero "esperar a que el user lo pida" · cero "lo dejo para otra sesión".
 Ejemplo: deadline `<YYYY-MM-DD>` ejecutar `bash scripts/archive-log.sh` → auto-propuesta literal en output.]

¿Arrancamos?
```

### Paso 6 · Esperar OK del user

NO ejecutar la próxima task automáticamente. Si el user quiere otra cosa, ajustar.

**Auto-propuesta contractual de deadlines ejecutables (Modo A · paridad regla #20 § Archivado periódico):**

Cuando un deadline activo en [`docs/logs/deadlines.md`](../../../docs/logs/deadlines.md) tiene un comando ejecutable explícito en su columna "Qué pasa" (ej: `bash scripts/archive-log.sh`) Y está vencido o ≤7 días, el agente DEBE proponer activamente la ejecución al user · cero depender de que el user lo recuerde · cero "lo dejo para otra sesión". Cuando el user firma SÍ, el agente ejecuta el comando. Cuando el user firma NO, queda diferido y el aviso re-aparece en la próxima sesión hasta ejecutarse o cambiar de estrategia.

**Identificación de deadlines auto-ejecutables:** la columna "Qué pasa" contiene un comando entre backticks (\`bash scripts/X.sh\` o equivalente) · el agente lo detecta semánticamente y agrega la línea de auto-propuesta en el output template § Deadlines.

**Ejemplos canónicos vigentes:**

- Deadline `<YYYY-MM-DD>` ejecutar `bash scripts/archive-log.sh` (regla #20 § Archivado periódico · cada 14 días).
- Deadline `<YYYY-MM-DD>` ejecutar `bash scripts/lint-memory.sh` (DT-NNN lint mensual de memoria).
- Deadline `<YYYY-MM-DD>` ejecutar `/revisar-main` (DT-NNN lint mensual de código).
- Deadline `<YYYY-MM-DD>` ejecutar `/auditar-dt` (skill `/auditar-dt` · audit mensual de deudas técnicas · cierra trilogía saneamiento mensual con `/revisar-main` (código) y `scripts/lint-memory.sh` (memoria)).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Ya conozco el estado del proyecto · salto la lectura de `log.md` últimas 5 entradas" | NO. `log.md` es la cronología append-only autoritativa de cierres de PRPs · decisiones · incidentes · directional · milestones (regla [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md)). "Ya conozco" es subjetivo · 30s de `grep "^## \[" .claude/memory/log.md \| tail -5` evita recomendar próxima task sobre supuestos viejos. |
| "El user pidió arrancar rápido · salto los archivos canónicos del proyecto" | NO. La carga de contexto **ES** el contrato del skill · sin ella, la recomendación de próxima task es ciega. "Rápido" se gana entregando recomendación correcta a la primera, no saltando lecturas que pesan segundos. |
| "Hay PRP en estado APROBADO pero recomiendo la próxima task del roadmap igual" | NO. PRP en APROBADO o EN PROGRESO **siempre** tiene prioridad sobre la próxima task del roadmap (Paso 3). Saltarse esta regla introduce trabajo en paralelo · rompe "una decisión a la vez". |
| "El roadmap dice TASK-X pero memoria sugiere otra cosa · voy con memoria" | NO. El roadmap es la SoT operativa de tasks pendientes. Si la memoria contradice, **reportar la inconsistencia al user** y esperar OK · no decidir solo. |

## Red flags

- 🚩 Emitís el output template sin haber corrido `grep "^## \[" .claude/memory/log.md | tail -5`.
- 🚩 Recomendás próxima task sin haber chequeado PRPs activos en `.claude/PRPs/` (1+ PRP en APROBADO/EN PROGRESO existe y NO lo priorizaste).
- 🚩 El working tree tiene cambios sin commit (`git status --short` retorna líneas) y NO lo mencionaste al user.
- 🚩 Determinás modo (A/B/C) sin haber cruzado [`WORKFLOW.md § 7 "Decisiones cerradas"`](../../../WORKFLOW.md) (ej upstream: TASK-NNN del proyecto original va modo C aunque parezca modo B).
- 🚩 Output template emitido sin la pregunta final "¿Arrancamos?" — el user no sabe que tiene que firmar antes de que el agente avance.

## Verification

- [ ] **CLAUDE.md NO re-leído** (ya cargado en system prompt automáticamente · evita gastar tokens · fix #4).
- [ ] Los 2 archivos de entrada restantes (BUSINESS_LOGIC.md · WORKFLOW.md) leídos al boot.
- [ ] Las 4 extensiones operativas (MEMORY.md índice · log.md últimas 5 · technical-debt.md · deadlines.md) leídas al boot **con workarounds del tool `Read` limit** cuando exceden 25K tokens (fix #1+#2 · usar `Read limit` · `head` · `sed -n` · `grep` targeted según archivo).
- [ ] Para cada deadline activo, `date -d <fecha> +%s` comparado con `date -d "+7 days" +%s` · output template § Deadlines emitido (con avisos o "Cero deadlines próximos").
- [ ] Para cada deadline activo con comando ejecutable Y vencido o ≤7 días, línea de auto-propuesta contractual agregada al output template § Deadlines (paridad regla #20 § Archivado periódico · cero depender de recuerdo del user).
- [ ] Próxima task del roadmap identificada con ID + título + fase + files + notes · **O backlog emergente** (RM-NNN · `/revisar-main` · `/auditar-dt` · DTs críticas firmadas) reconocido como fuente alternativa si roadmap está al día (fix #3).
- [ ] **Sub-paso 2.b aplicado** cuando próxima task toca decisión de feature / UX / arquitectura del producto: línea de anchor de mercado agregada al § Próximo paso recomendado (referente del rubro identificado en `BUSINESS_LOGIC.md` mencionado · regla [`heuristica-referente-mercado.md`](../../rules/heuristica-referente-mercado.md) como anchor para la próxima sesión de planificación · skip cuando la task es trivial técnica · refactor sin decisión · o no hay referente documentado).
- [ ] **Paso 4.5 síntesis pre-recomendación aplicada** (regla [`repaso-features.md`](../../rules/repaso-features.md)): 4 ejes cubiertos mentalmente antes de emitir output template (Estado actual · Próxima dirección recomendada · NO incluye en esta sesión + razón · Avisos críticos) · contradicciones entre fuentes reportadas al user antes de proponer próximo paso · cero saltos entre "leí 7 archivos" y "te propongo X".
- [ ] PRPs en estado APROBADO/EN PROGRESO listados (o explícitamente "ninguno todavía").
- [ ] Modo (A/B/C) determinado con justificación 1-frase cruzada con [`WORKFLOW.md § 5`](../../../WORKFLOW.md) + [`§ 7`](../../../WORKFLOW.md).
- [ ] Output template emitido con formato fijo (Estado del roadmap · Backlog emergente si aplica · PRPs existentes · Próximo paso recomendado · Deadlines · ¿Arrancamos?) + esperar OK del user antes de ejecutar.
- [ ] **Short-circuit aplicado** cuando la sesión heredó contexto reciente (último commit <30 min) · cero re-lectura de archivos canónicos · pasar directo al Paso 4 (fix #5).
- [ ] **Mapeo silencioso del repo ejecutado como sub-paso final del Paso 1** (consolidación firmada user · 7→6 pasos · paridad cardinalidad con `/revisar` y `/validar` · fix #6).
- [ ] **Sub-paso 1.b.4 paso 8 ejecutado** (post-commit del user del bootstrap): push fundacional `git push origin dev` + `git push origin dev:dev-backup` · las 3 ramas remotas alineadas al SHA del bootstrap-commit · cero CI · cero PR (única excepción contractual a regla [`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) § Excepción · bootstrap fundacional · hooks Husky dormidos hasta TASK-002 `npm install` · sin este push el work del bootstrap queda en limbo local).

**Cross-reference firme:**

- SoT contractual: [`WORKFLOW.md § 3 Paso 1`](../../../WORKFLOW.md) + [`CLAUDE.md`](../../../CLAUDE.md) (boot del flujo · 3 canónicos + 1 extensión operativa que este skill carga).
- Hermana operativa: [`status-tracker-visible.md`](../../rules/status-tracker-visible.md) (al determinar Modo C en Paso 3 · activar tracker visible de los 6 pasos al inicio de cada respuesta principal).
- Hermana operativa: [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) (lectura obligatoria de `technical-debt.md` + `log.md` al boot · ítem 4.6 timing bidireccional de DTs).
- Hermana operativa: [`heuristica-referente-mercado.md`](../../rules/heuristica-referente-mercado.md) (sub-paso 2.b · cuando la próxima task toca decisión de feature/UX/arquitectura · anchor de mercado para la sesión de planificación).
- Refuerza: [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md) (lectura de `log.md` últimas 5 entries al boot · Paso 5 Deadlines lee `deadlines.md` con paridad cadencia mensual).
- Sucesor: skill [`/planificar`](../planificar/SKILL.md) (paso 2 del flujo · activa cuando `/arrancar` propone Modo C con feature compleja).
