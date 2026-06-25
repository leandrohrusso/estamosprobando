# `.claude/memory/reference/` · Punteros y referencias operativas internas

> **Qué es:** memorias que documentan referencias estables del proyecto · helpers operativos · ubicación de credenciales gitignored · selectors de testing · mapas de componentes · bitácoras transversales (technical-debt log · ultrareview log) · baselines · notas operativas que sobreviven entre sesiones.
>
> **Por qué se creó:** preservar contexto operativo que NO vive en código pero que el agente o el dev necesitan rápido. Sin esta carpeta · cosas como "dónde está la URL de la TEST DB" · "cómo se llaman los selectors de Playwright para shadcn" · "qué CSV es el golden reference para validación" se redescubren cada sesión con costo.
>
> **Para qué sirve:** evitar redescubrir · permitir que cualquier sesión nueva consulte rápido la referencia operativa · servir de SoT auxiliar para tooling interno (test infra · CI · MCPs · audit logs).

## Convención

- **Naming:** kebab-case · descriptivo · `<recurso-o-area>.md` (ej: `test-credentials.md` · `playwright-shadcn-selectors.md` · `mcp-supabase.md`).
- **Frontmatter:** `name` · `description` · `type: reference`.
- **Estructura sugerida:** qué es el recurso · ubicación (path o URL) · cuándo consultarlo · qué buscar específicamente · cross-references si aplica. Ver [`_template.md`](./_template.md).
- **Cero secrets:** acá NO van credenciales · solo punteros (las credenciales viven en gitignored `.local.json` files fuera de `.claude/`).

## Memorias seed (pack workflow-base)

> Vacío al boot del pack. Sumar referencias específicas del proyecto conforme aparezcan (ubicaciones de TEST DB · MCPs activos · dashboards de monitoring · etc).

## Cómo agregar una memoria nueva

1. Identificar el recurso operativo · validar que NO existe ya en `feedback/` (gotcha) o `project/` (estado vivo).
2. Copiar [`_template.md`](./_template.md) y renombrar a kebab-case con frontmatter + Overview + ubicación + cuándo consultarlo.
3. Sumar entry en [`../MEMORY.md`](../MEMORY.md) § `reference/` con descripción 1-frase.
4. Cross-reference desde reglas firmes · skills · PRPs cuando aplique.

## Carpetas hermanas

- [`.claude/memory/feedback/`](../feedback/) — anti-patterns técnicos (NO punteros operativos).
- [`.claude/memory/project/`](../project/) — estado vivo de PRPs (NO referencias estables).
- [`.claude/memory/user/`](../user/) — perfil del user (NO recursos operativos).

## Reglas firmes asociadas

- [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) — al cerrar PRP · si el PRP descubrió referencia operativa nueva · va acá.
- [`no-suponer-fuente-de-verdad.md`](../../rules/no-suponer-fuente-de-verdad.md) — cuando el agente busca referencia interna del proyecto · esta carpeta es prioridad 2 después de archivos del repo.

---

*Convención de README firmada 2026-05-20 (regla [`folder-creation-with-readme.md`](../../rules/folder-creation-with-readme.md)).*
