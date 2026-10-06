import 'package:flutter/material.dart' hide Page;
import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/errors/base_exception.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/page.dart';
import 'package:flutter_app/features/catalog/presentation/catalog_page.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/product_repository.dart';
import 'package:flutter_app/features/products/presentation/provider/product_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

final Translations _t = AppLocale.es.buildSync();

class _MockRepository extends Mock implements ProductRepository;

const _product = Product(
  id: 1,
  title: 'Essence Mascara',
  price: 9.99,
  rating: 4.5,
  // Empty URL: the thumbnail shows "Sin foto" without touching the network.
  imageUrl: '',
);

Future<_MockRepository> _pump(
  WidgetTester tester,
  Either<Errors, Page<Product>> Function() answer,
) async {
  final repository = _MockRepository();
  when(() => repository.list(cancel: any(named: 'cancel')))
      .thenAnswer((_) async => answer());
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        retry: (_, _) => null,
        overrides: [productRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: CatalogPage()),
      ),
    ),
  );
  return repository;
}

void main() {
  setUpAll(() => registerFallbackValue(CancelSignal()));

  testWidgets('shows the products with title, price and rating', (
    tester,
  ) async {
    await _pump(tester, () => const Right(Page(items: [_product], total: 1)));
    await tester.pump();

    expect(find.text('Essence Mascara'), findsOneWidget);
    expect(find.text('9.99'), findsOneWidget);
    expect(find.text('★ 4.5'), findsOneWidget);
    expect(find.text(_t.noPhoto), findsOneWidget);
  });

  testWidgets('shows "No hay productos" for an empty page', (tester) async {
    await _pump(tester, () => const Right(Page(items: [], total: 0)));
    await tester.pump();

    expect(find.text(_t.emptyCatalog), findsOneWidget);
  });

  testWidgets('shows the error and "Reintentar" reloads the Catalog', (
    tester,
  ) async {
    var fail = true;
    final repository = await _pump(
      tester,
      () => fail
          ? const Left(Errors([NetworkException()]))
          : const Right(Page(items: [_product], total: 1)),
    );
    await tester.pump();

    expect(find.text(_t.errors.network), findsOneWidget);

    fail = false;
    await tester.tap(find.text(_t.retry));
    await tester.pump();
    await tester.pump();

    expect(find.text('Essence Mascara'), findsOneWidget);
    verify(() => repository.list(cancel: any(named: 'cancel'))).called(2);
  });
}
