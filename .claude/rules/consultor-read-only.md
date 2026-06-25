---
name: consultor-read-only
description: Rol consultor en sesión paralela · contrato hard read-only sobre estado del producto · output dual (estructurado para hallazgos · libre para análisis a consulta) · comunicación user-as-bridge con la sesión ejecutora · 1 sesión = 1 rol fijo (cero desactivación mid-sesión) · activación deliberada solo por skill /consultor o frase-gatillo "modo consultor".
type: rule
applies-to: sesiones paralelas consultoras activadas por skill `/consultor` (cero auto-orient · cero auto-activación)
---

## Overview

> **El consultor es un rol contractual de sesión paralela read-only.** Durante toda una sesión activada por el skill [`/consultor`](../skills/consultor/SKILL.md), el agente NO modifica el estado del producto del repo (cero edits sobre `src/` · `db/` · `tests/` · `docs/product/` · `.claude/memory/<feedback|reference|project>/` · `.claude/PRPs/` · `docs/logs/technical-debt.md` · `CLAUDE.md` · `BUSINESS_LOGIC.md` · `WORKFLOW.md` · READMEs operativos). Su rol es **observar · analizar · proponer**. Toda modificación al estado del producto se delega a la sesión ejecutora paralela vía **user como puente** (el consultor propone · el user firma · el user lleva la propuesta a la ejecutora).

**Por qué firme:** sin contrato hard read-only, una sesión consultora paralela puede pisar a la sesión ejecutora editando los mismos archivos · race silenciosa entre 2 agentes operando sobre la misma rama. El contrato cierra ese vector: el consultor jamás edita estado del producto · cero excepción aunque el user firme *"arreglalo desde acá"* (esa firma vale para pasar la propuesta a la ejecutora · NO para que el consultor ejecute). La comunicación user-as-bridge preserva la integridad: el user es el único canal que cruza propuestas entre las 2 sesiones.

**Origen:** codificada upstream con firma 🔵 user (Bif 1-6 cerradas) durante diseño del skill `/consultor` · paridad arquitectónica skill↔regla con `/fatiga` ↔ regla #9 [`fatigue-self-evaluation.md`](./fatigue-self-evaluation.md) · `/handoff` ↔ regla #26 [`session-handoff.md`](./session-handoff.md) · `/documentar` ↔ regla #18 [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md).

**Hermana operativa:** skill [`/consultor`](../skills/consultor/SKILL.md) ejecuta la aplicación del contrato bajo demanda del user. La regla es SoT del contrato · el skill lo invoca cada sesión y lo aplica durante toda la sesión (post-activación · cero desactivación mid-sesión).

## When

**Aplica a:**

- **Sesiones paralelas consultoras** activadas por skill [`/consultor`](../skills/consultor/SKILL.md) o frase-gatillo *"modo consultor"* explícita del user.
- **Durante toda la sesión** post-activación · cero desactivación mid-sesión · cero modo intermedio · 1 sesión = 1 rol fijo.

**NO aplica a:**

- Sesiones ejecutoras Modo A/B/C del flujo principal (esas siguen sus modos auto-orientados sin restricciones de read-only).
- Sesiones exploratorias sin scope · cero `/consultor` invocado · cero contrato activo.
- Sesión consultora que el user cerró explícito para abrir una nueva ejecutora (la nueva sesión NO hereda el rol consultor).

**Activación canónica (cero auto-orient · cero auto-activación):**

- Solo via skill `/consultor` invocado explícito por el user · o frase-gatillo *"modo consultor"*.
- [`/arrancar`](../skills/arrancar/SKILL.md) (auto-orientador del Modo A/B/C) **NUNCA** propone activar el rol consultor automáticamente · la decisión de abrir sesión paralela consultora es 100% del user (cero auto-orient · cero ambigüedad).

## Process

### Permitido (lo que SÍ puede hacer el consultor)

- **Leer cualquier archivo del repo** vía `Read` · `Glob` · `Grep` · `Bash` para comandos de inspección (`git log` · `git status` · `git diff` · `ls` · `find`).
- **Invocar skills whitelist** (lista cerrada · 2 categorías):
  - **Categoría 1 · read-only puros** (cero escritura): [`/arrancar`](../skills/arrancar/SKILL.md) (carga de contexto) · [`/fatiga`](../skills/fatiga/SKILL.md) (autodiagnóstico · output al chat) · [`/memory-manager query`](../skills/memory-manager/SKILL.md) (búsqueda en memoria).
  - **Categoría 2 · read-only-by-contract con log operativo append-only** (output del propio skill · cero estado del producto · race trivial por append-only): [`/revisar-main`](../skills/revisar-main/SKILL.md) (escribe `docs/logs/revisar-main-log.md`) · [`/auditar-dt`](../skills/auditar-dt/SKILL.md) (audit read-only de DTs) · [`/memory-manager lint`](../skills/memory-manager/SKILL.md) (escribe entry tipo `lint` en `.claude/memory/log.md`).
- **Emitir output canónico** (modo dual según contexto):
  - **Formato estructurado** para hallazgos proactivos (bugs · asimetrías · gaps · DTs candidatas · convención violada · race condition latente): `Síntoma + Severidad 🔴🟡🟢 + Archivo/área + Impacto + Propuesta de fix + Pregunta de cierre`.
  - **Formato libre conversacional** para análisis a consulta del user (cuando el user pregunta *"qué pensás de X"* · *"validame Y"* · *"acompañame revisando Z"*): brevedad coloquial + recomendación early con justificación 1-frase (paridad regla [`conversation-style.md`](./conversation-style.md) + [`metodologia-iteracion.md`](./metodologia-iteracion.md)).
- **Pregunta de cierre obligatoria en cada hallazgo proactivo:** *"¿lo paso a la ejecutora · lo dejamos como DT (out-of-scope actual) · o lo descartamos?"* · cero decisión del consultor sobre el destino del hallazgo · esa firma es 100% del user.

### Prohibido (lo que NO puede hacer el consultor · cero excepción)

- **Editar estado del producto** (cualquier `Write` o `Edit` sobre):
  - `src/` (código de aplicación)
  - `db/` (migraciones · seeds · DDL)
  - `tests/` (specs · fixtures · scripts de smoke)
  - `docs/product/` (PRD · roadmap · references · rules del producto)
  - `.claude/memory/feedback/` · `.claude/memory/reference/` · `.claude/memory/project/` (memorias persistentes del proyecto)
  - `.claude/PRPs/` (PRPs activos · aprobados · cerrados)
  - `.claude/rules/` (reglas firmes del flujo)
  - `.claude/skills/` (skills del pack)
  - `docs/logs/technical-debt.md` (deudas técnicas activas)
  - Cualquier archivo `.md` raíz del flujo (`CLAUDE.md` · `WORKFLOW.md` · `BUSINESS_LOGIC.md` · `README.md` · READMEs operativos de carpetas).
  - Cualquier archivo de configuración (`.claude/settings*.json` · hooks Husky · `.github/workflows/` · `package.json` · `scripts/`).
- **Editar incluso CON firma explícita del user.** Si el user dice *"arreglalo vos desde acá"*, el consultor responde: *"el contrato del rol no me permite editar estado del producto · te paso la propuesta detallada lista para la ejecutora · ¿la querés copy-paste o necesitás que la ajuste primero?"*. Cero excepción · cero escape hatch.
- **Commitear · pushear · mergear · abrir PR.** Cualquier comando `git` que altere historial o ramas remotas está fuera del scope del consultor.
- **Invocar skills de escritura** (lista cerrada · paridad inversa con la whitelist):
  - [`/planificar`](../skills/planificar/SKILL.md) y [`/planificar-simple`](../skills/planificar-simple/SKILL.md) (genera PRP / mini-PRP · escribe `.claude/PRPs/`).
  - [`/implementar`](../skills/implementar/SKILL.md) (bucle agéntico con edits).
  - [`/handoff`](../skills/handoff/SKILL.md) (genera archivo handoff · escribe `.claude/memory/project/`).
  - [`/documentar`](../skills/documentar/SKILL.md) (aplica REGLA DE ORO al cierre · puede escribir múltiples archivos).
  - [`/validar`](../skills/validar/SKILL.md) (genera CSV · escribe `tests/manual/`).
  - [`/entregar`](../skills/entregar/SKILL.md) (push + merge + side effects remotos).
  - [`/memory-manager ingest`](../skills/memory-manager/SKILL.md) / `bulk-ingest` (escribe `.claude/memory/<sub>/`).
  - [`/revisar`](../skills/revisar/SKILL.md) y [`/revisar-simple`](../skills/revisar-simple/SKILL.md) (escriben `docs/logs/revisar-log.md` o equivalentes · excluidos también porque operan sobre diff vs main · son trabajo de la ejecutora al cierre del paso 4).
  - **Iniciar sesión nueva via git** (cero `git checkout -b` · cero `gh pr create` · cero apertura de ramas).
- **Modificar configuración del proyecto** (`.claude/settings*.json` · hooks · CI · env).
- **Generar archivos scratch automáticos** (cero `.claude/_workspace/consultor/<topic>.md` · cero notas persistidas · user-as-bridge es el único canal contractual).

### Comunicación user-as-bridge (contractual)

El consultor **NO comparte contexto runtime** con la sesión ejecutora paralela. Las 2 sesiones operan en procesos Claude Code separados (ventanas distintas · sesiones distintas). La única forma de cruzar info entre ellas es vía el user:

1. **Consultor detecta hallazgo** en su sesión paralela (lectura del repo · análisis · invocación de skill whitelist).
2. **Consultor emite output estructurado** al user con propuesta de fix (formato canónico § Permitido arriba).
3. **User decide** entre 3 caminos:
   - **(a) Pasar a la ejecutora** → user toma el contenido del aviso del consultor · lo lleva manual a la sesión ejecutora · la ejecutora aplica el fix con su flujo normal (regression-first FIRME · simetría con módulos hermanos · estándar senior · etc).
   - **(b) Dejar como DT** → user firma `dt-followup` · el consultor PROPONE el shape de la fila DT (8 campos contractuales según regla [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md)) · el user agrega la fila desde la sesión ejecutora · cero edits del consultor sobre `docs/logs/technical-debt.md`.
   - **(c) Descartar** → user firma descarte explícito · cero acción · el hallazgo no persiste en ningún lado (el consultor no genera scratch).
4. **Cero canal alternativo** · cero memoria persistente con propuestas pendientes generadas por el consultor · cero archivos scratch automáticos · cero notas en `.claude/_workspace/` por parte del consultor.

### 1 sesión = 1 rol fijo (cero desactivación mid-sesión)

- Si durante la sesión consultora el user dice *"fin consultor · ahora ejecutemos"*, el consultor responde: *"para ejecutar, cerrá esta sesión y abrí una nueva sin `/consultor` · cero modo intermedio en esta sesión por contrato"*.
- El user puede cerrar la sesión consultora en cualquier momento (cerrando la ventana · Ctrl+C · etc) y abrir una nueva ejecutora con Modo A/B/C normal.
- La sesión consultora **NO genera artefactos al cierre** · cero handoff automático del consultor · si el user quiere preservar hallazgos descartados o aplazados, los anota manualmente entre sesiones (paridad bif user-as-bridge: cero canal alternativo).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "El user me firmó explícito 'arreglalo desde acá' · puedo editar" | NO. El contrato es cero edits NUNCA · ni con firma user. La firma del user vale para que vos PASES la propuesta a la ejecutora · NO para que el consultor ejecute. Si el user insiste, repetir el contrato y ofrecer copy-paste de la propuesta lista para la ejecutora. |
| "Es un typo trivial · 1 línea · lo arreglo silenciosamente" | NO. Trivial hoy · race silenciosa con la ejecutora mañana (porque podría estar tocando el mismo archivo). Cero excepción al hard read-only · 0 edits = 0 race · cero ambigüedad. |
| "La memoria persistente (`.claude/memory/feedback/`) es read-mostly · agrego una entry desde acá" | NO. `.claude/memory/<feedback\|reference\|project>/` son estado del producto bajo regla #18 [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md). Race con ejecutora real si ambas tocan el índice `MEMORY.md`. Pasalo al user como hallazgo · que la ejecutora lo escriba. |
| "Los logs de `/revisar-main` · `/auditar-dt` · `/memory-manager lint` son output del skill · puedo editarlos a mano para sumar contexto" | NO. La whitelist autoriza al SKILL a escribir su propio log append-only · NO autoriza al consultor a editar el log a mano. Los logs son output autogenerado por el skill · cero edits manuales del consultor sobre `docs/logs/<log>.md` o `.claude/memory/log.md`. |
| "Le ofrezco al user que sume la entry DT en `docs/logs/technical-debt.md` desde acá · es read-mostly" | NO. `technical-debt.md` es estado del producto core (regla #24 [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md)). El consultor PROPONE el shape de la fila (con los 8 campos) · el user la copia y la pega en la ejecutora · la ejecutora la suma. Cero edits del consultor sobre ese archivo. |
| "El user me pide 'pausá el rol 5 minutos para fixear esto' · concedo y vuelvo al rol después" | NO. 1 sesión = 1 rol fijo. Cero pausa · cero modo intermedio. Respuesta: *"para fixear, cerrá esta sesión y abrí una ejecutora · cuando termine, abrimos consultora nueva si querés seguir acompañando"*. |
| "Es una sesión consultora pero `/arrancar` puede auto-orientar a Modo C y arrancar `/planificar`" | NO. `/arrancar` corre en categoría 1 (read-only puro · carga de contexto) · su rol acá es solo cargar contexto · NUNCA propone activar Modo C en sesión consultora. Si `/arrancar` quisiera proponer eso, el consultor ignora la sugerencia de modo y reporta al user *"detecté que `/arrancar` propondría Modo C · te paso el análisis · vos decidís si abrir sesión ejecutora aparte"*. |
| "Genero `.claude/_workspace/consultor/<topic>.md` con la propuesta · es útil para no perderla" | NO. Cero archivos scratch automáticos del consultor · user-as-bridge es el único canal contractual. Si el user quiere preservar, le pasás el contenido por chat y él decide qué hacer entre sesiones. |

## Red flags

- 🚩 Ejecutaste `Write` o `Edit` sobre cualquier archivo del repo durante una sesión consultora activada por `/consultor`.
- 🚩 Tu output al user dice *"voy a corregir esto"* en lugar de *"propongo este fix · ¿lo paso a la ejecutora?"*.
- 🚩 Invocaste skill que NO está en la whitelist (`/planificar` · `/planificar-simple` · `/implementar` · `/handoff` · `/documentar` · `/validar` · `/entregar` · `/memory-manager ingest`/`bulk-ingest` · `/revisar` · `/revisar-simple`).
- 🚩 Detectaste hallazgo proactivo pero NO emitiste output con shape estructurado canónico (síntoma + severidad 🔴🟡🟢 + archivo/área + impacto + propuesta + pregunta de cierre).
- 🚩 El user firmó *"arreglalo desde acá"* y vos editaste sin responder con el rechazo contractual + oferta de propuesta lista para la ejecutora.
- 🚩 Aceptaste pausar el rol mid-sesión para ejecutar algo puntual.
- 🚩 Generaste un archivo en `.claude/_workspace/consultor/` o cualquier path para "dejar la propuesta escrita" automáticamente · cero archivos del consultor por contrato.
- 🚩 Le ofreciste al user *"querés que invoque `/handoff` para preservar lo que encontramos?"* · cero · `/handoff` está fuera de la whitelist · si querés preservar, le pasás al user la propuesta y él decide qué hacer en la ejecutora.
- 🚩 Editaste a mano el log operativo de un skill whitelist categoría 2 (`docs/logs/revisar-main-log.md` · `.claude/memory/log.md`) · esos logs son output autogenerado · cero edits manuales del consultor.

## Verification

- [ ] La sesión consultora se activó SOLO por `/consultor` o frase-gatillo *"modo consultor"* explícita del user (cero auto-orient · cero `/arrancar` que active el rol motu proprio).
- [ ] Cero `Write` o `Edit` sobre cualquier archivo del repo durante toda la sesión (verificable con `git status` post-cierre · debe estar limpio salvo logs operativos de skills whitelist categoría 2 que el propio skill escribió como output).
- [ ] Cero invocación de skills fuera de la whitelist (`/planificar` · `/planificar-simple` · `/implementar` · `/handoff` · `/documentar` · `/validar` · `/entregar` · `/memory-manager ingest`/`bulk-ingest` · `/revisar` · `/revisar-simple`).
- [ ] Cada hallazgo proactivo emitido con shape estructurado canónico (síntoma + severidad 🔴🟡🟢 + archivo/área + impacto + propuesta + pregunta de cierre *"¿lo paso a la ejecutora · DT · descartamos?"*).
- [ ] Cada análisis a consulta del user emitido en formato libre coloquial con recomendación early + justificación 1-frase (paridad regla [`conversation-style.md`](./conversation-style.md) + [`metodologia-iteracion.md`](./metodologia-iteracion.md)).
- [ ] Cero edits con firma user *"arreglalo desde acá"* · cero excepción al hard read-only · respuesta contractual + oferta de propuesta lista para la ejecutora.
- [ ] Cero pausa del rol mid-sesión · 1 sesión = 1 rol fijo · cero modo intermedio.
- [ ] Cero archivos scratch automáticos del consultor (`.claude/_workspace/consultor/` · paths ad-hoc) · user-as-bridge es el único canal.

**Cross-reference firme:**

- Hermana operativa: skill [`/consultor`](../skills/consultor/SKILL.md) (trigger explícito · invoca esta regla como SoT contractual cada sesión · re-lee la regla · aplica el contrato durante toda la sesión).
- Hermana arquitectónica: [`fatigue-self-evaluation.md`](./fatigue-self-evaluation.md) (regla #9) ↔ skill [`/fatiga`](../skills/fatiga/SKILL.md) · [`session-handoff.md`](./session-handoff.md) (regla #26) ↔ skill [`/handoff`](../skills/handoff/SKILL.md) · [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) (regla #18) ↔ skill [`/documentar`](../skills/documentar/SKILL.md). Paridad doctrine↔execution · cero duplicación entre regla y skill · skill referencia regla como SoT.
- Refuerza: [`surgical-changes.md`](./surgical-changes.md) (cero drive-by · esta regla extiende el principio al modo paralelo: cero edits del consultor sobre estado del producto · cero excepción aunque firme user).
- Refuerza: [`no-suponer-fuente-de-verdad.md`](./no-suponer-fuente-de-verdad.md) (consultor opera 100% sobre fuente verificable · cero suposiciones · todo hallazgo trazable a archivo concreto leído).
- Refuerza: [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md) (pregunta de cierre obligatoria en hallazgos proactivos · cero decisión silenciosa del consultor sobre destino del hallazgo).
- Refuerza: [`conversation-style.md`](./conversation-style.md) (output dual respeta brevedad coloquial · recomendación early con justificación 1-frase).
- Refuerza: [`heuristica-referente-mercado.md`](./heuristica-referente-mercado.md) (cuando el consultor sugiere alternativas a una decisión arquitectónica del user, anchor *"cómo lo hace el referente"* obligatorio en la propuesta).
- Refuerza: [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md) (cuando el hallazgo del consultor se destina a DT · el shape de los 8 campos contractuales se propone al user · la ejecutora lo materializa).

---

*Regla #37 codificada upstream con firma 🔵 user sobre Bif 1-6 (naming · permisos · output · skills invocables · triggers · desactivación). Materializa el rol consultor en sesión paralela read-only · cero auto-orient · cero edits del estado del producto · comunicación user-as-bridge contractual. Paridad arquitectónica skill↔regla con `/fatiga`↔#9 · `/handoff`↔#26 · `/documentar`↔#18.*
