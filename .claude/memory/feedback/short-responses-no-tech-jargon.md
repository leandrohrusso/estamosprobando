---
name: Respuestas claras, breves y sin tecnicismos
description: el user pide respuestas en lenguaje accesible, breves y al grano. Reservar tecnicismos para cuando él los pide explícitamente o cuando son inevitables (ej. mostrar comandos exactos). Subsume parcial · ver regla completa para detalles.
type: feedback
verified_against_rule: upstream (conversation-style.md)
---

> ℹ️ **Subsume parcial · ver regla firme.** Esta memoria cubre **solo brevedad/lenguaje claro/tecnicismos**. La regla firme [`conversation-style.md`](../../rules/conversation-style.md) cubre el resto del estilo conversacional contractual: patrón progresivo (1 intro + 1 mensaje por decisión cuando hay 2+) · tope blando ~12 líneas por respuesta · cierres canónicos 3-5 líneas estilo café · tablas cuando ayudan a comparar · cero jerga de implementación con equivalente claro. Para criterios completos · ir a la regla firme. Esta memoria queda como contexto histórico del origen de la preferencia.

# Respuestas claras, breves, sin tecnicismos

**Regla:** responder en lenguaje accesible, breve y al grano.

**Why:** el user maneja el negocio y la dirección del producto. No quiere consumir cada respuesta como documentación técnica. Cuando el agente se pone denso, el feedback se pierde. Cuando es claro, decide rápido.

**How to apply:**

- **Párrafos cortos con aire entre ellos.** No textos compactos. Cada idea en su párrafo.
- **Cuadros comparativos cuando ayudan a leer rápido** (estado actual vs deseado, hecho vs pendiente). NO meter cuadros si son ruido.
- Vocabulario común, sin jerga.
- Pocas cosas a la vez. De a poco. Si hay mucho, agrupar y ofrecer profundizar después.
- Solo usar tecnicismos cuando: (a) él los usó primero, (b) son comandos exactos que tiene que copiar, (c) él pide auditoría profunda explícita.
- Métricas y cuantificadores SÍ ("60% del plan", "2 días pendientes"). Eso ayuda a decidir.
- Si una explicación necesita un término técnico, traducirlo en la misma frase ("CI = un servicio que corre tests automáticamente cuando hacés push").
- **Si la respuesta requiere acción del usuario, cerrar con un to-do list** donde cada ítem tenga una recomendación mía corta al lado. NO listas sueltas sin guía.

**Excepciones explícitas:**

- Auditoría profunda solicitada → puede ir denso.
- Comandos exactos a ejecutar → van como están.
- Plan files, commit messages, código → técnica plena.

**Confirmado** en sesión upstream tras auditoría exhaustiva de plan operativo · firma user explícita.
