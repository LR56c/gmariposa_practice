import 'package:flutter/material.dart' hide Page;
import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/page.dart';
import 'package:flutter_app/core/shared_preferences_provider.dart';
import 'package:flutter_app/features/cart/presentation/widgets/cart_badge.dart';
import 'package:flutter_app/features/catalog/presentation/providers/search_provider.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/product_repository.dart';
import 'package:flutter_app/features/products/presentation/providers/product_repository_provider.dart';
import 'package:flutter_app/presentation/app.dart';
import 'package:flutter_app/presentation/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockRepository extends Mock implements ProductRepository;

const _term = 'phone';
const _toastLifetime = Duration(seconds: 5);
const _phone = Product(
  id: 7,
  title: 'Fake Phone',
  price: 199.5,
  rating: 4.2,
  // Empty URL: the image shows "Sin foto" without touching the network.
  imageUrl: '',
);
const _other = Product(
  id: 8,
  title: 'Fake Mascara',
  price: 9.99,
  rating: 4.8,
  imageUrl: '',
);

/// Serves fixed data, so a DummyJSON outage can't break the test.
_MockRepository _repository() {
  final repository = _MockRepository();
  when(() => repository.list(cancel: any(named: 'cancel'))).thenAnswer(
    (_) async => const Right(Page(items: [_phone, _other], total: 2)),
  );
  when(() => repository.search(_term, cancel: any(named: 'cancel')))
      .thenAnswer((_) async => const Right(Page(items: [_phone], total: 1)));
  when(() => repository.getById(_phone.id, cancel: any(named: 'cancel')))
      .thenAnswer((_) async => const Right(_phone));
  return repository;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => registerFallbackValue(CancelSignal()));

  testWidgets('search -> detail -> add to cart -> cart, badge survives back', (
    tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.es);
    final t = AppLocale.es.buildSync();
    SharedPreferences.setMockInitialValues({});
    final repository = _repository();
    // The router is a global: start every run from the Catalog.
    appRouter.go('/');

    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          retry: (_, _) => null,
          overrides: [
            productRepositoryProvider.overrideWithValue(repository),
            sharedPreferencesProvider.overrideWithValue(
              await SharedPreferences.getInstance(),
            ),
          ],
          child: const App(),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Fake Phone'), findsOneWidget);
    expect(find.text('Fake Mascara'), findsOneWidget);

    // Typing key by key must end in a single query, after the debounce.
    await tester.enterText(find.byType(TextField), _term);
    await tester.pump(searchDebounce + const Duration(milliseconds: 100));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    verify(() => repository.search(_term, cancel: any(named: 'cancel')))
        .called(1);
    expect(find.text('Fake Mascara'), findsNothing);

    await tester.tap(find.text('Fake Phone'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.text(t.addToCart));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(t.addedToCart), findsOneWidget);
    expect(_badgeText(), '1');
    // The toast overlaps the AppBar until it expires.
    await tester.pump(_toastLifetime);

    await tester.tap(find.byType(CartBadge));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Fake Phone'), findsOneWidget);
    expect(find.text(t.total(amount: '199.50')), findsOneWidget);

    appRouter.go('/');
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(_badgeText(), '1');
  });
}

String? _badgeText() =>
    (find
                .descendant(of: find.byType(Badge), matching: find.byType(Text))
                .evaluate()
                .first
                .widget
            as Text)
        .data;
