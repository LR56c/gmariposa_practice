import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/cart/domain/cart_repository.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_repository_provider.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/prefs.dart';

Product _p(int id, double price) =>
    Product(id: id, title: 'P$id', price: price, rating: 4, imageUrl: '');

/// A Cart store whose every write fails.
class _FailingCart implements CartRepository {
  @override
  List<CartItem> read() => const [];

  @override
  Future<void> write(List<CartItem> items) => Future.error(StateError('disk'));
}

void main() {
  late ProviderContainer container;
  late Cart cart;

  setUp(() async {
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [await prefsOverride()],
    );
    addTearDown(container.dispose);
    cart = container.read(cartProvider.notifier);
  });

  test('adds a new product with quantity 1', () {
    cart.add(_p(1, 10));
    expect(container.read(cartProvider).single.quantity, 1);
  });

  test('adding an existing product bumps quantity without duplicating', () {
    cart
      ..add(_p(1, 10))
      ..add(_p(1, 10));
    expect(container.read(cartProvider).single.quantity, 2);
  });

  test('decrease never goes below 1 nor removes the item', () {
    cart
      ..add(_p(1, 10))
      ..decrease(1);
    expect(container.read(cartProvider).single.quantity, 1);
    cart
      ..increase(1)
      ..decrease(1);
    expect(container.read(cartProvider).single.quantity, 1);
  });

  test('remove drops the item; the last one leaves an empty list', () {
    cart
      ..add(_p(1, 10))
      ..add(_p(2, 5))
      ..remove(1);
    expect(container.read(cartProvider).map((i) => i.product.id), [2]);
    cart.remove(2);
    expect(container.read(cartProvider), isEmpty);
  });

  test('a failed save keeps the Cart in memory and raises no error', () async {
    final failing = ProviderContainer(
      retry: (_, _) => null,
      overrides: [cartRepositoryProvider.overrideWithValue(_FailingCart())],
    );
    addTearDown(failing.dispose);

    failing.read(cartProvider.notifier).add(_p(1, 10));
    await pumpEventQueue(); // an unhandled async error would fail the test

    expect(failing.read(cartProvider).single.quantity, 1);
  });

  test('total and units sum over quantities', () {
    cart
      ..add(_p(1, 10.5))
      ..increase(1)
      ..add(_p(2, 5))
      ..increase(2)
      ..increase(2);
    expect(container.read(cartTotalProvider), 36);
    expect(container.read(cartCountProvider), 5);
  });
}
