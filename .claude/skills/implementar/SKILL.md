---
name: implementar
type: skill
description: "Ejecutar el bucle agentico por fases con checkpoints reversibles cuando un PRP esta APROBADO. Aplica los 5 pasos BLUEPRINT (delimitar fases, mapear contexto, ejecutar subtareas, transicionar, validacion final) + auto-blindaje hibrido + pre-validacion de regresion heredada como gate. Activar cuando el usuario dice: implementar, implementá, segui con la fase, seguí con la fase, arranca el bucle, arrancá el bucle, ejecuta el PRP, ejecutá el PRP, seguir con la implementacion, seguir con la implementación, construir esto, empeza la implementacion, empezá la implementación, siguiente fase del PRP, arranca implementar, arrancá implementar, ejecutar fases."
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - mcp__claude_ai_Supabase__list_tables
  - mcp__claude_ai_Supabase__execute_sql
  - mcp__claude_ai_Supabase__apply_migration
  - mcp__claude_ai_Supabase__get_logs
  - mcp__claude_ai_Supabase__get_advisors
  - mcp__playwright__browser_navigate
  - mcp__playwright__browser_snapshot
  - mcp__playwright__browser_click
  - mcp__playwright__browser_fill_form
  - mcp__playwright__browser_take_screenshot
  - mcp__next-devtools__nextjs_call
  - mcp__next-devtools__browser_eval
---

> **⚙️ Stack adaptation banner.** Este SKILL es **template universal**. Los ejemplos concretos en el cuerpo asumen un stack típico (Next.js · Supabase · Playwright · GitHub Actions · Husky). Si tu proyecto usa otro stack, adaptá:
>
> - **MCP names** del frontmatter `allowed-tools` (`mcp__claude_ai_Supabase__*` · `mcp__playwright__*` · `mcp__next-devtools__*`) a los MCPs disponibles en tu proyecto.
> - **Patrones de código** mencionados en `## Process` (Server Actions · RLS policies · RPCs · revalidatePath · etc) al equivalente de tu framework.
> - **Tooling externo** (`npm run ci:local` · `bash scripts/local-ci.sh` · `gh pr merge`) a los comandos reales de tu proyecto.
>
> El **shape canónico P8** (Overview · When · Process · Anti-rationalization · Red flags · Verification) NO se altera · solo las referencias concretas a stack.

# Skill: `/implementar` — paso 3 · Implementación del flujo de 6 pasos

> **Skill custom autocontenido.** Skill del paso 3 del flujo de 6 pasos · paridad estructural con `/arrancar` y `/planificar`.
>
> **Inspiración estructural:** [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills) · ver [doctrina estructural compartida](../README.md#doctrina-estructural-compartida) en `skills/README.md` para convención de adaptación.

## Overview

> **Propósito:** ejecutar el bucle agéntico por fases con checkpoints reversibles · auto-blindaje híbrido · DoD por fase · pre-validación de regresión heredada como gate · cuando un PRP de producto está en estado `APROBADO` o `EN PROGRESO`.

**Cuándo invocar:**

- **PRP aprobado · arrancar implementación** — `.claude/PRPs/PRP-NNN-*.md` en estado `APROBADO` (firmado por user en paso 2 · skill `/planificar`) · listo para ejecutar.
- **Continuar implementación de PRP en curso** — sesión nueva retoma trabajo previo · checkpoint o handoff existe en `.claude/memory/project/PRP-NNN-*.md` · arrancar desde el punto exacto de retoma.
- **Siguiente fase del bucle** — fase anterior cerrada con commit + checkpoint · arrancar Fase N+1 con re-mapeo de contexto.

**Qué NO hace:**

- ❌ NO planifica · NO genera PRPs (eso es paso 2 · skill [`/planificar`](../planificar/SKILL.md)).
- ❌ NO decide arquitectura solo · si aparece bifurcación arquitectónica no anticipada en el PRP, FRENA y pide firma 🔵 al user (regla FIRME modo de trabajo extendida).
- ❌ NO mergea ni hace push (eso es paso 6 · skill `/entregar`) · regla "1 push por PRP en paso 6" ([`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) #34).
- ❌ NO sustituye al `/validar` (paso 5) ni al `/revisar` (paso 4 del flujo · skills dedicados · `/revisar` embebe security-review como uno de sus 9 agentes paralelos).

## When

| Caso | Aplica `/implementar` |
|---|---|
| El user dice *"implementar"* · *"seguí con la fase"* · *"arrancá el bucle"* · *"ejecutá el PRP"* · *"seguir con la implementación"* · *"construir esto"* · *"empezá la implementación"* · *"siguiente fase del PRP"* · *"arranca implementar"* · *"ejecutar fases"* | ✅ SÍ |
| PRP del producto en estado `APROBADO` (firmado por user en paso 2) listo para arrancar Fase 1 | ✅ SÍ |
| PRP del producto en estado `EN PROGRESO` con checkpoint o handoff en `.claude/memory/project/` · sesión nueva retoma trabajo previo | ✅ SÍ (lectura previa de checkpoint/handoff · arrancar desde punto exacto de retoma) |
| Feature de **Modo C** del flujo ([`WORKFLOW.md § 5`](../../../WORKFLOW.md)) — múltiples archivos · multi-capa · fases que dependen una de otra | ✅ SÍ (sólo después de PRP aprobado · paso 2 cumplido) |
| PRP en estado `PENDIENTE` (sin firma del user) | ❌ NO (recordar al user que falta paso 2 · invocar `/planificar`) |
| Task de **Modo A** del flujo — task trivial · bien especificada en el roadmap · sin decisiones de arquitectura | ❌ NO (ejecutar directo · marcar `[ ]` → `[x]` en el roadmap) |
| Task de **Modo B** del flujo — encaja en un skill ya existente con flujo cerrado (ej: `/validar` · `/revisar`) | ❌ NO (invocar el skill correspondiente) |
| Bug fix puntual con root cause claro y scope acotado a 1-2 archivos | ❌ NO (fix directo · regression-first FIRME · sin bucle) |
| El user pide planificar antes (decisiones arquitectónicas abiertas · scope ambiguo) | ❌ NO (invocar `/planificar` · `/implementar` ejecuta PRP existente · NO genera) |

## Process

> **Skill autocontenido.** El § Process embebe los 5 pasos BLUEPRINT + Paso 0 pre-validación de regresión heredada + auto-blindaje híbrido + tabla MCPs híbrido sin requerir abrir WORKFLOW.md.
> **Cita inline de doctrina:** la descripción nominal del paso 3 vive en [`WORKFLOW.md § 3 Paso 3 · Implementación · skill /implementar`](../../../WORKFLOW.md) (SoT). Este skill **referencia** esa doctrina y **embebe** el detalle operativo del bucle. Cualquier cambio futuro en la descripción nominal del paso 3 se sincroniza con este skill.
> **Reglas firmes que enmarcan el flujo** (leyenda+link · NO embebidas · doctrina vive en los satélites):
>
> - [`pre-validation-inherited-regression.md`](../../rules/pre-validation-inherited-regression.md) — gate Paso 0 bloqueante · cruzar git diff main vs `tests/e2e/regression/COVERAGE.md` · correr specs heredados antes de Fase 1.
> - [`tests-as-dod-per-phase.md`](../../rules/tests-as-dod-per-phase.md) — cada fase cierra con 2-5 tests del DoD + `npm run typecheck` + `npm run build` verdes.
> - [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md) — bug detectado → caso codificado en `tests/e2e/regression/` o `tests/sql/` ANTES del fix · 1-2 filas vecinas.
> - [`goal-driven-execution.md`](../../rules/goal-driven-execution.md) — criterios de éxito binarios · loop hasta verificarlos · check binario por step.
> - [`surgical-changes.md`](../../rules/surgical-changes.md) — todo diff trazable al request · cero drive-by · matchear estilo del archivo destino.
> - [`simplicity-first.md`](../../rules/simplicity-first.md) — mínimo código que resuelve el problema · cero abstracciones especulativas sin caller real.
> - [`think-before-coding.md`](../../rules/think-before-coding.md) — listar asunciones · presentar interpretaciones múltiples · push back con approach más simple antes de codear.
> - [`quality-standard-senior.md`](../../rules/quality-standard-senior.md) — los 6 puntos del estándar senior aplicados a cada subtarea · sub-rule [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) cuando aplica.
> - [`migrations-idempotency.md`](../../rules/migrations-idempotency.md) — toda migración bajo `db/migrations/` es idempotente · aplicarla N veces produce el mismo resultado que aplicarla 1 vez · DDL · RLS policies · RPCs · seeds del schema (NO datos · esos siguen `seed-upsert-with-fixed-id`) · gate `bash scripts/test-migrations.sh` verde al cierre de la fase con DDL nueva.
> - [`no-suponer-fuente-de-verdad.md`](../../rules/no-suponer-fuente-de-verdad.md) — cero suposición · al mapear contexto Paso 2 ir a fuente correcta (proyecto = repo + memoria + MCPs · externa = docs oficiales) · NUNCA confiar en memoria del LLM como fuente única.
> - [`respect-existing-folder-structure.md`](../../rules/respect-existing-folder-structure.md) — estructura actual = baseline · cero creación silenciosa de carpetas durante subtareas del Paso 3 · sesgo FUERTE anti-raíz · cero `mkdir`/`Write`-con-path-nuevo sin haber validado que (a) ninguna carpeta existente cubre el rol semánticamente · (b) si genuinamente hay creación, default = subcarpeta dentro de carpeta padre razonable · cero carpeta nueva top-level sin firma 🔵 user.
> - [`routing-paths-in-english.md`](../../rules/routing-paths-in-english.md) — path segments y filenames del framework (Next.js App Router · equivalente) SIEMPRE en inglés · convención universal industria-estándar · cero `/<idioma-producto>/` en `src/app/` · cero mezcla idiomas en mismo árbol · gate check binario al cierre de fase con UI nueva o Server Action exportada.
> - [`seed-upsert-with-fixed-id.md`](../../rules/seed-upsert-with-fixed-id.md) — seeds durables (`db/seeds/test/test-seed.sql` o equivalente) usan UPSERT con UUIDs fijos + `ON CONFLICT (id) DO UPDATE SET <cols mutables>` · cero `gen_random_uuid()` · re-aplicar seed restaura state canónico cuando un spec previo lo drift-eó · aplica al cierre de fase que toca seed.
> - [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md) — el commit local del cierre de fase (Paso 5 último ítem) NO genera entry en `log.md` (fases son trabajo intermedio · excluidas por la regla) · PERO cuando se cierra la **última fase del PRP** y el PRP entero pasa a COMPLETADO (validación final del PRP), generar entry tipo `prp-close` en `.claude/memory/log.md` con sintaxis exacta `## [YYYY-MM-DD] prp-close \| PRP-NNN <título corto>` + Resumen + Refs (commit hash · PRP path) · append-only cronológico · cero modificación retroactiva · refinamiento iterativo upstream.

### Paso 0 · Pre-validación de regresión heredada (gate bloqueante)

> **Doctrina canónica:** [`pre-validation-inherited-regression.md`](../../rules/pre-validation-inherited-regression.md) · cita inline · skill referencia + ejecuta el procedimiento.
> **Por qué SIEMPRE como gate:** sin esto, los specs heredados quedan reactivos (CI los corre después del push, demasiado tarde). Si un spec heredado falla pre-fase, es bug introducido en commits previos no cubiertos por CI · confundirlo con bug del PRP nuevo te hace debuggear el lugar equivocado durante horas. Costo del gate: ~30s.

**Paso previo · clasificar gate level (matriz 4 escenarios):** antes de ejecutar los 5 sub-pasos canónicos, aplicar la matriz § "Escenarios y gate level" de la regla satélite [`pre-validation-inherited-regression.md`](../../rules/pre-validation-inherited-regression.md) (tabla canónica de 4 filas vive en la regla · NO se duplica acá para evitar drift cross-archivo · refinamiento iterativo upstream). Resumen 1-línea por escenario: A (docs-only + último merge verde ≤24h) → gate ligero · B (código producción + COVERAGE.md hit) → solo specs específicos · C (infra pura) → skip documentado · D (cualquier otro) → suite completo. Documentar 1 línea en el PRP qué escenario aplicó + SHA del último merge verde cuando aplica A o C.

**5 sub-pasos canónicos (cero detección runtime · ejecución mecánica · aplican según escenario clasificado):**

1. `git diff main --name-only` para listar archivos / tablas que el PRP va a tocar.
2. Cruzar contra `tests/<carpeta-de-regresión>/COVERAGE.md` (mapa archivo/tabla → spec heredado · tu proyecto genera este índice cuando acumula suite de regresión).
3. Para cada match, ejecutar el spec heredado localmente con `npm run test:e2e -- tests/e2e/regression/<spec>.spec.ts` (escenario B = solo matches · escenario D = suite completo).
4. Si alguno falla **antes** de tocar el código del PRP nuevo → alguien rompió código heredado en commits anteriores no cubiertos por CI. **Abrir incidente al inicio del bucle** (NO mezclar con trabajo del PRP). Agregar caso vecino al CSV del paso 5 (`/validar`) cuando aplique.
5. Si todos pasan → arrancar Fase 1.

**Escenarios A y C (skip / ligero):** documentar 1 línea en el PRP que el gate aplicó (ej: *"Paso 0 · escenario A · último merge verde `<SHA>` + commits intermedios docs-only · gate ligero sin correr suite E2E"*) · arrancar Fase 1.

### Paso 1 · DELIMITAR Y DESCOMPONER EN FASES (sin subtareas)

- Entender el problema FINAL completo del PRP (leer Blueprint del PRP en curso).
- Romper en FASES ordenadas cronológicamente · cada fase con tipo `🟢 reversible` o `🔴 punto-de-no-retorno`.
- Identificar dependencias entre fases (qué fase necesita salida de qué fase previa).
- **NO generar subtareas todavía** (las subtareas se generan al entrar en cada fase con contexto real · ver Paso 2).
- Registrar las fases en TodoWrite + status tracker visible al user (regla [`status-tracker-visible.md`](../../rules/status-tracker-visible.md)).

> **Carga del PRP en curso (SD-cos-N):** el skill lee `.claude/PRPs/PRP-NNN-*.md` (PRP del producto en estado APROBADO o EN PROGRESO) · NO un template (ese rol es de `/planificar`). Cero detección runtime · cero generación de PRP desde acá.

### Paso 2 · ENTRAR EN FASE N · MAPEAR CONTEXTO real · GENERAR subtareas

> **Innovación clave del BLUEPRINT** (metodología de fases con checkpoints reversibles · ver Paso 3.5 para detalle del skill que la introdujo): "No planifiques lo que no entiendes. Mapea contexto, luego planifica." Cada fase se planifica con información REAL del estado actual del sistema (incluyendo lo construido en fases anteriores) · NO sobre suposiciones tomadas al inicio del PRP.

ANTES de generar subtareas, mapear silenciosamente:

- **Codebase:** archivos/componentes existentes relacionados a la fase · patrones que el proyecto usa actualmente · código reusable. Aplica [`simplicity-first.md`](../../rules/simplicity-first.md) (reusar > recrear).
- **Base de Datos** (Supabase MCP cuando aplica · ver tabla MCPs Paso 3): `list_tables` · `execute_sql` para inspeccionar estructura · RLS policies activas · RPCs existentes.
- **Dependencias inter-fase:** qué se construyó en fases anteriores · qué se asume que ya existe · qué restricciones aplican.
- **Memoria persistente:** [`.claude/memory/MEMORY.md`](../../memory/MEMORY.md) feedback/reference relevante al área tocada por esta fase.
- **Memorias operativas de tooling críticas:** [`CLAUDE.md § Memorias operativas de tooling críticas`](../../../CLAUDE.md) lista las memorias `feedback/` que codifican gotchas de tooling NO cubiertos por reglas firmes (race typecheck post-Playwright · squash-merge dev divergence · skip-ci HEAD del PR · pooler flake · etc) · leerlas al boot del skill cuando la fase toca esas áreas evita reproducir gotchas conocidos.
- **Reglas firmes aplicables:** satélites en [`.claude/rules/`](../../rules/) que enmarcan el área (ej: reglas específicas del stack del proyecto).
- **Asunciones explícitas:** aplica [`think-before-coding.md`](../../rules/think-before-coding.md) — listar 1-líneas las asunciones implícitas que la fase tiene · presentar al user si hay ≥1 con tradeoff abierto.
- **Cero suposición · ir a fuente correcta (regla [`no-suponer-fuente-de-verdad.md`](../../rules/no-suponer-fuente-de-verdad.md) · refinamiento iterativo upstream):** antes de generar subtareas, auto-pregunta firme *"¿sé esto efectivamente o lo estoy suponiendo?"* por cada decisión técnica del mapeo. Si "lo supongo" → ir a fuente correcta según orden: **(A) cosas del proyecto:** archivos del repo (Read directo · grep/glob) → memoria persistente (`feedback/` · `reference/` · `project/` + MEMORY.md índice) → MCPs (Supabase MCP `list_tables`/`execute_sql`/`get_logs` · etc.) → preguntar al user. **(B) cosas externas (framework · API · servicio · convención):** docs oficiales (WebFetch URL canónica · MCPs específicos tipo `nextjs_docs` cuando existen) → memoria del proyecto como referencia (NO autoridad · siempre criterioso si la memoria es >1 mes y el tema cambia frecuente) → preguntar al user. **NUNCA memoria del LLM como fuente única** (puede estar stale · puede mezclar conceptos similares · cualquier decisión arquitectónica basada solo en eso es bug latente).

DESPUÉS de mapear, **GENERAR subtareas específicas** de la fase en TodoWrite + actualizar status tracker.

### Paso 3 · EJECUTAR SUBTAREAS DE LA FASE (con MCPs según tabla híbrido)

```text
WHILE subtareas pendientes en fase actual:
  1. Marcar subtarea como in_progress en TodoWrite.
  2. Ejecutar la subtarea respetando estándar senior (ver quality-standard-senior).
  3. Usar MCPs según tabla "MCP × caso de uso × obligatorio/opcional" abajo.
  4. Validar resultado:
     - Si hay error → AUTO-BLINDAJE HÍBRIDO (Paso 3.5 · ver tabla abajo).
     - Si está bien → marcar subtarea completed en TodoWrite.
  5. Siguiente subtarea.
Fase completada cuando todas las subtareas están done + DoD por fase verde.
```

**Estándar senior aplicado a cada subtarea** ([`quality-standard-senior.md`](../../rules/quality-standard-senior.md) · 6 puntos):

1. Senior · profesional · sustentable.
2. Cero hardcode (constantes nombradas · fixtures explícitas).
3. Cero copy-paste (helper extraído cuando ≥2 callers).
4. Cero código basura (sin TODOs vacíos · console.log olvidados · imports muertos).
5. Con esfuerzo, nunca con fatiga (sub-rule [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) · STOP + aviso al user antes de comprometer calidad · el user puede forzar el check manualmente vía skill [`/fatiga`](../fatiga/SKILL.md)).
6. Simetría con módulos hermanos (asimetrías = bugs en potencia).

**Cambios quirúrgicos** ([`surgical-changes.md`](../../rules/surgical-changes.md)): todo diff trazable a una subtarea de la fase · cero drive-by refactoring · matchear estilo del archivo destino · si descubrís dead code no relacionado, mencionarlo al user (NO borrarlo en silencio).

**Estructura de carpetas · cero creación silenciosa durante subtareas (regla [`respect-existing-folder-structure.md`](../../rules/respect-existing-folder-structure.md) · refinamiento iterativo upstream):** antes de cualquier `mkdir` · `Write` con path que crea carpeta · `git mv` a destino nuevo · creación implícita al escribir archivo · auto-pregunta firme: *"¿qué carpeta existente puede alojar esto?"*. Validación previa obligatoria en orden:

1. **Inventario de candidatas existentes** que cumplan el rol semánticamente (leer README de cada candidata cuando existe · regla #22).
2. **Si alguna existente cubre el rol** → usar esa · cero creación.
3. **Si ninguna cubre** → buscar carpeta padre razonable para subcarpeta nueva (sesgo FUERTE anti-raíz).
4. **Si genuinamente requiere carpeta nueva** → presentar al user (formato `metodologia-iteracion`: contexto · A/B/C · rec early con razón 1-frase · ¿OK?) + esperar firma 🔵 explícita ANTES de crear.
5. **Si user firma** → aplicar regla hermana #22 (`folder-creation-with-readme.md`): crear carpeta + `README.md` en su raíz con 3 secciones obligatorias (Qué es · Por qué se creó · Para qué sirve).

**Anti-pattern crítico (NO licencia para dumping):** reusar carpeta existente NO autoriza meter archivos que no encajan con el rol declarado de esa carpeta. Si el archivo no encaja semánticamente · proponer subcarpeta nueva dentro de carpeta padre razonable · NO forzar match en carpeta inadecuada.

**Tabla MCPs híbrido:**

> **Default:** agente usa MCPs según juicio (libertad). **Obligatorio** sólo en los 3 casos derivados de reglas firmes.

| MCP | Caso de uso | Obligatorio / Opcional |
|---|---|---|
| **Supabase MCP** (`list_tables` · `execute_sql` · `apply_migration` · `get_logs` · `get_advisors`) | Fase introduce schema nuevo · RLS nueva · RPC nueva · trigger · seed durable | **OBLIGATORIO** cuando la fase aplica DDL nueva o modifica policies (cumple [`tests-as-dod-per-phase.md § "DoD por tipo de fase"`](../../rules/tests-as-dod-per-phase.md) · query SQL en `tests/sql/` o verificación con `apply_migration` 2× idempotencia). Opcional para mapeo de contexto Paso 2 (`list_tables` · `execute_sql` para introspección read-only). |
| **Playwright MCP** (`browser_navigate` · `browser_snapshot` · `browser_click` · `browser_fill_form` · `browser_take_screenshot`) | Fase introduce UI nueva o regression-first PRINCIPIO 6 codifica spec E2E | **OBLIGATORIO** cuando regression-first FIRME ([`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md)) requiere spec en `tests/e2e/regression/` (validación visual + flujo end-to-end). Opcional para mapeo Paso 0 (corrida local de specs heredados antes de Fase 1) · validación visual ad-hoc durante ejecución de subtareas. |
| **Next.js MCP** (`nextjs_call` · `browser_eval`) | Errores TS persistentes que requieren introspección del compilador · errores Turbopack · `revalidatePath` con behavior inesperado | **OBLIGATORIO** cuando typecheck/build rompe con error opaco (TS2304 · TS2322 · errores RSC dynamic) y la lectura del stack trace no resuelve en ≤2 intentos. Opcional para validación general de "está corriendo el dev server" (eso lo hace `npm run dev` directo). |

> **Tabla NO exhaustiva:** si en el futuro se suma un 4to MCP relevante (ej: `<email-service>` MCP cuando se integre email transaccional), la tabla se actualiza en el PRP que introduzca el nuevo MCP.

**Goal-driven execution per subtarea** ([`goal-driven-execution.md`](../../rules/goal-driven-execution.md)): antes de implementar una subtarea ≥30 LoC nueva, escribir 1 línea de check binario verificable (ej: "spec X falla pre-fix · pasa post-fix · regresión heredada Y verde"). Si no existe criterio binario, frenar y definirlo · cero loops "creo que ya está".

**Procedimiento DT en el acto · OBLIGATORIO (regla #24 [`register-out-of-scope-as-dt.md`](../../rules/register-out-of-scope-as-dt.md) · refinamiento iterativo upstream):** cuando durante la ejecución de subtareas del Paso 3 (bucle agéntico · lectura de archivos vecinos · diagnóstico de fallas del DoD · grep cross-codebase del root cause Paso 5) el agente detecta hallazgos out-of-scope, aplicar el siguiente protocolo SIN excepción · ANTES de continuar con la subtarea que estaba haciendo.

**Auto-pregunta binaria al detectar cualquier hallazgo:** *"¿Esto está dentro del scope del PRP/fase actual y puedo fixearlo quirúrgicamente sin dispersar?"*

- **SÍ → fixear ahora** (regla #1 [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) + regla #19 [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md) regression-first FIRME · spec antes del fix · NO DT).
- **NO → DT en el acto · ANTES de continuar con la subtarea** · agregar fila en `docs/logs/technical-debt.md` con los **8 campos contractuales obligatorios** (regla #24 § Process Paso 2):

   | Campo | Contenido obligatorio |
   |---|---|
   | **ID** | `DT-NNN` autoincremental (siguiente disponible · NO reusar IDs resueltas) |
   | **Síntoma** | 1-2 frases del observable (NO root cause · eso va en notas) |
   | **Archivo / área afectada** | Path concreto o tabla/feature/módulo · NO "el sistema" |
   | **PRP destino tentativo** | `PRP-XXX` si ya hay candidato · `ad-hoc futuro` si no · `mini-PRP separado` si es infra |
   | **Severidad estimada** | `critical` · `normal` · `nit` (paridad con severidad de `/revisar` y `/ultrareview`) |
   | **Mitigación temporal aplicada hoy** | `ninguna` si no aplica · o descripción 1-frase del workaround |
   | **Disparador para cerrar** | Condición objetiva del cierre (ej: *"al migrar a `<payment-gateway>` real"* · *"al refactorear módulo X"* · *"cuando llegue PRP-NNN"*) |
   | **Detectada en sesión / commit** | Commit hash si aplica · o referencia a la sesión |

**Criterio firme para "está fuera de scope"** (regla #24 § Process Paso 1 · alguna de las 4 condiciones):

1. Bug pertenece a feature/stack/módulo distinto del scope actual.
2. Arreglarlo requiere decisiones de diseño que el PRP/tarea actual no firmó.
3. Arreglarlo expande el diff más allá de lo trazable al request actual (paridad regla [`surgical-changes.md`](../../rules/surgical-changes.md)).
4. Hay disparador objetivo para diferirlo.

**Por qué DT en el acto (NO al cierre):** la memoria del LLM NO persiste entre sesiones · solo `docs/logs/technical-debt.md` lo hace. *"Lo anoto al cierre"* es anti-pattern · al cierre se pierden detalles del síntoma · si la sesión se agota mid-flight la deuda nunca llega · la siguiente sesión arranca sin el bug en cabeza. Regla #24 § Anti-rationalization #1 contractual.

**Si la DT incluye patrón replicable** (gotcha · anti-pattern · convención violada) → sumar también memoria persistente en `.claude/memory/feedback/` o `reference/` + entrada en `MEMORY.md` (regla [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) ítem 4).

### Paso 3.5 · AUTO-BLINDAJE HÍBRIDO

> **Por qué híbrido:** alinea con regla firme `regression-first-on-fix.md` para bugs de producto · preserva el auto-blindaje 3-niveles del **BLUEPRINT viejo** (5 pasos canónicos + auto-blindaje 3-niveles + Error 1-3 anti-patterns) para gotchas de tooling · cero ambigüedad sobre dónde codificar el aprendizaje.

Cuando una subtarea falla, **clasificar el error binariamente** y aplicar la vía correspondiente:

**Tabla "tipo de error → vía de codificación":**

| Tipo de error | Vía de codificación | Detalle |
|---|---|---|
| **Bug de producto** (RLS · RPC · lógica de negocio · UI · render histórico · invariante de stock · multi-tenancy · auth · payments) | **Regression-first FIRME** ([`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md)) | Spec en `tests/e2e/regression/<prp>-<feature>.spec.ts` o `tests/sql/<feature>.sql` ANTES del fix · spec falla pre-fix (reproduce el bug) · pasa post-fix · 1-2 filas vecinas evaluadas (mismo root cause con distinto rol/policy/caller). |
| **Gotcha de tooling** (TS config · Turbopack · Husky hooks · build process · documentación · convención del codebase no testeable) | **Auto-blindaje 3-niveles** (preservado del BLUEPRINT viejo) | Documentación según alcance: (1) específico al PRP actual → § Aprendizajes / Self-Annealing del PRP. (2) aplica a múltiples features futuras → memoria persistente `feedback/` o `reference/` + entrada en MEMORY.md. (3) aplica a TODO el proyecto → banner CLAUDE.md (regla "NO Hacer" o sección dedicada). |

**Default si la duda es genuina:** regression-first FIRME (más conservador · cubre más casos · pierde solo gotchas de tooling no testeables · esos van a memoria persistente como segundo paso).

**Formato de documentación del aprendizaje** (ambas vías):

```markdown
### [YYYY-MM-DD]: [Título corto del gotcha]
- **Error:** [qué falló exactamente · stack trace o mensaje literal cuando aplica]
- **Root cause:** [por qué falló · análisis 1-2 frases]
- **Fix:** [cómo se arregló · referencia al spec/commit cuando aplica]
- **Aplicar en:** [dónde más aplica este conocimiento · regression-first SI/NO]
```

**El conocimiento persiste · el mismo error NUNCA ocurre dos veces** (principio del BLUEPRINT viejo · preservado).

**Auto-blindaje 3-niveles · decisión binaria del alcance (preservado del BLUEPRINT viejo · refinamiento iterativo upstream):**

Cuando la vía es **gotcha de tooling** (fila 2 de la tabla arriba), el agente clasifica el alcance del aprendizaje según este árbol:

1. **Nivel 1 · Específico al PRP actual** (el gotcha aplica SOLO a este PRP · no se repetirá fuera).
   - **Dónde codificar:** § Aprendizajes / Self-Annealing del propio PRP (`.claude/PRPs/PRP-NNN.md`).
   - **Ejemplo:** workaround temporal de configuración de tooling que solo aplica mientras este PRP toca el módulo X.
   - **Cuándo subir de nivel:** si en sesiones futuras detectás que el mismo gotcha aparece en otro PRP, promover a nivel 2 (memoria persistente).

2. **Nivel 2 · Aplica a múltiples features futuras** (el gotcha es transversal · puede aparecer en N PRPs futuros).
   - **Dónde codificar:** memoria persistente `.claude/memory/feedback/<topic>.md` (anti-patterns) o `.claude/memory/reference/<topic>.md` (punteros operativos) + entrada en `.claude/memory/MEMORY.md` (índice).
   - **Ejemplo:** race condition reproducible que el equipo paga cada vez que combina dev server + commit (multi-feature genuino · sobrevive a la sesión).
   - **Cuándo subir de nivel:** si el gotcha define cómo el proyecto entero debe trabajar (no solo cómo evitar un bug puntual), promover a nivel 3.

3. **Nivel 3 · Aplica a TODO el proyecto** (regla operativa universal · cambia la forma en que el agente trabaja en cualquier sesión).
   - **Dónde codificar:** banner del `CLAUDE.md` del proyecto (sección "NO Hacer" · "Reglas FIRMES" · o sección dedicada según convención del proyecto) · O regla satélite nueva en `.claude/rules/` con shape P8.
   - **Ejemplo:** convención canónica de helpers determinísticos para fechas en JSX descubierta después de N hydration mismatches por uso directo de APIs no-determinísticas en SSR.
   - **Cuándo NO subir de nivel:** si dudás entre 2 y 3, default = 2 (memoria persistente). Subir a banner / regla firme solo cuando el alcance es genuinamente universal · no como atajo para que el agente "no se olvide".

**Default si el alcance es ambiguo:** nivel 2 (memoria persistente). Más conservador que nivel 1 (perdés sesiones futuras si el gotcha vuelve a aparecer) · menos invasivo que nivel 3 (CLAUDE.md / reglas firmes NO son repositorio de gotchas · son contrato firme de cómo trabajar).

**Error 1-3 anti-patterns del BLUEPRINT viejo (preservados como red flags · cero excepción · refinamiento iterativo upstream):**

| # | Anti-pattern | Disparador típico | Costo de incurrir |
|---|---|---|---|
| Error 1 | Aplicar el fix sin clasificar el tipo de error (bug de producto vs gotcha de tooling) | Subtarea falla → `Edit` directo al fix sin pasar por la tabla de clasificación arriba | Fix de síntoma sin root cause · regresión silenciosa post-merge · spec heredado puede pescarlo en otro PRP (caro) |
| Error 2 | Codificar el aprendizaje en nivel equivocado del 3-niveles (ej: gotcha multi-feature codificado solo en § Aprendizajes del PRP) | *"Lo dejo en el PRP · si aparece de nuevo lo subo"* | El aprendizaje muere con el PRP · próxima sesión paga el mismo bug · principio "NUNCA dos veces" roto |
| Error 3 | Skip el re-mapeo de contexto entre fases (asumir que el contexto pre-fase sigue válido post-fase-anterior) | Cerrás Fase N → arrancás Fase N+1 sin re-correr Paso 2 (mapear contexto · ver Paso 4 abajo) | Subtareas de Fase N+1 ignoran lo construido en Fase N · contradicciones cross-fase · trabajo perdido · regla `pre-validation-inherited-regression` queda obsoleta |

### Paso 3.6 · Gate pre-commit · separación de commits cuando Paso 0 abrió incidente (refinamiento iterativo upstream)

> **Aplica cuando Paso 0 reportó spec heredado roto + incidente separado.** Antes del commit de la fase (típicamente Fase 1 · primera que entra al bucle post-Paso 0 · ver Paso 5 commit local), verificar mecánicamente que el staging NO incluye fix del spec heredado · paridad regla #16 [`pre-validation-inherited-regression.md`](../../rules/pre-validation-inherited-regression.md) § Verification ítem 4 (*"El commit de Fase 1 NO incluye fix de spec heredado roto · eso va en commit separado del incidente"*).

**Gate mecánico (cero excepción):**

1. `git diff --cached --name-only` (o `git status --porcelain` pre-stage) confirma que el staging contiene solo archivos del PRP actual · cero archivos del spec heredado roto · cero archivos del área del incidente abierto.
2. Si la verificación falla → **ABORT commit** · separar en 2 commits:
   - **Commit A** (PRP): `<tipo>(PRP-NNN): fase N · <título> · ...` con solo cambios de la fase actual.
   - **Commit B** (incidente): `fix(<área>): incidente <ID> · <título> · ...` con cross-ref al incidente abierto en Paso 0 + paths de specs heredados restaurados.
3. Si Paso 0 NO abrió incidente (escenarios A/B/C/D verdes de la matriz inline · ver Paso 0) → gate aplica trivialmente · staging del PRP nunca debería tener fix heredado · cero acción.

**Por qué este gate:** mezclar el fix del spec heredado con el commit de la fase del PRP rompe revert granular · revertir la fase por bug revierte también el fix del incidente · ciclo confuso post-mortem. Costo del gate: ~10s · costo de mezclar: debugear horas en el lugar equivocado en N meses (paridad rebuttal de § Anti-rationalization "spec heredado falló pre-fase · arranco igual y lo arreglo de paso").

### Paso 4 · TRANSICIONAR A SIGUIENTE FASE (con re-mapeo)

- Confirmar que la fase actual está REALMENTE completa (DoD por fase verde · ver Paso 5).
- **NO asumir** que todo salió como se planeó · verificar mecánicamente con typecheck + build verdes + tests del DoD.
- Si la fase es 🔴 punto-de-no-retorno (ej: migración SQL aplicada en cloud · archivado de archivos a `_archive/`): confirmar con el user antes de cerrarla.
- **Volver al Paso 2** con la siguiente fase · el contexto del mapeo ahora INCLUYE lo construido en la fase recién cerrada.
- **NO saltarse el re-mapeo entre fases** (anti-pattern Error 3 del BLUEPRINT viejo · `pre-validation-inherited-regression` queda obsoleta si el contexto no se refresca).

### Paso 5 · VALIDACIÓN FINAL · DoD por fase + commit local + checkpoint

> **Doctrina canónica:** [`tests-as-dod-per-phase.md`](../../rules/tests-as-dod-per-phase.md) · cita inline · cada fase del bucle cierra con código de producción + tests codificados que verifican los criterios de éxito de esa fase.

**Mapping tipo de fase → test esperado** (extracto · ver satélite para tabla completa):

| Tipo de fase | Test esperado |
|---|---|
| Invariantes RLS multi-tenant | Query SQL en `tests/sql/rls-invariants.sql` o archivo SQL específico del PRP. |
| Atomicidad de RPCs (crear · actualizar · eliminar · `<operaciones críticas del dominio>` · adaptá al stack transaccional del proyecto) | Spec de regresión en `tests/e2e/regression/prp-NNN-<feature>.spec.ts` (o equivalente del stack de testing). |
| Audit trail | Query SQL contra `audit_log` después de la operación. |
| Soft-delete + permisos por rol | Spec Playwright + query SQL. |
| Migración aplicada e idempotente | Verificar manualmente con Supabase MCP `apply_migration` 2× y comparar dumps (idempotencia). |

**Cuántos tests por fase:** 2-5 specs/queries por fase típica. **Total esperado por PRP:** 10-20 tests nuevos.

**Validaciones obligatorias al cierre de cada fase:**

- [ ] Subtareas todas en `completed` en TodoWrite.
- [ ] 2-5 tests del DoD codificados en `tests/e2e/regression/` o `tests/sql/` (cuando la fase entrega código de producto).
- [ ] `npm run typecheck` verde.
- [ ] `npm run build` verde.
- [ ] Si la fase aplicó migración: `bash scripts/test-migrations.sh` verde (idempotencia · regla [`migrations-idempotency.md`](../../rules/migrations-idempotency.md) FIRME · ver tabla de patrones idempotentes embebida abajo).
- [ ] Si la fase agregó UI nueva o Server Actions: **routing en inglés** (regla [`routing-paths-in-english.md`](../../rules/routing-paths-in-english.md) FIRME · refinamiento iterativo upstream) · gate check binario: `find src/app -type d -newer <prev-commit> | grep -E "/(<idioma-producto>|<localismo>)/"` retorna 0 matches · cada `page.tsx`/`route.ts`/`layout.tsx` nuevo bajo path en inglés · cada Server Action exportada nueva con verbo en inglés (`createX`/`updateX`/`deleteX` · NUNCA `crearX`/`actualizarX`/`borrarX`) · action namespaces de audit log en `snake_case` inglés (`event.created` · NO `evento.creado`) · copy de UI sigue regla ortogonal de localización del proyecto (idioma del producto).
- [ ] Status tracker actualizado con `[x]` en la fase cerrada.
- [ ] **Commit local** con mensaje `<tipo>(PRP-NNN): fase N · <título> · <resumen 1-frase>` (NO push · NO PR · regla satélite [`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) #27 "1 push por PRP en paso 6").
- [ ] **Checkpoint actualizado** en `.claude/memory/project/PRP-NNN-checkpoint.md` con estado al cierre (qué se hizo · qué viene · referencias a commits).

**Patrones idempotentes obligatorios por tipo de DDL (embebidos de regla #15 [`migrations-idempotency.md`](../../rules/migrations-idempotency.md) · refinamiento iterativo upstream):**

| Tipo | Patrón idempotente |
|---|---|
| **Table** | `CREATE TABLE IF NOT EXISTS <name> (...)` |
| **Column** | `ALTER TABLE <name> ADD COLUMN IF NOT EXISTS <col> <type>` |
| **Index** | `CREATE INDEX IF NOT EXISTS <name> ON <table>(<cols>)` |
| **Constraint** | Bloque `DO $$ BEGIN ... EXCEPTION WHEN duplicate_object THEN NULL; END $$;` o `ALTER TABLE ... DROP CONSTRAINT IF EXISTS <name>` antes del `ADD CONSTRAINT` |
| **Type / Enum** | `DO $$ BEGIN CREATE TYPE <name> AS ENUM (...); EXCEPTION WHEN duplicate_object THEN NULL; END $$;` |
| **Function / RPC** | `CREATE OR REPLACE FUNCTION <name>(...) RETURNS ... AS $$ ... $$ LANGUAGE plpgsql;` |
| **RLS Policy** | `DROP POLICY IF EXISTS <name> ON <table>;` ANTES de `CREATE POLICY <name> ON <table> ...` |
| **Trigger** | `DROP TRIGGER IF EXISTS <name> ON <table>;` ANTES de `CREATE TRIGGER ...` |
| **Comment** | `COMMENT ON ... IS '...'` (siempre idempotente) |

**Por qué embebido en el skill (NO solo cita):** los patrones son referencia operativa rápida del agente durante el bucle · sin esto, el agente improvisa el patrón "que recuerda" desde memoria del LLM · paridad regla [`no-suponer-fuente-de-verdad.md`](../../rules/no-suponer-fuente-de-verdad.md). Los 8 patrones cubren el 100% de DDL del stack Postgres/Supabase · si tu proyecto detecta un noveno tipo, agregarlo al satélite + sincronizar acá.

**Anti-pattern crítico (caso clásico):** `CREATE POLICY` sin `DROP POLICY IF EXISTS` previo NO actualiza policies preexistentes en cloud · queda shape stale silencioso · CI verde · cloud roto. Cuando tu proyecto pesque este caso, codificarlo como memoria persistente `feedback/migration-idempotente-no-actualiza-preexistentes.md`.

**Validación final del PRP entero (al cerrar la última fase):**

- [ ] Testing end-to-end del sistema completo cuando aplica · validación visual con Playwright MCP cuando la fase entregó UI.
- [ ] Confirmar que el problema ORIGINAL del PRP está resuelto (criterios de éxito del § Qué del PRP marcados).
- [ ] **Grep cross-codebase del root cause** (refinamiento iterativo upstream): identificar el patrón canónico del bug que cerró el PRP (ej: `\.toLocaleString\(` · `SECURITY DEFINER.*search_path` ausente · `CREATE POLICY` sin `DROP POLICY IF EXISTS` previo) + correr grep amplio en TODO `src/` (no solo el Inventario del PRP). Hallazgos fuera del Inventario → **DT en el acto** (regla #24 [`register-out-of-scope-as-dt.md`](../../rules/register-out-of-scope-as-dt.md) · 8 campos contractuales). Materializa los puntos 3 y 6 de la regla #8 [`quality-standard-senior.md`](../../rules/quality-standard-senior.md) (cero copy-paste · simetría entre módulos hermanos) + complementa regla #14 [`tests-as-dod-per-phase.md`](../../rules/tests-as-dod-per-phase.md) (los tests del DoD validan el PRP pero NO atrapan instancias hermanas fuera del Inventario · el grep cross-codebase es la red final). Sin este sub-paso, instancias hermanas del mismo bug quedan invisibles hasta que las pesque otro PRP por casualidad (caso real PRP-NNN · DT-NNN detectada por grep G4).
- [ ] **Contador tests vs meta 10-20** (refinamiento iterativo upstream · gate cuantitativo de regla [`tests-as-dod-per-phase.md`](../../rules/tests-as-dod-per-phase.md)): correr `git diff main --stat -- tests/e2e/regression/ tests/sql/ | tail -1` (o `git log main..HEAD --name-only -- tests/e2e/regression/ tests/sql/ | sort -u | wc -l`) y comparar con meta canónica del PRP (típicamente 10-20 tests nuevos cuando entrega código de producto · 2-5 por fase × N fases). Si `< 10` → revisar si alguna fase entregó código sin DoD (regla `tests-as-dod-per-phase.md` violada · cada fase debe cerrar con 2-5 tests) · si `> 20` → revisar si hay tests redundantes / over-engineering (regla [`simplicity-first.md`](../../rules/simplicity-first.md)). Documentar 1 línea en § Aprendizajes del PRP con el conteo final + relación con meta (ej: *"Cierre PRP-NNN · 14 tests nuevos · dentro de meta 10-20"*).
- [ ] **REGLA DE ORO 6 ítems aplicada al cierre del paso 3** (regla satélite [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) ítems 1-4 + 4.6 + 5 + 6 · cobertura útil ~6/8 según tabla "Mapping paso del flujo → ítems aplicables" · ítems 4.5 CSV y 4.7 ultrareview log quedan pendientes del paso 5 y paso 6 respectivamente · decisión arquitectónica 🔵 user).
- [ ] **Header del PRP actualizado a `EN PROGRESO (paso 3 cerrado · 4 + 5 + 6 pendientes)`** · NO a `COMPLETADO` (estado reservado a post-merge paso 6 · ver regla #18 § Mapping). El header se actualiza SOLO al cierre del paso completo · NO al cierre de cada fase intermedia (regla #25 § SoT del bookkeeping del flujo).
- [ ] Reportar al user qué se construyó · próxima acción según el flujo (paso 4 `/revisar` · paso 5 `/validar` · paso 6 `/entregar`).

### Continuidad multi-sesión (cuando aplica)

- **Cierre con checkpoint:** la fase está completa · queda contexto razonable para arrancar la siguiente · O el user pide cerrar sesión.
- **Handoff dedicado:** la fase NO está completa · O auto-evaluación de fatiga (≥30 turnos · ≥5 fases · sensación de "terminemos"). Genera `.claude/memory/project/PRP-NNN-handoff-<YYYY-MM-DD>.md` con punto exacto de retoma + contexto crítico + próxima acción + status tracker actual. Sub-rule [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) aplica. Skill [`/handoff`](../handoff/SKILL.md) genera el archivo bajo demanda · regla #26 [`session-handoff.md`](../../rules/session-handoff.md) como SoT del shape canónico de 7 secciones.
- **Backup automático:** hook `post-commit` hace `git push --quiet origin HEAD:dev-backup` · transparente · branch NO triggera CI.

## Anti-rationalization

> Excusas comunes que el agente puede racionalizar durante el bucle agéntico + rebuttal firme · refinamiento iterativo upstream consolidado del sub-bloque Anti-rationalization gaps.

| Excusa | Rebuttal |
|---|---|
| "Mi PRP no toca código heredado · skip Paso 0 pre-validación" | NO. Regla #16 [`pre-validation-inherited-regression.md`](../../rules/pre-validation-inherited-regression.md) § Anti-rationalization #1: la pre-validación es **barata (~30s)** y atrapa rotura silenciosa de commits previos no cubiertos por CI · saltarla normaliza el ruido en CI y deja al agente sin baseline confiable para distinguir bugs propios de heredados. Casi siempre el PRP toca archivos compartidos con PRPs previos (incluso si "no parece") · la matriz "escenarios → gate level" (A/B/C/D · ver Paso 0 inline) clasifica el contexto en 30s y decide gate apropiado · NO existe el escenario "skip silencioso porque PRP no toca código heredado" — solo escenario C (infra pura sin código de aplicación) admite skip y se documenta 1 línea en el PRP. |
| "El spec heredado falló pre-fase, pero seguro es por algo que voy a tocar yo · arranco Fase 1 igual y lo arreglo de paso" | NO. Un spec heredado roto **antes** de tocar el código del PRP es bug introducido en commits previos no cubiertos por CI · NO de tu trabajo. Mezclarlo con tu PRP confunde el root cause y te hace debuggear el lugar equivocado durante horas. **Abrir incidente separado al inicio del bucle** · dejar el spec heredado en el log · seguir con el PRP cuando esté verde. Costo del incidente: ~30 min · costo de mezclar: horas. |
| "Es un nit del fix · skip regression-first · entrego sin spec antes" | NO. [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md) FIRME: trivial hoy ≠ trivial en 6 meses. Sin caso codificado, el bug puede volver con cualquier refactor que toque el archivo. Costo del spec: ~5 min · costo de no tenerlo se cobra en producción. La regla "siempre fixear todo, con calidad senior" ([`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md)) NO admite diferimiento por severidad. |
| "El bug es de tooling (TS config · Turbopack), no es testeable · skip auto-blindaje · sigo de largo" | NO. Cuando el bug es genuinamente gotcha de tooling no testeable, la vía es **auto-blindaje 3-niveles** (NO skip). Documentación según alcance: específico al PRP → § Aprendizajes · multi-feature → memoria persistente `feedback/` o `reference/` · proyecto entero → banner CLAUDE.md. Saltarse el auto-blindaje rompe el principio "el mismo error NUNCA ocurre dos veces" del BLUEPRINT · y el equipo paga el bug en sesiones futuras. |
| "Los MCPs son opcionales · uso solo Read/Edit/Bash · más rápido" | NO. Default es libertad pero hay 3 casos OBLIGATORIOS derivados de reglas firmes. (1) Supabase MCP cuando la fase aplica DDL nueva · RLS · RPC (validación de idempotencia + DoD por tipo de fase). (2) Playwright MCP cuando regression-first PRINCIPIO 6 codifica spec E2E (validación end-to-end). (3) Next.js MCP cuando typecheck/build rompe con error opaco y la lectura del stack trace no resuelve en ≤2 intentos. Saltarse los obligatorios = entregar sin DoD validado. |
| "Salto el commit por fase · commiteo todo al final · más limpio" | NO. [`tests-as-dod-per-phase.md`](../../rules/tests-as-dod-per-phase.md) FIRME: cada fase cierra con commit local. Razones: (a) commit por fase es revertible directo si la siguiente fase rompe (`git revert <hash>` sin daño colateral). (b) Checkpoint actualizado per-fase es contrato con la próxima sesión (sin checkpoint, re-onboarding cuesta 30+ min). (c) Continuidad multi-sesión depende de commits granulares (handoff arranca desde el último commit · no desde "estado intermedio sin commit"). |
| "Skip el re-mapeo de contexto entre fases · ya conozco el codebase del PRP" | NO. Anti-pattern Error 3 del BLUEPRINT viejo: cada fase hereda el contexto de las anteriores (incluyendo lo recién construido). Skip el re-mapeo = generar subtareas sobre suposiciones del estado pre-fase, no del estado real post-fase-anterior. Costo del re-mapeo: ~2-5 min · costo de saltarlo: subtareas que ignoran lo que ya construiste y se contradicen con la Fase N-1. |
| "Encontré dead code en el archivo · lo borro de paso, total estoy acá" | NO. [`surgical-changes.md`](../../rules/surgical-changes.md) FIRME: todo diff trazable al request del PRP · cero drive-by refactoring. Mencionar el dead code al user al cierre · NO removerlo silenciosamente en el diff del PRP. La "limpieza colateral" se acumula sin review explícito y es donde nacen las regresiones. Si el dead code amerita eliminación, abrir DT en `docs/logs/technical-debt.md` con disparador. |
| "El PRP lista el CSV `tests/manual/PRP-NNN_*.csv` como entregable · lo creo al cierre del paso 3" | NO. **El CSV de validación lo crea y ejecuta el paso 5 `/validar` · NO el paso 3 `/implementar`.** En paso 3 solo se verifica que el PRP **lista** el CSV como entregable contractual del PRP entero. Crear el CSV en paso 3 con filas "Funciona" auto-asignadas pisa el rol del `/validar` (MCPs · credenciales reales · regression-first FIRME PRINCIPIO 6 · 100% verde validado end-to-end) y rompe la división de responsabilidades del flujo de 6 pasos. La REGLA DE ORO 6 ítems se **verifica al cierre del paso 5/6** (no del paso 3) · el ítem CSV se cumple cuando `/validar` lo deja 100% verde. Cuando tu proyecto pesque este anti-pattern, codificarlo como memoria persistente `feedback/csv-is-validar-not-implementar.md`. |
| "Cerré las N fases del Blueprint del paso 3 · marco el header del PRP como `COMPLETADO`" | NO. **El estado `COMPLETADO` se reserva para post-merge a `main` (paso 6 `/entregar`).** Al cerrar el bucle agéntico del paso 3, el header del PRP queda en `EN PROGRESO (paso 3 cerrado · 4 + 5 + 6 pendientes)`. Solo `/entregar` pasa el header a `COMPLETADO` cuando el PR está mergeado a `main` (o queda diferido con razón documentada). Marcar `COMPLETADO` al cierre del bucle del paso 3 es **cierre prematuro** · oculta que faltan paso 4 `/revisar` + paso 5 `/validar` + paso 6 `/entregar` · rompe la trazabilidad del flujo de 6 pasos y la regla [`status-tracker-visible.md`](../../rules/status-tracker-visible.md). Paridad simétrica con la fila CSV-es-validar-not-implementar (mismo incidente · 2 vectores). |

## Red flags

- 🚩 Estás por arrancar Fase 1 sin haber corrido el Paso 0 pre-validación de regresión heredada (gate bloqueante).
- 🚩 Un spec heredado falló en Paso 0 y NO abriste incidente separado · pensás "lo arreglo de paso con mi PRP" — anti-pattern que confunde root cause.
- 🚩 El bug que estás fixeando es de RLS / RPC / lógica de negocio (= bug de producto) y vas a aplicar el fix sin escribir spec en `tests/e2e/regression/` o `tests/sql/` antes (regression-first FIRME violado).
- 🚩 Subtarea ≥30 LoC nueva sin haber escrito 1 línea de check binario verificable antes de implementar (goal-driven-execution violado).
- 🚩 Cerraste una fase con typecheck o build rojo · "lo arreglo en la siguiente fase" — base inestable propaga errores cross-fase.
- 🚩 Cerraste una fase sin 2-5 tests del DoD codificados cuando la fase entregó código de producto (RLS · RPC · UI · render histórico).
- 🚩 La fase aplicó DDL nueva (migración · RLS · RPC) y NO usaste Supabase MCP `apply_migration` 2× para validar idempotencia (DoD por tipo de fase violado).
- 🚩 El diff de la fase incluye cambios fuera del scope del PRP · estás "limpiando" código adyacente sin OK del user.
- 🚩 La sesión lleva ≥30 turnos · ≥5 fases cerradas · sensación de "terminemos" — disparador inmediato de [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) · STOP + aviso al user antes de comprometer calidad.
- 🚩 El status tracker NO está actualizado al inicio de cada respuesta principal de la sesión (regla [`status-tracker-visible.md`](../../rules/status-tracker-visible.md) violada).
- 🚩 Estás por hacer push a `origin/dev` mid-fase · regla satélite [`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) #34 "1 push por PRP en paso 6" violada.
- 🚩 Estás por crear `tests/manual/PRP-NNN_*.csv` al cierre del paso 3 con filas "Funciona" auto-asignadas · ese artefacto pertenece al paso 5 `/validar` (no al paso 3 `/implementar`).
- 🚩 Estás por marcar el header del PRP como `COMPLETADO` al cerrar el bucle del paso 3 · ese estado se reserva para post-merge a `main` (paso 6 `/entregar`) · al cerrar paso 3 marcar `EN PROGRESO (paso 3 cerrado · 4 + 5 + 6 pendientes)`.

## Verification

- [ ] **Paso 0 corrido:** `git diff main --name-only` ejecutado · cruzado con `tests/e2e/regression/COVERAGE.md` · specs heredados matcheados corren verdes antes de arrancar Fase 1 · O excepción documentada (PRP de infra pura sin código de aplicación).
- [ ] **Paso 3.6 aplicado cuando Paso 0 abrió incidente:** `git diff --cached --name-only` confirma que el staging del commit de la fase (típicamente Fase 1) NO incluye archivos del spec heredado roto · si la verificación falla, commit separado del incidente con cross-ref a Paso 0 (paridad regla #16 § Verification ítem 4).
- [ ] **Cada fase cierra con commit local** + checkpoint actualizado en `.claude/memory/project/PRP-NNN-checkpoint.md` + status tracker con `[x]` en la fase cerrada.
- [ ] **Cada fase cierra con `npm run typecheck` + `npm run build` verdes** (regla [`tests-as-dod-per-phase.md`](../../rules/tests-as-dod-per-phase.md) FIRME · cero excepciones).
- [ ] **DoD por fase:** 2-5 tests del DoD codificados en `tests/e2e/regression/` o `tests/sql/` por fase típica · total esperado por PRP: 10-20 tests nuevos cuando entrega código de producto.
- [ ] **Contador tests-vs-meta-10-20 verificado al cierre del PRP entero** (gate cuantitativo · refinamiento iterativo upstream): `git diff main --name-only -- tests/e2e/regression/ tests/sql/` lista tests nuevos acumulados · count dentro de meta 10-20 · si `<10` revisar fases sin DoD · si `>20` revisar redundancia · conteo final + relación con meta documentado 1 línea en § Aprendizajes del PRP.
- [ ] **Auto-blindaje aplicado por error:** bug de producto → spec antes del fix + 1-2 filas vecinas evaluadas · gotcha de tooling → documentación 3-niveles según alcance (PRP § Aprendizajes / memoria persistente / banner CLAUDE.md).
- [ ] **MCPs obligatorios usados cuando aplica:** Supabase MCP en fases con DDL/RLS/RPC · Playwright MCP en fases con spec E2E regression-first · Next.js MCP en errores TS/build opacos no resueltos en ≤2 intentos.
- [ ] **Migraciones idempotentes (regla [`migrations-idempotency.md`](../../rules/migrations-idempotency.md)):** cada DDL de la fase usa el patrón idempotente correspondiente (8 tipos · tabla embebida en Paso 5) · `bash scripts/test-migrations.sh` verde local · `DROP POLICY IF EXISTS` antes de cualquier `CREATE POLICY` · `DROP TRIGGER IF EXISTS` antes de cualquier `CREATE TRIGGER` · cero `CREATE TABLE` sin `IF NOT EXISTS` · cero `CREATE TYPE` directo (siempre dentro de bloque `DO $$ EXCEPTION WHEN duplicate_object`).
- [ ] **Cero suposición durante mapeo Paso 2 (regla [`no-suponer-fuente-de-verdad.md`](../../rules/no-suponer-fuente-de-verdad.md)):** auto-pregunta firme *"¿sé esto efectivamente o lo estoy suponiendo?"* aplicada por cada decisión técnica del mapeo · fuente correcta consultada según orden (A=proyecto: repo → memoria → MCPs · B=externo: docs oficiales → memoria del proyecto como referencia) · cero memoria del LLM como fuente única en decisiones que generan código de producción · si fuente NO aclaró, hermana [`ante-duda-preguntar-user.md`](../../rules/ante-duda-preguntar-user.md) invocada con duda específica.
- [ ] **Cero creación silenciosa de carpetas durante subtareas Paso 3 (regla [`respect-existing-folder-structure.md`](../../rules/respect-existing-folder-structure.md)):** antes de cualquier `mkdir` · `Write` con path nuevo · `git mv` a destino nuevo · creación implícita al escribir archivo · auto-pregunta firme *"¿qué carpeta existente puede alojar esto?"* aplicada · inventario de candidatas existentes verificado (con lectura de READMEs cuando existen) · si genuinamente requiere carpeta nueva, firma 🔵 user explícita recibida ANTES de crear · creación con `README.md` raíz aplicando hermana regla #22.
- [ ] **Routing y filenames en inglés industria-estándar (regla [`routing-paths-in-english.md`](../../rules/routing-paths-in-english.md)):** path segments y filenames del framework (Next.js App Router · equivalente) en inglés · cero `/<idioma-producto>/` en `src/app/` · Server Actions exportadas con verbo inglés (`createX` · `updateX` · `deleteX`) · action namespaces de audit log en `snake_case` inglés · copy de UI sigue regla ortogonal de localización del producto · cero mezcla idiomas en mismo árbol del routing.
- [ ] **Seeds durables con UPSERT + UUID fijo (regla [`seed-upsert-with-fixed-id.md`](../../rules/seed-upsert-with-fixed-id.md)):** si la fase tocó `db/seeds/test/test-seed.sql` o equivalente · cada `INSERT` tiene UUID hardcoded literal (cero `gen_random_uuid()`) + `ON CONFLICT (id) DO UPDATE SET <cols mutables>` · columnas en `DO UPDATE SET` son solo las mutables (ej: en un dominio ticketing serían status · stock · venue_id · paid_at · etc · adaptá a las columnas mutables del proyecto · NUNCA `created_at` ni inmutables) · re-aplicar el seed restaura state canónico cuando un spec previo lo drift-eó · si tu proyecto tiene spec SQL `tests/sql/dt-NNN-seed-upsert-restores-canonical.sql` (o equivalente) · ejecutar verde antes del commit (regression-first FIRME).
- [ ] **Validación final del PRP entero:** criterios de éxito del § Qué del PRP marcados · sistema end-to-end testeado cuando aplica · validación visual con Playwright MCP cuando entregó UI.
- [ ] **Continuidad multi-sesión:** si la sesión se agota mid-fase → handoff dedicado en `.claude/memory/project/PRP-NNN-handoff-<YYYY-MM-DD>.md` con punto exacto de retoma · si fase cerrada → checkpoint actualizado + tracker `[x]`.

**Cross-reference firme:**

- SoT contractual: [`WORKFLOW.md § 3 Paso 3`](../../../WORKFLOW.md) (bucle agéntico por fases con checkpoints reversibles).
- Hermana operativa: [`pre-validation-inherited-regression.md`](../../rules/pre-validation-inherited-regression.md) (Paso 0 gate · cruzar archivos del PRP contra COVERAGE.md antes de arrancar Fase 1).
- Hermana operativa: [`tests-as-dod-per-phase.md`](../../rules/tests-as-dod-per-phase.md) (cada fase cierra con 2-5 tests codificados + typecheck/build verde · meta 10-20 tests por PRP).
- Hermana operativa: [`surgical-changes.md`](../../rules/surgical-changes.md) (cada diff trazable al request · cero drive-by refactoring durante el bucle).
- Hermana operativa: [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md) (bug detectado durante bucle · spec antes del fix + 1-2 filas vecinas evaluadas).
- Hermana operativa: [`simplicity-first.md`](../../rules/simplicity-first.md) (mínimo código que resuelve · cero abstracciones especulativas sin caller real).
- Hermana operativa: [`quality-standard-senior.md`](../../rules/quality-standard-senior.md) (6 puntos del estándar aplicados a cada commit del bucle · cero hardcode · cero copy-paste · cero código basura · simetría módulos hermanos).
- Hermana operativa: [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) (auto-evaluación obligatoria entre fases largas · disparador típico del handoff multi-sesión).
- Predecesor: skill [`/planificar`](../planificar/SKILL.md) (paso 2 · PRP `APROBADO` con bifurcaciones firmadas 🔵).
- Sucesor: skill [`/revisar`](../revisar/SKILL.md) (paso 4 · multi-agent review post-cierre del bucle).
