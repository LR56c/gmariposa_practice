# Revisión del Architecture Spine contra la rúbrica de "buen spine"

Documento revisado: `ARCHITECTURE-SPINE.md` (draft, 2026-10-06). Fuentes cruzadas: `prd.md` y `addendum.md`.
Severidad: Alta = dos unidades pueden divergir o el Rule no previene lo que dice; Media = hueco que obliga al nivel inferior a decidir; Baja = pulido.

## Veredicto

Spine sólido y mayormente ejecutable (stack verificado, AD con Binds/Prevents/Rule, cobertura FR/NFR casi completa), pero con tres puntos reales de divergencia sin fijar (propiedad del modelo Product y del Repository entre features, ciclo de vida del Cart, forma de estado del Catalog frente a `AsyncValue.guard`) y varias contradicciones menores con el PRD (alcance de DF-1, DA-1/DA-2, deep link) que conviene resolver antes de crear stories.

## 1. Hallazgos principales

### H-1 (Alta) Propiedad de `Product` y del Repository entre features no fijada
- La estructura semilla da `data/domain` tanto a `catalog` como a `product_detail`, y `cart` solo `domain/presentation`. AD-3 habla de "el Repository" y de un único `productRepositoryProvider`, pero no dice en qué feature vive el modelo `Product` (freezed) ni la interfaz `ProductRepository`.
- Divergencia posible: dos modelos `Product` (catalog y detalle), dos repositorios, o `cart/domain` importando de `catalog/domain` (AD-2 solo regula capas, no dependencias entre features; dice "ciclos entre features" pero no da la regla).
- FR-10 pide un único Repository con listado, búsqueda y `getById`. Fijar: `Product`, `Page<T>`, `ProductRepository` y su provider en un solo dueño (p. ej. `features/catalog` o un `core/domain` explícito), y la regla de qué feature puede importar de cuál.

### H-2 (Alta) AD-4 y AD-6 se contradicen en la paginación
- AD-4: los métodos que mutan estado usan `state = await AsyncValue.guard(...)`. AD-6: `loadMore()` debe conservar la lista y dejar `loadMoreError` si falla.
- Un `guard` sobre el `AsyncValue` raíz produce `AsyncLoading/AsyncError` y pierde `items`. El Rule de AD-4 no previene la divergencia; obliga a lo contrario de lo que AD-6 necesita.
- Fijar: `catalogProvider` es `AsyncValue<CatalogState>`; `loadMore` NO usa `guard` sobre el valor raíz, hace `try/fold` y asigna `AsyncData(copyWith(loadMoreError: ...))`. Añadir esa excepción a AD-4.
- Relacionado: `Errors` es un contenedor (lista de `BaseException`, glosario PRD) pero AD-4 no define su forma ni cómo se deriva "el mensaje" cuando hay varias.

### H-3 (Alta/Media) Ciclo de vida (`keepAlive`) del Cart y de Catalog sin decidir
- UJ-1 exige que el Cart "conserve su contenido al volver al Catalog". Con `riverpod_generator` los providers son autoDispose por defecto. AD-7 dice que el Notifier del Cart es el único dueño del estado pero no exige `@Riverpod(keepAlive: true)`. Un cart sin listeners (p. ej. entre rutas) se reinicia silenciosamente.
- Igual para `searchTerm`/`catalogProvider` al navegar a `/product/:id` y volver (el spine asume que el widget del Catalog sigue montado; no está dicho). Declarar la política de keepAlive por provider.

### H-4 (Media) `debouncedTerm` como `StreamProvider`: comportamiento inicial y de vaciado sin especificar
- Un `StreamProvider` no tiene valor hasta la primera emisión. FR-1 exige cargar al abrir sin esperar 400 ms; FR-3 dice que vaciar el término vuelve al Catalog completo (y cancela pendientes). El Rule no fija: emisión inicial inmediata (`startWith('')`), si vaciar salta el debounce, ni cómo `catalogProvider` consume el `AsyncValue` del stream (`.future`, `ref.watch` del valor). Dos implementadores producirán tiempos y estados de carga distintos.
- Además, `Notifier<String>` + `StreamProvider` + `stream_transform` es una pieza más para explicar en entrevista (SM-4); el spine no contrasta con `Timer` propio (Pregunta abierta 4 del PRD). Queda como decisión ADOPTED sin trade-off visible.

### H-5 (Media) Rules de Angular y de Flutter sin mecanismo de cumplimiento
- AD-2 sí nombra un mecanismo (lint de imports o revisión). AD-3 ("único lugar que captura `DioException`"), AD-10 ("ningún componente importa `HttpClient`", "ningún `subscribe()` sin limpieza"), AD-11 y AD-12 no. Para una prueba evaluada por código, conviene `no-restricted-imports` de ESLint (angular-eslint), `custom_lint`/`import_lint`/test de arquitectura en Dart, y una regla/revisión concreta para `subscribe()`. Sin eso son intenciones, no reglas verificables.
- AD-13 no incluye un gate de lint/format/build para Angular (`ng lint`, `ng build`, `strict`), solo tests; NFR-6 queda sin comprobación automática.

### H-6 (Media) Estado de Angular: filtro y selección de Order fuera del contrato del PRD
- FR-14 y DA-2 hablan de `FormControl` o `signal`/`computed` para el filtro; AD-10 lo mueve a "una acción más un selector" en NgRx. Se mantiene el comportamiento (sin nueva petición, `>=`), pero DA-2 (signals para el estado del filtro) queda contradicho o sin cobertura, y el spine no dice dónde vive el valor del filtro (Store vs. control local).
- FR-16 exige mostrar el detalle del Order "en la misma página" desde el evento `output()`; AD-11 salta directamente a la ruta `/orders/:id` (DA-1, que el PRD pone después de los obligatorios). No se define dónde vive la selección (`selectedId` en Store, signal local o ruta) para la versión obligatoria, ni cómo se reemplaza al hacer DA-1.
- NgRx Store clásico + `effects` + `fp-ts` + `zod` para 2 a 3 h de trabajo (20 % de la nota) es una carga alta; el PRD (§8) ya señala el riesgo de herramientas en Flutter pero el spine no pone Plan B para Angular. Considerar un Plan B explícito (servicio + signals) o diferir NgRx.

### H-7 (Media) Envolvente operativa/ambiental incompleta
Deferred cubre "Despliegue y entornos" como no aplicable, pero faltan dimensiones que sí aplican a una app local reproducible (NFR-8):
- **Plataformas objetivo de Flutter**: solo se menciona Android (deep link y emulador). No se decide Android-only vs. también web/iOS/desktop, ni `minSdk`.
- **Permiso INTERNET**: `flutter create` solo lo declara en el manifiesto de debug; en release la red falla. Si AD-9 edita `AndroidManifest.xml`, debe fijarse también.
- **Timeouts y política de red de Dio** (connect/receive): sin ellos, "sin red" puede quedar en "cargando" y no llegar a `NetworkException` (FR-2, FR-12). No se define el mapeo `DioExceptionType` -> `NetworkException`/`ServerException`.
- **Fijación de toolchain**: "Flutter stable tras `flutter upgrade` (Dart >= 3.13; hoy 3.44.1 / 3.12.1)" es un objetivo flotante. Verifiqué que `freezed 4.0.2` exige Dart >=3.13, pero el SDK actual declarado es 3.12.1: el spine admite que hoy no compila. Fijar versión mínima en `pubspec.yaml` (`environment`), `.nvmrc`/`engines` para Node (Angular 22.2.1 exige `^22.22.3 || ^24.15.0`; 24.16 cumple) y lockfiles commiteados, o NFR-8 (clon limpio) no está garantizado.
- **CORS/origen del navegador** para Angular contra DummyJSON: DummyJSON lo permite, pero no se anota; tampoco el comando/puerto de ejecución.
- **Logging/observabilidad**: solo "sin print"; sin política de logging de errores (aceptable para el alcance, pero conviene declararlo explícitamente como diferido).

### H-8 (Baja) Alcance añadido por el spine respecto del PRD
- **AD-9 (deep link `gmariposa://`)**: el PRD no lo pide; fuera de alcance y consume tiempo en un presupuesto de 6 a 8 h. Marcarlo opcional o diferirlo. Además `adb ... gmariposa://app/product/5` presupone que el host `app` y la ruta coinciden con el router; no se indica la configuración de Flutter para deep linking con go_router.
- **AD-6 (paginación, `isLoadingMore`, `ScrollController`)**: DF-1 es deseable fuera del MVP y FR-1 lo excluye explícitamente ("Fuera de alcance: paginación infinita"). El spine lo adopta por completo (AD-6 liga DF-1). Aceptable porque FR-10 ya exige `limit/skip/total`, pero el estado `isLoadingMore/loadMoreError` y su Rule deberían marcarse como "diferido hasta cerrar obligatorios" para no inflar la story base.
- **DA-3 (`@if/@for` con `track`) y DA-4 (pipe propio)** no aparecen; DA-5 (`OnPush`) sí. Si se pretende que Angular se priorice (PRD §6.1), conviene listar los DA no cubiertos en Deferred con su condición.

## 2. Revisión por criterio de la rúbrica

| Criterio | Resultado |
| --- | --- |
| Fija los puntos de divergencia reales y no omite ninguno | Parcial. Bien: capas, errores, Either/AsyncValue, DioException, router, Store. Faltan H-1, H-3, H-4 y política de red/timeouts. |
| Cada Rule es ejecutable y previene la divergencia | Parcial. AD-1, AD-2, AD-5, AD-8 sí. AD-4/AD-6 se contradicen (H-2). AD-3, AD-10..AD-12 sin mecanismo de cumplimiento (H-5). AD-9 no previene divergencia, solo verifica una función no requerida. |
| Nada en Deferred permite divergencia entre unidades | Casi. "Compatibilidad `riverpod_generator` 4 con `freezed` 4" diferida al scaffold es riesgo de arranque, no de divergencia, pero conviene fijar el Plan B del PRD (T-4/T-5 manual tras 2 h). "Filtro por categoría, persistencia del Cart, tema" están bien diferidos, pero la persistencia del Cart (DF-3) sí interactúa con H-3 (keepAlive). |
| Tecnología nombrada verificada y vigente | Sí. Contrasté contra pub.dev y npm hoy: flutter_riverpod 3.4.3, riverpod_annotation 4.0.7, riverpod_generator 4.0.9, freezed 4.0.2, freezed_annotation 3.1.0, json_serializable 6.14.1, build_runner 2.16.1, fpdart 1.2.0, dio 5.11.1, go_router 18.0.2, stream_transform 2.1.2, mocktail 1.0.5, very_good_analysis 11.0.0, @angular/core 22.2.1, @ngrx/store 22.0.1, fp-ts 2.16.11, zod 4.6.5, vitest 5.0.3 coinciden con `latest`. TypeScript 6.0: `latest` es 7.0.2, pero `@angular/compiler-cli@22.2.1` exige `>=6.0 <6.1`, por lo que 6.0 es correcto (anotarlo como restricción). `go_router 18` exige Flutter >=3.44.0 (coherente con el requisito de `flutter upgrade`). Nota: `fp-ts` es una librería estable pero en mantenimiento (su línea evolucionó hacia Effect); aceptable, justificar en README. |
| Cobertura de la spec (FR y NFR) | Ver sección 3. |
| Dimensiones del altitude decididas, diferidas o abiertas, incluida la envolvente operativa | Parcial: faltan H-7 (plataformas, permisos, timeouts, pinning de toolchain). El spine no tiene sección "Open Questions"; las preguntas 7 y 8 del PRD (Angular/Vitest, idioma de commits) quedan resueltas implícitamente (Angular 22 + Vitest, inglés) y la 2 (archivos generados commiteados) en AD-13, pero no se registra explícitamente que se cierran. |

## 3. Cobertura FR / NFR

| ID | Estado | Nota |
| --- | --- | --- |
| FR-1 | Cubierto (AD-6) | Falta decidir carga inicial inmediata (H-4); marcador de imagen faltante no decidido (detalle de UI, bajo). |
| FR-2 | Cubierto parcial (AD-4, AD-6) | Retry del estado inicial (`ref.invalidate`) no se nombra; solo el retry de `loadMore`. Estado vacío vía Repository falso: lo cubre AD-13 indirectamente. |
| FR-3 | Cubierto (AD-6) | Ver H-4 y cancelación con `CancelToken`: bien. |
| FR-4 | Cubierto (AD-8, AD-7) | `family` por id: no se dice explícitamente (el spine dice "consulta por id"); añadir "provider family". |
| FR-5 | Cubierto (AD-4, AD-8) | |
| FR-6..FR-9 | Cubierto (AD-7) | Falta keepAlive (H-3); el contador "visible desde cualquier pantalla" (AppBar compartido en shell o en cada pantalla) no se decide. |
| FR-10 | Cubierto (AD-2, AD-3) | Ver H-1. |
| FR-11 | Cubierto (AD-3) | `ParseException` para campo ausente: bien. Justificación en README (T-4): ver FR-20. |
| FR-12 | Cubierto (AD-4) | Forma de `Errors` no definida; mapeo exacto de fallos de Dio no definido (H-7). |
| FR-13 | Cubierto (AD-10, AD-12) | `providedIn: 'root'` y total con descuento no mencionados (bajo). |
| FR-14 | Cubierto con desvío (AD-10) | Ver H-6. |
| FR-15 | Cubierto parcial | Estado y `ErrorInfo` sí; la acción "Reintentar" no está en ningún Rule. |
| FR-16 | Parcial | Ver H-6 (vista en la misma página vs ruta). |
| FR-17 | Cubierto (AD-10) | Sin mecanismo de verificación (H-5). |
| FR-18, FR-19 | Diferido conscientemente | "Fuera del spine" (RESPUESTAS.md). Correcto, pero la reescritura del Fragmento A (FR-19) debe ser coherente con AD-2..AD-7; no hay nota que lo ate. |
| FR-20 | Parcial | AD-1 y AD-13 no listan las obligaciones del README (justificar T-4, paralelos Flutter/Angular, pendientes, mejoras); las equivalencias están en el spine pero sin Rule que las lleve al README. |
| FR-21 | Cubierto (AD-1, AD-13) | Falta mencionar `.gitignore` del PDF como Rule (AD-1 lo dice: "queda fuera del repo"; falta el `.gitignore`). |
| NFR-1 | Cubierto (AD-5) | Incluye `AsyncNotifier` y `Notifier`. |
| NFR-2 | Cubierto (AD-13) | Solo Flutter. |
| NFR-3 | Cubierto (AD-13) | |
| NFR-4 | Cubierto (AD-13) | |
| NFR-5 | Cubierto (AD-5, AD-7) | `const`, constantes sin números mágicos (p. ej. 20 y 400) solo implícitos; fijar dónde viven `pageSize` y `debounceDuration`. |
| NFR-6 | Cubierto (AD-10) | Sin gate automático (H-5). |
| NFR-7 | Cubierto (tabla UI) | |
| NFR-8 | Parcial | Ver H-7 (pinning de toolchain). |
| NFR-9 | Cubierto (Consistency Conventions) | |

Trazabilidad en el Map: la fila "NFR-1..NFR-6 / ambas apps" omite NFR-7..NFR-9 (cubiertos en Consistency Conventions y AD-1). Añadirlos al Map. Los IDs `T-1..T-5` y `DA-1`, `DF-1` en `binds` son correctos.

## 4. Contradicciones con el PRD

1. **AD-11 adopta DA-1 (ruta `/orders/:id` lazy)** como regla firme; el PRD lo coloca como deseable posterior a los obligatorios y FR-16 exige la vista en la misma página. (H-6)
2. **AD-10 mueve el filtro a NgRx**; FR-14 y DA-2 lo plantean como `FormControl`/signal. (H-6)
3. **AD-6 adopta DF-1 (paginación)** y FR-1 la declara fuera de alcance del MVP. (H-8)
4. **AD-9 añade deep link** no pedido; el PRD no lo incluye ni en §6.1 ni en §6.2. (H-8)
5. **AD-12 impone `Either` (fp-ts) y `zod` en Angular**; el addendum T-2 solo decide `Either` para el Repository de Flutter y el PRD pide en Angular "interfaces" tipadas. No es una contradicción estricta, pero es una decisión nueva sin respaldo del PRD ni coaching registrado.
6. **Stack: Angular "22.2.1" y NgRx** frente a NFR-6 "Angular 17 o superior": compatible. TypeScript 6.0 vs `latest` 7.0.2: justificado por Angular (ver arriba), no es contradicción.
7. **Debounce**: el PRD FR-3 dice "tras 400 ms sin nuevas pulsaciones" y que vaciar cancela la consulta pendiente; AD-6 con `StreamProvider` + `.debounce` agrega 400 ms de latencia también al vaciar (salvo que se especifique). (H-4)
8. **Nota menor**: el frontmatter dice `status: draft` mientras todos los AD están `[ADOPTED]`; el CLAUDE.md del repo exige coaching antes de cada decisión técnica. Confirmar que cada AD fue validado con el usuario (no se puede verificar desde el documento).

## 5. Acciones recomendadas (en orden)

1. Fijar propiedad de `Product`, `Page`, `ProductRepository` y reglas de importación entre features (H-1).
2. Reconciliar AD-4 con AD-6: excepción explícita al `guard` para `loadMore` y forma de `CatalogState` (H-2).
3. Declarar `keepAlive` para Cart (y política para searchTerm/catalog) (H-3).
4. Especificar emisión inicial y vaciado del debounce, o cambiar a `Timer` propio con trade-off (H-4).
5. Añadir mecanismos de cumplimiento (ESLint `no-restricted-imports`, test/lint de imports en Dart) y gate de lint/build para Angular (H-5).
6. Decidir dónde viven filtro y selección de Order; reconciliar DA-1/DA-2; considerar Plan B de Angular (H-6).
7. Completar la envolvente operativa: plataformas, permiso INTERNET, timeouts de Dio, pinning de toolchain y Node (H-7).
8. Marcar AD-9 y la parte de paginación de AD-6 como opcionales/diferidos con condición de revisión; listar DA-3 y DA-4 en Deferred (H-8).
9. Añadir sección de Open Questions (o registrar el cierre de las preguntas 2, 7 y 8 del PRD) y NFR-7..NFR-9 al Map.
