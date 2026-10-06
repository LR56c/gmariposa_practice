import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/features/cart/domain/cart_item.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_app/features/cart/presentation/widgets/cart_badge.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _product = Product(
  id: 1,
  title: 'P1',
  price: 10,
  rating: 4,
  imageUrl: '',
);

void main() {
  late ProviderContainer container;

  Future<void> pumpBadge(WidgetTester tester) async {
    container = ProviderContainer(retry: (_, _) => null);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      TranslationProvider(
        child: UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: CartBadge())),
        ),
      ),
    );
  }

  void setUnits(int n) => container.read(cartProvider.notifier).state = [
    CartItem(product: _product, quantity: n),
  ];

  test('cartCount sums units across items, 0 when empty', () {
    final c = ProviderContainer(retry: (_, _) => null);
    addTearDown(c.dispose);
    expect(c.read(cartCountProvider), 0);
    c.read(cartProvider.notifier).state = [
      const CartItem(product: _product, quantity: 2),
      CartItem(product: _product.copyWith(id: 2), quantity: 3),
    ];
    expect(c.read(cartCountProvider), 5);
  });

  testWidgets('hidden with 0, visible with units, 99+ past the limit', (
    tester,
  ) async {
    await pumpBadge(tester);
    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);

    setUnits(5);
    await tester.pump();
    expect(find.text('5'), findsOneWidget);

    setUnits(100);
    await tester.pump();
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('semantics label uses singular and plural', (tester) async {
    await pumpBadge(tester);
    expect(find.bySemanticsLabel('Carrito vacío'), findsOneWidget);

    setUnits(1);
    await tester.pump();
    expect(find.bySemanticsLabel('Carrito, 1 unidad'), findsOneWidget);

    setUnits(3);
    await tester.pump();
    expect(find.bySemanticsLabel('Carrito, 3 unidades'), findsOneWidget);
  });
}
