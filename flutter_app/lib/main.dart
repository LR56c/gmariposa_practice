import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/logging/logging_provider_observer.dart';
import 'package:flutter_app/core/shared_preferences_provider.dart';
import 'package:flutter_app/features/settings/data/shared_preference_settings_data.dart';
import 'package:flutter_app/presentation/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Async: a non-base locale (en) is a deferred library that must be loaded.
  final prefs = await SharedPreferences.getInstance();
  final language = SharedPreferenceSettingsData(prefs).readLanguage();
  await (language == null
      ? LocaleSettings.useDeviceLocale()
      : LocaleSettings.setLocaleRaw(language));
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
