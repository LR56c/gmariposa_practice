import 'package:flutter_app/features/cart/presentation/cart_provider.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Cart notifier adds products and keeps its state', () {
    final container = ProviderContainer(retry: (_, _) => null);
    addTearDown(container.dispose);
    const product = Product(
      id: 1,
      title: 'P',
      price: 2,
      rating: 4,
      imageUrl: '',
    );

    container.read(cartProvider.notifier)
      ..add(product)
      ..add(product);

    final items = container.read(cartProvider);
    expect(items.single.quantity, 2);
  });
}
