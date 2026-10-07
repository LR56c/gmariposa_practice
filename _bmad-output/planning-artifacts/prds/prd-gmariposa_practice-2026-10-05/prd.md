---
title: "PRD: Mini Catálogo (Flutter + Riverpod) y Panel de órdenes (Angular)"
status: final
created: 2026-10-05
updated: 2026-10-05
---

# PRD: Mini Catálogo (Flutter + Riverpod) y Panel de órdenes (Angular)
*Título de trabajo, a confirmar.*

## 0. Propósito del documento

Este PRD traduce la prueba técnica de Grupo Mariposa en requisitos funcionales numerados y verificables, para que `bmad-ux`, `bmad-architecture` y `bmad-create-epics-and-stories` trabajen sobre un vocabulario único. Se apoya en el brief (`_bmad-output/planning-artifacts/briefs/brief-gmariposa_practice-2026-10-05/brief.md`) y en el PDF de la prueba, que queda fuera del repo; no repite el contexto del brief. Los términos del Glosario (§3) se usan sin sinónimos. Los supuestos ya fueron confirmados por Mauri y se indexan en §10. Las decisiones técnicas del candidato están en `addendum.md`.

## 1. Visión

Dos entregables pequeños y bien hechos sobre la API pública DummyJSON: una app móvil Flutter con Riverpod para explorar un catálogo y armar un carrito, y un panel web Angular que muestra órdenes con filtro. El valor no está en las funcionalidades, sino en la calidad del código, la arquitectura por capas y las pruebas, que el candidato debe poder defender línea por línea en la entrevista.

El PDF reparte la nota así: Parte 2 Flutter 50 % (6 a 8 h sugeridas), Parte 3 Angular 20 % (2 a 3 h), Parte 1 preguntas 15 % (30 min) y Parte 4 code review 15 % (20 min). Documentar lo pendiente en el README es preferible a entregar código roto.

## 2. Usuario objetivo

### 2.1 Jobs To Be Done

- **Candidato (Mauri):** entregar una prueba que cumpla todos los obligatorios con calidad verificable, y explicar cada decisión y cada línea en la entrevista de seguimiento.
- **Evaluador (Grupo Mariposa):** ver de un vistazo, en el repo, el criterio del candidato: capas, estado inmutable, pruebas, README honesto y un historial de commits real.

### 2.2 No usuarios (v1)

Clientes finales reales: no hay tienda, pagos ni cuentas. Los datos son los de DummyJSON.

### 2.3 Viajes de usuario clave

*Viajes inferidos del PDF y confirmados por Mauri el 2026-10-05.*

- **UJ-1. Lucía, evaluadora, recorre la app Flutter.**
  - **Persona + contexto:** Lucía, ingeniera de Grupo Mariposa, revisa la entrega con el repo clonado y un emulador.
  - **Estado de entrada:** app recién abierta, con red.
  - **Recorrido:** ve el Catalog (imagen, título, precio y rating); escribe "phone" y, tras una pausa, el Catalog se filtra; abre el detalle de un Product; lo agrega al Cart y ve subir el contador del AppBar; abre el Cart, cambia una cantidad y ve el total actualizado.
  - **Clímax:** el total y el contador reflejan el cambio sin recargar nada.
  - **Resolución:** el Cart conserva su contenido al volver al Catalog.
  - **Caso límite:** sin red, el Catalog muestra un error con botón de reintentar.

- **UJ-2. Lucía revisa el panel Angular.**
  - **Persona + contexto:** la misma Lucía, ahora en el navegador.
  - **Estado de entrada:** panel abierto con red.
  - **Recorrido:** ve la lista de Orders con `userId` y total; filtra por total mínimo; pulsa "ver detalle" en un Order.
  - **Clímax:** la lista se reduce de forma reactiva al filtro.
  - **Resolución:** el Order elegido muestra sus productos en la misma página.
  - **Caso límite:** si la API falla, ve un estado de error y no una pantalla en blanco.

## 3. Glosario

- **Product** (Producto): artículo del catálogo de DummyJSON con id, título, precio, rating e imagen. Se muestra en el Catalog y en el detalle.
- **Catalog** (Catálogo): lista de Products, filtrable por Search term.
- **Search term** (Término de búsqueda): texto que el Usuario escribe; dispara una consulta tras 400 ms de pausa.
- **Cart** (Carrito): colección local, solo en la app Flutter, de Cart items. Tiene un total y un contador.
- **Cart item** (Ítem del carrito): un Product con una cantidad dentro del Cart.
- **Order** (Orden): registro de la API de carritos de DummyJSON (`/carts`), con `userId`, productos y totales, que el panel Angular muestra. No es un Cart.
- **Repository** (Repositorio de datos): único punto por el que la UI obtiene datos; en Angular es el servicio `OrdersService`.
- **BaseException** (Excepción base): error tipado del proyecto, en el estilo common del candidato, con `message` y `code`; cada tipo de falla es una subclase.
- **Errors** (Errores): contenedor con la lista de BaseException de una operación. Vive en `core/` (decisión T-1). La UI recibe un Errors en lugar de una excepción cruda, y los métodos pueden devolverlo como `Either<Errors, T>`.
- **Usuario:** quien interactúa con la app o el panel; en la entrega, el Evaluador.
- **Evaluador:** persona de Grupo Mariposa que revisa la entrega.
- **Candidato:** persona que entrega la prueba.
- **Repo:** repositorio git público de la entrega. No confundir con Repository.

## 4. Funcionalidades

### 4.1 Catálogo de Products (Flutter)
**Descripción:** al abrir la app, el Usuario ve el Catalog con los primeros 20 Products. Cada elemento muestra imagen, título, precio y rating. Realiza UJ-1.

**Requisitos funcionales:**

#### FR-1: Listar el Catalog
El Usuario puede ver una lista de Products con imagen, título, precio y rating. Realiza UJ-1.

**Consecuencias (verificables):**
- Al abrir la app se cargan los primeros 20 Products desde `GET /products?limit=20&skip=0`.
- Cada elemento muestra los cuatro datos; si falta la imagen, se muestra un marcador visual y no un error.

**Fuera de alcance:** filtro por categoría (deseable, ver §6.2). La paginación infinita (DF-1) entra al MVP (ver §6.1).

#### FR-2: Estados del Catalog
El Usuario ve siempre uno de cuatro estados: cargando, datos, vacío o error. Realiza UJ-1.

**Consecuencias (verificables):**
- Mientras carga, se muestra un indicador de progreso.
- Si la API falla, se muestra un mensaje de error y un botón "Reintentar", que repite la consulta.
- Si la consulta devuelve cero Products, se muestra un estado vacío con texto, no una lista en blanco.
- El error mostrado proviene de un Errors, no de una excepción cruda.

**Notas:** el estado vacío se prueba con un Repository falso, porque DummyJSON no devuelve listas vacías sin búsqueda.

### 4.2 Búsqueda (Flutter)
**Descripción:** el Usuario escribe un Search term y el Catalog se reemplaza por los resultados, sin disparar una consulta por tecla. Realiza UJ-1.

**Requisitos funcionales:**

#### FR-3: Buscar con debounce
El Usuario puede escribir un Search term y ver los Products que coinciden. Realiza UJ-1.

**Consecuencias (verificables):**
- La consulta (`GET /products/search?q=…&limit=20&skip=0`) se dispara solo tras 400 ms sin nuevas pulsaciones. El Search term se recorta (`trim`) antes de consultar; un término vacío o solo con espacios equivale a vaciarlo.
- Escribir 5 caracteres seguidos con menos de 400 ms entre ellos produce una sola consulta.
- Vaciar el Search term vuelve a mostrar el Catalog completo.
- Los resultados usan los mismos cuatro estados que FR-2.
- Si llega la respuesta de un Search term ya reemplazado, se descarta y no pisa la lista. Vaciar el Search term cancela cualquier consulta pendiente.
- "Reintentar" repite la consulta del Search term vigente.

**Notas:** `limit` y `skip` se envían desde el MVP para que la paginación infinita (DF-1) cubra Catalog y búsqueda sin cambiar el contrato del Repository (ver FR-10). `[NOTE FOR PM: cómo se implementa el debounce —Timer propio o paquete— y dónde vive se decide en el coaching de arquitectura.]`

**NFR específicos de esta funcionalidad:**
- La búsqueda y el Catalog comparten el mismo mecanismo de estados, sin duplicar la lógica. Los widgets cumplen NFR-5.

### 4.3 Detalle de Product (Flutter)
**Descripción:** al tocar un Product del Catalog, el Usuario abre una pantalla que recibe solo el `id` y carga el Product por su cuenta. Realiza UJ-1.

**Requisitos funcionales:**

#### FR-4: Ver el detalle de un Product
El Usuario puede abrir el detalle de un Product a partir de su `id`. Realiza UJ-1.

**Consecuencias (verificables):**
- La pantalla de detalle recibe únicamente el `id` y consulta `GET /products/{id}` mediante un provider `family`.
- Se muestran, como mínimo, imagen, título, precio, rating y un botón para agregar al Cart.
- Abrir dos detalles distintos no mezcla datos: cada `id` tiene su propio estado.

#### FR-5: Estados del detalle
El Usuario ve cargando, datos o error al abrir un detalle. Realiza UJ-1.

**Consecuencias (verificables):**
- Mientras carga, se muestra un indicador de progreso.
- Si la API falla o el `id` no existe, se muestra el error de un Errors y un botón "Reintentar".

**Notas:** el detalle no reutiliza los datos del Catalog; siempre consulta por `id`, porque así lo pide el PDF.

### 4.4 Cart (Flutter)
**Descripción:** el Usuario agrega Products al Cart desde el detalle, cambia cantidades, quita ítems y ve el total. El contador del AppBar es visible desde cualquier pantalla. El Cart vive solo en memoria en el MVP. Realiza UJ-1.

**Requisitos funcionales:**

#### FR-6: Agregar un Product al Cart
El Usuario puede agregar un Product al Cart desde el detalle. Realiza UJ-1.

**Consecuencias (verificables):**
- Agregar un Product que no está en el Cart crea un Cart item con cantidad 1.
- Agregar un Product que ya está en el Cart incrementa la cantidad de su Cart item en 1, sin crear un duplicado.

#### FR-7: Cambiar la cantidad de un Cart item
El Usuario puede aumentar o disminuir la cantidad de un Cart item. Realiza UJ-1.

**Consecuencias (verificables):**
- Aumentar suma 1 y disminuir resta 1 a la cantidad.
- La cantidad nunca queda por debajo de 1 mediante disminuir; para eliminar el ítem se usa FR-8. Disminuir desde 1 no elimina el Cart item.

#### FR-8: Quitar un Cart item
El Usuario puede quitar un Cart item del Cart. Realiza UJ-1.

**Consecuencias (verificables):**
- El Cart item desaparece y el total y el contador se actualizan.
- Quitar el último Cart item deja el Cart vacío, con un estado vacío visible.

#### FR-9: Total y contador
El Usuario ve el total del Cart y un contador en el AppBar, desde cualquier pantalla. Realiza UJ-1.

**Consecuencias (verificables):**
- El total es la suma de precio × cantidad de todos los Cart items, mostrado con dos decimales y sin símbolo de moneda.
- El contador del AppBar muestra la cantidad total de unidades, no la de Cart items distintos.
- El contador es visible en el Catalog, el detalle y el Cart.

**Fuera de alcance:** persistencia del Cart entre sesiones (deseable, ver §6.2).

**NFR específicos de esta funcionalidad:**
- La lógica del Cart (agregar, cambiar cantidad, quitar, total) no depende de la UI, para poder probarla con pruebas unitarias. El estado cumple NFR-5 (inmutable).

### 4.5 Capa de datos y errores (Flutter)
**Descripción:** la UI nunca habla con la red. Obtiene los datos a través de un Repository inyectado, recibe modelos inmutables y, cuando algo falla, un Errors tipado. Es lo que permite probar sin red y explicar el flujo de punta a punta. Realiza UJ-1.

**Requisitos funcionales:**

#### FR-10: Acceso a datos solo a través del Repository
Toda obtención de Products pasa por un Repository inyectado mediante un provider. Realiza UJ-1.

**Consecuencias (verificables):**
- Ningún widget ni notifier importa ni invoca el cliente HTTP directamente.
- Sustituir el Repository por uno falso con un `override` cambia los datos mostrados sin tocar la UI.
- El Repository expone el contrato en la capa de dominio y su implementación vive en la capa de datos.
- Los métodos de listado y de búsqueda de Products reciben `limit` y `skip` (por defecto 20 y 0) y devuelven también el `total` de la API, de modo que DF-1 se añade sin cambiar el contrato.

#### FR-11: Modelos inmutables con `fromJson`
Los Products y demás modelos se construyen desde el JSON de DummyJSON y no pueden modificarse después. Realiza UJ-1.

**Consecuencias (verificables):**
- Ningún modelo tiene campos mutables.
- `fromJson` de un Product convierte una respuesta real de ejemplo de DummyJSON sin perder id, título, precio, rating ni imagen.
- Un JSON con un campo requerido ausente o de tipo erróneo produce un BaseException de parseo y no un error genérico. La forma de construir los modelos (decisión T-4 del `addendum.md`) se justifica en el README, como pide el PDF.

#### FR-12: Errores tipados hacia la UI
Los errores de red, de respuesta y de parseo llegan a la UI como un Errors. Realiza UJ-1.

**Consecuencias (verificables):**
- Una falla de conexión, una respuesta no exitosa y un fallo de parseo corresponden cada una a una subclase de BaseException distinta, con `message` y `code`.
- La UI nunca recibe una excepción cruda de `http` o `dio`.
- El mensaje que ve el Usuario se deriva del Errors, no se construye en el widget.

**Notas:** decisiones T-1 a T-3 en `addendum.md`; la UI usa `AsyncValue` con pattern matching. `[NOTE FOR PM: la integración entre Either y AsyncValue se valida en el coaching de arquitectura.]` Obligatorio por decisión del candidato; el PDF lo lista como deseable.

**NFR específicos de esta funcionalidad:**
- Estructura sugerida por el PDF (no obligatoria): `core/` para cliente, errores y tema; `features/<feature>/{data,domain,presentation}`.

### 4.6 Panel de Orders (Angular)
**Descripción:** vista web que muestra los Orders de `GET https://dummyjson.com/carts` como un panel administrativo, con un filtro reactivo y los estados de carga y error. No replica la app móvil: verifica fundamentos de Angular. Realiza UJ-2.

**Requisitos funcionales:**

#### FR-13: Listar los Orders
El Usuario puede ver una lista de Orders, cada uno en su tarjeta. Realiza UJ-2.

**Consecuencias (verificables):**
- Un servicio `OrdersService` (`providedIn: 'root'`) obtiene los datos con `HttpClient` (`GET /carts?limit=0`, que devuelve todos los Orders) y los expone tipados con interfaces.
- Ningún componente llama a `HttpClient` directamente.
- `OrdersPageComponent` (contenedor) obtiene los Orders y renderiza un `OrderCardComponent` (presentacional) por cada uno.
- Cada tarjeta muestra al menos el id del Order, su `userId` y su total, y también el total con descuento si DummyJSON lo incluye.
- No hay `any` sin justificación en el código del servicio ni de los componentes.

#### FR-14: Filtrar por total mínimo
El Usuario puede filtrar los Orders por un total mínimo. Realiza UJ-2.

**Consecuencias (verificables):**
- El filtro usa el campo `total` del Order (no el total con descuento) y se captura con un `FormControl` (o un signal) que actualiza el store manual de Angular (AD-16), dueño del estado del filtro.
- Al cambiar el valor del filtro, la lista se actualiza sin recargar la página ni repetir la petición, porque se aplica sobre los datos ya cargados.
- Un Order cuyo `total` es igual al mínimo se incluye (comparación `>=`).
- Con el filtro vacío se muestran todos los Orders.
- Si ningún Order cumple el filtro, se muestra un mensaje de vacío y no una lista en blanco.

**Notas:** se eligió filtrar por total mínimo y no por usuario; el PDF acepta cualquiera de los dos.

#### FR-15: Estados de carga y error
El Usuario ve un estado de carga mientras llegan los datos y un estado de error si falla la API. Realiza UJ-2.

**Consecuencias (verificables):**
- Mientras se obtienen los Orders, se muestra un indicador de carga.
- Si la API falla, se muestra un mensaje de error legible con un botón "Reintentar" que repite la petición, y no una pantalla en blanco.

#### FR-16: Ver el detalle de un Order
El Usuario puede pedir el detalle de un Order desde su tarjeta. Realiza UJ-2.

**Consecuencias (verificables):**
- `OrderCardComponent` recibe el Order por `input()` (o `@Input()`) y emite el id del Order por `output()` (o `@Output()`) cuando se pulsa "ver detalle".
- La tarjeta no navega ni consulta datos: el contenedor decide qué hacer con el evento.
- Al recibir el evento, el contenedor navega a `/orders/:id` (ruta con lazy loading), que muestra los productos del Order elegido (título, cantidad y precio de cada uno).

**Notas:** decisión de arquitectura (2026-10-06): el detalle es una ruta autosuficiente desde la URL, así que DA-1 pasa de deseable a parte del MVP.

#### FR-17: Sin fugas de memoria
Ninguna suscripción queda abierta cuando el componente se destruye. Realiza UJ-2.

**Consecuencias (verificables):**
- Los datos se consumen con `async` pipe, `toSignal`, `takeUntilDestroyed` o equivalente.
- No existe ningún `subscribe()` sin limpieza.

**NFR específicos de esta funcionalidad:**
- Se aplican NFR-4 (pruebas) y NFR-6 (base de Angular).

### 4.7 Documentos escritos y entrega
**Descripción:** las Partes 1 y 4 (30 % de la nota) y el Repo como entregable. Son texto y estructura, no pantallas, pero se evalúan igual. El candidato redacta las respuestas con sus palabras, partiendo de un borrador de apoyo (`borrador-respuestas-parte1.md`) y haciendo coaching y revisión, porque debe poder explicar cada línea en la entrevista. Se escriben al final, con las dos apps construidas, porque el code review y varias preguntas se apoyan en el código propio.

**Requisitos funcionales:**

#### FR-18: Responder las preguntas conceptuales (Parte 1)
El Candidato responde las 20 preguntas conceptuales en `RESPUESTAS.md`. Realiza el JTBD del Candidato (§2.1).

**Consecuencias (verificables):**
- Hay 20 respuestas numeradas igual que en el PDF.
- Cada respuesta ocupa de 3 a 6 líneas, con frases propias y, cuando aplique, un ejemplo corto de código.

#### FR-19: Hacer el code review (Parte 4)
El Candidato revisa los dos fragmentos del PDF, A (Flutter) y B (Angular), en `RESPUESTAS.md`. Realiza el JTBD del Candidato (§2.1).

**Consecuencias (verificables):**
- Cada problema indica qué está mal, por qué importa y cómo se corrige.
- Incluye la reescritura del Fragmento A (Flutter) aplicando las correcciones.
- La reescritura es coherente con la arquitectura del proyecto (Repository, Riverpod, Errors).
- La Parte 4 también puede pedirse en vivo: el Candidato puede explicar cada hallazgo sin leer el documento.

#### FR-20: README en la raíz
El Repo incluye un `README.md` en la raíz. Realiza el JTBD del Evaluador (§2.1).

**Consecuencias (verificables):**
- Explica cómo ejecutar `flutter_app/` y `angular_app/`.
- Documenta las decisiones de arquitectura, lo que quedó pendiente y lo que se mejoraría con más tiempo; lo no terminado se documenta en lugar de entregarse roto.
- Justifica cómo se construyen los modelos (T-4) y menciona los paralelos entre Flutter y Angular: servicio ≈ Repository, signal u Observable ≈ provider, componente presentacional ≈ widget sin estado.

#### FR-21: Estructura del Repo e historial
El Repo público contiene `flutter_app/` y `angular_app/` y un historial de commits real. Realiza el JTBD del Evaluador (§2.1).

**Consecuencias (verificables):**
- Existen las dos carpetas en la raíz, cada una con sus propias convenciones y comandos.
- Hay una rama por story, con el formato `<tipo>/<epic>-<story>-<slug>`, que se fusiona a `main` al cerrar la story.
- Los commits siguen Conventional Commits con alcance `flutter`, `angular`, `docs` o `repo`; no existe un único commit final.
- El PDF de la prueba no forma parte del Repo ni de su historial, y se ignora con `.gitignore`.

**Fuera de alcance:** despliegue, publicación en tiendas y documentación de usuario final.

### 4.8 Requisitos transversales de calidad
*Aplican a todas las funcionalidades. Son los puntos del PDF que se evalúan como restricciones y no como pantallas; fallan en silencio si se dejan para el final.*

- **NFR-1 (estado):** el estado de negocio de Flutter se gestiona solo con Riverpod 2.x o 3.x, con al menos un `AsyncNotifier` o `FutureProvider` y un `Notifier`. No se usa `setState` ni `flutter_hooks` para estado de negocio.
- **NFR-2 (análisis estático):** `flutter analyze` termina sin warnings, con `flutter_lints` o `very_good_analysis`.
- **NFR-3 (pruebas Flutter):** al menos 3 pruebas unitarias (por ejemplo, la lógica del Cart) y 1 de widget, con `ProviderContainer` u `overrides` y un Repository falso.
- **NFR-4 (pruebas Angular):** al menos 2 pruebas unitarias: el servicio con `HttpTestingController` y/o un componente.
- **NFR-5 (prácticas observadas):** widgets pequeños con `const` donde corresponda y sin lógica de negocio; `ref.watch` en `build` y `ref.read` solo en callbacks; estado inmutable (cada cambio crea una nueva lista, nunca muta la existente); nombres claros y consistentes en todo el proyecto; sin código muerto, `print` de depuración ni valores mágicos sin constante.
- **NFR-6 (base de Angular):** Angular 17 o superior, componentes standalone y TypeScript en modo `strict`, sin `any` injustificado.
- **NFR-7 (interfaz):** interfaz ordenada y consistente; no se requiere diseño visual elaborado.
- **NFR-8 (reproducibilidad):** cada proyecto se ejecuta con los comandos documentados en el README, desde un clon limpio.
- **NFR-9 (idioma):** código e identificadores en inglés; README, `RESPUESTAS.md` y documentos en español; consistente en todo el proyecto.

## 5. No objetivos

- Backend propio: ambas apps consumen DummyJSON tal cual.
- Autenticación, cuentas de usuario y roles.
- Pagos, checkout y sincronización del Cart con la API.
- Edición de Orders: el panel Angular es de solo lectura.
- Replicar la app móvil en Angular: el panel verifica fundamentos de Angular.
- Despliegue, publicación en tiendas y CI/CD obligatorio (el GitHub Action es un bonus).
- Cumplimiento normativo de datos personales: no se tratan datos reales.
- Diseño visual elaborado.

## 6. Alcance del MVP

### 6.1 Dentro del alcance
- FR-1 a FR-21 y NFR-1 a NFR-9.
- `riverpod_generator` desde el inicio (decisión T-5 del `addendum.md`).
- Navegación con `go_router` (decisión de Mauri, 2026-10-06; antes DF-4). Rutas `/`, `/product/:id` y `/cart`.
- Paginación infinita en el Catalog y en la búsqueda (DF-1 promovido al MVP, decisión de Mauri, 2026-10-06).
- Deep link a `/product/:id` verificado en el emulador Android con `adb` (decisión de arquitectura AD-9).
- Angular: estado con un store manual con signals (sin NgRx), estilos con Tailwind, y validación y errores con `effect` (solo `Schema` y `Result`), según `ARCHITECTURE-SPINE.md` (AD-16, AD-17). Flutter: `dio`, `stream_transform` para el debounce, `mocktail` y `very_good_analysis`.
- Apoyo de UX: dirección visual con `bmad-ux` y un Stitch pequeño con 4 pantallas (listado, detalle, carrito y panel de órdenes), con un índice pantalla ↔ story que actúa como gate en las stories de UI.

**Angular priorizado.** Lo que el PDF pide para Angular se prioriza. Estos deseables se hacen apenas se cierran los obligatorios de Angular, antes que cualquier deseable o bonus de Flutter:

| ID | Ítem |
|---|---|
| DA-1 | Ruta `/orders/:id` con lazy loading (promovido al MVP, ver FR-16) |
| DA-2 | Signals de lectura (`toSignal`, `computed`) sobre los selectores del Store |
| DA-3 | Control flow nuevo (`@if`, `@for` con `track`) |
| DA-4 | Pipe propio (moneda o porcentaje de descuento) |
| DA-5 | `ChangeDetectionStrategy.OnPush` en los presentacionales |

### 6.2 Fuera del alcance del MVP (deseables y bonus)
*Regla de corte: cada ítem solo empieza cuando los obligatorios de su parte están cerrados, probados y con `analyze` limpio. Orden de apertura: obligatorios de Flutter y Angular, luego los DA, luego los DF y por último los B. Los IDs permiten convertirlos en stories si se llega a ellos.*

| ID | Parte | Ítem |
|---|---|---|
| DF-2 | Flutter | Filtro por categoría (`GET /products/categories`), combinable con la búsqueda; selector en un modal con `wolt_modal_sheet`. Bonus planificado (story 5.2) |
| DF-3 | Flutter | Persistencia del Cart con `shared_preferences` (decidido). Bonus planificado (story 5.3) |
| DF-6 | Flutter | Tema claro/oscuro controlado por un provider |
| B-1 | Flutter | Prueba de integración del flujo buscar → detalle → agregar al Cart. Bonus planificado (story 5.4) |
| B-2 | Repo | GitHub Action que ejecute `analyze` y `test` en cada push. Bonus planificado (story 5.5) |

`[NOTE FOR PM: DF-5 (errores tipados) se integró como FR-12, y el bonus riverpod_generator está dentro del alcance desde el inicio.]`

## 7. Métricas de éxito

*Cada métrica indica qué requisitos valida. Las contramétricas evitan optimizar lo equivocado.*

**Primarias**
- **SM-1:** `flutter analyze` termina con 0 warnings. Valida NFR-2.
- **SM-2:** pasan al menos 3 pruebas unitarias y 1 de widget en Flutter, y 2 pruebas en Angular. Valida NFR-3 y NFR-4.
- **SM-3:** cada obligatorio del PDF está cumplido. Flutter 1 a 9 → FR-1 a FR-12, NFR-1, NFR-2 y NFR-3; Angular 1 a 7 → FR-13 a FR-17, NFR-4 y NFR-6; Partes 1 y 4 → FR-18 y FR-19. Valida FR-1 a FR-21 y NFR-1 a NFR-9.
- **SM-4:** el Candidato explica, sin mirar el código, cómo fluye un provider desde la UI hasta el Repository, por qué usa `ref.read` en un callback, y cómo fluye un Order desde `OrdersService` hasta la tarjeta. Se mide con un ensayo antes de entregar. Valida FR-10, FR-12, FR-13 y NFR-1.
- **SM-5:** el README contiene los cuatro elementos pedidos (ejecución, decisiones, pendientes, mejoras). Valida FR-20.
- **SM-6:** hay al menos una rama por story, todos los commits siguen Conventional Commits y existe más de un commit. Valida FR-21.
- **SM-7:** la entrega ocurre dentro del plazo de 3 días calendario. Valida el objetivo de entrega del brief; ningún FR lo cubre.

**Secundaria**
- **SM-8:** cantidad de deseables y bonus completados (ver §6.1 y §6.2), contados solo si los obligatorios de su parte están cerrados. Valida DA-1 a DA-5, DF-1 a DF-3, DF-6, B-1 y B-2.

**Contramétricas (no optimizar)**
- **SM-C1:** deseables o bonus iniciados. Un extra a medias es peor que ninguno; contrapesa SM-8.
- **SM-C2:** velocidad de entrega. No se sacrifica la comprensión del código por entregar antes; contrapesa SM-7 y protege SM-4.

## 8. Riesgos y mitigaciones

- **Tiempo y extras a medias:** sin plan de horas por día, y se intentan los deseables y bonus. Mitigación: la regla de corte, el orden de apertura de §6.2 y documentar lo pendiente en lugar de entregar código roto.
- **Carga de herramientas (`freezed`, `riverpod_generator`, `build_runner`, `Either`) sobre las 6 a 8 h sugeridas para Flutter.** Plan B: si `build_runner` o la compatibilidad de versiones consume más de 2 h sin avanzar, se vuelve a modelos manuales (T-4) y/o a Riverpod sin generador (T-5), y se documenta en el README.
- **Código que el candidato no puede explicar.** Mitigación: modo coaching en cada decisión técnica y el ensayo de SM-4.
- **DummyJSON caído o con cambios.** Mitigación: pruebas con un Repository falso y sin red.

## 9. Preguntas abiertas

1. Hora y medio exactos de entrega (el PDF fija 3 días calendario desde la recepción).
2. Herramientas generadas (T-2, T-4 y T-5): versión de Riverpod (2.x o 3.x) y compatibilidad con `freezed`, `json_serializable` y `riverpod_generator`; si los archivos generados (`*.g.dart`, `*.freezed.dart`) se incluyen en el Repo o se generan con `build_runner`; y paquete de `Either`, su alcance y su integración con `AsyncValue`.
3. Resuelta (2026-10-06): `dio`.
4. Resuelta: paquete `stream_transform`.
5. Resuelta: `very_good_analysis`.
6. Resuelta (2026-10-06): navegación con `go_router` dentro del MVP (ver §6.1).
7. Resuelta: Angular 22 y Vitest; estado con store manual (sin NgRx) y estilos con Tailwind.
8. Resuelta: commits en inglés.

## 10. Supuestos confirmados

Mauri confirmó el 2026-10-05 los supuestos del documento: los viajes UJ-1 y UJ-2 y las notas de FR-2, FR-3, FR-5, FR-7, FR-9, FR-13, FR-14 y §4.7. Cada uno quedó escrito como regla en su requisito.
