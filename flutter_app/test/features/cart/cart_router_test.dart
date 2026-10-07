import 'package:flutter/material.dart' hide Page;
import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/page.dart';
import 'package:flutter_app/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter_app/features/cart/presentation/widgets/cart_icon_button.dart';
import 'package:flutter_app/features/catalog/presentation/pages/catalog_page.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/product_repository.dart';
import 'package:flutter_app/features/products/presentation/providers/product_repository_provider.dart';
import 'package:flutter_app/presentation/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/prefs.dart';

class _MockRepository extends Mock implements ProductRepository;

const _product = Product(
  id: 1,
  title: 'Product 1',
  price: 9.5,
  rating: 4.5,
  imageUrl: '',
);

/// Pumps the real [appRouter] at [location]; the router is a global, so it is
/// put back at `/` when the test ends.
Future<void> _pumpRouter(WidgetTester tester, String location) async {
  final repository = _MockRepository();
  when(() => repository.list(cancel: any(named: 'cancel')))
      .thenAnswer((_) async => const Right(Page(items: [_product], total: 1)));
  when(() => repository.categories(cancel: any(named: 'cancel')))
      .thenAnswer((_) async => const Right([]));
  addTearDown(() => appRouter.go('/'));
  appRouter.go(location);
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        retry: (_, _) => null,
        overrides: [
          productRepositoryProvider.overrideWithValue(repository),
          await prefsOverride(),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => registerFallbackValue(CancelSignal()));

  testWidgets('back on a Cart opened by URL goes to the Catalog', (
    tester,
  ) async {
    await _pumpRouter(tester, '/cart'); // cold entry: nothing to pop
    expect(find.byType(CartPage), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(CatalogPage), findsOneWidget);
    expect(find.byType(CartPage), findsNothing);
  });

  testWidgets('the Cart icon opens the Cart and back returns to the Catalog', (
    tester,
  ) async {
    await _pumpRouter(tester, '/');

    await tester.tap(find.byType(CartIconButton));
    await tester.pumpAndSettle();
    expect(find.byType(CartPage), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(CatalogPage), findsOneWidget);
    expect(find.byType(CartPage), findsNothing);
  });
}
