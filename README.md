# gmariposa_practice

[![CI](https://github.com/LR56c/gmariposa_practice/actions/workflows/ci.yml/badge.svg)](https://github.com/LR56c/gmariposa_practice/actions/workflows/ci.yml)

Prueba técnica Jr Flutter (Riverpod) + Angular.

## Ver la entrega

- **Web (Angular):** https://lr56c.github.io/gmariposa_practice/ (GitHub Pages, se actualiza con cada push a `main`).
- **APK de Android (Flutter):** está disponible en la action de CI. Entra a la
  [pestaña Actions](https://github.com/LR56c/gmariposa_practice/actions/workflows/ci.yml), abre el último run en verde y baja
  `app-release-apk` desde **Artifacts** (GitHub lo conserva 90 días). Está firmado con la clave debug, solo para probar.

- **Respuestas escritas (Partes 1 y 4):** [`RESPUESTAS.md`](RESPUESTAS.md).

## Cómo ejecutar

- **flutter_app/:** con un emulador Android abierto (o un dispositivo conectado):

  ```bash
  cd flutter_app
  flutter pub get
  flutter run
  ```

  Más detalle en [`flutter_app/README.md`](flutter_app/README.md).
- **angular_app/:** ver [`angular_app/README.md`](angular_app/README.md) (`npm install`, `ng serve`, `ng test`, `ng build`).

Versiones: Flutter 3.47.6 (stable), Dart 3.13.5, Angular 22.2, TypeScript 6.0, Node 24.

## Deseables y bonus hechos

- **Flutter, deseables:** paginación infinita, filtro por categoría, carrito persistente (`shared_preferences`), `go_router` y tema claro/oscuro.
- **Flutter, bonus:** `riverpod_generator`, prueba de integración del flujo buscar → detalle → carrito y GitHub Action (analyze y test).
- **Angular, deseables:** ruta de detalle con lazy loading, signals, control flow nuevo (`@if` / `@for`), pipe propio y `OnPush`.
- **Errores tipados** en las dos apps (`Either` en Flutter, `Result` en Angular).

## Extras propios

- i18n es/en y modo oscuro en Angular, y modal de ajustes (tema e idioma) en Flutter.
- Filas esqueleto al cargar más productos.
- Deep link en Android.
- APK de release como artifact del CI.
- Demo Angular en GitHub Pages.

## Decisiones de arquitectura

- **Flutter, capas por feature:** `domain` (modelos e interfaces) / `data` (implementaciones) / `presentation` (providers y widgets).
  Los Repository son interfaces con una implementación: `DioProductData`, `SharedPreferenceCartData` y `SharedPreferenceSettingsData`.
- **Riverpod con generador (`riverpod_generator`)**, un tipo de provider para cada necesidad:
  `AsyncNotifier` para el catálogo (`Catalog`, con búsqueda y paginación), `Notifier` para el estado síncrono (`Cart`, `SearchTerm`,
  `SelectedCategory`, `ThemeModeChoice`), `FutureProvider` para cargas de una vez (`categories`, `productDetail` con `family`),
  `StreamProvider` para el debounce (`debouncedTerm`) y `Provider` para dependencias (`dio`, los Repository).
- **Providers derivados:** `cartTotal` y `cartCount` se calculan a partir del estado de `Cart`, así que no se guardan aparte.
- **Paginación infinita con `infinite_scroll_pagination`:** la librería solo dibuja la lista y pide la siguiente página; el estado
  (`items`, `total`, `loadMore`) sigue en el `Catalog` de Riverpod. Mientras carga muestra filas esqueleto.
- **Errores tipados:** los métodos del Repository devuelven `Either<Errors, T>` (`fpdart`) y la UI traduce el error a un mensaje; las
  excepciones solo existen en el borde de red.
- **Modelos con `freezed`:** inmutables, con `==`, `copyWith` y `fromJson` generados, para no escribir ese código a mano. Los archivos generados
  están commiteados, así que la app compila sin ejecutar `build_runner`.
- **Angular, store manual:** un servicio `root` con signals (estado privado, lectura `readonly`, `computed` para lo derivado).
- **Angular, validación y errores:** con `effect` (`Schema` y `Result`).
- **Tailwind sobre tokens de diseño:** los mismos colores y medidas de `DESIGN.md` en las dos apps, y el modo oscuro solo redefine esos tokens.

Paralelos Flutter ↔ Angular: servicio ≈ Repository · store con signals ≈ provider / Notifier · componente presentacional ≈ widget sin estado.

## Con más tiempo

- Caché offline del catálogo
- Favoritos
- Notificaciones push
- Historial de búsquedas y pedidos
- Compartir producto con deep link
- Panel de métricas de ventas
- Exportar órdenes a CSV
- Edición del estado de una orden

## Flujo de ramas

Modelo `main ← dev ← sprint/<epic> ← story`:

- **`main`:** solo versiones verificadas (`dart format`, `flutter analyze`, `flutter test` y prueba en emulador). Nunca se commitea directo.
- **`dev`:** integración; recibe cada sprint ya cerrado.
- **`sprint/<epic>`** (ej. `sprint/e2`): se crea desde `dev` al empezar el epic y recibe las stories.
- **Una rama por story**, desde su sprint: `<tipo>/<epic>-<story>-<slug>` (ej. `feat/e2-s3-cart-notifier`). Al cerrar la story se
  fusiona con `--no-ff` al sprint, para conservar el historial real.
- **Cierre de sprint:** se verifica en la rama del sprint, se fusiona a `dev` y luego a `main` (mensaje `merge: sprint/<epic>`).
  Un fix posterior va en `fix/...` desde `dev`.
- **Commits:** Conventional Commits (`feat|fix|docs|test|refactor|chore|ci(scope): resumen`), pequeños y frecuentes.

Al trabajar solo no abrí pull requests; el merge `--no-ff` de cada story cumple ese papel, y en equipo sería el PR hacia la rama del sprint.
El Epic 1 se fusionó directo a `main`, antes de adoptar este modelo.

## CI

`.github/workflows/ci.yml` corre en cada `push` y en cada `pull_request` hacia `main` o `dev`
