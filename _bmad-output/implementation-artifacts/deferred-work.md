# Deferred work

Hallazgos de la review por lotes que se dejan para después. Cada lote añade su sección.

## Deferred from: code review R1, stories 1.1 + 1.2 (2026-10-07)

- **Tema con valores sueltos** [`flutter_app/lib/core/theme/app_theme.dart`] — la AC de la 1.1 pide colores y espaciado como constantes con nombre (NFR5). Hay `Color(0xFF...)` en línea, `EdgeInsets` y `SizedBox` con números, y no hay escala de radios. A `ColorScheme.light` le faltan `onPrimary` y `surface`, y el `FilledButton` usa el valor por defecto de Flutter. Es un refactor de tokens; se resuelve junto a la review de UI, contra `DESIGN.md`.
- **Dependencias añadidas sin justificar** [`flutter_app/pubspec.yaml`] — AD-18 y el `CLAUDE.md` piden justificar las librerías que sobran para el alcance: `skeletonizer`, `cached_network_image`, `slang` y `slang_flutter`, `infinite_scroll_pagination`, `flutter_gen_runner`, `shared_preferences` y `wolt_modal_sheet`. Se resuelve en el `README` o en `RESPUESTAS.md`, no en código.
- **`DioProductData` sin test propio** [`flutter_app/lib/features/products/data/dio_product_data.dart`] — decisión de Mauri: se quitó el test con adapter falso, igual que en e1-s2. Sin cobertura directa del mapeo `DioException` → `Errors` (404, 500, timeout, JSON roto), de los paths de los endpoints ni de la cancelación con `CancelSignal`. Los tests de páginas usan un Repository falso y no llegan a ese código. Retomar solo si se vuelve a tocar la capa de datos.

## Deferred from: code review R2, stories 1.3 + 1.4 + 1.5 (2026-10-07)

- **Test del debounce con timers reales** [`flutter_app/test/features/catalog/search_provider_test.dart`] — espera con `Future.delayed` de 50 ms y 10 ms contra un debounce de 400 ms y llega a esperar los 400 ms completos. Es lento y puede ser flaky en CI. Se resuelve con `fakeAsync` o con una duración de debounce inyectable; hoy pasa.

## Deferred from: code review R3, stories 2.1 + 2.2 (2026-10-07)

- **Toast: reemplazo con doble tap y "reduce motion" sin test** [`flutter_app/lib/features/product_detail/presentation/widgets/added_to_cart_toast.dart`] — `dismissAll(delayForAnimation: false)` y `animationDuration` con `disableAnimationsOf` implementan UX-DR9, pero el test solo toca una vez, así que no distingue "reemplaza" de "apila". Pulido de UX; añadir un test de doble tap y otro con `disableAnimations: true` si se vuelve a tocar el toast.
- **Evidencia de la verificación del deep link** [`README.md`, sección "Deep link en Android"] — AD-9 y la story 2.2 piden registrar con `adb` los casos `5`, `abc`, `99999`, una ruta desconocida y la app ya abierta, o marcar como "no verificado" los que no se probaron. El README solo documenta el caso `5`. Se resuelve en R8 (entrega), con un emulador.
