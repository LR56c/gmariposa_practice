# Addendum del PRD: decisiones técnicas del candidato

Decisiones tomadas por Mauri durante el PRD. Son insumo para `bmad-architecture`, que debe validarlas con coaching (trade-offs y alternativas), no reabrirlas sin motivo.

| # | Decisión | Razón del candidato | Pendiente de validar en arquitectura |
|---|---|---|---|
| T-1 | `Errors` y `BaseException` viven en `core/` (compartido), no en una feature. Del patrón de errores del checklist (§5) aplica `BaseException(message, code)` con una subclase por falla y el contenedor `Errors`; se omiten `toPrimitives`/`toPrimitivesFlatten`, `CommonResponse` y `CommonError`, porque son el envelope de una API propia y aquí no hay backend propio. | Los usan todas las features y las capas de datos y presentación. | Confirmar que `domain` puede depender de `core` sin violar las capas. |
| T-2 | El Repository **puede** devolver `Either<Errors, T>` en sus métodos. | Errores tipados sin excepciones crudas hacia la UI (FR-12). | Qué paquete de `Either` (`fpdart`) y si todos los métodos lo usan o solo algunos; coherencia con "estado solo con Riverpod" del PDF. |
| T-3 | `AsyncValue` se usa en la UI para hacer pattern matching según el estado del recurso (carga, datos, error). | El PDF lo pide (`.when` o pattern matching). | Cómo se convierte `Either<Errors, T>` en `AsyncValue` dentro del notifier. |
| T-4 | Modelos con `freezed`, para obtener métodos generados (`copyWith`, igualdad, `fromJson`). | Menos código repetido y modelos inmutables por construcción (FR-11). | Justificarlo en el README. Verificar con la documentación vigente la compatibilidad de versiones entre `freezed`, `json_serializable`, `riverpod_generator` y Riverpod (2.x o 3.x). |
| T-5 | `riverpod_generator` desde el inicio (decidido en el brief). | Evitar una migración al final. | Con T-4 implica `build_runner`; confirmar el costo de explicar el código generado en la entrevista. |
