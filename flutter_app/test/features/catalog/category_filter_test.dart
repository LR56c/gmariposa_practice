import 'dart:async';

import 'package:flutter/material.dart' hide Page;
import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/page.dart';
import 'package:flutter_app/features/catalog/presentation/pages/catalog_page.dart';
import 'package:flutter_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:flutter_app/features/catalog/presentation/providers/category_provider.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/product_category.dart';
import 'package:flutter_app/features/products/domain/product_repository.dart';
import 'package:flutter_app/features/products/presentation/providers/product_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

final Translations _t = AppLocale.es.buildSync();

class _MockRepository extends Mock implements ProductRepository;

Product _p(int id, String title) =>
    Product(id: id, title: title, price: 1, rating: 1, imageUrl: '');

Right<Errors, Page<Product>> _page(List<Product> items) =>
    Right(Page(items: items, total: items.length));

const _categories = [
  ProductCategory(slug: 'beauty', name: 'Beauty'),
  ProductCategory(slug: 'laptops', name: 'Laptops'),
];

_MockRepository _repository() {
  final repository = _MockRepository();
  when(() => repository.list(cancel: any(named: 'cancel')))
      .thenAnswer((_) async => _page([_p(1, 'Any product')]));
  when(() => repository.categories(cancel: any(named: 'cancel')))
      .thenAnswer((_) async => const Right(_categories));
  when(
    () => repository.byCategory(
      'beauty',
      skip: any(named: 'skip'),
      cancel: any(named: 'cancel'),
    ),
  ).thenAnswer((_) async => _page([_p(2, 'Essence Mascara')]));
  return repository;
}

void main() {
  setUpAll(() => registerFallbackValue(CancelSignal()));

  test('a late response of the previous category is dropped', () async {
    final repository = _repository();
    final slow = Completer<Either<Errors, Page<Product>>>();
    when(
      () => repository.byCategory(
        'laptops',
        skip: any(named: 'skip'),
        cancel: any(named: 'cancel'),
      ),
    ).thenAnswer((_) => slow.future);
    final container = ProviderContainer(
      overrides: [productRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(catalogProvider, (_, _) {});

    container.read(selectedCategoryProvider.notifier).set('laptops');
    await Future<void>.delayed(Duration.zero);
    container.read(selectedCategoryProvider.notifier).set('beauty');
    final state = await container.read(catalogProvider.future);
    slow.complete(_page([_p(3, 'Late laptop')]));
    await Future<void>.delayed(Duration.zero);

    expect(state.items.single.title, 'Essence Mascara');
    expect(
      container.read(catalogProvider).requireValue.items.single.title,
      'Essence Mascara',
    );
    verify(() => repository.byCategory('beauty', cancel: any(named: 'cancel')))
        .called(1);
  });

  testWidgets('choosing a category filters the list and "Todas" resets it', (
    tester,
  ) async {
    final repository = _repository();
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [productRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(home: CatalogPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Any product'), findsOneWidget);

    await tester.tap(find.text(_t.category));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beauty'));
    await tester.pumpAndSettle();

    expect(find.text('Essence Mascara'), findsOneWidget);
    expect(find.text('Any product'), findsNothing);
    expect(find.text('Beauty'), findsOneWidget); // the button shows it

    await tester.tap(find.text('Beauty'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_t.allCategories));
    await tester.pumpAndSettle();

    expect(find.text('Any product'), findsOneWidget);
    expect(find.text(_t.category), findsOneWidget);
  });
}
