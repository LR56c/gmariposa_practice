import 'package:flutter/material.dart' hide Page;
import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/page.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/product_repository.dart';
import 'package:flutter_app/features/products/presentation/providers/product_repository_provider.dart';
import 'package:flutter_app/features/settings/data/shared_preference_settings_data.dart';
import 'package:flutter_app/presentation/app.dart';
import 'package:flutter_app/presentation/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/prefs.dart';

class _MockRepository extends Mock implements ProductRepository;

Future<void> _pumpApp(WidgetTester tester) async {
  final repository = _MockRepository();
  when(() => repository.list(cancel: any(named: 'cancel'))).thenAnswer(
    (_) async => const Right(
      Page(
        items: [
          Product(id: 1, title: 'Product 1', price: 1, rating: 1, imageUrl: ''),
        ],
        total: 1,
      ),
    ),
  );
  when(() => repository.categories(cancel: any(named: 'cancel')))
      .thenAnswer((_) async => const Right([]));
  // The router and the locale are globals: put them back after the test.
  addTearDown(() => appRouter.go('/'));
  addTearDown(() => LocaleSettings.setLocale(AppLocale.es));
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        retry: (_, _) => null,
        overrides: [
          productRepositoryProvider.overrideWithValue(repository),
          await prefsOverride(),
        ],
        child: const App(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => registerFallbackValue(CancelSignal()));

  testWidgets('choosing a theme applies it to the app and saves it', (
    tester,
  ) async {
    await _pumpApp(tester);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );

    await _openSettings(tester);
    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(SharedPreferenceSettingsData.themeKey), 'dark');
  });

  testWidgets('choosing English switches the language and saves it', (
    tester,
  ) async {
    await _pumpApp(tester);
    expect(find.text('Mini Catálogo'), findsOneWidget);

    await _openSettings(tester);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(LocaleSettings.currentLocale, AppLocale.en);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(SharedPreferenceSettingsData.languageKey), 'en');
  });
}
