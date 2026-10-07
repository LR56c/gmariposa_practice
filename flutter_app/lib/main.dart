import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/logging/logging_provider_observer.dart';
import 'package:flutter_app/core/shared_preferences_provider.dart';
import 'package:flutter_app/presentation/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocaleSync();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    TranslationProvider(
      child: ProviderScope(
        retry: (_, _) => null,
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        observers: const [if (!kReleaseMode) LoggingProviderObserver()],
        child: const App(),
      ),
    ),
  );
}
