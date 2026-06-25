---
name: handoff
type: skill
description: "Generar archivo handoff bajo demanda del user cuando se cierra trabajo mid-sesión con continuidad esperada en sesión nueva. Invoca la regla firme #26 session-handoff.md como SoT contractual · re-lee la regla · mapea el estado actual de la sesión (commits hechos · qué se cerró · qué falta · gotchas detectados) · genera el archivo en `.claude/memory/project/<scope>-handoff-<YYYY-MM-DD>[-<contexto>].md` siguiendo el shape canónico (7 secciones · 6 obligatorias + Gotchas única opcional) · menciona el path al user al cierre. Activar cuando el usuario dice: handoff, armá el handoff, arma el handoff, generá el handoff, genera el handoff, cerrá la sesión, cerra la sesion, cortemos acá, cortemos aca, pasame a sesión nueva, pasame a sesion nueva, preparame el handoff, prepara el handoff, deja todo pronto para sesión nueva, deja todo pronto, dejame el handoff, listo para nueva sesión, listo para nueva sesion, cerrá y handoff, cerra y handoff, cierre fase 🔴, cierre fase punto-de-no-retorno, cerrá la fase 🔴, cerra la fase punto-de-no-retorno, bloqueo inesperado, estoy bloqueado, tengo un bloqueo, no puedo avanzar, me trabé acá, me trabe aca."
allowed-tools: Read, Write, Bash
---

# Skill: `/handoff` — generar handoff entre sesiones bajo demanda

> **Skill custom autocontenido.** Trigger explícito que el user invoca para forzar la generación de un archivo handoff cuando se cierra trabajo mid-sesión con continuidad esperada en sesión nueva · complementa la regla firme #26 (la regla codifica el shape + cuándo · el skill ejecuta la generación bajo demanda).
>
> **Relación con la regla #26:** la regla [`session-handoff.md`](../../rules/session-handoff.md) es **SoT contractual** del shape canónico (7 secciones · 6 obligatorias + Gotchas única opcional) + cuándo aplica + path obligatorio. Este skill **NO duplica** el shape · solo lo invoca y lo aplica. Si mañana cambia la regla, el skill refleja el cambio automáticamente (Process Paso 1 obliga re-lectura · cero cache). Paridad arquitectónica con [`/fatiga`](../fatiga/SKILL.md) ↔ regla #9 [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) y [`/documentar`](../documentar/SKILL.md) ↔ regla #18 [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) (refinamiento iterativo upstream · paridad bidireccional completa entre los 3 skills "trigger explícito · re-lectura obligatoria de SoT · cero cache").

## Overview

> **Propósito:** trigger explícito para generar un archivo handoff bajo demanda del user · invoca la regla firme #26 como SoT contractual · genera el archivo en `.claude/memory/project/` siguiendo el shape canónico (7 secciones · 6 obligatorias + Gotchas única opcional) · menciona el path al user al cierre para confirmación.

**Cuándo invocar:** 4 casos disparadores · detalle accionable con frases-gatillo en `## When` abajo. Resumen: cierre manual de sesión · firma camino B de la regla #9 (fatiga) · pre-cierre de fase 🔴 punto-de-no-retorno · bloqueo inesperado mid-sesión.

**Qué NO hace:**

- ❌ NO sustituye a la regla firme #26 — esa sigue siendo SoT contractual del shape + cuándo · el skill solo lo invoca bajo demanda.
- ❌ NO commitea automáticamente · solo genera el archivo · el commit local va en la operación normal de cierre de sesión (paridad regla #27 [`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) "1 push por PRP en paso 6" · NO push).
- ❌ NO sustituye a `prp-close` en `log.md` (regla #20 [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md)) — handoff es mid-flight · `prp-close` es post-merge a main.
- ❌ NO genera handoff si el trabajo es Modo A trivial sin continuidad esperada (verificar When antes de ejecutar).

## When

| Caso | Aplica `/handoff` |
|---|---|
| User dice *"/handoff"* · *"armá el handoff"* · *"cerrá la sesión"* · *"cortemos acá"* · *"pasame a sesión nueva"* · *"preparame el handoff"* · *"deja todo pronto para sesión nueva"* · *"listo para nueva sesión"* | ✅ SÍ |
| User firma "B" en aviso de fatigue self-evaluation (regla #9 · camino B = cerrar + handoff) | ✅ SÍ (skill automatiza la generación post-firma) |
| User invoca pre-cierre de fase 🔴 punto-de-no-retorno · prefiere arrancar fase nueva con contexto fresco | ✅ SÍ |
| Bloqueo inesperado · sesión nueva necesita saber qué se intentó · cómo · y dónde quedó la cosa | ✅ SÍ |
| Modo A task trivial cerrada exitosamente · cero continuidad esperada | ❌ NO (no hay nada para retomar · handoff sería ruido) |
| Cierre exitoso de PRP entero post-paso 6 | ❌ NO (eso es entrada `prp-close` en `log.md` vía regla #20 · NO handoff) |
| Sesión exploratoria sin scope definido · cero trabajo concreto pendiente | ❌ NO (no hay sustancia operativa para handoff) |
| User dice "estoy cansado" pero referido a SU fatiga personal · no a la del agente | ❌ NO (zona privada del user · regla #9 firme: cero injerencia · ofrecer handoff sería paternalismo) |

## Process

> **Skill autocontenido.** El § Process embebe los 3 pasos canónicos · cero detección runtime · ejecución mecánica.
> **Cita inline de doctrina:** el shape canónico de 7 secciones · el path obligatorio · y el cuándo viven en [`session-handoff.md`](../../rules/session-handoff.md) (SoT contractual). Este skill **referencia** la regla y **ejecuta** su aplicación bajo demanda.

### Paso 1 · Cargar regla #26 como SoT (obligatorio · cero cache)

`Read .claude/rules/session-handoff.md` cada invocación.

**Por qué obligatorio:** la regla es SoT contractual · puede haber cambiado entre invocaciones (refinamientos del shape · ajustes de path · etc). Re-leer cuesta segundos · evita drift entre skill y regla. Cero cache de invocaciones previas.

**Qué cargar de la regla:**

- Las 7 secciones del shape canónico (orden estricto · 6 obligatorias + Gotchas única opcional).
- El path obligatorio (`.claude/memory/project/<scope>-handoff-<YYYY-MM-DD>[-<contexto>].md`).
- Las reglas operativas firmes (6 ítems · commit del handoff · mención al user al cierre · etc).
- El cuándo aplica vs cuándo NO aplica.

### Paso 2 · Mapear estado actual de la sesión

Recopilar info operativa para poblar las secciones del shape canónico definidas por la regla #26 § Process. Helpers operativos:

- **Scope identificable:** decidir slug (`PRP-NNN` · `refactor-X.Y` · `dt-NNN` · O ad-hoc acordado con el user) · fecha `YYYY-MM-DD` · sub-contexto opcional (`fase-3-cerrada` · `post-fase4` · `bloqueo` · etc) cuando hay múltiples handoffs el mismo día.
- **Estado al cierre:** `git log --oneline -<N>` para commits de la sesión · `git status --short` para working tree (limpio post-último commit o documentar lo pendiente) · qué fases/pasos/sub-bloques cerraron · decisiones arquitectónicas 🔵 firmadas.
- **Qué falta hacer:** acción operativa paso a paso con paths exactos · DoD de la próxima fase/etapa · cross-refs a archivos/reglas/commits relevantes.
- **Gotchas detectados** (única opcional): aprendizajes técnicos · anti-patterns evitados · convenciones violadas y fixeadas inline · candidatos a memoria persistente en `feedback/<topic>.md`. Si genuinamente ninguno aplica → omitir sección entera (NO escribir "ninguno detectado").
- **Re-onboarding:** qué `Read` hacer primero · qué skill invocar · qué saltar · status tracker recomendado al boot.
- **Refs:** PRP / mini-PRP / refactor / scope correspondiente · DTs abiertas en esta sesión · commits clave (SHA) · reglas firmes aplicables.

### Paso 3 · Generar el archivo handoff siguiendo shape canónico

`Write .claude/memory/project/<scope>-handoff-<YYYY-MM-DD>[-<contexto>].md`

**Estructura del archivo:** template literal completo en regla #26 § Process (esa es la SoT contractual · cero recopiar acá). Resumen del orden estricto: (1) frontmatter YAML `name` + `description` + `type: project` · (2) título + blockquote intro de 3 líneas (`Disparado por` · `Próxima acción concreta` · `Skill a invocar`) · (3) `## Estado al cierre de esta sesión` · (4) `## Qué falta hacer en la próxima sesión` · (5) `## Gotchas detectados` (única opcional · omitir si no aplican) · (6) `## Re-onboarding en sesión nueva` · (7) `## Refs`.

### Paso 4 · Mencionar el handoff al user al cierre (obligatorio · regla #26 ítem operativo 6)

Cierre del skill con párrafo café 3-5 líneas (paridad [`conversation-style.md`](../../rules/conversation-style.md)):

```text
Handoff generado en `.claude/memory/project/<scope>-handoff-<YYYY-MM-DD>[-<contexto>].md` ·
próxima sesión arranca con [skill exacto].

[1 línea opcional: si la sesión cierra acá, recordatorio del commit local pendiente con el handoff incluido.]
```

**Reglas del cierre:**

- **Path exacto explícito** · cero archivos silenciosos.
- **Próxima acción concreta** · el user sabe qué viene.
- **Recordatorio de commit** si el handoff todavía no está commiteado · paridad regla #27 "1 push por PRP en paso 6" (handoff se commitea local · NO push).
- **Gate auto-verificación regex-match del mensaje al user (refinamiento iterativo upstream):** ANTES de enviar el mensaje de cierre, auto-verificar mentalmente (o con grep si la sesión lo permite) que el texto incluye los 2 patrones obligatorios: (a) path del handoff matcheando `\.claude/memory/project/[A-Za-z0-9._-]+-handoff-\d{4}-\d{2}-\d{2}([-A-Za-z0-9._]+)?\.md` · (b) referencia al skill próximo a invocar con barra inicial matcheando `/(arrancar|planificar|implementar|revisar|validar|entregar|documentar|fatiga|handoff|memory-manager|revisar-main|<otros>)` (o equivalente del proyecto). Si el mensaje NO matchea ambos patrones, reescribir antes de enviar · cero "ya está en el archivo el detalle" como excusa para omitir cualquiera de los 2 (paridad regla #26 ítem operativo 6 contractual).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Lo invocaron pero el trabajo es chico · skipeo el handoff" | NO. Si el user invocó `/handoff` explícitamente, el handoff es contractual · el user es la fuente de verdad sobre si hay continuidad esperada. Generar handoff "minimalista" siguiendo las 7 secciones cuesta 2 min y elimina ambigüedad para la sesión nueva. |
| "Re-uso el handoff de hace 1 hora · es casi el mismo" | NO. Cada invocación obliga re-leer la regla #26 (Paso 1) + re-mapear el estado ACTUAL (Paso 2). El estado cambia turno a turno. Re-usar = drift entre lo que el handoff dice y lo que realmente está. |
| "Skipeo el Paso 1 · ya sé las 7 secciones de memoria" | NO. La regla es SoT contractual · puede haber cambiado (refinamientos · ajustes de path · etc). Read cuesta segundos · evita drift entre skill y regla. |
| "Genero el handoff en otro path porque queda más claro acá" | NO. Path canónico `.claude/memory/project/<scope>-handoff-<YYYY-MM-DD>[-<contexto>].md` es contractual · `/arrancar` y otros skills buscan handoffs en ese path exacto. Path distinto = handoff invisible al boot de la próxima sesión. |
| "Omito la sección de Refs porque ya está todo en el commit message" | NO. El commit message es para git history · el handoff es para re-onboarding operativo. Los Refs en el handoff son cross-refs accionables al boot · no copy-paste del commit. |
| "Genero el archivo y no se lo menciono al user · si lo necesita lo encuentra" | NO. Mencionar el handoff al cierre es contractual (regla #26 ítem operativo 6 · path exacto + próxima acción + skill a invocar · template del cierre en regla #26). Cero archivos silenciosos en `.claude/memory/project/`. |
| "El user me pidió handoff pero la sesión es trivial · le explico que no aplica y skipeo" | OK si es genuinamente trivial sin continuidad esperada (verificar When de la regla #26). Pero el push-back tiene que ser explícito y argumentado · cero "asumir que no aplica" silenciosamente. |

## Red flags

- 🚩 Emitís handoff sin haber leído la regla #26 en esta invocación (Process Paso 1 omitido).
- 🚩 El archivo handoff que generaste vive fuera de `.claude/memory/project/`.
- 🚩 Falta alguna de las 6 secciones obligatorias del shape canónico (Gotchas es la única opcional).
- 🚩 El path no sigue convención `<scope>-handoff-<YYYY-MM-DD>[-<contexto>].md`.
- 🚩 El blockquote intro NO tiene "Disparado por · Próxima acción concreta · Skill a invocar" en 3 líneas.
- 🚩 Generaste el handoff y no lo mencionaste al user al cierre con path exacto.
- 🚩 Confundiste handoff con `prp-close` (handoff = mid-flight · `prp-close` = post-merge a main · regla #20 [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md)).
- 🚩 Generaste handoff para Modo A trivial sin continuidad esperada · ruido en `.claude/memory/project/`.

## Verification

- [ ] Paso 1 ejecutado · regla #26 [`session-handoff.md`](../../rules/session-handoff.md) leída en esta invocación (cero cache previo).
- [ ] Paso 2 ejecutado · estado de la sesión mapeado (scope · commits hechos · qué se cerró · qué falta · gotchas si aplican · re-onboarding · refs).
- [ ] Paso 3 ejecutado · archivo creado en `.claude/memory/project/<scope>-handoff-<YYYY-MM-DD>[-<contexto>].md` con las 6 secciones obligatorias del shape canónico (Gotchas única opcional · omitida cuando genuinamente no aplica).
- [ ] Paso 4 ejecutado · handoff mencionado al user al cierre con path exacto + próxima acción + recordatorio commit si aplica.
- [ ] **Gate regex-match del mensaje de cierre aplicado (refinamiento iterativo upstream):** mensaje al user matchea (a) regex del path `\.claude/memory/project/[A-Za-z0-9._-]+-handoff-\d{4}-\d{2}-\d{2}.*\.md` · (b) referencia al skill próximo con barra inicial `/(arrancar|implementar|validar|...)`. Si falta cualquiera, mensaje reescrito antes de enviar.
- [ ] Cero handoffs silenciosos · cero paths fuera de `.claude/memory/project/`.

**Cross-reference firme:**

- SoT contractual: [`session-handoff.md`](../../rules/session-handoff.md) (regla firme #26 · shape canónico de 7 secciones + path obligatorio + cuándo aplica).
- Hermana arquitectónica: skill [`/fatiga`](../fatiga/SKILL.md) ↔ regla #9 [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) (mismo patrón skill ↔ regla · skill invoca regla como SoT · cero duplicación).
- Hermana operativa: regla #9 fatigue-self-evaluation (camino B = cerrar + handoff · disparador típico de este skill).
- Refuerza: [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) (ítem 6 commit local con resumen · handoff es parte del cierre de sesión).
- Refuerza: [`conversation-style.md`](../../rules/conversation-style.md) (cierre del skill con párrafo café 3-5 líneas · path exacto + próxima acción + recordatorio commit).
