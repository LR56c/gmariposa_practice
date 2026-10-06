---
version: alpha
name: Mini Catálogo / Panel de Órdenes
description: Neutro tonal estilo Material 3 para la app Flutter y el panel Angular de una prueba técnica. Utilitario, familiar y sobrio.
status: final
updated: 2026-10-06
colors:
  primary: "#006A60"
  on-primary: "#FFFFFF"
  background: "#FBFDFA"
  surface: "#FFFFFF"
  surface-tonal: "#EDF3F0"
  on-surface: "#191C1B"
  on-surface-muted: "#4A5650"
  outline: "#6F7976"
  divider: "#DCE5E1"
  focus: "#0B57D0"
  danger: "#B3261E"
  on-danger: "#FFFFFF"
  star: "#8A5A00"
  placeholder: "#CDE8E2"
  on-placeholder: "#191C1B"
  skeleton: "#DCE5E1"
typography:
  title-lg:
    fontFamily: Roboto
    fontSize: 22px
    fontWeight: 500
    lineHeight: 28px
  title-md:
    fontFamily: Roboto
    fontSize: 16px
    fontWeight: 500
    lineHeight: 24px
  body-md:
    fontFamily: Roboto
    fontSize: 14px
    fontWeight: 400
    lineHeight: 20px
  label-md:
    fontFamily: Roboto
    fontSize: 12px
    fontWeight: 500
    lineHeight: 16px
  price:
    fontFamily: Roboto
    fontSize: 16px
    fontWeight: 600
    lineHeight: 24px
rounded:
  sm: 8px
  md: 12px
  lg: 16px
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  touch-target: 48px
  thumb: 56px
  app-bar: 64px
components:
  app-bar:
    backgroundColor: "{colors.surface-tonal}"
    textColor: "{colors.on-surface}"
    height: "{spacing.app-bar}"
  search-field:
    backgroundColor: "{colors.surface-tonal}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.full}"
    height: "{spacing.touch-target}"
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.full}"
    height: "{spacing.touch-target}"
  button-tonal:
    backgroundColor: "{colors.surface-tonal}"
    textColor: "{colors.primary}"
    rounded: "{rounded.full}"
    height: "{spacing.touch-target}"
  button-text-danger:
    textColor: "{colors.danger}"
    height: "{spacing.touch-target}"
  list-item:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.md}"
    padding: "{spacing.sm}"
  cart-item:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.md}"
    padding: "{spacing.sm}"
  cart-footer:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    height: "{spacing.app-bar}"
  order-card:
    backgroundColor: "{colors.surface-tonal}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.lg}"
    padding: "{spacing.md}"
  image-placeholder:
    backgroundColor: "{colors.placeholder}"
    textColor: "{colors.on-placeholder}"
    rounded: "{rounded.sm}"
  badge:
    backgroundColor: "{colors.danger}"
    textColor: "{colors.on-danger}"
    rounded: "{rounded.full}"
---

## Brand & Style

Neutro tonal en la línea de Material 3: utilitario, familiar y tranquilo. Superficies tonales verde azulado, botones y
buscador en píldora, radios medios, densidad media y tipografía de peso medio. No hay negocio real ni marca: la UI debe
verse ordenada y consistente (NFR-7), no elaborada. Una sola identidad para Flutter y Angular, en español y con importes
sin símbolo de moneda.

Referencia visual: Stitch `projects/475278247836846461`, design system "Neutro tonal M3". Ante un conflicto, este
documento y `EXPERIENCE.md` ganan sobre el mock (ver `stitch-index.md`).

## Colors

- **Primario** `{colors.primary}` para acciones principales y énfasis de marca. Contraste 6.4:1 sobre blanco.
- **Fondo** `{colors.background}` y **superficie tonal** `{colors.surface-tonal}` para AppBar, buscador y tarjetas de orden.
- **Texto**: `{colors.on-surface}` principal y `{colors.on-surface-muted}` secundario (7:1 sobre el fondo).
- **Danger** `{colors.danger}` solo para "Quitar", errores y el badge del contador (6.5:1 sobre blanco).
- **Foco** `{colors.focus}`: anillo visible en todo control interactivo. No lo reemplaza el primario.
- **Estrella** `{colors.star}` solo en el rating. **Placeholder** `{colors.placeholder}` con texto `{colors.on-placeholder}`
  para la imagen faltante.
- Solo tema claro en el MVP. El oscuro es deseable (DF-6) y queda fuera.

## Typography

Roboto en ambas apps: es la fuente por defecto de Flutter Material y, en Angular, se usa con las fuentes del sistema
como respaldo. Pesos de 400 a 600. `{typography.title-lg}` para el título de pantalla, `{typography.title-md}` para el
título de producto, `{typography.body-md}` para texto, `{typography.label-md}` para etiquetas y `{typography.price}`
para importes. En el listado, los títulos largos ocupan una línea con elipsis.

## Layout & Spacing

Escala de 4, 8, 16 y 24. Móvil vertical de una columna, con margen horizontal `{spacing.md}`. Áreas táctiles mínimas de
`{spacing.touch-target}`. Miniatura de `{spacing.thumb}`. Panel Angular de escritorio: rejilla de 2 columnas con
separación `{spacing.md}` y ancho máximo de contenido centrado.

## Elevation & Depth

Plano y tonal: la jerarquía sale del color de superficie y de bordes de 1 px `{colors.divider}`. Solo el pie del carrito
y la barra de acción del detalle llevan una separación superior sutil.

## Shapes

Radios `{rounded.md}` en elementos de lista y de carrito, `{rounded.lg}` en tarjetas de orden, `{rounded.full}` en
botones, buscador y badge, y `{rounded.sm}` en miniaturas.

## Components

- **app-bar**: título, flecha atrás cuando aplica y el carrito con **badge**.
- **search-field**: píldora tonal con ícono de lupa y sin ícono de filtros.
- **list-item** (producto): miniatura, título de una línea, precio y `★ rating`. Sin botón por ítem.
- **image-placeholder**: bloque `{colors.placeholder}` con ícono de imagen y el texto "Sin foto"; se usa en lista,
  detalle y carrito.
- **button-primary**: ancho completo, fijo al pie del detalle.
- **cart-item**: miniatura de `{spacing.thumb}`, título, precio unitario, controles −/+ de 48 px y, aparte, un
  **button-text-danger**. El "−" deshabilitado se ve atenuado.
- **cart-footer**: pie fijo con las unidades y el total, con separación superior sutil.
- **order-card**: id, `userId`, total y, solo si existe, total con descuento; un **button-tonal** "Ver detalle".
- **Tabla de productos de la orden**: columnas Título, Cantidad y Precio, dentro de la tarjeta expandida.
- **Estados**: skeleton `{colors.skeleton}` o indicador de progreso centrado; texto para el vacío; mensaje y
  **button-tonal** "Reintentar" para el error. Un pie de lista con indicador sirve para la carga de páginas (DF-1).

## Do's and Don'ts

- Sí: importes con 2 decimales y sin símbolo de moneda, foco `{colors.focus}` visible y contraste AA.
- Sí: los mismos tokens en Flutter (`ThemeData`/`ColorScheme`) y en Angular (variables CSS).
- No: usar `{colors.danger}` como decoración ni `{colors.primary}` para errores.
- No: sombras marcadas, gradientes ni ilustraciones.
- No: lo que el mock de Stitch agregó y la spec no pide (ver `stitch-index.md`, sección "Transversal").
