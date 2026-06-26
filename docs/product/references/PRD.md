# PRD — Sistema Multitenant de Ticketing para Eventos

> **Versión:** 1.0 (v1 / MVP)
> **Estado:** Borrador para revisión
> **Tipo de producto:** SaaS multitenant (B2B2C) — los organizadores son los clientes (tenants); los asistentes son usuarios finales.

---

## 1. Contexto y objetivo

### 1.1 Problema
Los organizadores de eventos pequeños y medianos necesitan publicar eventos, vender entradas y validar el ingreso sin depender de plataformas caras, rígidas o que retienen el dinero. Hoy resuelven esto con planillas, links de pago sueltos y validación manual en la puerta, lo que genera sobreventa, errores de caja y mala experiencia.

### 1.2 Objetivo
Ofrecer una plataforma donde cada organización pueda, de forma autónoma:
- Crear y publicar eventos en minutos.
- Vender entradas online con pago integrado y cobro directo a su cuenta.
- Emitir tickets con QR y validarlos en la puerta desde un celular.
- Ver ventas, ingresos y asistencia en tiempo real.

### 1.3 Definición de éxito
Un organizador nuevo puede registrarse, crear un evento, venderlo y hacer check-in el día del evento **sin intervención del equipo de la plataforma** y **sin un solo caso de sobreventa**.

### 1.4 Personas

| Persona | Descripción | Necesidad principal |
|---|---|---|
| **Organizador (Owner/Admin)** | Productor de eventos, dueño del tenant | Publicar, vender y cobrar sin fricción |
| **Staff de puerta** | Operario el día del evento | Escanear y validar rápido, incluso con mala señal |
| **Asistente / Comprador** | Público que compra entradas | Comprar en pocos pasos, sin crear cuenta |
| **Superadmin de plataforma** | Equipo interno | Gestionar tenants y la salud del sistema |

---

## 2. Stack técnico

El sistema se construye sobre el siguiente stack (fijado para v1):

| Capa | Tecnología |
|---|---|
| **Frontend** | Next.js (App Router) + Tailwind + shadcn/ui |
| **Backend** | Server Actions + Supabase Edge Functions |
| **Base de datos** | Supabase Postgres + RLS por `organization_id` |
| **Auth** | Supabase Auth (magic link + memberships) |
| **Pagos / externos** | Mercadopago / Mobbex + Resend (emails) |
| **Hosting** | Vercel + Supabase Cloud |
| **Tooling** | Husky + lint-staged + Playwright + Vitest + GitHub Actions |

### 2.1 Implicancias arquitectónicas del stack
- **Server Actions** son el canal por defecto para mutaciones desde el frontend (checkout, CRUD de eventos). Toda Server Action **debe** resolver el `organization_id` desde la sesión, nunca desde input del cliente.
- **Edge Functions** se usan para lógica que no debe vivir en el cliente ni depende de una sesión de usuario: webhooks de pago (Mercadopago/Mobbex), generación de PDFs, envío de emails vía Resend, y tareas con secretos.
- **RLS por `organization_id`** es la línea de defensa principal del aislamiento entre tenants. La seguridad no depende de que el código de aplicación recuerde filtrar.
- **Supabase Auth con memberships**: un usuario puede pertenecer a varias organizaciones con distinto rol. El login es **magic link** (sin contraseñas) para organizadores y staff. Los compradores **no usan Auth**.

---

## 3. Modelo multitenant

### 3.1 Definición de tenant
Un **tenant = una organización** (`organizations`). Cada evento, entrada, venta, código y reporte pertenece a exactamente una organización.

### 3.2 Estrategia de aislamiento — **Pooled + RLS**
- Base de datos única (Supabase Postgres).
- Cada tabla con datos de negocio incluye la columna `organization_id`.
- **Row-Level Security activado en todas esas tablas.** Las políticas garantizan que cada query sólo vea filas de las organizaciones a las que el usuario autenticado pertenece (vía tabla `memberships`).
- El `organization_id` se deriva siempre del contexto de sesión / membership, **nunca** de un parámetro enviado por el cliente.

> **Descartado en v1:** schema-per-tenant y database-per-tenant. Aportan más aislamiento pero su costo operativo (migraciones, backups, pooling de conexiones) no se justifica hasta tener clientes enterprise con exigencias de compliance que lo requieran.

### 3.3 Identificación del tenant
- **v1:** path-based (`app.com/{org-slug}/...`) — el más simple de implementar sobre App Router con segmentos dinámicos.
- **Evolución:** subdominio (`{org}.app.com`) resuelto en middleware.
- **Fuera de v1:** dominio propio (`entradas.miorg.com`).

### 3.4 Reglas transversales (aplican a todo el documento)
1. Toda tabla de negocio tiene `organization_id` + política RLS.
2. Toda Server Action y Edge Function valida la pertenencia del usuario a la organización antes de operar.
3. Las páginas públicas de compra (que no requieren login) acceden a los datos del evento mediante consultas server-side acotadas al evento publicado, sin exponer datos internos del tenant.

---

## 4. Roles y permisos (RBAC)

| Rol | Pertenece a | Puede |
|---|---|---|
| **Platform Superadmin** | Plataforma | Gestionar organizaciones, suspender cuentas, ver métricas globales. No opera eventos. |
| **Org Owner** | Una organización | Todo lo de Admin + facturación/conexión de cobros + gestión de miembros |
| **Org Admin** | Una organización | Crear/editar/publicar eventos, gestionar entradas y promos, ver reportes |
| **Org Staff** | Una organización | Check-in y lista de asistentes. Sin acceso financiero ni edición de eventos |
| **Comprador / Asistente** | — (sin cuenta) | Guest checkout con email. Recibe tickets por correo |

- Los roles dentro de una organización se modelan en la tabla `memberships` (`user_id`, `organization_id`, `role`).
- El comprador **no tiene cuenta**: guest checkout con email. Es el estándar en ticketing porque exigir registro reduce la conversión.

---

## 5. Funcionalidades core (v1)

### 5.1 Gestión de eventos
- CRUD de eventos con estados: `borrador → publicado → finalizado` (+ `cancelado`).
- Campos: nombre, descripción, imagen, fecha/hora de inicio y fin, ubicación, capacidad total.
- Sólo los eventos en estado `publicado` son visibles y comprables públicamente.

### 5.2 Tipos de entrada
- Múltiples tipos por evento (ej. General, VIP, Early Bird).
- Cada tipo: nombre, precio, cupo propio, ventana de venta (desde/hasta).
- La suma de cupos no necesita igualar la capacidad total (puede haber tipos solapados), pero **ninguna venta puede superar el cupo de su tipo**.

### 5.3 Checkout (sin login)
- Carrito simple: selección de tipos y cantidades.
- Datos del comprador: nombre + email.
- **Reserva temporal (hold) de ~10 min**: al iniciar el checkout se reserva el stock; si no se completa el pago, se libera automáticamente.
- Aplicación opcional de un código promocional (ver §6).
- Pago vía Mercadopago / Mobbex.
- Confirmación + emisión inmediata de tickets.

### 5.4 Control de stock (anti-overselling)
- El decremento de cupo es **atómico** dentro de la transacción de reserva/compra (lock a nivel fila o contador atómico en Postgres).
- Bajo concurrencia alta (lanzamiento de evento popular), el sistema nunca vende más entradas que el cupo disponible. **Sobreventa = bug crítico.**

### 5.5 Emisión de tickets
- **Un QR único por entrada individual** (no por compra).
- El código se **firma** (HMAC/JWT) para que no se pueda falsificar ni adivinar por enumeración.
- Entrega por **email vía Resend**, con PDF adjunto del/los ticket(s).

### 5.6 Check-in / validación
- Scanner web tipo **PWA**, usable desde el celular del staff.
- Validación **atómica e idempotente**: el primer escaneo marca el ticket como `usado` en una sola operación; los escaneos siguientes devuelven "ya validado".
- Previene el doble uso incluso con dos operadores escaneando simultáneamente.
- **Degradación con gracia**: la app cachea la lista de tickets válidos del evento para seguir validando si cae la conexión en el venue, sincronizando al reconectar.

### 5.7 Panel del organizador
- Ventas e ingresos en tiempo real.
- Entradas vendidas vs. capacidad (por tipo y total).
- Lista de asistentes.
- % de check-in en vivo el día del evento.
- Uso de códigos promocionales.

---

## 6. Descuentos y códigos promocionales

### 6.1 Alcance (deliberadamente acotado)
- **Tipo de descuento:** porcentaje (`20%`) **o** monto fijo (`$500`).
- **Alcance del código:** toda la compra, o restringido a tipos de entrada específicos.
- **Límites:** usos totales (ej. primeros 50), usos por comprador (default 1), ventana de validez (desde/hasta).
- **Estado:** activo / inactivo (corte manual).

### 6.2 Reglas de aplicación
- **Un (1) código por compra.** No combinable/stackeable.
- El código se valida y aplica **dentro del mismo hold** de la reserva (§5.3). Si el carrito se abandona, el uso del código se libera junto con el stock — **no se "queman" códigos** por carritos abandonados.
- El contador de usos se decrementa de forma **atómica**, reutilizando el mismo patrón de concurrencia del stock (§5.4).

### 6.3 Fuera de alcance (v1)
Descuentos automáticos sin código (ej. "2x1 los martes"), descuentos combinables entre sí, y descuentos escalonados por cantidad. Eso convierte el sistema en un motor de reglas, que es otra escala de complejidad.

---

## 7. Reportes exportables

Principio de diseño: **listas → CSV; resúmenes presentables → PDF.**

### 7.1 CSV (datos crudos)
- **Ventas:** transacciones con monto, fecha, comprador, tipo de entrada, código usado.
- **Asistentes:** lista para operación/check-in.
- **Resumen de evento:** vendido vs. capacidad, ingreso bruto, comisión, neto, uso de códigos.

### 7.2 PDF (documento con formato)
- **Resumen ejecutivo del evento** y/o **comprobante de liquidación**, con branding del tenant y totales maquetados.
- Pensado para resúmenes, **no** para listas largas (no volcar miles de asistentes a un PDF).

### 7.3 Generación
- **v1:** generación **síncrona** (botón → descarga), con tope de filas (~10–20k). El PDF se genera vía Edge Function.
- **Evolución (no v1):** generación en background con aviso por email cuando el dataset es muy grande.

### 7.4 Fuera de alcance (v1)
Reportes programados/automáticos por email, dashboards con gráficos exportables, rangos de fecha custom cruzando varios eventos, y formatos extra (xlsx).

---

## 8. Pagos

### 8.1 Modelo — Marketplace con split / cobro directo al organizador
- Cada organización **conecta su propia cuenta** de cobro (Mercadopago / Mobbex).
- El dinero va **directo a la cuenta del organizador**; la plataforma retiene su comisión automáticamente (modelo *split / destination charge*). La plataforma **no** es custodia del dinero ajeno, lo que evita problemas regulatorios y de flujo de caja.
- **Comisión:** fee por ticket (porcentaje + fijo), configurable por organización.

### 8.2 Mercadopago como principal (contexto LatAm)
- Mercadopago domina la región y soporta medios de pago locales y cuotas.
- Mobbex como alternativa/segundo proveedor.

### 8.3 Confirmación y robustez
- La confirmación de pago se procesa vía **webhook** (Edge Function), no confiando sólo en el redirect del navegador.
- **Idempotency keys** en la creación de pagos y en el procesamiento de webhooks (un webhook puede llegar duplicado).
- La emisión de tickets ocurre **sólo** tras confirmación efectiva del pago.

### 8.4 Reembolsos
- Soportados a nivel ticket, con reversión proporcional de la comisión.

---

## 9. Requisitos no funcionales

| Atributo | Requisito |
|---|---|
| **Aislamiento de datos** | RLS por `organization_id` en todas las tablas de negocio. Tests automáticos que verifican que una organización nunca lea datos de otra. `organization_id` siempre derivado de la sesión. |
| **Anti-overselling** | Control de cupo atómico. Tasa de sobreventa objetivo: **0**. |
| **Rendimiento en picos** | El cuello de botella es la venta simultánea al liberar un evento. Locks atómicos / contadores; colas si fuese necesario. |
| **Disponibilidad** | Objetivo 99.9%. Check-in degrada con gracia ante pérdida de conexión. |
| **Seguridad** | QR firmados (HMAC/JWT), rate limiting en checkout, idempotency en pagos, secretos sólo en Edge Functions/servidor. |
| **Auditoría** | Log de acciones sensibles: quién publicó/canceló un evento, quién reembolsó, quién validó un ticket. |
| **Calidad** | Vitest (unitarias), Playwright (E2E del flujo de compra y check-in), lint-staged + Husky en pre-commit, CI en GitHub Actions. |

---

## 10. Fuera de alcance (v1)

Excluido conscientemente para mantener el MVP acotado:
- Asientos numerados / mapa de sala.
- App móvil nativa (se usa PWA).
- Reventa / transferencia de tickets.
- Multi-idioma.
- Dominios propios por tenant.
- Wallets (Apple/Google Pay) como método dedicado.
- Reportes programados, dashboards exportables, xlsx, rangos multi-evento.
- Descuentos automáticos, stackeables o escalonados.

---

## 11. Métricas de éxito

| Métrica | Objetivo |
|---|---|
| Tiempo de creación de un evento | < 5 min |
| Tasa de conversión de checkout | Vista de evento → compra completada (medir y optimizar) |
| Tickets validados sin incidencias | Escaneos exitosos / total |
| **Tasa de sobreventa** | **0** (cualquier caso es bug crítico) |
| Onboarding autónomo | Organizador llega a su primer evento publicado sin soporte |

---

## 12. User stories y criterios de aceptación

> Formato Gherkin (Given/When/Then). Se listan las historias núcleo de v1.

### 12.1 Crear y publicar un evento
**Como** Org Admin **quiero** crear y publicar un evento **para** empezar a vender entradas.

```gherkin
Escenario: Publicar un evento válido
  Dado que soy un Org Admin autenticado en mi organización
  Y he creado un evento en estado "borrador" con fecha, ubicación y al menos un tipo de entrada
  Cuando publico el evento
  Entonces el evento pasa a estado "publicado"
  Y queda accesible en su URL pública de compra

Escenario: No puedo publicar un evento incompleto
  Dado un evento en "borrador" sin tipos de entrada
  Cuando intento publicarlo
  Entonces se rechaza la publicación
  Y se me indica qué falta completar
```

### 12.2 Comprar entradas sin cuenta
**Como** comprador **quiero** comprar entradas sin registrarme **para** hacerlo rápido.

```gherkin
Escenario: Compra exitosa
  Dado un evento publicado con cupo disponible
  Cuando selecciono cantidades, ingreso nombre y email, y pago correctamente
  Entonces se confirma la compra
  Y recibo por email un ticket con QR único por cada entrada

Escenario: La reserva expira sin pago
  Dado que inicié un checkout y se reservó el stock
  Cuando no completo el pago dentro de los 10 minutos
  Entonces el stock reservado se libera automáticamente
  Y queda disponible para otros compradores
```

### 12.3 No vender más que el cupo
**Como** organizador **quiero** que nunca se venda de más **para** no comprometer la capacidad.

```gherkin
Escenario: Cupo agotado bajo concurrencia
  Dado un tipo de entrada con 1 cupo restante
  Cuando dos compradores intentan pagarlo simultáneamente
  Entonces exactamente uno completa la compra
  Y el otro recibe un aviso de "sin disponibilidad"
  Y el total vendido nunca supera el cupo
```

### 12.4 Aplicar un código promocional
**Como** comprador **quiero** aplicar un código **para** obtener un descuento.

```gherkin
Escenario: Código válido
  Dado un código activo, dentro de su ventana y con usos disponibles
  Cuando lo aplico en el checkout
  Entonces el total refleja el descuento (porcentaje o monto fijo)
  Y el uso del código se asocia a mi reserva

Escenario: Código sin usos disponibles
  Dado un código que alcanzó su límite de usos
  Cuando intento aplicarlo
  Entonces se rechaza
  Y el total permanece sin descuento

Escenario: Carrito abandonado no consume el código
  Dado que apliqué un código y la reserva expiró sin pago
  Cuando se libera la reserva
  Entonces el uso del código vuelve a estar disponible
```

### 12.5 Check-in en la puerta
**Como** staff **quiero** escanear el QR **para** validar el ingreso sin doble uso.

```gherkin
Escenario: Primer escaneo válido
  Dado un ticket pagado y no usado
  Cuando escaneo su QR
  Entonces se marca como "usado"
  Y se muestra "ingreso válido"

Escenario: Segundo escaneo del mismo ticket
  Dado un ticket ya validado
  Cuando lo escaneo de nuevo
  Entonces se muestra "ya validado"
  Y no se permite el ingreso

Escenario: Validación sin conexión
  Dado que la app cacheó los tickets válidos del evento
  Y se pierde la conexión en el venue
  Cuando escaneo tickets
  Entonces la validación sigue funcionando localmente
  Y se sincroniza al recuperar conexión
```

### 12.6 Exportar reportes
**Como** Org Admin **quiero** exportar ventas y asistentes **para** mi operación y mi contabilidad.

```gherkin
Escenario: Exportar CSV de ventas
  Dado un evento con ventas
  Cuando exporto el reporte de ventas en CSV
  Entonces descargo un archivo con transacciones, montos, compradores y códigos usados

Escenario: Exportar resumen en PDF
  Dado un evento finalizado
  Cuando exporto el resumen en PDF
  Entonces descargo un documento con branding de mi organización
  Y con totales de vendido, ingreso bruto, comisión y neto
```

### 12.7 Aislamiento entre organizaciones
**Como** plataforma **quiero** garantizar el aislamiento **para** proteger los datos de cada tenant.

```gherkin
Escenario: Acceso cruzado bloqueado
  Dado un usuario que pertenece sólo a la Organización A
  Cuando intenta acceder a datos de la Organización B (por cualquier vía)
  Entonces la base de datos rechaza la consulta vía RLS
  Y no se devuelve ningún dato de B
```

---

## 13. Modelo de datos (orientativo)

> Todas las tablas de negocio incluyen `organization_id` y tienen RLS activada. Tipos simplificados.

| Tabla | Campos clave | Notas |
|---|---|---|
| `organizations` | `id`, `name`, `slug`, `payment_account_ref`, `fee_pct`, `fee_fixed` | Tenant. `slug` para URL path-based. |
| `memberships` | `id`, `user_id`, `organization_id`, `role` | Relación usuario–org con rol (Owner/Admin/Staff). |
| `events` | `id`, `organization_id`, `name`, `description`, `image_url`, `starts_at`, `ends_at`, `location`, `capacity`, `status` | `status`: borrador/publicado/finalizado/cancelado. |
| `ticket_types` | `id`, `organization_id`, `event_id`, `name`, `price`, `quota`, `sold`, `sale_starts_at`, `sale_ends_at` | `sold` se actualiza atómicamente. |
| `promo_codes` | `id`, `organization_id`, `event_id?`, `code`, `discount_type`, `discount_value`, `max_uses`, `uses`, `per_buyer_limit`, `starts_at`, `ends_at`, `active` | `discount_type`: percent/fixed. `uses` atómico. |
| `orders` | `id`, `organization_id`, `event_id`, `buyer_name`, `buyer_email`, `status`, `subtotal`, `discount`, `total`, `promo_code_id?`, `payment_ref`, `created_at`, `hold_expires_at` | `status`: held/paid/expired/refunded. |
| `tickets` | `id`, `organization_id`, `order_id`, `ticket_type_id`, `qr_signature`, `status`, `checked_in_at`, `checked_in_by?` | `status`: valid/used/refunded. Un registro por entrada. |
| `audit_log` | `id`, `organization_id`, `user_id`, `action`, `target`, `created_at` | Acciones sensibles. |

### 13.1 Notas de integridad
- `tickets.qr_signature`: valor firmado (HMAC/JWT), no enumerable.
- Decremento de `ticket_types.sold` y `promo_codes.uses`: dentro de la transacción del hold/compra, con bloqueo de fila para evitar carreras.
- `orders.hold_expires_at`: un job/lógica de expiración libera holds vencidos (stock y uso de código).

---

## 14. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| **Scope creep** en promos y reportes | Límites de §6.3 y §7.4 congelados; cualquier extensión va a un v2 explícito. |
| Fuga de datos entre tenants | RLS + tests automáticos de aislamiento + `organization_id` siempre desde sesión. |
| Sobreventa en picos | Decremento atómico de cupo; pruebas de concurrencia en CI. |
| Webhooks de pago duplicados/perdidos | Idempotency keys + reconciliación; emisión sólo tras pago confirmado. |
| Caída de red en el venue | Check-in con caché local y sincronización diferida. |

---

## 15. Roadmap posterior a v1 (referencia)
Subdominios y dominios propios · asientos numerados · transferencia/reventa de tickets · multi-idioma · reportes programados y xlsx · descuentos automáticos/escalonados · wallets (Apple/Google Pay) · esquema schema-per-tenant para clientes enterprise.
