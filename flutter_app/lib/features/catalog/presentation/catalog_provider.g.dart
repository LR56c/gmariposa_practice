// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// First page of the Catalog (AD-6); a failure ends as `AsyncError(Errors)`.

@ProviderFor(Catalog)
final catalogProvider = CatalogProvider._();

/// First page of the Catalog (AD-6); a failure ends as `AsyncError(Errors)`.
final class CatalogProvider
    extends $AsyncNotifierProvider<Catalog, CatalogState> {
  /// First page of the Catalog (AD-6); a failure ends as `AsyncError(Errors)`.
  CatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogHash();

  @$internal
  @override
  Catalog create() => Catalog();
}

String _$catalogHash() => r'fdf0278927e417a4a534258843d245869e22104a';

/// First page of the Catalog (AD-6); a failure ends as `AsyncError(Errors)`.

abstract class _$Catalog extends $AsyncNotifier<CatalogState> {
  FutureOr<CatalogState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CatalogState>, CatalogState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CatalogState>, CatalogState>,
              AsyncValue<CatalogState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
