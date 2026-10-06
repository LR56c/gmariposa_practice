import 'dart:async';

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

/// Records the errors providers emit.
final class _FailureRecorder extends ProviderObserver {
  final failures = <Object>[];

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) => failures.add(error);
}

Future<_MockRepository> _pump(
  WidgetTester tester,
  Either<Errors, Page<Product>> Function() answer, {
  ProviderObserver? observer,
}) async {
  final repository = _MockRepository();
  when(() => repository.list(cancel: any(named: 'cancel')))
      .thenAnswer((_) async => answer());
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        retry: (_, _) => null,
        observers: [?observer],
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
    final recorder = _FailureRecorder();
    final repository = await _pump(
      tester,
      () => fail
          ? const Left(Errors([NetworkException()]))
          : const Right(Page(items: [_product], total: 1)),
      observer: recorder,
    );
    await tester.pump();

    expect(find.text(_t.errors.network), findsOneWidget);

    fail = false;
    await tester.tap(find.text(_t.retry));
    await tester.pump();
    await tester.pump();

    expect(find.text('Essence Mascara'), findsOneWidget);
    verify(() => repository.list(cancel: any(named: 'cancel'))).called(2);
    // Only the first load failed; the retry did not fail again.
    expect(recorder.failures, hasLength(1));
  });

  group('loadMore', () {
    Product p(int id) =>
        Product(id: id, title: 'Item $id', price: 1, rating: 1, imageUrl: '');

    Future<_MockRepository> pumpPaged(
      WidgetTester tester, {
      required int total,
      required Future<Either<Errors, Page<Product>>> Function(int skip) next,
    }) async {
      final repository = _MockRepository();
      when(
        () => repository.list(
          skip: any(named: 'skip'),
          cancel: any(named: 'cancel'),
        ),
      ).thenAnswer((i) {
        final skip = i.namedArguments[#skip]! as int;
        return skip == 0
            ? Future.value(
                Right(
                  Page(
                    items: [for (var i = 0; i < 20; i++) p(i)],
                    total: total,
                  ),
                ),
              )
            : next(skip);
      });
      await tester.pumpWidget(
        TranslationProvider(
          child: ProviderScope(
            retry: (_, _) => null,
            overrides: [
              productRepositoryProvider.overrideWithValue(repository),
            ],
            child: const MaterialApp(home: CatalogPage()),
          ),
        ),
      );
      await tester.pump();
      return repository;
    }

    Future<void> scrollToEnd(WidgetTester tester) async {
      await tester.drag(find.byType(ListView), const Offset(0, -20000));
      await tester.pump();
    }

    testWidgets('appends the next page with skip = items.length', (
      tester,
    ) async {
      final repository = await pumpPaged(
        tester,
        total: 25,
        next: (skip) async =>
            Right(Page(items: [for (var i = 20; i < 25; i++) p(i)], total: 25)),
      );
      await scrollToEnd(tester);
      await tester.pump();
      await scrollToEnd(tester);

      verify(() => repository.list(skip: 20, cancel: any(named: 'cancel')))
          .called(1);
      expect(find.text('Item 24'), findsOneWidget);
      expect(find.text(_t.noMoreProducts), findsOneWidget);
    });

    testWidgets('keeps the list and retries when a page fails', (tester) async {
      var fail = true;
      await pumpPaged(
        tester,
        total: 25,
        next: (skip) async => fail
            ? const Left(Errors([NetworkException()]))
            : Right(Page(items: [p(20)], total: 25)),
      );
      await scrollToEnd(tester);
      await tester.pump();
      await scrollToEnd(tester);

      expect(find.text(_t.errors.network), findsOneWidget);
      expect(find.text('Item 19'), findsOneWidget);

      fail = false;
      await tester.tap(find.text(_t.retry));
      await tester.pump();
      await tester.pump();
      await scrollToEnd(tester);

      expect(find.text('Item 20'), findsOneWidget);
    });

    testWidgets('never has two pages in flight', (tester) async {
      final completer = Completer<Either<Errors, Page<Product>>>();
      final repository = await pumpPaged(
        tester,
        total: 100,
        next: (_) => completer.future,
      );
      await scrollToEnd(tester);
      await scrollToEnd(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      verify(() => repository.list(skip: 20, cancel: any(named: 'cancel')))
          .called(1);
      completer.complete(const Right(Page(items: [], total: 100)));
      await tester.pump();
    });
  });
}
