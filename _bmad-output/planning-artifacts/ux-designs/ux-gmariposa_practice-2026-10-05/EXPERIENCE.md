---
version: alpha
name: Mini Catálogo / Panel de Órdenes — Experiencia
status: final
updated: 2026-10-06
sources:
  - _bmad-output/planning-artifacts/briefs/brief-gmariposa_practice-2026-10-05/brief.md
  - _bmad-output/planning-artifacts/prds/prd-gmariposa_practice-2026-10-05/prd.md
  - _bmad-output/planning-artifacts/prds/prd-gmariposa_practice-2026-10-05/addendum.md
design: ./DESIGN.md
---

Cómo se comporta el producto. Cómo se ve vive en `DESIGN.md` (tokens como `{colors.primary}`). Los requisitos FR-x son
los del PRD. Qué del mock de Stitch no se construye está en `stitch-index.md`.

**Convenciones del texto.** En el texto corrido se dice "carrito" y "orden"; `Cart` y `Order` solo aparecen como tipos de
código. El texto literal de la UI va entre comillas rectas. Lo marcado `[ASSUMPTION]` es un supuesto a confirmar.

## Foundation

- **Dos superficies independientes**: app **Flutter** móvil vertical (emulador) y panel **Angular** de escritorio
  (navegador). Cada una tiene su código; comparten solo la identidad visual.
- **Datos**: DummyJSON. Sin cuentas, pagos, envíos ni backend propio. El carrito vive en memoria y se pierde al cerrar la
  app (DF-3, persistencia, queda fuera).
- **UI system**: Material 3 en Flutter (`ThemeData` con el `ColorScheme` de `DESIGN.md`); Angular con CSS propio y las
  mismas variables. Este documento solo especifica el comportamiento.
- **Idioma de la UI**: español [ASSUMPTION; el PRD no lo define]. Código en inglés.
- **Formato de importes** (ambas apps): punto decimal, 2 decimales, sin separador de miles y sin símbolo de moneda
  (FR-9). Ejemplo: `1234.50`.
- **Persona**: Lucía, ingeniera evaluadora, recorre ambas apps buscando orden, consistencia y manejo de estados.

## Information Architecture

**Flutter** (`go_router`, decisión de Mauri el 2026-10-06; PRD §6.1):

| Pantalla | Ruta | Contenido | Sale hacia |
|---|---|---|---|
| Catálogo | `/` | Buscador, lista de productos, contador del carrito | `/product/:id`, `/cart` |
| Detalle | `/product/:id` | Producto por `id` (consulta propia), "Agregar al carrito" | atrás, `/cart` |
| Carrito | `/cart` | Ítems, cantidades, quitar, total | atrás |

- El detalle recibe **solo el `id`** y consulta `GET /products/{id}` (FR-4). Un `id` no numérico (`/product/abc`) o
  inexistente cae en el estado de error, sin excepción cruda (FR-12). Una ruta desconocida muestra una pantalla de error
  con un botón para volver a `/` (`errorBuilder`).
- Del Catálogo al Detalle y del Catálogo al Carrito se navega con `push`, para que "atrás" vuelva a la pantalla anterior.
- Sin barra inferior, menú lateral ni pestañas. El contador del AppBar es el acceso al carrito.

**Angular**: una sola página, `OrdersPageComponent`, con un `OrderCardComponent` por orden. Sin routing en el MVP;
`/orders/:id` lazy (DA-1) es evolución futura.

## Key Flows

### UJ-1 — Lucía revisa el catálogo (Flutter, con red)
1. Lucía abre **Mini Catálogo** y ve los primeros 20 productos con imagen, título, precio y rating.
2. Escribe "phone" en el buscador y, tras una pausa de 400 ms, la lista se filtra.
3. Toca un producto y el detalle carga por `id`.
4. Pulsa **Agregar al carrito** y el contador del AppBar sube.
5. Abre el carrito, sube la cantidad de un ítem y quita otro.
6. **Clímax**: el total y el contador cambian al instante, sin recargar.
7. Vuelve atrás hasta el Catálogo: el carrito sigue ahí y el buscador conserva el término y los resultados.

Casos límite: sin red ve el mensaje de error con **Reintentar**. Quitar el último ítem muestra "Tu carrito está vacío".

### UJ-2 — Lucía revisa el panel (Angular)
1. Lucía abre el panel y ve las órdenes con `userId` y total.
2. Escribe un total mínimo en el filtro.
3. **Clímax**: la lista se reduce al instante, sin recargar ni repetir la petición.
4. Pulsa **Ver detalle** en una orden y ve sus productos (título, cantidad, precio) en la misma página.

Casos límite: si la API falla ve un mensaje de error con **Reintentar**. Si ninguna orden alcanza el total ve el mensaje
de vacío.

## Voice and Tone

Neutro, breve y directo, sin jerga técnica. Tuteo ("Revisa tu conexión"), sin signos de exclamación. Los textos de
error se derivan de `Errors` en Flutter (FR-12) y de `OrdersService` en Angular; el widget no los escribe.

| Contexto | Texto [ASSUMPTION] |
|---|---|
| Título Flutter | Mini Catálogo |
| Placeholder del buscador | Buscar productos |
| Catálogo vacío (sin término) | No hay productos |
| Búsqueda sin resultados | Sin resultados para "{término}" |
| Imagen faltante | Sin foto |
| Acción de error | Reintentar |
| Detalle | Agregar al carrito |
| Carrito | Carrito · Quitar · Total {importe} |
| Contador de unidades | 0 → "Carrito vacío"; 1 → "1 unidad"; otro → "{n} unidades" |
| Carrito vacío | Tu carrito está vacío |
| Órdenes | Órdenes · Total mínimo · Ver detalle · Ocultar detalle |
| Filtro sin coincidencias | Ninguna orden alcanza ese total |
| Orden sin productos | Esta orden no tiene productos |

**Textos de error** (misma tabla para Flutter, vía `BaseException.code`, y para Angular):

| Causa | Texto [ASSUMPTION] |
|---|---|
| Conexión | No se pudo conectar. Revisa tu conexión. |
| Respuesta no exitosa | Algo salió mal. Inténtalo de nuevo. |
| Producto inexistente (404) o `id` inválido | No encontramos ese producto. |
| Parseo | No se pudo leer la respuesta. Inténtalo de nuevo. |

## Component Patterns

- **Lista de productos**: cada elemento es táctil y abre el detalle. Sin acciones secundarias por ítem. Una imagen
  faltante muestra el marcador "Sin foto" (también en el detalle y el carrito), no un error.
- **Contador del carrito (badge)**: suma las **unidades**, no los ítems distintos (FR-9). Con 0 unidades se oculta el
  badge y el ícono sigue visible. Pasadas 99 unidades muestra "99+". Presente en Catálogo, Detalle y Carrito.
- **Cantidad −/+**: "+" suma 1; "−" resta 1 con mínimo 1. En cantidad 1, "−" está deshabilitado y **no elimina**
  (FR-7).
- **Quitar**: acción separada que elimina el ítem completo (FR-8). Sin diálogo de confirmación [ASSUMPTION].
- **Agregar al carrito**: un producto nuevo entra con cantidad 1; uno existente suma 1 y nunca se duplica (FR-6). La app
  confirma con un `SnackBar` breve "Agregado al carrito" [ASSUMPTION] y el contador sube.
- **Total del carrito**: Σ precio × cantidad, calculado en centavos enteros (o redondeado al final) para evitar errores
  de coma flotante, con 2 decimales (FR-9). Con el carrito vacío no hay pie con total.
- **Tarjeta de orden (Angular)**: es presentacional; "Ver detalle" **emite el id** al contenedor, que muestra los
  productos de esa orden en la misma página (FR-16). "Ocultar detalle" cierra el detalle [ASSUMPTION]. Solo una orden
  queda expandida a la vez [ASSUMPTION]; si el filtro oculta la orden expandida, el detalle se cierra.
- **Tabla de productos de la orden**: "Precio" es el precio unitario (2 decimales); sin símbolo de moneda.
- **Filtro "Total mínimo"**: campo numérico; compara `total >= mínimo` contra el `total` (no el descontado) y un
  mínimo vacío muestra todas las órdenes (FR-14). Un valor no numérico (incluida la coma decimal) se trata como vacío.
  El campo se deshabilita mientras las órdenes cargan o si la carga falló.

## State Patterns

Los mismos cuatro estados rigen Catálogo y búsqueda (FR-2, FR-3), Detalle (FR-5) y Órdenes (FR-14, FR-15).

| Superficie | Cargando | Datos | Vacío | Error |
|---|---|---|---|---|
| Catálogo / búsqueda | Indicador o skeleton centrado | Lista de hasta 20 productos | "No hay productos" o "Sin resultados para…"; nunca una lista en blanco | Mensaje + **Reintentar** (repite la consulta vigente) |
| Detalle | Indicador de progreso | Producto | n/a | Mensaje + **Reintentar** (incluye `id` inexistente) |
| Carrito | n/a (memoria) | Ítems + total | "Tu carrito está vacío" | n/a |
| Órdenes | Indicador de progreso | Tarjetas | "Ninguna orden alcanza ese total" | Mensaje + **Reintentar** (recarga `/carts`) |

- Sin red: error con **Reintentar**. No hay modo offline ni caché.
- Reintentar repite la consulta y vuelve a cargando.
- Los estados no tienen pantalla en Stitch; los define este documento. Las direcciones visuales de apoyo están en
  `.working/`.

## Interaction Primitives

- **Búsqueda con debounce de 400 ms**: 5 teclas rápidas producen **una** consulta (FR-3). La consulta usa
  `limit=20&skip=0` y el término recortado (`trim`); un término vacío o solo con espacios equivale a vaciarlo y
  vuelve al Catálogo completo. Vaciar el campo cancela el Timer y descarta cualquier respuesta en vuelo. Una respuesta
  de un término ya reemplazado se **descarta**. Timer propio o paquete es decisión técnica y no cambia el comportamiento.
- **Volver atrás**: el estado de búsqueda (término y resultados) vive en un provider que no se destruye al navegar, así
  que sobrevive al paso por el detalle.
- **Navegación**: `push` de `go_router`; "atrás" del sistema respeta la pila.
- **Filtro Angular**: reactivo (`FormControl` o signal), sin repetir la petición ni recargar (FR-14). El panel pide
  `GET /carts?limit=0` para traer todas las órdenes (FR-13).
- **Movimiento**: transiciones por defecto de Material, sin animaciones propias; se respeta "reducir movimiento".

### Preparado para paginación infinita (DF-1, fuera del MVP)

El Catálogo y la búsqueda ya piden `limit=20&skip=0` y el Repository devuelve el `total` de la API (FR-10), así que
DF-1 no cambia el contrato. En el MVP solo se muestra la primera página, sin "ver más". Al activar DF-1:

- Al llegar a unos 200 px del final de la lista se pide la siguiente página (`skip += 20`), con una sola petición en
  vuelo a la vez.
- El pie de la lista muestra un indicador mientras carga la página siguiente.
- Si esa página falla, el pie muestra el mensaje y **Reintentar**, y la lista ya cargada se conserva.
- Cuando `skip + 20 >= total`, el pie muestra "No hay más productos" y no se piden más páginas.
- Cambiar o vaciar el término reinicia `skip = 0` y descarta las páginas pendientes de términos anteriores.
- Volver desde el detalle conserva la posición de scroll.

## Accessibility Floor

Los documentos no piden accesibilidad; este nivel mínimo es un supuesto del equipo [ASSUMPTION].

- Contraste WCAG AA (verificado en `DESIGN.md` para primario, texto y danger). Áreas táctiles de al menos 48 px.
- Flutter: `Semantics` en el ícono del carrito ("Carrito, 3 unidades", con la misma regla de singular y plural), en
  "−" y "+" ("Disminuir cantidad de {producto}", "Aumentar cantidad de {producto}") y en las imágenes
  (`semanticLabel` = título).
- Angular: foco visible `{colors.focus}` y navegación por teclado (Tab, Enter, Espacio); `label` asociado a "Total
  mínimo"; los cambios de la lista y los errores se anuncian con una región `aria-live="polite"`; botones reales
  (`<button>`). Cada "Ver detalle" lleva `aria-label="Ver detalle de la orden {id}"`, `aria-expanded` y `aria-controls`
  hacia el detalle.
- El estado no se transmite solo con color: el error lleva texto y el "−" deshabilitado está atenuado y marcado como
  deshabilitado.

## Responsive & Platform

- **Flutter**: móvil vertical; sin tablet ni horizontal en el MVP.
- **Angular**: escritorio de 1024 px o más, rejilla de 2 columnas. Por debajo pasa a 1 columna (red de seguridad, no es
  un requisito).

## Open Items

- Copy de la UI, niveles de accesibilidad y los supuestos marcados `[ASSUMPTION]`: a confirmar.
- Timer propio o `easy_debounce` (decisión técnica; no cambia la UX).
- Verificar en vivo el mock de Stitch: ver `stitch-index.md`.
