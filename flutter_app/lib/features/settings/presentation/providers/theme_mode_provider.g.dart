// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The chosen [ThemeMode]; saving is best effort, the state stays the truth.

@ProviderFor(ThemeModeChoice)
final themeModeChoiceProvider = ThemeModeChoiceProvider._();

/// The chosen [ThemeMode]; saving is best effort, the state stays the truth.
final class ThemeModeChoiceProvider
    extends $NotifierProvider<ThemeModeChoice, ThemeMode> {
  /// The chosen [ThemeMode]; saving is best effort, the state stays the truth.
  ThemeModeChoiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeChoiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeChoiceHash();

  @$internal
  @override
  ThemeModeChoice create() => ThemeModeChoice();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeChoiceHash() => r'05187b33c2c67346f4e0ecbad27cf28e6a5db350';

/// The chosen [ThemeMode]; saving is best effort, the state stays the truth.

abstract class _$ThemeModeChoice extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
