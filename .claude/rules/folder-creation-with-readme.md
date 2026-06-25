---
name: Creación de carpetas con README obligatorio
description: Crear carpeta nueva requiere validar duplicados + firma user + README.md en la raíz (qué es · por qué · para qué). Mantenimiento dinámico de READMEs existentes en el día a día (drift detectado se fixea en el acto · paridad golden-rule-docs-memory). Antes de actuar en una carpeta no trivial · leer su README como fuente primaria de la convención (paridad no-suponer-fuente-de-verdad).
type: rule
---

## Overview

> **(A) Creación de carpetas:** cada vez que el agente está por crear una carpeta o subcarpeta nueva, debe (1) confirmar que regla #23 [`respect-existing-folder-structure.md`](./respect-existing-folder-structure.md) ya validó duplicados + sesgo anti-creación · (2) si la creación es genuinamente necesaria presentar el análisis al user con propuesta + recomendación early + esperar OK explícito · (3) recién ahí crear la carpeta + un `README.md` en su raíz que explique qué es · por qué se crea · para qué sirve. Aplica a cualquier nivel (carpeta o subcarpeta · cualquier path del repo).
>
> **(B) Mantenimiento dinámico de READMEs ya creados:** si en cualquier sesión la IA detecta que un README existente está mal · desactualizado · stale · con cross-refs rotos · o con asimetría respecto a hermanos que deberían tener shape paralelo, **lo fixea en el momento del descubrimiento** (paridad regla [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) "la doc no se pospone"). Cero "lo arreglo después" · cero esperar al próximo audit. Detalle del proceso en § Mantenimiento dinámico abajo.
>
> **(C) Lectura/consulta antes de actuar en una carpeta:** antes de crear · modificar · mover · archivar archivos en una carpeta cuya convención NO es trivialmente obvia, el agente **lee el `README.md` de esa carpeta** como fuente primaria de la convención (naming · shape · subcarpetas · cross-refs canónicos · procedimiento "Cómo agregar archivo nuevo" si aplica). La info que SOLO el README contiene (ej: las 6 reglas operativas para agregar un smoke test en `tests/scripts/infra-flujo/`) NO se consigue con `ls` · `grep` · ni MCPs · solo leyendo el README. Paridad regla [`no-suponer-fuente-de-verdad.md`](./no-suponer-fuente-de-verdad.md) · el README es archivo del repo · prioridad 1 de la fuente A. Detalle del proceso en § Lectura / consulta antes de actuar abajo.

**Por qué firme:** las carpetas se acumulan sin control si el agente las crea "porque sí" · el costo se cobra meses después cuando alguien tiene que entender por qué existe cada una. La regla atrapa el anti-pattern en el momento de la creación: validación previa de duplicados (¿hay otra carpeta que ya cumpla este rol?) + firma user + README contextual desde el día 1.

## When

> **Nota de orden operativo:** esta regla aplica **DESPUÉS** de que [`respect-existing-folder-structure.md`](./respect-existing-folder-structure.md) (regla hermana) determine que la creación es genuinamente necesaria. Esa regla cubre la política previa (**¿se crea o no?** · default = NO · sesgo anti-creación + anti-raíz). Esta regla cubre el **CÓMO** se crea una vez firmada la decisión. Las 2 son complementarias · cero solapamiento. Si llegaste acá sin haber ejecutado el procedimiento de validación previa de la regla hermana, frená y aplicalo primero.

**Aplica a · creación de carpetas:**

- Creación de carpeta nueva en CUALQUIER path del repo (`src/` · `tests/` · `db/` · `scripts/` · `docs/` · `.claude/` · raíz · etc).
- Creación de subcarpeta dentro de una carpeta existente (cualquier nivel · sin tope).
- Cualquier herramienta usada para crear (`mkdir` · `Write` con path nuevo · `git mv` que materializa carpeta destino · creación implícita de carpeta al escribir archivo).

**Aplica a · mantenimiento dinámico de READMEs ya creados** (ver § Mantenimiento dinámico abajo):

- Detección durante audit · spot-check · verificación cruzada · uso operativo · auditoría manual del user de un README mal · desactualizado · stale · con drift respecto a hermanos.
- Cualquier sesión de la IA · cero trigger explícito del user requerido para fixes triviales (typo · footer stale · cross-ref roto · fila faltante de tabla).
- Descubrimiento de cross-ref roto · tabla desincronizada con filesystem real · información obsoleta en el cuerpo · asimetría con hermanos que deberían tener shape paralelo.

**Aplica a · lectura/consulta antes de actuar en una carpeta** (ver § Lectura / consulta antes de actuar abajo):

- Primera vez que la sesión toca archivos de una carpeta cuya convención NO es trivialmente obvia.
- Antes de agregar un smoke test · una regla · una memoria · un PRP · un spec · etc · si la carpeta tiene README con sección "Cómo agregar archivo nuevo" o equivalente.
- Antes de mover · archivar · renombrar archivos para confirmar que el README destino justifica la operación.
- Cuando el shape de los archivos vecinos no es uniforme y se necesita criterio sobre cuál seguir.

**NO aplica a:**

- Carpetas auto-generadas por herramientas externas (`node_modules/` · `.next/` · `dist/` · `test-results/` · `.git/`). El agente NO controla esos paths.
- Carpetas que ya existen físicamente (esta regla cubre creación · no auditoría retroactiva).
- Carpetas creadas por scripts del propio proyecto en runtime (ejs: `tests/manual/` carpeta padre + `tests/manual/screenshots/PRP-NNN/` sub-carpeta · ambas las crea `/validar` automáticamente · esa creación está documentada en el SKILL del proceso · NO requiere firma user nueva en cada PRP · paridad excepción simétrica padre↔sub-carpeta · cero contradicción con § Paso 2 firma user porque el SKILL crea el `README.md` canónico en el mismo turno con el shape de las 3 secciones obligatorias).
- Mover un archivo a una carpeta `_archive/` que ya existe (la carpeta destino es preexistente).

## Process

> **Nota:** la validación previa de duplicados (inventario exhaustivo de carpetas existentes que puedan alojar el contenido) NO vive en esta regla · está cubierta por regla #23 [`respect-existing-folder-structure.md`](./respect-existing-folder-structure.md) Paso 1. Esta regla #22 asume que regla #23 ya cerró ese paso · arranca con el análisis al user (Paso 1 abajo) recién cuando la creación es genuinamente necesaria. Paridad con cross-ref existente en § When (Nota de orden operativo).

**Procedimiento canónico (4 pasos · obligatorios en orden):**

### Paso 1 · Análisis presentado al user

Cuando regla #23 concluyó que se necesita carpeta nueva, el agente presenta al user:

```markdown
Necesito crear carpeta nueva: <path propuesto>

**Contenido a alojar:** <descripción 1-2 líneas>
**Por qué carpeta nueva:** <razón · 1-2 líneas>
**Carpetas existentes evaluadas:** <lista corta · qué se descartó y por qué>

**Mi rec: crear <path>** porque <justificación 1-frase>.

¿OK firmás?
```

### Paso 2 · Esperar OK explícito del user

- Cero creación silenciosa · cero "ya estaba creando".
- Si el user objeta o propone otra carpeta · re-evaluar y volver al paso 1 con nueva propuesta.
- Si el user da OK explícito (sí · OK · dale · adelante) · pasar al paso 3.

### Paso 3 · Crear carpeta + README.md en la raíz

- Comando: `mkdir -p <path>` o `git mv` (según corresponda).
- Crear `<path>/README.md` siguiendo el **template canónico** (ver § "Template canónico (copiar/pegar)" abajo en este mismo archivo).

**Tabla de obligatoriedad de secciones del README** (cero ambigüedad · cero "se omite si no aplica" vago):

| Sección | Obligatoria | Cuándo se puede omitir | Si se omite, requiere |
|---|---|---|---|
| **Qué es** | 🔴 SIEMPRE | Nunca · cero excepciones | — |
| **Por qué se creó** | 🔴 SIEMPRE | Nunca · cero excepciones | — |
| **Para qué sirve** | 🔴 SIEMPRE | Nunca · cero excepciones | — |
| **Convención** | 🟡 Default | Si la carpeta es de archivado puro (`_archive/`) o de un único archivo sin patrón replicable | Justificar 1 línea en el README explicando por qué no aplica |
| **Archivos actuales** | 🟡 Default | Si la carpeta está vacía o contiene solo subcarpetas (sin archivos directos) | Justificar 1 línea en el README |
| **Carpetas hermanas** | 🟡 Default | Si es carpeta top-level sin hermanas obvias (raíz) | Justificar 1 línea explicando que es top-level sin hermanas |
| **Subcarpetas** | 🟡 Default | Si la carpeta NO tiene subcarpetas | Omitir sin justificación (sección N/A) |
| **Cómo agregar archivo nuevo** | 🟢 Opcional | Si la carpeta NO es operativa multi-archivo (ej: archivado) | Omitir sin justificación |

### Paso 4 · Verificación al cierre

- Antes de commitear · `ls <path>` confirma que existe `README.md` en la raíz.
- El commit del cambio incluye en el mensaje: `+ README.md explicando rol de la carpeta nueva`.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Es chico · creo la carpeta y el README después" | NO. Regla es upfront · cero "después". Sin README la convención se rompe (carpetas hermanas sin README pierden norte) · y nadie sabe por qué existe en 3 meses. Costo de hacerlo ahora: 5 min · costo de postergarlo: explicación pendiente eterna. |
| "La carpeta es obvia · no hace falta README" | NO. "Obvio" hoy es críptico mañana. `tests/stock-race/` parecía obvio cuando se creó · 3 meses después alguien preguntó "qué es esto" — caso real que disparó esta regla. 3 líneas cuestan menos que la pregunta futura. |
| "Ya existe la carpeta hermana · asumo que entendí el rol" | Validá primero. Si la hermana cubre el rol → usá esa · cero creación. Si NO cubre → explicá la diferencia al user antes de crear · cero asunción sobre lo "obvio". |
| "Mover un archivo nuevo crea carpeta destino implícita · no necesito firma" | SÍ necesitás firma. Creación implícita (`Write` a path inexistente · `git mv` a destino nuevo) cuenta igual que `mkdir`. Regla aplica a la primera vez que existe la carpeta · cero excepción por mecanismo. |
| "Es subcarpeta dentro de carpeta ya firmada · cubierta por firma anterior" | NO. Cada nivel se firma por separado · firma del padre NO autoriza subcarpetas nuevas. Profundidad de árbol es decisión arquitectónica per-nivel. |

## Red flags

- 🚩 Estás por correr `mkdir`, `Write` con path nuevo, o `git mv` a path destino nuevo · sin haber presentado análisis al user.
- 🚩 Pasaste paso 1 (presentar análisis) pero seguiste sin OK explícito del user (silencio NO es OK).
- 🚩 Creaste carpeta y olvidaste el README · vas a commitear sin él.
- 🚩 El README solo tiene "Qué es" pero le falta "Por qué se creó" y "Para qué sirve" (las 3 son obligatorias).
- 🚩 Saltaste la validación previa de duplicados (regla #23 [`respect-existing-folder-structure.md`](./respect-existing-folder-structure.md) Paso 1) · proponés carpeta nueva sin haber listado candidatas existentes.
- 🚩 Estás creando subcarpeta dentro de una ya firmada y asumís que la firma anterior la cubre.
- 🚩 Detectaste un README desactualizado · roto · con drift · durante una sesión y NO lo fixeaste en el momento ("lo dejo para después" · "no es mi PR" · "no me lo pidió el user") — la regla #22 te autoriza a fixear triviales sin pedir OK explícito (§ Mantenimiento dinámico).
- 🚩 Vas a crear · modificar · mover · archivar archivos en una carpeta no trivial sin haber leído su `README.md` primero · improvisás convención cuando el README la documenta (especialmente si tiene sección "Cómo agregar archivo nuevo").

## Verification

- [ ] Antes de crear cualquier carpeta nueva · validación previa de duplicados ejecutada según regla #23 [`respect-existing-folder-structure.md`](./respect-existing-folder-structure.md) Paso 1 · candidatas existentes listadas y evaluadas.
- [ ] Paso 1 (análisis presentado al user con contenido + razón + carpetas evaluadas + rec early) emitido cuando regla #23 concluyó "se necesita carpeta nueva".
- [ ] Paso 2 (OK explícito del user) recibido antes de la creación.
- [ ] Paso 3 (carpeta + README.md con las 3 secciones obligatorias en la raíz) ejecutado en el mismo turno que la creación.
- [ ] Paso 4 (verificación · commit incluye README explícitamente) cumplido al cierre.
- [ ] Subcarpeta nueva tiene su propio análisis + firma + README · cero herencia automática de la firma del padre.
- [ ] Si durante la sesión se detectó un README mal/desactualizado/con drift · se fixeó en el momento (trivial) o se presentó al user (estructural) · cero "lo arreglo después" (paridad § Mantenimiento dinámico).

## Mantenimiento dinámico

> **Los README NO son artefactos estáticos · se mantienen en el día a día.** Si en cualquier sesión la IA detecta que un README está mal · desactualizado · stale (info que dejó de ser cierta) · con cross-refs rotos · con asimetría respecto a hermanos que deberían tener shape paralelo · o con cualquier observación que merezca corrección, **lo fixea en el momento del descubrimiento** (paridad regla [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) "la doc no se pospone"). Cero "lo arreglo después" · cero "no es importante" · cero esperar al próximo audit.

**Triggers de mantenimiento (no exhaustivos):**

- La carpeta sumó / quitó archivos o subcarpetas y la tabla del README quedó desincronizada del filesystem real (`ls` no coincide con la tabla).
- Una memoria · regla · skill · PRP · path referenciado fue renombrado · movido · archivado · y el cross-ref rompió (`test -e` falla).
- Una decisión cerrada en el log de memoria · un cambio de estado del refactor · o un cierre de PRP volvieron obsoleta una afirmación del README (info stale en el cuerpo del documento).
- Hay drift entre dos READMEs hermanos que deberían tener shape paralelo (ej: las 5+ carpetas `_archive/` del proyecto · las 4 sub-carpetas de `.claude/memory/`).
- El template canónico (§ "Template canónico (copiar/pegar)" abajo) cambió y el README quedó atrás.
- Spot-check al pasar por la carpeta detectó que el contenido no refleja la realidad operativa actual.

**Procedimiento (paridad simétrica con § Process · 4 pasos):**

1. **Detectar** el issue (durante audit · spot-check · verificación cruzada · uso operativo · auditoría manual del user).
2. **Triage por severidad:**
   - **Trivial** (typo · footer stale · cross-ref roto · 1 línea de tabla desactualizada · fila faltante de subcarpeta hermana) → aplicar fix en el momento + mencionar al user en el cierre del turno · cero pregunta previa (autoridad pre-firmada por la propia regla #22).
   - **Estructural** (rewrite · re-shape · cambios significativos · información ambigua que merece firma user · convención que cambió) → presentar al user con formato canónico (regla [`metodologia-iteracion.md`](./metodologia-iteracion.md)) · esperar OK · aplicar.
3. **Commit explícito** con mensaje `docs(readmes): fix <path> · <razón corta>` (cero "drive-by" silencioso · paridad regla [`surgical-changes.md`](./surgical-changes.md)).
4. **Verificación post-fix** con los 4 criterios mecánicos: frontmatter blockquote 3-obligatorias · footer canónico · heading principal con backticks (excepto root) · cross-refs válidos contra filesystem.

**Excepción única:** cuando el README pertenece a un PRP en curso de una sesión paralela (in-flight · `git status` lo muestra modificado por trabajo de otra sesión que NO es la propia) · NO tocarlo · pertenece al carril de esa otra sesión · paridad con [`surgical-changes.md`](./surgical-changes.md) ("NO tocar cosas ajenas").

## Lectura / consulta antes de actuar

> **Antes de actuar en una carpeta no trivial · leer su `README.md`.** Es la fuente primaria de la convención de esa carpeta. La info que SOLO el README contiene (procedimiento "Cómo agregar archivo nuevo" · severidad de smokes · plantilla bash a copiar · wiring CI híbrido · etc) NO se consigue con `ls` · `grep` · ni MCPs · solo leyendo el README. Paridad con regla [`no-suponer-fuente-de-verdad.md`](./no-suponer-fuente-de-verdad.md) (el README es archivo del repo · prioridad 1 de la fuente A) y con regla [`think-before-coding.md`](./think-before-coding.md) (listar asunciones · ir a fuente antes de implementar).

**Cuándo aplica:**

- Primera vez que la sesión toca archivos de una carpeta cuya convención NO es trivialmente obvia.
- Antes de agregar un smoke test · una regla · una memoria · un PRP · un spec · si la carpeta tiene README con sección "Cómo agregar archivo nuevo" o equivalente.
- Antes de mover · archivar · renombrar archivos para confirmar que el README destino justifica la operación.
- Cuando el shape de los archivos vecinos no es uniforme y se necesita criterio sobre cuál seguir.

**Cuándo NO aplica:**

- Edits triviales sobre archivos ya existentes sin tocar shape (typo · 1 línea · ajuste de wording · etc).
- Operaciones cuya convención está totalmente cubierta por reglas firmes específicas (ej: convenciones de naming · idempotencia · estructuras de datos · cero ambigüedad).
- Carpetas auto-generadas o sin README convencional (ej: `node_modules/` · `.next/` · paths efímeros del runtime).

**Procedimiento (3 pasos · simétrico con § Process · § Mantenimiento dinámico):**

1. **Read del README** antes del primer `Write` · `Edit` · o `Bash mv` sobre archivos de la carpeta. Si la sesión ya leyó el README en un turno anterior y NO hay razón para sospechar drift, no hace falta releer (paridad con regla [`no-suponer-fuente-de-verdad.md`](./no-suponer-fuente-de-verdad.md) § "auto-chequeo de 3 segundos").
2. **Si tiene "Cómo agregar archivo nuevo"** o sección equivalente · seguir esos pasos al pie de la letra (la convención del README gana sobre improvisación · paridad regla [`heuristica-referente-mercado.md`](./heuristica-referente-mercado.md) "el patrón documentado gana sobre la idea propia").
3. **Si la lectura detecta drift** (info stale · cross-ref roto · asimetría con hermanos · tabla desincronizada con filesystem) · disparar § Mantenimiento dinámico arriba · fixear trivialmente en el momento o presentar al user para fixes estructurales antes de seguir con la operación original.

**Tie-in con reglas hermanas:**

- [`no-suponer-fuente-de-verdad.md`](./no-suponer-fuente-de-verdad.md) · el README es la fuente primaria sobre la convención de su carpeta · cero suponer · ir a fuente.
- [`think-before-coding.md`](./think-before-coding.md) · listar asunciones sobre la carpeta · si el README las contradice · seguir el README.
- [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) · si la lectura detecta que el README es la única fuente de un procedimiento · no posponer su consulta.

## Template canónico (copiar/pegar)

> **Modelo único** del README.md de cualquier carpeta del repo. Reemplazar los placeholders `<...>` con contenido real. Mantener el orden de las secciones · NO improvisar otro shape.

````markdown
# `<path/relativo/al/repo>` · <título corto descriptivo>

> **Qué es:** <descripción 1-2 líneas · qué tipo de archivos vive acá · su rol funcional>.
>
> **Por qué se creó:** <razón · contexto · PRP/decisión/fecha que la motivó · firma user 🔵 si aplica>.
>
> **Para qué sirve:** <cómo se usa operativamente · qué problema resuelve · cómo se relaciona con el resto del proyecto>.

## Convención

- **Naming:** <patrón de naming de los archivos dentro · ej: `prp-NNN-<feature>.spec.ts`>.
- **Shape / formato:** <si los archivos siguen un shape canónico · referenciarlo · ej: shape P8 · plantilla bash>.
- **Otras reglas operativas:** <lo que NO se hace · convenciones de archivado · etc>.

## Subcarpetas (si aplica)

| Carpeta | Rol |
|---|---|
| [`<sub1>/`](./<sub1>/) | <descripción 1 línea> |

## Archivos actuales

| Archivo | Rol |
|---|---|
| `<archivo>` | <descripción 1 línea> |

## Carpetas hermanas

- [`<hermana1>`](<path>) — <relación funcional · cuándo usar esta vs aquella>.
- [`<hermana2>`](<path>) — <ídem>.

## Cómo agregar un archivo nuevo (opcional · si la carpeta es operativa multi-archivo)

1. <paso 1 · qué validar antes>.
2. <paso 2 · dónde escribir / qué actualizar>.
3. <paso 3 · qué tests/CI tocar>.

---

*Convención de README firmada YYYY-MM-DD (regla [`folder-creation-with-readme.md`](<path/relativo/a/la/regla>)).*
````

**Reglas operativas del template:**

1. **Frontmatter blockquote** con las 3 obligatorias (`Qué es` · `Por qué se creó` · `Para qué sirve`) en ese orden · cada una en línea propia con `> **<Sección>:**`.
2. **Heading principal** con backticks alrededor del path relativo + título corto descriptivo (ej: `` # `tests/scripts/infra-flujo/` · Capa transversal "infra del flujo" ``).
3. **Tablas** para subcarpetas y archivos actuales · 2 columnas mínimo (`Carpeta`/`Archivo` · `Rol`). Sumar más columnas si aplica (severidad · job CI · memoria fuente · etc).
4. **Carpetas hermanas** SIEMPRE lista de bullets con link relativo + 1 frase de relación funcional ("cuándo usar esta vs aquella"). Si no hay hermanas obvias (carpeta top-level), justificarlo 1 línea.
5. **Cómo agregar archivo nuevo** opcional · solo si la carpeta es operativa y tiene patrón claro (ej: agregar smoke test nuevo · agregar spec nuevo). Carpetas de archivado (`_archive/`) NO necesitan esta sección.
6. **Footer** con la línea cursiva referenciando esta regla y la fecha de adopción · obligatorio para trazabilidad.
7. **Secciones adicionales:** si por algún motivo necesitás crear alguna sección adicional a las propuestas en este template, podés hacerlo **debajo de las secciones fijas** (antes del footer · sin alterar el orden ni el contenido de las secciones fijas).

**Cross-reference firme:**

- Hermana operativa: [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md) (cualquier ambigüedad sobre la carpeta · preguntar al user con formato canónico).
- Hermana operativa: [`no-suponer-fuente-de-verdad.md`](./no-suponer-fuente-de-verdad.md) (validación previa de duplicados es ir a fuente · cero suposición sobre carpetas existentes).
- Hermana operativa: [`surgical-changes.md`](./surgical-changes.md) (creación de carpeta debe ser trazable al request · cero drive-by `mkdir`).
- Hermana operativa: [`agents-conditional-by-domain.md`](./agents-conditional-by-domain.md) (regla #35 · `.claude/config/` es carpeta nueva canónica creada bajo esta regla #22 · alberga config opt-in/opt-out de sub-agentes domain-tight · paridad arquitectónica padre↔especialización).
- Refuerza: [`quality-standard-senior.md`](./quality-standard-senior.md) (estándar senior incluye documentar el rol de cada artefacto · README es la mínima documentación de una carpeta).
- Refuerza: [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) (la doc no se pospone · README es doc operativa de la carpeta).
