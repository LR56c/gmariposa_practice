import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final Translations _t = AppLocale.es.buildSync();

Product _p(int id, double price) => Product(
  id: id,
  title: 'P$id',
  price: price,
  rating: 4,
  // Empty URL: "Sin foto" without touching the network.
  imageUrl: '',
);

void main() {
  late ProviderContainer container;

  Future<void> pumpCart(WidgetTester tester) async {
    container = ProviderContainer(retry: (_, _) => null);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      TranslationProvider(
        child: UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: CartPage()),
        ),
      ),
    );
  }

  testWidgets('"+" and "−" update quantity, units and total', (tester) async {
    await pumpCart(tester);
    container.read(cartProvider.notifier).add(_p(1, 10.5));
    await tester.pump();

    expect(find.text('Total 10.50'), findsOneWidget);
    expect(find.text('1 unidad'), findsOneWidget);
    // At quantity 1 "−" is disabled and does nothing.
    final minus = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.remove),
    );
    expect(minus.onPressed, isNull);

    await tester.tap(find.byTooltip(_t.increaseQuantity(title: 'P1')));
    await tester.pump();
    expect(find.text('Total 21.00'), findsOneWidget);
    expect(find.text('2 unidades'), findsOneWidget);

    await tester.tap(find.byTooltip(_t.decreaseQuantity(title: 'P1')));
    await tester.pump();
    expect(find.text('Total 10.50'), findsOneWidget);
    expect(container.read(cartProvider).single.quantity, 1);
  });

  testWidgets('"Quitar" removes the item; the last one shows the empty state', (
    tester,
  ) async {
    await pumpCart(tester);
    container.read(cartProvider.notifier)
      ..add(_p(1, 10))
      ..add(_p(2, 5));
    await tester.pump();

    await tester.tap(find.text(_t.remove).first);
    await tester.pump();
    expect(container.read(cartProvider).single.product.id, 2);
    expect(find.text('Total 5.00'), findsOneWidget);

    await tester.tap(find.text(_t.remove));
    await tester.pump();
    expect(find.text(_t.cartEmpty), findsOneWidget);
    expect(find.textContaining('Total'), findsNothing);
  });
}
