// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One Product by [id], loaded on its own (never from the Catalog).
///
/// A failure ends as `AsyncError(Errors)`.

@ProviderFor(productDetail)
final productDetailProvider = ProductDetailFamily._();

/// One Product by [id], loaded on its own (never from the Catalog).
///
/// A failure ends as `AsyncError(Errors)`.

final class ProductDetailProvider
    extends $FunctionalProvider<AsyncValue<Product>, Product, FutureOr<Product>>
    with $FutureModifier<Product>, $FutureProvider<Product> {
  /// One Product by [id], loaded on its own (never from the Catalog).
  ///
  /// A failure ends as `AsyncError(Errors)`.
  ProductDetailProvider._({
    required ProductDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'productDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productDetailHash();

  @override
  String toString() {
    return r'productDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Product> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Product> create(Ref ref) {
    final argument = this.argument as int;
    return productDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productDetailHash() => r'22d4eb392ca61818dd376ae04cd529fee201e243';

/// One Product by [id], loaded on its own (never from the Catalog).
///
/// A failure ends as `AsyncError(Errors)`.

final class ProductDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Product>, int> {
  ProductDetailFamily._()
    : super(
        retry: null,
        name: r'productDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One Product by [id], loaded on its own (never from the Catalog).
  ///
  /// A failure ends as `AsyncError(Errors)`.

  ProductDetailProvider call(int id) =>
      ProductDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'productDetailProvider';
}
