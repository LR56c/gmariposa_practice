import 'package:flutter_app/core/shared_preferences_provider.dart';
import 'package:flutter_app/features/cart/data/cart_storage.dart';
import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/prefs.dart';

const _product = Product(
  id: 1,
  title: 'Essence Mascara',
  price: 9.99,
  rating: 4.5,
  imageUrl: 'https://example.com/a.png',
);

Future<SharedPreferences> _prefs([Map<String, Object> initial = const {}]) {
  SharedPreferences.setMockInitialValues(initial);
  return SharedPreferences.getInstance();
}

void main() {
  test('write then read returns the same Cart', () async {
    final storage = CartStorage(await _prefs());
    const items = [CartItem(product: _product, quantity: 3)];

    await storage.write(items);

    expect(storage.read(), items);
  });

  test('a corrupt value reads as an empty Cart and is discarded', () async {
    final prefs = await _prefs({CartStorage.key: '{not json'});

    expect(CartStorage(prefs).read(), isEmpty);
    expect(prefs.containsKey(CartStorage.key), isFalse);
  });

  test('an outdated format reads as an empty Cart', () async {
    final prefs = await _prefs({CartStorage.key: '[{"id":1}]'});

    expect(CartStorage(prefs).read(), isEmpty);
  });

  test('the Cart starts from the saved one', () async {
    final storage = CartStorage(await _prefs());
    await storage.write(const [CartItem(product: _product, quantity: 2)]);
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(cartProvider).single.quantity, 2);
    expect(container.read(cartCountProvider), 2);
  });

  test('adding a product writes the Cart to storage', () async {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [await prefsOverride()],
    );
    addTearDown(container.dispose);

    container.read(cartProvider.notifier).add(_product);
    await Future<void>.delayed(Duration.zero);

    final saved = CartStorage(await SharedPreferences.getInstance()).read();
    expect(saved.single.product, _product);
    expect(saved.single.quantity, 1);
  });

  test('removing the last item saves an empty Cart', () async {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [await prefsOverride()],
    );
    addTearDown(container.dispose);

    container.read(cartProvider.notifier)
      ..add(_product)
      ..remove(_product.id);
    await Future<void>.delayed(Duration.zero);

    expect(CartStorage(await SharedPreferences.getInstance()).read(), isEmpty);
  });
}
