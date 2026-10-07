// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cartStorage)
final cartStorageProvider = CartStorageProvider._();

final class CartStorageProvider
    extends $FunctionalProvider<CartStorage, CartStorage, CartStorage>
    with $Provider<CartStorage> {
  CartStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartStorageHash();

  @$internal
  @override
  $ProviderElement<CartStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CartStorage create(Ref ref) {
    return cartStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CartStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CartStorage>(value),
    );
  }
}

String _$cartStorageHash() => r'876ee7a25bb785f9c7705dea1fe837071be69220';
