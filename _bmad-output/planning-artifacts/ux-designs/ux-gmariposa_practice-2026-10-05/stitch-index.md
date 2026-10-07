# Stitch ↔ app: índice de pantallas y diferencias

> **La spec gana sobre el mock.** `DESIGN.md`, `EXPERIENCE.md` y el PRD (FR-x) mandan. Stitch es solo referencia visual:
> si algo del mock no figura aquí como "se mantiene", no se implementa.

Proyecto Stitch: `projects/475278247836846461` · Design system: `assets/15608182579743448115` ("Neutro tonal M3").

## Pendientes de Stitch (única fuente)

- Las dos ediciones de `edit_screens` que eliminaron elementos del mock **no están verificadas**: las capturas que
  entrega la API son anteriores a esas ediciones. Hasta revisar Stitch en vivo, trata como no verificadas las filas
  marcadas "No implementar".
- Borrar en Stitch la copia vieja de Órdenes (`bcdf32db2d5848a28c11b39d79a077a0`), que tiene los ids inventados
  `#ORD-001` y `usr_…`.

## Índice pantalla ↔ story (gate para stories de UI)

| Pantalla | App | Screen ID Stitch | Ruta / contenedor | FR | Story |
|---|---|---|---|---|---|
| Catálogo | Flutter | `0d762685e2044b1da58750a9b667a78c` | `go_router` `/` | FR-1, 2, 3, 9 | 1.3, 1.4, 1.5, 3.2, 3.3, 5.2 |
| Detalle | Flutter | `b0e799e0db0b4c42be81e70c72658b69` | `/product/:id` | FR-4, 5, 6, 9 | 2.1, 3.1, 3.3 |
| Carrito | Flutter | `f6db58a53f334618803f46bd60e49ce7` | `/cart` | FR-6 a 9 | 3.2, 3.3 |
| Órdenes | Angular | `1b9f30e0c87346e89569ed83f17ec75b` | `OrdersPageComponent` (`/`) y detalle en `/orders/:id` | FR-13 a 16 | 4.2, 4.3, 4.4 |

La story 4.1 solo prepara el shell y el tema de Angular; la pantalla Órdenes se construye desde la 4.2.

Sin pantalla en Stitch (solo documentados en `EXPERIENCE.md`): estados de carga, vacío y error, y carrito vacío.

## Transversal: no implementar en ninguna pantalla

Barra inferior, menú lateral o hamburguesa, banners de envío, cupones, subtotales de envío o descuento, sellos de pago,
favoritos, reseñas, chips de categoría (el filtro de DF-2 es un botón con un modal, story 5.2), "Tramitar pedido" y cualquier ícono de filtros fuera del botón de categoría de la story 5.2. Además:

- Importes siempre sin símbolo de moneda y con 2 decimales.
- Ids reales de DummyJSON; no inventar formatos como `#ORD-001` o `usr_…`.
- Todo mensaje de error sale de `Errors` en Flutter (FR-12) y de `OrdersService` en Angular, no del widget.
- Íconos de Material (Flutter: `Icons.*`).
- Los nombres y datos del mock son ilustrativos.

## Diferencias por pantalla

### Catálogo (Flutter)
| Aparece en el mock | Decisión | Motivo |
|---|---|---|
| Botón "agregar al carrito" por ítem | No implementar | FR-4 y FR-6: se agrega desde el detalle |
| Encabezado "Productos disponibles · 5 artículos", "Todos (5)" | No implementar | No pedido |
| Rating con conteo "(128)" | Mostrar solo `★ 4.9` | FR-1: imagen, título, precio y rating |
| 5 productos | La app muestra 20 | FR-1 (`limit=20`) |
| Título truncado con "…" | Se mantiene (1 línea, elipsis) | Evita saltos de layout |
| Marcador "Sin foto" en Powder Canister | Se mantiene | FR-1: la falta de imagen no es un error |
| Contador del carrito en el AppBar | Se mantiene | FR-9 (unidades totales) |

### Detalle (Flutter)
| Aparece en el mock | Decisión | Motivo |
|---|---|---|
| Categoría, "En stock", chips, descripción larga | No implementar | Inventado por Stitch; FR-4 no lo pide |
| Selector de cantidad (− 1 +) | No implementar | Agregar suma 1 (FR-6); la cantidad se edita en el carrito |
| Dots de carrusel | No implementar | No pedido |
| Precio "9.99 €", "$9.99", "IVA incluido" | Solo `9.99` | FR-9: sin símbolo de moneda |
| Datos recibidos del Catálogo | Consultar `GET /products/{id}` | FR-4: recibe solo el `id` |
| Faltan los estados de carga y error | Agregar según `EXPERIENCE.md` | FR-5 |

### Carrito (Flutter)
| Aparece en el mock | Decisión | Motivo |
|---|---|---|
| Ícono de papelera "Vaciar carrito" | No implementar | No pedido |
| Subtítulos de categoría ("Ojos • Máscaras") | No implementar | No pedido |
| Título "Mi Carrito" | Usar "Carrito" | Consistencia |
| "3 artículos" | Usar "3 unidades" (singular: "1 unidad") | FR-9: el contador son unidades |
| Total "32.97" y nombres de producto | Ilustrativos | Total real = Σ precio × cantidad, 2 decimales |
| "−" deshabilitado en cantidad 1 | Se mantiene | FR-7: mínimo 1, disminuir no elimina |
| "Quitar" separado en `#B3261E` | Se mantiene | FR-8 |
| Falta el carrito vacío | Agregar según `EXPERIENCE.md` | FR-8 |

### Órdenes (Angular)
| Aparece en el mock | Decisión | Motivo |
|---|---|---|
| Barra superior "Gestión de Órdenes · Historial · Reportes" y íconos de refrescar | No implementar | Página única, sin navegación |
| Etiqueta "Usuario" | Usar `userId` | FR-13 |
| "Total con descuento" siempre visible | Solo si la orden lo trae | FR-13 |
| Orden #1 expandida de forma fija | "Ver detalle" navega a `/orders/:id`, que muestra los productos | FR-16 |
| "Ocultar detalle" | No implementar | El detalle es una ruta, no una tarjeta expandible |
| Tabla con productos inventados | Datos de `/carts`; "Precio" es unitario | FR-16 |
| Filtro "Total mínimo" con valor 30.00 | Filtra por `total >= mínimo`, no por el descontado; vacío = todas las órdenes | FR-14 |
| Anillo de foco en el primario `#006A60` | Usar `{colors.focus}` (`#0B57D0`) | Foco visible según el tema |
| Faltan carga, error con Reintentar y vacío del filtro | Agregar según `EXPERIENCE.md` | FR-15 |
