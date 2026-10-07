import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/features/settings/presentation/providers/theme_mode_provider.dart';
import 'package:flutter_app/presentation/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class App extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ToastificationWrapper(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => context.t.appTitle,
        theme: buildAppTheme(),
        darkTheme: buildAppTheme(Brightness.dark),
        themeMode: ref.watch(themeModeChoiceProvider),
        locale: TranslationProvider.of(context).flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: appRouter,
      ),
    );
  }
}
