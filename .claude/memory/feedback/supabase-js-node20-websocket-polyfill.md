---
name: '`@supabase/supabase-js` en Node 20 (CI) tira "native WebSocket not found" · polyfill con `ws`'
description: createClient de @supabase/supabase-js construye un RealtimeClient eager que exige un WebSocket global. Node <21 no lo trae nativo (llegó en 21+) · el runner CI corre Node 20 → cualquier helper/script de test que use createClient tira "Node.js 20 detected without native WebSocket support". Fix: devDep `ws` + polyfill de globalThis.WebSocket.
type: feedback
---

`createClient` de `@supabase/supabase-js` (v2.x) construye un `RealtimeClient` de forma **eager** en el constructor de `SupabaseClient`. `@supabase/realtime-js` (`websocket-factory.ts`) exige un `WebSocket` global; si no lo encuentra tira `Error: Node.js 20 detected without native WebSocket support`. Node **<21 no expone `WebSocket` global nativo** (aterrizó estable en Node 21/22). El runner de CI corre **Node 20** (stack congelado) → cualquier helper o script de test que use el `createClient` completo rompe, **aunque nunca abra una conexión realtime**.

**Why:**

- Detectado en `/entregar` de PRP-002 (2º CI-red). El webServer de Next (que usa `@supabase/ssr`, no el client completo) arrancaba OK y los specs de páginas estáticas pasaban; los specs que usaban `tests/e2e/auth-session.ts` (que sí usa `@supabase/supabase-js` `createClient` para `auth.admin`) fallaban todos con el error de WebSocket.
- Local NO reproducía porque la máquina corre Node ≥21 (v24 · WebSocket nativo). Diferencia de entorno local↔CI · el bug solo aparece en el runner Node 20.
- `@supabase/ssr` (server/browser client de la app) **no** dispara esto — solo el `createClient` completo de `@supabase/supabase-js` (que trae realtime). Por eso la app en prod (Node 20) no se ve afectada · solo helpers/scripts de test.
- La detección de `realtime-js` (`WebSocketFactory.detectEnvironment`) chequea `typeof WebSocket !== 'undefined'` y `typeof globalThis.WebSocket !== 'undefined'` → un polyfill de `globalThis.WebSocket` la satisface. El helper nunca instancia el WS (no llama `.channel()`), así que basta con que el constructor exista.

**How to apply:**

- En cualquier helper/script de test que use `@supabase/supabase-js` `createClient` bajo Node <21 (CI Node 20 · scripts locales en máquinas viejas): agregar `ws` como devDep + polyfill defensivo al tope del módulo:

  ```ts
  import { WebSocket as NodeWebSocket } from 'ws'
  {
    const g = globalThis as unknown as { WebSocket?: unknown }
    if (typeof g.WebSocket === 'undefined') g.WebSocket = NodeWebSocket
  }
  ```

  El `if` lo hace no-op en Node ≥21 (usa el nativo) · activo en Node 20.
- Verificación red/green sin Node 20 a mano: en un runtime con WS nativo, `globalThis.WebSocket = undefined` antes de `createClient` reproduce el error; re-setearlo desde `ws` lo cierra.
- Alternativa descartada: bumpear el Node del CI a 22 · deja el e2e corriendo sobre otra major que la de prod (Node 20 congelado · stack-versions PRP-001) · el polyfill mantiene paridad.
