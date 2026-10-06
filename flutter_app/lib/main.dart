import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/presentation/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocaleSync();
  runApp(
    TranslationProvider(
      // No automatic retry: "Reintentar" is the only retry (AD-5).
      child: ProviderScope(retry: (_, _) => null, child: const App()),
    ),
  );
}
