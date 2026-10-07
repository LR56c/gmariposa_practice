# gmariposa_practice

Prueba técnica Jr Flutter (Riverpod) + Angular. Dos apps independientes, cada una con su lint, pruebas y lockfile.
Respuestas a las preguntas de la prueba: [`RESPUESTAS.md`](RESPUESTAS.md) (pendiente, ver "Estado de la entrega").

| Carpeta | Qué es | Detalle |
| --- | --- | --- |
| `flutter_app/` | Catálogo de productos, detalle, carrito (Android) | [`flutter_app/README.md`](flutter_app/README.md) |
| `angular_app/` | Panel de Órdenes | [`angular_app/README.md`](angular_app/README.md) |

## Versiones reales

| Herramienta | Versión |
| --- | --- |
| Flutter / Dart | 3.47.6 / 3.13.5 (fijado en `flutter_app/.fvmrc`) |
| Angular / TypeScript / Node | 22.2 / ~6.0 / 24.16 |

## Cómo ejecutar

**Flutter** (con un emulador Android abierto). Requiere Flutter 3.47.x: el `pubspec` pide Dart `^3.13.0`, así que un
Flutter más viejo falla en `pub get`. Con FVM:

```bash
cd flutter_app
fvm install
fvm flutter pub get
fvm flutter run
fvm dart format --set-exit-if-changed . && fvm flutter analyze && fvm flutter test
```

Los archivos generados (`*.g.dart`, `*.freezed.dart`) están commiteados: no hace falta correr `build_runner`.

**Angular** (Standalone, zoneless, TypeScript `strict`, pruebas con Vitest). Si no tienes el CLI global, usa
`npx ng <comando>`:

```bash
cd angular_app
npm install
ng serve      # http://localhost:4200
ng test
ng build
```

Dependencia no obvia: **Tailwind 4.3** (`tailwindcss`, `@tailwindcss/postcss`, `postcss`). Estilado con utilidades y
los tokens de `DESIGN.md` en un bloque `@theme`, para compartir identidad visual con la app Flutter sin escribir CSS
propio.

## Decisiones de arquitectura

Detalle completo en `_bmad-output/planning-artifacts/architecture/.../ARCHITECTURE-SPINE.md` (AD-1 a AD-18).

- **Flutter:** capas feature-first (`data` / `domain` / `presentation`), con `domain` puro y el Repository inyectado.
  Estado solo con Riverpod (`riverpod_generator`), modelos inmutables con `freezed`, navegación con `go_router`.
- **Errores tipados:** `Either` de `fpdart` en el contrato del Repository y excepción tipada en el borde (AD-4).
  En Angular, `Result` y `Schema` de `effect` solo en el borde (AD-12).
- **Catalog, búsqueda y paginación** son un único mecanismo (AD-6); el debounce es de 400 ms con `stream_transform`.
- **Cart** sin red, con la lógica dentro de su Notifier (AD-7).
- **Angular usa un store manual con signals y RxJS, sin NgRx** (AD-16): RxJS ya viene con Angular y basta para el
  estado; NgRx sería una dependencia sin uso. Estilos con Tailwind (AD-17). El spine, el PRD y el addendum ya reflejan
  esta decisión (AD-10 y AD-11 quedan marcados como sustituidos parcialmente).

### Por qué `freezed` para los modelos (T-4)

Da inmutabilidad, `copyWith`, igualdad por valor y las uniones selladas (estados de carga, error, datos) sin escribir
a mano `==`, `hashCode` ni `copyWith`. El coste es `build_runner`; se mitiga commiteando los archivos generados. No se
aplicó el plan B del PRD §8 (modelos manuales o Riverpod sin generador).

### Paralelos Flutter ↔ Angular

| Flutter | Angular |
| --- | --- |
| Repository | Servicio (`OrdersService`) |
| provider / Notifier | signal / store |
| widget sin estado | componente presentacional |

## Estado de la entrega

Las verificaciones automáticas se corrieron el 2026-10-07. Lo marcado "pendiente de Mauri" requiere emulador,
navegador o la persona, y no se afirma como cumplido sin haberlo hecho.

| Ítem | Estado |
| --- | --- |
| `flutter analyze` (0 issues), `dart format` (0 cambios), `flutter test` (28 pruebas) | Cumplido |
| `ng test` (12 pruebas, 5 archivos) y `ng build` sin warnings | Cumplido |
| Archivos generados commiteados, compila sin `build_runner` | Cumplido |
| Recorrido UJ-1 en emulador (Catalog, búsqueda, scroll, detalle, carrito, volver, error sin red) | Pendiente de Mauri: no verificado en esta revisión |
| Recorrido UJ-2 en navegador (lista, filtro, detalle, error con "Reintentar") | Pendiente de Mauri: no verificado en esta revisión |
| Deep link `/product/:id` con `adb` (AD-9) | No verificado: no hay registro del resultado |
| `RESPUESTAS.md` | Pendiente de Mauri: el archivo no existe aún |
| Ensayo SM-4 (explicar provider → Repository, `ref.read`, flujo de Order) | Pendiente de Mauri |
| El PDF de la prueba no debe estar en el historial | **No cumplido**: el commit `49b7cc3` lo añadió. Hoy está fuera del árbol y excluido por `.gitignore`; no se reescribió el historial (decisión de Mauri) |

Deseables y bonus: hechos el i18n es/en de Angular (story 4.5), la paginación infinita (DF-1, promovida al MVP) y
`riverpod_generator`. No se hicieron DF-2 (filtro por categoría), DF-3 (persistencia del Cart), B-1 (prueba de
integración) ni B-2 (GitHub Action); son las stories 5.2 a 5.5, que empiezan solo tras cerrar esta.

## Qué mejoraría con más tiempo

- Prueba de integración del flujo buscar → detalle → agregar al Cart (B-1) y CI con `analyze` y `test` (B-2).
- Persistir el Cart entre sesiones y filtrar el Catalog por categoría (DF-3, DF-2).
- Verificar el deep link con `adb` y dejar el resultado registrado.
