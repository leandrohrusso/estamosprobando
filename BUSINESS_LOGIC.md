# BUSINESS_LOGIC del proyecto · identidad y constraints no negociables

<!--
INSTRUCCIONES PARA EL DEV QUE COPIA EL PACK:

Este archivo es la fuente única de verdad sobre QUÉ se construye (vs WORKFLOW.md = CÓMO).
Llenarlo es el paso #1 obligatorio del bootstrap del proyecto nuevo, ANTES de arrancar
cualquier PRP. El skill `/arrancar` lo lee en cada boot · si está vacío, el agente NO
tiene cómo enmarcar las decisiones del producto.

Recomendación: llenar la § 1 (Identidad) + § 7 (Stack) + § 8 (Constraints) primero ·
las otras secciones pueden completarse iterativamente conforme avanza el producto.
-->

## § 1 · Identidad del producto

<!--
Llenar acá:
- Nombre del producto.
- Dominio (si tenés URL · si todavía no, dejar "pendiente").
- One-liner (1 frase que describe qué es · estilo elevator pitch · ej: "SaaS de ticketing
  boutique para productores boutique argentinos · recaudación directa al banco del productor").
- Founder · equipo · roles (quién/quiénes construyen).
- Magic moment del producto (la primera vez que el usuario primary siente el valor · ej:
  "cuando el productor ve su primera venta entrar a su Mercadopago en tiempo real").
-->

**Nombre:** `<PROYECTO>`

**Dominio:** `<dominio.tld>` (o `pendiente`)

**One-liner:** `<1 frase elevator pitch>`

**Founder / equipo:** `<roles>`

**Magic moment:** `<primer momento donde el usuario primary siente el valor>`

## § 2 · Problema + costo

<!--
El dolor que resuelve el producto. NO descripción genérica del rubro · el dolor SPECIFIC
del usuario que justifica que prefiera tu producto sobre los existentes. El costo es lo
que el usuario pierde HOY por no tener tu solución (tiempo · dinero · oportunidad · etc).
-->

**Dolor primario:** `<descripción concreta del problema>`

**Costo del status quo:** `<qué pierde el usuario sin tu solución>`

## § 3 · Solución + flujo

<!--
Happy path del usuario primary · qué hace en tu producto desde que descubre hasta que
captura valor. NO descripción de features sueltas · el flujo end-to-end del usuario
primary que justifica el magic moment de § 1.
-->

**Happy path del usuario primario:**

1. `<paso 1>`
2. `<paso 2>`
3. `<paso 3>`
4. ...

## § 4 · Usuario objetivo

<!--
- Persona primaria: quién toca tu producto día-a-día · su rol · su nivel técnico.
- Personas operativas: roles secundarios (admin · finance · ops · staff · etc) que
  interactúan con superficies del producto pero NO son la persona primaria.
- Anti-persona: para quién explícitamente NO está construido el producto (evita scope creep).
-->

**Persona primaria:** `<descripción>`

**Personas operativas:** `<lista de roles secundarios>`

**Anti-persona:** `<para quién NO está construido el producto>`

## § 5 · Modelo de negocio

<!--
Cómo monetiza el producto. Si SaaS = pricing tiers · si marketplace = comisiones ·
si transaccional = fee por transacción · etc. Métricas clave del modelo (ARR · LTV ·
CAC · etc) si ya están definidas.
-->

**Modelo:** `<SaaS suscripción · marketplace comisión · transaccional fee · híbrido>`

**Pricing / fees:** `<estructura>`

**Métricas clave:** `<ARR · LTV · CAC · etc si aplica>`

## § 6 · KPIs de éxito

<!--
Cómo sabés si el producto funciona. NO vanity metrics (signups · followers · etc) ·
métricas que indican que el magic moment se está entregando consistentemente y que
el modelo de negocio se sostiene.
-->

**KPI #1 (norte estrella):** `<la métrica única que indica que el producto funciona>`

**KPIs operativos:** `<2-4 métricas que indican que la operación se sostiene>`

## § 7 · Stack confirmado

<!--
Stack técnico no negociable del proyecto. Lo que ya está decidido y NO se discute en
cada PRP (cambiar el stack es trabajo de migración estructural, no scope de PRP).
-->

**Frontend:** `<ej: Next.js 16 App Router + Tailwind + shadcn>`

**Backend:** `<ej: Server Actions Next + Supabase Edge Functions cuando aplica>`

**Base de datos:** `<ej: Supabase Postgres + RLS por organization_id>`

**Auth:** `<ej: Supabase Auth + magic link + organization memberships>`

**Pagos / providers externos:** `<ej: Mercadopago + Mobbex + Resend para emails>`

**Hosting:** `<ej: Vercel + Supabase Cloud>`

**Tooling:** `<ej: Husky + lint-staged + Playwright + Vitest + GitHub Actions>`

## § 8 · Constraints no negociables

<!--
LAS DECISIONES CRÍTICAS DEL PRODUCTO que enmarcan cada PRP futuro. NO se discuten en
cada PRP · están firmadas y son inmutables hasta que el founder explícitamente
decida revisarlas (en cuyo caso se actualiza este archivo + entrada `directional`
en `.claude/memory/log.md`).

Patrón canónico:

1. **<Nombre corto del constraint>** — <enunciado del constraint · 1-2 líneas>.
   **Por qué firme:** <razón · contexto · cita del founder si aplica>.

> [!EXAMPLE]
> Los 3 ejemplos siguientes son **ilustrativos** (escenario en dominio ticketing · adaptá a
> tu dominio · borrá estos al llenar los reales del producto).

1. **Multi-tenant aislamiento estricto.** Cada tenant ve SOLO sus datos · RLS por
   `organization_id` en TODAS las tablas · cero excepciones.
   **Por qué firme:** legal + confianza · una fuga cross-tenant es game-over.

2. **Stock fundamental · cero sobreventa.** El stock se decrementa atómicamente vía
   RPC SQL con `UPDATE ... WHERE stock >= qty` · cero race conditions tolerable.
   **Por qué firme:** sobreventa es default-fail · destruye trust.

3. **Snapshot histórico en renders post-venta.** PDFs · scanner · endpoint público
   leen `<tabla>.snapshot`, NO live tables · si el tenant editor (ej: en un proyecto
   ticketing sería "el productor") renombra X post-venta, el comprador ve lo que compró.
   **Por qué firme:** trazabilidad legal + UX del comprador.

Listar acá los constraints del producto · 5-15 entries típicamente · cada uno firmado.
-->

1. **`<Nombre del constraint #1>`** — `<enunciado>`. **Por qué firme:** `<razón>`.

2. **`<Nombre del constraint #2>`** — `<enunciado>`. **Por qué firme:** `<razón>`.

3. ...

### Constraints del dominio que activan sub-agentes de `/revisar` y `/revisar-main`

> Declarar aquí los constraints del dominio que activan los 3 sub-agentes
> domain-tight de `/revisar` y `/revisar-main`. Los flags alimentan
> [`.claude/config/agents-applicability.yml`](.claude/config/agents-applicability.yml).
> El bootstrap del proyecto destino debe cambiar cada `unknown` a `yes` o `no`
> explícito · cero defaults silenciosos. Doctrina del mecanismo: regla firme #35
> [`agents-conditional-by-domain.md`](.claude/rules/agents-conditional-by-domain.md).

- **`multi_tenant`:** ¿el proyecto es SaaS multi-tenant con aislamiento entre
  tenants (RLS por `organization_id` o equivalente)?
  - `yes` → activa agente `multi-tenant` de `/revisar` y `/revisar-main`.
  - `no` → desactiva.

- **`stock_atomicity`:** ¿el proyecto maneja stock · contadores · race conditions
  sobre BD compartida que requieren RPCs SQL atómicas?
  - `yes` → activa agente `atomicity`.
  - `no` → desactiva.

- **`relational_db_with_migrations`:** ¿el proyecto tiene BD relacional con
  migrations + RLS policies (Postgres/Supabase/MySQL/etc)?
  - `yes` → activa agente `migration-safety`.
  - `no` → desactiva.

> **Nota sobre naming · mapeo flags ↔ YAML:** los flags se nombran largo en
> esta sección (naming declarativo del dominio · `multi_tenant` ·
> `stock_atomicity` · `relational_db_with_migrations`) y corto en
> [`.claude/config/agents-applicability.yml`](.claude/config/agents-applicability.yml)
> (naming operativo del agente · `multi-tenant` · `atomicity` · `migration-safety`).
> Mapeo 1:1 · cada flag de esta sección activa exactamente un sub-key del YAML:
> `multi_tenant` → `multi-tenant.enabled` · `stock_atomicity` → `atomicity.enabled` ·
> `relational_db_with_migrations` → `migration-safety.enabled`.

> **Bootstrap operativo:** al adoptar el pack, el dev del proyecto destino:
>
> 1. Lee esta sección + decide cada flag según el producto que está construyendo.
> 2. Edita [`.claude/config/agents-applicability.yml`](.claude/config/agents-applicability.yml) reemplazando `unknown` por
>    `yes`/`no` en cada agente.
> 3. Documenta la decisión inline acá con justificación 1-frase en la tabla siguiente.

**Decisiones del proyecto** (llenar en el bootstrap):

| Flag | Valor | Justificación 1-frase |
|---|---|---|
| `multi_tenant` | `<unknown / yes / no>` | `<por qué>` |
| `stock_atomicity` | `<unknown / yes / no>` | `<por qué>` |
| `relational_db_with_migrations` | `<unknown / yes / no>` | `<por qué>` |

## § 9 · Mapa de documentación

<!--
Pointer a los archivos clave del proyecto que el agente debe consultar cuando arranca
un PRP del área correspondiente. NO listar TODOS los archivos · solo los SoT por área.

Patrón:

| Área | SoT | Cuándo consultar |
|---|---|---|
| Schema BD | `docs/db/schema.md` | Al planificar PRP que toca tablas/columnas |
| Auth + roles | `docs/auth/roles.md` | Al planificar PRP que toca permisos |
| Vocabulario del rubro | `docs/product/references/rules/vocabulario.md` | Al revisar copy de UI o naming técnico |
| Decisiones arquitectónicas históricas | `.claude/memory/project/` | Multi-sesión continuity |
-->

| Área | SoT | Cuándo consultar |
|---|---|---|
| _(vacío al boot · llenar conforme aparezcan SoTs por área del producto)_ | — | — |

---

<!--
TIP PARA SESIONES FUTURAS:

- Al cerrar un PRP que cambia un constraint de § 8, actualizar este archivo + entrada
  `directional` en `.claude/memory/log.md`.
- Al sumar área de documentación nueva, sumar fila en § 9.
- Si el founder firma cambio del stack (§ 7), actualizar acá + entrada `directional`
  en `log.md` + verificar que los skills heavy-MCP del pack (`/implementar` · `/validar`)
  sigan teniendo allowed-tools válidos.
- Cero "documentar en el próximo PRP" — este archivo se actualiza en el commit que
  introduce el cambio (regla #18 [`golden-rule-docs-memory.md`](.claude/rules/golden-rule-docs-memory.md)).
-->

---

_Documento canónico de identidad/business logic del producto · template del pack workflow-base · convención firmada 2026-05-22 · vacío al boot · llenar durante el bootstrap del proyecto destino._
