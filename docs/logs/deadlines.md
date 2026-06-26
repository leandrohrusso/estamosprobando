# Deadlines del proyecto · `docs/logs/deadlines.md`

> **Cadencias periódicas del proyecto.** `/arrancar` Paso 5 lee este archivo al boot y avisa cuando un deadline vence o está ≤7 días. Auto-propuesta contractual del agente cuando hay comando ejecutable asociado.

## § Activos

| Deadline | Próxima ejecución | Cadencia | Comando ejecutable |
|---|---|---|---|
| Lint mensual de **memoria** | 2026-07-25 | Mensual | `bash scripts/lint-memory.sh` |
| Lint mensual de **código** (`/revisar-main`) | 2026-07-25 | Mensual + ad-hoc | `/revisar-main` (skill) |
| Audit mensual de **deudas técnicas** (`/auditar-dt`) | 2026-07-25 | Mensual + ad-hoc | `/auditar-dt` (skill) |
| Archivado periódico de **log.md** | Cuando `log.md` supere ~40 entries | Cada 14 días | `bash scripts/archive-log.sh` |

## § Histórico

_(vacío al boot · mover filas activas acá cuando se ejecuta el deadline · con resultado / output / paths generados)_

| Deadline | Fecha ejecución | Resultado |
|---|---|---|

---

_Trilogía de revisión mensual: `/revisar-main` (código) + `scripts/lint-memory.sh` (memoria) + `/auditar-dt` (deudas técnicas). Detalle en [WORKFLOW.md § 8](../../WORKFLOW.md)._
