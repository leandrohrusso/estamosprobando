# Memoria del Proyecto — Índice

> Archivos organizados por carpeta (tipo). Índice mecánico · entries cortos con link markdown.
> Gestionado por skill [`/memory-manager`](../skills/memory-manager/SKILL.md). Auto-memory de Claude Code DESACTIVADO en favor de esta memoria por-proyecto versionada con git.
> Última actualización: <YYYY-MM-DD del proyecto>.

## Glosario rápido (jerga interna usada en entries)

Convenciones del pack workflow-base. Para sesiones nuevas:

- **`PRP-NNN`** — Product Requirements Proposal (ver `.claude/PRPs/`). Documento que cierra el scope antes de implementar.
- **`DT-NNN`** — Deuda Técnica (registro vivo en `docs/logs/technical-debt.md`).
- **`🔵`** — Decisión firmada explícitamente por el user (tag firme, inmutable). Se usa al pie de bifurcaciones arquitectónicas cerradas con el user.
- **`Modo A / B / C`** — Modos del flujo de 6 pasos definidos en [`WORKFLOW.md § 5`](../../WORKFLOW.md). Modo A = task trivial · Modo B = skill cerrado · Modo C = PRP del producto con bucle agéntico.
- **`Bif N = X`** — Bifurcación arquitectónica firmada por el user con opción X (A/B/C). Aparece en PRPs y en handoffs entre sesiones.
- **`SD-cos N`** — Sub-decisión cosmética (NO arquitectónica) cerrada por el agente con justificación 1-frase. Trazable en el PRP.
- **`<op>`** — Tipo de evento en `log.md` (1 de 6: `prp-close` · `decision` · `incident` · `directional` · `milestone` · `lint`). Ver regla #20 [`log-chronology-append-only.md`](../rules/log-chronology-append-only.md).
- **`DoD`** — Definition of Done (Agile). Criterios de aceptación binarios y verificables que cierran un paso del flujo o una fase del bucle agéntico.
- **Severidad de bug · `critical` · `normal` · `nit`** (equivalentes visuales 🔴 · 🟡 · 🟢) — escala canónica para clasificar findings de `/revisar` · `/validar` · `/ultrareview` por **impacto en el sistema/usuarios**. Aplica a la regla [`always-fix-all-bugs.md`](../rules/always-fix-all-bugs.md) (los 3 niveles se cierran antes del merge).
- **`Confidence: high | medium | low`** (output de los 9 agentes Opus de `/revisar` y `/revisar-main`) — escala **PARALELA y DISTINTA** a severidad de bug · clasifica la **confianza del agente detector en su propio finding** (qué tan seguro está el agente de que lo que reportó es realmente un bug). NO es severidad · NO es impacto · es certeza epistémica. Un finding puede ser `critical · low confidence` (bug grave pero el agente NO está seguro · necesita validación humana antes de fixear) o `nit · high confidence` (detalle menor pero el agente está seguro). Las 2 escalas conviven en cada finding sin solaparse · son ortogonales y deliberadas.

> **Adaptar al proyecto:** sumá acá tu jerga propia (etiquetas de PRPs · nomenclatura de fases · alias internos). Cero abreviaturas sin entry en el glosario.

## log.md — Bitácora cronológica del proyecto

- [Chronology append-only](log.md) — eventos significativos en formato `## [YYYY-MM-DD] <op> | <título corto>` + Resumen / Detalle / Refs. Append-only · cero backfill. Consulta: `grep "^## \[" .claude/memory/log.md | tail -N`. Agregar entrada al cierre de cada PRP · decisión arquitectónica · incidente · pivote · hito · lint mensual.

## user/ — Sobre el user / equipo

> **Cuándo crear entry:** cuando aprendés sobre el user (rol · stack · preferencias · responsabilidades · conocimiento previo).

- _(vacío al boot · llenar con perfil del user del proyecto)_

## project/ — Estado vivo de PRPs · decisiones activas · handoffs

> **Cuándo crear entry:** PRPs en curso · checkpoints multi-sesión · handoffs entre sesiones · decisiones arquitectónicas activas · estado de migraciones grandes.

- _(vacío al boot · llenar conforme arrancan PRPs)_

## feedback/ — Anti-patterns · correcciones · gotchas universales

> **Cuándo crear entry:** correcciones del user · gotchas descubiertos · patrones que afectan código futuro. Cero captura de cosas ya en git/código.

### Seed universal del pack workflow-base (15 memorias sanitizadas)

**Harness Claude Code (gotchas del tooling LLM):**

- [Tool `Read` límite ~25K tokens · workaround canónico](feedback/read-tool-token-limit-workaround.md) — archivos crecidos del repo se leen con `Read offset/limit` · `head -N` · `sed -n 'A,Bp'` · `grep` targeted. NUNCA leer entero al boot un archivo grande.
- [Bash tool 10 min timeout + classifier auto-mode interpreta "NO" literal](feedback/bash-tool-timeout-and-classifier-boundary.md) — tareas largas (>10 min) usar `nohup ... &` shell-level + watcher · classifier auto-mode puede denegar legítimo si el "NO" se interpreta scope-totalizado.
- [`tail -N` con `run_in_background` produce buffer 0 bytes hasta EOF](feedback/tail-N-buffer-in-background-tasks.md) — `cmd | tail -N` solo emite cuando recibe EOF · para monitor progresivo redirect a archivo regular + `tail -f` después.
- [Race condition `ci:local` ↔ dev server typecheck](feedback/dev-server-typecheck-race-during-ci-local.md) — el dev server del framework regenera schemas tipados (TS) mientras corre · si el hook pre-commit/pre-push hace typecheck a medio camino · rompe con error opaco. Workaround: commit+push ANTES de arrancar `ci:local`.
- [PRPs grandes acumulan comment noise (banners + JSX narration)](feedback/comment-noise-bulk-cleanup.md) — durante bucles agénticos largos, tendemos a escribir banners + comentarios obvios. Auto-contención durante el bucle previene cleanup masivo en paso 4.
- [Install de tools del sistema · preferir binary release sobre curl-pipe-bash](feedback/system-tool-install-prefer-binary-over-curl-pipe-bash.md) — `bash <(curl ...)` y `curl ... | bash` los deniega el classifier auto-mode como "Code from External" · usar binary release directo (curl + tar + mv) o gestor nativo (apt/brew) · más seguro · más auditable · classifier-friendly.

**Git / CI / GitHub Actions (gotchas del flujo de entrega):**

- [`squash-merge` deja `dev` divergente de `main` · próximo CI bloqueado](feedback/squash-merge-dev-divergence.md) — cada `gh pr merge --squash` requiere `bash scripts/sync-dev-after-squash-merge.sh` inmediato · sin él, próximo PRP debugea horas el "por qué CI no arranca".
- [`[skip ci]` en HEAD del PR bloquea trigger CI remoto](feedback/skip-ci-blocks-pr-head.md) — GitHub skipea TODOS los eventos si el HEAD commit subject tiene `[skip ci]` · la política "1 CI por PRP" se rompe silenciosamente. NO usar `[skip ci]` en el último commit del paso 6.
- [`git mv` + Edit sobre archivo renombrado pierde el header en commit](feedback/git-mv-plus-edit-staging.md) — rename queda staged + edit unstaged · lint-staged hace `stash --keep-index` y se lleva el edit. Workaround: re-stagear explícito post-Edit.
- [`sync-dev-after-squash` destruye commits locales no pusheados a `main`](feedback/sync-dev-after-squash-destroys-unpushed-local-commits.md) — si commiteás sobre `dev` post-merge `--squash` antes de correr el sync script, esos commits se pierden del backup remoto. Script ahora ABORTA si detecta `origin/main..dev > 0`.
- [Hooks que ejecutan en background con `--quiet` deben loguear fallos](feedback/post-commit-hook-must-log-failures.md) — `--quiet 2>&1 >/dev/null` esconde fallos silenciosamente. Regla derivada: SIEMPRE loguear fallos a `.git/<hook>.log` con timestamp + SHA + razón.

**Meta-flujo (cómo trabaja el agente):**

- [Respuestas claras, breves, sin tecnicismos](feedback/short-responses-no-tech-jargon.md) — preferencia firme: lenguaje accesible, párrafos cortos, tecnicismos solo cuando son inevitables. Listas con recomendación early. Cero docs densos como respuestas conversacionales · cubre solo brevedad/lenguaje claro · ver [`conversation-style.md`](../rules/conversation-style.md) para regla completa (patrón progresivo · tope ~12 líneas · cierres canónicos · tablas).
- [Estimaciones de ritmo/escala basadas en datos reales · cero heurísticas](feedback/estimations-must-be-based-on-real-data.md) — toda estimación de cadencia/threshold debe verificarse con `grep | awk | wc | date` ANTES · subestimar por órdenes de magnitud calibra decisiones arquitectónicas mal.
- [Operaciones bulk del agente (≥10 archivos) requieren firma user previa](feedback/bulk-auto-fix-needs-pre-signature.md) — auto-fix de linters · prettier --write · bulk rename · regex masivo · cualquier batch ≥10 archivos exige plan al user + firma explícita ANTES de ejecutar. Cero "fix masivo silencioso". Recovery con 3 opciones (revertir · mantener · híbrido) si ya pasó.
- [`markdownlint --fix` puede romper listas numeradas con semántica](feedback/markdownlint-fix-breaks-semantic-lists.md) — MD029 renumera silenciosamente listas `4.` semánticas a `1.` · NUNCA correr `--fix` sin diff post-fix + revisión manual. Si hay listas semánticas, deshabilitar MD029 en `.markdownlint.json` ANTES de ejecutar.

**Testing / e2e (descubiertos en el proyecto):**

- [Playwright `getByLabel` matchea por substring → colisiona con aria-labels superstring](feedback/playwright-getbylabel-substring-collision.md) — `getByLabel('Rol de X')` sin `{exact:true}` matchea el `<select aria-label="Rol de X">` Y su botón hermano `"Guardar rol de X"` (superstring) → strict-mode violation. Detectado en `/validar` PRP-002 (CRUD miembros post-LR-002 onChange→submit). Usar `{exact:true}` o acotar por rol cuando dos accessible names comparten stem.

## reference/ — Punteros a recursos externos

> **Cuándo crear entry:** info viva fuera del repo (Linear · Slack · Grafana · docs externas · MCPs · servicios cloud).

- [Stack versions PRP-001](reference/stack-versions-PRP-001.md) — versiones exactas del stack instaladas en el scaffold (Next 16.2.9 · React 19.2.7 · Tailwind v3.4.19 · eslint 9 no 10 por compat de plugins · TS 6.0.3 · @types/node 20 alineado a CI) verificadas contra registry. TASK-002+ heredan este set.

## _archive/ — Memorias archivadas

> **Cuándo mover:** entry obsoleta · superseded por otra · contexto histórico que sobrevive pero NO se carga al boot.

- _(vacío al boot)_
