# `tests/manual/` · Matriz CSV de validación · skill `/validar`

> ⚙️ **Stack adaptation banner:** este README menciona **Playwright MCP + Supabase MCP** como ejemplos típicos de MCPs usados en runtime por el skill `/validar`. Si tu proyecto usa otros MCPs (Firebase MCP · Postgres MCP genérico · Browserbase MCP · etc), adaptá: el principio (matriz CSV exhaustiva · 100% verde antes del merge · destilación a specs codificados vía PRINCIPIO 6) es universal · los MCPs concretos cambian.

> **Qué es:** carpeta operativa del skill [`/validar`](../../.claude/skills/validar/SKILL.md) (paso 5 del flujo de 6 pasos · Verificación). Cada PRP del producto crea acá su CSV `PRP-NNN_<slug>-validation.csv` con el 100% de los casos a verificar · más credenciales reales para login runtime + screenshots de evidencia.
>
> **Por qué se creó:** materializar la doctrina de *"verificá comportamiento, no líneas"*. El CSV exhaustivo es el artefacto core del paso 5 · ejecutado contra la app real con los MCPs del stack del adopter.
>
> **Para qué sirve:** dejar trazabilidad fila-por-fila del comportamiento entregado por cada PRP · garantizar 100% verde antes del merge · destilar casos a specs codificados en [`tests/e2e/regression/`](../e2e/regression/) y [`tests/sql/`](../sql/) vía PRINCIPIO 6 del skill `/validar`.

## Convención

- **Naming CSV:** `PRP-NNN_<slug>-validation.csv` (ej: `PRP-001_<feature>-validation.csv`).
- **Columnas canónicas:** `ID · Categoría · Caso · Pasos · Resultado esperado · Evidencia · Estado`.
- **Estados:** `Funciona` · `Falla` · `Diferido (justificado)`. NO se mergea sin 100% verde.
- **Screenshots de evidencia:** `screenshots/PRP-NNN/[ID]-[descripción].png` · cada fila con captura cuando aplica.
- **Credenciales:** `.credentials.local.json` (gitignored · operativo en runtime). El template `.credentials.local.json.test-template` se copia y se completa con valores reales por dev (pendiente de materialización just-in-time según `TEMPLATE_PENDING_STRUCTURALS.md` bache #10).
- **Archivado:** los CSVs de PRPs cerrados se mueven a `_archive/` cuando la cobertura quedó codificada en `regression/` y/o `sql/` (adopter crea la carpeta cuando aplique · paridad con `tests/e2e/_archive/`).

## Archivos actuales (al boot del template)

> Al boot del template la carpeta arranca **vacía** (solo este README). Cada adopter agrega CSVs conforme corre el paso 5 del skill `/validar` para cada PRP del producto.

**Estructura sugerida cuando empiecen a aparecer artefactos:**

| Archivo / carpeta | Rol típico |
|---|---|
| `.credentials.local.json` | Credenciales reales para login runtime · gitignored (NO commitear) |
| `.credentials.local.json.test-template` | Template para devs nuevos · estructura sin valores (bache #10 del registro · materialización just-in-time) |
| `PRP-NNN_<slug>-validation.csv` | CSV del PRP en curso o histórico |
| `screenshots/PRP-NNN/` | Capturas de evidencia por caso |
| `_archive/` | CSVs históricos + reportes + screenshots de PRPs cerrados |

## Carpetas hermanas

- [`tests/e2e/regression/`](../e2e/regression/) — destino de los casos del CSV destilados a specs codificados (PRINCIPIO 6 del skill `/validar`).
- [`tests/sql/`](../sql/) — invariantes SQL · destino paralelo cuando el caso del CSV es de capa BD.
- [`.claude/skills/validar/`](../../.claude/skills/validar/) — skill que opera sobre esta carpeta · referencia las credenciales runtime y la convención del CSV.

## Cómo crear un CSV nuevo (resumen del skill `/validar`)

1. Leer el PRP del producto · enumerar el 100% de los comportamientos entregados.
2. Crear `tests/manual/PRP-NNN_<slug>-validation.csv` con todas las filas.
3. Verificar credenciales en `.credentials.local.json` · si NO existen, copiar desde `.credentials.local.json.test-template` y completar valores reales.
4. Ejecutar fila por fila contra la app real con los MCPs del stack del adopter · marcar Estado.
5. Cada `Falla` se fixea con calidad senior + spec PRINCIPIO 6 en `tests/e2e/regression/` o `tests/sql/` antes del re-test (regla [`regression-first-on-fix`](../../.claude/rules/regression-first-on-fix.md)).
6. Reporte 100% verde · cierre del PRP (paridad regla [`always-fix-all-bugs`](../../.claude/rules/always-fix-all-bugs.md) · cero bug diferido sin firma user).

---

*Convención de README firmada 2026-05-25 (regla [`folder-creation-with-readme.md`](../../.claude/rules/folder-creation-with-readme.md)).*
