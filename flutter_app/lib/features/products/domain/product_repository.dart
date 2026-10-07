import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/core/page.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/product_category.dart';
import 'package:fpdart/fpdart.dart';

/// Source of [Product]s.
abstract interface class ProductRepository {
  Future<Either<Errors, Page<Product>>> list({
    int limit = 20,
    int skip = 0,
    CancelSignal? cancel,
  });

  Future<Either<Errors, Page<Product>>> search(
    String query, {
    int limit = 20,
    int skip = 0,
    CancelSignal? cancel,
  });

  /// Products of the category [slug]; a [limit] of 0 returns all of them.
  Future<Either<Errors, Page<Product>>> byCategory(
    String slug, {
    int limit = 20,
    int skip = 0,
    CancelSignal? cancel,
  });

  Future<Either<Errors, List<ProductCategory>>> categories({
    CancelSignal? cancel,
  });

  /// A missing [id] fails with `NotFoundException`.
  Future<Either<Errors, Product>> getById(int id, {CancelSignal? cancel});
}
