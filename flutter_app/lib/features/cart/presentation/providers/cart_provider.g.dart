// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sole owner of the Cart state: an immutable list, replaced on each change.

@ProviderFor(Cart)
final cartProvider = CartProvider._();

/// Sole owner of the Cart state: an immutable list, replaced on each change.
final class CartProvider extends $NotifierProvider<Cart, List<CartItem>> {
  /// Sole owner of the Cart state: an immutable list, replaced on each change.
  CartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartHash();

  @$internal
  @override
  Cart create() => Cart();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CartItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CartItem>>(value),
    );
  }
}

String _$cartHash() => r'ce86c6292f96258106f7d00fb89c3810aaef3e82';

/// Sole owner of the Cart state: an immutable list, replaced on each change.

abstract class _$Cart extends $Notifier<List<CartItem>> {
  List<CartItem> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<CartItem>, List<CartItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<CartItem>, List<CartItem>>,
              List<CartItem>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Sum of price × quantity, unrounded (round only when displaying).

@ProviderFor(cartTotal)
final cartTotalProvider = CartTotalProvider._();

/// Sum of price × quantity, unrounded (round only when displaying).

final class CartTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Sum of price × quantity, unrounded (round only when displaying).
  CartTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartTotalProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartTotalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return cartTotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$cartTotalHash() => r'3381930fe11c75d5be325687c8c948e73a4341c3';

/// Sum of quantities, not the number of distinct items.

@ProviderFor(cartCount)
final cartCountProvider = CartCountProvider._();

/// Sum of quantities, not the number of distinct items.

final class CartCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Sum of quantities, not the number of distinct items.
  CartCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return cartCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$cartCountHash() => r'fcac4132ad375a9b01fa3d9723a09494b8212bc5';
