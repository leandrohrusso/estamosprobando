# PROYECTO ACTIVO: `PUERTITA`

> **PUERTITA** — SaaS multitenant de ticketing para eventos (B2B2C). Cada organización publica eventos, vende entradas con cobro directo a su cuenta y valida el ingreso por QR desde el celular · sin sobreventa y sin depender del equipo de la plataforma.
>
> **Estado actual del proyecto:** ver [`.claude/memory/log.md`](.claude/memory/log.md) § últimas entradas (`grep "^## \[" .claude/memory/log.md | tail -5`) para cierres de PRPs · decisiones · directional · milestones recientes. Identidad y resumen completo del producto: [BUSINESS_LOGIC.md](BUSINESS_LOGIC.md).

## Punto de entrada: `/arrancar`

Toda sesión arranca acá. El skill [`/arrancar`](.claude/skills/arrancar/SKILL.md) lee 3 archivos canónicos del proyecto + 1 extensión operativa, mapea estado del repo, aplica el protocolo de auto-orient embebido en su § Process, y propone próximo paso al user en formato Modo A/B/C (ver [WORKFLOW.md § 5](WORKFLOW.md)).

### Archivos de entrada del proyecto

**3 canónicos** (lectura obligatoria al inicio de toda sesión):

1. [BUSINESS_LOGIC.md](BUSINESS_LOGIC.md) — qué construimos: identidad del producto · decisiones críticas del producto · mapa de la documentación del proyecto.
2. [WORKFLOW.md](WORKFLOW.md) — cómo construimos: flujo de sesión (6 pasos), modos A/B/C, decisiones cerradas, criterios operativos, mantenimiento periódico.
3. Este archivo — reglas firmes del flujo y del producto · tabla canónica con pointer a cada satélite (shape P8).

**1 extensión operativa** (lectura obligatoria al inicio de toda sesión):

4. [docs/logs/technical-debt.md](docs/logs/technical-debt.md) — deudas técnicas activas por PRP destino. Leer siempre para identificar (a) si es buen momento para corregir alguna DT que cruce con la sesión, y (b) si lo que se va a hacer en la sesión cruza con una DT vinculada (que el agente lo sepa y lo arregle). Actualizar en cada cierre ([REGLA DE ORO ítem 4.6](.claude/rules/golden-rule-docs-memory.md)): si se abrió una deuda → agregar fila; si el PRP la cerró → marcar `✅ Resuelta`.

## Glosario de los 15 skills del pack

> Resumen 1-línea de los 15 skills custom autocontenidos. Detalle completo + triggers conversacionales en [`WORKFLOW.md § 10`](WORKFLOW.md). Cada skill vive en `.claude/skills/<nombre>/SKILL.md` con shape P8.

**6 del flujo de 6 pasos · pasos 2 y 4 con 2 variantes cada uno** (orden secuencial · típicamente Modo C):

| Skill | Rol |
|---|---|
| [`/arrancar`](.claude/skills/arrancar/SKILL.md) | Paso 1 · carga contexto del proyecto + mapea estado del repo + propone próximo paso. |
| [`/planificar`](.claude/skills/planificar/SKILL.md) | Paso 2 · variante **compleja** · genera PRP con bifurcaciones arquitectónicas cerradas por firma 🔵 del user · 4 sub-agentes pre/post-draft. |
| [`/planificar-simple`](.claude/skills/planificar-simple/SKILL.md) | Paso 2 · variante **simple** · genera mini-PRP para scope acotado (≤2 capas · ≤5 archivos · sin decisiones arquitectónicas abiertas) · cero multi-agent · gate de escalación a `/planificar` si aparecen señales de complejidad. |
| [`/implementar`](.claude/skills/implementar/SKILL.md) | Paso 3 · bucle agéntico por fases con checkpoints reversibles + pre-validación regresión heredada. |
| [`/revisar`](.claude/skills/revisar/SKILL.md) | Paso 4 · variante **compleja** · multi-agent code review local del diff (9 agentes Opus paralelos + consolidator + log persistente). |
| [`/revisar-simple`](.claude/skills/revisar-simple/SKILL.md) | Paso 4 · variante **simple** · revisión rápida del diff por el agente principal (≤5 archivos · 1 capa · sin dominios domain-tight tocados) · cero multi-agent · cero log persistente · gate de escalación a `/revisar` si aparecen señales. |
| [`/validar`](.claude/skills/validar/SKILL.md) | Paso 5 · validación exhaustiva con matriz CSV + regression-first FIRME + 100% verde. |
| [`/entregar`](.claude/skills/entregar/SKILL.md) | Paso 6 · `ci:local` 6/6 → push único → CI remoto garantizado → merge `--squash` a `main`. |

**7 auxiliares** (triggers explícitos del user · bajo demanda):

| Skill | Rol |
|---|---|
| [`/fatiga`](.claude/skills/fatiga/SKILL.md) | Auto-evaluación de fatiga DEL AGENTE bajo demanda (invoca regla #9 como SoT). |
| [`/handoff`](.claude/skills/handoff/SKILL.md) | Genera archivo handoff entre sesiones con shape canónico de 7 secciones (invoca regla #26). |
| [`/documentar`](.claude/skills/documentar/SKILL.md) | Aplica REGLA DE ORO docs y memoria al cierre de tasks/fases/PRPs (invoca regla #18). |
| [`/memory-manager`](.claude/skills/memory-manager/SKILL.md) | Sistema de memoria persistente por proyecto: `ingest` · `query` · `lint` · `bulk-ingest`. |
| [`/auditar-dt`](.claude/skills/auditar-dt/SKILL.md) | Audit mensual read-only de deudas técnicas activas cruzadas contra roadmap próximo + PRPs en curso. |
| [`/revisar-main`](.claude/skills/revisar-main/SKILL.md) | Lint mensual de código · multi-agent review holístico del estado completo de `main` (cero diff). |
| [`/consultor`](.claude/skills/consultor/SKILL.md) | Activa rol consultor en sesión paralela read-only (invoca regla #37 como SoT) · cero edits del estado del producto · output dual estructurado/libre · comunicación user-as-bridge con la sesión ejecutora · 1 sesión = 1 rol fijo. |

## Política de pushes y CI runs

> Política firme operativa codificada como satélite [`push-and-ci-policy.md`](.claude/rules/push-and-ci-policy.md). Resumen: **1 push = 1 PR = 1 CI por PRP del producto** · validaciones distribuidas durante el bucle · backup automático post-commit · sync-dev post-squash obligatorio · skip-ci prohibido en HEAD del PR · orden operativo paso 6 evita race con dev server.

Detalle completo + anti-rationalization + verification: ver el satélite. Detalle del flujo de 6 pasos: [WORKFLOW.md § 3](WORKFLOW.md) (descripción de los pasos) + [§ 6](WORKFLOW.md) (política de pushes).

### Infra transversal del flujo

Capa de smoke tests bash que codifican invariantes mecánicos del flujo en [`tests/scripts/infra-flujo/`](tests/scripts/infra-flujo/README.md). Dos canales:

- **Invariantes firmes:** ABORT en job `lint` (ej: `skip-ci-not-in-pr-head.sh`).
- **Operativos:** `infra-flujo-warnings` con `continue-on-error: true` (ej: `husky-hooks-not-degenerated.sh`).

Para sumar smokes nuevos seguir convención del [README de la carpeta](tests/scripts/infra-flujo/README.md) y la regla satélite [`husky-hooks-smoke-tests.md`](.claude/rules/husky-hooks-smoke-tests.md).

## Política de tooling del sistema (propose si falta · NO auto-install)

Si el agente detecta que una herramienta del sistema (WSL/Linux/macOS · NO del proyecto via `npm install`) **NO está instalada** Y su uso mejoraría significativamente al menos uno de · **(a)** velocidad · **(b)** consumo de tokens · **(c)** calidad del output · **(d)** eficiencia operativa · **(e)** evitar workaround silencioso ya fallido · debe **proponer al user instalarla** con justificación 1-frase de la mejora esperada.

**Reglas operativas:**

- **Cero auto-install** · siempre firma user explícita antes de `apt install` / `npm install -g` / binary release.
- **Formato de propuesta:** *"Detecté que `<tool>` no está instalada · si la instalás (`<install command>`) podría `<beneficio concreto>`. ¿La instalamos?"*
- **Cross-ref:** lista canónica de pre-requisitos del pack en [`README.md` § Pre-requisitos del sistema](README.md).

**Origen empírico:** mid-sesión 2026-05-23 · agente improvisó `node -e "JSON.parse(...)"` porque `jq` no estaba instalado · workaround silencioso · costo de tokens evitable con propose explícito.

## Reglas FIRMES — no negociables

El detalle de cada regla vive en su archivo satélite con shape P8 (Overview · When · Process · Anti-rationalization · Red flags · Verification). Esta tabla es la leyenda + pointer al detalle. **37 reglas** total · agrupadas por bloque conceptual para legibilidad · cada fila linkea al satélite con el detalle completo.

> [!IMPORTANT]
> **Referencias históricas en los satélites NO aplican a tu proyecto.** Algunas reglas mencionan PRPs · DTs · fechas (ej: `PRP-049 · 2026-05-19` · `DT-044`) como **contexto de ORIGEN** de la regla en el proyecto upstream donde se codificó. Son documentación de pedigrí ("anti-pattern detectado en sesión X que llevó a codificar esta regla"). Cada regla describe el **principio universal** · la mención del PRP/DT/fecha es solo el "por qué" histórico. Tu proyecto generará sus propias referencias históricas cuando adopte/refine reglas durante un PRP del producto.

### Bloque A · Estilo de trabajo + comunicación

| # | Regla | Pointer | Aplica a |
|---|---|---|---|
| 1 | Estilo de conversación | [`conversation-style.md`](.claude/rules/conversation-style.md) | Patrón progresivo · 2+ decisiones presentadas una por mensaje con recomendación early · brevedad por default · tope blando ~12 líneas · cierres estilo café |
| 2 | Metodología de iteración | [`metodologia-iteracion.md`](.claude/rules/metodologia-iteracion.md) | Estructura SIEMPRE para decisiones · una por vez · brevedad + recomendación + referente del rubro |
| 3 | Decisiones de features una por una | [`decisiones-features.md`](.claude/rules/decisiones-features.md) | Features se deciden UNA POR UNA con el user · cero set cerrado masivo |
| 4 | Repaso de features | [`repaso-features.md`](.claude/rules/repaso-features.md) | Al cerrar feature/sub-feature en discusión iterativa · síntesis antes de la siguiente |
| 5 | Pensar antes de codear | [`think-before-coding.md`](.claude/rules/think-before-coding.md) | Listar asunciones · presentar interpretaciones múltiples · push back con approach más simple |
| 6 | Ante duda preguntar al user | [`ante-duda-preguntar-user.md`](.claude/rules/ante-duda-preguntar-user.md) | Ambigüedad · interpretación múltiple · scope no claro · validación necesaria → preguntar al user con recomendación early · NO improvisar |
| 7 | Cero suposición · siempre fuente de verdad | [`no-suponer-fuente-de-verdad.md`](.claude/rules/no-suponer-fuente-de-verdad.md) | Prohibido suponer · ir a fuente correcta (repo+memoria+MCPs internos · docs oficiales externas) · NUNCA solo memoria del LLM · aplica universal |

### Bloque B · Calidad senior + auto-protección

| # | Regla | Pointer | Aplica a |
|---|---|---|---|
| 8 | Estándar senior profesional | [`quality-standard-senior.md`](.claude/rules/quality-standard-senior.md) | Toda acción del sistema · 6 puntos del estándar · cero excepciones · senior · cero hardcode |
| 9 | Auto-evaluación de fatiga | [`fatigue-self-evaluation.md`](.claude/rules/fatigue-self-evaluation.md) | Stop + aviso al user antes de comprometer calidad por carga de sesión · sub-rule de quality-standard-senior |
| 10 | Siempre fixear todo, con calidad senior | [`always-fix-all-bugs.md`](.claude/rules/always-fix-all-bugs.md) | Bugs detectados en `/ultrareview` · `/validar` · bucle · reportes externos · sin diferir por severidad |

### Bloque C · Cambios + scope + complejidad

| # | Regla | Pointer | Aplica a |
|---|---|---|---|
| 11 | Cambios quirúrgicos | [`surgical-changes.md`](.claude/rules/surgical-changes.md) | Todo diff trazable al request · cero drive-by refactoring · matchear estilo del archivo |
| 12 | Simplicidad primero | [`simplicity-first.md`](.claude/rules/simplicity-first.md) | Mínimo código que resuelve el problema · cero abstracciones especulativas · sin caller real |
| 13 | Complejidad BAJA o MEDIA | [`complejidad.md`](.claude/rules/complejidad.md) | Estimación de complejidad de features · ALTA se descarta, posterga o divide · solo BAJA o MEDIA entran al scope |

### Bloque D · Goal-driven + tests + regresión

| # | Regla | Pointer | Aplica a |
|---|---|---|---|
| 14 | Ejecución goal-driven | [`goal-driven-execution.md`](.claude/rules/goal-driven-execution.md) | Criterios de éxito binarios · loop hasta verificarlos · aplica a fixes y multi-step tasks |
| 15 | Regression-first sobre fix | [`regression-first-on-fix.md`](.claude/rules/regression-first-on-fix.md) | Bugs detectados · caso codificado en `tests/` ANTES del fix · 1-2 filas vecinas |
| 16 | Pre-validación de regresión heredada | [`pre-validation-inherited-regression.md`](.claude/rules/pre-validation-inherited-regression.md) | Antes de Fase 1 del bucle · cruzar archivos del PRP contra `tests/e2e/regression/COVERAGE.md` |
| 17 | Tests como DoD por fase | [`tests-as-dod-per-phase.md`](.claude/rules/tests-as-dod-per-phase.md) | Cada fase del bucle cierra con tests codificados · sin tests = fase no cerrada |

### Bloque E · Documentación + memoria

| # | Regla | Pointer | Aplica a |
|---|---|---|---|
| 18 | REGLA DE ORO docs y memoria | [`golden-rule-docs-memory.md`](.claude/rules/golden-rule-docs-memory.md) | Cierre de tasks/fases/PRPs · checklist 6 ítems indispensable antes de marcar `done` |
| 19 | Lint mensual de memoria | [`lint-memory-periodic.md`](.claude/rules/lint-memory-periodic.md) | Lint mensual `.claude/memory/` · 6 criterios · read-only · reporte + entrada en log.md |
| 20 | Log cronología append-only | [`log-chronology-append-only.md`](.claude/rules/log-chronology-append-only.md) | `.claude/memory/log.md` · 6 tipos de evento · h2 con prefijo `[YYYY-MM-DD] <op>` · cero backfill |
| 21 | Documentos definitivos requieren OK | [`documentos-definitivos.md`](.claude/rules/documentos-definitivos.md) | Avisar al user antes de generar PRD/roadmap/plan formal · esperar OK explícito |
| 36 | Docs de producto como SoT del bootstrap | [`product-docs-as-bootstrap-sot.md`](.claude/rules/product-docs-as-bootstrap-sot.md) | Estado post-template (sesión 1) · `/arrancar` solicita PRD mínimo (opcional `product-vision.md` + `product-roadmap.md`) en `docs/product/references/` antes del llenado mecánico · docs inmutables · sesiones futuras los consultan |

### Bloque F · Estructura del repo + gobierno

| # | Regla | Pointer | Aplica a |
|---|---|---|---|
| 22 | Creación de carpetas con README obligatorio | [`folder-creation-with-readme.md`](.claude/rules/folder-creation-with-readme.md) | Crear carpeta/subcarpeta · validar duplicados + firma user explícita + `README.md` raíz con qué/por qué/para qué · cero creación silenciosa |
| 23 | Respeto a la estructura actual · sesgo anti-creación de carpetas | [`respect-existing-folder-structure.md`](.claude/rules/respect-existing-folder-structure.md) | Estructura actual = baseline · cero carpeta nueva sin justificación + firma user + búsqueda de carpeta existente · sesgo FUERTE anti-raíz · default subcarpeta · NO dumping · complementa #22 |
| 24 | Registrar bug/hallazgo out-of-scope como DT en el acto | [`register-out-of-scope-as-dt.md`](.claude/rules/register-out-of-scope-as-dt.md) | Todo hallazgo out-of-scope (bug · gotcha · asimetría · gap · dead code) → fila en `docs/logs/technical-debt.md` en el acto · 8 campos contractuales · cero excepción |

### Bloque G · Flujo + sesiones

| # | Regla | Pointer | Aplica a |
|---|---|---|---|
| 25 | Status tracker visible | [`status-tracker-visible.md`](.claude/rules/status-tracker-visible.md) | Sesiones en Modo C · tracker de los 6 pasos al inicio de cada respuesta principal |
| 26 | Handoff entre sesiones · shape canónico | [`session-handoff.md`](.claude/rules/session-handoff.md) | Continuidad multi-sesión · cuándo aplica (camino B fatiga firmado · cierre fase 🔴 · user invoca `/handoff` · bloqueo inesperado) · path obligatorio `.claude/memory/project/<scope>-handoff-<YYYY-MM-DD>[-<contexto>].md` · 7 secciones canónicas |
| 27 | Política de pushes y CI runs | [`push-and-ci-policy.md`](.claude/rules/push-and-ci-policy.md) | Cierre paso 6 PRP del producto · 1 push = 1 PR = 1 CI · validaciones distribuidas durante bucle · backup post-commit · sync-dev post-squash · skip-ci prohibido en HEAD del PR |
| 35 | Sub-agentes domain-tight condicionales por dominio | [`agents-conditional-by-domain.md`](.claude/rules/agents-conditional-by-domain.md) | Sub-agentes de skills multi-agente (típicamente `/revisar` y `/revisar-main`) con scope condicional al dominio aplican mecanismo dual: config declarativo `.claude/config/agents-applicability.yml` (opt-in/opt-out por flag) + banner top + early-exit clause en el archivo del agente · cero false positives en proyectos donde el dominio no aplica |
| 37 | Rol consultor read-only en sesión paralela | [`consultor-read-only.md`](.claude/rules/consultor-read-only.md) | Sesiones consultoras activadas explícito por skill `/consultor` o frase-gatillo *"modo consultor"* · contrato hard read-only sobre estado del producto (cero edits aunque firme user) · output dual estructurado/libre · comunicación user-as-bridge con la sesión ejecutora paralela · 1 sesión = 1 rol fijo (cero desactivación mid-sesión) · paridad arquitectónica skill↔regla con `/fatiga`↔#9 · `/handoff`↔#26 · `/documentar`↔#18 |

### Bloque H · Diseño + UX + dominio

| # | Regla | Pointer | Aplica a |
|---|---|---|---|
| 28 | Matriz Claude Design | [`claude-design-matrix.md`](.claude/rules/claude-design-matrix.md) | Decisión de cuándo abrir sesión Claude Design vs primitivos directos del DS |
| 29 | Heurística del referente del rubro | [`heuristica-referente-mercado.md`](.claude/rules/heuristica-referente-mercado.md) | Dudas de diseño/feature/UX · mirar cómo lo hace el referente del rubro primero · copiar approach simplificado |
| 30 | Principios de desarrollo (flujo) | [`principios-desarrollo-flujo.md`](.claude/rules/principios-desarrollo-flujo.md) | 6 principios técnicos generales · menos es más · simplicidad · performance · seguridad |

### Bloque I · Stack-tight (Next + Supabase + Postgres)

> **Estas 4 reglas asumen un stack típico del pack: Next.js (App Router) + Supabase (Postgres + RLS) + Husky hooks.** Si tu proyecto usa otro stack, adaptar los ejemplos del satélite (los principios universales siguen aplicando).

| # | Regla | Pointer | Aplica a |
|---|---|---|---|
| 31 | Routing en inglés industria-estándar | [`routing-paths-in-english.md`](.claude/rules/routing-paths-in-english.md) | Path segments y filenames del framework · siempre en inglés · slugs de usuarios libres · convención universal industria |
| 32 | Migraciones idempotentes | [`migrations-idempotency.md`](.claude/rules/migrations-idempotency.md) | Toda migración bajo `db/migrations/` · `IF NOT EXISTS` · `DROP POLICY IF EXISTS` · etc. |
| 33 | Seeds con UPSERT id fijo | [`seed-upsert-with-fixed-id.md`](.claude/rules/seed-upsert-with-fixed-id.md) | `db/seeds/test/test-seed.sql` · UUIDs fijos + `ON CONFLICT (id) DO UPDATE SET <cols mutables>` |
| 34 | Husky hooks con smoke tests | [`husky-hooks-smoke-tests.md`](.claude/rules/husky-hooks-smoke-tests.md) | Hooks `pre-commit` · `pre-push` · `post-commit` · cambio obliga actualizar smoke test |

### Reglas del producto (`docs/product/references/rules/`)

> **Vacío al boot del pack.** El proyecto define sus reglas firmes específicas del producto (constraints no negociables · vocabulario canónico del rubro · principios del producto · etc) bajo `docs/product/references/rules/<regla>.md` · cada una con shape narrativo (NO obliga shape P8 que es para reglas del flujo). Tabla de pointer aquí cuando aplique. Paridad arquitectónica con `.claude/rules/` (flujo · cómo trabajamos) ↔ `docs/product/references/rules/` (producto · qué construimos).

## Memorias operativas de tooling críticas

> Memorias de [`.claude/memory/feedback/`](.claude/memory/feedback/) que codifican gotchas de tooling **NO** cubiertos por reglas firmes · skills del flujo (`/implementar` · `/validar` · `/entregar`) deben consultarlas al tocar el área correspondiente. Paridad arquitectónica con la tabla de Reglas FIRMES · 1 SoT por gotcha.

> **Seed universal del pack:** la carpeta arranca con **15 memorias seed sanitizadas** (6 harness Claude Code · 5 git/CI/GH Actions · 4 meta-flujo del agente) indexadas en [`.claude/memory/MEMORY.md` § feedback/](.claude/memory/MEMORY.md). **Sumar gotchas que descubras en tu stack** conforme aparezcan (paridad con la tabla canónica de reglas · 1 SoT por gotcha · indexar en MEMORY.md + sumar fila acá si el gotcha es crítico para que el agente lo consulte al tocar un área del codebase).

| Área | Memoria | Cuándo aplica |
|---|---|---|
| _(vacío al boot · llenar conforme descubras gotchas de tu stack)_ | — | — |

## Convenciones · memoria · saneamiento mensual

- **Vocabulario:** definir en [BUSINESS_LOGIC.md](BUSINESS_LOGIC.md) el vocabulario canónico del rubro del producto (UI / copy / términos del mercado) + naming técnico (tablas, campos, endpoints). El agente `i18n` del skill [`/revisar`](.claude/skills/revisar/agents/i18n.md) verifica consistencia.
- **Memoria persistente** ([`.claude/memory/`](.claude/memory/)): `feedback/` (anti-patterns y gotchas universales) · `reference/` (punteros a recursos externos) · `project/` (estado vivo de PRPs y handoffs entre sesiones) · `user/` (perfil del user · stack · preferencias) · índice en [`MEMORY.md`](.claude/memory/MEMORY.md) · cronología append-only en [`log.md`](.claude/memory/log.md). Templates por sub-carpeta en `<sub>/_template.md`.
- **Workspace gitignored del meta-work del template:** ver [`.claude/_workspace/README.md`](.claude/_workspace/README.md) · convención + regla firme workspace-only + test mental crítico + anti-rationalization + smoke que lo defiende mecánicamente (Bloque K de `fresh-install-canonical-state.sh`). Aplica SOLO al meta-work del template · en proyectos derivados los handoffs siguen viviendo en `.claude/memory/project/` (regla #26).
- **Trilogía de saneamiento mensual:** 3 skills/scripts read-only que cierran la red de saneamiento del proyecto · cadencia mensual indexada en [`docs/logs/deadlines.md`](docs/logs/deadlines.md) · `/arrancar` Paso 5 auto-propone cuando el deadline vence o ≤7 días.
  - [`/revisar-main`](.claude/skills/revisar-main/SKILL.md) — lint mensual de **código** · auditoría holística del estado completo de `main` · 9 agentes Opus paralelos + consolidator · log en `docs/logs/revisar-main-log.md`.
  - [`scripts/lint-memory.sh`](scripts/lint-memory.sh) — lint mensual de **memoria** · 6 criterios · read-only · reporte + entry tipo `lint` en `.claude/memory/log.md`.
  - [`/auditar-dt`](.claude/skills/auditar-dt/SKILL.md) — audit mensual de **deudas técnicas** · cruza DTs activas contra roadmap próximo + PRPs en curso · clasifica en 3 baldes (urgentes vs latentes vs obsoletas) + recomendación accionable · cero side effects.
- **NO correr `/init`** en este proyecto · ese skill genera un `CLAUDE.md` nuevo desde cero y va a pisar TODO el contenido del pack · si la idea es regenerar, hacer backup completo primero (`cp CLAUDE.md CLAUDE.md.backup`).
