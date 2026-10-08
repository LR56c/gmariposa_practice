parte 1

dart y flutter

1. `final` se asigna una vez y se evalúa en tiempo de ejecución. `const` es una constante de compilación y las instancias idénticas se reutilizan. En widgets, un constructor `const` permite que Flutter reutilice la instancia y se salte la reconstrucción de ese widget-tree cuando nada cambió.

2. Null safety: previene errores en tiempo de ejecución causados por posibles valores null, obligando a manejarlo de forma explícita.
 `?` declara que puede ser nulo o uso de operador ternario, `??` da un valor por defecto, `late` promete que el valor estará establecido antes de usar. Abusar de `!` devuelve el error a tiempo de ejecución, que es lo que null safety evita.

3. `StatelessWidget` no guarda estado propio. `StatefulWidget`, tiene un `State` que sobrevive a las reconstrucciones/rebuild. `ConsumerWidget` es un stateless que recibe un `WidgetRef` en `build` para leer providers. `ConsumerStatefulWidget` hace lo mismo con un `State` que expone `ref`.

4. Un `Future` entrega un único valor futuro (cargar un producto por id). Un `Stream` entrega varios valores a lo largo del tiempo (cambios de conectividad, un chat en vivo).

5. Una clase propia puede ser `const`, tiene su propio contexto y ciclo de reconstrucción, y se prueba de forma aislada. Un método se ejecuta siempre dentro del build del padre y no se puede marcar `const`.

riverpod

6. `setState` vincula el estado a un widget. Riverpod saca el estado del árbol de widgets y concede funcionalidades extra como tener mayor control del ciclo de vida de los providers, cache, estados asíncronos, facilitar pruebas.

7. `watch` observa y reconstruye cuando cambia, en build. `read` lee una vez, en ese momento. `listen` ejecuta un efecto secundario al cambiar sin reconstruir. Es incorrecto usar `read` en `build` ya que la UI puede quedar desincronizada. Tampoco se usa `ref` en `dispose`.

8. `Provider` para un valor de solo lectura o una dependencia. `FutureProvider` para cargar algo asíncrono una vez, sin métodos para modificarlo. `Notifier` para estado síncrono con métodos. `AsyncNotifier` para estado asíncrono con métodos.

9. `autoDispose` destruye el estado cuando nadie lo escucha, liberando memoria y forzando una nueva carga la próxima vez. `family` crea un provider por parámetro (un estado por `id` de producto).

10.
```dart
final products = ref.watch(productsProvider);
return switch (products) {
  AsyncData(:final value) => Text('${value.length} productos'),
  AsyncError(:final error) => Text('Error: $error'),
  _ => const CircularProgressIndicator(),
};
```

11.
Las dos formas principales son:
- ProviderScope (Para Widget/Integration Tests con árbol de widgets):
```dart
ProviderScope(
  overrides: [miRepoProvider.overrideWithValue(RepoFalso())],
  child: MyApp(),
)
```
- ProviderContainer (Para Unit Tests puros de lógica, sin UI):
```dart
final container = ProviderContainer(
  overrides: [miRepoProvider.overrideWithValue(RepoFalso())],
);
final result = container.read(miProvider);
```

angular

12. Standalone (por defecto en Angular actual): Son autónomos. Sus dependencias se declaran directamente en su propio decorador (imports), sin necesidad de un módulo, lo que simplifica el lazy loading y reduce el código repetido.
NgModule (tradicional): Requieren estar registrados en un módulo y sus dependencias se gestionan a nivel de módulo, lo que genera mayor acoplamiento y un sistema de carga más rígido.

13. Un `Observable` es un flujo asíncrono de valores en el tiempo que se consume suscribiéndose y con operadores. Un `Signal` guarda siempre un valor actual, se lee de forma síncrona y Angular actualiza solo lo que depende de él. Señal para el estado de la UI; Observable para flujos asíncronos; `toSignal` los conecta.

14. `input()` recibe datos del padre y `output()` emite eventos hacia él, en forma de señal y con tipos. Dos componentes hermanos no se hablan directamente: se comunican por el padre común (subiendo el estado) o por un servicio compartido.

15. Angular entrega las dependencias que un componente o servicio declara con `inject()`, en lugar de crearlas él. `providedIn: 'root'` registra una única instancia global del servicio y permite eliminarlo del bundle si nadie lo usa.

16. Una suscripción abierta sigue ejecutándose y reteniendo memoria aunque el componente ya no exista. Se evitan con el `async` pipe, con `toSignal` (ambos se desuscriben solos al destruirse el componente) y con `takeUntilDestroyed`.

Código limpio y buenas prácticas

17. Cada clase debe tener una sola razón para cambiar. En Flutter se aplica delegando responsabilidades: el Widget renderiza la interfaz, el Notifier maneja el estado y el Repositorio accede a los datos. Si un widget mezclara estas tareas, dependería tanto de la infraestructura como de la UI, lo que provocaría que tuviera múltiples razones para cambiar y dificultaría sus pruebas unitarias.

18. Presentación (pantallas, widgets y providers), dominio (entidades y el contrato del repositorio, sin depender de Flutter) y datos (implementación del repositorio). Separarlas permite código modular, predecible, facilita cambiar la fuente de datos o probar la lógica sin tocar la UI.

19. Una prueba unitaria verifica una función o clase aislada y es la más rápida y barata. Una de widget renderiza un widget en un entorno simulado, sin dispositivo, para comprobar la UI y su interacción. Una de integración ejecuta la app completa en un emulador y es la más lenta, pero la más cercana al uso real.

20. 
- Conventional Commits con tipo y alcance. Commits pequeños y atómicos.
- Jerarquía de ramas. Mi flujo es `main <- dev <- feature o etapa <- story`, la etapa cerrada va a `dev` y solo versiones verificadas llegan a `main`. Nunca se va directo a `main`.
- Pull requests pequeños, de una sola story y solo se fusionan con test en verde. En esta ocasión, hice el merge `--no-ff` de cada story en vez del PR.

parte 4

Fragmento A: Flutter

1. La petición HTTP está dentro de `build`. `build` se ejecuta en cada reconstrucción, y además llama a `setState`, que dispara otra reconstrucción, es un bucle de peticiones infinito. Se corrige sacando la carga a un `FutureProvider` que la ejecuta una sola vez y la cachea.
2. `ref.read(cartProvider)` en `build`. `read` no escucha cambios, así que el contador del `AppBar` nunca se actualiza. En `build` se usa `ref.watch`, para reconstruir solo si cambia la cantidad. `read` se reserva para callbacks como `onTap`.
3. Mutación directa del estado: `ref.read(cartProvider).add(p)` modifica la lista en su sitio. Como la referencia no cambia, Riverpod no notifica a la UI. El estado debe ser inmutable: `state = [...state, p]`, dentro de un método de un `Notifier`.
4. `StateProvider` con `List<Map>`, y declarado con `var`. `StateProvider` expone el estado para que cualquiera lo modifique. Se reemplaza por un `Notifier` con `add`, el único punto que cambia el estado. Se declara `final`, y `Map` sin tipos se cambia por un modelo.
5. Datos sin tipos: `List data`, `p['title']`, `p['price']` son `dynamic`; un campo mal escrito o ausente falla en ejecución. Se corrige con un modelo `Product` inmutable y `fromJson`.
6. Sin manejo de errores. Si falla la red o la respuesta no es 200, `loading` queda en `true` para siempre y no hay mensaje ni reintento. Se corrige comprobando `statusCode`, lanzando un error y mostrando un estado de error con reintento.
7. Red mezclada con la UI. La pantalla conoce la URL y el JSON, y no se puede probar sin red. Debería existir un repositorio.
8. `setState` sin comprobar `mounted`. Si la pantalla se cierra antes de que responda la petición, falla. Desaparece al usar Riverpod o manejar ciclo de vida correctamente.
9. Widget y listado: `ConsumerStatefulWidget` sobra al no haber estado local, el constructor no tiene `const` ni `super.key`, el spinner no está centrado ni dentro de un `Scaffold`. `ListView(children: ...map)` construye todos los elementos de una vez, y para listas largas se usa `ListView.builder`.
10. Menores: `print` en producción, usar un logger o dar feedback al usuario.

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class Product {
  const Product({required this.id, required this.title, required this.price});

  final int id;
  final String title;
  final double price;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        title: json['title'] as String,
        price: (json['price'] as num).toDouble(),
      );
}

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final res = await http.get(Uri.parse('https://dummyjson.com/products'));
  if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
  final list = jsonDecode(res.body)['products'] as List;
  return [for (final p in list) Product.fromJson(p as Map<String, dynamic>)];
});

class CartNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() => const [];

  void add(Product product) => state = [...state, product];
}

final cartProvider =
    NotifierProvider<CartNotifier, List<Product>>(CartNotifier.new);

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final count = ref.watch(cartProvider.select((cart) => cart.length));

    return Scaffold(
      appBar: AppBar(title: Text('Productos ($count)')),
      body: switch (products) {
        AsyncData(:final value) => ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, i) {
              final p = value[i];
              return ListTile(
                title: Text(p.title),
                subtitle: Text('\$${p.price}'),
                onTap: () => ref.read(cartProvider.notifier).add(p),
              );
            },
          ),
        AsyncError() => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(productsProvider),
              child: const Text('Error al cargar. Reintentar'),
            ),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
```

Fragmento B: Angular

1. `setInterval` nunca se limpia. Al destruir el componente el temporizador sigue pidiendo datos, retiene el componente en memoria y, si se vuelve a crear, se acumulan temporizadores. Se corrige con `timer(0, 5000)` de RxJS y `takeUntilDestroyed()`, o con un servicio, para que se cancele solo al destruirse el componente.
2. Suscripción sin cancelar dentro del intervalo. Cada tick crea una nueva suscripción y, si el servidor tarda más de 5 segundos, las peticiones se solapan y las respuestas pueden llegar desordenadas. Se usa `switchMap` (cancela la anterior).
3. Tipos `any` (`orders: any`, `r: any`): se pierde la ayuda del compilador y los errores de forma aparecen en ejecución. Se define una interfaz (`Cart`, con `id` y `total`) y se tipa `http.get<CartsResponse>`.
4. Sin manejo de errores. Si la petición falla, no se muestra nada ni se informa al usuario. Se agrega `catchError` o un estado de error, y un estado de carga y de lista vacía.
5. HTTP directo en el componente. Mezcla presentación con acceso a datos y dificulta las pruebas. Debe vivir en un servicio inyectable y el componente solo lo consume.
6. Plantilla y detección de cambios. `*ngFor` es la sintaxis antigua; se usa `@for (o of orders(); track o.id)`, que además exige `track` para no recrear el DOM. Falta `ChangeDetectionStrategy.OnPush`, y `orders` inicia en `undefined`.
7. Menores: inyección por constructor en lugar de `inject()`, `{{ o.total }}` sin formato de moneda (pipe `currency`).

Reescritura del fragmento B:

```ts
export interface Cart {
  id: number;
  total: number;
}

@Injectable({ providedIn: 'root' })
export class CartsService {
  private readonly http = inject(HttpClient);

  getCarts() {
    return this.http
      .get<{ carts: Cart[] }>('https://dummyjson.com/carts')
      .pipe(map((r) => r.carts));
  }
}

@Component({
  selector: 'app-orders',
  imports: [CurrencyPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (error()) {
      <p>Error al cargar las órdenes.</p>
    }
    @for (o of orders(); track o.id) {
      <div>{{ o.total | currency }}</div>
    } @empty {
      <p>Sin órdenes.</p>
    }
  `,
})
export class OrdersComponent {
  private readonly service = inject(CartsService);

  protected readonly error = signal(false);

  protected readonly orders = toSignal(
    timer(0, 5000).pipe(
      switchMap(() =>
        this.service.getCarts().pipe(
          tap(() => this.error.set(false)),
          catchError(() => {
            this.error.set(true);
            return EMPTY;
          }),
        ),
      ),
    ),
    { initialValue: [] as Cart[] },
  );
}
```

