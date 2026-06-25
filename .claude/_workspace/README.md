# `.claude/_workspace/` · Workspace gitignored para WIP del agente

> [!WARNING]
> **Aplica SOLO al meta-work del template** (mejoras al pack `workflow-base` mismo). Si clonaste `workflow-base` como template para tu proyecto, esta carpeta NO te aplica · ignorala (queda ahí silenciosa · cero impacto en tu workflow del proyecto). Tu trabajo va por los canales canónicos del proyecto: handoffs en `.claude/memory/project/` (regla #26) · memorias en `.claude/memory/feedback/` · PRPs en `.claude/PRPs/` · etc. Detalle del scope + cuándo NO aplica + excepciones: ver § "Regla firme · workspace-only para meta-work del template" abajo.

> **Qué es:** carpeta gitignored para artefactos work-in-progress que el agente genera durante el trabajo en el repo del template mismo (handoffs entre sesiones · drafts de planes · scratchpads de análisis · outputs efímeros · cualquier cosa que NO debe viajar al template público).
>
> **Por qué se creó:** cuando se hace meta-work del template (mejoras al pack workflow-base mismo), el agente genera artefactos de continuidad multi-sesión (típicamente handoffs siguiendo regla #26 [`session-handoff.md`](../rules/session-handoff.md)) que son útiles localmente pero NO deben commitearse al repo del template (cualquier proyecto derivado heredaría polución). Sin esta carpeta, esos artefactos terminaban accidentalmente commiteados en `.claude/memory/project/` y requerían cleanup post-facto. Esta carpeta + gitignore + smoke proveen defensa pre-facto: convención positiva del "dónde va el WIP".
>
> **Para qué sirve:** (a) el agente tiene path explícito + contractual donde escribir artefactos efímeros · cero ambigüedad cada vez · (b) el user ve todos los WIPs en un solo lugar separados de los artefactos canónicos del template · (c) `git status` nunca los reporta · (d) el smoke `fresh-install-canonical-state.sh` verifica que `git ls-files` retorne solo el `README.md` (cero archivos efímeros commiteados por error).

## Regla firme · workspace-only para meta-work del template

> **Cuando se trabaja en el meta-work del template (mejoras al pack workflow-base mismo · cwd = repo del template), TODO archivo work-in-progress del agente DEBE ir EXCLUSIVAMENTE a `.claude/_workspace/`. PROHIBIDO crear archivos efímeros en cualquier otra ubicación del repo (`.claude/memory/feedback/` · `.claude/memory/project/` · `.claude/memory/reference/` · `.claude/memory/log.md` · `docs/logs/*` · `.claude/PRPs/` · etc), salvo si son artefactos canónicos contractuales del pack que aportan valor permanente a futuros adopters.**

**Por qué firme:** la convención positiva ("WIP va a `_workspace/`") sin la prohibición negativa explícita ("WIP NO va a ninguna otra parte") deja espacio para que el agente racionalice caso por caso ("esto parece importante · va a memory/feedback/"). La regla absoluta elimina la ambigüedad: el agente NO decide cada vez, sigue una regla firme. El smoke `fresh-install-canonical-state.sh` defiende mecánicamente post-facto · esta regla codifica la doctrina pre-facto que el agente lee al iniciar sesión.

**Cuándo aplica:**

- Sesiones de mejora del pack workflow-base mismo (auditorías · refinamientos · features nuevas del pack · expansión de smokes · debugging del template · etc).
- Detección operativa: cwd termina en `/workflow-base/` (o el repo del template tiene placeholder `<PROYECTO>` en CLAUDE.md + 0 PRPs reales + 0 product docs · paridad 5 chequeos del sub-paso 1.b del `/arrancar`).

**Cuándo NO aplica:**

- Trabajo en un proyecto derivado del template (los proyectos derivados usan los canales canónicos: handoffs en `memory/project/` · memorias en `memory/feedback/` · PRPs en `.claude/PRPs/` · etc · paridad reglas #26 + #18 + etc).
- Modificaciones contractuales del pack que aportan valor a TODOS los adopters futuros (ver excepciones abajo).

### Excepciones · artefactos canónicos del pack

La regla firme NO se aplica cuando el archivo es un artefacto canónico del pack con valor permanente. Excepciones permitidas (path correspondiente):

| Tipo de artefacto canónico | Path correcto |
|---|---|
| Regla firme nueva del flujo del pack | `.claude/rules/<slug>.md` con shape P8 |
| Memoria seed nueva (gotcha universal · lección operativa replicable) | `.claude/memory/feedback/<slug>.md` con frontmatter `type: feedback` + indexar en `MEMORY.md` |
| Skill nuevo del flujo | `.claude/skills/<skill>/SKILL.md` con shape canónico |
| Script nuevo del pack | `scripts/<nombre>.sh` con shellcheck + bash -n verde |
| Smoke nuevo del flujo | `tests/scripts/infra-flujo/<smoke>.sh` con severidad declarada + wiring CI |
| Referencia doctrinal nueva | `.claude/references/external-doctrine/<doc>.md` (snapshot inmutable) |
| README de carpeta nueva (regla #22) | `<carpeta>/README.md` con shape canónico |

**Criterio firme para distinguir WIP vs artefacto canónico:** ver § "Test mental crítico" abajo.

### Test mental crítico

> *"¿este archivo va a tener valor para alguien que clone el template en 6 meses?"*

- **SÍ → artefacto canónico** · va al path apropiado del pack (ver tabla de excepciones arriba).
- **NO → WIP** · va a `.claude/_workspace/<archivo>.md`.

**Auto-pregunta del agente antes de cada `Write` durante meta-work del template:**

1. ¿El archivo aporta valor universal a futuros adopters del template? → SÍ = canónico · NO = WIP.
2. Si la respuesta es ambigua: ¿puedo justificar al user en 1 frase por qué este archivo merece estar en el pack canónico? → SÍ = canónico (con firma user previa si es regla/memoria seed nueva) · NO = WIP.
3. Si sigue ambiguo: default = WIP en `_workspace/` · el user cristaliza después si decide promoverlo.

### Anti-rationalization

| Excusa típica del agente | Rebuttal |
|---|---|
| "Esta memoria parece universal · va a `memory/feedback/`" | Si NO firmó el user que es seed permanente del pack · va a `_workspace/` · cero auto-promoción del agente. El user es quien valida qué se vuelve seed canónico. |
| "Este handoff documenta trabajo importante · va a `memory/project/` para preservar trazabilidad" | NO. Handoffs del meta-work del template NUNCA van a `memory/project/` (esa carpeta es para handoffs de proyectos derivados que clonen el template). Van a `_workspace/`. La trazabilidad histórica del meta-work vive en git history del workflow-base, no en `memory/project/`. |
| "Voy a registrar esta deuda en `docs/logs/technical-debt.md`" | NO. `technical-debt.md` del template debe arrancar VACÍO para adopters · sumar filas pollute el seed canónico. Si la deuda es del meta-work, va a un draft en `_workspace/<dt-draft>.md` para discusión con el user · si el user firma que es deuda real del pack, abre PRP/refinamiento. |
| "Sumo entry al `log.md` para documentar el cierre del scope" | NO. `log.md` del template debe arrancar SIN entries reales (`^## \[` count = 0) para adopters · cada entry pollute la bitácora. Trazabilidad del meta-work vive en git commits + commit messages del workflow-base. |
| "Genero un script de utilidad temporal en `scripts/`" | Si el script es contractual del pack → va a `scripts/` con shellcheck verde + wiring. Si es one-shot del meta-work → va a `_workspace/<script>.sh`. Test mental crítico decide. |
| "El cwd parece template pero estoy haciendo trabajo de un PRP del producto" | Verificar: si el repo tiene placeholder `<PROYECTO>` en CLAUDE.md + 0 PRPs reales → es template puro · regla aplica. Si el repo NO es template (CLAUDE.md tiene producto real definido) → estás en un proyecto derivado · esta regla NO aplica · usar canales canónicos del proyecto. |

### Red flags

- 🚩 Vas a hacer `Write` a un path fuera de `.claude/_workspace/` durante meta-work del template · sin haber pasado el test mental crítico.
- 🚩 La auto-pregunta retornó "ambigua" y elegiste path canónico en lugar de `_workspace/` (default debe ser WIP cuando hay duda).
- 🚩 Generaste handoff en `.claude/memory/project/` durante meta-work del template (caso real que disparó la creación de esta convención · 2026-05-23).
- 🚩 Sumaste fila a `docs/logs/technical-debt.md` durante meta-work del template (debe estar vacío para adopters).
- 🚩 Editaste `.claude/memory/log.md` agregando entry durante meta-work del template (debe estar sin entries para adopters).

### Verification

- [ ] Antes de cada `Write` durante meta-work del template, test mental crítico aplicado: WIP → `_workspace/` · canónico → path del pack.
- [ ] Cero archivos efímeros del meta-work commiteados fuera de `_workspace/`.
- [ ] Smoke `fresh-install-canonical-state.sh` Bloque K verde: `git ls-files .claude/_workspace/` retorna solo `README.md`.
- [ ] Smoke `fresh-install-canonical-state.sh` Bloque G verde: `log.md` cero entries reales.
- [ ] Smoke `fresh-install-canonical-state.sh` Bloque H verde: `docs/logs/*` tablas de datos vacías.

## Convención operativa de la carpeta

- **Path canónico:** `.claude/_workspace/<archivo>.md` (o subcarpeta si el WIP amerita estructura · ej: `.claude/_workspace/audit-2026-05-23/`).
- **Gitignored:** todo el contenido excepto este `README.md` está ignorado por `.gitignore` (patrón `.claude/_workspace/*` + `!.claude/_workspace/README.md`).
- **Persistencia:** los archivos viven en el filesystem local de la máquina · NO se sincronizan entre clones · NO se commitean. Si necesitás preservar uno, copialo a una ubicación fuera del repo (ej: `~/handoffs/`) o convertilo en artefacto canónico del template (con firma user previa).
- **Cleanup:** el user puede borrar el contenido cuando quiera (`rm -rf .claude/_workspace/*` salvo `README.md`) sin consecuencias · cero impacto en el repo.

## Qué SÍ va acá

- ✅ Handoffs entre sesiones del meta-work del template (paridad regla #26 · shape canónico de 7 secciones · pero gitignored).
- ✅ Drafts de planes que el user va a revisar antes de cristalizar (drafts de reglas nuevas · drafts de smokes · drafts de skills).
- ✅ Scratchpads de análisis intermedio (auditorías · inventarios · listas exploratorias).
- ✅ Output de comandos largos que el agente quiere preservar para referencia mid-sesión.
- ✅ Cualquier artefacto cuya vida útil es ≤1 sesión (o continuidad entre N sesiones consecutivas del meta-work).

## Qué NO va acá

- ❌ Memorias seed permanentes del pack (`.claude/memory/feedback/<slug>.md` · va al path canónico si el user firma que es seed).
- ❌ Handoffs de trabajo de un proyecto derivado · esos viven en `.claude/memory/project/` del proyecto derivado (no del template).
- ❌ PRPs · esos viven en `.claude/PRPs/` del proyecto derivado (no del template).
- ❌ Reglas firmes nuevas del pack · esas van a `.claude/rules/<slug>.md` con shape P8 si son contractuales.
- ❌ Cualquier artefacto que aporte valor a futuros adopters del template · esos son canónicos + commiteados con su path correspondiente.

## Tabla de decisión · `.claude/_workspace/` vs artefactos canónicos

| Caso | Destino correcto |
|---|---|
| Handoff entre sesiones del meta-work del template (esta sesión cerró fase X · próxima sesión retoma fase Y) | `.claude/_workspace/<scope>-handoff-<YYYY-MM-DD>.md` (gitignored) |
| Handoff entre sesiones de un proyecto derivado (en el repo del proyecto, no del template) | `.claude/memory/project/<scope>-handoff-<YYYY-MM-DD>.md` (commiteado · paridad regla #26) |
| Memoria seed nueva (gotcha universal · lección operativa replicable · firmada por user) | `.claude/memory/feedback/<slug>.md` + indexar en `MEMORY.md` |
| Memoria draft sin firma user previa (durante meta-work) | `.claude/_workspace/<memoria-draft>.md` (gitignored · cristaliza en feedback/ después si user firma) |
| Draft de un plan que el user va a revisar | `.claude/_workspace/<plan>-draft.md` (gitignored · cristaliza después en PRP o memoria si aprueba) |
| Auditoría exhaustiva de inventario (lista de archivos · análisis intermedio) | `.claude/_workspace/audit-<topic>-<YYYY-MM-DD>.md` (gitignored) |
| Regla firme nueva del flujo del pack (con shape P8 · firma user) | `.claude/rules/<slug>.md` (commiteado canónico) |
| Skill nuevo del flujo (con shape canónico · firma user) | `.claude/skills/<skill>/SKILL.md` (commiteado canónico) |
| Script nuevo del pack contractual (con shellcheck + bash -n verde) | `scripts/<nombre>.sh` (commiteado canónico) |
| Script one-shot del meta-work (ej: cleanup ad-hoc · análisis temporal) | `.claude/_workspace/<script>.sh` (gitignored) |

## Carpetas hermanas

- [`.claude/memory/_archive/`](../memory/_archive/) — memorias archivadas históricas · commiteadas (NO gitignored) · contenido NO se carga al boot pero persiste como trazabilidad. Diferencia: `_archive/` es histórico canónico permanente, `_workspace/` es WIP efímero local.
- [`.claude/memory/project/`](../memory/project/) — handoffs entre sesiones de proyectos derivados (NO del template) · commiteado · paridad regla #26 `session-handoff.md`.

---

*README seed canónico del pack workflow-base · regla [`folder-creation-with-readme.md`](../rules/folder-creation-with-readme.md) (regla #22) · convención + regla firme + test mental + anti-rationalization consolidados en este doc · CLAUDE.md tiene pointer 1-línea hacia acá.*
