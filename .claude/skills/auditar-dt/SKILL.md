---
name: auditar-dt
type: skill
description: "Audit mensual read-only de las deudas técnicas activas en `docs/logs/technical-debt.md` cruzadas contra el roadmap próximo (`docs/product/product-roadmap.md`) y los PRPs en curso. Emite reporte estructurado clasificando DTs en 3 baldes (urgentes vs latentes vs obsoletas) + recomendación accionable de cuáles fixear preventivamente vs cuáles dejar como están. Cero side effects (NO modifica technical-debt.md ni código). Paridad operativa con `/revisar-main` (lint mensual de código) y lint mensual de memoria (`scripts/lint-memory.sh`) · cierra trilogía de saneamiento mensual del proyecto. Cadencia mensual codificada en `docs/logs/deadlines.md` · `/arrancar` Paso 5 auto-propone la ejecución al detectar el deadline vencido o ≤7 días. Activar cuando el usuario dice: auditar deudas, audit de deudas, audita las deudas, audita DTs, audit DTs, audit DT, revisá las DTs, revisa las DTs, revisión de deudas, revision de deudas, qué deudas tenemos, qué DTs hay activas, lint mensual de deudas, lint deudas, auditá technical-debt, audita technical-debt, deudas técnicas activas, repaso de DTs."
allowed-tools: Read, Grep, Glob, Bash
---

# Skill: `/auditar-dt` — audit mensual read-only de deudas técnicas activas

> **Skill custom autocontenido.** Trigger explícito que el user invoca (o `/arrancar` Paso 5 auto-propone cuando el deadline vence) para forzar un audit mensual de las DTs activas en [`docs/logs/technical-debt.md`](../../../docs/logs/technical-debt.md) cruzadas con el roadmap próximo + PRPs en curso. Read-only · cero side effects · emite reporte estructurado clasificando DTs en 3 baldes con recomendación accionable.
>
> **Relación con la regla #24** [`register-out-of-scope-as-dt.md`](../../rules/register-out-of-scope-as-dt.md) (SoT contractual del **registro** de DTs): este skill **NO modifica** DTs (eso lo hace el agente principal vía PRPs nuevos que consuman las recomendaciones del reporte) · solo las **lee + clasifica + recomienda**. Paridad arquitectónica con [`/revisar-main`](../revisar-main/SKILL.md) (lint mensual de código · scope holístico read-only · emite reporte · fixes via PRPs nuevos) y con `scripts/lint-memory.sh` (lint mensual de memoria · scope memoria read-only · emite reporte) · trilogía de saneamiento mensual cerrada (refinamiento iterativo upstream · los 3 triggers operan read-only con cadencia mensual + reporte + decisión user sobre fixes · ninguno modifica directamente · paridad operativa con triada bidireccional `/fatiga` + `/handoff` + `/documentar` que opera con trigger explícito on-demand pero también shape "re-lectura SoT + cero cache").

## Overview

> **Propósito:** auditar mensualmente las DTs activas del proyecto · cruzarlas contra el roadmap próximo + PRPs en curso · clasificarlas en 3 baldes (urgentes vs latentes vs obsoletas) · emitir reporte estructurado con recomendación accionable de cuáles fixear preventivamente vs cuáles dejar como están. Cierra trilogía de saneamiento mensual: `/revisar-main` (código) + `scripts/lint-memory.sh` (memoria) + `/auditar-dt` (deudas técnicas).
>
> **Cuándo invocar (esquemático):** cadencia mensual codificada en [`docs/logs/deadlines.md`](../../../docs/logs/deadlines.md) · `/arrancar` Paso 5 auto-propone al detectar deadline vencido o ≤7 días (paridad regla #20 § Archivado periódico) · invocable ad-hoc cuando el user pide *"qué deudas tenemos"* o *"revisá las DTs"*.
>
> **Qué NO hace:**
>
> - ❌ NO modifica [`docs/logs/technical-debt.md`](../../../docs/logs/technical-debt.md) · cero side effects (read-only contractual).
> - ❌ NO fixea código (eso lo hace el agente principal post-reporte vía PRPs nuevos del producto que consuman las recomendaciones).
> - ❌ NO sustituye a la regla #24 [`register-out-of-scope-as-dt.md`](../../rules/register-out-of-scope-as-dt.md) (SoT del registro de DTs · ese contrato sigue vigente independiente de este skill).
> - ❌ NO genera log persistente (Modo A minimalista · si después aparece la necesidad, se agrega como evolución V1.5).
> - ❌ NO se mezcla con `/revisar-main` (código) ni con `scripts/lint-memory.sh` (memoria) · skills hermanos con scope distinto.

## When

| Caso | Aplica `/auditar-dt` |
|---|---|
| Deadline mensual codificado en [`deadlines.md`](../../../docs/logs/deadlines.md) vencido o ≤7 días · `/arrancar` Paso 5 auto-propone | ✅ SÍ |
| User dice *"auditar deudas"* · *"audita las deudas"* · *"audita DTs"* · *"revisá las DTs"* · *"qué deudas tenemos"* · *"qué DTs hay activas"* · *"lint mensual de deudas"* · *"deudas técnicas activas"* · *"repaso de DTs"* | ✅ SÍ |
| Pre-planning de un PRP nuevo · user quiere ver qué DTs cruzan con el área del PRP futuro antes de definir scope | ✅ SÍ (ad-hoc · cero requisito de cadencia) |
| Trigger explícito post-merge de un PRP grande · user quiere chequear si quedaron DTs huérfanas o asimétricas | ✅ SÍ (ad-hoc) |
| Modo A trivial sin DTs en el área tocada | ❌ NO (audit sería ruido · no hay material para clasificar) |
| Sesión exploratoria sin scope definido · cero intención de fixear deudas | ❌ NO (audit emite reporte que nadie va a consumir) |
| User pide *"abrí una DT nueva"* o *"cerrá DT-NNN"* | ❌ NO (eso lo hace el agente principal aplicando regla #24 directamente · este skill es read-only) |

## Process

> **Skill autocontenido · read-only · cero side effects.** El § Process embebe los 5 pasos canónicos · cero detección runtime · ejecución mecánica.
> **Cita inline de doctrina:** la **fuente de verdad del registro de DTs** vive en regla #24 [`register-out-of-scope-as-dt.md`](../../rules/register-out-of-scope-as-dt.md) (SoT contractual de los 8 campos + apertura inmediata + 4 pasos del registro). Este skill **referencia** esa regla como SoT y **opera** sobre el output (las filas registradas) · cero modificación al registro.

### Paso 1 · Cargar inventario completo de DTs activas

`Read docs/logs/technical-debt.md` · parsear todas las filas bajo § "Deudas activas" agrupadas por PRP destino tentativo. Para cada DT capturar:

- **ID** (`DT-NNN`).
- **PRP destino tentativo** (heading de la sub-sección · ej: "PRP futuro — integración pagos real" · "Próximo PRP que toque backoffice combo" · "Próximo PRP que toque infra de testing / linting" · etc).
- **Severidad estimada** (campo "Bloqueante" del shape clásico · convertir a `critical` si dice "BLOQUEANTE" · `normal` si dice "No bloqueante" con disparador definido · `nit` si dice solo "disparador opcional").
- **Disparador para cerrar** (texto del campo "Bloqueante" o equivalente · ej: "Al migrar a <payment-gateway> real" · "Próximo PRP que toque cancel_order").
- **Origen** (PRP/sesión donde se detectó · campo "Origen").
- **Síntoma corto** (primera frase del campo "Descripción").

**Sanity check:** confirmar que el conteo de DTs activas en el reporte coincide con `grep -cE "^\| DT-[0-9]+ \|" docs/logs/technical-debt.md` (sección Activas).

### Paso 2 · Cargar contexto de roadmap próximo + PRPs en curso

Para el cruce DTs vs trabajo próximo:

1. **Roadmap próximo:** `Read docs/product/product-roadmap.md` · identificar las próximas 10-15 tasks pendientes (`- [ ]`) en orden secuencial. Capturar ID + título + fase + files mencionados en notes (si aparecen).
2. **PRPs en curso:** `Bash grep -l "EN PROGRESO\|APROBADO" .claude/PRPs/*.md` · para cada PRP que matchee leer el header (estado + área temática del título). Capturar PRP-NNN + estado + área temática.

**Nota:** si el `grep` retorna >10 PRPs, agrupar por área temática para no inflar el contexto del reporte. La idea es identificar "zonas calientes próximas" (qué áreas del código se van a tocar pronto), no enumerar exhaustivamente.

### Paso 3 · Clasificar DTs en 3 baldes (criterio binario · cero subjetividad)

Para cada DT del Paso 1, aplicar el criterio binario cruzando con el contexto del Paso 2:

| Balde | Criterio binario | Acción recomendada |
|---|---|---|
| 🔴 **Urgente** | El disparador de la DT está activo o por activarse en ≤2 PRPs próximos del roadmap · O un PRP EN PROGRESO toca el área de la DT · O la DT tiene severidad `critical` con disparador "bloquea X" donde X está próximo | **Fixear preventivamente** en el próximo PRP del área · O abrir mini-PRP dedicado si es huérfana del roadmap actual |
| 🟡 **Latente** | El disparador NO está activo en el roadmap próximo (≤10 tasks) · pero la DT sigue siendo válida (síntoma observable · disparador concreto · NO obsoleto) | **Dejar como está** · re-evaluar en próximo audit mensual · sin acción inmediata |
| ⚪ **Obsoleta** | El síntoma ya no aplica (área refactoreada · feature cancelada · disparador imposible) · O la DT fue silenciosamente cerrada en otro commit sin actualizar la fila · O el PRP destino tentativo ya fue COMPLETADO y la DT no se cerró formalmente | **Proponer cierre formal** en próximo PRP del área · O proponer eliminación retroactiva con firma user explícita |

**Anti-pattern del agente al clasificar:** improvisar baldes ("medio urgente", "casi obsoleta", "depende"). El criterio es binario · si dudás entre 🔴 y 🟡, default 🟡 (latente · re-evaluar el mes que viene · cero falso positivo de urgencia). Si dudás entre 🟡 y ⚪, default 🟡 (latente · cero borrado silencioso de DTs que pueden ser legítimas).

### Paso 4 · Emitir reporte estructurado (formato canónico)

Output directo al user · cero archivo persistente (Modo A minimalista). Formato:

```markdown
## /auditar-dt · audit mensual · YYYY-MM-DD

**Inventario:** N DTs activas · cruzadas contra <M> tasks próximas del roadmap + <P> PRPs EN PROGRESO/APROBADO.

### 🔴 Urgentes (X DTs) · fixear preventivamente

| DT | Síntoma corto | Disparador | Razón urgencia |
|---|---|---|---|
| DT-NNN | ... | ... | <PRP próximo que toca el área · o PRP EN PROGRESO en zona caliente> |

### 🟡 Latentes (Y DTs) · dejar como están · re-evaluar próximo audit

| DT | Síntoma corto | Disparador | PRP destino tentativo |
|---|---|---|---|
| DT-NNN | ... | ... | ... |

### ⚪ Obsoletas (Z DTs) · proponer cierre formal

| DT | Síntoma corto | Razón obsolescencia |
|---|---|---|
| DT-NNN | ... | <área refactoreada en commit XXX · PRP destino COMPLETADO sin cerrar la DT · disparador imposible> |

### Recomendación accionable

- **Urgentes (🔴):** sumar al scope del próximo PRP que toque <área X> · o abrir mini-PRP dedicado para <DT-NNN huérfana>.
- **Obsoletas (⚪):** proponer cierre en commit dedicado con firma user (cero borrado silencioso · paridad regla #24).
- **Latentes (🟡):** sin acción · re-evaluación próximo audit (cadencia mensual · próximo deadline YYYY-MM-DD).

**Próximo audit:** YYYY-MM-DD (fila en [`docs/logs/deadlines.md`](../../../docs/logs/deadlines.md) § Activos).
```

### Paso 5 · Mencionar próximo deadline al user al cierre

Cierre del skill con párrafo café 3-5 líneas (paridad [`conversation-style.md`](../../rules/conversation-style.md)):

```text
Audit mensual cerrado. <X urgentes · Y latentes · Z obsoletas>. Las urgentes sugieren <acción concreta 1-2 líneas>. Próximo audit programado <YYYY-MM-DD> · `/arrancar` va a auto-proponer la ejecución al detectar el deadline vencido.

¿Querés que arranque <PRP/mini-PRP> para fixear las urgentes ahora · o lo dejamos para próxima sesión?
```

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Mientras audito, modifico la fila de DT-NNN porque encontré que está obsoleta · ahorro un commit" | NO. El skill es **read-only contractual**. Modificar DTs requiere PRP/mini-PRP separado con firma user (paridad regla #24 · cero side effects silencioso). Si encontrás obsoletas, van al balde ⚪ del reporte · el cierre formal va en commit dedicado posterior. |
| "Genero log persistente porque queda más prolijo (paridad con `/revisar-main`)" | NO. Modo A minimalista firmado 🔵 user (firma del skill mismo): sin script · sin log persistente · output directo al user. Si después aparece la necesidad, se agrega como evolución V1.5. |
| "Salto el cruce con roadmap + PRPs en curso · solo leo `technical-debt.md` y emito conteos" | NO. La clasificación 🔴/🟡/⚪ depende del cruce. Sin contexto del roadmap próximo + PRPs en curso, todas las DTs caen a 🟡 (latente) por default · el reporte pierde valor de recomendación accionable. El cruce cuesta 2-3 reads · paga su costo. |
| "Improviso baldes ('medio urgente', 'casi obsoleta', 'depende')" | NO. Criterio binario contractual. Si dudás 🔴 vs 🟡 → 🟡 (latente · cero falso positivo de urgencia). Si dudás 🟡 vs ⚪ → 🟡 (cero borrado silencioso). Cero subjetividad. |
| "El user me invocó pero hace 2 días corrí el audit · re-uso el reporte" | NO. Cada invocación obliga re-cargar inventario (Paso 1) + roadmap próximo (Paso 2). El estado cambia turno a turno · re-usar = drift entre reporte y realidad. Cuesta 1-2 min re-correr · evita recomendar sobre supuestos viejos. |
| "Genero el reporte y se lo emito sin Paso 5 (mención del próximo deadline)" | NO. La cadencia mensual es contractual · el cierre debe explicitar próximo deadline para preservar continuidad. Paridad regla #20 § Archivado periódico (`/arrancar` Paso 5 auto-propone cuando vence). |

## Red flags

- 🚩 Modificaste alguna fila de `docs/logs/technical-debt.md` durante la ejecución del skill · violación contractual read-only.
- 🚩 Generaste archivo persistente nuevo (log · CSV · reporte en disco) · Modo A minimalista firmado · cero archivos.
- 🚩 Saltaste el Paso 2 (cruce con roadmap + PRPs) · clasificación de baldes sin contexto pierde valor accionable.
- 🚩 Inventaste baldes intermedios ("medio urgente" · "casi obsoleta") · criterio binario contractual.
- 🚩 El reporte emitido NO incluye los 3 baldes (🔴 + 🟡 + ⚪) · aunque alguno esté vacío con count 0, los 3 headings van por estructura.
- 🚩 Skipeaste el Paso 5 (mención próximo deadline) · cierre incompleto · cadencia mensual desvirtuada.
- 🚩 Confundiste `/auditar-dt` con `/revisar-main` (auditas DTs vs auditas código del repo) o con `scripts/lint-memory.sh` (auditas DTs vs auditas memoria persistente) · skills hermanos con scope distinto.
- 🚩 Te invocaron para fixear una DT específica · este skill NO fixea · ese rol es del agente principal vía PRP/mini-PRP que consuma el reporte.

## Verification

- [ ] Paso 1 ejecutado · inventario completo de DTs activas cargado · conteo coincide con `grep -cE "^\| DT-[0-9]+ \|"` (sanity check).
- [ ] Paso 2 ejecutado · roadmap próximo (10-15 tasks) + PRPs EN PROGRESO/APROBADO leídos.
- [ ] Paso 3 ejecutado · cada DT clasificada en 1 de 3 baldes con criterio binario · cero baldes inventados.
- [ ] Paso 4 ejecutado · reporte estructurado emitido con formato canónico (3 baldes + recomendación accionable + próximo deadline).
- [ ] Paso 5 ejecutado · cierre con párrafo café 3-5 líneas · próximo deadline mencionado explícito.
- [ ] Cero modificación a `docs/logs/technical-debt.md` (verificable con `git status --short` post-skill · debe retornar vacío).
- [ ] Cero archivo persistente generado (Modo A minimalista · output directo al user).

**Cross-reference firme:**

- SoT contractual del registro de DTs: [`register-out-of-scope-as-dt.md`](../../rules/register-out-of-scope-as-dt.md) (regla #24 · 8 campos + apertura inmediata + 4 pasos · este skill opera sobre el output read-only).
- Hermana arquitectónica (lint mensual de código): skill [`/revisar-main`](../revisar-main/SKILL.md) (paridad operativa · scope holístico de `main` · 9 agentes + consolidator · log persistente).
- Hermana arquitectónica (lint mensual de memoria): `scripts/lint-memory.sh` invocado vía skill [`/memory-manager`](../memory-manager/SKILL.md) sub-comando `lint` (paridad operativa · scope memoria persistente · 6 criterios · read-only · genera entrada `lint` en `log.md`).
- Refuerza: [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) ítem 4.6 (DT bidireccional · este skill atrapa drift entre apertura y cierre).
- Refuerza: [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md) § Archivado periódico (paridad arquitectónica de cadencia mensual con auto-propuesta contractual en `/arrancar` Paso 5).
- Refuerza: [`conversation-style.md`](../../rules/conversation-style.md) (cierre del skill con párrafo café 3-5 líneas · próximo deadline explícito).
