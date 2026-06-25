# Grupos canónicos del CSV de validación

> **Template universal.** Adaptar los grupos al dominio del proyecto. Cada grupo agrupa casos del PRP por **familia técnica** (no por feature). El objetivo: criterios de éxito binarios + cobertura completa de invariantes críticos.

## Grupos sugeridos (adaptar al proyecto)

| Grupo | Código | Cuándo aplica | Verifica |
|---|---|---|---|
| **Schema BD** | `MIG` | Si el PRP crea o modifica tablas/columnas/índices/constraints | Verificación SQL de cada tabla, columna, tipo, NOT NULL, DEFAULT, CHECK constraint, índice único, trigger, función. |
| **CRUD básico** | `CRD` | Si el PRP agrega operaciones de lectura/escritura sobre nuevas entidades | Cada operación CRUD desde UI → SQL DB. Validación de inputs. Errores esperados. |
| **Atomicidad de operaciones** | `ATM` | Si el PRP introduce RPCs / transacciones / operaciones compuestas | La operación es atómica end-to-end. Estados intermedios no son observables. Rollback funciona ante fallo. |
| **Auditoría** | `AUD` | Si el PRP toca tabla de audit log | Cada acción crítica registra fila completa en audit log (actor, before, after, metadata). |
| **Permisos por rol** | `PERM` | Si el PRP introduce roles nuevos o cambia permisos existentes | Cada rol puede hacer lo que se espera, NO puede hacer lo que NO se espera. Casos negativos explícitos. |
| **Multi-tenant / Aislamiento** | `ISO` | Si hay datos de múltiples tenants | Tenant A no ve datos de tenant B. Intentar GET de recurso ajeno devuelve 404. SQL via app muestra solo los datos propios. |
| **Endpoints públicos** | `PUB` | Si el PRP expone endpoints sin auth | Cada endpoint público respeta rate limiting, sanitización, validación. Inputs maliciosos rechazados. |
| **Soft delete** | `SDL` | Si el PRP introduce soft delete sobre entidades | La entidad eliminada NO aparece en queries normales, pero sigue existiendo en BD. Reactivación funciona. |
| **Reglas FIRMES** | `RUL` | Si el PRP toca código sujeto a reglas firmes con call sites cross-repo | Cada call site relevante respeta la regla FIRME post-fix (cero asimetría acumulada). |
| **Dominio específico** | `DOM` | Si el PRP toca lógica nuclear del producto | Casos representativos del dominio que verifican comportamiento end-to-end del feature. |

## Orden recomendado de grupos en el CSV

1. **MIG** primero (sin schema correcto, nada funciona).
2. **CRD** después (operaciones base sobre el schema).
3. **ATM** + **AUD** (transversales · validan que las operaciones son atómicas y auditadas).
4. **PERM** + **ISO** (seguridad multi-tenant).
5. **PUB** (si aplica · expone superficie al mundo).
6. **SDL** (si aplica · soft delete consistency).
7. **RUL** (reglas FIRMES con call sites cross-repo).
8. **DOM** (casos del dominio específico del producto).

## Cómo adaptar al proyecto

Cada PRP define en su sección "Inventario de casos a validar" qué grupos aplican. NO todos los grupos en todos los PRPs · solo los relevantes al scope. Si el PRP es pure refactor sin schema, **MIG** se omite; si no expone endpoints públicos, **PUB** se omite.

**Grupos adicionales específicos del proyecto:** sumarlos a esta tabla con código de 3 letras canónico (ej: `WHK` para webhooks · `EML` para email · etc).
