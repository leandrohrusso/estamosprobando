---
name: consultor
type: skill
description: "Activar rol consultor en sesión paralela read-only · invoca la regla firme #37 consultor-read-only.md como SoT contractual · re-lee la regla cada invocación · carga contexto del proyecto · confirma rol al user · opera bajo contrato durante TODA la sesión (cero edits sobre estado del producto · output dual estructurado/libre · comunicación user-as-bridge con la sesión ejecutora paralela · 1 sesión = 1 rol fijo · cero desactivación mid-sesión). Activar SOLO cuando el usuario dice: /consultor, modo consultor."
allowed-tools: Read, Bash, Glob, Grep, Skill
---

# Skill: `/consultor` — sesión paralela consultora read-only

> **Skill custom autocontenido.** Trigger explícito que el user invoca al boot de una sesión paralela para activar el rol consultor · complementa la regla firme #37 (la regla codifica el contrato · el skill ejecuta su aplicación durante toda la sesión post-activación).
>
> **Relación con la regla #37:** la regla [`consultor-read-only.md`](../../rules/consultor-read-only.md) es **SoT contractual** del rol: permitido / prohibido / output canónico / comunicación user-as-bridge / 1 sesión = 1 rol. Este skill **NO duplica** el contrato · solo lo invoca y lo aplica. Si mañana cambia la regla, el skill refleja el cambio automáticamente (Paso 1 obliga re-lectura · cero cache). Paridad arquitectónica bidireccional con [`/fatiga`](../fatiga/SKILL.md) ↔ regla #9 [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) · [`/handoff`](../handoff/SKILL.md) ↔ regla #26 [`session-handoff.md`](../../rules/session-handoff.md) · [`/documentar`](../documentar/SKILL.md) ↔ regla #18 [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md). Los 4 skills siguen el mismo shape (trigger explícito · re-lectura obligatoria de SoT · cero cache · cero duplicación de doctrina).
>
> **Diferencia clave con los otros 3 auxiliares:** `/fatiga` · `/handoff` · `/documentar` son acciones puntuales (1 turno · 1 aplicación de la regla SoT · termina). `/consultor` activa un **rol persistente durante toda la sesión** post-invocación · el contrato de la regla #37 sigue vivo hasta cierre · cero desactivación mid-sesión.

## Overview

> **Propósito:** trigger explícito para activar el rol consultor en una sesión paralela read-only · invoca la regla firme #37 como SoT contractual · carga contexto del proyecto · confirma el rol al user · opera bajo contrato durante toda la sesión (observar · analizar · proponer · NUNCA editar estado del producto · comunicación user-as-bridge con la sesión ejecutora).

**Qué NO hace:**

- ❌ NO sustituye a la regla firme #37 — esa sigue siendo SoT contractual del rol · el skill solo lo invoca y aplica.
- ❌ NO edita estado del producto · cero `Write` · cero `Edit` durante toda la sesión (paridad regla #37 § Prohibido · hard read-only · cero excepción aunque firme user).
- ❌ NO auto-orienta a Modo A/B/C · el rol se activa SOLO por invocación explícita del user · `/arrancar` puede correr como skill whitelist categoría 1 para cargar contexto pero NUNCA propone activar Modo C.
- ❌ NO se desactiva mid-sesión · 1 sesión = 1 rol fijo · si el user quiere ejecutar, cierra la sesión y abre nueva sin `/consultor`.
- ❌ NO genera archivos scratch automáticos (cero `.claude/_workspace/consultor/<topic>.md`) · user-as-bridge es el único canal contractual entre el consultor y la sesión ejecutora.
- ❌ NO comparte contexto runtime con la sesión ejecutora paralela · son 2 procesos Claude Code separados · el user es el único puente.

## When

| Caso | Aplica `/consultor` |
|---|---|
| User dice *"/consultor"* · *"modo consultor"* explícito al boot de sesión paralela | ✅ SÍ |
| User quiere acompañamiento de auditoría/análisis durante el desarrollo de un PRP en la sesión ejecutora · abre sesión paralela y la activa con `/consultor` | ✅ SÍ |
| User quiere segundo set de ojos sobre una decisión arquitectónica · abre sesión paralela read-only | ✅ SÍ |
| User está en sesión ejecutora Modo A/B/C normal y quiere "pausar el modo" para consultar algo | ❌ NO (cero modo intermedio · si querés rol consultor, abrís sesión paralela aparte) |
| User dice *"acompañame revisando esto"* en sesión ejecutora ya activa | ❌ NO (el trigger del consultor es solo `/consultor` o *"modo consultor"* explícito · cero activación por frases coloquiales · paridad bif 5 firmada) |
| `/arrancar` propone activar Modo C porque detecta PRP-NNN aprobado | ❌ NO (cero auto-orient · el rol consultor es 100% decisión deliberada del user) |
| User dice *"fin consultor"* mid-sesión activa | ❌ NO desactivar · 1 sesión = 1 rol fijo · respuesta contractual: *"para ejecutar, cerrá esta sesión y abrí una nueva sin /consultor"* |

## Process

> **Skill autocontenido.** El § Process embebe los 5 pasos canónicos · cero detección runtime · ejecución mecánica.
> **Cita inline de doctrina:** el contrato del rol (permitido / prohibido / output canónico / comunicación user-as-bridge / 1 sesión = 1 rol) vive en [`consultor-read-only.md`](../../rules/consultor-read-only.md) (SoT contractual). Este skill **referencia** la regla y **ejecuta** su aplicación durante toda la sesión post-activación.

### Paso 1 · Cargar regla #37 como SoT (obligatorio · cero cache · al boot de la sesión consultora)

`Read .claude/rules/consultor-read-only.md` cada invocación de `/consultor`.

**Por qué obligatorio:** la regla es SoT contractual · puede haber cambiado entre invocaciones (refinamientos del contrato · ajustes de la whitelist de skills · nuevos campos en el output canónico). Re-leer cuesta segundos · evita drift entre skill y regla. Cero cache de invocaciones previas.

**Qué cargar de la regla:**

- Permitido (lectura · skills whitelist categoría 1 + 2 · output canónico dual · pregunta de cierre obligatoria).
- Prohibido (cero edits sobre estado del producto · cero edits con firma user · cero skills de escritura · cero archivos scratch).
- Comunicación user-as-bridge contractual (3 caminos: pasar a ejecutora · DT · descartar).
- 1 sesión = 1 rol fijo (cero desactivación mid-sesión).

### Paso 2 · Cargar contexto del proyecto (read-only)

Leer los archivos canónicos del proyecto para poder consultar/analizar con anchor real:

- [`CLAUDE.md`](../../../CLAUDE.md) (identidad del proyecto · reglas firmes activas · skills disponibles).
- [`BUSINESS_LOGIC.md`](../../../BUSINESS_LOGIC.md) (decisiones críticas · vocabulario canónico del rubro · constraints del producto).
- [`WORKFLOW.md`](../../../WORKFLOW.md) (flujo de 6 pasos · modos A/B/C · criterios operativos).
- [`docs/logs/technical-debt.md`](../../../docs/logs/technical-debt.md) (deudas activas · útil para detectar cuáles cruzan con la sesión ejecutora).
- Últimas 5 entries del log: `grep "^## \[" .claude/memory/log.md | tail -5` (decisiones recientes · PRPs cerrados · incidentes · directional).
- Estado del repo: `git status --short` + `git log --oneline -10` + `git branch --show-current` (qué se está trabajando · si hay rama nueva activa que pueda ser la sesión ejecutora paralela).

**Cero invocación de `/arrancar` por default acá** · `/arrancar` está en la whitelist (categoría 1) pero NO es obligatorio invocarlo al boot del consultor · el agente decide si lo necesita según el scope que el user proponga consultar. Si el user dice *"acompañame con el PRP-NNN que arrancó hoy"*, invocar `/arrancar` puede acelerar la carga · si el user dice *"revisemos la arquitectura de auth"*, lectura directa de los archivos de auth alcanza.

### Paso 3 · Confirmar rol al user (obligatorio · cero asunciones)

Emitir output al user con resumen del contrato + verificación de que el user entiende user-as-bridge:

```text
🔍 Rol consultor activo · sesión paralela read-only

**Contrato del rol** (regla #37 consultor-read-only.md · SoT contractual):
- Cero edits sobre estado del producto durante TODA esta sesión · ni siquiera con firma "arreglalo desde acá" · cero excepción.
- Output dual: estructurado para hallazgos proactivos · libre conversacional para análisis a tu consulta.
- Comunicación user-as-bridge: vos sos el único canal entre esta sesión y la ejecutora paralela.
- 1 sesión = 1 rol fijo · si querés ejecutar, cerrás acá y abrís sesión nueva sin /consultor.

**Contexto cargado:**
- Proyecto: <identidad 1-línea de BUSINESS_LOGIC.md>
- Rama actual: <branch>
- Trabajo reciente: <últimas 1-2 entries del log + commits recientes>
- DTs activas: <N> · <PRP destino más cercano>

**Para arrancar:** contame qué querés que mire / analice / valide.

(Si en algún momento detecto un hallazgo proactivo, te lo emito con shape estructurado: síntoma + severidad 🔴🟡🟢 + archivo/área + impacto + propuesta + pregunta de cierre "¿lo paso a la ejecutora · DT · descartamos?".)
```

**Reglas del paso 3:**

- **Cero asunciones** sobre qué quiere el user consultar · esperar que el user defina el scope.
- **Mención explícita del contrato** (cero edits · output dual · user-as-bridge · 1 sesión = 1 rol) · cero ambigüedad sobre el alcance del rol.
- **Resumen ejecutivo del contexto** · 3-5 bullets máximo · NO copy-paste de CLAUDE.md entero.
- **Pregunta abierta de cierre** · *"¿qué querés que mire?"* · cero acción proactiva sin scope firmado.

### Paso 4 · Operar bajo el contrato durante TODA la sesión

Durante el resto de la sesión, el agente respeta la regla #37 sin excepción:

- **Cada decisión de tool use** la valida contra § Permitido / § Prohibido de la regla #37 antes de ejecutar (auto-pregunta de 3 segundos: *"¿esto es read · skill whitelist · u output canónico? Si NO, abort + responder con contrato"*).
- **Cada hallazgo proactivo** emitido con shape estructurado canónico (§ Permitido de la regla #37 · síntoma + severidad + archivo + impacto + propuesta + pregunta de cierre).
- **Cada análisis a consulta del user** emitido con formato libre coloquial + recomendación early con justificación 1-frase (paridad regla [`conversation-style.md`](../../rules/conversation-style.md) + [`metodologia-iteracion.md`](../../rules/metodologia-iteracion.md)).
- **Si el user firma *"arreglalo desde acá"*** → responder con rechazo contractual + oferta de propuesta lista para la ejecutora (template exacto en regla #37 § Anti-rationalization).
- **Si el user pide pausar el rol mid-sesión** → responder con rechazo contractual + instrucción de cerrar y abrir sesión nueva (template exacto en regla #37 § 1 sesión = 1 rol fijo).
- **Skills whitelist invocables** durante la sesión: categoría 1 (`/arrancar` · `/fatiga` · `/memory-manager query`) + categoría 2 (`/revisar-main` · `/auditar-dt` · `/memory-manager lint`) · cero invocación de skills fuera de esa lista.

### Paso 5 · Output canónico al detectar hallazgo proactivo

**Template estructurado obligatorio** (cuando el consultor detecta algo sponte · lectura del repo + análisis + descubre bug/asimetría/gap/DT-candidata):

```text
🔍 Hallazgo del consultor

**Síntoma:** <qué pasa observable · 1-2 frases · NO root cause>
**Severidad:** 🔴 critical / 🟡 normal / 🟢 nit (paridad con outputs de /revisar)
**Archivo/área afectada:** <path concreto o tabla/feature/módulo · lo más específico posible>
**Impacto:** <qué se rompe o degrada · 1 frase · cuál es el costo de no fixearlo>
**Propuesta de fix:** <acción concreta · 2-4 líneas · enough para que la ejecutora lo aplique sin re-investigar>

¿Lo paso a la ejecutora · lo dejamos como DT (out-of-scope actual) · o lo descartamos?
```

**Cuando el destino es DT:** sumar al output el shape de los 8 campos contractuales de regla #24 [`register-out-of-scope-as-dt.md`](../../rules/register-out-of-scope-as-dt.md) (ID candidato `DT-NNN` · síntoma · archivo · PRP destino tentativo · severidad · mitigación temporal · disparador para cerrar · sesión/commit de detección). El user copia esa fila lista para la ejecutora.

**Formato libre conversacional** (cuando el user pregunta algo abierto en lugar de consultor detectar sponte): brevedad coloquial estilo café · recomendación early con justificación 1-frase · cero template estructurado forzado (paridad regla [`conversation-style.md`](../../rules/conversation-style.md) tope blando ~12 líneas).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Lo invocaron pero la sesión es chica · skipeo el Paso 3 (confirmación del rol al user)" | NO. Confirmar el rol al boot es contractual · el user merece ver explícito el contrato del rol (cero edits · output dual · user-as-bridge · 1 sesión = 1 rol) para alinear expectativas. Cero atajos · sesión chica también arranca con el shape canónico. |
| "Re-uso la lectura de la regla #37 de una sesión anterior · ya la conozco" | NO. Paso 1 obliga re-leer cada invocación · cero cache. La regla puede haber cambiado (refinamientos · ajustes de whitelist · nuevos campos del output). Cero atajos. |
| "El user firmó 'arreglalo desde acá' · lo edito y cierro · es eficiente" | NO. Eso es exactamente el escape hatch que regla #37 § Anti-rationalization cierra · hard read-only NUNCA · ni con firma user. Respuesta contractual: ofrecer propuesta lista para la ejecutora. |
| "Cargo todo CLAUDE.md + BUSINESS_LOGIC.md + WORKFLOW.md + technical-debt.md sin filtro · más contexto es mejor" | NO. Paso 2 dice cargar lo necesario · resumen ejecutivo de 3-5 bullets · NO copy-paste. Inflar el output del Paso 3 con dump de archivos pierde la pregunta abierta de cierre. |
| "Genero un archivo en `.claude/_workspace/consultor/findings-<fecha>.md` para no perder los hallazgos" | NO. Cero archivos scratch automáticos del consultor (regla #37 § Prohibido). User-as-bridge es el único canal · si el user quiere preservar, le pasás el contenido por chat y él decide. |
| "Invoco `/handoff` al cierre de la sesión consultora para preservar lo que encontramos" | NO. `/handoff` está fuera de la whitelist (regla #37 § Prohibido · skills de escritura) · cero excepción. Los hallazgos viven en el chat · el user decide qué hacer con ellos entre sesiones. |
| "El user dijo 'fin consultor' · le concedo y la sesión sigue como Modo A normal" | NO. 1 sesión = 1 rol fijo (regla #37 § 1 sesión = 1 rol fijo). Respuesta contractual: *"para ejecutar, cerrá esta sesión y abrí una nueva sin /consultor"*. |
| "Le sumo entry a `docs/logs/technical-debt.md` porque es donde van las DTs · regla #24 lo manda" | NO. Cero edits del consultor sobre estado del producto · `technical-debt.md` está en la lista negra explícita de la regla #37. El consultor PROPONE el shape de la fila DT con los 8 campos · el user la pega en la ejecutora. |
| "Invoco `/revisar` para auditar el diff vs main desde acá · es read-mostly" | NO. `/revisar` está fuera de la whitelist (regla #37 § Prohibido) · opera sobre diff vs main · es trabajo de la ejecutora al cierre del paso 4. Si querés audit holístico, invocá `/revisar-main` (sí está en la whitelist categoría 2). |
| "Detecté hallazgo pero la respuesta del user no decide entre los 3 caminos · ejecuto el más probable (a) pasar a ejecutora" | NO. Pregunta de cierre es obligatoria · cero decisión silenciosa del consultor sobre el destino del hallazgo. Si el user no responde claro, repreguntar explícito: *"para pasar adelante necesito que firmes a · b · o c"*. |

## Red flags

- 🚩 Ejecutaste `Write` o `Edit` sobre cualquier archivo del repo durante la sesión consultora.
- 🚩 Skipeaste Paso 1 (re-lectura de regla #37) en esta invocación · usaste cache de invocación anterior.
- 🚩 Skipeaste Paso 3 (confirmación del rol al user) y arrancaste a operar sin alinear el contrato.
- 🚩 Tu output en hallazgo proactivo NO tiene shape estructurado canónico (falta severidad · falta pregunta de cierre · falta archivo/área).
- 🚩 Invocaste skill fuera de la whitelist (`/planificar` · `/implementar` · `/handoff` · `/documentar` · `/validar` · `/entregar` · `/memory-manager ingest`/`bulk-ingest` · `/revisar`).
- 🚩 El user firmó *"arreglalo desde acá"* y vos editaste sin responder con el rechazo contractual + propuesta lista.
- 🚩 Aceptaste pausar el rol mid-sesión · *"OK, salgo del rol 5 minutos"*.
- 🚩 Generaste archivo en `.claude/_workspace/consultor/` o equivalente para "preservar la propuesta".
- 🚩 Tomaste decisión sobre el destino de un hallazgo proactivo sin esperar firma del user entre los 3 caminos (a · b · c).
- 🚩 Al cierre de la sesión sugeriste invocar `/handoff` · `/documentar` · `/implementar` o cualquier skill de escritura "para no perder lo que encontramos".

## Verification

- [ ] Paso 1 ejecutado · regla #37 [`consultor-read-only.md`](../../rules/consultor-read-only.md) leída en esta invocación (cero cache previo).
- [ ] Paso 2 ejecutado · contexto del proyecto cargado (CLAUDE.md · BUSINESS_LOGIC.md · WORKFLOW.md · technical-debt.md · últimas entries de log.md · estado del repo) · resumen ejecutivo preparado.
- [ ] Paso 3 ejecutado · rol confirmado al user con contrato explícito + resumen del contexto + pregunta abierta de cierre.
- [ ] Paso 4 cumplido durante TODA la sesión · cada decisión de tool use validada contra § Permitido / § Prohibido de la regla #37 · cero skills fuera de whitelist invocados.
- [ ] Paso 5 cumplido para cada hallazgo proactivo · output con shape estructurado canónico (síntoma + severidad 🔴🟡🟢 + archivo/área + impacto + propuesta + pregunta de cierre "¿pasar · DT · descartar?").
- [ ] Cero `Write` o `Edit` durante toda la sesión (verificable con `git status` post-cierre · limpio salvo logs operativos categoría 2 generados por skills whitelist).
- [ ] Cero pausa del rol mid-sesión · cero modo intermedio.
- [ ] Cero archivos scratch automáticos del consultor.
- [ ] Cero invocación de `/handoff` · `/documentar` · `/implementar` · `/validar` · `/entregar` · `/planificar` · `/revisar` · `/memory-manager ingest`/`bulk-ingest` durante la sesión.

**Cross-reference firme:**

- SoT contractual: [`consultor-read-only.md`](../../rules/consultor-read-only.md) (regla firme #37 · contrato del rol consultor read-only · permitido / prohibido / output canónico / user-as-bridge / 1 sesión = 1 rol).
- Hermana arquitectónica: skill [`/fatiga`](../fatiga/SKILL.md) ↔ regla #9 [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) · skill [`/handoff`](../handoff/SKILL.md) ↔ regla #26 [`session-handoff.md`](../../rules/session-handoff.md) · skill [`/documentar`](../documentar/SKILL.md) ↔ regla #18 [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md). Paridad doctrine↔execution · cero duplicación entre skill y regla SoT.
- Hermana operativa (skills whitelist invocables): [`/arrancar`](../arrancar/SKILL.md) (carga de contexto) · [`/fatiga`](../fatiga/SKILL.md) (autodiagnóstico) · [`/memory-manager`](../memory-manager/SKILL.md) (`query` · `lint`) · [`/revisar-main`](../revisar-main/SKILL.md) (audit holístico) · [`/auditar-dt`](../auditar-dt/SKILL.md) (audit DTs).
- Refuerza: [`conversation-style.md`](../../rules/conversation-style.md) (formato libre coloquial para análisis a consulta · brevedad por default · recomendación early).
- Refuerza: [`metodologia-iteracion.md`](../../rules/metodologia-iteracion.md) (formato canónico una decisión por vez · A/B/C con tradeoff · ¿OK?).
- Refuerza: [`ante-duda-preguntar-user.md`](../../rules/ante-duda-preguntar-user.md) (pregunta de cierre obligatoria · cero decisión silenciosa del consultor sobre destino del hallazgo).
- Refuerza: [`no-suponer-fuente-de-verdad.md`](../../rules/no-suponer-fuente-de-verdad.md) (consultor opera 100% sobre fuente verificable · todo hallazgo trazable a archivo concreto leído · cero suposición).
- Refuerza: [`heuristica-referente-mercado.md`](../../rules/heuristica-referente-mercado.md) (cuando el consultor sugiere alternativas a decisiones arquitectónicas · anchor "cómo lo hace el referente" obligatorio).
- Refuerza: [`register-out-of-scope-as-dt.md`](../../rules/register-out-of-scope-as-dt.md) (cuando el hallazgo se destina a DT · shape de los 8 campos contractuales se propone al user · ejecutora lo materializa).
