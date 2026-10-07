// Freezed factories can't use the `new` constructor syntax.
// ignore_for_file: unnecessary_type_name_in_constructor

import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_category.freezed.dart';

/// A product category; [slug] is what the API takes, [name] what the user sees.
@freezed
abstract class ProductCategory with _$ProductCategory {
  const factory ProductCategory({required String slug, required String name}) =
      _ProductCategory;
}
