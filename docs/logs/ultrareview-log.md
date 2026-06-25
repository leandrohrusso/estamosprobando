# Ultrareview Log · `docs/logs/ultrareview-log.md`

> **Bitácora de runs `/ultrareview`** lanzados durante el paso 6 sub-paso 6.◆ del flujo Modo C. Cada PRP del producto decide SÍ/NO ejecutar `/ultrareview <PR#>` (camino CON `/ultrareview` vs camino SIN). Esta bitácora trackea: (1) la decisión por PRP, (2) las entradas UR-NNN cuando se lanza, (3) el estado de cada hallazgo (fixeado · descartado · diferido).

## § Decisiones por PRP

_(vacío al boot · agregar fila cuando se cierre la decisión SÍ/NO en paso 6 sub-paso 6.◆)_

| PRP | Decisión SÍ/NO | Razón breve | Fecha |
|---|---|---|---|

## § Entradas UR-NNN

_(vacío al boot · agregar entry cuando se lanza `/ultrareview <PR#>` · estado: en curso → completado)_

| UR | PR# | Status | Hallazgos críticos / normales / nits | Fecha |
|---|---|---|---|---|

## § Hallazgos consolidados

_(vacío al boot · 1 fila por hallazgo individual de cada UR · estado: 🔴 pendiente → ✅ fixeado / ❌ descartado / ⏸ diferido a DT)_

| ID | UR | Severidad | Archivo:LN | Síntoma | Estado | Commit fix |
|---|---|---|---|---|---|---|

---

_Bitácora gestionada por regla #18 [`golden-rule-docs-memory.md`](../../.claude/rules/golden-rule-docs-memory.md) ítem 4.7 (timing bidireccional · decisión inmediata + apertura + cierre + estado)._
