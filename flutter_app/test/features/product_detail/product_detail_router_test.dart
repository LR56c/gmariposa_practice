import 'dart:async';

import 'package:flutter/material.dart' hide Page;
import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/page.dart';
import 'package:flutter_app/features/catalog/presentation/pages/catalog_page.dart';
import 'package:flutter_app/features/product_detail/presentation/pages/product_detail_page.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/product_repository.dart';
import 'package:flutter_app/features/products/presentation/providers/product_repository_provider.dart';
import 'package:flutter_app/presentation/not_found_page.dart';
import 'package:flutter_app/presentation/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/prefs.dart';

final Translations _t = AppLocale.es.buildSync();

class _MockRepository extends Mock implements ProductRepository;

const _product = Product(
  id: 7,
  title: 'Product 7',
  price: 9.5,
  rating: 4.5,
  imageUrl: '',
);

/// Pumps the real [appRouter] at [location]; the router is a global, so it is
/// put back at `/` when the test ends.
Future<_MockRepository> _pumpRouter(
  WidgetTester tester,
  String location,
) async {
  final repository = _MockRepository();
  when(() => repository.list(cancel: any(named: 'cancel')))
      .thenAnswer((_) async => const Right(Page(items: [_product], total: 1)));
  when(() => repository.categories(cancel: any(named: 'cancel')))
      .thenAnswer((_) async => const Right([]));
  when(() => repository.getById(7, cancel: any(named: 'cancel')))
      .thenAnswer((_) async => const Right(_product));
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
  return repository;
}

void main() {
  setUpAll(() => registerFallbackValue(CancelSignal()));

  testWidgets('/product/7 loads that product by id', (tester) async {
    final repository = await _pumpRouter(tester, '/product/7');

    expect(find.byType(ProductDetailPage), findsOneWidget);
    expect(find.text('Product 7'), findsOneWidget);
    verify(() => repository.getById(7, cancel: any(named: 'cancel'))).called(1);
  });

  testWidgets('back on a detail opened by URL goes to the Catalog', (
    tester,
  ) async {
    await _pumpRouter(tester, '/product/7'); // cold entry: nothing to pop

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(CatalogPage), findsOneWidget);
    expect(find.byType(ProductDetailPage), findsNothing);
  });

  testWidgets('back on a pushed detail pops to the Catalog', (tester) async {
    await _pumpRouter(tester, '/');
    unawaited(appRouter.push<void>('/product/7'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailPage), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(CatalogPage), findsOneWidget);
    expect(find.byType(ProductDetailPage), findsNothing);
  });

  testWidgets('an unknown route shows the not-found page with a way back', (
    tester,
  ) async {
    await _pumpRouter(tester, '/does-not-exist');

    expect(find.byType(NotFoundPage), findsOneWidget);

    await tester.tap(find.text(_t.backToCatalog));
    await tester.pumpAndSettle();

    expect(find.byType(CatalogPage), findsOneWidget);
  });
}
