# `.claude/skills/` · Skills del flujo (paridad pack universal)

> **Qué es:** carpeta de los 15 skills universales del pack workflow-base. Cada subcarpeta es un skill autocontenido con `SKILL.md` (shape canónico P8) + opcionalmente sub-agentes en `agents/` + `consolidator.md` (para skills multi-agente) + `references/` (para skills que necesitan templates auxiliares).
>
> **Por qué se creó:** materializar el flujo de 6 pasos + skills auxiliares para que un proyecto nuevo lo invoque directamente. Sin esta carpeta, el agente del proyecto nuevo no tiene cómo ejecutar el flujo · solo tiene la doctrina (`CLAUDE.md` + `WORKFLOW.md` + reglas) sin ejecutores concretos.
>
> **Para qué sirve:** invocación de skills desde el agente principal vía Skill tool · cada skill define qué hace · cuándo aplica · cómo ejecuta · qué verifica al cierre.

## Convención

- **Naming:** kebab-case en español · 1-2 palabras · `<accion>` (ej: `implementar.md` · `revisar.md`).
- **Shape P8 obligatorio en cada `SKILL.md`:** Overview · When · Process · Anti-rationalization · Red flags · Verification + frontmatter (`name` · `description` · `allowed-tools`).
- **Stack adaptation banner:** los 7 skills del flujo principal (`arrancar` · `planificar` · `implementar` · `revisar` · `validar` · `entregar` · `revisar-main`) + las 2 variantes simple (`planificar-simple` · `revisar-simple`) llevan banner ⚙️ inmediato post-frontmatter que avisa al lector: *los ejemplos del cuerpo asumen Next.js + Supabase + Playwright; adaptá MCP names + patrones + tooling a tu stack*.
- **Sub-agentes en `agents/`:** los skills multi-agente (`/revisar` · `/revisar-main` · `/planificar`) tienen sub-agentes cada uno en su `.md` con foco no-superpuesto + `consolidator.md` (cuando aplica) que sintetiza outputs.
- **References en `references/`:** los skills que necesitan templates auxiliares (`/validar` con `canonical-groups.md` + `credentials-template.json` + `regression-heuristics.md`) los alojan en `references/` del propio skill.

## Los 15 skills del pack

### 6 skills del flujo de 6 pasos (orden estricto · pasos 2 y 4 con 2 variantes cada uno)

| Paso | Skill | Rol |
|---|---|---|
| 1 | [`arrancar`](./arrancar/SKILL.md) | Contexto · carga del estado del proyecto al inicio de sesión + propone próximo paso Modo A/B/C (C-simple vs C-complejo) |
| 2 | [`planificar`](./planificar/SKILL.md) | Planificación variante **compleja** · genera PRP con bifurcaciones firmadas por el user · 4 sub-agentes pre/post-draft |
| 2 | [`planificar-simple`](./planificar-simple/SKILL.md) | Planificación variante **simple** · mini-PRP para scope acotado (≤2 capas · ≤5 archivos · sin decisiones arquitectónicas abiertas) · cero multi-agent · gate de escalación a `/planificar` mid-skill |
| 3 | [`implementar`](./implementar/SKILL.md) | Implementación · bucle agéntico por fases con DoD por fase + commit local por fase |
| 4 | [`revisar`](./revisar/SKILL.md) | Revisión variante **compleja** · 9 sub-agentes Opus paralelos + consolidator + log persistente · paso pre-merge gate-keeper |
| 4 | [`revisar-simple`](./revisar-simple/SKILL.md) | Revisión variante **simple** · agente principal lee diff directo + checklist compacto 5 ítems universales (correctness · security · tests · simplicity-first · surgical-changes) · cero multi-agent · cero log · gate de escalación a `/revisar` mid-skill |
| 5 | [`validar`](./validar/SKILL.md) | Verificación · matriz CSV exhaustiva + Playwright MCP + 100% verde como criterio binario |
| 6 | [`entregar`](./entregar/SKILL.md) | Entrega · `ci:local` 6/6 + push único + decisión `/ultrareview` + merge `--squash` a main |

### 7 skills auxiliares

| Skill | Rol |
|---|---|
| [`fatiga`](./fatiga/SKILL.md) | Auto-evaluación de fatiga del agente bajo demanda · invoca regla #9 como SoT |
| [`handoff`](./handoff/SKILL.md) | Generar handoff entre sesiones · invoca regla #26 como SoT · 7 secciones canónicas |
| [`documentar`](./documentar/SKILL.md) | Aplicar REGLA DE ORO docs y memoria bajo demanda · invoca regla #18 como SoT |
| [`memory-manager`](./memory-manager/SKILL.md) | Sistema de memoria persistente del proyecto · 4 sub-comandos (`ingest` · `query` · `lint` · `bulk-ingest`) |
| [`auditar-dt`](./auditar-dt/SKILL.md) | Audit mensual read-only de deudas técnicas activas · cierra trilogía de saneamiento mensual |
| [`revisar-main`](./revisar-main/SKILL.md) | Multi-agent code review holístico del estado de `main` · paridad arquitectónica con `/revisar` pero scope holístico |
| [`consultor`](./consultor/SKILL.md) | Activar rol consultor en sesión paralela read-only · invoca regla #37 como SoT contractual · cero edits del estado del producto · comunicación user-as-bridge con la sesión ejecutora paralela · 1 sesión = 1 rol fijo |

## Cómo se invocan

Los skills se invocan desde el agente principal vía la herramienta `Skill` (si está habilitada en el harness Claude Code del proyecto) o desde la entrada del user con el prefijo `/` (ej: `/arrancar` · `/implementar`). La descripción de cada skill en el frontmatter declara los **triggers conversacionales** que activan la invocación (ej: *"arrancá"* · *"dame contexto"* · *"qué tenemos"* disparan `/arrancar`).

## Cómo adaptar el pack a tu stack

1. **Lee cada SKILL.md** con su banner ⚙️ de Stack adaptation.
2. **Editá el frontmatter `allowed-tools`** para listar los MCPs disponibles en tu proyecto (Supabase MCP genérico · DB MCP propietario · Vercel MCP · Sentry MCP · etc) en lugar de los placeholders del template.
3. **Reemplazá ejemplos concretos** en el cuerpo (`Server Action` · `RLS policy` · `revalidatePath` · `gh pr merge`) por los equivalentes de tu stack.
4. **Renombrá agentes** del skill `/revisar` (ej: `migration-safety.md` → `<tu equivalente>` · si tu stack no es SQL puro, podés sustituir por agentes específicos del tipo de migración que usás).
5. **Llená los TODOs** del `package.json` template + `scripts/local-ci.sh` template + `.github/workflows/ci.yml` template del root del repo con los comandos concretos del proyecto.

## Cómo agregar un skill nuevo

1. **Validar duplicados:** ¿hay skill existente que ya cubre el patrón? Si SÍ, extender.
2. **Naming canónico:** kebab-case en español · descriptivo · 1-2 palabras.
3. **Shape P8:** copiar plantilla de skill existente (ej: `fatiga/SKILL.md` para skills cortos · `implementar/SKILL.md` para skills largos) · 6 secciones + frontmatter.
4. **Decidir multi-agente o monolítico:** si requiere foco no-superpuesto en ≥3 dimensiones, considerar sub-agentes en `agents/` + `consolidator.md`.
5. **Wiring CLAUDE.md / WORKFLOW.md:** si el skill es parte del flujo de 6 pasos, sumar entrada al glosario de skills de `WORKFLOW.md § 10`.
6. **Verificación:** correr smokes de la carpeta `tests/scripts/infra-flujo/` (`skills-flujo-shape.sh`) que verifica shape canónico de los skills del flujo.

## Inspiración doctrinal

Los snapshots fuente externos que justifican la arquitectura de los skills viven en [`.claude/references/external-doctrine/`](../references/external-doctrine/):

- **Karpathy CLAUDE.md** + ejemplos antes/después + llm-wiki (gobierno · cronología · self-evaluation).
- **Addy Osmani agent-skills** (shape autocontenido · multi-agent paralelo · consolidator).
- **Vibe Coding Schluntz** (anclaje filosófico de validación end-to-end + spec-driven development).

## Doctrina estructural compartida

> **SoT canónica** de la doctrina común a los skills derivados de [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills) · snapshots locales en [`addyosmani-readme.md`](../references/external-doctrine/addyosmani-readme.md) + [`addyosmani-agents.md`](../references/external-doctrine/addyosmani-agents.md). Cada SKILL.md vincula a esta sección + agrega sus refinamientos específicos.

**Convención común:**

- **Cero copia textual** · adaptación al proyecto (no reproducir verbatim la fuente).
- **Shape P8** · 6 secciones canónicas (Overview · When · Process · Anti-rationalization · Red flags · Verification) en cada `SKILL.md`.
- **Skill autocontenido** · cero dependencia runtime de doctrina externa · el SKILL.md ejecuta sin abrir la fuente.
- **Cita inline a doctrina** · cuando se deriva una decisión arquitectónica de la fuente (ej: mapeo SD-XX · persona específica de addyosmani-agents) se cita en el lugar concreto del SKILL.md.

**Skills que aplican esta doctrina:** [`arrancar`](./arrancar/SKILL.md) · [`planificar`](./planificar/SKILL.md) · [`implementar`](./implementar/SKILL.md) · [`revisar`](./revisar/SKILL.md) · [`validar`](./validar/SKILL.md) · [`entregar`](./entregar/SKILL.md).

---

*Convención de README firmada upstream (regla [`folder-creation-with-readme.md`](../rules/folder-creation-with-readme.md)).*
