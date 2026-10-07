# Borrador de la Parte 1 (punto de partida, no para copiar)

Reescribe cada respuesta con tus palabras y asegúrate de poder explicarla en voz alta sin leerla. El PDF pide 3 a 6 líneas por pregunta. Los puntos de Riverpod y Angular se contrastaron con la documentación vigente (Riverpod 3.x, Angular 20+); revisa de nuevo la versión que uses.

**Autoprueba por pregunta:** tapa la respuesta, explícala en 30 segundos y da un ejemplo propio. Si no puedes, esa pregunta es tu prioridad de estudio.

## Dart y Flutter

**1. `final` vs `const`.** `final` se asigna una vez y se evalúa en tiempo de ejecución; `const` es una constante de compilación y las instancias idénticas se reutilizan. En widgets, un constructor `const` permite que Flutter reutilice la instancia y se salte la reconstrucción de ese subárbol cuando nada cambió.
```dart
final now = DateTime.now();          // valor conocido solo al ejecutar
const padding = EdgeInsets.all(8);   // constante de compilación
```

**2. Null safety.** Un tipo no nulo (`String`) nunca vale `null`; uno nulo (`String?`) puede. `?` declara que puede ser nulo, `??` da un valor por defecto, `late` promete inicializar antes de usar. `!` afirma "no es nulo" y falla en ejecución si te equivocas, por eso abusar de él devuelve los errores de nulo que null safety quería evitar en compilación.

**3. `StatelessWidget` vs `StatefulWidget`.** El primero no guarda estado propio; el segundo tiene un `State` que sobrevive a las reconstrucciones. `ConsumerWidget` es un stateless que recibe un `WidgetRef` en `build` para leer providers; `ConsumerStatefulWidget` hace lo mismo con un `State` que expone `ref`.

**4. `Future` vs `Stream`.** Un `Future` entrega un único valor futuro (cargar un producto por id). Un `Stream` entrega varios valores a lo largo del tiempo (cambios de conectividad, un chat en vivo).

**5. Widget como clase vs `_buildAlgo()`.** Una clase propia puede ser `const`, tiene su propio contexto y ciclo de reconstrucción, y se prueba de forma aislada. Un método que devuelve un widget se reconstruye siempre con el padre y no se puede marcar `const`.

## Riverpod

**6. Qué resuelve frente a `setState` o `Provider`.** `setState` ata el estado a un widget y a su `BuildContext`. Riverpod saca el estado del árbol de widgets: los providers pueden depender de otros providers, se prueban sin UI, cachean y manejan estados asíncronos con `AsyncValue`, y se sobrescriben en pruebas con `overrides`.

**7. `ref.watch`, `ref.read` y `ref.listen`.** `watch` observa y reconstruye cuando cambia (en `build`). `read` lee una vez sin escuchar (en callbacks como `onPressed`). `listen` ejecuta un efecto secundario al cambiar (un snackbar o navegar) sin reconstruir. Es incorrecto usar `read` en `build` para "evitar reconstrucciones": la UI puede quedar desincronizada. Tampoco se usa `ref` en `dispose`.

**8. Qué provider usar.** `Provider` para un valor de solo lectura o una dependencia (el repositorio). `FutureProvider` para cargar algo asíncrono una vez, sin métodos para modificarlo. `Notifier` para estado síncrono con métodos (el carrito). `AsyncNotifier` para estado asíncrono con métodos (la búsqueda).

**9. `autoDispose` y `family`.** `autoDispose` destruye el estado cuando nadie lo escucha, liberando memoria y forzando una nueva carga la próxima vez. `family` crea un provider por parámetro (un estado por `id` de producto). En Riverpod 3 se unificaron las interfaces y `AutoDisposeNotifier` desapareció; el comportamiento sigue igual. [Verifica el valor por defecto de `autoDispose` con `@riverpod` en tu versión.]

**10.
```dart
final asyncValue = ref.watch(myProvider);
return asyncValue.when(
  loading: () => const Center(
    child: CircularProgressIndicator(),
  ),
  error: (error, stackTrace) => Center(
    child: Text('Error al cargar: $error'),
  ),
  data: (data) => Center(
    child: Text('Datos obtenidos: $data'),
  ),
);
```

**11. Sobrescribir un provider en una prueba.**
```dart
final container = ProviderContainer.test(
  overrides: [productRepositoryProvider.overrideWithValue(FakeProductRepository())],
);
```
En una prueba de widget, lo mismo con `ProviderScope(overrides: [...])` en la raíz de `pumpWidget`. `ProviderContainer.test()` libera el contenedor al terminar.

## Angular

**12. Standalone vs `NgModule`.** Un componente standalone declara sus propias dependencias en `imports` y no necesita un módulo; es el modo por defecto en versiones recientes (para declararlo en un `NgModule` hay que poner `standalone: false`). Simplifica la carga diferida y reduce el código repetido.

**13. `Observable` vs `Signal`.** Un `Observable` es un flujo asíncrono de valores en el tiempo que se consume suscribiéndose y con operadores (HTTP, eventos). Un `Signal` guarda siempre un valor actual, se lee de forma síncrona y Angular actualiza solo lo que depende de él. Señal para el estado de la UI; Observable para flujos asíncronos; `toSignal` los conecta.

**14. `input()` y `output()`.** `input()` recibe datos del padre y `output()` emite eventos hacia él, en forma de señal y con tipos. Dos componentes hermanos no se hablan directamente: se comunican por el padre común (subiendo el estado) o por un servicio compartido.

**15. Inyección de dependencias.** Angular entrega las dependencias que un componente o servicio declara con `inject()`, en lugar de crearlas él. `providedIn: 'root'` registra una única instancia global del servicio y permite eliminarlo del bundle si nadie lo usa.

**16. Fugas por suscripciones.** Una suscripción abierta sigue ejecutándose y reteniendo memoria aunque el componente ya no exista. Se evitan con el `async` pipe, con `toSignal` (ambos se desuscriben solos al destruirse el componente) y con `takeUntilDestroyed`.

## Código limpio y buenas prácticas

**17. SRP.** Cada clase debería tener una sola razón para cambiar. En Flutter: el widget dibuja, el notifier decide el estado y el repositorio obtiene los datos. Si un widget llama a la red y además da formato a los datos, cambia por razones distintas.

**18. Capas.** Presentación (pantallas, widgets y providers), dominio (entidades y el contrato del repositorio, sin depender de Flutter) y datos (implementación del repositorio, DTOs y cliente HTTP). Separarlas permite cambiar la fuente de datos o probar la lógica sin tocar la UI.

**19. Tipos de prueba.** Unitaria: una función o clase aislada (la lógica del carrito). De widget: un widget con su entorno simulado, sin dispositivo. De integración: un flujo completo de la app sobre un dispositivo o emulador (buscar, ver el detalle y agregar al carrito).

**20. Convenciones de commits y PR.** [Esta pregunta es la más tuya: escribe las tres que realmente sigues. Ejemplos de tu propio flujo: Conventional Commits con tipo y alcance, una rama por story, commits pequeños, y un PR con descripción de qué y por qué.]
