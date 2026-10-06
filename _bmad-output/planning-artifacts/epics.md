---
status: final
stepsCompleted: ['step-01-validate-prerequisites', 'step-02-design-epics', 'step-03-create-stories', 'step-04-final-validation']
inputDocuments:
  - _bmad-output/planning-artifacts/prds/prd-gmariposa_practice-2026-10-05/prd.md
  - _bmad-output/planning-artifacts/prds/prd-gmariposa_practice-2026-10-05/addendum.md
  - _bmad-output/planning-artifacts/architecture/architecture-gmariposa_practice-2026-10-06/ARCHITECTURE-SPINE.md
  - _bmad-output/planning-artifacts/ux-designs/ux-gmariposa_practice-2026-10-05/DESIGN.md
  - _bmad-output/planning-artifacts/ux-designs/ux-gmariposa_practice-2026-10-05/EXPERIENCE.md
  - _bmad-output/planning-artifacts/ux-designs/ux-gmariposa_practice-2026-10-05/stitch-index.md
---

# gmariposa_practice - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for gmariposa_practice, decomposing the requirements from the PRD, UX Design and Architecture into implementable stories.

**Resolución de contradicciones (decidida con Mauri, a favor del PRD/Arquitectura sobre `EXPERIENCE.md`):**
1. Angular SÍ tiene la ruta lazy `/orders/:id` en el MVP (FR-16, AD-11).
2. La paginación infinita (DF-1) SÍ entra al MVP (PRD §6.1, AD-6).
3. El total del Cart es `double` redondeado solo al mostrar (AD-7), no centavos enteros.
5. **Angular: Tailwind en lugar de CSS propio** (decisión de Mauri, posterior al spine y a `DESIGN.md`). Los tokens de `DESIGN.md` se definen en `@theme`, y el estilado va en utilidades de Tailwind. Afecta a la story 4.1 (instalación y tema) y a UX-DR1, UX-DR20; `DESIGN.md` y `EXPERIENCE.md` aún dicen "variables CSS" y "CSS propio" para Angular y se actualizan al empezar la 4.1.
4. **Angular: store manual, sin NgRx** (decisión de Mauri, posterior al spine). Un servicio-store propio lleva el mismo estado (mapa de Orders por `id`, `listStatus`/`listError`, `byIdStatus`, `minTotal`). `@ngrx/*` queda instalado en `package.json` sin uso y se justifica en el README (FR20). Esto **sustituye** a T-7 y a las partes de AD-10, AD-11 y FR-14 que nombran Store, actions, reducer, selectors y effects; el spine y el PRD aún dicen NgRx y deben alinearse (ver nota de cierre).

## Requirements Inventory

### Functional Requirements

FR1: Listar el Catalog: el Usuario ve Products con imagen, título, precio y rating; al abrir se cargan los primeros 20 (`GET /products?limit=20&skip=0`); una imagen faltante muestra marcador, no error.
FR2: Estados del Catalog: cargando, datos, vacío o error; error con botón "Reintentar"; el mensaje de error proviene de un Errors.
FR3: Buscar con debounce: tras 400 ms sin pulsaciones se consulta `GET /products/search?q=…&limit=20&skip=0`; el término se recorta con `trim`; vacío vuelve al Catalog completo; las respuestas de un término ya reemplazado se descartan; vaciar cancela la consulta pendiente; "Reintentar" repite el término vigente.
FR4: Ver el detalle de un Product a partir de su `id` (solo recibe el `id`, consulta `GET /products/{id}` con provider `family`); muestra imagen, título, precio, rating y botón agregar al Cart; dos detalles no mezclan datos.
FR5: Estados del detalle: cargando, datos o error (API falla o `id` inexistente) con "Reintentar".
FR6: Agregar un Product al Cart: nuevo crea Cart item con cantidad 1; existente incrementa en 1 sin duplicar.
FR7: Cambiar la cantidad de un Cart item: aumentar suma 1, disminuir resta 1; nunca baja de 1 al disminuir.
FR8: Quitar un Cart item: desaparece, total y contador se actualizan; quitar el último deja estado vacío visible.
FR9: Total y contador: total = Σ precio × cantidad con dos decimales y sin símbolo; el contador del AppBar muestra unidades totales y es visible en Catalog, detalle y Cart.
FR10: Acceso a datos solo a través del Repository inyectado por provider; ningún widget/notifier toca el cliente HTTP; un `override` con Repository falso cambia los datos; `limit`/`skip` (20/0) y `total` en el contrato.
FR11: Modelos inmutables con `fromJson`; un JSON con campo requerido ausente o erróneo produce BaseException de parseo; la forma de construir los modelos (T-4) se justifica en el README.
FR12: Errores tipados hacia la UI: red, respuesta no exitosa y parseo son subclases distintas de BaseException con `message` y `code`; la UI nunca recibe excepciones crudas de `dio`; el mensaje se deriva del Errors.
FR13: Listar los Orders (Angular): `OrdersService` (`providedIn: 'root'`, `HttpClient`, `GET /carts?limit=0`) tipado; `OrdersPageComponent` contenedor y `OrderCardComponent` presentacional; tarjeta con id, `userId`, total y total con descuento si existe; sin `any` injustificado.
FR14: Filtrar por total mínimo: `FormControl` actualiza el store manual (dueño del estado del filtro; antes NgRx, ver resolución 4); filtra `total >= mínimo` sin repetir la petición; vacío muestra todos; sin coincidencias muestra mensaje de vacío.
FR15: Estados de carga y error del panel: indicador de carga; error legible con "Reintentar" que repite la petición.
FR16: Detalle de un Order: `OrderCardComponent` recibe el Order por `input()` y emite el id por `output()`; no navega ni consulta; el contenedor navega a `/orders/:id` (lazy) que muestra título, cantidad y precio de cada producto.
FR17: Sin fugas de memoria: datos con `async` pipe, `toSignal`, `takeUntilDestroyed` o equivalente; ningún `subscribe()` sin limpieza.
FR18: Responder las 20 preguntas conceptuales (Parte 1) en `RESPUESTAS.md`, numeradas como el PDF, 3 a 6 líneas cada una, con frases propias.
FR19: Code review (Parte 4) de los fragmentos A (Flutter) y B (Angular) en `RESPUESTAS.md`: qué está mal, por qué importa, cómo se corrige; incluye reescritura del Fragmento A coherente con la arquitectura.
FR20: README en la raíz: cómo ejecutar ambas apps, decisiones de arquitectura, pendientes, mejoras, justificación de T-4 y paralelos Flutter↔Angular.
FR21: Estructura del Repo e historial: `flutter_app/` y `angular_app/`; una rama por story `<tipo>/<epic>-<story>-<slug>` fusionada a `main`; Conventional Commits con alcance `flutter|angular|docs|repo`; sin commit único; el PDF fuera del Repo y en `.gitignore`.

### NonFunctional Requirements

NFR1: Estado de Flutter solo con Riverpod 2.x/3.x, con al menos un `AsyncNotifier`/`FutureProvider` y un `Notifier`; sin `setState` ni `flutter_hooks` para estado de negocio.
NFR2: `flutter analyze` sin warnings con `very_good_analysis`.
NFR3: Al menos 3 pruebas unitarias y 1 de widget en Flutter, con `ProviderContainer`/`overrides` y Repository falso.
NFR4: Al menos 2 pruebas en Angular (servicio con `HttpTestingController` y/o componente).
NFR5: Prácticas observadas: widgets pequeños con `const` y sin lógica de negocio; `ref.watch` en `build` y `ref.read` solo en callbacks; estado inmutable; nombres consistentes; sin código muerto, `print` ni valores mágicos.
NFR6: Angular 17+ (spine: 22), standalone, TypeScript `strict`, sin `any` injustificado.
NFR7: Interfaz ordenada y consistente; sin diseño elaborado.
NFR8: Cada proyecto se ejecuta con los comandos del README desde un clon limpio.
NFR9: Código e identificadores en inglés; README, `RESPUESTAS.md` y documentos en español.

### Additional Requirements

- **Scaffold (sin starter template de terceros):** `flutter create` para `flutter_app/` y `ng new` para `angular_app/` (AD-14). Paso 0 de Flutter: `flutter upgrade` hasta Dart ≥ 3.13. Angular exige TypeScript `~6.0`; confirmar zoneless y Vitest al generar.
- AD-1: dos apps independientes, cada una con su lint, test, lockfile commiteado y comandos; sin imports cruzados; PDF fuera del repo.
- AD-2: regla de dependencias Flutter (`domain` solo importa `core/errors`, `fpdart`, `freezed_annotation`, `json_annotation`; ni `domain` ni `presentation` importan `dio`; imports entre features limitados a los listados).
- AD-3: un único `Dio` en `core/` (URL base constante, timeouts 10 s); `data/` único que captura `DioException` (→ `NetworkException`, `ServerException(status)`, `ParseException`; cancelación no es error); `CancelSignal` propio en `core/`; `features/products/{data,domain}` único dueño de `Product`, `Page<Product>` y `ProductRepository`; `productRepositoryProvider` en `products/data/`; modelos `freezed` con `fromJson` en `domain/`.
- AD-4: `Errors`/`BaseException` en `core/errors/`; Repository devuelve `Future<Either<Errors, T>>` (`fpdart`); extensión propia `getOrThrow()` en la carga inicial; `loadMore` hace `fold` y escribe el error en el estado sin `AsyncValue.guard`.
- AD-5: `riverpod_generator` en todos los providers; reintento automático de Riverpod 3 desactivado (`ProviderScope(retry: (_, __) => null)` y en tests); autoDispose por defecto, `keepAlive` en Cart, `searchTerm`, `Dio` y Repository; notifiers sin navegación ni UI.
- AD-6: `searchTerm` (`Notifier<String>` keepAlive), `debouncedTerm` (`StreamProvider` con `stream_transform`, 400 ms, vacío inmediato), `catalogProvider` con `items`, `total`, `loadMore: AsyncValue<void>`; contador de época para descartar respuestas tardías; `CancelSignal` en `ref.onDispose`; `loadMore` con `skip = items.length`; "Reintentar" inicial = `ref.invalidate(catalogProvider)`; gatillo de `loadMore` por `ScrollController`.
- AD-7: `CartItem` único en `cart/domain/` con funciones puras (agregar, cantidad, quitar, total); Notifier del Cart en `presentation/` con `keepAlive`; `cartCountProvider` derivado; total `double` redondeado solo al mostrar.
- AD-8: un único `GoRouter` en el shell (`MaterialApp.router`), sin provider; `context.push` del Catalog al detalle y al Cart; rutas `/`, `/product/:id`, `/cart` autosuficientes; `id` parseado a `int` una vez, inválido → pantalla de error; atrás con `canPop() ? pop() : go('/')`; `errorBuilder` para rutas desconocidas.
- AD-9: deep link Android (`intent-filter` `VIEW`/`DEFAULT`/`BROWSABLE`, `scheme="gmariposa"`, `host="app"`) verificado con `adb shell am start …gmariposa://app/product/5`; resultado al README.
- AD-10: Angular standalone, strict, zoneless; contenedor/presentacional; solo `OrdersService` usa `HttpClient` y solo el store manual llama a `OrdersService` (sustituye a "solo los effects", resolución 4); filtro del `FormControl` al store (`setMinTotal`), lista visible como valor derivado (`computed`); cada story corre `ng test` y `ng build`.
- AD-11: Orders en un mapa por `id` con `upsert`; `listStatus`/`listError` independientes de `byIdStatus`; `/orders/:id` lazy con `loadComponent`, `id` parseado a `number` una vez, `loadOrder(id)` si no está cargado; la carga de la lista ignora una nueva petición mientras hay una en vuelo (equivale a `exhaustMap`) y el detalle admite cargas concurrentes por `id` (equivale a `mergeMap`); el store es un servicio `providedIn: 'root'` único, no registrado en rutas lazy; estado solo con valores planos (`ErrorInfo { message, code }`, `toErrorInfo(errors)`).
- AD-12: `Errors`/`BaseException` en TypeScript con las mismas subclases; solo módulos `Schema` y `Result` de `effect` (v4, confirmar nombres de API en la story); `OrdersService` devuelve `Observable<Result<T, Errors>>` con `Schema.decodeUnknownResult`; `Order` inferido del esquema; `discountedTotal` opcional.
- AD-13: `mocktail`, `ProviderContainer` con reintento desactivado; cada story Flutter corre `dart format`, `flutter analyze`, `flutter test`; Angular con Vitest y `HttpTestingController`; archivos generados (`*.g.dart`, `*.freezed.dart`) commiteados y regenerados antes de cada commit, conflictos se regeneran; rama por story y Conventional Commits en inglés.
- AD-14: plataforma Flutter Android (emulador); permiso `INTERNET` en el `AndroidManifest.xml` principal; sin despliegue.
- AD-15: constitución DDD como referencia: aplican `error-handling`, `no-unsafe-type-escapes` (sin `as` ni `!` forzados) y `no-dynamic-imports` (excepción `loadComponent`); sin Value Objects.
- Stack: Flutter/Dart (≥ 3.13), flutter_riverpod 3.4.3, riverpod_annotation 4.0.7, riverpod_generator 4.0.9, freezed 4.0.2, freezed_annotation 3.1.0, json_serializable 6.14.1, build_runner 2.16.1, fpdart 1.2.0, dio 5.11.1, go_router 18.0.2, stream_transform 2.1.2, mocktail 1.0.5, very_good_analysis 11.0.0; Angular 22.2.1, TypeScript ~6.0, Node 24.16, @ngrx/* 22.0.1, effect 4.0.1, Vitest 5.0.3. Verificar compatibilidad con el primer `build_runner`.
- Plan B (PRD §8): si `build_runner`/versiones consumen más de 2 h sin avanzar, volver a modelos manuales (T-4) y/o Riverpod sin generador (T-5) y documentarlo en el README.
- Gate de UI: cada story de UI cita su pantalla en `stitch-index.md` (Catálogo `0d762685…`, Detalle `b0e799e0…`, Carrito `f6db58a5…`, Órdenes `1b9f30e0…`) y actualiza la columna "Story" del índice.
- Deseables fuera del MVP, en este orden y solo con obligatorios cerrados: DA-2..DA-5 (Angular), DF-2, DF-3, DF-6 (Flutter), B-1, B-2. DA-1 (`/orders/:id` lazy) y DF-1 (paginación infinita) ya están en el MVP.
- Si el PRD y el índice de Stitch chocan, mandan `DESIGN.md`/`EXPERIENCE.md`/PRD sobre el mock.
- Librerías de UI elegidas por Mauri (no están en el Stack del spine): `toastification` ^3.2.0 (toast "Agregado al carrito", story 3.1; Flutter ≥ 3.38, sin generador) y `wolt_modal_sheet` ^0.11.0 (modal del selector de categoría, solo si se hace el bonus 5.2; Flutter ≥ 3.16, sin dependencias; su último release es de febrero de 2025). Ninguna usa generador, así que no choca con `analyzer`. Hay que justificarlas en el README, y `wolt_modal_sheet` se verifica con un `pub get` real al empezar la 5.2.

### UX Design Requirements

UX-DR1: Tokens de color de `DESIGN.md` (primary `#006A60`, background `#FBFDFA`, surface, surface-tonal `#EDF3F0`, on-surface, on-surface-muted, outline, divider, focus `#0B57D0`, danger `#B3261E`, star `#8A5A00`, placeholder, skeleton) aplicados en Flutter (`ThemeData`/`ColorScheme`) y, en Angular, como tokens `@theme` de Tailwind (decisión de Mauri, en lugar de variables CSS propias). Solo tema claro.
UX-DR2: Tipografía Roboto (title-lg 22/28, title-md 16/24, body-md 14/20, label-md 12/16, price 16/24 peso 600) en ambas apps, con fuentes del sistema como respaldo en Angular.
UX-DR3: Escala de espaciado 4/8/16/24, área táctil mínima 48 px, miniatura 56 px, AppBar 64 px; radios sm 8, md 12, lg 16, full 9999.
UX-DR4: Componente `app-bar` con título, flecha atrás cuando aplica y carrito con badge; superficie tonal.
UX-DR5: Badge del contador de unidades: oculto con 0 unidades (el ícono sigue visible), "99+" pasadas 99; presente en Catalog, detalle y Cart; texto de contador "Carrito vacío" / "1 unidad" / "{n} unidades".
UX-DR6: `search-field` en píldora tonal con ícono de lupa, placeholder "Buscar productos" y sin ícono de filtros; el término y los resultados sobreviven al paso por el detalle.
UX-DR7: `list-item` de producto: miniatura, título de una línea con elipsis, precio y `★ rating` (solo el valor, sin conteo); sin botón por ítem; toda la fila abre el detalle.
UX-DR8: `image-placeholder` "Sin foto" (bloque `placeholder` con ícono de imagen) en lista, detalle y carrito.
UX-DR9: Detalle: `button-primary` "Agregar al carrito" a ancho completo fijo al pie, con separación superior sutil; sin selector de cantidad, chips, carrusel ni categoría; toast breve "Agregado al carrito" con `toastification` (decisión de Mauri, sustituye al `SnackBar` de `EXPERIENCE.md`).
UX-DR10: `cart-item`: miniatura 56 px, título, precio unitario, controles −/+ de 48 px ("−" atenuado y deshabilitado en cantidad 1) y "Quitar" separado (`button-text-danger`) sin diálogo de confirmación.
UX-DR11: `cart-footer` fijo con unidades y "Total {importe}"; carrito vacío muestra "Tu carrito está vacío" y no hay pie con total.
UX-DR12: Estados de Catálogo/búsqueda/detalle: indicador o skeleton centrado al cargar; vacío "No hay productos" o `Sin resultados para "{término}"` (nunca lista en blanco); error con mensaje y `button-tonal` "Reintentar".
UX-DR13: Textos de error derivados de `BaseException.code`/`OrdersService` (conexión, respuesta no exitosa, producto inexistente/`id` inválido, parseo) con la tabla de `EXPERIENCE.md`; tuteo, sin signos de exclamación; el widget no escribe el mensaje.
UX-DR14: Pie de lista de paginación (DF-1 en MVP): indicador mientras carga la página, mensaje + "Reintentar" si falla conservando la lista, "No hay más productos" cuando `skip + 20 >= total`, nuevo término reinicia `skip = 0`, scroll se conserva al volver del detalle; disparo a ~200 px del final.
UX-DR15: Importes en ambas apps con punto decimal, 2 decimales, sin separador de miles ni símbolo de moneda.
UX-DR16: Pantalla de error para ruta desconocida (`errorBuilder`) con botón para volver a `/`; `id` no numérico o inexistente cae al estado de error "No encontramos ese producto."
UX-DR17: `order-card` (Angular, `surface-tonal`, radio lg): id, `userId`, total y, solo si existe, total con descuento; `button-tonal` "Ver detalle" con `aria-label="Ver detalle de la orden {id}"`; como el detalle es una ruta (resolución 1), no aplican `aria-expanded` ni `aria-controls`.
UX-DR18: Tabla de productos de la orden (Título, Cantidad, Precio unitario) en la página `/orders/:id` (sin "Ocultar detalle", resolución 1); "Esta orden no tiene productos" si está vacía; ids reales de DummyJSON.
UX-DR19: Filtro "Total mínimo" (campo numérico con `label` asociado): `total >= mínimo`, vacío o no numérico (incluida coma decimal) = todas; deshabilitado mientras carga o si la carga falló; sin coincidencias "Ninguna orden alcanza ese total".
UX-DR20: Panel Angular: rejilla de 2 columnas desde 1024 px con ancho máximo centrado y separación 16 px; 1 columna por debajo (red de seguridad).
UX-DR21: Accesibilidad Flutter: `Semantics` en el ícono del carrito ("Carrito, 3 unidades"), en −/+ ("Disminuir/Aumentar cantidad de {producto}") y `semanticLabel` en imágenes.
UX-DR22: Accesibilidad Angular: foco visible `focus` en todo control, navegación por teclado, botones reales, región `aria-live="polite"` para cambios de lista y errores; el estado nunca solo por color; contraste AA.
UX-DR23: Movimiento: transiciones por defecto de Material, sin animaciones propias; respeta "reducir movimiento".
UX-DR24: Exclusiones transversales del mock de Stitch (no implementar): barra inferior, menú, hamburguesa, banners de envío, cupones, subtotales, sellos de pago, favoritos, reseñas, chips de categoría, "Tramitar pedido", íconos de filtros, "Vaciar carrito", "Gestión de Órdenes · Historial · Reportes".

### FR Coverage Map

FR1: Epic 1 - Listar el Catalog
FR2: Epic 1 - Estados del Catalog
FR3: Epic 1 - Búsqueda con debounce
FR4: Epic 2 - Detalle por `id`
FR5: Epic 2 - Estados del detalle
FR6: Epic 3 - Agregar al Cart
FR7: Epic 3 - Cambiar cantidad
FR8: Epic 3 - Quitar Cart item
FR9: Epic 3 - Total y contador
FR10: Epic 1 - Acceso a datos vía Repository
FR11: Epic 1 - Modelos inmutables con `fromJson`
FR12: Epic 1 - Errores tipados hacia la UI
FR13: Epic 4 - Listar Orders
FR14: Epic 4 - Filtro por total mínimo
FR15: Epic 4 - Estados de carga y error del panel
FR16: Epic 4 - Detalle de Order (`/orders/:id` lazy)
FR17: Epic 4 - Sin fugas de memoria
FR18: Aviso en Epic 5 (lo redacta Mauri, sin story de dev) - Respuestas Parte 1
FR19: Aviso en Epic 5 (lo redacta Mauri, sin story de dev) - Code review Parte 4
FR20: Epic 5 (story 5.1) - README
FR21: Epic 1 (estructura y `.gitignore` del repo) y Epic 5 (cierre de historial); las reglas de ramas y commits aplican a todas las stories

NFR1..NFR9 son transversales: se llevan como criterios de aceptación y definition of done de cada story (analyze limpio, tests mínimos, Conventional Commits).

## Epic List

### Epic 1: Explorar el catálogo (Flutter)
Lucía abre la app y ve los Products, los busca con debounce y sigue cargando más al hacer scroll, con estados claros ante carga, vacío y error.
**FRs covered:** FR1, FR2, FR3, FR10, FR11, FR12, FR21 (estructura y `.gitignore`)
**Notas:** scaffold Flutter (paso 0 `flutter upgrade`), `core/` (Dio, Errors, CancelSignal), tema (UX-DR1..3), shell con `GoRouter` mínimo, `features/products`, búsqueda y paginación infinita. Gate Stitch: Catálogo.

### Epic 2: Ver el detalle de un producto (Flutter)
Lucía abre un Product por `id`, también desde un deep link, y ve su detalle con estados de carga y error.
**FRs covered:** FR4, FR5
**Notas:** provider `family`, rutas `/product/:id` y `errorBuilder`, deep link Android (AD-9) verificado con `adb`. El botón "Agregar" queda inactivo hasta el Epic 3. Gate Stitch: Detalle.

### Epic 3: Armar el carrito (Flutter)
Lucía agrega Products, cambia cantidades, quita ítems y ve total y contador desde cualquier pantalla.
**FRs covered:** FR6, FR7, FR8, FR9
**Notas:** lógica pura en `cart/domain`, Notifier `keepAlive`, badge del AppBar, pantalla `/cart`. Gate Stitch: Carrito.

### Epic 4: Panel de órdenes (Angular)
Lucía ve las Orders, filtra por total mínimo y abre el detalle de una, con estados de carga y error.
**FRs covered:** FR13, FR14, FR15, FR16, FR17 (y DA-1)
**Notas:** scaffold Angular, `Errors`, `OrdersService` con `Schema`/`Result`, store manual (sin NgRx, `@ngrx/*` instalado sin uso), filtro, tarjeta presentacional, ruta lazy `/orders/:id`. Aplica DA-2, DA-3 y DA-5. Gate Stitch: Órdenes.

### Epic 5: Verificación del MVP y bonus
El evaluador clona el repo, ejecuta ambas apps y comprueba que cumplen lo pedido; después se suman los bonus elegidos (DF-2, DF-3, B-1, B-2), solo con el MVP verificado.
**FRs covered:** FR20 (y cierre de FR21); FR18 y FR19 quedan como aviso para que Mauri redacte `RESPUESTAS.md`, sin story de dev.
**Notas:** story 5.1 de verificación (README final, clon limpio, historial, SM-1..SM-7); stories 5.2 a 5.5 de bonus en el orden del PRD §6.2 (DF-2, DF-3, B-1, B-2).

## Epic 1: Explorar el catálogo (Flutter)

Lucía abre la app y ve los Products, los busca con debounce y sigue cargando más al hacer scroll, con estados claros ante carga, vacío y error.

### Story 1.1: Repo base y app Flutter que arranca

As a Evaluador,
I want clonar el repo, seguir el README y ver la app Flutter corriendo en un emulador Android,
So that pueda revisar la entrega sobre una base ordenada, reproducible y con historial real.

**Acceptance Criteria:**

**Given** la rama `chore/e1-s1-flutter-scaffold` creada desde `main`
**When** se completa la story
**Then** la rama se fusiona a `main` con commits en Conventional Commits en inglés (scope `repo` o `flutter`)
**And** no existe un único commit con todo el trabajo (FR21, AD-13)

**Given** el repo en la raíz
**When** se lista su contenido
**Then** existe la carpeta `flutter_app/` creada con `flutter create`, y `angular_app/` aún no hace falta
**And** el `.gitignore` de la raíz excluye el PDF de la prueba y no hay rastro del PDF en el historial (FR21, AD-1)
**And** `flutter_app/pubspec.lock` está commiteado (AD-1)

**Given** una máquina con Flutter instalado
**When** se ejecuta el paso 0 del scaffold (`flutter upgrade`) y luego `flutter --version`
**Then** Dart es ≥ 3.13 (AD-14)
**And** las versiones resultantes de Flutter y Dart quedan anotadas en el README o en el spine, según el Stack

**Given** `flutter_app/pubspec.yaml`
**When** se instalan las dependencias con `flutter pub get`
**Then** resuelve sin conflictos con `flutter_riverpod`, `riverpod_annotation`, `go_router`, `riverpod_generator`, `build_runner` y `very_good_analysis`
**And** si `build_runner` o la compatibilidad de versiones consume más de 2 h sin avanzar, se aplica el plan B del PRD §8 y se documenta

**Given** `analysis_options.yaml` con `very_good_analysis`
**When** se ejecuta `dart format --set-exit-if-changed .` y `flutter analyze`
**Then** ambos terminan sin cambios ni warnings (NFR2, AD-13)

**Given** `android/app/src/main/AndroidManifest.xml` (el principal, no el de debug)
**When** se inspecciona
**Then** declara el permiso `android.permission.INTERNET` (AD-14)

**Given** la estructura de `lib/`
**When** se inspecciona
**Then** existen `core/`, `presentation/` y `features/` según el Structural Seed del spine
**And** los nombres de archivos están en `snake_case` y los identificadores en inglés (NFR9)

**Given** el tema de la app
**When** se inspecciona `ThemeData`/`ColorScheme`
**Then** usa los tokens de `DESIGN.md` (primary `#006A60`, background `#FBFDFA`, surface-tonal `#EDF3F0`, focus `#0B57D0`, danger `#B3261E` y demás) (UX-DR1)
**And** usa Roboto con la escala de `DESIGN.md` (UX-DR2) y la escala de espaciado y radios (UX-DR3)
**And** solo hay tema claro
**And** los valores de color y espaciado son constantes con nombre, sin valores mágicos (NFR5)

**Given** el shell de la app (`presentation/`)
**When** se ejecuta `flutter run` en un emulador Android
**Then** la app arranca con `MaterialApp.router` y un único `GoRouter` creado una sola vez, sin provider (AD-8)
**And** la ruta `/` muestra el AppBar con el título "Mini Catálogo" sobre `surface-tonal` y un cuerpo provisional
**And** el cuerpo provisional se reemplaza en la story 1.3, sin dejar código muerto ni `print` (NFR5)

**Given** el `ProviderScope` raíz
**When** se inspecciona
**Then** desactiva el reintento automático de Riverpod 3 con `retry: (_, __) => null` (AD-5)

**Given** las transiciones de navegación y de componentes de la app
**When** se inspecciona el código
**Then** se usan las transiciones por defecto de Material, sin animaciones propias (UX-DR23)
**And** no se desactiva ni se sobrescribe el comportamiento de "reducir movimiento" del sistema (UX-DR23)

**Given** un test de widget mínimo
**When** se ejecuta `flutter test`
**Then** el shell se monta con el `ProviderScope` y muestra el título "Mini Catálogo" (NFR3)

**Given** la story de UI
**When** se actualiza `stitch-index.md`
**Then** la columna "Story" de Catálogo queda en `1.3`, y esta story anota que solo prepara el shell y el tema

**Given** el README en la raíz
**When** se lee tras esta story
**Then** contiene al menos los comandos para ejecutar `flutter_app/` desde un clon limpio (NFR8); el resto del README queda para el Epic 5

### Story 1.2: Capa de datos y errores tipados

As a Evaluador,
I want que toda obtención de Products pase por un Repository inyectado y que las fallas lleguen como errores tipados,
So that la UI nunca vea excepciones crudas de `dio` y yo pueda probar el flujo sin red.

**Acceptance Criteria:**

**Given** la rama `feat/e1-s2-data-layer` desde `main`
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `flutter`)
**And** corre `dart format`, `flutter analyze` sin warnings y `flutter test` (AD-13, NFR2)

**Given** `core/errors/`
**When** se inspecciona
**Then** existe `BaseException(message, code)` con las subclases `NetworkException`, `ServerException(status)` y `ParseException`, y el contenedor `Errors` con la lista de excepciones (FR12, AD-4, T-1)
**And** no existen `toPrimitives`, `CommonResponse` ni `CommonError` (T-1)
**And** una extensión propia `getOrThrow()` sobre `Either<Errors, T>` vive en `core/`, porque `fpdart` no la trae

**Given** `core/`
**When** se inspecciona el cliente HTTP
**Then** existe un único `Dio`, con la URL base de DummyJSON como constante y `connectTimeout` y `receiveTimeout` de 10 s como constantes (AD-3)
**And** su provider lleva `keepAlive: true` (AD-5)
**And** existe un `CancelSignal` propio que los métodos del Repository aceptan como parámetro opcional (AD-3)

**Given** `features/products/domain/`
**When** se inspecciona
**Then** `Product` es un modelo `freezed` inmutable con `fromJson` (id, título, precio, rating, imagen) y no tiene campos mutables (FR11, T-4)
**And** existe `Page<Product>` con los items y el `total` de la API
**And** el contrato `ProductRepository` expone `list` y `search` con `limit` y `skip` (por defecto 20 y 0) y devuelve `Future<Either<Errors, Page<Product>>>` (FR10, AD-3)
**And** `domain/` solo importa `core/errors`, `fpdart`, `freezed_annotation` y `json_annotation` (AD-2)

**Given** `features/products/data/`
**When** se inspecciona la implementación
**Then** es el único lugar que captura `DioException` (AD-3)
**And** timeouts y fallos de conexión producen `NetworkException`, una respuesta no exitosa produce `ServerException(status)`, y un JSON inválido produce `ParseException`
**And** una petición cancelada con `CancelSignal` no se reporta como error
**And** `productRepositoryProvider` se declara aquí con `keepAlive`, y es la única importación de `data` permitida desde `presentation` (AD-2, AD-5)

**Given** una respuesta real de ejemplo de DummyJSON para `GET /products?limit=20&skip=0`
**When** `Product.fromJson` la procesa
**Then** conserva id, título, precio, rating e imagen sin pérdida (FR11)

**Given** un JSON con un campo requerido ausente o de tipo erróneo
**When** el Repository lo parsea
**Then** devuelve `Left(Errors)` con una `ParseException`, y no un error genérico (FR11, FR12)

**Given** un Repository falso (`mocktail`) inyectado con un `override` del provider
**When** se leen los datos desde un `ProviderContainer`
**Then** los datos mostrados cambian sin tocar ninguna UI (FR10)
**And** el `ProviderContainer` de test desactiva el reintento con `retry: (_, __) => null` (AD-5)

**Given** las pruebas unitarias de esta story
**When** se ejecuta `flutter test`
**Then** hay al menos 2 que pasan: el parseo de `Product` (feliz y con campo ausente) y el mapeo de `DioException` a cada subclase de `BaseException` (aportan a NFR3)

**Given** el README
**When** se actualiza
**Then** incluye una nota inicial que justifica la forma de construir los modelos con `freezed` (T-4) y los archivos generados (`*.g.dart`, `*.freezed.dart`) commiteados y regenerados antes de cada commit (AD-13)

### Story 1.3: Ver el Catalog con sus estados

As a Usuario (Lucía),
I want ver al abrir la app la lista de Products con imagen, título, precio y rating, y entender siempre en qué estado está,
So that pueda explorar el catálogo y recuperarme si falla la red.

**Acceptance Criteria:**

**Given** la rama `feat/e1-s3-catalog-list` desde `main`
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `flutter`)
**And** corre `dart format`, `flutter analyze` sin warnings y `flutter test` (AD-13, NFR2)
**And** la story cita la pantalla Catálogo (`0d762685…`) de `stitch-index.md` y completa su columna "Story" con `1.3` (gate de UI)

**Given** la app recién abierta con red
**When** se muestra `/`
**Then** `catalogProvider` (autoDispose, generado con `riverpod_generator`) consulta `GET /products?limit=20&skip=0` y muestra los primeros 20 Products (FR1)
**And** el estado del provider es `items`, `total` y `loadMore` (`AsyncValue<void>`, `AsyncData(null)` en reposo), sin banderas booleanas sueltas (AD-6)
**And** la carga inicial desenvuelve el `Either` con `getOrThrow()` dentro de `build()` y Riverpod la guarda como `AsyncError(Errors)` (AD-4)

**Given** la lista de Products
**When** se renderiza cada elemento
**Then** muestra miniatura de 56 px, título en una sola línea con elipsis, precio con dos decimales y sin símbolo, y `★ rating` sin conteo (FR1, UX-DR7, UX-DR15)
**And** toda la fila es táctil, sin botón de agregar por ítem (UX-DR7)
**And** el rating usa el color `star` y el resto los tokens de `DESIGN.md`
**And** las imágenes llevan `semanticLabel` con el título (UX-DR21)

**Given** un Product sin imagen o con imagen que falla al cargar
**When** se renderiza
**Then** se muestra el marcador "Sin foto" (bloque `placeholder` con ícono de imagen), no un error (FR1, UX-DR8)

**Given** la consulta en curso
**When** el estado es `AsyncLoading`
**Then** se muestra un indicador de progreso centrado o un skeleton (FR2, UX-DR12)

**Given** una consulta que devuelve cero Products
**When** el Catalog recibe `items` vacío
**Then** se muestra el texto "No hay productos" y no una lista en blanco (FR2, UX-DR12)

**Given** una falla de red, una respuesta no exitosa o un JSON inválido
**When** el estado es `AsyncError`
**Then** se muestra el mensaje derivado del `Errors` según la tabla de `EXPERIENCE.md` (conexión, respuesta no exitosa, parseo) y un `button-tonal` "Reintentar" (FR2, UX-DR13)
**And** el widget no construye el texto: lo obtiene del `code` de la `BaseException`; un error que no sea `Errors` muestra el mensaje genérico (AD-4)
**And** "Reintentar" ejecuta `ref.invalidate(catalogProvider)` y vuelve al estado de carga (AD-6)

**Given** el código de los widgets
**When** se revisa
**Then** `ref.watch` se usa en `build` y `ref.read` solo en callbacks; los widgets son pequeños, usan `const` donde corresponde y no contienen lógica de negocio (NFR5)
**And** ni `presentation` ni `domain` importan `dio` y solo se importa `productRepositoryProvider` desde `data` (AD-2)
**And** el AppBar de la story 1.1 se conserva y el cuerpo provisional se reemplaza por el Catalog, sin código muerto

**Given** la prueba de widget de esta story, con un Repository falso (`mocktail`) por `override`
**When** se ejecuta `flutter test`
**Then** pasa al menos una prueba que verifica los estados de datos, vacío y error con "Reintentar" (NFR3)
**And** el estado vacío se prueba así porque DummyJSON no devuelve listas vacías sin búsqueda (nota de FR2)

### Story 1.4: Buscar productos con debounce

As a Usuario (Lucía),
I want escribir un término y ver solo los Products que coinciden, sin que se dispare una consulta por cada tecla,
So that encuentre lo que busco rápido y sin saturar la API.

**Acceptance Criteria:**

**Given** la rama `feat/e1-s4-search-debounce` desde `main`
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `flutter`)
**And** corre `dart format`, `flutter analyze` sin warnings y `flutter test` (AD-13, NFR2)
**And** cita la pantalla Catálogo (`0d762685…`) de `stitch-index.md` (gate de UI)

**Given** el Catalog de la story 1.3
**When** se muestra el AppBar o la cabecera de la lista
**Then** aparece un `search-field` en píldora sobre `surface-tonal`, con ícono de lupa, placeholder "Buscar productos", altura de 48 px y sin ícono de filtros (UX-DR6)

**Given** `searchTerm`
**When** se inspecciona su provider
**Then** es un `Notifier<String>` síncrono con `keepAlive` y no hace red (AD-5, AD-6)
**And** el término y los resultados sobreviven al paso por otra pantalla y al volver (UX-DR6)

**Given** `debouncedTerm`
**When** se inspecciona
**Then** es un `StreamProvider` con `stream_transform` que emite `''` al inicio sin debounce (AD-6)
**And** un término vacío tras `trim` se emite de inmediato, y uno no vacío solo tras 400 ms sin cambios (FR3)
**And** el 400 ms es una constante con nombre (NFR5)

**Given** el Usuario escribe 5 caracteres con menos de 400 ms entre ellos
**When** pasan 400 ms sin nuevas pulsaciones
**Then** se dispara una sola consulta `GET /products/search?q=…&limit=20&skip=0` con el término recortado (FR3)

**Given** `catalogProvider`
**When** cambia `debouncedTerm`
**Then** lo observa con `select((a) => a.value ?? '')` y elige entre listar y buscar con el mismo mecanismo de estados, sin duplicar lógica (AD-6, FR3)
**And** la búsqueda muestra los mismos cuatro estados que el Catalog: cargando, datos, vacío y error (FR3, FR2)

**Given** un Search term vacío o solo con espacios
**When** el Usuario lo envía o lo borra
**Then** vuelve a mostrarse el Catalog completo (FR3)
**And** cualquier consulta pendiente se cancela con el `CancelSignal` en `ref.onDispose` (AD-6)

**Given** una respuesta que llega para un Search term ya reemplazado
**When** vuelve a `catalogProvider`
**Then** se descarta y no pisa la lista, gracias al contador de época que se incrementa en cada `build()` (FR3, AD-6)

**Given** una búsqueda sin coincidencias
**When** la API devuelve cero Products
**Then** se muestra `Sin resultados para "{término}"` y no una lista en blanco (UX-DR12)
**And** sin término y sin Products se sigue mostrando "No hay productos" (story 1.3)

**Given** una búsqueda que falla
**When** el estado es `AsyncError`
**Then** "Reintentar" ejecuta `ref.invalidate(catalogProvider)` y repite la consulta del Search term vigente (FR3, AD-6)

**Given** el `searchTerm` y `debouncedTerm`
**When** se revisa la UI
**Then** los widgets leen con `ref.watch` en `build` y escriben el término con `ref.read` solo en el callback del campo (NFR5, AD-5)
**And** los notifiers no navegan ni muestran UI (AD-5)

**Given** las pruebas unitarias de esta story
**When** se ejecuta `flutter test`
**Then** pasa al menos una que verifica con `fake_async` (o un `Timer` controlado) que 5 pulsaciones rápidas producen una sola consulta al Repository falso, y que el descarte por época ignora una respuesta tardía (aporta a NFR3)

### Story 1.5: Cargar más productos al hacer scroll

As a Usuario (Lucía),
I want que al llegar al final de la lista se carguen más Products, tanto en el Catalog como en la búsqueda,
So that pueda recorrer todo el catálogo sin perder lo que ya veo, aunque una página falle.

**Acceptance Criteria:**

**Given** la rama `feat/e1-s5-infinite-scroll` desde `main`
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `flutter`)
**And** corre `dart format`, `flutter analyze` sin warnings y `flutter test` (AD-13, NFR2)
**And** cita la pantalla Catálogo (`0d762685…`) de `stitch-index.md` (gate de UI)

**Given** el estado del Catalog con más Products por cargar
**When** el `ScrollController` de la UI llega a unos 200 px del final de la lista
**Then** se llama a `loadMore()` y se pide la página siguiente con `skip = items.length` y `limit = 20` (AD-6, UX-DR14)
**And** hay más páginas mientras `items.length < total`
**And** el umbral de 200 px es una constante con nombre (NFR5)

**Given** una página en vuelo
**When** `loadMore.isLoading` es verdadero
**Then** `loadMore()` se ignora y nunca hay más de una petición en vuelo (AD-6, UX-DR14)

**Given** `loadMore()` en curso
**When** el estado es `AsyncLoading`
**Then** el pie de la lista muestra un indicador de progreso y la lista ya cargada se conserva (UX-DR14)

**Given** una página que se carga bien
**When** llegan los Products
**Then** se añaden a `items` creando una nueva lista, sin mutar la anterior (NFR5, AD-5)
**And** `loadMore` vuelve a `AsyncData(null)`

**Given** una página que falla
**When** el Repository devuelve `Left(Errors)`
**Then** el notifier hace `fold` y escribe el error en `loadMore` como `AsyncError(Errors)`, sin `AsyncValue.guard` y sin reemplazar la lista (AD-4, AD-6)
**And** el pie muestra el mensaje derivado del `Errors` y un botón "Reintentar" que vuelve a llamar a `loadMore()`, y no a `ref.invalidate` (AD-6, UX-DR13, UX-DR14)

**Given** `items.length >= total`
**When** el Usuario llega al final de la lista
**Then** el pie muestra "No hay más productos" y no se piden más páginas (UX-DR14)

**Given** el Usuario cambia o vacía el Search term mientras hay una página pendiente
**When** `catalogProvider` hace `build()` de nuevo
**Then** `skip` vuelve a 0 y se descartan las páginas pendientes del término anterior mediante el contador de época y el `CancelSignal` (AD-6, UX-DR14)

**Given** la paginación sobre la búsqueda
**When** hay un Search term vigente
**Then** `loadMore()` usa `search` con el mismo término y `limit`/`skip`, con el mismo mecanismo que el listado (FR3, AD-6)

**Given** las pruebas unitarias de esta story, con un Repository falso (`mocktail`)
**When** se ejecuta `flutter test`
**Then** pasa al menos una que verifica que `loadMore` añade la página con `skip = items.length`, otra que verifica que un fallo conserva la lista y deja `loadMore` en `AsyncError`, y otra que verifica que no se piden páginas cuando `items.length >= total` (aportan a NFR3)

## Epic 2: Ver el detalle de un producto (Flutter)

Lucía abre un Product por `id`, también desde un deep link, y ve su detalle con estados de carga y error.

### Story 2.1: Abrir y ver el detalle de un producto

As a Usuario (Lucía),
I want tocar un Product del Catalog y ver su detalle cargado por `id`, con un estado claro si algo falla,
So that pueda decidir si lo agrego al carrito, sin depender de los datos de la lista.

**Acceptance Criteria:**

**Given** la rama `feat/e2-s1-product-detail` desde `main`
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `flutter`)
**And** corre `dart format`, `flutter analyze` sin warnings y `flutter test` (AD-13, NFR2)
**And** cita la pantalla Detalle (`b0e799e0…`) de `stitch-index.md` y completa su columna "Story" con `2.1` (gate de UI)

**Given** el `GoRouter` del shell
**When** se inspecciona
**Then** declara las rutas `/` y `/product/:id` y sigue siendo único, creado una vez y sin provider (AD-8)
**And** el `id` se parsea a `int` una sola vez en la ruta, y uno no numérico (`/product/abc`) va a la pantalla de error "No encontramos ese producto." (AD-8, UX-DR13, UX-DR16)
**And** la ruta funciona con solo la URL, sin `extra` ni estado previo (AD-8)

**Given** el Catalog
**When** el Usuario toca un Product
**Then** navega con `context.push('/product/{id}')`, de modo que el Catalog sigue en la pila (AD-8)
**And** al volver atrás, el Catalog conserva el término de búsqueda, los resultados y la posición de scroll (UX-DR6, UX-DR14)

**Given** la pantalla de detalle
**When** se inspecciona su constructor
**Then** recibe únicamente el `id` y no el Product (FR4)
**And** consulta `GET /products/{id}` con un provider `family` generado, y nunca reutiliza los datos del Catalog (FR4, AD-7)
**And** el provider usa `productRepositoryProvider`, sin importar `dio` y sin duplicar `Product` ni el Repository (AD-2, AD-3)
**And** es autoDispose y toma `getOrThrow()` dentro de `build()` (AD-4, AD-5)

**Given** el detalle cargado
**When** se renderiza
**Then** muestra imagen, título, precio con dos decimales y sin símbolo, `★ rating` y el botón "Agregar al carrito" (FR4, UX-DR15)
**And** el botón es un `button-primary` de ancho completo, fijo al pie, con separación superior sutil, sin selector de cantidad, chips, carrusel ni categoría (UX-DR9)
**And** el botón aparece inactivo (`onPressed: null`) hasta el Epic 3, sin lógica de Cart (AD-2)
**And** una imagen faltante muestra "Sin foto" (UX-DR8) y las imágenes llevan `semanticLabel` con el título (UX-DR21)

**Given** dos detalles abiertos con `id` distintos
**When** se navega entre ellos
**Then** cada `id` tiene su propio estado y no se mezclan datos (FR4)

**Given** la consulta en curso
**When** el estado es `AsyncLoading`
**Then** se muestra un indicador de progreso centrado (FR5, UX-DR12)

**Given** una falla de red, una respuesta no exitosa o un JSON inválido
**When** el estado es `AsyncError`
**Then** se muestra el mensaje derivado del `Errors` y un `button-tonal` "Reintentar" (FR5, UX-DR12, UX-DR13)
**And** "Reintentar" ejecuta `ref.invalidate` sobre el provider del `id` y vuelve a cargar (FR5)

**Given** un `id` inexistente (404)
**When** el estado es `AsyncError`
**Then** la capa de datos lo expresa como `NotFoundException` y se muestra "No encontramos ese producto." y no el texto genérico de respuesta no exitosa (UX-DR13)
**And** en lugar de "Reintentar" se ofrece un `button-tonal` "Volver al catálogo" que navega a `/`, porque reintentar no puede cambiar el resultado (FR5, UX-DR13)

**Given** una ruta desconocida
**When** el `errorBuilder` del router la recibe
**Then** muestra una pantalla de error con un botón que vuelve a `/` (UX-DR16, AD-8)

**Given** el botón atrás del detalle
**When** el Usuario lo pulsa
**Then** ejecuta `context.canPop() ? context.pop() : context.go('/')` (AD-8)

**Given** el AppBar del detalle
**When** se muestra
**Then** lleva la flecha atrás y el título, sobre `surface-tonal` (UX-DR4)
**And** el badge del carrito se añade en el Epic 3

**Given** el código de los widgets
**When** se revisa
**Then** `ref.watch` se usa en `build` y `ref.read` solo en callbacks, los widgets son pequeños y con `const`, y no hay lógica de negocio (NFR5)

**Given** la prueba de widget de esta story, con un Repository falso (`mocktail`) por `override`
**When** se ejecuta `flutter test`
**Then** pasa al menos una que verifica los estados de datos y error con "Reintentar" para un `id`, y otra que verifica que un 404 muestra "No encontramos ese producto." con "Volver al catálogo" y sin "Reintentar" (NFR3)

### Story 2.2: Abrir un producto desde un deep link

As a Evaluador (Lucía),
I want abrir la app directamente en el detalle de un Product con un enlace `gmariposa://app/product/{id}`,
So that compruebe que las rutas funcionan con solo la URL y que el deep link de Android está probado, no solo declarado.

**Acceptance Criteria:**

**Given** la rama `feat/e2-s2-deep-link` desde `main`
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `flutter` o `docs`)
**And** corre `dart format`, `flutter analyze` sin warnings y `flutter test` (AD-13, NFR2)

**Given** `android/app/src/main/AndroidManifest.xml`
**When** se inspecciona la `activity` principal
**Then** declara un `intent-filter` con acción `android.intent.action.VIEW`, categorías `DEFAULT` y `BROWSABLE`, y datos `scheme="gmariposa"` y `host="app"` (AD-9)
**And** el permiso `INTERNET` de la story 1.1 se mantiene en el manifiesto principal (AD-14)

**Given** la app instalada en un emulador Android, cerrada
**When** se ejecuta `adb shell am start -a android.intent.action.VIEW -d "gmariposa://app/product/5"`
**Then** la app abre el detalle del Product con `id` 5, cargado por su propia consulta (AD-9, FR4)
**And** al pulsar atrás, el botón usa `canPop() ? pop() : go('/')` y como no hay pila llega a `/` (AD-8)

**Given** la app ya abierta en el Catalog
**When** se ejecuta el mismo comando `adb`
**Then** se muestra el detalle del `id` indicado y la navegación atrás respeta la pila (AD-8)

**Given** un enlace con un `id` inválido o inexistente, como `gmariposa://app/product/abc` o `gmariposa://app/product/99999`
**When** se abre con `adb`
**Then** `abc` va a la pantalla "No encontramos ese producto." y `99999` muestra el error con "Reintentar", sin excepción cruda (FR5, UX-DR13, UX-DR16)

**Given** un enlace con una ruta desconocida, como `gmariposa://app/otra`
**When** se abre con `adb`
**Then** el `errorBuilder` muestra la pantalla de error con el botón para volver a `/` (UX-DR16)

**Given** el resultado de la verificación
**When** se cierra la story
**Then** quedan anotados, para el README del Epic 5, el comando exacto, el emulador usado, la versión de Android y el resultado observado de cada caso (AD-9, FR20)
**And** si el emulador o `adb` no están disponibles, el deep link se documenta como no verificado y no como logrado

**Given** el router
**When** se revisa tras esta story
**Then** sigue siendo un único `GoRouter` sin provider y no se añadieron rutas ni código de navegación nuevos para el deep link: `go_router` resuelve la URL con las rutas de la story 2.1 (AD-8)

## Epic 3: Armar el carrito (Flutter)

Lucía agrega Products, cambia cantidades, quita ítems y ve el total y el contador desde cualquier pantalla.

### Story 3.1: Agregar productos al carrito desde el detalle

As a Usuario (Lucía),
I want agregar el Product que estoy viendo al carrito,
So that vaya armando mi compra y el carrito conserve lo agregado mientras navego.

**Acceptance Criteria:**

**Given** la rama `feat/e3-s1-cart-add` desde `main`
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `flutter`)
**And** corre `dart format`, `flutter analyze` sin warnings y `flutter test` (AD-13, NFR2)
**And** cita la pantalla Detalle (`b0e799e0…`) de `stitch-index.md` y añade `3.1` a su columna "Story" (gate de UI)

**Given** `features/cart/domain/`
**When** se inspecciona
**Then** `CartItem { Product product, int quantity }` se define una sola vez, inmutable (`freezed`) (AD-7, FR11)
**And** `domain/` solo importa `products/domain` y las librerías permitidas, sin Flutter ni Riverpod (AD-2)

**Given** las funciones puras del Cart en `cart/domain/`
**When** se inspeccionan
**Then** existen agregar, aumentar, disminuir, quitar, total y unidades, todas sin estado ni dependencias de UI (AD-7)
**And** cada una devuelve una nueva lista y nunca muta la recibida (NFR5)
**And** el total es la suma de precio × cantidad en `double`, sin redondear (AD-7)
**And** las unidades son la suma de las cantidades, no la cantidad de ítems distintos (FR9)

**Given** un Product que no está en el Cart
**When** se agrega
**Then** se crea un Cart item con cantidad 1 (FR6)

**Given** un Product que ya está en el Cart
**When** se agrega de nuevo
**Then** la cantidad de su Cart item sube en 1 y no se crea un duplicado (FR6)

**Given** un Cart item con cantidad 1
**When** se disminuye
**Then** la cantidad se queda en 1 y el ítem no se elimina; para eliminarlo se usa quitar (FR7)
**And** con cantidad mayor que 1, aumentar suma 1 y disminuir resta 1 (FR7)

**Given** un Cart item
**When** se quita
**Then** desaparece de la lista, y quitar el último deja una lista vacía (FR8)

**Given** el Notifier del Cart en `cart/presentation/`
**When** se inspecciona
**Then** es un `Notifier` generado con `riverpod_generator` y `keepAlive: true`, y es el único dueño del estado (AD-5, AD-7, NFR1)
**And** su estado es la lista inmutable de `CartItem` y delega toda la lógica en las funciones puras
**And** el Cart se conserva al navegar entre pantallas y al volver al Catalog (UX-DR6, AD-7)
**And** no navega ni muestra UI (AD-5)

**Given** el detalle de la story 2.1 con el botón inactivo
**When** se completa esta story
**Then** "Agregar al carrito" queda activo y llama al Notifier con `ref.read` en el callback (NFR5, AD-5)
**And** `product_detail/presentation` importa `cart/presentation` solo para este botón, como permite AD-2
**And** al pulsarlo aparece un toast breve "Agregado al carrito" con `toastification`, y no un `SnackBar` (UX-DR9, decisión de Mauri)
**And** `toastification` se añade a `pubspec.yaml` en esta story, y el shell envuelve el `MaterialApp.router` con `ToastificationWrapper`, de modo que el toast se muestra con `toastification.show(...)` desde el callback del botón sin pasar por un provider ni por el Notifier (AD-5, AD-8)
**And** el toast usa los tokens de `DESIGN.md`, dura unos 2 a 3 segundos, no se acumula si se pulsa varias veces seguidas y respeta "reducir movimiento" (UX-DR23)
**And** al empezar la story se actualizan `EXPERIENCE.md` (Component Patterns, "Agregar al carrito") y `DESIGN.md` para decir "toast" donde decían `SnackBar`, y el README justifica la dependencia
**And** el botón sigue siendo `button-primary` de ancho completo fijo al pie, sin selector de cantidad (UX-DR9)

**Given** el detalle cargando o con error
**When** se muestra la pantalla
**Then** el botón no se muestra, o se muestra inactivo, porque no hay Product que agregar (FR5)

**Given** las pruebas de esta story
**When** se ejecuta `flutter test`
**Then** pasan al menos 3 pruebas unitarias de la lógica pura: agregar nuevo con cantidad 1, agregar existente sin duplicar, y disminuir que no baja de 1 ni elimina (NFR3)
**And** otra prueba verifica el total y las unidades de una lista con varias cantidades
**And** una prueba con `ProviderContainer` (reintento desactivado) verifica que el Notifier agrega y conserva el estado (NFR3, AD-5)
**And** una prueba de widget verifica que pulsar el botón agrega el Product y muestra el toast "Agregado al carrito" (el widget de prueba monta el `ToastificationWrapper`)

### Story 3.2: Revisar y editar el carrito

As a Usuario (Lucía),
I want abrir el carrito, cambiar cantidades, quitar ítems y ver el total,
So that ajuste mi compra y vea cuánto suma, con el cambio reflejado al instante.

**Acceptance Criteria:**

**Given** la rama `feat/e3-s2-cart-screen` desde `main`
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `flutter`)
**And** corre `dart format`, `flutter analyze` sin warnings y `flutter test` (AD-13, NFR2)
**And** cita la pantalla Carrito (`f6db58a5…`) de `stitch-index.md` y completa su columna "Story" con `3.2` (gate de UI)

**Given** el AppBar del Catalog y del detalle
**When** se muestra
**Then** incluye el ícono del carrito, que navega con `context.push('/cart')` y mantiene el Catalog o el detalle en la pila (AD-8, UX-DR4)
**And** el ícono tiene un `Semantics` con la etiqueta "Carrito" (UX-DR21); el contador y su badge llegan en la story 3.3

**Given** el `GoRouter`
**When** se inspecciona
**Then** declara `/cart` además de `/` y `/product/:id`, y sigue siendo único y sin provider (AD-8)
**And** `/cart` funciona con solo la URL: el Cart es `keepAlive`, así que un enlace directo muestra el Cart vigente (AD-8)
**And** el botón atrás usa `context.canPop() ? context.pop() : context.go('/')` (AD-8)

**Given** el AppBar del Carrito
**When** se muestra
**Then** lleva la flecha atrás y el título "Carrito" sobre `surface-tonal` (UX-DR4)

**Given** un Cart con ítems
**When** se muestra `/cart`
**Then** cada `cart-item` muestra miniatura de 56 px, título, precio unitario con dos decimales y sin símbolo, controles −/+ de 48 px y un botón "Quitar" separado (UX-DR10, UX-DR15)
**And** una imagen faltante muestra "Sin foto" (UX-DR8)
**And** "Quitar" usa `button-text-danger` con el color `danger` y no lleva diálogo de confirmación (UX-DR10)
**And** no existen "Vaciar carrito", subtotales, envío, cupones ni "Tramitar pedido" (UX-DR24)

**Given** un Cart item con cantidad 2 o más
**When** el Usuario pulsa "+" o "−"
**Then** la cantidad sube o baja en 1 y el total y las unidades se actualizan al instante, sin recargar (FR7, FR9)

**Given** un Cart item con cantidad 1
**When** se muestra su control "−"
**Then** está deshabilitado, atenuado y marcado como deshabilitado para `Semantics`, y pulsarlo no elimina el ítem (FR7, UX-DR10)

**Given** un Cart item
**When** el Usuario pulsa "Quitar"
**Then** el ítem desaparece y el total y las unidades se actualizan (FR8)
**And** al quitar el último ítem se muestra el estado vacío "Tu carrito está vacío" (FR8)

**Given** un Cart con ítems
**When** se muestra el pie
**Then** un `cart-footer` fijo muestra las unidades ("1 unidad" o "{n} unidades") y "Total {importe}" con dos decimales, sin símbolo ni separador de miles, con separación superior sutil (FR9, UX-DR11, UX-DR15)
**And** el total es la suma de precio × cantidad en `double`, redondeado solo al mostrarlo con la función de formato de la story 1.3 (AD-7)
**And** con el Cart vacío no hay pie ni total (UX-DR11)

**Given** los controles −/+
**When** se revisa su accesibilidad
**Then** llevan `Semantics` "Disminuir cantidad de {producto}" y "Aumentar cantidad de {producto}" (UX-DR21)
**And** el área táctil es de al menos 48 px (UX-DR3)
**And** las imágenes llevan `semanticLabel` con el título (UX-DR21)

**Given** el código de los widgets
**When** se revisa
**Then** la UI lee el estado con `ref.watch` en `build` y llama al Notifier con `ref.read` solo en callbacks, sin lógica de negocio en los widgets (NFR5, AD-5)
**And** `cart/presentation` no importa `dio` ni `data` (AD-2)

**Given** las pruebas de widget de esta story, con el Notifier del Cart sobre un `ProviderContainer`
**When** se ejecuta `flutter test`
**Then** pasa al menos una que verifica que "+" y "−" actualizan cantidad y total, y que "−" en cantidad 1 está deshabilitado (NFR3)
**And** otra verifica que "Quitar" elimina el ítem y que quitar el último muestra "Tu carrito está vacío" sin pie

### Story 3.3: Ver el contador del carrito en todas las pantallas

As a Usuario (Lucía),
I want ver en el AppBar cuántas unidades llevo en el carrito, desde el Catalog, el detalle o el propio carrito,
So that sepa qué llevo sin abrir el carrito y vea el número subir al agregar.

**Acceptance Criteria:**

**Given** la rama `feat/e3-s3-cart-badge` desde `main`
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `flutter`)
**And** corre `dart format`, `flutter analyze` sin warnings y `flutter test` (AD-13, NFR2)
**And** cita las pantallas Catálogo (`0d762685…`), Detalle (`b0e799e0…`) y Carrito (`f6db58a5…`) de `stitch-index.md` y añade `3.3` a su columna "Story" (gate de UI)

**Given** `cartCountProvider`
**When** se inspecciona
**Then** se deriva del estado del Notifier del Cart como la suma de unidades, usando la función pura de la story 3.1, y no mantiene un estado propio (AD-7, FR9)
**And** el contador muestra unidades, no ítems distintos: dos Cart items de cantidad 2 y 3 dan 5 (FR9)
**And** no puede diferir del total del Cart, porque ambos salen del mismo estado (AD-7)

**Given** el ícono del carrito de la story 3.2
**When** se añade el contador
**Then** el `badge` aparece sobre el ícono con fondo `danger` y texto `on-danger`, en forma de píldora (UX-DR5)
**And** con 0 unidades el badge se oculta y el ícono sigue visible (UX-DR5)
**And** pasadas 99 unidades muestra "99+" (UX-DR5)
**And** el límite de 99 es una constante con nombre (NFR5)

**Given** el AppBar del Catalog, del detalle y del Carrito
**When** se muestra cada pantalla
**Then** el contador es visible en las tres (FR9, UX-DR5)
**And** se implementa como un único widget compartido y pequeño, no copiado en cada pantalla (NFR5)

**Given** el Usuario agrega un Product desde el detalle
**When** el Notifier actualiza el estado
**Then** el badge sube al instante, sin recargar (FR9, UX-DR5)
**And** al cambiar cantidad o quitar ítems en `/cart`, el badge se actualiza en la misma pantalla (FR9)

**Given** el contador y el Cart
**When** el Usuario navega Catalog → detalle → carrito → atrás hasta el Catalog
**Then** el contador conserva su valor en todas las pantallas (AD-7, UX-DR6)

**Given** la accesibilidad del ícono
**When** se revisa su `Semantics`
**Then** la etiqueta es "Carrito, {n} unidades" con la regla "1 unidad" en singular, y "Carrito vacío" con 0 (UX-DR5, UX-DR21)
**And** la regla singular/plural es la misma función de la story 3.2 para el pie del carrito, escrita una sola vez
**And** el área táctil del ícono es de al menos 48 px (UX-DR3)

**Given** el código de los widgets
**When** se revisa
**Then** el badge lee `cartCountProvider` con `ref.watch` en `build`, sin lógica de negocio (NFR5, AD-5)
**And** el widget usa `select` o un provider derivado para no reconstruirse cuando cambia algo distinto de las unidades

**Given** las pruebas de esta story
**When** se ejecuta `flutter test`
**Then** pasa una prueba unitaria de `cartCountProvider` con un `ProviderContainer` (reintento desactivado): suma de unidades con varios ítems, 0 con el Cart vacío (NFR3)
**And** una prueba de widget verifica el badge: oculto con 0, visible con unidades, "99+" pasadas 99, y la etiqueta `Semantics` con singular y plural

## Epic 4: Panel de órdenes (Angular)

Lucía ve las Orders, filtra por total mínimo y abre el detalle de una, con estados de carga y error.

### Story 4.1: Panel Angular que arranca, con el tema

As a Evaluador,
I want clonar el repo, instalar y levantar el panel Angular con los comandos del README,
So that revise el panel sobre una base reproducible, estricta y con la identidad visual de la app Flutter.

**Acceptance Criteria:**

**Given** la rama `chore/e4-s1-angular-scaffold` desde `main`
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales en inglés (scope `angular` o `repo`)
**And** no hay un único commit con todo el trabajo (FR21, AD-13)

**Given** el repo en la raíz
**When** se lista su contenido
**Then** existe `angular_app/` creada con `ng new`, independiente de `flutter_app/`: lint, test, lockfile y comandos propios, sin imports cruzados (AD-1)
**And** `angular_app/package-lock.json` está commiteado (AD-1)

**Given** el proyecto generado
**When** se inspecciona
**Then** usa Angular 22 (mínimo 17, NFR6), componentes standalone y TypeScript `strict` con TypeScript `~6.0` (AD-14, NFR6)
**And** las versiones reales de Angular, TypeScript y Node quedan anotadas, y si difieren del Stack del spine se documenta la diferencia
**And** se confirma al generarlo si el proyecto es zoneless y si el runner es Vitest (ítems "Deferred" del spine), y el resultado se anota

**Given** `package.json`
**When** se inspecciona
**Then** `@ngrx/store`, `@ngrx/effects` y `@ngrx/store-devtools` están instalados y no se importan en ningún archivo (resolución 4 de este documento)
**And** `effect` y las demás dependencias llegan en la story que las usa (4.2), no aquí

**Given** el proyecto generado y la elección de Tailwind (decisión de Mauri, en lugar de CSS propio)
**When** se configura el estilado
**Then** se instalan `tailwindcss`, `@tailwindcss/postcss` y `postcss` (con `ng add tailwindcss` o a mano), se añade `.postcssrc.json` con el plugin `@tailwindcss/postcss` y `src/styles.css` importa `tailwindcss` (documentación vigente de Angular)
**And** se confirma y anota la versión de Tailwind instalada (la documentación consultada describe la v4, con `@theme`)
**And** el estilado vive en las clases de Tailwind de las plantillas, y los estilos de componente quedan vacíos o mínimos
**And** al empezar la story se actualizan `DESIGN.md` y `EXPERIENCE.md`, donde dicen "variables CSS" y "CSS propio" para Angular, para que digan Tailwind con los mismos tokens
**And** el README justifica la dependencia (FR20)

**Given** el tema de la app
**When** se inspeccionan los estilos globales
**Then** los tokens de `DESIGN.md` son tokens del tema de Tailwind en un bloque `@theme` (que genera variables CSS y utilidades como `bg-primary` o `text-on-surface`): primary `#006A60`, background `#FBFDFA`, surface, surface-tonal `#EDF3F0`, on-surface, on-surface-muted, outline, divider, focus `#0B57D0`, danger `#B3261E` y demás (UX-DR1)
**And** usa Roboto con las fuentes del sistema como respaldo, y la escala title-lg, title-md, body-md, label-md y price de `DESIGN.md` (UX-DR2)
**And** define la escala de espaciado 4/8/16/24 y los radios sm 8, md 12, lg 16 y full 9999 como tokens `@theme`: la escala de 4 px de Tailwind ya cubre 4/8/16/24 con `1`, `2`, `4` y `6`, y los radios se definen con `--radius-*` (UX-DR3)
**And** solo hay tema claro, y los componentes usan las utilidades del tema, sin colores ni medidas arbitrarias (`bg-[#…]`, `p-[13px]`) ni CSS propio salvo donde Tailwind no alcance (NFR5)

**Given** cualquier control interactivo
**When** recibe foco por teclado
**Then** muestra un anillo visible con el color `focus` (`#0B57D0`), no con el primario (UX-DR22)
**And** se aplica con una utilidad de Tailwind sobre el token (por ejemplo `focus-visible:outline-focus`), no con una regla CSS suelta

**Given** las transiciones y animaciones del panel
**When** se inspeccionan los estilos
**Then** no hay animaciones propias, y toda transición lleva la variante `motion-reduce:` de Tailwind para desactivarse con `prefers-reduced-motion` (UX-DR23)

**Given** el shell de la app
**When** se ejecuta `ng serve` y se abre el navegador
**Then** se ve la página "Órdenes" con un contenedor de ancho máximo centrado y la plantilla por defecto de Angular eliminada (UX-DR20)
**And** el cuerpo es provisional y se reemplaza en la story 4.2, sin `console.log` ni código muerto (NFR5)
**And** la UI está en español y el código e identificadores en inglés (NFR9)

**Given** `ng test`
**When** se ejecuta
**Then** pasa al menos una prueba que monta el shell y verifica el título "Órdenes" (NFR4, AD-13)

**Given** `ng build`
**When** se ejecuta
**Then** termina sin errores ni warnings (AD-10, AD-13)
**And** no hay `any` sin justificar ni `as` o `!` para forzar tipos en el código escrito (NFR6, AD-15)

**Given** `stitch-index.md`
**When** se actualiza
**Then** la columna "Story" de Órdenes queda en `4.2` y se anota que esta story solo prepara el shell y el tema

**Given** el README en la raíz
**When** se lee tras esta story
**Then** incluye los comandos para instalar y ejecutar `angular_app/` desde un clon limpio: `npm install`, `ng serve`, `ng test` y `ng build` (NFR8)
**And** deja una nota provisional de que `@ngrx/*` está instalado sin uso, con la justificación completa para el Epic 5 (FR20)

### Story 4.2: Ver las Orders en tarjetas

As a Usuario (Lucía),
I want ver la lista de Orders, cada una en su tarjeta con id, `userId` y total, con un estado claro si carga o falla,
So that revise de un vistazo las órdenes y me recupere si la API falla.

**Acceptance Criteria:**

**Given** la rama `feat/e4-s2-orders-list` desde `main`
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `angular`)
**And** corren `ng test` y `ng build` sin errores ni warnings (AD-10, AD-13)
**And** cita la pantalla Órdenes (`1b9f30e0…`) de `stitch-index.md` (gate de UI)

**Given** que esta story instala `effect`
**When** se escribe el primer código con `Schema` y `Result`
**Then** antes se confirman los nombres de la API v4 contra la documentación vigente (en la v3 el tipo se llamaba `Either`) y se anotan (AD-12)
**And** solo se usan los módulos `Schema` y `Result`, nunca el runtime `Effect` (fibers, layers, `Effect.gen`) (AD-12)

**Given** `core/errors/` en TypeScript
**When** se inspecciona
**Then** existen `BaseException(message, code)` con `NetworkException`, `ServerException(status)` y `ParseException`, y el contenedor `Errors` (AD-12, FR12 paralelo)
**And** el `code` es de un tipo cerrado (unión de literales) (AD-11)
**And** una única función `toErrorInfo(errors)` convierte un `Errors` en `ErrorInfo { message, code }` con valores planos (AD-11)
**And** los textos salen de la tabla de `EXPERIENCE.md` (conexión, respuesta no exitosa, parseo) y no se arman en los componentes (UX-DR13)

**Given** el tipo `Order`
**When** se inspecciona
**Then** se obtiene de `Schema.Schema.Type` del esquema, que es su única definición (AD-12)
**And** `id`, `userId` y `total` son requeridos, `discountedTotal` es opcional, y los productos de la Order (id, título, cantidad, precio) forman parte del esquema para la story 4.4 (AD-12, FR13)

**Given** `OrdersService` (`providedIn: 'root'`)
**When** se inspecciona
**Then** es el único que usa `HttpClient` y consulta `GET https://dummyjson.com/carts?limit=0` con la URL base como constante (FR13, AD-10)
**And** devuelve `Observable<Result<Order[], Errors>>` y valida la respuesta con `Schema.decodeUnknownResult` (AD-12)
**And** un fallo de conexión produce `NetworkException`, una respuesta no exitosa produce `ServerException(status)` y un fallo de validación produce `ParseException`, sin que un `HttpErrorResponse` llegue al store ni a la UI (AD-12)

**Given** el store manual de Orders (`providedIn: 'root'`, un solo servicio)
**When** se inspecciona
**Then** guarda los Orders en un mapa por `id` actualizado siempre por `upsert`, y la lista se ordena por `id` (AD-11)
**And** `listStatus` (`idle`, `loading`, `loaded`, `error`) y `listError` son independientes del estado del detalle (AD-11)
**And** el estado son solo valores planos y se actualiza creando valores nuevos, sin mutar (AD-11, NFR5)
**And** una nueva carga de la lista se ignora si ya hay una en vuelo (equivale a `exhaustMap`) (AD-11, resolución 4)
**And** solo el store llama a `OrdersService`, y los componentes nunca importan `HttpClient` ni el servicio (AD-10)
**And** la suscripción al servicio se limpia con `takeUntilDestroyed` o equivalente, sin ningún `subscribe()` sin limpieza (FR17)

**Given** `OrdersPageComponent` (contenedor)
**When** se abre el panel
**Then** pide la carga al store y renderiza un `OrderCardComponent` por cada Order, usando `@for` con `track` (FR13, DA-3)
**And** lee el estado del store con signals o `async` pipe, sin lógica de negocio ni suscripciones manuales (AD-10, FR17)

**Given** `OrderCardComponent` (presentacional)
**When** se inspecciona
**Then** recibe el Order por `input()`, usa `ChangeDetectionStrategy.OnPush`, no inyecta servicios y no navega (FR16 parcial, AD-10, DA-5)
**And** muestra el id, el `userId` y el total, y el total con descuento solo si la Order lo trae (FR13, UX-DR17)
**And** el botón "Ver detalle" y su `output()` no se añaden aquí, sino en la story 4.4, para no dejar un botón sin efecto
**And** la tarjeta usa `surface-tonal`, radio lg y padding md (UX-DR17)

**Given** un importe
**When** se muestra
**Then** lleva dos decimales, punto decimal, sin separador de miles y sin símbolo de moneda (UX-DR15)
**And** el formato lo hace un pipe propio y pequeño (cubre DA-4), no el `number` por defecto, porque este agrega separador de miles

**Given** la carga en curso
**When** `listStatus` es `loading`
**Then** se muestra un indicador de carga (FR15)

**Given** una falla de red, una respuesta no exitosa o una respuesta inválida
**When** `listStatus` es `error`
**Then** se muestra el mensaje del `ErrorInfo` y un `button-tonal` "Reintentar", y no una pantalla en blanco (FR15, UX-DR13)
**And** "Reintentar" vuelve a pedir la lista al store y vuelve a cargando (FR15)

**Given** el panel en escritorio de 1024 px o más
**When** se muestran las tarjetas
**Then** forman una rejilla de 2 columnas con separación de 16 px y ancho máximo centrado, y por debajo de 1024 px pasa a 1 columna, con utilidades de Tailwind (`grid`, `lg:grid-cols-2`, `gap-4`) (UX-DR20)

**Given** los cambios de estado de la lista
**When** cambian la carga, los datos o el error
**Then** se anuncian en una región `aria-live="polite"` (UX-DR22)
**And** los controles son botones reales y el foco es visible (UX-DR22)

**Given** las pruebas de esta story
**When** se ejecuta `ng test`
**Then** pasan al menos 2 pruebas del servicio con `HttpTestingController`: una respuesta válida que produce `Result` exitoso con los Orders, y respuestas con falla que producen `ServerException(status)` y `ParseException` (NFR4, AD-13)
**And** otra prueba de componente o del store verifica el estado de datos y el error con "Reintentar", usando un `OrdersService` falso

### Story 4.3: Filtrar Orders por total mínimo

As a Usuario (Lucía),
I want escribir un total mínimo y ver solo las Orders que lo alcanzan, sin recargar la página,
So that encuentre rápido las órdenes grandes y la lista reaccione al instante.

**Acceptance Criteria:**

**Given** la rama `feat/e4-s3-min-total-filter` desde `main`
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `angular`)
**And** corren `ng test` y `ng build` sin errores ni warnings (AD-10, AD-13)
**And** cita la pantalla Órdenes (`1b9f30e0…`) de `stitch-index.md` (gate de UI)

**Given** el panel de la story 4.2
**When** se muestra sobre la lista
**Then** aparece un campo numérico "Total mínimo" con un `label` asociado al control (UX-DR19, UX-DR22)
**And** el campo usa los tokens de `DESIGN.md` y su foco muestra el anillo `focus` (UX-DR22)

**Given** el campo de filtro
**When** el Usuario escribe un valor
**Then** un `FormControl` es la única entrada de la UI y despacha `setMinTotal` al store, que es el dueño de `minTotal` (FR14, AD-10, resolución 4)
**And** el flujo va siempre del `FormControl` al store, nunca al revés (AD-10)
**And** la suscripción a `valueChanges` se limpia con `takeUntilDestroyed` o se usa `toSignal`, sin ningún `subscribe()` sin limpieza (FR17)

**Given** los Orders ya cargados y un `minTotal`
**When** cambia el valor del filtro
**Then** la lista visible es un valor derivado (`computed`) sobre los datos ya cargados, sin recargar la página ni repetir la petición HTTP (FR14, AD-10)
**And** se compara con `total >= mínimo` sobre el campo `total` y no sobre `discountedTotal` (FR14)
**And** un Order con `total` igual al mínimo se incluye (FR14)

**Given** un campo vacío
**When** no hay valor
**Then** se muestran todos los Orders (FR14)

**Given** un valor no numérico, incluida la coma decimal (por ejemplo `30,5`)
**When** se escribe
**Then** se trata como vacío y se muestran todos los Orders, sin lanzar error (UX-DR19)
**And** el valor se interpreta en un único lugar y en forma pura, no en la plantilla (NFR5)

**Given** un filtro que ningún Order alcanza
**When** la lista visible queda vacía
**Then** se muestra "Ninguna orden alcanza ese total" y no una lista en blanco (FR14, UX-DR19)

**Given** los Orders cargando o la carga fallida
**When** `listStatus` es `loading` o `error`
**Then** el campo está deshabilitado (UX-DR19)
**And** se habilita cuando `listStatus` es `loaded`

**Given** un cambio en la lista por el filtro
**When** cambia la cantidad de tarjetas visibles
**Then** el cambio se anuncia en la región `aria-live="polite"` (UX-DR22)
**And** el mensaje de vacío también se anuncia

**Given** el código del filtro
**When** se revisa
**Then** `minTotal` y la lista visible no se duplican en el componente: el store es la única fuente (AD-10)
**And** no hay `any` sin justificar ni `as` o `!` para forzar tipos (NFR6, AD-15)

**Given** las pruebas de esta story
**When** se ejecuta `ng test`
**Then** pasa al menos una prueba del store o del valor derivado: `>=` incluye el valor igual al mínimo, vacío muestra todos, y un valor no numérico equivale a vacío (NFR4)
**And** otra prueba de componente verifica que escribir en el campo reduce las tarjetas sin una segunda petición HTTP, y que sin coincidencias aparece "Ninguna orden alcanza ese total"

### Story 4.4: Ver el detalle de una Order

As a Usuario (Lucía),
I want pulsar "Ver detalle" en una Order y ver sus productos con título, cantidad y precio,
So that revise qué contiene cada orden, también si abro su URL directamente.

**Acceptance Criteria:**

**Given** la rama `feat/e4-s4-order-detail` desde `main`
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `angular`)
**And** corren `ng test` y `ng build` sin errores ni warnings (AD-10, AD-13)
**And** cita la pantalla Órdenes (`1b9f30e0…`) de `stitch-index.md` (gate de UI)

**Given** `OrderCardComponent`
**When** se completa esta story
**Then** añade un `button-tonal` "Ver detalle" que emite el id de la Order por `output()` (FR16, UX-DR17)
**And** el botón lleva `aria-label="Ver detalle de la orden {id}"` (UX-DR17, UX-DR22)
**And** la tarjeta sigue sin navegar, sin consultar datos y sin inyectar servicios (FR16, AD-10)
**And** no lleva `aria-expanded` ni `aria-controls`, ni "Ocultar detalle", porque el detalle es una ruta y no una tarjeta expandible (resolución 1 de este documento)

**Given** `OrdersPageComponent`
**When** recibe el id emitido por la tarjeta
**Then** el contenedor decide y navega a `/orders/:id` (FR16)

**Given** las rutas de la app
**When** se inspeccionan
**Then** existen `''` (la lista) y `orders/:id`, esta última con `loadComponent` (lazy loading) (FR16, DA-1, AD-11)
**And** el `loadComponent` es la única importación dinámica y está documentada como excepción de AD-15 (`no-dynamic-imports`)
**And** el `id` se parsea a `number` una sola vez, en la ruta, y uno no numérico (`/orders/abc`) muestra el error "No encontramos esa orden." [ASSUMPTION: `EXPERIENCE.md` solo define el texto de producto inexistente] (AD-11, UX-DR13)

**Given** `OrdersService`
**When** se añade el detalle
**Then** `getById(id)` consulta `GET /carts/{id}`, devuelve `Observable<Result<Order, Errors>>` y valida con el mismo esquema `Order` de la story 4.2, sin una segunda definición (AD-12)
**And** un 404 produce `ServerException(404)`, que la UI muestra como "No encontramos esa orden." y no como el texto genérico de respuesta no exitosa [ASSUMPTION] (UX-DR13)

**Given** el store manual
**When** se añade `loadOrder(id)`
**Then** si `entities[id]` existe no hace ninguna petición, y si no existe consulta `getById` (AD-11)
**And** el resultado se agrega al mapa por `upsert` y nunca lo reemplaza, de modo que cargar un detalle no borra la lista ni al revés (AD-11)
**And** `byIdStatus` y `byIdError` se llevan por `id` y son independientes de `listStatus` y `listError` (AD-11)
**And** las cargas de `id` distintos pueden ser concurrentes (equivale a `mergeMap`) (AD-11)
**And** el store sigue siendo un único servicio en la raíz y no se registra en la ruta lazy (AD-11)
**And** la suscripción se limpia con `takeUntilDestroyed` o equivalente (FR17)

**Given** el Usuario llega al detalle desde la lista
**When** la Order ya está en el mapa
**Then** el detalle se muestra al instante, sin nueva petición (AD-11)

**Given** el Usuario abre `/orders/:id` directamente por URL
**When** la Order no está cargada
**Then** el contenedor del detalle despacha `loadOrder(id)` y muestra la Order al llegar (FR16, AD-11)

**Given** el detalle cargado
**When** se renderiza
**Then** muestra el id, el `userId`, el total y el total con descuento solo si existe (FR13, UX-DR17)
**And** muestra una tabla con columnas Título, Cantidad y Precio, con el precio unitario y dos decimales sin símbolo, usando el pipe de la story 4.2 (FR16, UX-DR18, UX-DR15)
**And** la tabla usa `<table>` con encabezados `<th scope="col">` (UX-DR22)
**And** una Order sin productos muestra "Esta orden no tiene productos" (UX-DR18)
**And** los ids son los reales de DummyJSON, sin inventar formatos como `#ORD-001` (UX-DR18)

**Given** el detalle cargando
**When** `byIdStatus[id]` es `loading`
**Then** se muestra un indicador de carga (FR15)

**Given** el detalle con falla de red, respuesta no exitosa, 404 o respuesta inválida
**When** `byIdStatus[id]` es `error`
**Then** se muestra el mensaje del `ErrorInfo` y un `button-tonal` "Reintentar" que repite `loadOrder(id)` (FR15, UX-DR13)

**Given** el detalle
**When** el Usuario quiere volver
**Then** hay un enlace real "Volver a órdenes" con `routerLink` a `/` (UX-DR22)
**And** al volver, el filtro `minTotal` y la lista cargada se conservan porque viven en el store de la raíz (AD-10, AD-11)

**Given** los cambios de estado del detalle
**When** cambian la carga o el error
**Then** se anuncian en una región `aria-live="polite"` y el foco es visible en el botón y el enlace (UX-DR22)

**Given** el código del detalle
**When** se revisa
**Then** ningún componente importa `HttpClient` ni `OrdersService`, y no hay `subscribe()` sin limpieza (AD-10, FR17)
**And** el componente del detalle usa `@if` y `@for` con `track`, y `OnPush` en los presentacionales (DA-3, DA-5)
**And** no hay `any` sin justificar ni `as` o `!` para forzar tipos (NFR6, AD-15)

**Given** las pruebas de esta story
**When** se ejecuta `ng test`
**Then** pasa una prueba de componente que verifica que pulsar "Ver detalle" emite el id de la Order, y otra del store que verifica que `loadOrder` no consulta si la Order ya está cargada y que `upsert` no reemplaza el mapa (NFR4)
**And** una prueba del servicio con `HttpTestingController` verifica que un 404 de `GET /carts/{id}` produce `ServerException(404)`

## Epic 5: Verificación del MVP y bonus

El evaluador clona el repo, ejecuta ambas apps y comprueba que cumplen lo pedido; después se suman los bonus elegidos por Mauri, solo con el MVP verificado.

**Aviso (sin story de dev) — FR18 y FR19:** Mauri redacta `RESPUESTAS.md` con las 20 preguntas conceptuales (Parte 1) y el code review de los fragmentos A y B (Parte 4), con sus propias palabras, partiendo de `borrador-respuestas-parte1.md` y con coaching. Se hace con el código ya terminado, porque el review se apoya en él. La story 5.1 solo verifica que el archivo exista y esté enlazado desde el README.

### Story 5.1: Verificación de la app MVP

As a Evaluador,
I want clonar el repo, seguir el README y comprobar que las dos apps cumplen lo pedido,
So that vea una entrega reproducible, honesta sobre lo pendiente y con historial real.

**Acceptance Criteria:**

**Given** la rama `docs/e5-s1-mvp-verification` desde `main`, con los Epics 1 a 4 fusionados
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `docs` o `repo`)
**And** las stories de bonus (5.2 a 5.5) no se empiezan hasta cerrar esta (PRD §6.2)

**Given** un clon limpio del repo en una carpeta nueva
**When** se siguen solo los comandos del README para `flutter_app/`
**Then** `flutter pub get` y `flutter run` en el emulador Android arrancan la app sin pasos no documentados (NFR8)
**And** los archivos generados (`*.g.dart`, `*.freezed.dart`) están commiteados y la app compila sin ejecutar `build_runner` (AD-13)

**Given** un clon limpio del repo
**When** se siguen solo los comandos del README para `angular_app/`
**Then** `npm install`, `ng serve`, `ng test` y `ng build` funcionan sin pasos no documentados (NFR8)

**Given** `flutter_app/`
**When** se ejecutan `dart format --set-exit-if-changed .`, `flutter analyze` y `flutter test`
**Then** el análisis termina con 0 warnings (SM-1, NFR2) y pasan al menos 3 pruebas unitarias y 1 de widget (SM-2, NFR3)

**Given** `angular_app/`
**When** se ejecutan `ng test` y `ng build`
**Then** pasan al menos 2 pruebas y el build termina sin warnings (SM-2, NFR4)

**Given** los requisitos obligatorios FR1 a FR17 y NFR1 a NFR9
**When** se recorre cada uno contra la app corriendo
**Then** el README incluye una sección "Estado de la entrega" que lista cada obligatorio como cumplido o pendiente, con el motivo si es pendiente (SM-3, FR20)
**And** lo no terminado se documenta en lugar de entregarse roto (PRD §1)

**Given** el flujo de UJ-1 en el emulador
**When** se recorre completo (Catalog, búsqueda con debounce, scroll, detalle, agregar, cambiar cantidad, total y contador, volver)
**Then** el Cart conserva su contenido y el buscador su término al volver (UJ-1)
**And** sin red, el Catalog muestra el error con "Reintentar" (UJ-1, FR2)

**Given** el flujo de UJ-2 en el navegador
**When** se recorre completo (lista, filtro, Ver detalle, volver)
**Then** el filtro reduce la lista sin recargar y, si la API falla, se ve el error con "Reintentar" (UJ-2, FR14, FR15)

**Given** el README en la raíz
**When** se completa
**Then** explica cómo ejecutar `flutter_app/` y `angular_app/`, documenta las decisiones de arquitectura, lo pendiente y lo que se mejoraría con más tiempo (FR20, SM-5)
**And** justifica la construcción de modelos con `freezed` (T-4) y menciona los paralelos Flutter↔Angular: servicio ≈ Repository, signal/store ≈ provider, componente presentacional ≈ widget sin estado (FR20)
**And** incluye el resultado de la verificación del deep link con `adb` de la story 2.2, o dice que no se verificó (AD-9)
**And** documenta que Angular usa un store manual y que `@ngrx/*` está instalado sin uso, con la razón (resolución 4)
**And** si `ARCHITECTURE-SPINE.md`, el PRD o el addendum aún dicen NgRx, lo lista como pendiente o los actualiza en esta story
**And** si se aplicó el plan B del PRD §8 (modelos manuales o Riverpod sin generador), lo documenta
**And** anota las versiones reales de Flutter, Dart, Angular, TypeScript y Node
**And** declara honestamente qué deseables y bonus se hicieron (SM-8) y enlaza a `RESPUESTAS.md`
**And** está escrito en español, con código e identificadores en inglés (NFR9)

**Given** el historial de git
**When** se revisa con `git log` y `git branch -a`
**Then** hay una rama por story con el formato `<tipo>/<epic>-<story>-<slug>`, fusionada a `main` (FR21, SM-6)
**And** todos los commits siguen Conventional Commits en inglés, y existe más de un commit (FR21, SM-6)

**Given** el repo
**When** se busca el PDF de la prueba con `git log --all -- "*.pdf"` y en el árbol de trabajo
**Then** no aparece, y el `.gitignore` lo excluye (FR21)
**And** existen `flutter_app/` y `angular_app/` en la raíz, y el repo es público (FR21)

**Given** `stitch-index.md`
**When** se revisa
**Then** la columna "Story" de las 4 pantallas está completa con las stories reales (gate de UI)
**And** los pendientes de Stitch (ediciones sin verificar, copia vieja de Órdenes) quedan resueltos o anotados como pendientes

**Given** el ensayo de SM-4
**When** Mauri explica sin mirar el código cómo fluye un provider de la UI al Repository, por qué usa `ref.read` en un callback, y cómo fluye un Order desde `OrdersService` hasta la tarjeta
**Then** queda marcado como hecho en la lista de verificación de esta story (SM-4)

**Given** `RESPUESTAS.md`
**When** se revisa la entrega
**Then** el archivo existe y está enlazado desde el README (FR18, FR19)
**And** si su contenido aún no está completo, esta story lo reporta como pendiente de Mauri y no lo rellena

**Given** el plazo de 3 días calendario
**When** se cierra la story
**Then** se anota la hora de entrega frente al plazo (SM-7)

### Story 5.2: Bonus: filtrar el catálogo por categoría (DF-2)

As a Usuario (Lucía),
I want elegir una categoría y ver solo sus Products, también mientras busco,
So that acote el catálogo sin recorrer toda la lista.

**Acceptance Criteria:**

**Given** la rama `feat/e5-s2-category-filter` desde `main`, con la story 5.1 cerrada
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `flutter`)
**And** corre `dart format`, `flutter analyze` sin warnings y `flutter test` (AD-13, NFR2)
**And** si no se cierra completa y con tests, no se entrega a medias: se documenta como pendiente en el README (SM-C1, PRD §8)

**Given** que DF-2 estaba fuera del MVP y el índice de Stitch lo marcaba "No implementar"
**When** se empieza la story
**Then** antes de escribir código se añade el selector de categoría a `DESIGN.md`, `EXPERIENCE.md` y `stitch-index.md`, y se retira DF-2 de la lista de exclusiones (UX-DR24, gate de UI)
**And** el selector se define como un botón de filtro bajo el buscador, que abre un modal con "Todas" y las categorías, hecho con `wolt_modal_sheet` (decisión de Mauri), con los tokens existentes y áreas táctiles de 48 px [ASSUMPTION]
**And** el botón muestra la categoría elegida (o "Categoría" si es "Todas") para que el estado no dependa de abrir el modal
**And** `wolt_modal_sheet` se añade a `pubspec.yaml` en esta story, y se confirma con un `flutter pub get` real que resuelve sin conflictos antes de escribir la UI; si no resuelve, se recurre a `showModalBottomSheet` de Material y se documenta

**Given** `GET /products/categories`
**When** se abre el Catalog
**Then** el Repository la consulta con el mismo patrón de `Either<Errors, T>` y `CancelSignal`, y devuelve las categorías como un modelo inmutable en `products/domain/` (FR10, FR11, AD-3)
**And** si la consulta de categorías falla, el Catalog sigue funcionando sin el selector, y el error no oculta la lista (FR2, AD-4)

**Given** `selectedCategory`
**When** se inspecciona su provider
**Then** es un `Notifier` síncrono con `keepAlive`, igual que `searchTerm`, y sin red (AD-5, AD-6)
**And** el valor "Todas" equivale a ninguna categoría

**Given** una categoría elegida y sin Search term
**When** cambia `selectedCategory`
**Then** `catalogProvider` consulta `GET /products/category/{slug}` con `limit` y `skip`, con el mismo mecanismo de estados, de época y de `loadMore` del Catalog (AD-6, FR2)
**And** cambiar la categoría reinicia `skip = 0` y descarta las respuestas pendientes de la anterior (AD-6)

**Given** una categoría elegida y un Search term no vacío
**When** el Usuario busca
**Then** el Catalog muestra los Products de esa categoría cuyo título contiene el término, sin distinguir mayúsculas [ASSUMPTION: la API de DummyJSON no combina `q` con categoría, así que el cruce se hace en el cliente sobre la categoría completa, pedida con `limit=0`]
**And** en ese modo no hay paginación, porque una categoría tiene pocos Products, y el pie no muestra "Cargar más"
**And** un Search term vacío vuelve a la lista paginada de la categoría
**And** se confirma contra la API real, antes de escribir código, que `/products/search` no admite categoría y que `/products/category/{slug}?limit=0` devuelve toda la categoría

**Given** una categoría sin Products que coincidan con el término
**When** el resultado es vacío
**Then** se muestra `Sin resultados para "{término}"`, y sin término "No hay productos" (FR2, UX-DR12)

**Given** una falla de red o de respuesta con una categoría elegida
**When** el estado es `AsyncError`
**Then** se muestra el mensaje derivado del `Errors` y "Reintentar" ejecuta `ref.invalidate(catalogProvider)` (FR2, AD-6)

**Given** el Usuario abre un detalle y vuelve atrás
**When** regresa al Catalog
**Then** la categoría elegida, el término y los resultados se conservan (UX-DR6)

**Given** el botón de filtro y el modal
**When** se revisa su accesibilidad
**Then** el botón tiene un área táctil de 48 px y una etiqueta de `Semantics` con la categoría elegida (UX-DR21)
**And** cada opción del modal lleva una etiqueta de `Semantics` con el nombre de la categoría y su estado seleccionado, y el estado no se transmite solo con color (UX-DR21)
**And** el modal se cierra con el botón atrás del sistema y al elegir una opción, y el foco vuelve al botón de filtro

**Given** el código de los widgets
**When** se revisa
**Then** `ref.watch` se usa en `build` y `ref.read` solo en callbacks, sin lógica de negocio en los widgets, y `presentation` no importa `dio` (NFR5, AD-2)
**And** el filtrado del término sobre la categoría es una función pura en `domain/`

**Given** las pruebas de esta story, con un Repository falso (`mocktail`)
**When** se ejecuta `flutter test`
**Then** pasa una prueba unitaria de la función pura (coincidencia sin distinguir mayúsculas y lista vacía)
**And** otra prueba verifica que `catalogProvider` consulta la categoría y descarta una respuesta tardía al cambiar de categoría
**And** una prueba de widget verifica que abrir el modal y elegir una categoría filtra la lista y que "Todas" la restablece

### Story 5.3: Bonus: conservar el carrito entre sesiones (DF-3)

As a Usuario (Lucía),
I want que el carrito siga ahí al cerrar y volver a abrir la app,
So that no pierda lo que agregué.

**Acceptance Criteria:**

**Given** la rama `feat/e5-s3-cart-persistence` desde `main`, con la story 5.1 cerrada
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `flutter`)
**And** corre `dart format`, `flutter analyze` sin warnings y `flutter test` (AD-13, NFR2)
**And** los archivos generados se regeneran y commitean (AD-13)
**And** si no se cierra completa y con tests, se documenta como pendiente en el README (SM-C1)

**Given** que `EXPERIENCE.md` y AD-7 describen el Cart como solo en memoria
**When** se empieza la story
**Then** se actualizan `EXPERIENCE.md` (Foundation) y el PRD (§4.4, "Fuera de alcance") para reflejar que el Cart persiste, o se anota la desviación en el README
**And** la persistencia no cambia ninguna pantalla: no hay gate de UI nuevo

**Given** la elección del paquete (decidida por Mauri)
**When** se justifica en el README
**Then** se usa `shared_preferences` (PRD: `shared_preferences` o `hive`), porque no necesita generador ni adaptadores y reutiliza el `toJson`/`fromJson` de los modelos, sin un segundo mecanismo de serialización
**And** el README anota por qué se descartaron `isar_community` y `hive_ce`: `isar_community_generator` 3.3.2 exige `analyzer >=8.0.0 <11.0.0` y `freezed` 4.0.2 exige `>=14.0.0 <15.0.0`, sin intersección; `hive_ce` es una base clave-valor (no un ORM) que añadiría adaptadores generados y otro `*.g.dart` (rangos de pub.dev, no probados con un `pub get` real)
**And** la dependencia se añade a `pubspec.yaml` en esta story y no antes (AD-1)

**Given** `CartItem` en `cart/domain/`
**When** se añade la serialización
**Then** `CartItem` (y por tanto el `Product` que guarda) se serializa con `toJson` y `fromJson` generados, y `domain/` solo importa `json_annotation`, sin Flutter ni `shared_preferences` (AD-2, FR11)
**And** las funciones puras de la story 3.1 no cambian

**Given** `cart/data/`
**When** se inspecciona
**Then** un `CartStorage` es el único lugar que lee y escribe `shared_preferences`, con una clave constante (AD-3, NFR5)
**And** guarda la lista de Cart items como un JSON y la lee devolviendo una lista inmutable
**And** el provider de `SharedPreferences` se sobrescribe en `main()` con la instancia ya cargada, para que el Notifier siga siendo síncrono y sin estado de carga (AD-5)

**Given** el Notifier del Cart (`keepAlive`)
**When** la app arranca con un Cart guardado
**Then** su estado inicial es el Cart guardado, con las mismas cantidades, y el contador y el total reflejan ese estado (FR9, AD-7)

**Given** el Usuario agrega, cambia la cantidad o quita un ítem
**When** el Notifier actualiza el estado
**Then** escribe el nuevo Cart en `CartStorage`, y el estado en memoria sigue siendo la fuente de verdad (AD-7)
**And** si la escritura falla, el Cart en memoria no se altera y la app no se cae; el fallo se ignora de forma deliberada y comentada [ASSUMPTION], sin `print` (NFR5)
**And** al quitar el último ítem se guarda el Cart vacío y no queda basura

**Given** un valor guardado corrupto o con un formato anterior
**When** la app arranca
**Then** el Cart inicia vacío, el valor inválido se descarta y la app no se cae (FR12, AD-4)

**Given** un Product guardado hace tiempo
**When** se muestra en el Cart
**Then** conserva el título y el precio guardados, sin consultar la API, y esa limitación (el precio puede haber cambiado) se documenta en el README como pendiente [ASSUMPTION: guardar un snapshot del Product]

**Given** las pruebas de esta story
**When** se ejecuta `flutter test`
**Then** pasa una prueba de ida y vuelta de `CartStorage` con `SharedPreferences.setMockInitialValues`: guardar y leer devuelve el mismo Cart (NFR3)
**And** otra prueba verifica que un Notifier creado con valores guardados arranca con ese Cart, y que un JSON corrupto da un Cart vacío
**And** otra verifica que agregar un Product escribe en `CartStorage`, con el `ProviderContainer` y el reintento desactivado (AD-5)

### Story 5.4: Bonus: prueba de integración del flujo principal (B-1)

As a Evaluador,
I want una prueba que recorra buscar → detalle → agregar al carrito en la app real,
So that vea comprobado de punta a punta el flujo central, y no solo sus piezas por separado.

**Acceptance Criteria:**

**Given** la rama `test/e5-s4-integration-flow` desde `main`, con la story 5.1 cerrada
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `flutter`)
**And** corre `dart format`, `flutter analyze` sin warnings y `flutter test` (AD-13, NFR2)
**And** si no queda estable y repetible, no se entrega: se documenta como pendiente en el README (SM-C1)

**Given** `flutter_app/pubspec.yaml`
**When** se añade la prueba
**Then** `integration_test` (del SDK de Flutter) se agrega como `dev_dependency`, en esta story y no antes (AD-1)
**And** la prueba vive en `flutter_app/integration_test/` y no se ejecuta con el `flutter test` normal

**Given** la app
**When** la prueba la arranca
**Then** monta el mismo widget raíz que `main()`, incluido el `ToastificationWrapper`, con un `ProviderScope` cuyo `productRepositoryProvider` se sobrescribe con un Repository falso de datos fijos (FR10, AD-13)
**And** el reintento automático de Riverpod sigue desactivado (AD-5)
**And** si la story 5.3 ya está fusionada, `SharedPreferences` se sobrescribe con valores vacíos para que el Cart inicie vacío
**And** no se llama a la red real, de modo que DummyJSON caído no rompe la prueba (PRD §8)

**Given** el flujo de UJ-1
**When** la prueba lo recorre
**Then** abre el Catalog y ve los Products del Repository falso (FR1)
**And** escribe "phone" en el buscador y, tras los 400 ms del debounce, el Catalog muestra solo los resultados del término (FR3)
**And** el Repository falso recibe una única consulta de búsqueda con el término recortado, no una por tecla (FR3)
**And** toca el primer resultado y llega al detalle de ese `id` (FR4)
**And** pulsa "Agregar al carrito", ve el toast "Agregado al carrito" y el badge del AppBar pasa a 1 (FR6, FR9, UX-DR5)
**And** abre el carrito y ve el ítem con cantidad 1 y el total igual al precio, con dos decimales (FR9)
**And** vuelve atrás hasta el Catalog y el badge conserva el valor 1 (AD-7)

**Given** la espera del debounce y del toast
**When** la prueba avanza el tiempo
**Then** usa `pump` con una duración mayor que los 400 ms y `pumpAndSettle` con tope, sin `sleep` ni esperas fijas arbitrarias (NFR5)
**And** el toast se cierra o se deja expirar con `pump`, para que un temporizador pendiente no rompa el final de la prueba
**And** los widgets se buscan por texto o `Semantics`, y solo se añaden `Key`s donde un finder estable lo exija

**Given** el emulador Android
**When** se ejecuta `flutter test integration_test` (o `flutter drive`, según lo que resulte funcionar)
**Then** la prueba pasa dos veces seguidas sin cambios, sin depender del orden ni del estado previo
**And** el comando exacto y el emulador usado quedan en el README

**Given** el README y la futura GitHub Action de la story 5.5
**When** se documenta la prueba
**Then** el README explica que requiere un emulador o dispositivo, y que por eso queda fuera del job de CI por defecto
**And** si la prueba depende de un valor que cambió en otra story (por ejemplo, el título del buscador), se actualiza aquí y no se duplica en dos pruebas

**Given** el código de la prueba
**When** se revisa
**Then** no contiene `print`, código muerto ni valores mágicos sin constante (NFR5)
**And** el Repository falso reutiliza el de las pruebas de widget si ya existe, sin duplicar el fake (NFR5)

### Story 5.5: Bonus: GitHub Action de analyze y test (B-2)

As a Evaluador,
I want que cada push al repo ejecute automáticamente el análisis y las pruebas de las dos apps,
So that vea una señal verificable de calidad sin clonar nada.

**Acceptance Criteria:**

**Given** la rama `ci/e5-s5-github-actions` desde `main`, con la story 5.1 cerrada
**When** se completa la story
**Then** se fusiona a `main` con commits convencionales (scope `repo`)
**And** si no queda en verde, no se entrega como logrado: se documenta como pendiente en el README (SM-C1)

**Given** `.github/workflows/`
**When** se inspecciona
**Then** existe un workflow que se ejecuta en cada `push` y en cada `pull_request` hacia `main`
**And** tiene dos jobs independientes, uno para `flutter_app/` y otro para `angular_app/`, de modo que el fallo de uno no oculta el resultado del otro (AD-1)
**And** cada job usa `working-directory` de su carpeta y no comparte pasos ni caché con el otro (AD-1)

**Given** el job de Flutter
**When** se ejecuta
**Then** instala Flutter con una acción de la comunidad fijada a una versión, usando la versión de Flutter y Dart anotada en la story 1.1 (Dart ≥ 3.13, AD-14)
**And** ejecuta `flutter pub get`, `dart format --set-exit-if-changed .`, `flutter analyze` y `flutter test` (AD-13, NFR2, NFR3)
**And** falla si `flutter analyze` reporta warnings
**And** no ejecuta `build_runner`, porque los archivos generados están commiteados (AD-13)
**And** no ejecuta la prueba de integración de la 5.4, que requiere un emulador (se documenta en el README)

**Given** el job de Angular
**When** se ejecuta
**Then** instala la versión de Node anotada en la story 4.1 (Node 24 según el spine), ejecuta `npm ci`, `ng test` en modo no interactivo y `ng build` (AD-10, AD-13, NFR4)
**And** el runner de pruebas corre sin navegador gráfico y sin un modo `--watch` que cuelgue el job

**Given** los archivos generados de Flutter
**When** alguien olvida regenerarlos
**Then** el job lo detecta, porque `flutter analyze` o `flutter test` fallan, y no se oculta con un paso de generación (AD-13)

**Given** el repo con el workflow
**When** se hace un push de prueba
**Then** ambos jobs terminan en verde y el resultado queda visible en GitHub, con una insignia (badge) de estado en el README (FR20)
**And** si un job falla por un motivo del entorno (versión de Flutter o de Node), se corrige el workflow y se anota qué versión quedó fijada

**Given** el workflow
**When** se revisa
**Then** usa permisos mínimos (`contents: read`) y no contiene secretos, tokens ni claves
**And** no despliega ni publica nada (PRD §5, CI/CD obligatorio fuera de alcance)
**And** las acciones de terceros están fijadas a una versión, no a `latest` ni a una rama móvil

**Given** el README
**When** se actualiza
**Then** explica qué ejecuta el CI, qué no (la prueba de integración) y cómo reproducir los mismos comandos en local (NFR8)
