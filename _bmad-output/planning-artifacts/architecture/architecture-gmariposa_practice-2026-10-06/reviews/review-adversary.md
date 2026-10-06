# Revisión adversaria — ARCHITECTURE-SPINE.md

Fecha: 2026-10-06. Revisor: adversario (no se editó el spine).
Método: por cada hallazgo se construyen dos unidades de trabajo un nivel por debajo (dos stories o dos desarrolladores) que cumplen cada AD al pie de la letra y aun así construyen piezas incompatibles. Cada par es un hueco; la última línea de cada hallazgo es el AD nuevo o ajustado que lo cierra.

Escala: **Alta** = rompe un FR/UJ o obliga a reescribir una story ya hecha; **Media** = divergencia que aparece en integración o en pruebas; **Baja** = fricción o riesgo menor.

## Veredicto

El spine fija bien las capas y los dueños de infraestructura, pero deja sin decidir las costuras entre stories: el dueño y la forma de Product/CartItem, el ciclo de vida de los providers, la cancelación y las carreras de `loadMore`, y en Angular la forma del estado (un solo `status` para lista y detalle) y la política de efectos. Además hay dos contradicciones internas (AD-4 vs AD-6, AD-2 vs AD-6/AD-3). Con el texto actual, dos stories correctas pueden entregar un Catalog que pierde su estado y un Cart que se vacía.

## Resumen de hallazgos

| # | Sev. | Hallazgo | AD afectados |
| --- | --- | --- | --- |
| H1 | Alta | `loadMore` falla: AD-4 manda `AsyncValue.guard` (reemplaza la lista por error), AD-6 manda conservarla | AD-4, AD-6 |
| H2 | Alta | `CancelToken` en el notifier choca con "ni domain ni presentation importan dio" | AD-2, AD-6 |
| H3 | Alta | Respuesta tardía de `loadMore` tras un cambio de término: `ref.mounted` no basta (verificar) | AD-6 |
| H4 | Alta | `debouncedTerm` como `StreamProvider`: sin valor inicial el Catalog nunca carga; "Reintentar" ambiguo | AD-6 |
| H5 | Alta | Ciclo de vida: `@riverpod` es autoDispose por defecto; Cart, término y paginación se pierden; `go` vs `push` | AD-5, AD-7, AD-8 |
| H6 | Alta | Product, CartItem y Repository con dos dueños posibles; imports entre features sin regla | AD-2, AD-3, AD-7 |
| H7 | Alta | NgRx: un solo `status`/`error` para lista y detalle; `setAll` vs `upsert` pisa el mapa por id | AD-11 |
| H8 | Media | NgRx: operador de aplanado de los effects y registro de effects en rutas lazy sin regla | AD-10, AD-11 |
| H9 | Media | Serializabilidad de acciones (no solo del estado); `ErrorInfo` y `code` sin tipo ni mapeo único | AD-11, AD-12 |
| H10 | Media | Filtro y orden seleccionado: dueño ambiguo (Store vs signal/FormControl vs ruta); `id` string vs int | AD-10, AD-11 |
| H11 | Media | Order: interfaz a mano vs `z.infer`; `discountedTotal` opcional; sobre `{carts,…}` | AD-12 |
| H12 | Media | AD-2/AD-3 contradicen su propio stack: `domain` solo puede importar `core/errors` y `fpdart`, pero ahí viven los `freezed` con `fromJson` | AD-2, AD-3 |
| H13 | Baja | Cart: redondeo del total, firma de `add`, quién calcula el total | AD-7 |
| H14 | Baja | Deep link (host y categorías), testabilidad del router, archivos generados en ramas paralelas, `Errors.message` | AD-8, AD-9, AD-13, AD-4 |

---

## H1 — `loadMore` fallido: el spine manda dos cosas opuestas (Alta)

- **Unidad A (story de paginación, sigue AD-4):** "Los métodos que mutan estado usan `state = await AsyncValue.guard(...)` y no lanzan." Implementa `loadMore()` con `guard`. Si falla, el estado pasa a `AsyncError` y la lista desaparece; la UI de FR-2 muestra pantalla de error completa.
- **Unidad B (story de UI del Catalog, sigue AD-6):** "conserva la lista y, si falla, deja un reintento al final" con `loadMoreError` en el estado. Su widget lee `state.value.loadMoreError`, que nunca se llena porque A dejó `AsyncError`.
- Ambas cumplen un AD al pie de la letra. El resultado es incompatible y además rompe el "Prevents" de AD-6 (paginación que reemplaza la lista).
- **Cierre (ajustar AD-4):** `AsyncValue.guard` solo se usa cuando el fallo debe reemplazar el dato (carga inicial, retry de carga inicial). Un método que mutan estado ya cargado (`loadMore`) hace `fold` sobre el `Either` y escribe el fallo en un campo del estado de datos (`loadMoreError: Errors?`), sin pasar por `AsyncError`. Añadir una prueba de notifier obligatoria: "loadMore falla → `state.hasValue && state.value.items` intactos".

## H2 — `CancelToken` contra la regla de dependencias (Alta)

- AD-6 exige cortar la petición con `CancelToken` en `ref.onDispose` dentro de `catalogProvider` (presentation). AD-2 prohíbe que `domain` y `presentation` importen `dio`. El contrato del Repository vive en `domain`.
- **Unidad A:** importa `package:dio/dio.dart` en el notifier y añade `CancelToken?` a la interfaz del Repository en `domain` (viola AD-2, pero cumple AD-6). **Unidad B:** respeta AD-2, no pasa token y "cancela" solo descartando (cumple AD-2, viola el texto de AD-6 y FR-3 "cancela cualquier consulta pendiente"). Los fakes de `mocktail` de cada una no son intercambiables.
- **Cierre (nuevo AD):** `core/` define un tipo propio `CancelSignal` (envoltorio de `CancelToken`, sin exponer `dio`). El Repository del dominio recibe `CancelSignal? cancel`; `data/` lo traduce a `CancelToken`. `domain` puede importar `core/errors` y `core/cancel_signal`. O bien, alternativa explícita: declarar que cancelar = descartar (H3) y retirar `CancelToken` del AD-6 y de FR-3 en el PRD.

## H3 — Respuesta tardía de `loadMore` tras reiniciar el término (Alta; verificar contra docs de Riverpod 3)

- AD-6 dice "una respuesta de un término ya reemplazado se descarta (`ref.mounted` tras cada `await`)". `catalogProvider` es un Notifier cuya `build()` se vuelve a ejecutar cuando cambia `debouncedTerm`. En un Notifier el `ref` es el mismo objeto entre reconstrucciones, por lo que `ref.mounted` sigue en `true` tras un rebuild (solo pasa a `false` al disponer el provider). Verificar este punto con context7 al escribir la story: si es así, el chequeo no detecta el cambio de término.
- **Unidad A (`build`/búsqueda)** reinicia el estado con el término nuevo. **Unidad B (`loadMore`)** tenía una petición en vuelo con `skip=20` del término viejo; al volver, `ref.mounted` es `true` y concatena resultados del término viejo a la lista nueva. Ambas cumplen AD-6.
- **Cierre (ajustar AD-6):** el notifier mantiene un contador de época (`_epoch`) incrementado en cada `build()`. Todo `await` captura `final epoch = _epoch` y descarta si cambió; `ref.mounted` se mantiene además para el caso de dispose. Añadir una prueba: "loadMore en vuelo + cambio de término → la lista nueva queda intacta".

## H4 — `debouncedTerm` como `StreamProvider`: estado inicial, vacío y reintento (Alta)

- Un `StreamProvider` está en `AsyncLoading` sin valor hasta que el stream emite. `stream_transform.debounce` solo emite 400 ms después de un evento de entrada; si no hay entrada, no emite nunca. El spine no dice cómo se alimenta el stream ni con qué valor inicial.
- **Unidad A (`debouncedTerm`):** alimenta el stream desde `ref.listen(searchTermProvider)` sin valor inicial. **Unidad B (`catalogProvider`):** hace `await ref.watch(debouncedTermProvider.future)`: con A, la carga inicial (FR-1, UJ-1) queda colgada hasta que el Usuario teclee. Si B usa `.value ?? ''` para sortearlo, A y B ya divergen. Si A siembra `''` y lo pasa por el debounce, la app abre con 400 ms de retraso y nada se muestra.
- Vaciar el término: ¿pasa por el debounce de 400 ms o es inmediato? FR-3 solo dice que cancela la consulta pendiente y vuelve al Catalog.
- **Reintentar:** la story de UI hace `ref.invalidate(debouncedTermProvider)` (el `StreamProvider` vuelve a `AsyncLoading` y re-suscribe; se pierde el valor y el catálogo se cuelga como arriba); otra hace `ref.invalidate(catalogProvider)` (correcto). AD-6 no lo define. Además, con la invalidación de un provider con error, el `AsyncValue` queda `isLoading && hasError`; `when` por defecto no muestra spinner en `refresh` (según el caso), y cada story elegirá su patrón.
- **Cierre (ajustar AD-6):**
  1. `debouncedTerm` emite siempre un primer valor `''` sin debounce (stream sembrado) y aplica `.distinct()` tras `trim`.
  2. El término vacío se emite de inmediato (sin los 400 ms); los no vacíos pasan por el debounce.
  3. `catalogProvider` lee con `ref.watch(debouncedTermProvider.select((a) => a.value ?? ''))` (nunca `.future`).
  4. "Reintentar" es siempre `ref.invalidate(catalogProvider)`, nunca el término; y la UI deriva sus cuatro estados con un único `switch` sobre `AsyncValue` (error → `AsyncError` sin valor previo; vacío → `items.isEmpty` en `AsyncData`) en un widget compartido.
  5. Al cambiar el término el estado se reinicia sin conservar el valor anterior (definir cómo: `build` devuelve `AsyncLoading` sin `copyWithPrevious`); si no, una story muestra resultados viejos con spinner y otra solo spinner.

## H5 — Ciclo de vida de providers y navegación que reinicia estado (Alta)

- `riverpod_generator` (AD-5) crea providers autoDispose por defecto. El spine nunca nombra `keepAlive`.
- **Unidad A (Cart):** `@riverpod class Cart extends _$Cart`. El estado vive solo mientras alguien lo escucha. Si el contador del AppBar es un widget por pantalla y la navegación usa `context.go` (que reemplaza la pila), hay un instante sin oyentes entre pantallas y el Cart se vacía, rompiendo el "Resolución" de UJ-1 (el Cart conserva su contenido). **Unidad B (detalle):** agrega con `ref.read(cartProvider.notifier).add(...)` en un callback (correcto según AD-5) y, como `read` no mantiene vivo el provider, el estado se descarta en cuanto termina la pantalla.
- **Unidad C (Catalog) y D (detalle):** AD-8 permite `context.go`, `push` y `pop` sin decir cuál se usa de lista a detalle. Con `go('/product/5')` el Catalog se desmonta; `searchTerm` y `catalogProvider` (autoDispose) se reinician. Con el botón atrás (`canPop() ? pop() : go('/')`), `canPop()` es `false` tras un `go` y se vuelve a `/` con búsqueda vacía, scroll en 0 y sin páginas. Esto invalida también el sentido de DF-1.
- **Infra:** `dioProvider` autoDispose con `ref.onDispose(dio.close)` cancelaría peticiones en vuelo; `productRepositoryProvider` leído con `ref.read` se recrea en cada uso.
- **Texto-campo vs provider:** el `TextEditingController` del buscador y `searchTerm` son dos dueños del término. Si `searchTerm` sobrevive y el campo se recrea vacío, la UI muestra vacío con resultados filtrados.
- **Cierre (nuevo AD "Ciclo de vida"):**
  - `keepAlive: true` obligatorio en: Cart, `cartCount`/total derivados (heredan por observar), `searchTerm`, `dioProvider`, `productRepositoryProvider`. `catalogProvider` y `debouncedTerm` viven mientras exista la pantalla `/` en la pila.
  - El detalle y el Cart se abren con `context.push` desde el Catalog; `context.go` solo para volver a `/` desde un deep link sin pila. Nadie llama `dio.close()` en `onDispose`.
  - El campo de búsqueda inicializa su controlador con `ref.read(searchTermProvider)` y escribe en una sola dirección (controlador → provider).
  - `catalogProvider` conserva paginación y scroll mientras `/` esté en la pila.

## H6 — Product, CartItem y Repository: dueños duplicados e imports entre features (Alta)

- El árbol tiene `features/catalog/{data,domain,…}` y `features/product_detail/{data,domain,…}` y `cart/{domain,presentation}`. El spine habla de "el Repository" y de un `productRepositoryProvider`, pero no dice a qué feature pertenecen.
- **Unidad A (catalog):** define `Product` en `catalog/domain`, `ProductRepository.list/search` y `productRepositoryProvider` en `catalog/data`. **Unidad B (product_detail):** define su `Product` (con más campos) en `product_detail/domain`, `getById` en un segundo repositorio y su propio provider. AD-3 ("un solo dueño de cada pieza") y "la única importación de data permitida" quedan cumplidos por duplicado. El Cart no sabe de cuál `Product` depender, ni puede hacerlo sin que una feature importe a otra, y AD-2 solo regula capas, no features ("ciclos entre features y core").
- **Unidad C (Cart):** `CartItem { Product product; int quantity }` (con el `Product` completo). **Unidad D (UI del Cart):** asume `CartItem { productId, title, price, thumbnail, quantity }` por la regla "el detalle no reutiliza datos del Catalog". La firma de `add` también diverge: `add(Product)` frente a `add(CartItem)` frente a `add(int id)`.
- **AppBar:** "contador visible desde cualquier pantalla" (FR-9): tres pantallas, tres AppBars; cada story crea su propia versión del badge o importa la de otra feature sin regla.
- **Cierre (nuevo AD "Dueños de modelos y de feature a feature"):**
  - Un solo `Product` en `features/catalog/domain` (el detalle de DummyJSON es el mismo esquema que el listado; un único `fromJson`) y un único `ProductRepository` con `list`, `search` y `getById`, en `features/catalog/data`. `product_detail` no tiene `data/` ni `domain/` propios. Se retira esa carpeta del árbol o se declara como solo `presentation`.
  - `CartItem { Product product; int quantity }` es la forma canónica y `Cart.add(Product)`, `setQuantity`/`increment`/`decrement(int productId)`, `remove(int productId)`.
  - Tabla de imports permitidos entre features: `catalog/presentation` y `product_detail/presentation` → `cart/presentation` (solo `CartBadge`, `cartProvider`); `cart/domain` → `catalog/domain` (solo `Product`). Cualquier otro cruce se prohíbe. `CartBadge` es un widget único con dueño (`cart/presentation`).
  - Ajustar el contrato: `Page<T> { items, total, skip, limit }`.

## H7 — NgRx: forma del estado de Orders (Alta)

AD-11 fija "un único mapa por `id`" y "un `status` y un `ErrorInfo`", pero no la forma real.

- **Un solo `status`/`error` para lista y detalle.** **Unidad A (lista, FR-13/FR-15):** `loadOrders` → `status: 'loading'`; el estado de error se muestra con "Reintentar". **Unidad B (DA-1, `/orders/:id`):** `loadOrder(5)` pone el mismo `status: 'loading'`, así que la lista (si está a la vista) vuelve a mostrar el indicador de carga; un `loadOrder(9999)` fallido guarda el error en el campo único y la lista muestra "error" aunque cargó bien.
- **Entrada directa a `/orders/5`:** B inserta el Order 5 en el mapa. Al volver a la lista, la regla "si no está cargado, despacha" de A (¿`ids.length === 0`?) ve el mapa no vacío y no pide la lista: el panel muestra un solo Order como si fuera todo. El spine no define "lista cargada".
- **Reemplazo vs fusión:** A implementa el éxito de `loadOrders` como `setAll` (reemplaza el mapa); B inserta con `upsertOne`. Con las acciones intercaladas (detalle llega primero, lista después, o un "Reintentar" posterior), `setAll` borra lo que insertó el detalle y viceversa, y el orden de `ids` depende de quién llegó primero. Ambos cumplen "mismo mapa".
- **Orden de la lista:** el orden de `ids` es de inserción; sin `sortComparer` el Order que llegó por detalle aparece primero.
- **Cierre (ajustar AD-11):**

  ```ts
  interface OrdersState {
    entities: Record<number, Order>;   // mapa único; ids numéricos
    listStatus: 'idle' | 'loading' | 'loaded' | 'error';
    listError: ErrorInfo | null;
    byIdStatus: Record<number, { status: 'loading' | 'error'; error: ErrorInfo | null }>;
  }
  ```

  - `loadOrdersSuccess` hace upsert (fusión) y marca `listStatus: 'loaded'`; nunca reemplaza el mapa. `loadOrderSuccess` hace upsert de un Order y no toca `listStatus`.
  - "Order cargado" = `entities[id] !== undefined`; "lista cargada" = `listStatus === 'loaded'`. Nada infiere uno del otro.
  - Selector `selectAllOrders` ordena por `id` ascendente (o usa `EntityAdapter` con `sortComparer`).
  - Los errores del detalle son por id; el de la lista no se mezcla con ellos.

## H8 — NgRx: carreras de effects y registro en rutas lazy (Media)

- **Operador de aplanado.** AD-10 dice que solo los effects llaman al servicio, pero no el operador. **Unidad A:** `switchMap` en `loadOrders` (el segundo "Reintentar" cancela el primero; correcto). **Unidad B:** `switchMap` en `loadOrder` también; al navegar entre `/orders/3` y `/orders/4` rápido se cancela el Order 3 y su `byIdStatus` queda en `loading` para siempre. Otra story usa `mergeMap`/`concatMap` y deja peticiones duplicadas.
- **Cierre:** `loadOrders` con `exhaustMap` (ignora un reintento mientras está en vuelo); `loadOrder` con `mergeMap` (por id) más un guard `if entities[id]` antes de pedir. Todo effect debe emitir siempre una acción de éxito o fallo (`catchError` dentro del `inner pipe`, no fuera, para no matar el effect).
- **Registro.** `/orders` y `/orders/:id` son lazy (DA-1). Si cada ruta declara `provideState`/`provideEffects` en sus `providers`, se instancian en entornos distintos. Puede duplicar las llamadas HTTP (NgRx suele deduplicar por clase, pero hay que verificarlo en la story) y duplicar el reducer.
- **Cierre:** `provideStore`, `provideState('orders', …)` y `provideEffects` se registran una sola vez, en el nivel de la ruta padre `/orders` (o en `app.config.ts`); las rutas hijas no registran nada.

## H9 — Serializabilidad de acciones, `ErrorInfo` y `code` (Media)

- AD-11 exige "valores planos" solo para el estado. Las acciones también las verifica `strictActionSerializability` (por defecto en dev). El effect hace `fold` de `Either<Errors, T>`: **Unidad A** despacha `loadOrdersFailure({ errors })` con la instancia de clase `Errors` (falla la comprobación de serializabilidad o el reducer guarda una clase en el estado); **Unidad B** despacha `{ error: ErrorInfo }`.
- `ErrorInfo { message, code }`: `code` sin tipo (`number` de HTTP, `string` de la subclase o ambos). `Errors` es una lista de `BaseException`; ¿qué excepción rellena `message`? ¿la primera? ¿todas unidas? Lo mismo en Flutter (`Errors.message`). Los dos paneles de errores se verán distintos.
- **Cierre (ajustar AD-12):** un único `toErrorInfo(errors: Errors): ErrorInfo` en `core/errors`, y `code: string` (nombre estable de la subclase, p. ej. `'NETWORK'`, `'SERVER'`, `'PARSE'`) más `status?: number`. Las acciones de fallo llevan solo `ErrorInfo`. En Flutter, `Errors.message` es un getter único definido en `core/errors` (primera excepción); los widgets lo usan sin reinterpretar.

## H10 — Filtro, orden seleccionado e `id` de ruta: dueño ambiguo (Media)

- **Filtro.** AD-10: "una acción más un selector": el valor vive en el Store. PRD FR-14/DA-2: "`FormControl` o un signal", y DA-2 pide `signal`/`computed` para el estado del filtro. **Unidad A (FR-14):** acción `setMinTotal` + selector. **Unidad B (DA-2):** mueve el filtro a un `signal` del contenedor y lo combina con `toSignal(select(allOrders))`. Dos dueños del mismo valor; al volver desde `/orders/:id`, el `FormControl` se recrea vacío y el Store aún tiene 100: la UI muestra vacío con la lista filtrada. Faltan también la forma del valor (`number | null`; vacío, `NaN` y negativos).
- **Orden seleccionado.** FR-16 (misma página) frente a DA-1 (ruta). **Unidad A:** `selectedId` como signal local del contenedor. **Unidad B:** como parámetro de ruta. Dos fuentes de verdad; el detalle de A no tiene URL.
- **`id` de ruta:** `:id` llega como `string`; `entities[idParam]` funciona por coerción de JS aunque el tipo dice `number`, y `'abc'` produce `NaN`. AD-8 parsea una sola vez en Flutter; AD-11 no dice lo mismo para Angular.
- **Cierre (ajustar AD-10/AD-11):** el valor del filtro vive en el Store (`minTotal: number | null`); DA-2 usa `computed` solo para derivar, no para almacenar. El `FormControl` se inicializa desde el selector y escribe en una sola dirección. El Order seleccionado se deriva de la ruta desde el primer commit (`/orders` y `/orders/:id` con `withComponentInputBinding` o un selector de ruta) aun antes de DA-1; el `id` se parsea a `number` una vez en la ruta y uno inválido va a una vista de error.

## H11 — Order: interfaz o `z.infer`, campos opcionales y sobre de la API (Media)

- FR-13 pide "interfaces"; AD-12 pide validar con `zod`. **Unidad A:** interfaz escrita a mano en `core/` + esquema `zod` aparte, que se desfasan. **Unidad B:** `type Order = z.infer<typeof OrderSchema>` y `discountedTotal` opcional. **Unidad C:** `discountedTotal: z.number()` obligatorio, que rompe con respuestas sin ese campo ("si DummyJSON lo incluye").
- `GET /carts?limit=0` devuelve `{ carts, total, skip, limit }`. No se define si `OrdersService` devuelve `Order[]` o el sobre, ni si el esquema es `strict` o `passthrough` (`strict` rechaza campos nuevos de DummyJSON).
- **Cierre:** `core/` define el esquema `zod` como única fuente; `Order` y `OrderProduct` se exportan con `z.infer`. `discountedTotal` es `.optional()`; el esquema usa el comportamiento por defecto (campos extra eliminados, no `strict`). `OrdersService.getAll()` devuelve `Observable<Either<Errors, Order[]>>` (el sobre se desenvuelve dentro del servicio).

## H12 — AD-2 y AD-3 se contradicen con el stack (Media)

- AD-2: "`domain` solo importa `core/errors` y `fpdart`". AD-3: los modelos `freezed` con `fromJson` viven en `domain/`. `freezed_annotation` y `json_annotation` no están permitidos, y `Page<T>`/`CancelSignal` tampoco. Un lint de imports aplicado al pie de la letra rechaza el código que AD-3 exige.
- **Unidad A** añade una excepción local sin documentar; **Unidad B** pone los modelos en `data/` como DTO (rompe AD-3 y "Product" con dos dueños, véase H6).
- **Cierre (ajustar AD-2):** lista blanca explícita para `domain`: `core/errors`, `core/cancel_signal`, `fpdart`, `freezed_annotation`, `json_annotation`, `meta`, y la del propio `domain`. `presentation` solo importa `flutter_riverpod`/`riverpod_annotation`, `go_router`, y su `domain`. Nombrar la herramienta del lint de imports (por ejemplo `import_lint` o `dart_code_linter`), o declarar que la regla se hace cumplir solo con revisión.

## H13 — Cart: redondeo, firma y total (Baja)

- Precios `double` (AD, Data & formats). **Unidad A:** suma doubles y formatea con `toStringAsFixed(2)` en el widget (lógica en UI, viola FR-9/AD-7). **Unidad B:** redondea en `domain`. Las pruebas del total (`19.99 * 3`) comparan igualdad de doubles y salen distintas.
- `cartCountProvider` está nombrado; el total, no (`cartTotalProvider` o función libre).
- **Cierre (ajustar AD-7):** el total se calcula en `domain` con una función `cartTotal(items)` que devuelve `double` redondeado a 2 decimales (`(x * 100).round() / 100`) y la UI solo formatea con `toStringAsFixed(2)`. Existe `cartTotalProvider` junto a `cartCountProvider`, ambos derivados.

## H14 — Hallazgos menores (Baja)

1. **Deep link (AD-9).** El esquema `gmariposa` requiere también `android:host="app"` en el `<data>` y las categorías `DEFAULT` y `BROWSABLE` del `intent-filter`; sin ellas `adb am start` con `-d "gmariposa://app/product/5"` no resuelve. El host también debe coincidir con lo que go_router ignora (solo usa el path `/product/5`). Fijar los tres elementos en AD-9 y cubrir el caso de arranque en frío (la pila solo tiene el detalle: el botón atrás cae en `go('/')`).
2. **Creación del router (AD-8).** "Creado en el shell, sin provider": si una story lo construye dentro de `build()` de un widget, cada reconstrucción de `MaterialApp` reinicia la navegación. Y sin provider, una prueba de widget no puede elegir la ruta inicial. Cierre: `GoRouter createRouter({String initialLocation = '/'})` como función en `presentation/`, invocada una vez en el `State` del shell; las pruebas llaman a la misma función.
3. **Archivos generados (AD-13).** Dos ramas de stories paralelas que regeneran `*.g.dart`/`*.freezed.dart` producen conflictos al fusionar. Cierre: al fusionar se resuelve volviendo a ejecutar `build_runner`, nunca a mano, y cada story toca solo los generados de su feature.
4. **`ref.listen` en Riverpod 3.** Los oyentes de rutas cubiertas se pausan; una story que muestre un `SnackBar` desde `ref.listen` en una pantalla que no está visible no lo verá. Documentarlo en AD-5 como regla: las reacciones de UI se declaran en la pantalla que las muestra.
5. **Pruebas.** `ProviderScope(retry: …)` en la app y `ProviderContainer(retry: …)` en las pruebas se duplican en cada story; añadir un helper de pruebas único (`pumpApp`/`makeContainer`) como parte de AD-13.

---

## Qué sí resiste

- Un solo `Dio`, un solo punto de captura de `DioException` y el provider del Repository como única entrada de `data` (AD-3): sin ambigüedad una vez resuelto H6.
- El contrato `limit/skip/total` desde el MVP.
- Angular: ningún componente toca `HttpClient`, `OrderCardComponent` puro con `OnPush`.
- Detalle por `id` con `family`: cada `id` con su estado (el aislamiento de FR-4 se cumple por construcción).

## Orden sugerido para cerrar

1. H1, H2, H12 (contradicciones internas del spine; baratas y de efecto inmediato).
2. H6, H5 (dueños y ciclo de vida: deciden la forma de todas las stories de Flutter).
3. H4, H3 (mecanismo de búsqueda y paginación: pruebas de notifier con `FakeRepository` que controla el `Completer`).
4. H7, H8, H9, H10, H11 (un solo AD "Forma del estado de Orders" lo cubre).
5. H13, H14 (ajustes de una línea).
