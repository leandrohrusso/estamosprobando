---
name: tool Read límite ~25K tokens · workaround canónico para archivos del repo que crecen
description: El tool `Read` de Claude Code retorna error cuando el archivo excede ~25K tokens. En tu proyecto, archivos que típicamente cruzan el límite cuando crecen: `.claude/memory/MEMORY.md` (índice maestro que acumula entries · empieza chico al boot del template · puede crecer >25K cuando supere ~200 líneas) y `docs/logs/technical-debt.md` (DTs activas + resueltas + bitácora · puede crecer >25K cuando supere ~300 líneas). Workaround canónico: `Read offset:N limit:M` para rangos específicos · `head -N` para overview · `sed -n 'A,Bp'` para sección concreta · `grep` targeted para entries indexados. NUNCA leer entero al boot un archivo crecido.
type: feedback
---

**Aplica a:** cualquier skill del flujo (`/arrancar`, `/planificar`, `/implementar`, `/revisar`, `/validar`, `/entregar`, `/revisar-main`, `/auditar-dt`) que invoque `Read` sobre archivos del repo que crecieron por encima del límite del tool.

## La regla

**Cuando un archivo del repo excede ~25K tokens, el tool `Read` retorna error de tamaño y el skill se rompe.** No leer el archivo entero al boot · usar workarounds targeted según contexto.

**Why:** el tool `Read` de Claude Code tiene un límite estructural (~25K tokens). NO es bug del proyecto · es característica del tool. Al boot del template, los archivos del SoT del flujo son pequeños (cero entries acumuladas) y el límite NO se activa. A medida que el proyecto evoluciona, 2 archivos típicamente crecen y eventualmente cruzan el límite:

| Archivo | Por qué crece | Threshold orientativo |
|---|---|---|
| [`.claude/memory/MEMORY.md`](../MEMORY.md) | Índice maestro · acumula entries de feedback/reference/project/user a medida que el proyecto evoluciona | ~200+ líneas densas (típicamente cruza el límite alrededor de las 240-260 líneas) |
| [`docs/logs/technical-debt.md`](../../../docs/logs/technical-debt.md) | DTs activas + resueltas + bitácora histórica · cada DT con descripción larga + 8 campos contractuales | ~300+ líneas (típicamente cruza el límite alrededor de las 350-380 líneas) |

**Disparador objetivo cuantitativo:** archivo del repo supera ~200 líneas densas (tablas con descripciones largas) · alta probabilidad de cruzar el límite. Verificá con `wc -l <path>` antes de leer entero. Los thresholds arriba son orientativos a partir de la experiencia upstream · tu proyecto puede cruzar el límite antes o después según densidad de contenido por línea.

## Workarounds canónicos

4 patrones según contexto · elegir el más targeted posible (NO leer más de lo necesario):

### Patrón 1 · `Read` con `offset` + `limit` (preferido cuando se conoce el rango)

```text
Read .claude/memory/MEMORY.md offset:1 limit:50
```

Lee las primeras 50 líneas · suficiente para header + glosario + carpetas principales en `MEMORY.md`. Funciona porque el tool `Read` respeta `limit` y devuelve solo el rango pedido (cero error de tamaño).

**Cuándo usar:** sabés exactamente qué rango necesitás (header del archivo · sección al inicio · líneas específicas referenciadas).

### Patrón 2 · `head -N` via Bash (overview rápido)

```bash
head -50 .claude/memory/MEMORY.md
```

Igual que Patrón 1 pero via Bash · útil cuando combinás con otros comandos pipe (`head -50 X | grep Y`).

**Cuándo usar:** overview rápido al boot · combinación con grep/awk · cuando NO sabés con precisión cuántas líneas hace falta.

### Patrón 3 · `sed -n 'A,Bp'` para sección concreta

```bash
sed -n '23,275p' docs/logs/technical-debt.md
```

Lee SOLO el rango 23-275 (que en `technical-debt.md` corresponde a § Deudas activas · skip header + § Resueltas + § Bitácora). Útil cuando el archivo tiene secciones bien delimitadas por línea y solo te interesa una.

**Cuándo usar:** el archivo tiene estructura conocida con secciones por rango · querés solo una sección operativa (típicamente § Activas en logs).

### Patrón 4 · `grep` targeted para entries indexados

```bash
grep "^- \[" .claude/memory/MEMORY.md | head -30
```

Lista los entries de tipo `- [Title](path.md) — descripción` SIN leer las descripciones largas. Útil cuando MEMORY.md tiene índice tipo lista markdown y solo querés los títulos.

**Cuándo usar:** archivo es índice mecánico (líneas formato lista) · querés overview de los entries sin sus descripciones.

## Detección y procedimiento al boot

**Detección rápida** (antes de invocar `Read`):

```bash
wc -l <path>
```

Si > 200 líneas Y el archivo está bajo `.claude/memory/` o `docs/logs/` → alta probabilidad de exceder el límite. Aplicar workaround targeted desde el inicio · NO intentar `Read` entero primero.

**Procedimiento canónico:**

1. **Verificar tamaño** (`wc -l`) si el archivo es candidato a haber crecido.
2. **Elegir patrón** según contexto (1=rango conocido · 2=overview · 3=sección · 4=índice).
3. **Aplicar workaround** · cero `Read` entero.
4. **Si necesitás más contexto post-overview,** invocar workaround más targeted (ej: post-`head -50` aplicás `sed -n 'A,Bp'` sobre rango identificado).

## Resolución estructural a futuro

[DT-NNN](../../../docs/logs/technical-debt.md) ya formaliza el cierre completo: evolucionar `MEMORY.md` a **multi-level index** (root slim + sub-índices por carpeta `feedback/INDEX.md` · `reference/INDEX.md` · etc) cuando se cumpla el disparador objetivo cuantitativo:

- `MEMORY.md` > 300 líneas · O
- `project/` > 50 archivos · O
- `feedback/`/`reference/` > 50 archivos.

Cuando dispare, abrir PRP propio (Modo C · firma 🔵 user · ~2-3h ejecución).

Para `technical-debt.md` el cierre estructural sería paralelo: split en sub-archivos por PRP destino o por severidad cuando supere ~400 líneas. NO está formalizado todavía como DT (disparador potencial · si llega a 500+ líneas evaluar).

## Cómo se detectó

Sesión `/arrancar` upstream ejecutando Paso 1 punto 4 (lectura `MEMORY.md`) · el tool `Read` retornó error tipo `File content (N tokens) exceeds maximum allowed tokens (25000). Use offset and limit parameters to read specific portions of the file, or search for specific content instead of reading the whole file.`. Mismo síntoma con `technical-debt.md` cuando creció. El skill `/arrancar` documentaba "leer siempre" pero NO el workaround → audit empírico del skill detectó la falla → Modo A con fixes operativos la cerró inline en el SKILL.md de arrancar + esta memoria la generaliza para otros skills.

## Cross-ref

- [`.claude/skills/arrancar/SKILL.md`](../../skills/arrancar/SKILL.md) Paso 1 puntos 4 y 6 — workaround documentado inline para los 2 archivos críticos del boot.
- [DT-NNN](../../../docs/logs/technical-debt.md) — evolución estructural pendiente (`MEMORY.md` multi-level index cuando dispare threshold).
- [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) ítem 4 (memoria persistente) — el patrón replicable amerita codificar memoria nueva (regla #12 simplicity-first respetada · 3+ callers reales hoy + DT-NNN anticipa más).

## Por qué la regla existe

El tool `Read` parece "lo natural" para cargar contexto al boot — leer el archivo entero · 1 sola llamada. Pero el límite de ~25K tokens es estructural · NO se puede saltar. Sin esta memoria · cada skill nuevo o cada agente que invoque `Read` sobre un archivo crecido va a romper la sesión al boot · y va a improvisar workarounds ad-hoc (lo que pasó hasta que se codificó · al menos 3 sesiones improvisaron el patrón antes de formalizarlo).

Codificar el patrón centraliza la SoT · cualquier skill futuro tiene la guía mecánica · cero re-improvisación. Cost: 1 archivo nuevo + entry en MEMORY.md. Benefit: cero fricción al boot cuando los archivos crezcan.
