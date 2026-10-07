import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/features/settings/presentation/providers/settings_repository_provider.dart';
import 'package:flutter_app/features/settings/presentation/providers/theme_mode_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

Future<void> showSettingsSheet(BuildContext context) =>
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (_) => [
        SliverWoltModalSheetPage(
          topBarTitle: Text(
            context.t.settings,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          isTopBarLayerAlwaysVisible: true,
          mainContentSliversBuilder: (_) => const [
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(child: _SettingsBody()),
            ),
          ],
        ),
      ],
    );

class _SettingsBody extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final mode = ref.watch(themeModeChoiceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(t.theme, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(value: ThemeMode.system, label: Text(t.themeSystem)),
            ButtonSegment(value: ThemeMode.light, label: Text(t.themeLight)),
            ButtonSegment(value: ThemeMode.dark, label: Text(t.themeDark)),
          ],
          selected: {mode},
          onSelectionChanged: (s) =>
              ref.read(themeModeChoiceProvider.notifier).set(s.first),
        ),
        const SizedBox(height: 24),
        Text(t.language, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        SegmentedButton<AppLocale>(
          // Language names stay in their own language.
          segments: const [
            ButtonSegment(value: AppLocale.es, label: Text('Español')),
            ButtonSegment(value: AppLocale.en, label: Text('English')),
          ],
          selected: {LocaleSettings.currentLocale},
          onSelectionChanged: (s) => unawaited(_setLanguage(ref, s.first)),
        ),
      ],
    );
  }

  Future<void> _setLanguage(WidgetRef ref, AppLocale locale) async {
    // English is a deferred library: it must finish loading before it applies.
    await LocaleSettings.setLocale(locale);
    try {
      await ref
          .read(settingsRepositoryProvider)
          .writeLanguage(locale.languageCode);
    } on Object {
      // Deliberately ignored: a failed write must not break the app.
    }
  }
}
