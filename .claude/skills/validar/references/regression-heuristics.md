# Heurísticas de Regresión — Qué re-testear tras un fix

Cuando se aplica un fix para una fila en `Falla`, no se re-corre todo el CSV. Se re-corre solo lo que el fix pudo haber afectado. Esta tabla define qué re-testear según el tipo de fix.

## Por tipo de cambio

| Tipo de fix | Re-testear obligatoriamente |
|---|---|
| **Cambio en migración de BD (columna, constraint, default)** | Todos los grupos MIG + todos los casos de Crear/Editar que usan esa columna |
| **Cambio en policy de seguridad row-level** | Todos los grupos RLS de la tabla afectada + casos de Permisos (PERM) e Isolation (ISO) relacionados |
| **Cambio en Server Action** | El caso que falló + todos los casos de Audit log (AUD) que la acción debería generar + casos de Permisos que la acción protege |
| **Cambio en validación de inputs (Zod · Yup · etc)** | Todos los casos de validación (ZOD) del mismo formulario |
| **Cambio en componente React (UI)** | Los casos de Navegación (NAV) y de UI que lo usan |
| **Cambio en middleware / routing** | Los casos de Setup (S) que prueban auth/redirect + casos de Navegación (NAV) |
| **Cambio en RPC SQL** | El caso que usa la RPC + los casos de Schema BD (MIG) que verifican la existencia y comportamiento de la función |
| **Cambio en trigger de BD** | El caso que activa el trigger + los casos donde el trigger NO debería ejecutarse (verificar que no hay side effects indeseados) |
| **Cambio en query a la BD (client-side)** | El caso que fallaba + los casos de aislamiento ISO que usan la misma query |
| **Fix de tipado TypeScript** | Correr `npm run typecheck` + correr el caso que fallaba |

## Regla general

**La pregunta a responder es: "¿qué otros casos del CSV comparten la misma ruta de código que acabo de tocar?"**

- Si tocaste un archivo de Server Action → re-testear todos los casos de ese formulario/flujo.
- Si tocaste un archivo de servicio (`<services dir del proyecto>`) → re-testear todos los casos que llaman a ese servicio.
- Si tocaste una migración de BD → re-testear todos los casos que tocan esa tabla.
- Si tocaste middleware → re-testear todos los casos de auth/redirect/routing.

## Casos que SIEMPRE se re-testean tras cualquier fix

Los siguientes casos son "canario" — si algo rompió transversalmente, se manifiesta acá primero:

1. `S1` — dev server sigue corriendo y respondiendo.
2. `S2` — login con el usuario principal sigue funcionando.
3. El primer caso del grupo donde se hizo el fix.

## Cuándo hacer full re-run

Solo en estos dos casos:

1. **El fix tocó el middleware principal** (`src/middleware.ts`) → re-correr todos los grupos S y NAV.
2. **El fix tocó una migration que modifica tablas base** (ej: en un dominio ticketing serían producers, users, organization_memberships · adaptá a las tablas base del proyecto) → re-correr todos los grupos MIG y RLS.

En cualquier otro caso, un full re-run es overkill y consume tiempo innecesario. Aplicar las heurísticas de arriba para acotar.
