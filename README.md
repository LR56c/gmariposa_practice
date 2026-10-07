# gmariposa_practice

[![CI](https://github.com/LR56c/gmariposa_practice/actions/workflows/ci.yml/badge.svg)](https://github.com/LR56c/gmariposa_practice/actions/workflows/ci.yml)

Prueba técnica Jr Flutter (Riverpod) + Angular. Cada carpeta es independiente (lint, test y lockfile propios).

## Ver la entrega

- **Web (Angular):** https://lr56c.github.io/gmariposa_practice/ (GitHub Pages, se actualiza con cada push a `main`).
- **APK de Android (Flutter):** está disponible en la action de CI. Entra a la
  [pestaña Actions](https://github.com/LR56c/gmariposa_practice/actions/workflows/ci.yml), abre el último run en verde y baja
  `app-release-apk` desde **Artifacts** (GitHub lo conserva 90 días). Está firmado con la clave debug, solo para probar.

## Cómo ejecutar

- **flutter_app/:** ver [`flutter_app/README.md`](flutter_app/README.md) (fvm, `flutter run`, checks y prueba de integración).
- **angular_app/:** `npm install`, `ng serve`, `ng test`, `ng build` (detalle más abajo y en [`angular_app/README.md`](angular_app/README.md)).

Versiones: Flutter 3.47.6 (stable), Dart 3.13.5, Angular 22.2, TypeScript 6.0, Node 24.

## Estado de la entrega

| Parte | Entregable | Estado |
| --- | --- | --- |
| Flutter | Catálogo con carga, vacío y error con reintento; búsqueda con debounce de 400 ms; scroll infinito; detalle; carrito con cantidades, total y contador; `go_router`; estado solo con Riverpod | Cumplido |
| Angular | Lista de órdenes en tarjetas, filtro por total mínimo, detalle en `/orders/:id` con lazy loading, store con signals, pipe propio, `OnPush`, `@if`/`@for` | Cumplido |
| Pruebas | Flutter: 25 unitarias y 19 de widget, más 1 de integración; Angular: pruebas con Vitest | Cumplido |
| Calidad | `dart format`, `flutter analyze` sin issues, `ng build` sin warnings; todo en el CI | Cumplido |
| Partes 1 y 4 | `RESPUESTAS.md` (preguntas conceptuales y code review) | **Pendiente**: se está redactando aparte; se enlazará aquí |

Extras hechos: filtro por categoría, carrito persistente (`shared_preferences`), prueba de integración, GitHub Actions
(analyze, test y APK como artifact), i18n es/en y modo oscuro en las dos apps, demo en GitHub Pages.

## Decisiones de arquitectura

- **Dos apps independientes**, sin código compartido: cada una con su lint, sus pruebas y su lockfile.
- **Flutter, capas por feature:** `domain` (modelos e interfaces) / `data` (implementaciones) / `presentation` (providers y widgets).
  Los Repository son interfaces con una implementación: `DioProductData`, `SharedPreferenceCartData` y `SharedPreferenceSettingsData`.
- **Riverpod con generador (`riverpod_generator`)**, un tipo de provider para cada necesidad:
  `AsyncNotifier` para el catálogo (`Catalog`, con búsqueda y paginación), `Notifier` para el estado síncrono (`Cart`, `SearchTerm`,
  `SelectedCategory`, `ThemeModeChoice`), `FutureProvider` para cargas de una vez (`categories`, `productDetail` con `family`),
  `StreamProvider` para el debounce (`debouncedTerm`) y `Provider` para dependencias (`dio`, los Repository, `cartTotal`, `cartCount`).
- **Errores tipados:** los métodos del Repository devuelven `Either<Errors, T>` (`fpdart`) y la UI traduce el error a un mensaje; las
  excepciones solo existen en el borde de red.
- **Modelos con `freezed`:** inmutables, con `==`, `copyWith` y `fromJson` generados, para no escribir ese código a mano. Los archivos generados
  están commiteados, así que la app compila sin ejecutar `build_runner`.
- **Angular, store manual sin NgRx:** un servicio `root` con signals (estado privado, lectura `readonly`, `computed` para lo derivado).
  RxJS ya viene con Angular y basta para este alcance; NgRx habría sido una dependencia sin uso real. Validación y errores con `effect` (`Schema` y `Result`).
- **Tailwind sobre tokens de diseño:** los mismos colores y medidas de `DESIGN.md` en las dos apps, y el modo oscuro solo redefine esos tokens.

Paralelos Flutter ↔ Angular: servicio ≈ Repository · store con signals ≈ provider / Notifier · componente presentacional ≈ widget sin estado.

## Deep link en Android

`adb shell am start -a android.intent.action.VIEW -d "gmariposa://app/product/5"` abre el detalle del producto 5. Verificado en el emulador.

## Pendientes

- `RESPUESTAS.md` (Partes 1 y 4), en redacción.
- Ensayo de explicación del flujo de providers y de Orders, antes de entregar.

## Con más tiempo

- Pruebas de widget del modal de ajustes y del cambio de idioma.
- Firmar el APK con una clave propia en vez de la de debug.
- Un caché de respuestas de red y una prueba de integración también para Angular.

## CI

`.github/workflows/ci.yml` corre en cada `push` y en cada `pull_request` hacia `main` o `dev`, con jobs independientes:

- **flutter** (Flutter 3.47.6): `flutter pub get`, `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`.
- **flutter-apk** (tras `flutter`): `flutter build apk --release` y sube `app-release.apk` como artifact (firmado con la clave debug, solo para probar).
- **angular** (Node 24): `npm ci`, `npx ng test --no-watch`, `npx ng build`.

No ejecuta la prueba de integración de Flutter (`integration_test/`), porque requiere emulador o dispositivo.
Para reproducirlo en local, corre esos mismos comandos dentro de `flutter_app/` y `angular_app/`.

## Demo (GitHub Pages)

La app Angular se despliega en https://lr56c.github.io/gmariposa_practice/ con `.github/workflows/pages.yml` (en cada push a `main`
o a mano). Es un extra de demostración, no parte del CI. El build está localizado: la raíz redirige a `/es/` o `/en/` según el
idioma del navegador, y `404.html` carga el `index.html` del idioma para que los enlaces profundos (`/es/orders/3`) funcionen al recargar.

Para verlo en local como en producción: `cd angular_app && npx ng build` y servir `dist/angular_app/browser/es` con un servidor estático
(por ejemplo `npx http-server dist/angular_app/browser/es -p 8080 --proxy http://localhost:8080?`).

## angular_app

Panel de Órdenes. Angular 22.2 (standalone, zoneless, TypeScript 6.0 `strict`), runner de pruebas Vitest, Node 24.

```bash
cd angular_app
npm install
ng serve      # http://localhost:4200
ng test
ng build
```

Si no tienes el CLI global, usa `npx ng <comando>`.

### Dependencias

- **Tailwind 4.3** (`tailwindcss`, `@tailwindcss/postcss`, `postcss`): estilado con utilidades y los tokens de
  `DESIGN.md` en un bloque `@theme`, para compartir identidad visual con la app Flutter sin escribir CSS propio.
