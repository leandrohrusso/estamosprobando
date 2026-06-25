# workflow-base · pack genérico para proyectos LLM-asisted

> [!NOTE]
> **Template en estado beta · 0 adopters reales validaron end-to-end todavía.**
>
> El pack se extrajo de un proyecto upstream complejo y la abstracción a "genérico universal" se cerró just-in-time. Los 24 baches estructurales conocidos del inventario inicial están resueltos al 2026-05-25. Pueden persistir baches desconocidos que aparezcan en futuras sesiones adopter · ningún proyecto real validó el end-to-end completo del pack todavía.
>
> **Qué este pack NO garantiza** (expectativa-setting honesta hacia adopters):
>
> - Que el agente se comporte idéntico turno a turno · los LLMs son no-determinísticos por naturaleza · el pack reduce varianza con 37 reglas firmes pero no la elimina.
> - Que el sync template→adopter sea automático · GitHub Templates crea repos sin fork relationship (ver § Gotchas conocidos abajo · procedimiento manual documentado).
> - Que el stack del proyecto adopter sea idéntico al del template · los skills tienen `stack adaptation banner` ⚙️ y el adopter ajusta MCP names + tooling a su realidad.

> [!IMPORTANT]
> **El meta-work del template NO escribe en `.claude/memory/log.md` ni en las memorias project-scoped.** Los commits que mejoran el pack en sí (reglas · skills · scripts · docs de gobierno · este README) son desarrollo del repo upstream · su historia vive en `git log`, NO en `log.md` · que **ships vacío** para que cada adopter arranque su cronología desde cero. Mismo criterio para `.claude/memory/{project,user,reference}/` (vacías al boot) · la única excepción son las 15 memorias seed universales de `feedback/` (gotchas de tooling que aplican a cualquier adopter).
>
> Esta convención aplica **SOLO al desarrollo del template**. En proyectos derivados, `log.md` y las memorias se llenan normalmente al cierre de cada PRP / decisión / hito (regla #20 [`log-chronology-append-only.md`](.claude/rules/log-chronology-append-only.md) + regla #18 [`golden-rule-docs-memory.md`](.claude/rules/golden-rule-docs-memory.md)).

> **Qué es:** pack autocontenido con la **maquinaria del flujo de desarrollo asistido con Claude Code**. Incluye:
>
> - 37 reglas firmes con shape P8.
> - 15 skills (8 del flujo de 6 pasos · variantes simple incluidas · + 7 auxiliares).
> - Memoria persistente versionada con git.
> - Gobernanza (templates `CLAUDE.md` · `WORKFLOW.md` · `BUSINESS_LOGIC.md`).
> - Infra (Husky hooks · GitHub Actions CI · scripts universales · smokes infra-flujo).
>
> **Para qué sirve:** arrancar un proyecto nuevo con sobre un workflow base listo para producción. Cero reinventar el flujo cada vez · cero perder gotchas operativos descubiertos en proyectos previos.
>
> **Inspiración doctrinal:** [Karpathy CLAUDE.md](.claude/references/external-doctrine/karpathy-claude-md.md) (4 principios + ejemplos antes/después · gobierno · cronología append-only) + [Erik Schluntz Vibe Coding](.claude/references/external-doctrine/vibe-coding-schluntz.md) (anclaje filosófico de validación end-to-end + spec-driven) + [Addy Osmani agent-skills](.claude/references/external-doctrine/addyosmani-readme.md) (shape autocontenido P8 + multi-agent paralelo + consolidator).

> **Glosario rápido para este documento:**
>
> - **`Skill`** — función autocontenida del agente invocable con `/<nombre>` (ej: `/arrancar` · `/revisar`). Viven en [`.claude/skills/<nombre>/SKILL.md`](.claude/skills/).
> - **`Shape P8`** — convención de 6 secciones canónicas (Overview · When · Process · Anti-rationalization · Red flags · Verification) que aplican a TODAS las reglas firmes y skills del pack.
> - **`MCP`** — Model Context Protocol · interfaces standardizadas de Claude Code que el harness activa (ej: `mcp__supabase__` · `mcp__playwright__`).
> - **`Agente`** — instancia de Claude que ejecuta un rol específico (ej: 9 agentes paralelos en `/revisar`).
> - **`Consolidator`** — agente final que integra outputs de los N agentes anteriores con checklist común.
> - **`PRP`** · **`DT`** · **`Modo A/B/C`** · **`Bif`** · **`SD-cos`** — definidos en [`.claude/memory/MEMORY.md` § Glosario rápido](.claude/memory/MEMORY.md).

## Cómo usar como GitHub Template

1. Click "Use this template" en la UI de GitHub → "Create a new repository".
2. Cloná el nuevo repo a tu máquina local.
3. Seguí el checklist de bootstrap abajo.

## Pre-requisitos del sistema (1 vez por máquina · pre-clone)

> Antes de clonar el repo, verificá que tu sistema tenga las herramientas que el pack invoca. Son del **sistema** (WSL/Linux/macOS) · NO del proyecto · se instalan **1 vez** y sirven para todos los proyectos derivados del template.

**Comandos requeridos · clasificados por tier:**

| Tier | Comando | Para qué |
|---|---|---|
| 🔴 CRÍTICO | `jq` | Parsear JSON (`package.json` · outputs de `gh` · configs) |
| 🔴 CRÍTICO | `gh` (GitHub CLI) | `/entregar` paso 6 · crear/checkear/mergear PRs |
| 🟡 ALTO VALOR | `shellcheck` | Linter de los scripts bash del pack · auditoría de calidad |
| 🟡 ALTO VALOR | `markdownlint-cli` | Linter de archivos `.md` del pack (reglas · skills · memorias · PRPs · READMEs) |
| 🟡 ALTO VALOR | `yamllint` | Linter YAML general (`agents-applicability.yml` · frontmatter de reglas/skills · etc) |
| 🟡 ALTO VALOR | `actionlint` | Linter específico de `.github/workflows/*.yml` (GitHub Actions) |
| 🟡 ALTO VALOR | `yq` (go-based) | Paralelo a `jq` pero para YAML · parsear `agents-applicability.yml` programáticamente |
| 🟢 NICE TO HAVE | `ripgrep` (`rg`) | Grep 5-10x más rápido en repos grandes |
| 🟢 NICE TO HAVE | `fd` | Paralelo a `rg` pero para búsqueda de archivos · más rápido que `find` |
| 🟢 NICE TO HAVE | `bat` | `cat` con syntax highlighting · útil cuando se muestran archivos al user |
| 🟢 NICE TO HAVE | `git-delta` (`delta`) | Diff viewer mejorado · paridad con `git diff` pero más legible |
| 🟢 NICE TO HAVE | `fzf` | Fuzzy finder · útil para grep interactivo en muchos archivos |
| 🟢 NICE TO HAVE | `tree` | Visualizar estructura de directorios |

**Instalación (Ubuntu/WSL) · 3 pasos:**

```bash
# Pre-requisito: npm instalado (vía nvm o sistema · ver Paso 5 del checklist abajo).

# 1. Paquetes de apt (10 tools).
sudo apt update && sudo apt install -y \
  jq gh shellcheck yamllint ripgrep fd-find bat git-delta fzf tree

# 2. Symlinks para fd y bat (apt los instala como `fdfind` y `batcat` por conflictos · symlink a nombres canónicos).
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
ln -sf "$(which batcat)" ~/.local/bin/bat

# 3. Tools que NO están en apt repos (npm global + binary releases).
npm install -g markdownlint-cli   # sin sudo si usás nvm · con sudo si npm es sistema

# actionlint (binary release · NO en apt):
LATEST=$(curl -sSL https://api.github.com/repos/rhysd/actionlint/releases/latest | jq -r .tag_name | sed 's/^v//')
curl -sSL "https://github.com/rhysd/actionlint/releases/download/v${LATEST}/actionlint_${LATEST}_linux_amd64.tar.gz" -o /tmp/actionlint.tar.gz
tar -xzf /tmp/actionlint.tar.gz -C /tmp actionlint && sudo mv /tmp/actionlint /usr/local/bin/

# yq go-based (la versión apt es Python · distinta · usar binary release de mikefarah/yq):
sudo curl -sSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq
```

**Equivalente macOS (Homebrew · más simple · todo via brew):**

```bash
brew install jq gh shellcheck yamllint actionlint yq ripgrep fd bat git-delta fzf tree
npm install -g markdownlint-cli
```

**Pre-instalados típicamente en Ubuntu/WSL** (cero acción): `git` · `bash` · `grep` · `sed` · `awk` · `find` · `curl` · `cat` · `head` · `tail` · `wc` · `mkdir` · `chmod` · `tee` · `date` · `ls` · `echo` · etc.

**Tools del PROYECTO (NO del sistema · vienen vía `npm install` del `package.json`):** `node` · `npm` · `npx` · `tsc` · `eslint` · `husky` · `lint-staged` · `playwright` · etc. Estos NO se instalan a nivel sistema · cada proyecto los gestiona en su `package.json` (ver Paso 5 del checklist abajo).

## Checklist de bootstrap del proyecto nuevo

> **Leyenda de fase del checklist** · cada paso lleva un badge que indica CUÁNDO ocurre:
>
> - 🟦 **bootstrap-time** — durante la sesión inicial `/arrancar` (sub-paso 1.b · el agente llena los placeholders del template) + tu commit + push fundacional. **Hooks Husky DORMIDOS · CERO `npm install`** (deps vacías salvo `husky` · `node_modules/.bin/husky` todavía no existe).
> - 🟩 **primer-PRP-time** — en la **primera sesión de PRP (Módulo A · Fase 0 · TASK-002)**, NO en el bootstrap. Acá se suman las deps reales + corre `npm install` (que recién acá activa Husky) + se verifican los smokes.
>
> El orden numérico 1→7 NO implica "todo en una sentada": `/arrancar` (Paso 0.4) cubre los pasos 🟦 y **difiere los 🟩 al primer PRP**. Esta separación es la SoT de reglas [#27 `push-and-ci-policy`](.claude/rules/push-and-ci-policy.md) § Excepción bootstrap fundacional y [#36 `product-docs-as-bootstrap-sot`](.claude/rules/product-docs-as-bootstrap-sot.md).

### Paso 0 · Crear el repo nuevo · clonar · ramas · primera sesión

Checklist end-to-end desde la UI de GitHub hasta el primer `/arrancar`. Seguilo en orden:

**0.1 · Crear el repo nuevo desde el template (UI de GitHub)**

Entrá a `https://github.com/leandrohrusso/workflow-base` y click el botón verde **"Use this template" → "Create a new repository"**. Elegí owner + nombre + visibility + descripción · click **"Create repository from template"**. (Alternativa equivalente: botón `+` arriba a la derecha → "New repository" → dropdown "Repository template" → buscar `leandrohrusso/workflow-base` → seleccionar.)

**0.2 · Clonar el repo nuevo a tu máquina local**

```bash
git clone https://github.com/<tu-owner>/<nombre-del-repo-nuevo>.git
cd <nombre-del-repo-nuevo>
```

**0.3 · Crear las ramas `dev` y `dev-backup`**

El flujo asume 3 ramas (`main` viene del template · `dev` + `dev-backup` las creás vos). Crearlas en remote ANTES del primer commit es crítico · sin `dev-backup` el hook `post-commit` falla silently al intentar el backup automático (ver [`.husky/post-commit`](.husky/post-commit)).

```bash
# Crear branch `dev` (rama de trabajo · todos los PRPs viven acá)
git checkout -b dev
git push -u origin dev

# Crear branch `dev-backup` (rama de backup automático del post-commit hook)
git checkout -b dev-backup
git push -u origin dev-backup

# Volver a `dev` para trabajar
git checkout dev
```

**0.4 · Abrir Claude Code y arrancar la sesión inicial** · 🟦 bootstrap-time

Abrí Claude Code en la raíz del repo nuevo y decí: `/arrancar`. El skill detecta el estado "sesión inicial post-template" (BUSINESS_LOGIC.md con placeholders sin llenar · cero PRPs en `.claude/PRPs/` · 1 solo commit) y te guía por los **pasos 🟦 bootstrap-time** abajo (Pasos 1, 1.5 y 3 completos + solo los *scripts* del Paso 2 + roadmap/deadlines/log + commit + push fundacional) · no hace falta seguir el checklist manual mientras el agente te asista. Los **pasos 🟩 primer-PRP-time** (las *deps reales* del Paso 2 · Pasos 4-6 · env config + `npm install` que activa Husky + verificación de smokes) se difieren a la primera sesión de PRP (Módulo A · Fase 0) · **NO corren durante el bootstrap**.

**0.5 · Después del commit del bootstrap · push fundacional manual de las 3 ramas**

Cuando el agente cierra los Pasos 1-7 + vos firmás el commit del bootstrap (mensaje sugerido tipo `chore(bootstrap): adopt workflow-base pack + PRD vN as SoT`), el work del bootstrap vive solo en `dev` local. Necesitás un push manual de las 2 ramas (`dev` + `dev-backup`) para que el remoto las refleje:

```bash
git push origin dev
git push origin dev:dev-backup
```

**Por qué push manual:**

- El hook Husky `post-commit` (que normalmente hace backup automático a `dev-backup`) está **dormido durante el bootstrap** porque `node_modules/.bin/husky` todavía no existe (deps vacías en `package.json` template · `npm install` corre 🟩 en el primer PRP · Módulo A · Fase 0 · TASK-002 · ver Paso 5).
- Sin push manual, las 3 ramas quedan desincronizadas: `dev` local en el bootstrap-commit pero `origin/dev` + `origin/dev-backup` en `Initial commit` · si tu máquina muere antes de TASK-002, perdés TODO el work del bootstrap.
- Este push **NO triggerea CI remoto** (el workflow es `pull_request` event only · cero trigger en push directo a `dev`). Cero PR · cero CI · cero gates. Es **única excepción contractual** a regla #27 [`push-and-ci-policy.md`](.claude/rules/push-and-ci-policy.md) § Excepción · bootstrap fundacional · 1 push por proyecto en toda su vida.
- Una vez TASK-002 cierre (`npm install`) y Husky se active, el hook `post-commit` empieza a hacer backup automático a `dev-backup` post cada commit · este push manual ya NO es necesario para commits posteriores.

### Paso 1 · Llenar `BUSINESS_LOGIC.md` (obligatorio antes del primer PRP) · 🟦 bootstrap-time

Editar [`BUSINESS_LOGIC.md`](BUSINESS_LOGIC.md):

- § 1 Identidad del producto (nombre · dominio · one-liner · founder · magic moment).
- § 7 Stack confirmado (frontend · backend · DB · auth · pagos · hosting · tooling).
- § 8 Constraints no negociables del producto (las decisiones críticas que enmarcan cada PRP).

El skill [`/arrancar`](.claude/skills/arrancar/SKILL.md) lee este archivo en cada boot · si está vacío, el agente NO tiene cómo enmarcar las decisiones del producto.

### Paso 1.5 · Configurar aplicabilidad de sub-agentes domain-tight · 🟦 bootstrap-time

Editar [`.claude/config/agents-applicability.yml`](.claude/config/agents-applicability.yml) y declarar los 3 flags de los sub-agentes domain-tight de [`/revisar`](.claude/skills/revisar/SKILL.md) y [`/revisar-main`](.claude/skills/revisar-main/SKILL.md):

- `multi-tenant.enabled` (`yes` / `no`) — activa si el proyecto es SaaS multi-tenant.
- `atomicity.enabled` (`yes` / `no`) — activa si el proyecto maneja stock · contadores · race conditions sobre BD compartida.
- `migration-safety.enabled` (`yes` / `no`) — activa si el proyecto tiene BD relacional con migrations + RLS policies.

Las decisiones deben matchear los constraints declarados en [`BUSINESS_LOGIC.md § 8 Constraints del dominio que activan sub-agentes`](BUSINESS_LOGIC.md). **Cero dejar flags en `unknown` post-bootstrap.** Si dejás algún flag en `unknown`, `/revisar` y `/revisar-main` van a frenar y pedir firma user **en CADA invocación** hasta que edites este archivo y resuelvas el flag a `yes`/`no`. El mecanismo es self-enforcing · evita defaults silenciosos · la fricción iterativa es deliberada.

Detalle del mecanismo: [`.claude/config/README.md`](.claude/config/README.md) + regla firme #35 [`agents-conditional-by-domain.md`](.claude/rules/agents-conditional-by-domain.md).

### Paso 2 · Llenar `package.json` con los scripts del stack · 🟦 scripts (bootstrap) · 🟩 deps reales (primer PRP)

Editar [`package.json`](package.json) reemplazando los `echo TODO` con los comandos reales:

```json
{
  "scripts": {
    "typecheck": "tsc --noEmit",          // o equivalente del stack
    "lint": "eslint .",                    // o equivalente
    "build": "next build",                 // o equivalente
    "test:unit": "vitest run",             // si aplica
    "test:e2e": "playwright test",         // si aplica
    "ci:local": "bash scripts/local-ci.sh",
    "prepare": "husky"
  }
}
```

**Scripts (🟦 bootstrap-time · ahora):** reemplazá los `echo TODO` con los comandos reales del stack — esto lo hace `/arrancar` en el Paso 2 del bootstrap. **Deps reales (🟩 primer-PRP-time):** sumar las `devDependencies` (`husky` + `lint-staged` + tooling de lint/test/build) y `dependencies` reales se difiere a la primera sesión de PRP (Módulo A · Fase 0), junto con el `npm install` del Paso 5. Durante el bootstrap el `package.json` queda con **deps vacías (solo `husky`)** · por eso los hooks están dormidos hasta entonces.

### Paso 3 · Ajustar `scripts/local-ci.sh` y `.github/workflows/ci.yml` · 🟦 bootstrap-time

Reemplazar los `TODO` con los comandos reales del stack. Mantener invariante de orden entre ambos archivos.

- **Requisitos asumidos:** Git + GitHub (workflow CI corre como `pull_request` event en GitHub Actions). Si usás otro VCS (GitLab · Gitea · Bitbucket), adaptar `.github/workflows/ci.yml` al equivalente de tu CI runner.
- **Sin BD en el stack:** eliminar el job `sql` en AMBOS archivos · ejemplo y guía en los comentarios inline del propio `local-ci.sh` y `ci.yml` (job `sql`).

### Paso 4 · Configurar entorno · 🟩 primer-PRP-time

- Crear `.env.local` y `.env.test` con las vars del proyecto (NO commitear · ya están en `.gitignore`).
- Si usás Supabase u otra DB cloud, crear los projects de TEST y PROD.
- Si usás Vercel, configurar el deployment + variables de entorno.

### Paso 5 · Activar Husky hooks · 🟩 primer-PRP-time

> **⚠️ Esto NO es bootstrap · corre en el primer PRP (Módulo A · Fase 0 · TASK-002 · ver Paso 0.5).** Hasta acá los hooks Husky están **dormidos** (`node_modules/.bin/husky` no existe · deps vacías salvo `husky`). El `npm install` de este paso es el que instala las deps reales y **recién acá activa los hooks** · es el mismo `npm install` que el Paso 0.5 ubica en TASK-002.
>
> **Antes de correr `npm install`:** confirmá que (a) `package.json` § `scripts` ya tiene los comandos reales del stack — `/arrancar` los dejó listos en el Paso 2 🟦 durante el bootstrap, reemplazando los `echo TODO` — y (b) sumaste las deps reales (`husky` + `lint-staged` + tooling de lint/test/build) a `devDependencies`. Con placeholders `echo TODO`, los hooks pasarían trivialmente post-install · falsa sensación de safety. Si los scripts siguen en placeholder, completá el Paso 2 antes de instalar.

```bash
npm ci        # recomendado · reproducible · respeta package-lock.json
# o npm install  # si todavía no hay package-lock.json
# Ambos corren el script `prepare: husky` que activa los hooks de .husky/
chmod +x .husky/*  # garantizar permisos (defensivo · suele estar OK post-clone)
```

### Paso 6 · Verificar smokes verde · 🟩 primer-PRP-time

```bash
bash tests/scripts/infra-flujo/rules-shape-p8.sh
bash tests/scripts/infra-flujo/skills-shape.sh
bash tests/scripts/infra-flujo/husky-hooks-not-degenerated.sh
bash tests/scripts/infra-flujo/skip-ci-not-in-pr-head.sh
```

Los smokes deben pasar verde al boot del pack.

### Paso 7 · Arrancar la primera sesión (primer PRP) · 🟩 primer-PRP-time

Decir al agente principal: `/arrancar`. El skill lee CLAUDE.md + WORKFLOW.md + BUSINESS_LOGIC.md + docs/logs/technical-debt.md, mapea el estado del repo, y propone primer paso en formato Modo A/B/C.

> **Si BUSINESS_LOGIC.md está vacío** (no completaste Paso 1 todavía), el agente lo va a notar y va a guiarte a llenarlo primero · NO es bloqueante · el flujo redirige a "completar identidad del producto" antes de cualquier PRP.

## Qué hace cada carpeta principal

### `.claude/rules/` · 37 reglas firmes con shape P8

Reglas operacionales del flujo · cada una con frontmatter + 6 secciones canónicas (Overview · When · Process · Anti-rationalization · Red flags · Verification). Indexadas en la **tabla canónica de [`CLAUDE.md` § "Reglas FIRMES"](CLAUDE.md)** organizadas en 9 bloques conceptuales (estilo + comunicación · calidad senior · cambios · goal-driven · documentación · estructura · flujo · diseño · stack-tight).

### `.claude/skills/` · 15 skills autocontenidos

- **8 del flujo de 6 pasos** (orden secuencial · típicamente Modo C): `/arrancar` (1) · `/planificar` + `/planificar-simple` (2) · `/implementar` (3) · `/revisar` + `/revisar-simple` (4) · `/validar` (5) · `/entregar` (6). Los pasos 2 y 4 tienen variante `-simple` para scope acotado.
- **7 auxiliares** (triggers explícitos · bajo demanda): `/fatiga` · `/handoff` · `/documentar` · `/memory-manager` · `/auditar-dt` · `/revisar-main` · `/consultor`.

Glosario completo con el rol de cada skill: [`CLAUDE.md` § "Glosario de los 15 skills del pack"](CLAUDE.md). Cada skill lleva **stack adaptation banner** ⚙️ post-frontmatter (los ejemplos asumen Next.js + Supabase + Playwright + GitHub Actions + Husky · el adopter adapta al stack real).

### `.claude/memory/` · sistema de memoria persistente

Inspirado en `llm-wiki` (Karpathy). 4 sub-carpetas + `MEMORY.md` (índice cargado al boot) + `log.md` (cronología append-only · 6 tipos de evento · cero backfill).

- [`feedback/`](.claude/memory/feedback/) — anti-patterns / gotchas universales. **Seed inicial: 15 memorias seed sanitizadas** (6 harness Claude Code · 5 git/CI/GH Actions · 4 meta-flujo del agente).
- [`reference/`](.claude/memory/reference/) — punteros a recursos externos (vacío al boot).
- [`project/`](.claude/memory/project/) — estado vivo de PRPs + handoffs entre sesiones (vacío al boot).
- [`user/`](.claude/memory/user/) — perfil del user / equipo (vacío al boot).
- [`_archive/`](.claude/memory/_archive/) — memorias archivadas (vacío al boot).

Cada sub-carpeta tiene un `_template.md` que el agente copia para crear entries nuevas.

### `.claude/references/external-doctrine/` · snapshots doctrinales inmutables

7 archivos snapshot de la doctrina externa que justifica el pack: Karpathy CLAUDE.md + ejemplos + llm-wiki · Addy Osmani agent-skills · Vibe Coding Schluntz. Trazabilidad histórica · NO se modifican.

### `docs/design/` · flujo de diseño Claude Design (esqueleto · vacío al boot)

Materializa el flujo `PRP → Claude Design → Implementación` de la regla #28 [`claude-design-matrix.md`](.claude/rules/claude-design-matrix.md) en una raíz explícita (input→output del diseño visual). Las sub-carpetas de contenido arrancan vacías · el adopter las puebla conforme cada PRP que toca UI pasa por Claude Design.

- [`handoff/`](docs/design/handoff/) — **input**: briefs que se pegan en una sesión Claude Design + bundles cerrados (inmutables) del proveedor.
- [`reference/`](docs/design/reference/) — **output** curado al repo: [`preview/`](docs/design/reference/preview/) (HTML previews de tokens/componentes en aislamiento) + [`ui_kits/`](docs/design/reference/ui_kits/) (UI kits prototipo · referencia para implementar UI nueva en `src/`).

### `scripts/` · scripts universales del flujo

Scripts bash del flujo: gate local de CI (`local-ci.sh`), re-sync obligatorio `dev`↔`main` post-squash (`sync-dev-after-squash-merge.sh`), archivado periódico de `log.md`, lint de memoria, tests SQL + migraciones, preflight. Inventario y detalle en [`scripts/`](scripts/).

### `tests/scripts/infra-flujo/` · Smokes de invariantes mecánicos

Verifican invariantes que se rompen silenciosamente sin estos smokes:

- `rules-shape-p8.sh` (ABORT) — las 37 reglas mantienen frontmatter + shape P8.
- `skills-shape.sh` (warning) — los 15 skills mantienen shape P8.
- `husky-hooks-not-degenerated.sh` (warning) — los 4 hooks Husky no se degeneran a `exit 0`.
- `skip-ci-not-in-pr-head.sh` (ABORT) — `[skip ci]` no aparece en HEAD del PR (rompería CI silenciosamente).

Ver [`tests/scripts/infra-flujo/README.md`](tests/scripts/infra-flujo/README.md) para detalle + cómo agregar smokes nuevos.

### `.github/workflows/ci.yml` · CI remoto

Política firme **1 push = 1 PR = 1 CI por PRP** (regla #27 [`push-and-ci-policy.md`](.claude/rules/push-and-ci-policy.md)). El workflow NO trigger sobre push (ahorra minutos GH Actions) · solo sobre `pull_request` no-draft. Jobs: typecheck → lint → build → unit + e2e + sql (paralelos) + warnings infra-flujo (`continue-on-error`).

### `.husky/` · 4 hooks Git

- `pre-commit` — typecheck + lint-staged (rápido · solo archivos staged).
- `pre-push` — typecheck + lint full (gate más estricto antes de push).
- `post-commit` — backup automático a `origin/dev-backup` + auto-recovery non-fast-forward post-squash + log de fallos a `.git/post-commit-backup.log`.
- `commit-msg` — valida firma user explícita (`🔵` · `firma user` · `firma 🔵`) en commits que tocan `.claude/config/agents-applicability.yml` (regla #35 defense in depth).

## Trilogía de saneamiento mensual

3 skills/scripts read-only que cierran la red de saneamiento del proyecto · cadencia mensual indexada en [`docs/logs/deadlines.md`](docs/logs/deadlines.md):

| Scope | Comando | Output |
|---|---|---|
| Código | `/revisar-main` (skill) | `docs/logs/revisar-main-log.md` |
| Memoria | `bash scripts/lint-memory.sh` | Reporte + entry `lint` en `.claude/memory/log.md` |
| Deudas técnicas | `/auditar-dt` (skill) | Reporte estructurado · fixes via PRPs nuevos |

`/arrancar` Paso 5 auto-propone ejecución cuando un deadline vence o está ≤7 días.

## Conceptos clave del flujo

- **Modos A/B/C** ([WORKFLOW.md § 5](WORKFLOW.md)) — task trivial (A) · skill cerrado (B) · PRP del producto con bucle agéntico (C).
- **PRP** (Product Requirements Proposal) — documento que cierra el scope ANTES de implementar · firmas 🔵 del user en bifurcaciones arquitectónicas · auditable.
- **DT** (Deuda Técnica) — registro vivo en `docs/logs/technical-debt.md` · cada hallazgo out-of-scope se registra en el acto (regla #24).
- **🔵** — Decisión firmada explícitamente por el user · inmutable hasta que el user explícitamente la revise.
- **Shape P8** — convención de 6 secciones canónicas para reglas y skills (Overview · When · Process · Anti-rationalization · Red flags · Verification).
- **Status tracker visible** — durante sesiones Modo C, el agente mantiene visible el tracker de los 6 pasos al inicio de cada respuesta principal (regla #25).

## Gotchas conocidos del template

| Gotcha | Detalle | Mitigación |
|---|---|---|
| **Child repos NO auto-sync con updates del template** | GitHub Templates crea un repo nuevo con 1 commit inicial · cero fork relationship · cero tracking de upstream. Si el template `workflow-base` mejora (nuevos fixes de reglas · skills · scripts) DESPUÉS de que crearas tu repo, esos cambios NO llegan automáticamente al repo child. | Ver § Sync template→adopter abajo. |
| **WSL2 `:Zone.Identifier` metadata** | Al copiar archivos desde Windows host a WSL2 (`cp /mnt/c/...` o drag-drop desde Explorer), Windows agrega un archivo adyacente `<filename>:Zone.Identifier` con metadata de seguridad. Cero info útil para el repo. | El `.gitignore` del template incluye `*:Zone.Identifier` · cero acción adicional necesaria. Si los archivos ya están untracked, no aparecen en `git status`. |
| **Hooks Husky dormidos hasta TASK-002** | El template viene con `package.json` placeholder (deps vacías) · `npm install` no se ejecutó · `node_modules/.bin/husky` no existe · `git config core.hooksPath .husky/` nunca se aplicó · cero hook corre durante el bootstrap-commit. | El Paso 0.5 del checklist arriba documenta el **push fundacional manual** (`git push origin dev` + `git push origin dev:dev-backup`) como compensación contractual. Una vez TASK-002 cierre con `npm install`, los hooks se activan y el backup automático del `post-commit` empieza a funcionar normal. |
| **`npm install` hace `npm run prepare: husky`** | Si por alguna razón el script `prepare` del `package.json` se modifica o se borra durante el bootstrap, Husky no se activa aunque `npm install` corra. | Verificar después de `npm install`: `grep prepare package.json` debería retornar `"prepare": "husky"` · y `git config core.hooksPath` debería retornar `.husky` (no vacío). |

## Sync template→adopter

GitHub Templates NO crea fork relationship · cero auto-sync. Para traer updates del template a tu repo child:

```bash
git remote add template https://github.com/leandrohrusso/workflow-base.git
git fetch template main
git log HEAD..template/main --oneline   # ver qué cambió en el template
```

Copiá selectivo solo lo **universal** (`.claude/rules/` · `.claude/skills/` · `.claude/memory/feedback/` · `scripts/` · `tests/scripts/infra-flujo/` · `.husky/` · `.github/workflows/`) con `git checkout template/main -- <path>`. **NUNCA pises** tus customizaciones: `BUSINESS_LOGIC.md` · `CLAUDE.md` · `package.json` · `.claude/PRPs/` · `.claude/memory/{project,user,reference}/` · `log.md` · `docs/`. Hacé backup branch antes y corré los smokes de `tests/scripts/infra-flujo/` después.

## Recursos externos

- **Anthropic Claude Code:** <https://claude.com/claude-code>
- **Doctrina del pack en `.claude/references/external-doctrine/`** — Karpathy + Schluntz + Addy Osmani (snapshots inmutables).

## Licencia

MIT — adaptar y reusar libremente.

---

*Pack workflow-base · convención firmada 2026-05-20 · cero hardcode de proyecto origen · listo para "Use this template".*
