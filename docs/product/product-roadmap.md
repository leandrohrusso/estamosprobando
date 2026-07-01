# Product Roadmap · `docs/product/product-roadmap.md`

> **Roadmap activo de PUERTITA.** Tasks priorizadas por fase con marcas `[ ]` / `[x]` · cada cierre suma notas con archivos creados/modificados + decisiones + aprendizajes (regla #18 [`golden-rule-docs-memory.md`](../../.claude/rules/golden-rule-docs-memory.md) ítem 1).
>
> **Origen:** backlog derivado del scope v1 del PRD ([`references/PRD.md`](references/PRD.md)) durante el bootstrap (2026-06-25). Cada task es un **placeholder a planificar** · el scope concreto se cierra feature por feature con el user vía `/planificar` (regla #3 [`decisiones-features.md`](../../.claude/rules/decisiones-features.md)) · NO son decisiones de feature pre-aprobadas.

## § Fase actual · Fundación

- [x] **TASK-001 · Scaffold + infra base** — Next.js App Router + Tailwind + shadcn/ui + cliente Supabase + config TS/ESLint/Vitest/Playwright + wiring real del CI. → **[PRP-001](../../.claude/PRPs/PRP-001-scaffold-infra-base.md) COMPLETADO 2026-06-26** (mergeado `--squash` a `main` · `e4a9036` · CI remoto verde). Entregó: deps reales (Next 16 · React 19 · Tailwind v3 · eslint 9 · TS 6) + `src/app` scaffold + cliente Supabase skeleton + wiring CI (Playwright `--with-deps` · `run-sql-tests` skip-safe) + smokes e2e/unit. **Scope acotado 🔵 Bif 1=A:** TEST DB real + auth/RLS + specs con datos → TASK-002. **DT-001** abierta (var `DATABASE_URL` vs `TEST_DATABASE_URL`).
- [ ] **TASK-002 · Auth + organizaciones + memberships + RLS base** — Supabase Auth (magic link), tablas `organizations` + `memberships`, RLS por `organization_id`, selección de organización, RBAC (Owner/Admin/Staff). _Base del aislamiento multi-tenant (constraint #1)._ → **[PRP-002](../../.claude/PRPs/PRP-002-auth-organizations-memberships-rls.md) APROBADO 2026-07-01** (5 bifurcaciones firmadas 🔵 · cierra DT-001).

## § Próxima fase · Eventos y entradas

- [ ] **TASK-003 · CRUD de eventos + estados** — `events` con `borrador → publicado → finalizado` (+ `cancelado`) · gate de publicación (requiere ≥1 tipo de entrada) · audit log de publicar/cancelar.
- [ ] **TASK-004 · Tipos de entrada con cupo** — `ticket_types` (precio, cupo propio, ventana de venta desde/hasta).
- [ ] **TASK-005 · Página pública del evento** — read-only server-side acotada al evento publicado (sin exponer datos internos del tenant).

## § Backlog · Resto del MVP v1

- [ ] **TASK-006 · Checkout guest + hold de stock** — carrito, datos del comprador (nombre + email), hold ~10 min, decremento **atómico** de cupo (constraint #2), liberación automática al expirar.
- [ ] **TASK-007 · Pagos marketplace split (Mercadopago)** — conexión de cuenta del organizador, split/destination charge, comisión por ticket, webhook idempotente (Edge Function), emisión solo tras pago confirmado (constraints #5/#6).
- [ ] **TASK-008 · Emisión de tickets** — QR firmado HMAC/JWT no enumerable (constraint #7), email vía Resend con PDF adjunto (Edge Function).
- [ ] **TASK-009 · Check-in PWA** — scanner web, validación **atómica e idempotente** (constraint #3), modo offline con caché de tickets válidos + sync al reconectar.
- [ ] **TASK-010 · Códigos promocionales** — porcentaje o monto fijo, 1 código por compra no combinable (constraint #9), uso atómico dentro del hold (constraint #8), límites (totales/por comprador/ventana).
- [ ] **TASK-011 · Panel del organizador** — ventas e ingresos en tiempo real, vendido vs. capacidad, lista de asistentes, % check-in en vivo, uso de códigos (≤5 KPIs · regla #30).
- [ ] **TASK-012 · Reportes exportables** — CSV (ventas, asistentes, resumen) + PDF (resumen ejecutivo con branding del tenant), generación síncrona con tope de filas.
- [ ] **TASK-013 · Reembolsos** — a nivel ticket con reversión proporcional de comisión + audit log.
- [ ] **TASK-014 · Mobbex como segundo proveedor de pago** — alternativa a Mercadopago.
- [ ] **TASK-015 · Platform Superadmin** — gestión de organizaciones, suspensión de cuentas, métricas globales.

## § Cerradas

_(vacío al boot · mover tasks acá cuando se cierran con `[x]` + notas)_

---

_Roadmap gestionado por regla #18 [`golden-rule-docs-memory.md`](../../.claude/rules/golden-rule-docs-memory.md) ítem 1. Fuera de v1 (PRD §10): asientos numerados, app nativa, reventa/transferencia, multi-idioma, dominios propios, wallets, reportes programados/xlsx, descuentos automáticos/escalonados._
