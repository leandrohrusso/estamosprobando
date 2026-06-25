---
name: Estimaciones basadas en datos reales · cero heurísticas sin verificación
description: Toda estimación de ritmo/escala/cadencia debe basarse en datos reales medibles (`grep | awk | wc | date`) · NUNCA en heurísticas sin verificación previa. Subestimar por órdenes de magnitud genera decisiones arquitectónicas mal calibradas.
type: feedback
---

# Estimaciones de ritmo/escala deben basarse en datos reales · NUNCA en heurísticas sin verificación

**Regla:** cualquier estimación de ritmo de archivos del repo (log · memoria · entries · líneas · entries por mes · velocidad de crecimiento · etc) debe basarse en datos reales medibles (`grep | awk | wc | date`) — NUNCA en heurísticas sin verificación previa.

**Why:** durante una sesión upstream de análisis 4 dimensiones del flujo, al evaluar threshold para archivado del log el agente estimó sin verificar fechas reales: *"~10 entries/mes al ritmo normal post-refactor"*. El user corrigió firmemente con datos reales del log: *"el ritmo que yo manejo creó N líneas en el log en pocos días · revisá las fechas y verás · esa estimación está mal por orden de magnitud"*. Datos reales verificados: N líneas / M entries / K días con actividad = X entries/día · Y líneas/día (ritmo refactor activo). La estimación inicial subestimó por ~18× (10/mes vs ~180/mes reales). Una decisión arquitectónica basada en esa estimación habría calibrado el threshold con orden de magnitud equivocado.

**How to apply:**

- **Antes de proponer cualquier threshold/cadencia/horizonte temporal** sobre archivos del repo, ejecutar verificación mecánica:
  - **Ritmo de entries:** `grep -oE "^## \[[0-9]{4}-[0-9]{2}-[0-9]{2}" <archivo> | sort | uniq -c` (entries por día).
  - **Días con actividad:** `grep -oE "^## \[[0-9]{4}-[0-9]{2}-[0-9]{2}" <archivo> | sort -u | wc -l`.
  - **Líneas totales + entries totales:** `wc -l <archivo>` + `grep -c "^## \[" <archivo>`.
  - **Primera/última fecha:** `grep "^## \[" <archivo> | head -1` y `tail -1`.
- **Honestidad sobre datos limitados:** si solo tenés N días de actividad (refactor activo · sesión intensiva · etc), declarar que NO es proyectable al ritmo "normal" y NO inventar números. Mejor decir *"NO conozco el ritmo normal · el threshold se re-evalúa en M meses"* que improvisar con cifras sin base.
- **Distinción ritmo intensivo vs ritmo normal:** durante períodos de refactor activo el ritmo es alto (en sesiones upstream se midieron ~6 entries/día · ~58 líneas/día) · post-refactor probablemente más lento, pero **sin datos reales del periodo post-refactor, NO proyectar** · medir el ritmo propio del proyecto antes de cualquier estimación.
- **Verificable con git también:** `git log --since="<N days ago>" --oneline | wc -l` para ritmo de commits si aplica.

**Cuándo se aplica:**

- Decisiones de threshold para archivado / rotación / archivado periódico (log · memoria · DTs · etc).
- Decisiones de cadencia (cada X días · cada N entries · cada M líneas).
- Cualquier proyección a futuro basada en ritmo actual del repo.
- Diseño de scripts auxiliares que dependen de tasa de crecimiento.

**Anti-pattern a evitar:**

> "Estimo Y al ritmo normal post-X" sin haber verificado el ritmo actual con `grep` ni el periodo activo con conteo de días distintos.

**Refs:**

- Origen del aprendizaje: sesión upstream de análisis 4 dimensiones · corrección user firmada tras una estimación basada en heurística (no en datos reales).
- Aplica universal · cualquier estimación de cadencia/threshold de gobierno debe verificarse con `grep | awk | wc | date` antes de proponerla al user.
- Regla hermana: [`no-suponer-fuente-de-verdad.md`](../../rules/no-suponer-fuente-de-verdad.md) (cero suposición · siempre fuente · esta memoria especializa para "datos reales del repo" como fuente).
