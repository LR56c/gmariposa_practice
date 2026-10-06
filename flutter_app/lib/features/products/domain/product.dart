// Freezed factories can't use the `new` constructor syntax.
// ignore_for_file: unnecessary_type_name_in_constructor

import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// A catalog product.
@freezed
abstract class Product with _$Product {
  /// Creates a product.
  const factory Product({
    required int id,
    required String title,
    required double price,
    required double rating,
    @JsonKey(name: 'thumbnail') required String imageUrl,
  }) = _Product;

  /// Parses a DummyJSON product.
  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
