---
name: validar
type: skill
description: "Validación exhaustiva de un PRP del producto mediante matriz CSV completa. Crea el CSV con el 100% de los casos del PRP, los ejecuta usando Playwright MCP + Supabase MCP + credenciales reales, arregla cada falla con un fix de calidad senior + spec PRINCIPIO 6 antes del re-test, y entrega un reporte final 100% verde. Activar en el paso 5 Verificación del flujo de 6 pasos, después de /revisar y REGLA DE ORO cierre-implementación. También activar cuando el usuario dice: 'validá el PRP', 'valida el PRP', 'armá el CSV', 'arma el CSV', 'armá el CSV de pruebas', 'arma el CSV de pruebas', 'corré la validación exhaustiva', 'corre la validacion exhaustiva', 'ejecutá el CSV', 'ejecuta el CSV', 'csv-validation', 'validar', 'verificá funcionamiento', 'verifica funcionamiento', 'pasamos al paso 5', 'validación exhaustiva', 'validacion exhaustiva', 'matriz CSV', '100% verde', 'validación final', 'validacion final'."
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, mcp__playwright__*, mcp__claude_ai_Supabase__*, mcp__next-devtools__*
---

> **⚙️ Stack adaptation banner.** Este SKILL es **template universal**. Los ejemplos concretos en el cuerpo asumen un stack típico (Next.js · Supabase · Playwright · GitHub Actions · Husky). Si tu proyecto usa otro stack, adaptá:
>
> - **MCP names** del frontmatter `allowed-tools` (`mcp__claude_ai_Supabase__*` · `mcp__playwright__*` · `mcp__next-devtools__*`) a los MCPs disponibles en tu proyecto.
> - **Patrones de código** mencionados en `## Process` (Server Actions · RLS policies · RPCs · revalidatePath · etc) al equivalente de tu framework.
> - **Tooling externo** (`npm run ci:local` · `bash scripts/local-ci.sh` · `gh pr merge`) a los comandos reales de tu proyecto.
>
> El **shape canónico P8** (Overview · When · Process · Anti-rationalization · Red flags · Verification) NO se altera · solo las referencias concretas a stack.

# Skill: `/validar` — paso 5 · Verificación del flujo de 6 pasos

> **Skill custom autocontenido** (Bif 1 = C · 🔵 user). Skill del paso 5 del flujo de 6 pasos · sustituyó al skill `/csv-validation` archivado · paridad estructural con los demás skills del flujo nuevo.
>
> **Inspiración estructural:** [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills) · ver [doctrina estructural compartida](../README.md#doctrina-estructural-compartida) en `skills/README.md` para convención de adaptación.
>
> **Anclaje filosófico:** Vibe Coding § 5 (snapshot inmutable [`vibe-coding-schluntz.md`](../../references/external-doctrine/vibe-coding-schluntz.md)) — cita literal en Overview.

## Overview

> **Propósito:** ejecutar validación exhaustiva de un PRP del producto vía matriz CSV completa con Playwright MCP + Supabase MCP + credenciales reales. El skill genera el CSV con el 100% de los casos del PRP · provisiona el entorno · ejecuta cada fila contra la app real · arregla cada `Falla` con un fix de calidad senior + spec PRINCIPIO 6 antes del re-test · entrega un reporte final 100% verde.
>
> **Posición en el flujo de 6 pasos:** paso 5 Verificación · post paso 4 Revisión (`/revisar`) · pre paso 6 Entrega (`/entregar`).
>
> **Predecesor obligatorio:** paso 4 Revisión cerrado (multi-agent paralelo `/revisar` con 9 agentes Opus + consolidator · 0 findings critical/normal/nit) · REGLA DE ORO cierre implementación cerrada (commit local con tests del DoD verdes · roadmap actualizado).
>
> **Sucesor obligatorio:** REGLA DE ORO cierre validación ([`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) · checklist 6 ítems con CSV reporte archivado · DT actualizado · memorias persistentes) → paso 6 Entrega (`/entregar` · run local CI 6/6 · push único · decisión `/ultrareview <PR#>` · merge `--squash` a `main`).
>
> **Cita Vibe Coding Paso 4 (SD-V2 · justificación filosófica del checkpoint shift-left):** *"Don't verify lines of code. Verify behavior. Set up mechanisms that tell you the system behaves correctly: stress tests, minimal end-to-end tests, system-level validations."* — verificá comportamiento, NO líneas. El paso 4 Revisión (`/revisar`) hace check estructural sobre el diff (multi-agent · architect · security · multi-tenant · etc); este paso 5 Verificación (`/validar`) hace check de comportamiento contra la app real (CSV exhaustivo · Playwright + Supabase MCPs · 100% verde como criterio binario). La doctrina vive en [`WORKFLOW.md § 3 Paso 5`](../../../WORKFLOW.md) (SoT) · este skill embebe el detalle del flujo en § Process.

## When

**Aplica a:** Modo C del flujo (PRP del producto en estado `EN PROGRESO` · post paso 4 Revisión cerrado · pre paso 6 Entrega · paso 7 REGLA DE ORO cierre implementación commiteado localmente).

**Cuándo activar:**

| Condición | Detalle |
|---|---|
| **Paso 4 cerrado** | `/revisar` ejecutado y reporte multi-agent consolidado con 0 critical/normal/nit pendientes. Si hay hallazgos abiertos: parar y fixearlos antes (regla [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md)). |
| **REGLA DE ORO cierre implementación cerrada** | Roadmap actualizado · PRP con criterios marcados · memorias nuevas en `.claude/memory/feedback\|reference\|project/` · MEMORY.md actualizado · DT abierta o cerrada · commit local con resumen + aprendizajes. |
| **PRP entregó código de aplicación** | Hubo cambios en `src/` · `db/migrations/` · Server Actions · RLS policies · UI · API endpoints. PRP puramente documental NO requiere validación CSV. |
| **User invoca con triggers** | *"validar"* · *"validá el PRP"* · *"armá el CSV"* · *"armá el CSV de pruebas"* · *"corré la validación exhaustiva"* · *"ejecutá el CSV"* · *"csv-validation"* · *"verificá funcionamiento"* · *"pasamos al paso 5"* · *"validación exhaustiva"* · *"matriz CSV"* · *"100% verde"* · *"validación final"* (SD-cos-N · español argentino LATAM-friendly · voseo). |

**NO activar:**

| Condición | Razón |
|---|---|
| **PRP sin código entregado** | PRP puramente documental o de definición · NO tiene comportamientos a validar contra la app. Saltar a REGLA DE ORO cierre validación con criterio "N/A · documental". |
| **Paso 4 Revisión NO cerrado** | El skill `/revisar` debe correr antes con su reporte consolidado · sin esto, validar comportamiento sin haber chequeado estructura es saltarse el shift-left. Resolver `/revisar` primero. |
| **REGLA DE ORO cierre implementación NO cerrada** | Sin cierre del paso 4 commiteado localmente, el código del PRP no está estable · validar sobre estado mid-flight produce reportes que no se pueden archivar. Resolver el cierre primero. |
| **Modo A o Modo B** | Tasks triviales (Modo A · ej: rename · 1 línea · adopciones livianas) o skills cerrados con flujo propio (Modo B · ej: `/add-emails` · `/website-3d`) NO usan validación CSV exhaustiva. |

## Process

> **Doctrina canónica:** descripción nominal del paso 5 vive en [`WORKFLOW.md § 3 Paso 5 · Verificación · skill /validar`](../../../WORKFLOW.md) (SoT). Este § Process embebe el flujo completo absorbido bit-perfect del `csv-validation` actual (reorganizado al shape P8) — el skill queda autocontenido y legible sin abrir WORKFLOW.md.

### Tabla de MCPs

| MCP | Para qué se usa |
|---|---|
| `mcp__playwright__*` | Navegación UI · interacción con la app real · screenshots de estados visuales · network requests · console messages. Ejecuta el 100% de las filas con interacción de UI. |
| `mcp__claude_ai_Supabase__*` | `execute_sql` para validar invariantes RLS · queries de audit log · creación de fixtures puntuales · `list_tables` / `list_migrations` / `get_advisors` / `get_logs` para diagnóstico durante fixes. |
| `mcp__next-devtools__*` (opcional) | Introspección de errores TS persistentes durante fixes Fase 4 (paridad SD-cos-N). Solo cuando el fix toca código con errores cross-file no triviales. |

---

### Reglas firmes que enmarcan el flujo (leyenda+link · NO embebidas · doctrina vive en los satélites · refinamiento iterativo upstream)

> Las reglas siguientes enmarcan el flujo completo del skill (Pasos 0-5) · doctrina vive en los satélites · este bloque solo lista leyenda+link para visibilidad inmediata.

> - [`register-out-of-scope-as-dt.md`](../../rules/register-out-of-scope-as-dt.md) — si durante Paso 4 (fix) el diagnóstico de root cause revela bug en módulo hermano fuera del scope del PRP actual, aplicar protocolo DT en el acto · 8 campos contractuales · sin esperar al cierre · sin esperar a confirmación · cero diferimiento silencioso (ya embebido inline en Paso 4 sub-paso · este bullet referencia + da visibilidad al boot del skill).
> - [`status-tracker-visible.md`](../../rules/status-tracker-visible.md) — `/validar` se invoca SIEMPRE en Modo C (paso 5 del flujo de 6 pasos) · el agente DEBE mantener el status tracker visible al inicio de cada respuesta principal con los 6 ítems canónicos hasta que el PRP cierre con paso 6 ejecutado · al arrancar `/validar` el tracker imprime `[ ] 5. /validar (CSV creado · ejecutado · 100% verde · reporte · regression-first FIRME) ← in_progress` · al cerrar Paso 5 con CSV 100% verde el tracker actualiza a `[✓] 5. /validar · X/X filas verde · reporte archivado`.
> - [`quality-standard-senior.md`](../../rules/quality-standard-senior.md) — los 6 puntos del estándar senior aplicados a cada fix del Paso 4 · sub-rule [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) gate Paso 0 firme.
> - [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md) — caso codificado en `tests/e2e/regression/` o `tests/sql/` ANTES del fix · 1-2 filas vecinas · paridad con PRINCIPIO 6 (regression-first FIRME).
> - [`no-suponer-fuente-de-verdad.md`](../../rules/no-suponer-fuente-de-verdad.md) — cero suposición sobre por qué un test falla · ir a fuente correcta (logs · diff · MCP queries) ANTES de diagnosticar root cause.
> - [`seed-upsert-with-fixed-id.md`](../../rules/seed-upsert-with-fixed-id.md) — re-aplicar el seed canónico ANTES del Setup del Paso 2 (PROVISIÓN) cuando los specs previos pudieron drift-ear state · seeds durables siguen patrón UPSERT con UUIDs fijos · ABORT si NO sigue patrón.

---

### Los 6 PRINCIPIOS FUNDAMENTALES — REGLAS SIN EXCEPCIÓN

Estas reglas NO son sugerencias. Son restricciones absolutas. Violar cualquiera invalida la validación completa.

#### PRINCIPIO 1 — COBERTURA TOTAL

**El CSV cubre el 100% de los comportamientos entregados por el PRP. Ningún caso se omite, ninguno se agrupa con otro, ninguno se considera implícito porque "es similar" a otro que ya se testeó.**

- Si dos casos tienen inputs diferentes, son dos filas diferentes.
- Si un caso tiene múltiples resultados esperables (UI + BD + audit log), son múltiples filas.
- Si el agente considera que un caso "ya está cubierto" por otro, está equivocado. Cada caso se ejecuta individualmente.
- La única excepción permitida para omitir un caso es que **requiera intervención humana absolutamente imposible de automatizar** (ej: abrir email físico en cliente externo · aprobar pago real con tarjeta). Si la automatización es técnicamente posible —aunque difícil— se automatiza. No se omite por comodidad.

#### PRINCIPIO 2 — EJECUCIÓN REAL, SIN INFERENCIAS

**Cada fila del CSV se ejecuta contra la aplicación real. Nunca se marca `Funciona` basándose en inferencia, revisión de código, o similitud con otro test.**

- "Este test es idéntico al anterior" → se ejecuta igual. Igual.
- "Puedo ver en el código que esto funciona" → no importa. Se ejecuta.
- "El paso anterior ya lo validó implícitamente" → no existe la validación implícita en este skill.
- "Asumo que funciona porque..." → PROHIBIDO. Si no se ejecutó, no está validado.

#### PRINCIPIO 3 — RESPUESTA BINARIA

**El Status de cada fila tiene exactamente 3 valores posibles:**

| Status | Significado |
|---|---|
| `Funciona` | El comportamiento observado coincide EXACTAMENTE con el Resultado esperado. Sin "más o menos", sin "básicamente", sin "razonablemente". |
| `Falla` | El comportamiento observado NO coincide. Se documenta qué se observó vs qué se esperaba. |
| `Diferido` | El caso NO se puede ejecutar en este PRP porque requiere un sistema externo no disponible (payment gateway real, email externo, etc.). REQUIERE justificación textual obligatoria en columna Notas Y un link a la TASK o PRP futuro donde se cierra. **NO es sinónimo de "me da trabajo", "no tengo ganas", o "es complicado".** |

Nada más. NO existe `Parcialmente funciona`. NO existe `Funcionó con advertencias`. NO existe `Funciona en el happy path`. Funciona o no funciona. Mapeo regla firme: [`goal-driven-execution.md`](../../rules/goal-driven-execution.md) — criterio binario · loop hasta verificarlo · cero ambigüedad.

#### PRINCIPIO 4 — FIX DE CALIDAD SENIOR

**Cuando una fila marca `Falla`, el fix que se aplica debe ser:**

- **Diagnóstico real:** identificar la causa raíz, no el síntoma. Si hay error en consola, se lee. Si hay HTTP 500, se investiga el server log. Si hay query que falla, se ejecuta en SQL y se analiza.
- **Solución definitiva:** arreglar la causa raíz, no parchear el síntoma. NO se comenta código que falla, NO se agrega `try/catch` que swallowea el error, NO se desactiva una validación para que pase.
- **Calidad de producción:** el fix debe poder pasar auditoría de seguridad, code review de un senior, y test de regresión. Si introduce deuda técnica, se documenta explícitamente y se crea TASK para resolverla.
- **Sin romper otras cosas:** antes de marcar el fix completo, identificar qué otras partes del sistema podrían verse afectadas y re-testear esas filas del CSV.

**Lo que NO es un fix aceptable:**

- ❌ Cambiar el "Resultado esperado" del CSV para que coincida con lo que hace el código.
- ❌ Marcar `Diferido` un caso que falla para evitar arreglarlo.
- ❌ Hacer un `// TODO: fix later` y marcar `Funciona`.
- ❌ Desactivar RLS temporalmente, remover validación, o bajar el estándar de seguridad.
- ❌ Un fix que solo funciona en desarrollo y no en producción.

Mapeo reglas firmes: [`quality-standard-senior.md`](../../rules/quality-standard-senior.md) (6 puntos del estándar · cero hardcode · cero copy-paste · cero código basura · simetría entre módulos hermanos) + [`surgical-changes.md`](../../rules/surgical-changes.md) (todo diff trazable al request · cero drive-by refactoring durante el fix).

**Checklist 6 puntos del estándar senior · OBLIGATORIO por cada fix (refinamiento iterativo upstream · materializa regla #8 [`quality-standard-senior.md`](../../rules/quality-standard-senior.md) como gate operativo de PRINCIPIO 4):**

Para CADA fila `Falla` post-fix · ANTES de re-ejecutar y marcar `Funciona`, evaluar el fix contra los 6 puntos del estándar (no solo contra los 4 atributos "Diagnóstico real · Solución definitiva · Calidad de producción · Sin romper" de arriba · esos son qualities del fix · los 6 puntos son chequeo del código resultante):

1. **Senior, profesional, sustentable.** Pensado · simétrico con el resto del módulo · con WHY si la solución no es obvia · sin atajos. Si el fix se sintió apurado o "hasta acá llego", re-trabajarlo en frío (sub-rule [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) aplicable · aviso al user antes de entregar mediocre).
2. **Cero hardcode.** Constantes mágicas → nombradas. UUIDs/slugs/shortcodes literales → fixtures/helpers. Strings de error inline → tablas centralizadas del módulo.
3. **Cero copy-paste.** Si la lógica del fix ya existe en otro módulo, extraer helper compartido o referenciar el patrón con WHY. Duplicar = divergencia futura garantizada (paridad con consolidator step 6 mini-checklist).
4. **Cero código basura.** Sin TODOs vacíos · sin `console.log` olvidados · sin código comentado "por si acaso" · sin variables sin uso · sin imports muertos. Cada línea defiende su derecho a existir.
5. **Con esfuerzo, nunca con fatiga.** Si el fix N+1 del batch se siente "apurada", parar es la respuesta correcta (sub-rule fatigue-self-evaluation · aviso canónico · NO entregar fix mediocre silenciosamente al CSV).
6. **Simetría entre módulos hermanos.** Si el bug toca `softDeleteX`, evaluar si `softDeleteY` tiene operación análoga que merece fix paralelo (cross-ref con `tests/e2e/regression/` de PRPs hermanos · paridad con PRINCIPIO 6 "1-2 filas vecinas" abajo).

**Acción binaria según resultado del checklist:**

| Estado por puntos | Acción |
|---|---|
| **6/6 puntos pasados** | Fix aceptable · re-ejecutar fila · marcar `Funciona` si el caso pasa end-to-end · spec PRINCIPIO 6 codificado ANTES del re-test |
| **1-2 puntos dudosos** | NO marcar `Funciona` · re-trabajar el fix hasta que el punto pase · paridad con consolidator `quality_review: PENDING` · cero "lo dejo así y veo" (regla #1 [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) § Anti-rationalization #1) |
| **3+ puntos rotos** | Fix mediocre · re-diseñar antes de tocar código · si este patrón aparece en horizonte de 5+ fixes consecutivos del batch CSV, activar fatigue self-evaluation (regla #7 indicador cualitativo #3 *"trabajo grande en sentada"*) + aviso canónico al user |

#### PRINCIPIO 5 — SOLICITAR LO QUE FALTA

**Si el agente no tiene acceso a algo necesario para ejecutar un caso, lo solicita. NO omite el caso.**

- No tiene credenciales → pide al usuario que las agregue al archivo de credenciales (ver § Credenciales y golden reference).
- No tiene acceso a una URL → pide al usuario que levante el servidor o confirme la URL correcta.
- No tiene datos de prueba en BD → los crea via Supabase MCP antes de ejecutar el caso.
- No tiene un permiso de tool → lo reporta al usuario antes de empezar, NO durante.

#### PRINCIPIO 6 — ACUMULACIÓN AUTOMÁTICA · CADA BUG ENCONTRADO DEJA UN TEST PERPETUO

**Cuando una fila marca `Falla` y se arregla con un fix, el caso de regresión correspondiente se codifica como spec Playwright (en `tests/e2e/regression/prp-NNN-<feature>.spec.ts`) o test SQL (en `tests/sql/`) ANTES de re-ejecutar la fila y marcarla `Funciona`.**

**Por qué este principio existe:**

- El CSV exhaustivo es write-only por naturaleza: se ejecuta una vez y nadie lo re-corre. Sin este principio, cada bug encontrado se "olvida" en el CSV archivado y la regresión cross-PRP queda invisible.
- Codificar el caso como spec/SQL lo lleva al suite acumulativo que CI ejecuta en cada PR (política "1 push = 1 PR = 1 CI" · ver `WORKFLOW.md § 6`) y que `npm run ci:local` ejecuta en el gate del paso 6 (Entrega). El bug nunca vuelve a pasar silenciosamente: el spec lo detecta automáticamente.
- El costo es ~2 minutos por bug. El beneficio es regresión automática a perpetuidad.

**Reglas operativas:**

1. **Cuándo aplica:** SOLO cuando una fila `Falla` y se arregla. Filas que pasan `Funciona` en el primer intento NO requieren spec adicional (ya están cubiertas por el DoD del paso 3 si aplica).
2. **Dónde codificar:**
   - Invariantes RLS multi-tenant, defense-in-depth de policies → `tests/sql/rls-invariants.sql` o archivo SQL específico del PRP.
   - Atomicidad RPC, Server Actions, validaciones cruzadas → `tests/e2e/regression/prp-NNN-<feature>.spec.ts`.
   - Audit log esperado tras operación → query SQL en `tests/sql/`.
   - UI / UX behavior crítico (no solo visual) → spec Playwright.
3. **Verificación obligatoria del spec antes de marcar `Funciona`:**
   - El spec debe **fallar** con el código bugueado (revertir mentalmente el fix → ¿el spec se pone rojo? si NO, no está testando lo correcto).
   - El spec debe **pasar** con el fix aplicado.
   - Si el spec siempre pasa o siempre falla → spec mal escrito; rehacer.
4. **Co-commiteo:** el spec nuevo va en el mismo commit que el fix. Mensaje: `fix(prp-NNN): <bug> + spec regresión [archivo:test]`.
5. **COVERAGE.md:** después del commit, actualizar `tests/e2e/regression/COVERAGE.md` con la fila nueva (archivo/tabla tocada → spec que la cubre). Sin actualizar COVERAGE.md, el siguiente PRP no sabrá que existe el spec heredado.

**Lo que NO es PRINCIPIO 6 aceptable:**

- ❌ Spec que duplica lo que el fix ya garantiza por construcción (ej: testar que un campo NOT NULL existe — eso lo testea el schema).
- ❌ Spec con `expect(true).toBe(true)` o tautologías equivalentes.
- ❌ Spec que solo testa el happy path cuando el bug era en un edge case.
- ❌ Skip / TODO / `xit` para "completar después" — si NO se codifica ahora, NO se codifica.

**Si codificar el spec lleva más de 15 minutos** (ej: requiere setup elaborado de fixtures, infra nueva de testing): documentar el bug en TASK del roadmap para spec deferido. La fila del CSV puede marcarse `Funciona` solo si: el fix está aplicado y verificado manualmente · existe TASK abierta con título "Spec regresión PRP-NNN/<bug>" · se documenta en columna Notas: "Spec deferido a TASK-NNN".

Mapeo reglas firmes: [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md) (caso codificado ANTES del fix · 1-2 filas vecinas con mismo root cause) + [`tests-as-dod-per-phase.md`](../../rules/tests-as-dod-per-phase.md) (DoD por bug arreglado · cada Falla deja test perpetuo).

**Heurística "1-2 filas vecinas" · OBLIGATORIA por cada Falla (refinamiento iterativo upstream · materializa regla #19 [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md) § Process operativa #2):**

Cuando una fila marca `Falla`, ANTES del fix agregar 1-2 filas vecinas al CSV que cubran casos adyacentes que el root cause podría tocar (regression-first FIRME · cero *"el caso original alcanza"*). El "vecino" comparte **root cause** con el original · NO es un caso cualquiera del CSV.

**Definición operativa de "fila vecina":** 1-2 casos que comparten root cause con el original via uno de estos 3 ejes:

| Eje | Patrón canónico |
|---|---|
| **Mismo path con distinto rol** | Si bug original es *"rolA accede a endpoint X y debería bloquear"*, vecino es *"rolB accede a endpoint X y también debería bloquear"* (asimetría de permission check entre roles). |
| **Misma policy con distinta condición** | Si bug original es *"policy RLS rechaza UPDATE silenciosamente"*, vecino es *"misma policy con DELETE"* (misma defense-in-depth · distinta operación) o *"misma policy en módulo hermano"* (asimetría cross-módulo). |
| **Mismo helper con distinto caller** | Si bug original es *"helper `formatA()` con input X falla por root cause Y"*, vecino es *"helper `formatB()` (hermano) con input similar"* o *"mismo helper con input Z distinto que comparte el root cause Y"*. |

**Ejemplos concretos (adaptar al stack del proyecto):**

- Bug original: `softDeleteX` no bloquea cuando hay registro en estado bloqueante → vecino: `softDeleteY` (mismo patrón de soft-delete en módulo hermano · simetría módulo-X↔módulo-Y · ej: en un dominio ticketing serían `softDeleteTicketType`↔`softDeleteProduct`).
- Bug original: policy RLS rechaza `UPDATE` silenciosamente al rol staff → vecino 1: misma policy con `DELETE` (operación hermana sobre misma tabla) · vecino 2: mismo policy en módulo soft-delete hermano (asimetría cross-módulo).
- Bug original: helper `formatA()` con ICU U+202F rompe hidratación → vecino: helper `formatB()` (mismo problema · cualquier helper que use `.toLocaleString` directo en JSX cae acá · ej: en un dominio ticketing serían `formatDateShortAR`↔`formatTimeARFull`).

**Anti-pattern · NO es fila vecina (prohibido):** (a) caso del CSV NO relacionado con el root cause del bug original (*"el siguiente caso del CSV"* NO califica como vecino) · (b) sumar caso que ya estaba previsto en cobertura original (no es "vecino" · es caso del CSV original que el agente había olvidado) · (c) sumar caso cuyo único punto en común es el archivo (el "vecino" requiere mismo root cause · NO mismo file).

**Cuándo aplicar 1 vs 2 vecinos:** 1 vecino cuando el root cause tiene 1 eje de variación claro (típico · default) · 2 vecinos cuando el root cause toca módulo hermano (eje "simetría cross-módulo" + 1 eje adicional típico). Por defecto: 1 vecino · subir a 2 solo si el bug original señala asimetría cross-módulo evidente (paridad con PRINCIPIO 4 punto 6 "Simetría entre módulos hermanos" · ambos atrapan el mismo vector desde distinto ángulo).

---

> **Las 6 fases del flujo del skill (Paso 0 pre-arranque + Pasos 1-5 ejecutivos):**

### Paso 0 — PRE-ARRANQUE · SELF-CHECK DE FATIGA · GATE FIRME

**Antes de arrancar el Paso 1 generación del CSV exhaustivo** (operación costosa · cientos de filas potencialmente · horas de wall time), invocar mentalmente la regla #7 [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) · auto-evaluar los 6 indicadores cualitativos contra MI estado actual:

1. Contexto cargado · re-leyendo archivos que ya leí hace 5+ turnos.
2. Ambigüedad creciente · improvisando criterios que antes eran claros.
3. Trabajo grande en una sentada · N acciones impecables + (N+1) se siente "apurada".
4. Confusión de scope · no estoy seguro si el cambio entra al PRP o es drive-by.
5. Decisiones repetidas · mismo tradeoff resuelto distinto cada vez.
6. Sensación de "terminemos" · prisa por cerrar antes de validar.

**Si ≥1 indicador dispara** → emitir aviso formato canónico (estimación 🟢/🟡/🔴 + caminos A continuar / B handoff + recomendación early con sujeto explícito = agente) · esperar decisión user · NO avanzar al Paso 1 sin firma explícita. Skill operativo bajo demanda: [`/fatiga`](../fatiga/SKILL.md). Si user firma B → invocar [`/handoff`](../handoff/SKILL.md) (regla #26 [`session-handoff.md`](../../rules/session-handoff.md) como SoT del shape canónico) para retomar `/validar` en sesión nueva (CSV preservado en `tests/manual/PRP-NNN_<slug>-validation.csv` si existe parcial).

**Si cero indicadores disparan** → continuar al Paso 1.

**Por qué gate obligatorio (NO opcional · refinamiento iterativo upstream):** `/validar` ejecuta el CSV exhaustivo contra la app real (cientos de filas potencialmente · Playwright MCP + Supabase MCP · fixes calidad senior + specs PRINCIPIO 6 por cada `Falla`). El work load se extiende horas. Arrancar fatigado degrada (a) la cobertura del CSV en Paso 1 (PRINCIPIO 1 cobertura total se relaja silenciosamente) · (b) el diagnóstico de fixes en Paso 4 (PRINCIPIO 4 calidad senior cede a parches superficiales) · (c) el spec PRINCIPIO 6 (regla #19 [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md) se incumple con tautologías). La regla #7 § Anti-rationalization #1 prohíbe explícitamente *"queda poco · sigo y cierro"* — esa anti-excusa aplica simétricamente al arranque (decidir entrar al pipeline costoso fatigado es el mismo error de juicio).

### Paso 1 — GENERACIÓN DEL CSV

**Objetivo:** crear `tests/manual/PRP-NNN_<slug>-validation.csv` con el 100% de los casos del PRP.

**Pre-condición operativa (proyecto recién booteado):** si `tests/manual/` NO existe en el repo (primer PRP del producto · cero CSV de referencia previo), **crear la carpeta + README canónico en este turno** (paridad regla [`folder-creation-with-readme.md`](../../rules/folder-creation-with-readme.md) shape: Qué es · Por qué se creó · Para qué sirve · README cumple obligación de doc inmediata). Auto-creación operativa del SKILL · NO requiere firma user nueva en cada PRP · excepción documentada explícita en ambas reglas firmes hermanas: [`folder-creation-with-readme.md`](../../rules/folder-creation-with-readme.md) § When NO aplica y [`respect-existing-folder-structure.md`](../../rules/respect-existing-folder-structure.md) § When NO aplica (paridad simétrica padre↔sub-carpeta · `tests/manual/` carpeta padre + `tests/manual/screenshots/PRP-NNN/` sub-carpeta · ambas las crea `/validar` automáticamente · cero contradicción con § Paso 3 firma user porque el README canónico se crea en el mismo turno).

**Proceso:**

1. Leer el PRP completo (`.claude/PRPs/PRP-NNN-*.md`) — objetivos, entregables, schema, fases, criterios de éxito.
2. Leer el CSV de referencia más reciente en `tests/manual/` (golden reference: `tests/manual/PRP-NNN_<feature>-validation.csv`) para mantener consistencia de formato y nivel de detalle.
3. Identificar todos los comportamientos entregados: tablas BD · RPCs · policies RLS · rutas Next.js · componentes · validaciones Zod · Server Actions · endpoints API · flujos de permisos.
4. Mapear cada comportamiento a uno o más casos de prueba concretos.
5. Agrupar los casos usando los grupos canónicos (ver [`references/canonical-groups.md`](references/canonical-groups.md)).
6. Generar el CSV con **filas vacías en columnas Fecha y Status** — se llenan durante la ejecución.

**Formato de columnas:** `ID,Grupo,Fecha,Status,Acción,Resultado esperado,Notas`

**Regla de ID:** prefijo del grupo + número correlativo (ej: `S1`, `MIG1`, `RLS1`, `NAV1`, `C1`). Ver [`references/canonical-groups.md`](references/canonical-groups.md) para la lista de prefijos.

**Criterio de completitud:** el CSV está listo cuando **todos los criterios de éxito del PRP tienen al menos una fila que los verifica directamente**. Si un criterio NO tiene fila, el CSV está incompleto.

**Validación previa al guardar:**

- ¿Existe al menos 1 grupo Setup?
- ¿Existe al menos 1 grupo Schema/MIG (si el PRP crea tablas)?
- ¿Existe al menos 1 grupo RLS (si el PRP crea o modifica policies)?
- ¿Están cubiertos los permisos negativos (qué NO puede hacer un observer · un anon · un tenant ajeno · ej: en un dominio ticketing sería un productor distinto al dueño del evento)?
- ¿Están cubiertos los edge cases de validación (inputs inválidos · campos vacíos · valores fuera de rango)?

### Paso 2 — PROVISIÓN

**Objetivo:** dejar el entorno listo para ejecutar el CSV de principio a fin sin interrupciones.

1. Verificar que el servidor de desarrollo está corriendo:

   ```bash
   curl -s -o /dev/null -w "%{http_code}" http://localhost:3000
   ```

   Si NO responde → informar al usuario y esperar que lo levante.

2. Verificar que las credenciales están disponibles en `tests/manual/.credentials.local.json`. Si NO → ver § Credenciales y golden reference.

3. **Re-aplicar seed durable de TEST DB para garantizar state canónico (regla [`seed-upsert-with-fixed-id.md`](../../rules/seed-upsert-with-fixed-id.md) · refinamiento iterativo upstream):** si el Setup del CSV depende de fixtures durables compartidos (ej: en un dominio ticketing serían events · event_dates · ticket_types · orders · vouchers · users · producers · adaptá a las tablas del proyecto), **re-aplicar `db/seeds/test/test-seed.sql` ANTES del Setup** (vía Supabase MCP `execute_sql` o `psql` directo). El UPSERT con UUIDs fijos + `ON CONFLICT (id) DO UPDATE SET <cols mutables>` garantiza que columnas mutables que specs previos drift-earon (ej: en un dominio ticketing serían `status` · `stock_remaining` · `paid_at` · `venue_id` · etc · adaptá a las columnas mutables del proyecto) vuelven a su valor canónico. Si el seed NO sigue el patrón UPSERT (uses `gen_random_uuid()` · O `ON CONFLICT DO NOTHING` · O las columnas mutables NO están en el SET) → ABORT del `/validar` · DT en el acto con disparador "seed sin UPSERT canónico bloquea validación reproducible" · regla #21 satélite es FIRME · cero excepción.

4. Leer el grupo Setup del CSV y ejecutarlo completo. Si algún paso de Setup falla → resolver antes de continuar con los demás grupos. Un Setup roto invalida todos los tests que dependen de él.

5. Crear directorio de screenshots:

   ```bash
   mkdir -p tests/manual/screenshots/PRP-NNN
   ```

### Paso 3 — EJECUCIÓN

**Objetivo:** correr cada fila del CSV en orden, de arriba a abajo, marcando Status y completando Fecha y Notas.

**Protocolo por fila:**

1. Leer la columna Acción.
2. Ejecutar la acción exactamente como está escrita — sin interpretar, sin abreviar, sin asumir.
3. Observar el resultado.
4. Comparar con columna Resultado esperado.
5. Marcar Status:
   - Si coincide exactamente → `Funciona`. Fecha = hoy.
   - Si NO coincide → `Falla`. Documentar en Notas qué se observó. Fecha = hoy.
   - Si es un caso que requiere intervención humana real e imposible de automatizar → `Diferido`. Documentar justificación + TASK/PRP futuro. Fecha = hoy.
6. Para filas de SQL via Supabase MCP: ejecutar el SQL exactamente, capturar el resultado, comparar.
7. Para filas de UI via Playwright MCP: navegar, interactuar, tomar screenshot si hay dudas, comparar estado visual con resultado esperado.
8. Actualizar el archivo CSV en disco después de cada fila (NO esperar al final).

**Sobre screenshots:**

- Tomar screenshot en casos de UI complejos · estados visuales · cuando el resultado esperado incluye elementos visuales específicos.
- Guardar en `tests/manual/screenshots/PRP-NNN/[ID]-[descripcion].png`.
- NO es necesario en casos puramente SQL.

**Sobre los datos de prueba:**

- Si un caso requiere datos que NO existen en BD, crearlos via Supabase MCP antes de ejecutar el caso.
- Documentar los IDs creados en columna Notas para que sean reproducibles.
- Si los datos creados interfieren con otros tests, limpiarlos al final del grupo correspondiente.

### Paso 4 — FIX Y REGRESIÓN

**Esta fase se ejecuta cada vez que una fila marca `Falla`.**

**Protocolo de fix:**

1. **Diagnóstico:** leer el error completo. Buscar en logs del servidor · consola del browser · respuesta HTTP · output de SQL. NO asumir la causa — verificarla.
2. **Root cause:** identificar el origen real del problema. Puede ser en: schema de BD · RLS policy · Server Action · validación Zod · componente React · middleware · query de Supabase · typing TypeScript.

   **Procedimiento DT en el acto · OBLIGATORIO (regla #24 [`register-out-of-scope-as-dt.md`](../../rules/register-out-of-scope-as-dt.md) · refinamiento iterativo upstream):** si el diagnóstico de root cause revela bug en módulo hermano fuera del scope del PRP actual (ej: el síntoma estaba en feature X pero la causa raíz vive en feature Y que NO toca el PRP), aplicar el siguiente protocolo SIN excepción · ANTES de aplicar fix o continuar con el siguiente sub-paso.

   **Auto-pregunta binaria al confirmar root cause:** *"¿La causa raíz está dentro del scope del PRP actual y puedo fixearla quirúrgicamente sin dispersar?"*

   - **SÍ → fixear ahora** en el flujo normal del Paso 4 (sub-pasos 3 al 9 · regression-first FIRME + PRINCIPIO 6).
   - **NO → DT en el acto · ANTES de continuar el sub-paso 3 (filas vecinas)** · agregar fila en `docs/logs/technical-debt.md` con los **8 campos contractuales obligatorios** (regla #24 § Process Paso 2):

      | Campo | Contenido obligatorio |
      |---|---|
      | **ID** | `DT-NNN` autoincremental (siguiente disponible · NO reusar IDs resueltas) |
      | **Síntoma** | 1-2 frases del observable que llevó al fix de la fila CSV (NO root cause · eso va en notas) |
      | **Archivo / área afectada** | Path concreto del módulo hermano · NO "el sistema" |
      | **PRP destino tentativo** | `PRP-XXX` si ya hay candidato · `ad-hoc futuro` si no · `mini-PRP separado` si es infra |
      | **Severidad estimada** | `critical` · `normal` · `nit` (paridad con severidad de `/revisar` y `/ultrareview`) |
      | **Mitigación temporal aplicada hoy** | Workaround aplicado en el módulo del PRP para que la fila CSV pueda marcarse `Funciona` mientras el root cause real espera al PRP destino · O `ninguna` |
      | **Disparador para cerrar** | Condición objetiva (ej: *"al refactorear módulo Y"* · *"cuando llegue PRP-NNN"*) |
      | **Detectada en sesión / commit** | Commit del fix aplicado al PRP actual + referencia a la fila CSV |

   **Criterio firme para "root cause está fuera de scope del PRP actual"** (regla #24 § Process Paso 1 · alguna de las 4 condiciones):

   1. Root cause vive en feature/stack/módulo distinto del que toca el PRP.
   2. Arreglar el root cause requiere decisiones de diseño que el PRP actual no firmó.
   3. Arreglar el root cause expande el diff más allá de lo trazable al fix de la fila CSV.
   4. Hay disparador objetivo para diferirlo.

   **Por qué DT en el acto:** la memoria del LLM NO persiste entre sesiones · solo `docs/logs/technical-debt.md` lo hace. Sin la fila DT, el root cause real queda invisible al próximo PRP que toque el módulo hermano · y el workaround aplicado se vuelve patrón silencioso. La fila CSV puede marcarse `Funciona` con workaround + DT documentada · NO sin DT.
3. **Filas vecinas (regression-first FIRME):** ANTES del fix, agregar 1-2 filas vecinas al CSV que cubran casos adyacentes que el root cause podría tocar (mismo path con distinto rol · misma policy con distinta condición · mismo helper con distinto caller). Ver [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md) para heurística de "filas vecinas".
4. **Fix:** escribir la solución que resuelve la causa raíz. El fix debe:
   - Pasar `npm run typecheck` y `npm run lint` sin errores.
   - NO desactivar validaciones existentes.
   - Seguir patrones establecidos del codebase (ver `.claude/memory/feedback/`).
   - Si requiere migración de BD → aplicarla via Supabase MCP y agregarla al repo en `db/migrations/`.
   - Sin tocar código ajeno al request ([`surgical-changes.md`](../../rules/surgical-changes.md) · todo diff trazable al fix).
5. **Codificar el caso como spec PRINCIPIO 6 + gate mecánico de timing (refinamiento iterativo upstream):** ANTES de re-test la fila, escribir el spec correspondiente en `tests/e2e/regression/prp-NNN-<feature>.spec.ts` (o test SQL en `tests/sql/`). Aplicar el **protocolo regression-first FIRME** ([`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md)) en este orden estricto:

   1. **Spec codificado primero** (en working tree · ANTES de aplicar el fix al código del scope).
   2. **Spec rojo pre-fix verificado** (correr el spec contra el código bugueado · debe fallar reproduciendo el bug · si pasa, el spec NO testea lo correcto · rehacer).
   3. **Fix aplicado** (sub-paso 4 anterior · root cause).
   4. **Spec verde post-fix verificado** (re-correr el spec contra el código fixeado · debe pasar).
   5. **Commit conjunto fix + spec** (sub-paso 9 abajo).

   **Gate mecánico OBLIGATORIO antes de marcar la fila CSV como `Funciona`:** ejecutar las 2 verificaciones binarias siguientes con Bash · ambas deben pasar · cero excepción:

   ```bash
   # 1. Spec existe en el repo como commit (NO solo en working tree)
   git log --oneline -1 -- tests/e2e/regression/prp-NNN-<feature>.spec.ts
   #   → debe retornar el commit del fix (no vacío)
   #   → si vacío: spec NO commiteado · NO marcar Funciona

   # 2. Spec tiene assertion activa (no placeholder · no tautología)
   git show HEAD:tests/e2e/regression/prp-NNN-<feature>.spec.ts | grep -E 'expect\(|assert\(|toBe\(|toEqual\(|toHaveBeenCalled'
   #   → debe retornar ≥1 assertion real
   #   → si vacío o solo expect(true).toBe(true): tautología · NO marcar Funciona
   ```

   **Si alguna verificación falla** → NO marcar la fila como `Funciona` · re-trabajar el spec hasta que ambas pasen · documentar el gap si el spec excede 15 min (regla operativa § PRINCIPIO 6 punto 5 · TASK abierta + nota explícita en columna Notas del CSV).

   **Por qué gate mecánico (NO solo verificación mental):** la verificación mental *"revertir mentalmente el fix"* es susceptible a sesgo confirmatorio del agente fatigado · el gate binario con `git log` + `git show` + `grep` elimina la subjetividad · si los 2 comandos no retornan output esperado, el spec NO cumple PRINCIPIO 6 y la fila NO avanza a `Funciona`. Esta verificación mecánica materializa el contrato regression-first FIRME como gate operativo del skill (paridad simétrica con el preflight bash determinístico del `/revisar` Paso 1 · ambos eliminan ambigüedad subjetiva). Para specs SQL en `tests/sql/`, adaptá el grep al patrón del SQL (`SELECT 1 WHERE NOT EXISTS` · `DO $$ ... ASSERT ... $$;` · etc · cero `SELECT 1;` aislado · cero comentario `-- TODO`).
6. **Re-test de la fila + vecinas:** ejecutar nuevamente la fila original que falló y las vecinas agregadas en paso 3. Si pasan → marcar `Funciona`.
7. **Regression check:** aplicar las heurísticas de [`references/regression-heuristics.md`](references/regression-heuristics.md) para identificar qué otras filas del CSV podrían haber sido afectadas por el fix. Re-ejecutar solo esas filas (NO todo el CSV).
8. **Actualizar COVERAGE.md:** agregar fila nueva al mapa `tests/e2e/regression/COVERAGE.md` (archivo/tabla tocada → spec que la cubre).
9. **Commit del fix + spec en el mismo commit:**

   ```text
   fix(prp-NNN): [descripción concisa del bug arreglado] + spec regresión [archivo:test-name]
   ```

**Si el fix NO se puede hacer correctamente en esta sesión:**

- NO marcar `Diferido` para evadir el trabajo (PRINCIPIO 3 + PRINCIPIO 4).
- Documentar el bug exactamente: qué falla · por qué · qué se intentó.
- Abrir TASK en el roadmap para el fix.
- Dejar la fila en `Falla` con link a la TASK.
- **NO se cierra el paso 5 del flujo hasta que todas las filas sean `Funciona` o `Diferido` justificado.**

### Paso 5 — REPORTE FINAL

**Objetivo:** generar el reporte de cierre del paso 5 una vez que el CSV está 100% verde.

**Criterio de "100% verde":**

- Todas las filas tienen Status `Funciona` o `Diferido`.
- Ninguna fila tiene Status `Falla` o vacío.
- Cada `Diferido` tiene justificación y link a TASK/PRP futuro.
- **Todos los specs PRINCIPIO 6 commiteados y verdes en CI** (uno por bug arreglado · salvo casos deferidos a TASK con justificación).
- **`tests/e2e/regression/COVERAGE.md` actualizado** con los specs nuevos del PRP (mapa archivo/tabla → spec).
- **Audit COVERAGE.md sync vs filesystem aplicado al cierre del Paso 5 (gate mecánico · refinamiento iterativo upstream · prerequisite regla #16 [`pre-validation-inherited-regression.md`](../../rules/pre-validation-inherited-regression.md)):** correr `find tests/e2e/regression -name "*.spec.ts" -type f | sort -u > /tmp/specs-physical.txt && grep -oE 'tests/e2e/regression/[A-Za-z0-9._-]+\.spec\.ts' tests/e2e/regression/COVERAGE.md | sort -u > /tmp/specs-coverage.txt && diff /tmp/specs-physical.txt /tmp/specs-coverage.txt` · si diff retorna ≥1 línea → desincronización detectada · agregar fila NUEVA al CSV (severidad `Falla`) con descripción *"COVERAGE.md desincronizado vs filesystem · spec X físico no indexado / fila Y de COVERAGE apunta a spec inexistente"* + bloquear cierre del paso 5 hasta resync · regla #16 § When ítem "COVERAGE.md sin entradas para los archivos del scope" depende de este índice sincronizado para gate level B.

**Formato del reporte** (mostrar al usuario antes de pasar a REGLA DE ORO cierre validación):

```markdown
## CSV Validation — PRP-NNN — Reporte Final

**Fecha:** [YYYY-MM-DD]
**CSV:** tests/manual/PRP-NNN_<slug>-validation.csv

### Resultados
| Status | Cantidad |
|---|---|
| ✅ Funciona | X |
| ⏸ Diferido | Y |
| Total | X+Y |

### Bugs encontrados y resueltos
- **[ID fila]** — [descripción del bug] → fix en commit [hash]
- [...]

### Casos diferidos
- **[ID fila]** — [justificación] → TASK-NNN
- [...]

### Screenshots disponibles
tests/manual/screenshots/PRP-NNN/
```

**Si quedan fixes pendientes para próxima sesión:** invocar [`/handoff`](../handoff/SKILL.md) para preservar contexto operativo (CSV actual · filas `Falla` restantes · specs PRINCIPIO 6 pendientes) · regla #26 [`session-handoff.md`](../../rules/session-handoff.md) como SoT del shape canónico.

Una vez generado el reporte y confirmado que todo está verde → el paso 5 se marca `✓` en el tracker → pasar a REGLA DE ORO cierre validación + paso 6 Entrega ([`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) · checklist 6 ítems al cierre).

---

### Credenciales y golden reference

- **Archivo de credenciales** (gitignored · NUNCA se commitea): `tests/manual/.credentials.local.json` con los roles del proyecto (ej: en un dominio ticketing serían productores · staff · super_admin · observers · adaptá a los roles de tu dominio). Template: [`references/credentials-template.json`](references/credentials-template.json).
- **Golden reference** (referencia canónica de nivel de detalle y formato esperado): `tests/manual/PRP-NNN_<feature>-validation.csv`.
- **Grupos canónicos** (prefijos S/MIG/RLS/NAV/C/...): [`references/canonical-groups.md`](references/canonical-groups.md).
- **Heurísticas de regresión** (qué re-testear después de cada tipo de fix): [`references/regression-heuristics.md`](references/regression-heuristics.md).

## Anti-rationalization

> 7 entradas (Bif 2 = B · 🔵 user): 3 derivadas de SD-V3 Vibe Coding + 4 específicas del paso 5 Verificación. Las 3 SD-V3 citan inline al snapshot inmutable [`vibe-coding-schluntz.md`](../../references/external-doctrine/vibe-coding-schluntz.md) § 5 *"Errores comunes (y cómo evitarlos)"* — paridad estructural con la doctrina Schluntz/Anthropic.

| Excusa | Rebuttal |
|---|---|
| **1. "Se ve que anda · marco Funciona sin ejecutar la fila"** | Sin verificación de comportamiento NO hay vibe coding responsable · hay solo rezar. Cita inline: [`vibe-coding-schluntz.md`](../../references/external-doctrine/vibe-coding-schluntz.md) § 5 línea *"Saltarse los checkpoints porque 'se ve que anda'. Sin verificación, no hay vibe coding responsable; hay solo rezar."* PRINCIPIO 2 contractual: cada fila se ejecuta contra la app real — sin excepción. |
| **2. "Saltarse los checkpoints porque el PRP es chico"** | Los checkpoints son la única capa entre IA implementando y prod · saltarlos invalida el paradigma. Cita inline: [`vibe-coding-schluntz.md`](../../references/external-doctrine/vibe-coding-schluntz.md) § 5 *"Saltarse los checkpoints porque 'se ve que anda'. Sin verificación, no hay vibe coding responsable; hay solo rezar."* "Chico" no es justificación: PRINCIPIO 1 cobertura total · PRINCIPIO 2 ejecución real · PRINCIPIO 6 acumulación automática. |
| **3. "Vibe codear sin experiencia previa en el dominio · me arriesgo igual"** | Si no podés distinguir qué es peligroso y qué es seguro, leaf vs core no se aplica · review humano completo. Cita inline: [`vibe-coding-schluntz.md`](../../references/external-doctrine/vibe-coding-schluntz.md) § 5 *"Vibe codear sin experiencia previa en el dominio. Si no podés distinguir qué es peligroso y qué es seguro, todavía no es para vos."* En este skill el agente tiene experiencia en el dominio (PRPs ya cerrados con paridad bit-perfect) — pero la regla aplica si aparece código nuevo cross-domain (ej: pagos · auth · multi-tenant): PRINCIPIO 4 fix calidad senior con diagnóstico real obligatorio. |
| **4. "Este caso es similar al anterior · agrupo en una fila"** | NO. PRINCIPIO 1 cobertura total · 1 fila por caso, sin agrupación por similitud. Si dos casos tienen inputs distintos, son dos filas distintas. La excusa "similar" es atajo cognitivo que esconde edge cases. Costo marginal de la fila extra: ~30s. Costo de no tenerla: bug latente que se descubre en producción. |
| **5. "El fix es trivial · marco Funciona sin codificar el spec PRINCIPIO 6"** | NO. PRINCIPIO 6 contractual · spec antes del re-test · sin spec verificado = no avanzar. "Trivial" hoy = regresión silenciosa cuando alguien refactore el archivo en 6 meses. El spec cuesta 2-5 minutos · garantiza regresión perpetua. Cross-reference firme: [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md) + [`tests-as-dod-per-phase.md`](../../rules/tests-as-dod-per-phase.md). |
| **5b. "El spec lo verifico mentalmente · no hace falta correr el gate mecánico `git log` + `git show \| grep`"** | NO. La verificación mental "revertí mentalmente el fix · el spec se pondría rojo" es susceptible a sesgo confirmatorio del agente fatigado · especialmente en sesiones largas con N fixes acumulados. El gate mecánico binario (Paso 4 sub-paso 5 · refinamiento iterativo upstream) cuesta 30 segundos de comandos bash · elimina la subjetividad · si los 2 comandos retornan output esperado el spec cumple PRINCIPIO 6 · si fallan la fila NO avanza. Paridad simétrica con el preflight bash determinístico de `/revisar` Paso 1 · ambos materializan el contrato como gate operativo del skill (cero juicio cualitativo). |
| **6. "El caso falló por timing · re-corro y marca verde sin investigar root cause"** | NO. PRINCIPIO 4 fix calidad senior · diagnóstico real obligatorio · cero re-corridas ciegas. Re-corrida ciega que pasa la 2ª vez es flakiness · NO es "estaba bien". Investigar root cause: ¿race condition? ¿webServer cold-compile? ¿fixture drift? Documentar la causa + fix determinístico. La regla [`quality-standard-senior.md`](../../rules/quality-standard-senior.md) se rompe acá si no aplicás diagnóstico. |
| **7. "Marco Diferido para evitar un fix difícil · justifico con timing"** | NO. PRINCIPIO 3 + PRINCIPIO 4 prohibido. `Diferido` es solo para sistemas externos NO automatizables (payment gateway real · email externo · clic físico en cuenta de Google). "Me da trabajo" / "es complicado" / "no tengo ganas" NO son justificación. Si el fix excede 15 min de spec PRINCIPIO 6, abrir TASK con título *"Spec regresión PRP-NNN/<bug>"* y dejar la fila `Falla` con link a TASK — NO `Diferido`. |
| **8. "El bug era trivial · skip checklist 6 puntos del estándar senior · marco Funciona y sigo"** | NO. PRINCIPIO 4 contractual + regla [`quality-standard-senior.md`](../../rules/quality-standard-senior.md) § Process: el checklist 6 puntos (1. senior/profesional/sustentable · 2. cero hardcode · 3. cero copy-paste · 4. cero código basura · 5. con esfuerzo nunca con fatiga · 6. simetría módulos hermanos) es **gate operativo** del PRINCIPIO 4 (tabla acción binaria: 6/6 verde · 1-2 dudosos requieren refactor · 3+ rotos = bug todavía abierto). "Trivial" es exactamente la racionalización que la regla atrapa: el fix-1-línea puede romper punto 2 (UUID hardcoded en spec) · punto 3 (copy-paste de helper existente) · punto 6 (asimetría con módulo hermano `softDeleteX` vs `softDeleteY`). Costo del checklist: ~2 min de scan visual del diff · costo de saltarlo: bug latente con interés compuesto (caso real bug UR-NNN asimetrías módulo-X↔módulo-Y · ej: product↔ticket en un dominio ticketing). Aplica a TODO fix · cero excepción por tamaño · sin verificar los 6 puntos NO se marca `Funciona`. |

## Red flags

Señales que disparan **FRENO inmediato** durante la validación. Si aparece cualquiera, parar y reportar — NO avanzar por inercia.

- 🚩 Estás por arrancar el Paso 1 GENERACIÓN DEL CSV sin haber ejecutado el self-check de fatiga del Paso 0 (regla #7 [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) · gate obligatorio · NO opcional).
- 🚩 Self-check de fatiga emitió aviso 🟡/🔴 y arrancaste el CSV exhaustivo sin firma del user en camino A continuar o B handoff.
- 🚩 Estás por marcar `Funciona` sin haber ejecutado la fila contra la app real (PRINCIPIO 2 violado).
- 🚩 Estás por marcar `Diferido` sin justificación textual + link a TASK/PRP futuro (PRINCIPIO 3 violado).
- 🚩 Estás por aplicar fix sin haber agregado 1-2 filas vecinas al CSV (regression-first FIRME · PRINCIPIO 6 + [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md)).
- 🚩 Estás por re-test la fila post-fix sin haber codificado el spec PRINCIPIO 6 antes (`tests/e2e/regression/` o `tests/sql/`).
- 🚩 El spec que escribiste pasa siempre o falla siempre (no testea lo correcto · revertir mentalmente el fix → ¿se pone rojo? si no, está mal escrito).
- 🚩 Estás por marcar la fila CSV como `Funciona` sin haber ejecutado el gate mecánico binario del Paso 4 sub-paso 5 (`git log --oneline -1 -- <spec>` retorna commit + `git show HEAD:<spec> | grep -E 'expect\(|assert\(|toBe\('` retorna assertion real).
- 🚩 El gate mecánico retornó vacío o solo `expect(true).toBe(true)` y vas a marcar `Funciona` igual (tautología detectada · regression-first FIRME violado).
- 🚩 Estás por commitear el fix SIN el spec PRINCIPIO 6 en el mismo commit (regla operativa contractual).
- 🚩 No actualizaste `tests/e2e/regression/COVERAGE.md` con la fila nueva del spec (el siguiente PRP NO sabrá que existe el spec heredado).
- 🚩 Vas a cerrar el paso 5 con filas en `Falla` o vacías (criterio 100% verde NO cumplido).
- 🚩 El reporte final omite bugs encontrados con commit hash · diferidos con TASK · screenshots disponibles.
- 🚩 No solicitaste credenciales/datos faltantes y omitiste filas por "no tengo acceso" (PRINCIPIO 5 prohibido · solicitar lo que falta es contractual).

## Verification

Checklist binaria al cierre del paso 5 — cada ítem es verificable mecánicamente o por inspección directa del CSV/repo.

- [ ] **Paso 0 self-check de fatiga ejecutado:** cero indicadores cualitativos disparando O aviso formato canónico emitido + user firmó camino A continuar (regla #7 [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) · gate obligatorio · NO opcional).
- [ ] CSV `tests/manual/PRP-NNN_<slug>-validation.csv` existe con 100% de filas marcadas `Funciona` o `Diferido` (cero `Falla` o vacías).
- [ ] Cada fila `Diferido` tiene justificación textual + link a TASK/PRP futuro en columna Notas.
- [ ] Cada bug arreglado durante FASE 4 tiene su spec PRINCIPIO 6 commiteado en el mismo commit que el fix (`tests/e2e/regression/prp-NNN-<feature>.spec.ts` o `tests/sql/`).
- [ ] Cada spec PRINCIPIO 6 falla pre-fix (revertir mentalmente → rojo) y pasa post-fix (verde verificado · no tautología).
- [ ] **Audit COVERAGE.md sync vs filesystem aplicado al cierre del Paso 5** (refinamiento iterativo upstream): `diff` entre `find tests/e2e/regression -name "*.spec.ts"` ordenado y `grep -oE 'tests/e2e/regression/[A-Za-z0-9._-]+\.spec\.ts' tests/e2e/regression/COVERAGE.md` ordenado retorna 0 líneas · si hay desincronización, finding agregado al CSV con severidad `Falla` y cierre del paso 5 bloqueado hasta resync (prerequisite regla #16 [`pre-validation-inherited-regression.md`](../../rules/pre-validation-inherited-regression.md) gate level B).
- [ ] **Gate mecánico binario aplicado por cada spec PRINCIPIO 6** (Paso 4 sub-paso 5 · refinamiento iterativo upstream): `git log --oneline -1 -- <spec>` retorna el commit del fix (no vacío) + `git show HEAD:<spec> | grep -E 'expect\(|assert\(|toBe\(|toEqual\('` retorna ≥1 assertion real (no tautología · no placeholder). Ambos comandos ejecutados antes de marcar la fila CSV como `Funciona`.
- [ ] `tests/e2e/regression/COVERAGE.md` actualizado con los specs nuevos del PRP (mapa archivo/tabla → spec).
- [ ] Reporte final formato canónico mostrado al usuario antes de avanzar a REGLA DE ORO cierre validación: Resultados (Funciona/Diferido/Total) · Bugs encontrados con commit hash · Casos diferidos con TASK · Screenshots disponibles.
- [ ] Cero hardcode introducido durante fixes ([`quality-standard-senior.md`](../../rules/quality-standard-senior.md) · constantes nombradas · fixtures explícitas · strings centralizados).
- [ ] Cero código basura en los fixes (sin `console.log` · sin TODOs vacíos · sin código comentado "por si acaso") · diff revisado antes del commit.
- [ ] Cada fix aplicado es trazable al request del CSV ([`surgical-changes.md`](../../rules/surgical-changes.md) · cero drive-by refactoring durante la validación).
- [ ] REGLA DE ORO cierre validación ejecutada al final ([`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) · checklist 6 ítems · roadmap actualizado · DT abierta o cerrada según corresponda · memorias persistentes con MEMORY.md actualizado · CSV reporte archivado · commit local con resumen + aprendizajes).

**Cross-reference firme:**

- SoT contractual: [`WORKFLOW.md § 3 Paso 5`](../../../WORKFLOW.md) + [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) ítem 4.5 (CSV es DUEÑO ÚNICO de este skill · NO se crea ni se ejecuta en pasos anteriores).
- Hermana operativa: [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md) (PRINCIPIO 6 contractual · spec antes del re-test + 1-2 filas vecinas · cero re-test sin spec).
- Hermana operativa: [`tests-as-dod-per-phase.md`](../../rules/tests-as-dod-per-phase.md) (specs PRINCIPIO 6 acumulan al suite `tests/e2e/regression/` o `tests/sql/` · COVERAGE.md actualizado).
- Hermana operativa: [`surgical-changes.md`](../../rules/surgical-changes.md) (cada fix trazable a la fila CSV · cero drive-by refactoring durante FASE 4).
- Hermana operativa: [`quality-standard-senior.md`](../../rules/quality-standard-senior.md) (PRINCIPIO 4 · 6 puntos del estándar aplicados a cada fix antes de marcar `Funciona`).
- Hermana operativa: [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) (Paso 0 self-check obligatorio antes de arrancar CSV exhaustivo · regla #9 gate).
- Hermana operativa: [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) (cero `Falla` al cierre · todos los bugs detectados se cierran con fix + spec antes del reporte 100% verde).
- Predecesor: skill [`/revisar`](../revisar/SKILL.md) (paso 4 · 0 hallazgos críticos/normales/nit-backlog requerido antes de arrancar `/validar`).
- Sucesor: skill [`/entregar`](../entregar/SKILL.md) (paso 6 · arranca cuando CSV cierra 100% verde + REGLA DE ORO cierre validación commiteada).
