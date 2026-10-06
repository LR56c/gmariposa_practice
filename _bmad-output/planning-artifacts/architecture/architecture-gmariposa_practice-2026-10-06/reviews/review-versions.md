# Revisión de versiones y compatibilidad — Architecture Spine (gmariposa_practice)

Fecha de la revisión: 2026-10-06. Método: `curl pub.dev/api/packages/<pkg>`, `npm view`, lectura del código de los tarballs `riverpod 3.4.3`, `flutter_riverpod 3.4.3` y `fpdart 1.2.0`, `releases_windows.json` de Flutter y `flutter upgrade --verify-only`. No se editó el spine.

## Veredicto

Todas las versiones del Stack existen y son las últimas publicadas, y las APIs de Riverpod 3 citadas existen; el spine es viable, pero hay un bloqueo de orden (hay que subir Flutter antes de `pub get`), un hueco de diseño (`StreamProvider` sin valor inicial), `fpdart`/`fp-ts` en mantenimiento lento y varias afirmaciones de Angular sin verificar contra el starter.

## Resultado de la tabla Stack (pub.dev / npm)

| Paquete | Spine | Última real | Restricciones relevantes | Estado |
| --- | --- | --- | --- | --- |
| flutter_riverpod | 3.4.3 | 3.4.3 | Dart ^3.12.0 | OK |
| riverpod_annotation | 4.0.7 | 4.0.7 | depende de `riverpod 3.4.3` exacto | OK |
| riverpod_generator | 4.0.9 | 4.0.9 | analyzer >=13 <15, source_gen >=3 <5, `riverpod_annotation 4.0.7` exacto | OK |
| freezed | 4.0.2 | 4.0.2 | **Dart >=3.13.0**, analyzer >=14 <15, `freezed_annotation 3.1.0` exacto | OK, exige subir Flutter |
| freezed_annotation | 3.1.0 | 3.1.0 | Dart >=3.0 | OK |
| json_serializable | 6.14.1 | 6.14.1 | analyzer >=10 <15, build ^4.0.4, source_gen ^4.1.2, json_annotation >=4.12 <4.13 | OK |
| build_runner | 2.16.1 | 2.16.1 | analyzer >=13.3 <15, build ^4.0.9 | OK |
| fpdart | 1.2.0 | 1.2.0 (oct-2025) | Dart >=3.0 | OK, estancado (F3) |
| dio | 5.11.1 | 5.11.1 | Dart >=2.18 | OK |
| go_router | 18.0.2 | 18.0.2 | Dart ^3.12, **Flutter >=3.44.0**, usa `material_ui`/`cupertino_ui` ^1.0.0 | OK |
| stream_transform | 2.1.2 | 2.1.2 | Dart ^3.4 | OK |
| mocktail | 1.0.5 | 1.0.5 | Dart >=2.12 | OK |
| very_good_analysis | 11.0.0 | 11.0.0 | **Dart ^3.13.0** | OK, exige subir Flutter |
| @angular/core, cli, build | 22.2.1 | 22.2.1 (latest) | Node ^22.22.3 / ^24.15.0 / >=26; `@angular/build` pide TypeScript `>=6.0 <6.1` | OK con TS 6.0.x |
| TypeScript | 6.0 | **7.0.2 es `latest`** | Angular fija 6.0.x | OK, hay que fijar `~6.0` (F5) |
| Node | 24.16 | local v24.16.0 | cumple ^24.15.0 | OK |
| @ngrx/store, effects, store-devtools | 22.0.1 | 22.0.1 | peers `@angular/core ^22.0.0`, rxjs ^7.5 | OK |
| fp-ts | 2.16.11 | 2.16.11 (ago-2025) | sin peers | OK, mantenimiento (F4) |
| zod | 4.6.5 | 4.6.5 | sin peers | OK |
| Vitest | 5.0.3 | 5.0.3 | vite ^6.4 / ^7 / ^8, Node ^22.12 / ^24; `@angular/build` acepta vitest ^4.0.8 o ^5 | OK |

Grafo de pub: `freezed 4.0.2` (analyzer >=14 <15), `riverpod_generator 4.0.9` (>=13 <15), `build_runner 2.16.1` (>=13.3 <15) y `json_serializable 6.14.1` (>=10 <15) intersectan en analyzer 14.x (última 14.4.0, Dart ^3.11); `source_gen 4.3.0` también. No pude correr `pub get` porque `flutter_app/` no existe; la intersección es por lectura de rangos, no por resolución real.

## Hallazgos

### F1 — ALTA — El SDK local actual no resuelve el Stack
`freezed 4.0.2` (Dart >=3.13) y `very_good_analysis 11.0.0` (Dart ^3.13) no resuelven con Dart 3.12.1. El spine lo anota ("Dart >= 3.13; hoy 3.44.1 / 3.12.1") pero no fija a qué versión sube `flutter upgrade`. Confirmado: `flutter upgrade --verify-only` reporta actualización disponible, y el manifiesto oficial da stable **3.47.6 / Dart 3.13.5** (2026-10-01); 3.47.3 a 3.47.5 usan Dart 3.13.3 a 3.13.4. El Stack es consistente con Flutter 3.47.x, no con 3.44.1. Acciones: escribir "Flutter 3.47.x / Dart 3.13.x" en el spine, poner `flutter upgrade` como paso 0 de la story de scaffold y fijar `environment: sdk: ^3.13.0` en el pubspec. `go_router 18` pide Flutter >=3.44, cumplido en ambos casos.

### F2 — ALTA — `debouncedTerm` como `StreamProvider` no emite hasta el primer cambio
APIs verificadas en el código de `riverpod 3.4.3`: `Ref.mounted` (`lib/src/core/ref.dart:112`), `ref.onDispose`, `AsyncValue.guard` (`async_value.dart:524`) y `ProviderScope(retry:)` / `ProviderContainer(retry:)` existen; `typedef Retry = Duration? Function(int retryCount, Object error)`, así que `(_, __) => null` es válido. `stream_transform 2.1.2` ofrece `debounce(Duration, {leading, trailing})` y encaja con un `StreamProvider`. Pero hay un hueco que el spine no cubre: el `StreamProvider` queda en `AsyncLoading` hasta que su stream emite, y con debounce solo-trailing la primera emisión tarda 400 ms. Con `searchTerm` inicial `""`, `catalogProvider` (que observa `debouncedTerm`) quedaría cargando sin pedir nada o esperaría 400 ms en la primera carga. Hay que dejar escrito cómo se siembra el stream con el valor inicial sin debounce (p. ej. `StreamController` alimentado por `ref.listen(searchTermProvider)` más un evento inicial) y que el término vacío vaya por "listar". Los tests con `fakeAsync` deben cubrirlo.

### F3 — MEDIA — `fpdart` estancado y sin `getOrThrow`
Última estable 1.2.0 (2025-10-29); la 2.0 sigue en `dev` desde marzo-abril de 2024. Existe y es Flutter Favorite, pero el mantenimiento es lento. Leyendo `fpdart 1.2.0` no hay `getOrThrow` en `Either` (hay `getOrElse`, `toNullable`, `getRight()`). El spine ya dice que es "una extensión en `core`", correcto, pero conviene fijar la firma (`T getOrThrow() => fold((l) => throw l, (r) => r)`, con `Errors` lanzable). Riesgo bajo para tres días; justificar en RESPUESTAS.md frente a un `Result` propio, que CLAUDE.md dejaba abierto.

### F4 — MEDIA — `fp-ts` 2.16 es la rama en mantenimiento; el sucesor es Effect
npm: `fp-ts` latest 2.16.11 (última publicación 2025-08-18), dist-tags `next: 3.0.0-alpha.26`; `effect` está en 4.0.1. Que Effect sea el sucesor es mi interpretación de los dist-tags y de mi conocimiento previo; no abrí el anuncio oficial, así que está sin confirmar en la web. Sin peers declarados no hay conflicto de resolución con TypeScript 6, pero **no verifiqué** que los `.d.ts` de fp-ts 2.16 compilen bajo `strict` y TS 6.0; probarlo en el primer `ng build`. Justificar fp-ts en RESPUESTAS.md (paralelismo con `fpdart`). Alternativa de menor riesgo: un `Result<T, E>` propio pequeño.

### F5 — MEDIA — TypeScript `latest` es 7.0.2, Angular 22 exige `>=6.0 <6.1`
`npm i typescript` por defecto instalaría 7.0.2 y rompería el peer de `@angular/build` y `compiler-cli`. `ng new` fija la versión, pero un `npm i -D typescript@latest` o un bot la subiría. Anotar "TypeScript ~6.0 (no subir a 7)" en el Stack.

### F6 — BAJA — Afirmaciones de Angular no confirmadas contra el starter
- "zoneless (el default de la versión vigente)": no verificado. `@angular/core 22.2.1` declara `zone.js` como peer opcional (`~0.15 || ~0.16`), coherente con zoneless por defecto, pero hay que confirmarlo con `ng new`. Impacto en tests (`await fixture.whenStable()`).
- Vitest como runner: `@angular/build 22.2.1` lo admite (`vitest ^4.0.8 || ^5.0.0`) y depende de `vite 8.3.0`, compatible con Vitest 5. No verifiqué que `ng new` lo traiga por defecto ni que instale 5.0.3; el spine fija "5.0.3" sin contrastarlo con el starter.
- "Storybook añade zone.js como peer" (Deferred): no verificado, bajo impacto.

### F7 — BAJA — Notas menores
- `riverpod_annotation` fija `riverpod 3.4.3` exacto y `riverpod_generator` fija `riverpod_annotation 4.0.7` exacto; igual `freezed` con `freezed_annotation 3.1.0`. Declararlos juntos; un `pub upgrade` parcial puede fallar.
- `freezed 4` es una mayor nueva; no leí su changelog, la sintaxis (`abstract`/`sealed`, `with _$X`) puede diferir de 3.x. La fila Deferred sobre "riverpod_generator 4 con freezed 4" pasa de duda de resolución (no hay conflicto de rangos) a riesgo de sintaxis/generación, que `build_runner` revela.
- `very_good_analysis 11` es estricto (p. ej. `public_member_api_docs`); probablemente haya que ajustar `analysis_options.yaml` para "sin warnings". No verificado.
- `flutter_app/` y `angular_app/` no existen aún: no hubo contraste con un starter real, solo con registros públicos.

## Confirmado sin reservas
- Versiones del Stack (salvo Flutter/Dart) iguales a `latest` en pub.dev y npm el 2026-10-06.
- Riverpod 3.4.3: `Ref.mounted`, `ref.onDispose`, `AsyncValue.guard`, `ProviderScope.retry`.
- Rangos de `analyzer`, `build` y `source_gen` se solapan entre riverpod_generator, freezed, json_serializable y build_runner.
- Node 24.16.0 local cumple Angular 22 y Vitest 5; NgRx 22.0.1 compatible con Angular 22.x; zod 4.6.5 sin peers.

## Acciones recomendadas
1. Fijar Flutter 3.47.x / Dart 3.13.x en el Stack y `flutter upgrade` como paso 0 del scaffold (F1).
2. Definir en AD-6 el valor inicial y el debounce sobre el primer término (F2).
3. Anotar TypeScript `~6.0`; confirmar con `ng new` zoneless y Vitest (F5, F6).
4. Probar fp-ts bajo TS 6 en el primer `ng build`; justificar fp-ts/fpdart en RESPUESTAS.md (F3, F4).
