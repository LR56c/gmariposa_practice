// Freezed factories can't use the `new` constructor syntax.
// ignore_for_file: unnecessary_type_name_in_constructor

import 'package:flutter_app/features/products/domain/product.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item.freezed.dart';

/// A [product] in the Cart with its [quantity] (always >= 1).
@freezed
abstract class CartItem with _$CartItem {
  const factory CartItem({required Product product, required int quantity}) =
      _CartItem;
}
