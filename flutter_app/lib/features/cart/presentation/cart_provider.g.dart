// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sole owner of the Cart state; all logic lives in `cart_logic.dart` (AD-7).

@ProviderFor(Cart)
final cartProvider = CartProvider._();

/// Sole owner of the Cart state; all logic lives in `cart_logic.dart` (AD-7).
final class CartProvider extends $NotifierProvider<Cart, List<CartItem>> {
  /// Sole owner of the Cart state; all logic lives in `cart_logic.dart` (AD-7).
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

String _$cartHash() => r'af9523f95ffb6385f12bfa7aa48e7cb20414d257';

/// Sole owner of the Cart state; all logic lives in `cart_logic.dart` (AD-7).

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
