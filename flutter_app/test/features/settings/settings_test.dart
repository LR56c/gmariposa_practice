import 'package:flutter/material.dart';
import 'package:flutter_app/features/settings/data/shared_preference_settings_data.dart';
import 'package:flutter_app/features/settings/presentation/providers/theme_mode_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/prefs.dart';

void main() {
  test('reads the system theme and no language by default', () async {
    SharedPreferences.setMockInitialValues({});
    final data = SharedPreferenceSettingsData(
      await SharedPreferences.getInstance(),
    );

    expect(data.readThemeMode(), ThemeMode.system);
    expect(data.readLanguage(), isNull);
  });

  test('an unknown saved theme falls back to the system theme', () async {
    SharedPreferences.setMockInitialValues({
      SharedPreferenceSettingsData.themeKey: 'neon',
    });
    final data = SharedPreferenceSettingsData(
      await SharedPreferences.getInstance(),
    );

    expect(data.readThemeMode(), ThemeMode.system);
  });

  test('the chosen theme is applied and saved', () async {
    final container = ProviderContainer(overrides: [await prefsOverride()]);
    addTearDown(container.dispose);

    container.read(themeModeChoiceProvider.notifier).set(ThemeMode.dark);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(themeModeChoiceProvider), ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(SharedPreferenceSettingsData.themeKey), 'dark');
  });
}
