import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/logging/logging_provider_observer.dart';
import 'package:flutter_app/presentation/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocaleSync();
  runApp(
    TranslationProvider(
      child: ProviderScope(
        retry: (_, _) => null,
        observers: const [if (!kReleaseMode) LoggingProviderObserver()],
        child: const App(),
      ),
    ),
  );
}
