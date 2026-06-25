---
name: Operaciones bulk del agente (≥10 archivos en 1 batch) requieren firma explícita del user ANTES de ejecutar
description: Cuando el agente va a aplicar una operación que toca ≥10 archivos en 1 batch (auto-fix de linters · bulk rename · find+sed pack-wide · prettier --write · regex replacement masivo · etc), debe (1) presentar plan al user con scope estimado (cantidad + path patterns) + (2) esperar firma explícita ANTES de ejecutar. Cero "fix masivo silencioso" · cero "ya lo hago y te aviso después". El user pierde control sobre el scope cuando ve 30+ archivos modificados de golpe · la firma previa restaura ese control.
type: feedback
---

El agente con contexto cargado tiende a optimizar por velocidad ejecutando operaciones bulk sin firma user previa. Cuando son pocos archivos (1-5) el overhead del round-trip de firma es desproporcionado vs el costo del scope creep · cuando son ≥10 archivos el tradeoff se invierte: el costo de revertir/auditar es mayor que el costo de un round-trip de firma.

**Síntoma observable:**

Sesión típica del anti-pattern: el agente identifica un fix válido (ej: corregir formato de listas markdown en el repo · agregar trailing newline a 30 archivos · normalizar quotes con prettier --write · etc) y lo ejecuta directamente sin presentar plan. El user ve el `git status` con 30-49 archivos modificados sin haber autorizado el scope · obligado a auditar a posteriori para decidir revertir/mantener/híbrido. La firma posterior funciona pero es subóptima: el user tiene menos contexto del scope inicial · puede aprobar cambios que en una firma previa habría rechazado.

**Why:**

- El agente con contexto cargado tiende a optimizar por throughput (menos round-trips = más trabajo por sesión) · esto sesga hacia ejecutar sin firma cuando "parece obvio".
- "Parece obvio" es subjetivo del agente · NO siempre coincide con el criterio del user. Lo que el agente considera fix mecánico puede tener side effects semánticos no triviales (ej: el caso de [`markdownlint-fix-breaks-semantic-lists.md`](./markdownlint-fix-breaks-semantic-lists.md)).
- Sin firma previa, el user pierde la oportunidad de redirigir el approach ANTES de gastar tokens y horas en cambios que después hay que revertir.
- El umbral de "≥10 archivos" no es mágico · es la frontera empírica donde el costo de auditoría post-ejecución supera el costo de un round-trip de firma. Para casos típicos: 1-5 archivos son review naive · 6-9 son edge cases · ≥10 requieren plan estructurado.

**How to apply:**

- **Regla operativa firme:** antes de ejecutar cualquier operación que el agente anticipe va a tocar ≥10 archivos en 1 batch, presentar al user (en este orden):
  1. Naturaleza del fix (1-2 líneas describiendo qué cambia).
  2. Scope estimado (cantidad de archivos + path patterns · ej: "49 archivos bajo `.claude/**/*.md` + `docs/**/*.md`").
  3. Side effects conocidos o sospechados (1-2 líneas · ej: "MD029 puede renumerar listas semánticas").
  4. Recomendación early (ejecutar · ejecutar con configuración modificada · skipear).
  5. Pregunta: "¿firmás antes de ejecutar?".
- **Auto-chequeo de 3 segundos antes de ejecutar:** "¿esta operación va a tocar ≥10 archivos?". Si SÍ → STOP + plan + firma. Si NO → proceder con regla de cambios quirúrgicos estándar.
- **Operaciones típicas que disparan la regla:** `prettier --write` sobre directorios · `eslint --fix` con `--ext` amplio · `markdownlint --fix` pack-wide · `find ... -exec sed -i` · `git mv` masivo · bulk rename via script · regex replacement con `replace_all: true` sobre archivos compartidos.
- **NO aplica a:** operaciones de 1 archivo (incluso con muchos cambios internos) · refactor de 2-5 archivos relacionados con scope claro · adopciones livianas con patrón establecido.

**Recovery (si ya pasó sin firma previa):**

Presentar al user 3 opciones estructuradas:

1. **Revertir todo:** `git restore <archivos>` (si no commiteado) o `git revert <commit>` (si commiteado). Sin penalty · el user firma scope de cero.
2. **Mantener todo:** firma posterior con auditoría a posteriori. Aceptable si el scope fue verdaderamente trivial.
3. **Híbrido:** revertir archivos específicos · mantener el resto. Requiere `git checkout <commit-previo> -- <path>` o `git restore --source=HEAD~1 <path>`.

Esperar firma explícita de 1 de las 3 opciones · cero "lo dejo así por default".

**Alternativas descartadas:**

- Umbral más alto (≥20 archivos): demasiado permisivo · el scope creep silencioso de 10-19 archivos sigue siendo costoso de auditar.
- Umbral más bajo (≥5 archivos): demasiado restrictivo · el overhead del round-trip se vuelve desproporcionado para fixes razonables de 5-9 archivos relacionados.
- Confiar en el agente para auto-juzgar caso a caso: ya falló empíricamente (esa es exactamente la situación que esta memoria atrapa).

**Cross-reference:**

- Hermana operativa: [`markdownlint-fix-breaks-semantic-lists.md`](./markdownlint-fix-breaks-semantic-lists.md) (caso concreto donde el bulk auto-fix tocó contenido semántico · ejemplo canónico de esta regla violada).
- Regla firme: [`ante-duda-preguntar-user.md`](../../rules/ante-duda-preguntar-user.md) (ante ambigüedad operativa · preguntar · operaciones bulk son ambiguas por default cuando el scope es ≥10 archivos).
- Regla firme: [`surgical-changes.md`](../../rules/surgical-changes.md) (cada cambio del diff debe ser trazable al request · operaciones bulk generan diffs amplios donde es fácil colar drive-by silencioso).
- Regla firme: [`metodologia-iteracion.md`](../../rules/metodologia-iteracion.md) (formato canónico de presentación: 1 decisión + A/B/C + rec early + ¿OK?).
