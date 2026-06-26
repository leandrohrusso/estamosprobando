# BUSINESS_LOGIC de PUERTITA · identidad y constraints no negociables

> **Fuente única de verdad sobre QUÉ se construye** (vs `WORKFLOW.md` = CÓMO). Derivado del PRD v1.0 ([`docs/product/references/PRD.md`](docs/product/references/PRD.md)) durante el bootstrap. El skill `/arrancar` lo lee en cada boot para enmarcar las decisiones del producto.

## § 1 · Identidad del producto

**Nombre:** PUERTITA

**Dominio:** `pendiente`

**One-liner:** SaaS multitenant de ticketing para eventos (B2B2C) · cada organización publica eventos, vende entradas online con cobro directo a su cuenta y valida el ingreso por QR desde el celular · sin sobreventa y sin depender del equipo de la plataforma.

**Founder / equipo:** `pendiente de definir` (operación inicial vía `boleterialive@gmail.com`).

**Magic moment:** un organizador nuevo va de cero a evento publicado + primera venta + check-in en la puerta el día del evento, de forma autónoma, sin soporte de la plataforma y sin un solo caso de sobreventa.

## § 2 · Problema + costo

**Dolor primario:** los organizadores de eventos pequeños y medianos necesitan publicar, vender y validar entradas sin depender de plataformas caras, rígidas o que retienen el dinero. Hoy lo resuelven con planillas, links de pago sueltos y validación manual en la puerta.

**Costo del status quo:** sobreventa, errores de caja, mala experiencia del comprador y del staff, y dinero retenido por intermediarios.

## § 3 · Solución + flujo

**Happy path del usuario primario (organizador):**

1. Se registra (magic link) y crea su organización.
2. Crea un evento en borrador (fecha, ubicación, capacidad) + define tipos de entrada con cupo propio.
3. Conecta su cuenta de cobro (Mercadopago/Mobbex) y publica el evento.
4. Comparte la URL pública; los compradores hacen guest checkout (nombre + email) con hold de stock ~10 min y pagan.
5. El sistema emite un ticket con QR firmado por cada entrada y lo envía por email tras confirmar el pago.
6. El día del evento, el staff valida los QR desde el celular (PWA · atómico/idempotente · con modo offline).
7. El organizador ve ventas, ingresos y % de check-in en tiempo real, y exporta reportes (CSV/PDF).

## § 4 · Usuario objetivo

**Persona primaria:** organizador de eventos pequeños/medianos (Org Owner/Admin) · perfil no técnico · quiere publicar, vender y cobrar sin fricción.

**Personas operativas:** Org Staff (check-in en la puerta) · Platform Superadmin (gestión de tenants y salud del sistema · no opera eventos) · Comprador/Asistente (guest checkout, recibe tickets por email).

**Anti-persona:** clientes enterprise con exigencias de compliance que requieran aislamiento schema/DB-per-tenant, asientos numerados o dominios propios (fuera de v1).

## § 5 · Modelo de negocio

**Modelo:** marketplace transaccional · cobro directo al organizador con split (destination charge) · la plataforma NO es custodia del dinero ajeno.

**Pricing / fees:** comisión por ticket (porcentaje + fijo), configurable por organización (`organizations.fee_pct` + `fee_fixed`).

**Métricas clave:** GMV por organización · comisión neta de la plataforma · targets formales `pendientes de definir`.

## § 6 · KPIs de éxito

**KPI #1 (norte estrella):** tasa de sobreventa = **0** (cualquier caso es bug crítico) + onboarding autónomo (organizador llega a su primer evento publicado sin soporte).

**KPIs operativos:** tiempo de creación de un evento (< 5 min) · tasa de conversión de checkout (vista de evento → compra completada) · tickets validados sin incidencias (escaneos exitosos / total).

## § 7 · Stack confirmado

**Frontend:** Next.js (App Router) + Tailwind + shadcn/ui.

**Backend:** Server Actions (mutaciones desde el frontend · resuelven `organization_id` desde la sesión, nunca de input del cliente) + Supabase Edge Functions (webhooks de pago, generación de PDF, emails vía Resend, tareas con secretos).

**Base de datos:** Supabase Postgres + RLS por `organization_id` en TODAS las tablas de negocio.

**Auth:** Supabase Auth · magic link (sin contraseñas) para organizadores y staff · memberships (un usuario puede pertenecer a varias organizaciones con distinto rol) · los compradores NO usan Auth.

**Pagos / providers externos:** Mercadopago (principal · LatAm) + Mobbex (alternativa/segundo proveedor) + Resend (emails transaccionales con PDF adjunto).

**Hosting:** Vercel + Supabase Cloud.

**Tooling:** Husky + lint-staged + Playwright (E2E) + Vitest (unit) + GitHub Actions (CI).

## § 8 · Constraints no negociables

> Decisiones críticas del producto que enmarcan cada PRP futuro · firmadas e inmutables hasta que el founder explícitamente las revise (con actualización de este archivo + entrada `directional` en `.claude/memory/log.md`).

1. **Multi-tenant · aislamiento estricto por RLS.** Cada organización ve SOLO sus datos · RLS por `organization_id` en todas las tablas de negocio · el `organization_id` se deriva SIEMPRE de la sesión/membership, nunca de input del cliente. **Por qué firme:** una fuga cross-tenant es game-over legal + de confianza.

2. **Stock atómico · cero sobreventa.** El decremento de cupo es atómico (lock de fila / contador en Postgres) dentro de la transacción de hold/compra · sobreventa = bug crítico (objetivo: 0). **Por qué firme:** la sobreventa destruye el trust del organizador y compromete la capacidad real.

3. **Check-in atómico e idempotente.** El primer escaneo marca el ticket `used` en una sola operación · escaneos siguientes devuelven "ya validado" · sin doble uso ni con dos operadores simultáneos. **Por qué firme:** el doble ingreso es fraude/error operativo en la puerta.

4. **Guest checkout sin cuenta.** El comprador NO usa Auth · guest checkout con nombre + email. **Por qué firme:** exigir registro reduce la conversión · es el estándar del rubro.

5. **Pagos split · cobro directo al organizador.** El dinero va directo a la cuenta de cobro del organizador (MP/Mobbex) · la plataforma retiene su comisión automáticamente · NO es custodia del dinero ajeno. **Por qué firme:** evita problemas regulatorios y de flujo de caja.

6. **Emisión de tickets SOLO tras pago confirmado por webhook.** La confirmación se procesa vía webhook (Edge Function) con idempotency keys, no por el redirect del navegador · los tickets se emiten solo tras confirmación efectiva. **Por qué firme:** el redirect no es confiable y los webhooks pueden llegar duplicados.

7. **QR firmado · no enumerable.** `tickets.qr_signature` firmado (HMAC/JWT) · no falsificable ni adivinable por enumeración. **Por qué firme:** seguridad anti-fraude del ticket.

8. **Hold temporal libera stock Y código juntos.** El hold (~10 min) reserva stock + uso de código promocional · si el carrito se abandona, ambos se liberan automáticamente · no se "queman" códigos por carritos abandonados. **Por qué firme:** UX del comprador + integridad de cupos y promos.

9. **Un (1) código promocional por compra · no combinable.** **Por qué firme:** evita convertir el sistema en un motor de reglas (otra escala de complejidad · scope freeze del MVP).

10. **Secretos solo en servidor / Edge Functions.** Webhooks, generación de PDF, emails y secrets viven en Edge Functions/servidor, nunca en el cliente. **Por qué firme:** seguridad.

11. **Audit log de acciones sensibles.** Quién publicó/canceló un evento, quién reembolsó, quién validó un ticket. **Por qué firme:** trazabilidad legal y operativa.

12. **Scope congelado de promos y reportes (anti scope-creep).** Los límites del PRD §6.3 (descuentos) y §7.4 (reportes) están congelados · cualquier extensión va a un v2 explícito. **Por qué firme:** mantener el MVP acotado.

### Constraints del dominio que activan sub-agentes de `/revisar` y `/revisar-main`

> Flags que activan los 3 sub-agentes domain-tight · alimentan [`.claude/config/agents-applicability.yml`](.claude/config/agents-applicability.yml) (mapeo 1:1 · `multi_tenant` → `multi-tenant.enabled` · `stock_atomicity` → `atomicity.enabled` · `relational_db_with_migrations` → `migration-safety.enabled`). Doctrina: regla firme #35 [`agents-conditional-by-domain.md`](.claude/rules/agents-conditional-by-domain.md).

**Decisiones del proyecto:**

| Flag | Valor | Justificación 1-frase |
|---|---|---|
| `multi_tenant` | `yes` | SaaS multi-tenant pooled + RLS por `organization_id` en todas las tablas de negocio (PRD §3). |
| `stock_atomicity` | `yes` | Anti-overselling con decremento atómico de cupo · "sobreventa = bug crítico" (PRD §5.4). |
| `relational_db_with_migrations` | `yes` | Supabase Postgres + migraciones + RLS policies (PRD §2). |

## § 9 · Mapa de documentación

| Área | SoT | Cuándo consultar |
|---|---|---|
| Identidad + constraints del producto | este archivo (`BUSINESS_LOGIC.md`) | Al planificar cualquier PRP |
| PRD v1 (fuente del bootstrap) | [`docs/product/references/PRD.md`](docs/product/references/PRD.md) | Al planificar features del MVP · modelo de datos orientativo (§13) · user stories Gherkin (§12) |
| Roadmap operativo | [`docs/product/product-roadmap.md`](docs/product/product-roadmap.md) | Al elegir la próxima task |
| Decisiones arquitectónicas históricas | [`.claude/memory/project/`](.claude/memory/project/) | Continuidad multi-sesión |

---

> **Tips para sesiones futuras:**
>
> - Al cerrar un PRP que cambia un constraint de § 8, actualizar este archivo + entrada `directional` en `.claude/memory/log.md` (regla #18 [`golden-rule-docs-memory.md`](.claude/rules/golden-rule-docs-memory.md)).
> - Al sumar área de documentación nueva, sumar fila en § 9.
> - Si el founder firma cambio del stack (§ 7), actualizar acá + entrada `directional` en `log.md` + verificar que los skills heavy-MCP (`/implementar` · `/validar`) sigan teniendo allowed-tools válidos.

---

_Documento canónico de identidad/business logic de PUERTITA · derivado del PRD v1.0 (`docs/product/references/PRD.md`) durante el bootstrap del 2026-06-25._
