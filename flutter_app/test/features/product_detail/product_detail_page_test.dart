import 'package:flutter/material.dart';
import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/errors/base_exception.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_app/features/product_detail/presentation/pages/product_detail_page.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/product_repository.dart';
import 'package:flutter_app/features/products/presentation/providers/product_repository_provider.dart';
import 'package:flutter_app/presentation/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

import '../../support/prefs.dart';

final Translations _t = AppLocale.es.buildSync();

class _MockRepository extends Mock implements ProductRepository;

Product _product(int id) => Product(
  id: id,
  title: 'Product $id',
  price: 9.5,
  rating: 4.5,
  // Empty URL: the image shows "Sin foto" without touching the network.
  imageUrl: '',
);

late Override prefs;

Widget _app(_MockRepository repository, Widget home) => TranslationProvider(
  child: ProviderScope(
    retry: (_, _) => null,
    overrides: [productRepositoryProvider.overrideWithValue(repository), prefs],
    child: ToastificationWrapper(child: MaterialApp(home: home)),
  ),
);

void main() {
  late _MockRepository repository;

  setUp(() async => prefs = await prefsOverride());

  setUpAll(() => registerFallbackValue(CancelSignal()));
  setUp(() => repository = _MockRepository());

  void answer(int id, Either<Errors, Product> Function() result) =>
      when(() => repository.getById(id, cancel: any(named: 'cancel')))
          .thenAnswer((_) async => result());

  testWidgets('shows the product and an active "Agregar al carrito"', (
    tester,
  ) async {
    answer(1, () => Right(_product(1)));
    await tester.pumpWidget(_app(repository, const ProductDetailPage(id: 1)));
    expect(find.bySubtype<Skeletonizer>(), findsOneWidget);
    await tester.pump();

    expect(find.text('Product 1'), findsOneWidget);
    expect(find.text('9.50'), findsOneWidget);
    expect(find.text('★ 4.5'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
    expect(find.text(_t.addToCart), findsOneWidget);
  });

  testWidgets('tapping "Agregar al carrito" adds the product and toasts', (
    tester,
  ) async {
    answer(1, () => Right(_product(1)));
    await tester.pumpWidget(_app(repository, const ProductDetailPage(id: 1)));
    await tester.pump();

    await tester.tap(find.text(_t.addToCart));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProductDetailPage)),
    );
    expect(container.read(cartProvider).single.product.id, 1);
    expect(find.text(_t.addedToCart), findsOneWidget);

    // Let the toast auto-close so no timer stays pending.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('shows the error and "Reintentar" reloads the product', (
    tester,
  ) async {
    var fail = true;
    answer(
      1,
      () =>
          fail ? const Left(Errors([NetworkException()])) : Right(_product(1)),
    );
    await tester.pumpWidget(_app(repository, const ProductDetailPage(id: 1)));
    await tester.pump();
    expect(find.text(_t.errors.network), findsOneWidget);

    fail = false;
    await tester.tap(find.text(_t.retry));
    await tester.pump();
    await tester.pump();

    expect(find.text('Product 1'), findsOneWidget);
    verify(() => repository.getById(1, cancel: any(named: 'cancel'))).called(2);
  });

  testWidgets('a 404 shows "No encontramos ese producto."', (tester) async {
    answer(404, () => const Left(Errors([NotFoundException()])));
    await tester.pumpWidget(_app(repository, const ProductDetailPage(id: 404)));
    await tester.pump();

    expect(find.text('No encontramos ese producto.'), findsOneWidget);
    expect(find.text(_t.errors.server), findsNothing);
    // Retrying a missing product is pointless: the way back replaces it.
    expect(find.text(_t.retry), findsNothing);
    expect(find.text(_t.backToCatalog), findsOneWidget);
  });

  testWidgets('each id keeps its own state', (tester) async {
    answer(1, () => Right(_product(1)));
    answer(2, () => Right(_product(2)));
    for (final id in [1, 2]) {
      await tester.pumpWidget(_app(repository, ProductDetailPage(id: id)));
      await tester.pump();
      expect(find.text('Product $id'), findsOneWidget);
    }
    verify(() => repository.getById(1, cancel: any(named: 'cancel'))).called(1);
    verify(() => repository.getById(2, cancel: any(named: 'cancel'))).called(1);
  });

  testWidgets('/product/abc goes to the error screen without a request', (
    tester,
  ) async {
    // The router is a global: put it back so other tests start at `/`.
    addTearDown(() => appRouter.go('/'));
    appRouter.go('/product/abc');
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          retry: (_, _) => null,
          overrides: [
            productRepositoryProvider.overrideWithValue(repository),
            prefs,
          ],
          child: MaterialApp.router(routerConfig: appRouter),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('No encontramos ese producto.'), findsOneWidget);
    verifyZeroInteractions(repository);
  });
}
