# `docs/logs/` · Logs cronológicos live del proyecto

> **Qué es:** carpeta de logs cronológicos del proyecto con **timing bidireccional inmediato**. Contiene cadencias periódicas + bitácoras vivas de deudas técnicas + bitácoras de runs de los skills de revisión (`/revisar` local · `/revisar-main` mensual · `/ultrareview` cloud cuando el adopter lo invoca en paso 6 sub-paso 6.◆). Son artefactos vivos · append-only en su mayoría · pero con timing bidireccional (apertura y cierre inmediatos al detectar/resolver).
>
> **Por qué se creó:** la naturaleza live de estos logs (timing bidireccional · refs históricas inmutables en entradas viejas · cero modificación retroactiva del histórico) merece sub-carpeta dedicada con README que explicite la convención. Separar logs vivos de docs estables del producto (que viven en [`docs/product/`](../product/)) preserva claridad operativa.
>
> **Para qué sirve:** documentar el timing bidireccional inmediato de los logs (REGLA DE ORO docs y memoria ítems 4.6 y 4.7) · servir de SoT operativa de deuda técnica activa + cobertura de revisiones + cadencias periódicas · materializar la convención append-only para entradas históricas (regla [`log-chronology-append-only.md`](../../.claude/rules/log-chronology-append-only.md)).

## Convención

- **Append-only:** entradas nuevas se agregan al final · cero modificación retroactiva del contenido histórico (regla [`log-chronology-append-only.md`](../../.claude/rules/log-chronology-append-only.md)).
- **Timing bidireccional inmediato:** las entradas que tienen estado (DT · UR finding · review finding) se abren EN EL ACTO al detectar y se cierran EN EL ACTO al resolver. NO se postergan al cierre del PRP (REGLA DE ORO ítems 4.6 + 4.7 en [`CLAUDE.md`](../../CLAUDE.md) + regla [`golden-rule-docs-memory.md`](../../.claude/rules/golden-rule-docs-memory.md)).
- **Refs históricas inmutables:** las entradas viejas pueden citar paths viejos del proyecto (pre-cleanups · pre-renames) · NO se actualizan retroactivamente · son snapshots del momento en que se escribieron (paridad con [`.claude/memory/log.md`](../../.claude/memory/log.md)).
- **Excluido del find/replace masivo:** los cleanups estructurales y refactors masivos del repo deben explícitamente excluir estos archivos del find/replace para preservar la cronología histórica.

## Archivos actuales

| Archivo | Rol | Timing |
|---|---|---|
| [`deadlines.md`](./deadlines.md) | Cadencias periódicas del proyecto (lint mensual de memoria · lint mensual de código vía `/revisar-main` · audit mensual de DTs vía `/auditar-dt` · archivado periódico de `log.md` · etc) · [`/arrancar`](../../.claude/skills/arrancar/SKILL.md) Paso 5 lee este archivo al boot y avisa cuando un deadline vence o está ≤7 días | Append-only · fila a § Histórico al ejecutar deadline · fila nueva a § Activos con próxima fecha |
| [`technical-debt.md`](./technical-debt.md) | Deudas técnicas activas por PRP destino · DT-NNN con 8 campos contractuales (ID · síntoma · archivo · PRP destino · severidad · mitigación · disparador · sesión detección) | Bidireccional inmediato · regla [`register-out-of-scope-as-dt.md`](../../.claude/rules/register-out-of-scope-as-dt.md) |
| [`ultrareview-log.md`](./ultrareview-log.md) | Bitácora de runs `/ultrareview` (cloud · paso 6 sub-paso 6.◆ del flujo Modo C · skill que NO ejecuta el agente local · el adopter lo invoca en chat cloud) + mapa de cobertura por área/PRP/rango de commits | Bidireccional inmediato · REGLA DE ORO ítem 4.7 |
| `revisar-log.md` (no existe al boot · se crea al primer run) | Bitácora de runs [`/revisar`](../../.claude/skills/revisar/SKILL.md) (multi-agent local · 9 agentes Opus paralelos + consolidator) con findings y resolución por LR-NNN · paso 4 del flujo Modo C | Bidireccional inmediato · paridad con `ultrareview-log` |
| `revisar-main-log.md` (no existe al boot · se crea al primer run) | Bitácora de runs [`/revisar-main`](../../.claude/skills/revisar-main/SKILL.md) (multi-agent local holístico · cadencia mensual · 9 agentes Opus + consolidator sobre estado completo de `main`) con findings y resolución | Bidireccional inmediato · paridad con `revisar-log` |

> **Sobre los 2 archivos pendientes de primer run** (`revisar-log.md` + `revisar-main-log.md`): los skills `/revisar` y `/revisar-main` crean el archivo en su primer run si no existe (cero pre-creación al boot del template · evita archivos vacíos sin contenido real). Ver `<skill>/SKILL.md` § "Output" para shape canónico de cada log.

## Relación con la cronología del agente

- [`.claude/memory/log.md`](../../.claude/memory/log.md) — cronología del **agente** (decisions · milestones · directional · incidents · prp-close · lint) · paridad de patrón con esta carpeta pero su scope es la **fábrica del proyecto** (cómo se trabaja · cómo se decidió · cómo se cerró un PRP). Los logs acá son del **producto** (DTs activas · reviews · cadencias periódicas). Las 2 cronologías son complementarias · cero solapamiento.

## REGLA DE ORO docs y memoria · ítems 4.6 y 4.7

Citas literales de [`CLAUDE.md`](../../CLAUDE.md) y de la regla firme [`golden-rule-docs-memory.md`](../../.claude/rules/golden-rule-docs-memory.md) que aplican a esta carpeta:

- **Ítem 4.6** · Deuda técnica (`technical-debt.md`) — verificación bidireccional:
  - Toda deuda nueva tiene fila en el acto (regla [`register-out-of-scope-as-dt.md`](../../.claude/rules/register-out-of-scope-as-dt.md) · 8 campos contractuales).
  - Toda deuda cerrada está marcada como ✅ Resuelta con commit hash · en el mismo commit que cierra la deuda.
- **Ítem 4.7** · Ultrareview log (`ultrareview-log.md`) — timing bidireccional:
  - Al tomar decisión SÍ/NO `/ultrareview` en paso 6 sub-paso 6.◆: fila en § Decisiones por PRP en el acto.
  - Al lanzar (camino CON): entrada UR-NNN con `status: en curso`.
  - Al recibir notificación de completado: completar con hallazgos por severidad + estado por bug.
  - Al fixear/descartar un hallazgo: actualizar estado con commit SHA.

## Carpetas hermanas

- [`../product/`](../product/) — primarios del producto (vision · prd · roadmap) + backing material en `references/` · estables · NO live.

> **Nota:** `docs/README.md` (índice general de `docs/`) no existe al boot del template · el adopter lo crea cuando suma carpetas adicionales a `docs/` (típicamente `design/` · `qa/` · `runbooks/` · etc) y necesita índice navegable.

## Reglas firmes asociadas

- [`../../.claude/rules/log-chronology-append-only.md`](../../.claude/rules/log-chronology-append-only.md) — cronología append-only · cero modificación retroactiva · paridad con `.claude/memory/log.md`.
- [`../../.claude/rules/register-out-of-scope-as-dt.md`](../../.claude/rules/register-out-of-scope-as-dt.md) — DT en el acto · 8 campos contractuales · centraliza obligación previamente distribuida en 3 hermanas.
- [`../../.claude/rules/golden-rule-docs-memory.md`](../../.claude/rules/golden-rule-docs-memory.md) — REGLA DE ORO checklist 6 ítems · 4.6 y 4.7 son requisitos al cierre.
- [`../../.claude/rules/lint-memory-periodic.md`](../../.claude/rules/lint-memory-periodic.md) — lint mensual de memoria · cadencia indexada en `deadlines.md` · auto-propuesta de [`/arrancar`](../../.claude/skills/arrancar/SKILL.md) Paso 5.

---

*Convención de README firmada (regla [`folder-creation-with-readme.md`](../../.claude/rules/folder-creation-with-readme.md)).*
