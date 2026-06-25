---
name: planificar-simple
type: skill
description: "Planificar una feature simple antes de implementarla · variante reducida de /planificar para scope acotado (≤2 capas · ≤5 archivos · sin decisiones arquitectónicas abiertas). Genera un mini-PRP con shape canónico del template prp-base.md. Sin multi-agent · sin spawn de personas pre/post-draft · sin gate complejidad ALTA explícito. Si mid-skill se detectan señales de complejidad, escala a /planificar completo. Activar cuando el usuario dice: planificá simple, planificá rápido, planeá simple, planeá rápido, armá un mini-PRP, mini-PRP, PRP simple, PRP rápido, planificá esto · es chico, planificá esto · es simple, planificación liviana, planeá liviano, planeá liviana."
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

> **⚙️ Stack adaptation banner.** Este SKILL es **template universal**. Los ejemplos concretos en el cuerpo asumen un stack típico (Next.js · Supabase · Playwright · GitHub Actions · Husky). Si tu proyecto usa otro stack, adaptá MCP names + patrones + tooling según el banner común del pack. El **shape canónico P8** (Overview · When · Process · Anti-rationalization · Red flags · Verification) NO se altera.

# Skill: `/planificar-simple` — paso 2 (variante simple) · Planificación rápida del flujo de 6 pasos

> **Skill custom autocontenido · variante reducida de [`/planificar`](../planificar/SKILL.md).** Mismo rol estructural (paso 2 del flujo de 6 pasos · genera PRP firmado antes de implementar) pero con proceso simplificado para features acotadas. Sin multi-agent · sin spawn de personas pre-draft · sin skeptic post-draft · sin gate complejidad ALTA explícito (irrelevante cuando el scope ya es acotado por contrato del skill).
>
> **Inspiración estructural:** [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills) · ver [doctrina estructural compartida](../README.md#doctrina-estructural-compartida).

## Overview

> **Propósito:** generar un mini-PRP para una feature acotada del producto en 4 pasos (vs 8 del skill completo) · cero multi-agent · cero overhead cuando la complejidad real es BAJA. Si durante el proceso aparecen señales de complejidad MEDIA/ALTA o decisiones arquitectónicas no anticipadas, el skill **escala** a [`/planificar`](../planificar/SKILL.md) completo con firma explícita del user · cero degradación silenciosa de la calidad del PRP.

**Cuándo invocar:**

- **Triggers explícitos del user** — *"planificá simple"* · *"planificá rápido"* · *"armá un mini-PRP"* · *"PRP simple"* · *"planificá esto · es chico"*.
- **Auto-orient del agente principal** — `/arrancar` Paso 4 detectó Modo C-simple (≤2 capas · ≤5 archivos · sin decisiones arquitectónicas abiertas) y el user firmó la propuesta antes de invocar.
- **Bug fix con scope >1 archivo pero claro** — root cause identificado · 2-3 archivos tocados · regression-first FIRME aplica pero la decisión de fases vale documentar en PRP corto.

**Qué NO hace:**

- ❌ NO implementa código (eso es paso 3 · skill `/implementar`).
- ❌ NO ejecuta migraciones ni tests reales.
- ❌ NO mergea ni pushea (eso es paso 6 · skill `/entregar`).
- ❌ NO decide bifurcaciones arquitectónicas solo · si aparecen mid-proceso → escalación a `/planificar` completo.
- ❌ NO spawnea sub-agentes (cero `Task` calls · `allowed-tools` lo excluye intencionalmente).

## When

| Caso | Aplica `/planificar-simple` |
|---|---|
| El user dice triggers explícitos *"planificá simple"* · *"PRP rápido"* · *"mini-PRP"* · etc | ✅ SÍ |
| `/arrancar` Paso 4 propuso Modo C-simple y el user firmó | ✅ SÍ |
| Feature acotada: ≤2 capas (ej: solo UI · solo BD · UI+helper) · ≤5 archivos · sin decisiones arquitectónicas abiertas | ✅ SÍ |
| Refactor mecánico con scope conocido (rename · adopción de patrón existente · extracción de helper para 2 callers) | ✅ SÍ |
| Bug fix con root cause claro pero scope >1 archivo (vale documentar en mini-PRP corto) | ✅ SÍ |
| Feature **multi-capa** con BD + API + UI coordinados | ❌ NO → escalar a [`/planificar`](../planificar/SKILL.md) completo |
| Feature con **≥1 decisión arquitectónica abierta** (patrón nuevo · trade-off real entre opciones) | ❌ NO → escalar a [`/planificar`](../planificar/SKILL.md) completo |
| Feature de **complejidad MEDIA o ALTA** (≥3 tablas · ≥3 pantallas · reglas con override · sincronizaciones) | ❌ NO → escalar a [`/planificar`](../planificar/SKILL.md) completo (regla #13 [`complejidad.md`](../../rules/complejidad.md)) |
| Bug fix puntual con root cause claro y scope 1 archivo | ❌ NO → fix directo + regression-first FIRME ([`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md)) |
| Task de **Modo A** del flujo · trivial · bien especificada en roadmap | ❌ NO → ejecutar directo · marcar `[ ]` → `[x]` |

## Process

> **Skill autocontenido · 4 pasos vs 8 del skill completo.** Las reglas firmes que enmarcan el flujo son las mismas que [`/planificar`](../planificar/SKILL.md) (referencias por leyenda · doctrina vive en los satélites): [`think-before-coding`](../../rules/think-before-coding.md) · [`simplicity-first`](../../rules/simplicity-first.md) · [`goal-driven-execution`](../../rules/goal-driven-execution.md) · [`surgical-changes`](../../rules/surgical-changes.md) · [`no-suponer-fuente-de-verdad`](../../rules/no-suponer-fuente-de-verdad.md) · [`ante-duda-preguntar-user`](../../rules/ante-duda-preguntar-user.md) · [`respect-existing-folder-structure`](../../rules/respect-existing-folder-structure.md) · [`golden-rule-docs-memory`](../../rules/golden-rule-docs-memory.md).

### Paso 1 · Lectura del template + investigación contextual mínima (~2-5 min)

- Leer `.claude/PRPs/prp-base.md` (template canónico del PRP · mismo que `/planificar` completo · cero divergencia de shape entre simple y complejo). Estructura esperada: **Objetivo · Por Qué · Qué + Criterios de Éxito · Contexto · Blueprint · Aprendizajes / Self-Annealing**.
- Mapeo silencioso mínimo (cero spawn de personas · agente principal investiga directo):
  - **Codebase:** archivos que la feature toca directamente (`grep`/`glob` targeted · NO inventario exhaustivo del repo).
  - **Roadmap:** [`docs/product/product-roadmap.md`](../../../docs/product/product-roadmap.md) — task del roadmap a la que el mini-PRP responde (si aplica · puede ser trabajo emergente sin task).
  - **Memoria persistente:** [`.claude/memory/MEMORY.md`](../../memory/MEMORY.md) — entries del `feedback/` o `reference/` aplicables al área tocada.
  - **PRPs históricos:** `ls .claude/PRPs/PRP-*.md | tail -5` para encontrar precedentes recientes con shape similar.
  - **DT activas:** `docs/logs/technical-debt.md` § Activas — DT que la feature podría cerrar (oportunidad de scope explícito ofrecida al user).
- **Numeración secuencial del PRP destino:** `ls .claude/PRPs/PRP-*.md | sort | tail -3` para identificar próxima numeración disponible · cero asunción.
- **Cero suposición · ir a fuente correcta** (regla [`no-suponer-fuente-de-verdad`](../../rules/no-suponer-fuente-de-verdad.md)) por cada afirmación que el mini-PRP va a incluir · auto-pregunta firme *"¿sé esto o lo supongo?"*.

### Paso 2 · 3 preguntas core compactadas (subset de las 6 PM hat)

Las 3 preguntas son **subset compactado** de las 6 PM hat del `/planificar` completo · cubren lo mínimo indispensable para un mini-PRP firmable · cero overhead innecesario:

1. **¿Qué construir, exactamente?** Estado final deseado · 1-2 oraciones. **Criterio de éxito binario** verificable mecánicamente (alineado con [`goal-driven-execution`](../../rules/goal-driven-execution.md)). **Compacta PM hat #1 + #2.**
2. **¿Qué archivos tocar y cuáles NO?** Inventario explícito · 1-5 archivos (si >5 → señal de complejidad → ejecutar gate de escalación abajo). Alineado con [`surgical-changes`](../../rules/surgical-changes.md) (cero drive-by). **Compacta PM hat #4 + #5.**
3. **¿Cómo verifico que funciona?** Tests del DoD · spec E2E acotado o query SQL o smoke bash · cero "lo veo cuando corro la app". Alineado con [`tests-as-dod-per-phase`](../../rules/tests-as-dod-per-phase.md). **Compacta PM hat #6.**

**Patrón de validación activa** (paridad regla [`ante-duda-preguntar-user`](../../rules/ante-duda-preguntar-user.md)): por cada pregunta · si la investigación del Paso 1 ya respondió → presentar al user + solicitar confirmación explícita. Si NO respondió → preguntar al user con recomendación early ([`conversation-style`](../../rules/conversation-style.md)) + justificación 1-frase. Cero round-trip vacío.

Las **3 preguntas omitidas** vs `/planificar` completo (#3 restricciones · parcial #4 patrones a reusar · NO sub-paso 5.b features candidatas múltiples) se asumen acotadas por contrato del skill (scope simple = restricciones obvias del codebase · patrones reusables identificados en mapeo Paso 1 · cero features candidatas múltiples sino sería complejo).

### Paso 2.5 · Gate de escalación a `/planificar` completo (firme · cero ambigüedad)

> **Gate contractual del skill simple.** Si durante el Paso 1 o 2 aparecen ≥1 de las siguientes señales de complejidad, el skill **DEBE abortar** y proponer al user pasar a `/planificar` completo con firma explícita. Cero "ya arranqué simple, sigo simple". El gate protege la calidad del PRP de la racionalización *"es chico, lo cierro rápido"*.

**Señales de escalación (cualquiera dispara · cero excepción):**

- **>2 capas** tocadas (ej: BD + API + UI coordinados · NO solo UI con helper).
- **>5 archivos** afectados (inventario del Paso 2 pregunta 2).
- **≥1 decisión arquitectónica abierta** detectada (tradeoff real con ≥2 opciones razonables · no SD cosmética).
- **≥2 features candidatas** discretas con decisión propia (entran al MVP · van a V1.5+ · se descartan · paridad sub-paso 5.b del skill completo).
- **Complejidad estimada MEDIA o ALTA** según tabla regla #13 [`complejidad.md`](../../rules/complejidad.md) (3+ tablas · 3+ pantallas · reglas con override · sincronizaciones).
- **Carpetas nuevas propuestas en el inventario** (regla [`respect-existing-folder-structure`](../../rules/respect-existing-folder-structure.md) protocolo 5-step requiere firma user específica · mejor con flujo completo).
- **Decisión de UI nueva no trivial** (la matriz [`claude-design-matrix`](../../rules/claude-design-matrix.md) dispararía SÍ · mejor con flujo completo).

**Protocolo del gate (binario · cero ambigüedad):**

1. **Aborto del skill** sin generar el draft.
2. **Presentar al user con formato canónico** ([`metodologia-iteracion`](../../rules/metodologia-iteracion.md)):

   > Detecté señal(es) de complejidad: [lista de señales disparadas · cuál(es) aplicó].
   >
   > **Mi rec: escalar a [`/planificar`](../planificar/SKILL.md) completo** porque [razón 1-frase basada en las señales].
   >
   > ¿OK firmás escalación? (A: escalar · B: continuar con `/planificar-simple` con override explícito tuyo asumiendo el riesgo de PRP con scope acotado para feature que no lo es).
3. **Si A** → invocar `/planificar` completo con el contexto recolectado en Paso 1-2 como input (cero re-investigación) · el flujo completo arranca en su Paso 2.5 (spawn de 3 personas pre-draft).
4. **Si B** → continuar con `/planificar-simple` Paso 3 · documentar el override del user en el draft del PRP en sub-sección *"Override de gate de escalación"* con firma `🔵 user · YYYY-MM-DD · "<justificación>"` (paridad firma de bifurcaciones del skill completo).

### Paso 3 · Generación del mini-PRP draft

Rellenar el template `.claude/PRPs/prp-base.md` con las respuestas firmadas/confirmadas del Paso 2:

- **Header:** estado `PENDIENTE` · fecha · task T-XX que cubre (si aplica · `null` si trabajo emergente) · sesiones estimadas (típicamente 1 para mini-PRP) · riesgo (🟢 BAJA por contrato del skill · si MEDIA/ALTA → debiste escalar en Paso 2.5).
- **Objetivo:** 1-2 oraciones del Paso 2 pregunta 1.
- **Por Qué:** problema/solución del Paso 2 pregunta 1.
- **Qué + Criterios de Éxito:** binarios verificables del Paso 2 pregunta 1.
- **Contexto:** referencias canónicas del Paso 1 (archivos · memoria · reglas firmes aplicables · DT relevantes · PRPs históricos identificados). Cero firma 🔵 user de bifurcaciones (por contrato del skill no hay decisiones arquitectónicas abiertas · si las hubo, escalaste).
- **Blueprint:** típicamente 1-2 fases (mini-PRP simple) · cada fase con tests del DoD ([`tests-as-dod-per-phase`](../../rules/tests-as-dod-per-phase.md)) · typecheck + build verdes al cierre · commit local.
- **Inventario de archivos afectados:** tabla con acción 🟢🟡🟠🆕 + justificación 1-frase + restricciones de scope. **Crítico anti-regresión:** si listás `tests/manual/PRP-NNN_*.csv` en el inventario, marcalo con emoji 🟣 + nota *"NO se crea en `/implementar` paso 3 · ownership exclusivo del SKILL `/validar` paso 5"* (paridad `/planificar` completo).
- **Validación final:** mecánica + Playwright/CSV cuando aplica · referenciada al paso 5 (`/validar`).
- **Aprendizajes / Self-Annealing:** sección vacía (se rellena durante implementación con gotchas detectados).
- **Sub-sección "Override de gate de escalación"** (solo si el user firmó B en Paso 2.5) · documenta el override con firma `🔵 user · YYYY-MM-DD · "<justificación>"`.
- **Cero sub-sección "Análisis pre-draft de las personas"** (skill simple NO spawnea personas · cero sub-secciones `### architect-planning` · `### complexity` · `### historical-precedent` · `### skeptic`). El draft del mini-PRP es más corto por diseño.

### Paso 4 · Presentación al user para aprobación final

- Reportar al user el mini-PRP completo: path del archivo creado · resumen de las 3 preguntas respondidas · sesiones estimadas · riesgo · próximos pasos.
- Solicitar OK explícito: *"¿Aprobás el PRP-NNN (mini) para arrancar implementación?"*.
- **Al recibir OK** → cambiar estado del PRP a `APROBADO` en el header · actualizar [`docs/product/product-roadmap.md`](../../../docs/product/product-roadmap.md) con marca del PRP destino para la task asociada (si aplica) · agregar entrada en [`.claude/memory/log.md`](../../memory/log.md) tipo `decision` ([`log-chronology-append-only`](../../rules/log-chronology-append-only.md) formato canónico) · **commit local de los cambios SIN push** (regla [`push-and-ci-policy`](../../rules/push-and-ci-policy.md) reserva el push único para paso 6 `/entregar`).
- **Al NO recibir OK** → ajustar el mini-PRP según feedback del user · re-presentar · iterar hasta firma.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Me llamaron al simple pero veo señales de complejidad mid-proceso · sigo con simple porque ya arranqué" | NO. El Paso 2.5 es **gate contractual** del skill · cero excepción. Si aparecen señales de complejidad → abortar + escalar a `/planificar` completo con firma user explícita. El "ya arranqué" es exactamente la racionalización que el gate atrapa · sigue cosa simple solo si el user firma override B explícito asumiendo el riesgo. |
| "Skipeo las 3 preguntas core porque la feature es obvia · genero draft directo" | NO. Las 3 son **contractuales** (subset compactado de las 6 PM hat · ninguna más se puede omitir sin romper la calidad mínima del PRP). "Obvia" es subjetivo · el costo de las 3 preguntas es minutos · el costo de un mini-PRP con scope ambiguo es horas de bucle improvisando decisiones. Si la feature es tan obvia que no necesita PRP, es Modo A · ejecutalo directo sin pasar por este skill. |
| "Genero el mini-PRP draft sin firma user del Paso 4 · le aviso después" | NO. Paridad con `/planificar` Paso 8: estado `APROBADO` SOLO post-OK explícito user · cero firma implícita por silencio. El archivo se crea con estado `PENDIENTE` · el user firma · recién ahí pasa a `APROBADO`. |
| "El user me dijo 'planificá simple' explícito · skip el gate de escalación aunque vea señales de complejidad" | NO. El override del user al inicio (trigger explícito) NO es licencia para skip del gate · el gate es la red defensiva contra invocación equivocada. Si las señales de complejidad aparecen genuinamente, el aviso al user en Paso 2.5 vale igual · cuesta 1 round-trip · evita PRP con scope inadecuado. El user puede firmar B (override) sabiendo el riesgo · pero NO se le oculta la detección. |
| "El draft del mini-PRP es más corto · skip secciones del template porque no aplican" | NO. El shape del PRP es el **mismo** que `/planificar` completo (cero divergencia · paridad simetría módulos hermanos regla #8 punto 6). Lo que cambia es el contenido (secciones canónicas con menos volumen · cero sub-secciones de personas) · NO el shape. Saltar secciones del template rompe la consultabilidad por sesiones futuras y por skills sucesores (`/implementar` · `/revisar` · `/validar`). |

## Red flags

- 🚩 Detectaste ≥1 señal de complejidad (>2 capas · >5 archivos · decisión arquitectónica abierta · features candidatas múltiples · MEDIA/ALTA · carpetas nuevas · UI nueva no trivial) y NO ejecutaste el gate de escalación del Paso 2.5.
- 🚩 Estás generando el mini-PRP draft (Paso 3) sin haber confirmado las 3 preguntas core con el user (validación activa omitida).
- 🚩 El draft del mini-PRP tiene secciones del template `prp-base.md` vacías o con placeholders (`TBD` · `TODO`) — el PRP NO está listo para `APROBADO`.
- 🚩 Cambiaste el estado del PRP a `APROBADO` sin OK explícito del user en el Paso 4 (firma implícita por silencio).
- 🚩 Spawneaste sub-agentes vía `Task` (el frontmatter `allowed-tools` excluye `Task` intencionalmente · si lo necesitás genuinamente, escalá a `/planificar` completo).
- 🚩 No agregaste entrada en [`.claude/memory/log.md`](../../memory/log.md) tipo `decision` al cerrar la planificación (regla [`log-chronology-append-only`](../../rules/log-chronology-append-only.md)).
- 🚩 El user firmó override B del gate de escalación pero NO documentaste el override en sub-sección *"Override de gate de escalación"* del mini-PRP draft con firma `🔵 user`.

## Verification

- [ ] Paso 1 hecho: template `prp-base.md` leído + investigación contextual mínima completada (codebase + roadmap + memoria + PRPs históricos + DT activas) + numeración secuencial del PRP destino verificada con `ls`.
- [ ] **Cero suposición durante Paso 1** (regla [`no-suponer-fuente-de-verdad`](../../rules/no-suponer-fuente-de-verdad.md)): auto-pregunta firme aplicada por cada afirmación que el mini-PRP va a incluir.
- [ ] Paso 2 hecho: las 3 preguntas core respondidas con confirmación explícita del user (validación activa) · ninguna omitida.
- [ ] **Paso 2.5 evaluado** (cero salto silencioso): ninguna señal de complejidad disparada → continuar al Paso 3. O si disparada → aborto + propuesta de escalación al user con firma A (escalar) o B (override documentado).
- [ ] Paso 3 hecho: archivo `.claude/PRPs/PRP-NNN-<descripcion-kebab>.md` generado con todas las secciones del template `prp-base.md` rellenas (cero placeholders) · cero sub-sección de personas (skill simple NO spawnea) · sub-sección *"Override de gate de escalación"* presente solo si el user firmó B en Paso 2.5.
- [ ] Paso 4 hecho: OK explícito del user recibido · estado del PRP cambiado a `APROBADO` · roadmap actualizado con marca del PRP destino (si aplica) · entrada `decision` agregada en `.claude/memory/log.md` · commit local SIN push (paso 6 reserva el push único).

**Cross-reference firme:**

- Hermana operativa: [`/planificar`](../planificar/SKILL.md) (variante completa · escalación cuando aparece complejidad mid-skill · mismo rol estructural paso 2 del flujo de 6 pasos · paridad shape del PRP generado · cero divergencia del template `prp-base.md`).
- Hermana operativa: [`/arrancar`](../arrancar/SKILL.md) (paso 1 · Paso 4 auto-orient distingue Modo C-simple vs Modo C-complejo y propone con rec early · user firma A/B antes de invocar).
- Hermana doctrinal: las mismas reglas firmes que enmarcan `/planificar` (referencias por leyenda · doctrina vive en los satélites): [`think-before-coding`](../../rules/think-before-coding.md) · [`simplicity-first`](../../rules/simplicity-first.md) · [`goal-driven-execution`](../../rules/goal-driven-execution.md) · [`surgical-changes`](../../rules/surgical-changes.md) · [`no-suponer-fuente-de-verdad`](../../rules/no-suponer-fuente-de-verdad.md) · [`ante-duda-preguntar-user`](../../rules/ante-duda-preguntar-user.md) · [`respect-existing-folder-structure`](../../rules/respect-existing-folder-structure.md) · [`golden-rule-docs-memory`](../../rules/golden-rule-docs-memory.md) · [`complejidad`](../../rules/complejidad.md) (paso 2.5 gate de escalación lo invoca como SoT para señales MEDIA/ALTA).
- Predecesor: skill [`/arrancar`](../arrancar/SKILL.md) (paso 1 · activa `/planificar-simple` cuando output template propone Modo C-simple).
- Sucesor: skill [`/implementar`](../implementar/SKILL.md) (paso 3 · arranca cuando el mini-PRP queda `APROBADO`).
