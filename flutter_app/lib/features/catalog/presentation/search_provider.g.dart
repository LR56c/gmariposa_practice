// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Raw text of the search field; sync, no network (AD-5).

@ProviderFor(SearchTerm)
final searchTermProvider = SearchTermProvider._();

/// Raw text of the search field; sync, no network (AD-5).
final class SearchTermProvider extends $NotifierProvider<SearchTerm, String> {
  /// Raw text of the search field; sync, no network (AD-5).
  SearchTermProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchTermProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchTermHash();

  @$internal
  @override
  SearchTerm create() => SearchTerm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchTermHash() => r'e5d73c8fdaa3a77be6e069fe072af77e236c5e1d';

/// Raw text of the search field; sync, no network (AD-5).

abstract class _$SearchTerm extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Trimmed [searchTermProvider], debounced; empty terms pass at once (AD-6).

@ProviderFor(debouncedTerm)
final debouncedTermProvider = DebouncedTermProvider._();

/// Trimmed [searchTermProvider], debounced; empty terms pass at once (AD-6).

final class DebouncedTermProvider
    extends $FunctionalProvider<AsyncValue<String>, String, Stream<String>>
    with $FutureModifier<String>, $StreamProvider<String> {
  /// Trimmed [searchTermProvider], debounced; empty terms pass at once (AD-6).
  DebouncedTermProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debouncedTermProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debouncedTermHash();

  @$internal
  @override
  $StreamProviderElement<String> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String> create(Ref ref) {
    return debouncedTerm(ref);
  }
}

String _$debouncedTermHash() => r'5717cc3d87820673a51ac3dae2007a1a1ef1a15c';
