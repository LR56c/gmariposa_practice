# flutter_app

Catálogo de productos hecho con Flutter y Riverpod (Android).

## Versiones

| Herramienta | Versión |
| --- | --- |
| Flutter | 3.47.6 (stable), fijada en `.fvmrc` |
| Dart | 3.13.5 |

## Ejecutar

```sh
dart pub global activate fvm   # omitir si fvm ya está instalado
fvm install                    # lee .fvmrc
fvm flutter pub get
fvm flutter run               # con un emulador Android abierto
```

Sin fvm sirve cualquier Flutter 3.47.x stable.

## Checks

```sh
fvm dart format --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
```

## Prueba de integración

`integration_test/main_flow_test.dart` cubre búsqueda → detalle → agregar al carrito → carrito, con un repositorio falso (sin red).
Necesita un emulador o dispositivo, por eso el CI no la ejecuta.

```sh
fvm flutter test integration_test -d emulator-5554   # id de cualquier dispositivo abierto
```

Verificada dos veces seguidas en un emulador Android (`sdk gphone16k x86 64`, API 36).

## Extras

- Filtro por categoría.
- Carrito persistente (`shared_preferences`).
- Modal de ajustes: tema (sistema, claro, oscuro) e idioma (es, en), con persistencia.
- Filas esqueleto al cargar más productos.
- Prueba de integración.
- Deep link en Android.
- APK de release construido por el CI (artifact `app-release-apk`, firmado con la clave debug, solo para probar).

## Librerías

- **Estado y navegación:** `flutter_riverpod`, `riverpod_annotation` / `riverpod_generator`, `go_router`.
- **Red y errores:** `dio`, `fpdart` (`Either` para errores tipados).
- **Modelos:** `freezed`, `json_annotation` / `json_serializable`.
- **Persistencia:** `shared_preferences`.
- **UI:** `infinite_scroll_pagination` (dibuja la lista y pide la siguiente página; el estado sigue en `Catalog`), `skeletonizer`,
  `cached_network_image`, `toastification`, `wolt_modal_sheet`.
- **i18n y assets:** `slang` / `slang_flutter`, `flutter_gen_runner`.
- **Utilidades:** `stream_transform` (debounce de la búsqueda).
- **Pruebas y lint:** `flutter_test`, `integration_test`, `mocktail`, `very_good_analysis`.
