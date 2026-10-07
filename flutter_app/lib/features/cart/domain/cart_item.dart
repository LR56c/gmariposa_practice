// Freezed factories can't use the `new` constructor syntax.
// ignore_for_file: unnecessary_type_name_in_constructor
// ignore_for_file: invalid_annotation_target

import 'package:flutter_app/features/products/domain/product.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

/// A [product] in the Cart with its [quantity] (always >= 1).
@freezed
abstract class CartItem with _$CartItem {
  @JsonSerializable(explicitToJson: true)
  const factory CartItem({required Product product, required int quantity}) =
      _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}
