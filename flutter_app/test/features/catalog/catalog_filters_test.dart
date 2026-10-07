// `skip: 0` is spelled out on purpose: the stubs tell page 1 from page 2.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';

import 'package:flutter/material.dart' hide Page;
import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/page.dart';
import 'package:flutter_app/features/catalog/presentation/pages/catalog_page.dart';
import 'package:flutter_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:flutter_app/features/catalog/presentation/providers/category_provider.dart';
import 'package:flutter_app/features/catalog/presentation/providers/search_provider.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/product_repository.dart';
import 'package:flutter_app/features/products/presentation/providers/product_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/prefs.dart';

class _MockRepository extends Mock implements ProductRepository;

Product _p(int id, String title) =>
    Product(id: id, title: title, price: 1, rating: 1, imageUrl: '');

Right<Errors, Page<Product>> _page(List<Product> items, {int? total}) =>
    Right(Page(items: items, total: total ?? items.length));

Future<ProviderContainer> _container(
  _MockRepository repository, {
  String? term,
}) async {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      productRepositoryProvider.overrideWithValue(repository),
      await prefsOverride(),
      if (term != null)
        debouncedTermProvider.overrideWith((ref) => Stream.value(term)),
    ],
  );
  addTearDown(container.dispose);
  container.listen(catalogProvider, (_, _) {});
  return container;
}

List<String> _titles(ProviderContainer container) => container
    .read(catalogProvider)
    .requireValue
    .items
    .map((p) => p.title)
    .toList();

void main() {
  setUpAll(() => registerFallbackValue(CancelSignal()));

  late _MockRepository repository;

  setUp(() {
    repository = _MockRepository();
    when(() => repository.categories(cancel: any(named: 'cancel')))
        .thenAnswer((_) async => const Right([]));
  });

  group('category + search term', () {
    test(
      'filters the whole category by title and has no further page',
      () async {
        when(() => repository.list(skip: 0, cancel: any(named: 'cancel')))
            .thenAnswer((_) async => _page([_p(1, 'Any')]));
        when(
          () => repository.byCategory(
            'beauty',
            limit: 0,
            cancel: any(named: 'cancel'),
          ),
        ).thenAnswer(
          (_) async => _page([
            _p(2, 'Essence Mascara'),
            _p(3, 'Red Lipstick'),
            _p(4, 'Mascara Pro'),
          ]),
        );
        final container = await _container(repository, term: 'mascara');
        container.read(selectedCategoryProvider.notifier).set('beauty');
        await pumpEventQueue();

        final state = container.read(catalogProvider).requireValue;
        expect(_titles(container), ['Essence Mascara', 'Mascara Pro']);
        expect(state.total, state.items.length);
        verifyNever(
          () => repository.search(any(), cancel: any(named: 'cancel')),
        );

        await container.read(catalogProvider.notifier).loadMore();

        verify(
          () => repository.byCategory(
            'beauty',
            limit: 0,
            cancel: any(named: 'cancel'),
          ),
        ).called(1);
      },
    );
  });

  group('loadMore under a filter', () {
    test(
      'asks the category for the next page with skip = items.length',
      () async {
        when(
          () => repository.byCategory(
            'beauty',
            skip: 0,
            cancel: any(named: 'cancel'),
          ),
        ).thenAnswer((_) async => _page([_p(1, 'a'), _p(2, 'b')], total: 3));
        when(
          () => repository.byCategory(
            'beauty',
            skip: 2,
            cancel: any(named: 'cancel'),
          ),
        ).thenAnswer((_) async => _page([_p(3, 'c')], total: 3));
        when(() => repository.list(skip: 0, cancel: any(named: 'cancel')))
            .thenAnswer((_) async => _page([_p(9, 'unfiltered')]));
        final container = await _container(repository);
        container.read(selectedCategoryProvider.notifier).set('beauty');
        await pumpEventQueue();

        await container.read(catalogProvider.notifier).loadMore();

        expect(_titles(container), ['a', 'b', 'c']);
      },
    );

    test(
      'asks the search for the next page with skip = items.length',
      () async {
        when(() => repository.list(skip: 0, cancel: any(named: 'cancel')))
            .thenAnswer((_) async => _page([_p(9, 'unfiltered')]));
        when(
          () => repository.search('mas', skip: 0, cancel: any(named: 'cancel')),
        ).thenAnswer((_) async => _page([_p(1, 'mas 1')], total: 2));
        when(
          () => repository.search('mas', skip: 1, cancel: any(named: 'cancel')),
        ).thenAnswer((_) async => _page([_p(2, 'mas 2')], total: 2));
        final container = await _container(repository, term: 'mas');
        await pumpEventQueue();

        await container.read(catalogProvider.notifier).loadMore();

        expect(_titles(container), ['mas 1', 'mas 2']);
      },
    );

    test('a late page from the previous filter is dropped', () async {
      final slow = Completer<Either<Errors, Page<Product>>>();
      when(() => repository.list(skip: 0, cancel: any(named: 'cancel')))
          .thenAnswer((_) async => _page([_p(1, 'a'), _p(2, 'b')], total: 5));
      when(() => repository.list(skip: 2, cancel: any(named: 'cancel')))
          .thenAnswer((_) => slow.future);
      when(
        () => repository.byCategory(
          'beauty',
          skip: 0,
          cancel: any(named: 'cancel'),
        ),
      ).thenAnswer((_) async => _page([_p(7, 'beauty only')]));
      final container = await _container(repository);
      await pumpEventQueue();

      unawaited(container.read(catalogProvider.notifier).loadMore());
      container.read(selectedCategoryProvider.notifier).set('beauty');
      await pumpEventQueue();
      slow.complete(_page([_p(3, 'late')], total: 5));
      await pumpEventQueue();

      expect(_titles(container), ['beauty only']);
    });

    test('is ignored while the Catalog reloads', () async {
      final reload = Completer<Either<Errors, Page<Product>>>();
      when(() => repository.list(skip: 0, cancel: any(named: 'cancel')))
          .thenAnswer((_) async => _page([_p(1, 'a'), _p(2, 'b')], total: 5));
      when(
        () => repository.byCategory(
          'laptops',
          skip: 0,
          cancel: any(named: 'cancel'),
        ),
      ).thenAnswer((_) => reload.future);
      final container = await _container(repository);
      await pumpEventQueue();

      container.read(selectedCategoryProvider.notifier).set('laptops');
      await pumpEventQueue();
      expect(container.read(catalogProvider).isLoading, isTrue);
      await container.read(catalogProvider.notifier).loadMore();

      verifyNever(
        () => repository.byCategory(
          'laptops',
          skip: 2,
          cancel: any(named: 'cancel'),
        ),
      );
    });
  });

  testWidgets('typing a term searches and shows the results', (tester) async {
    when(() => repository.list(skip: 0, cancel: any(named: 'cancel')))
        .thenAnswer((_) async => _page([_p(1, 'Any product')]));
    when(() => repository.search('mas', skip: 0, cancel: any(named: 'cancel')))
        .thenAnswer((_) async => _page([_p(2, 'Essence Mascara')]));
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          retry: (_, _) => null,
          overrides: [
            productRepositoryProvider.overrideWithValue(repository),
            await prefsOverride(),
          ],
          child: const MaterialApp(home: CatalogPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Any product'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'mas');
    await tester.pump(searchDebounce + const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Essence Mascara'), findsOneWidget);
    expect(find.text('Any product'), findsNothing);
    verify(
      () => repository.search('mas', skip: 0, cancel: any(named: 'cancel')),
    ).called(1);
  });
}
