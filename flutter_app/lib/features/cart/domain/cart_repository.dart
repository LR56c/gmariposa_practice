import 'package:flutter_app/features/cart/domain/cart_item.dart';

/// Where the Cart is saved between sessions (AD-3).
abstract interface class CartRepository {
  /// The saved Cart; a corrupt or outdated value reads as empty.
  List<CartItem> read();

  Future<void> write(List<CartItem> items);
}
