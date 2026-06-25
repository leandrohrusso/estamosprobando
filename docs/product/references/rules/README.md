# `docs/product/references/rules/` · Reglas firmes del PRODUCTO

> **Qué es:** carpeta canónica donde viven las reglas firmes específicas del producto que el proyecto construye (constraints no negociables del dominio · principios del producto · vocabulario canónico del rubro · prohibiciones explícitas · regla stock fundamental · etc). Shape narrativo (NO obliga shape P8 que es para reglas del flujo).
>
> **Por qué se creó:** path contractual codificado por el pack workflow-base · paridad arquitectónica con [`.claude/rules/`](../../../../.claude/rules/) (reglas del FLUJO · cómo trabajamos) ↔ esta carpeta (reglas del PRODUCTO · qué construimos). Separar ambos canales evita mezclar doctrina del agente con doctrina del dominio del producto · cada uno tiene shape, lectores y disparadores distintos.
>
> **Para qué sirve:** (a) alojar las reglas firmes del producto que el agente debe respetar al implementar features (ej: "stock NUNCA puede ser negativo" · "vocabulario regional AR-friendly" · "cero argentinismos puros") · (b) servir de referencia consultable durante todo el flujo de 6 pasos cuando una decisión técnica toca un constraint del producto.

## Convención

- **Naming:** kebab-case en español o inglés según el dominio del producto · descriptivo · 2-4 palabras (ej: `backoffice-simple.md` · `principios-producto.md` · `vocabulario-regional.md` · `regla-stock-fundamental.md`).
- **Shape:** narrativo libre · cero obligación de shape P8 (ese shape es para reglas del flujo en `.claude/rules/`). Estructura recomendada (no contractual): frontmatter blockquote con "Qué dice la regla" + secciones libres con "Por qué" · "Cuándo aplica" · "Ejemplos del producto" · "Cross-reference".
- **Footer recomendado:** referencia a la hermana del flujo cuando aplica (ej: regla del producto sobre simplicidad de UI ↔ regla del flujo `simplicity-first.md`).

## Archivos actuales (templates del pack · vacíos al boot)

| Archivo | Rol |
|---|---|
| [`backoffice-simple.md`](./backoffice-simple.md) | Plantilla para principio "menos es más" aplicado al UI del operador del backoffice. Vacío al boot · llenar si el producto tiene panel/backoffice · eliminar si NO aplica. |
| [`principios-producto.md`](./principios-producto.md) | Plantilla para los principios firmes del producto (constraints no negociables del rubro · prohibiciones explícitas · stock fundamental · etc). Vacío al boot · llenar conforme arranca el proyecto. Hermana arquitectónica del lado FLUJO: [`.claude/rules/principios-desarrollo-flujo.md`](../../../../.claude/rules/principios-desarrollo-flujo.md). |

## Carpetas hermanas

- [`docs/product/references/`](../) (carpeta padre) — Source of Truth de docs de producto del proyecto (`PRD.md` · `product-vision.md` · `product-roadmap.md`). Esta sub-carpeta es para reglas del producto · el padre es para docs canónicos del producto.
- [`.claude/rules/`](../../../../.claude/rules/) (paralela arquitectónica) — reglas firmes del FLUJO (cómo trabajamos · shape P8 obligatorio). Cero solapamiento de scope · cada carpeta cubre un eje (producto vs flujo).

## Cómo agregar una regla nueva del producto

1. **Validar duplicados:** ¿hay regla existente que ya cubra el patrón? Si SÍ, extender. Si NO, continuar.
2. **Naming canónico:** kebab-case · 2-4 palabras descriptivas del scope de la regla.
3. **Shape recomendado:** frontmatter blockquote con "Qué dice la regla" + "Por qué firme" + secciones libres según contenido (ejemplos · excepciones · cross-references). NO copiar shape P8 del flujo · este lado es narrativo libre.
4. **Cross-references:** sumar al footer link a regla hermana del flujo en `.claude/rules/` cuando aplique (ej: regla de producto sobre simplicidad UI ↔ regla del flujo `simplicity-first.md`).
5. **Indexar en CLAUDE.md:** sumar fila a la tabla "Reglas del producto" en CLAUDE.md (al boot vacía · llenar conforme aparezcan reglas concretas del producto).
6. **Cero shape P8 obligatorio:** si la regla amerita anti-rationalization · red flags · verification (paridad P8), agregar esas secciones. Si no, narrativo libre.

## Qué NO va acá

- ❌ Reglas del flujo del agente (esas viven en [`.claude/rules/`](../../../../.claude/rules/) con shape P8 obligatorio).
- ❌ Documentos de producto generales (PRD · vision · roadmap · esos viven en la carpeta padre [`docs/product/references/`](../)).
- ❌ Reglas operativas de implementación (esas viven en el PRP correspondiente).
- ❌ Decisiones puntuales del bucle agéntico (esas viven en la sección "Aprendizajes" del PRP).

---

*README firmado al adoptar regla [`folder-creation-with-readme.md`](../../../../.claude/rules/folder-creation-with-readme.md) (regla #22 · pack `workflow-base`).*
