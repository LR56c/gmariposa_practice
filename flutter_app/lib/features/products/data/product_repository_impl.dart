import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/dio_provider.dart';
import 'package:flutter_app/core/errors/base_exception.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/features/products/domain/page.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/product_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_repository_impl.g.dart';

/// The only place that catches [DioException] (AD-3).
class ProductRepositoryImpl implements ProductRepository {
  /// Creates a repository over [_dio].
  const new(this._dio);

  final Dio _dio;

  @override
  Future<Either<Errors, Page<Product>>> list({
    int limit = 20,
    int skip = 0,
    CancelSignal? cancel,
  }) => _fetch('/products', {'limit': limit, 'skip': skip}, cancel);

  @override
  Future<Either<Errors, Page<Product>>> search(
    String query, {
    int limit = 20,
    int skip = 0,
    CancelSignal? cancel,
  }) => _fetch('/products/search', {
    'q': query,
    'limit': limit,
    'skip': skip,
  }, cancel);

  Future<Either<Errors, Page<Product>>> _fetch(
    String path,
    Map<String, Object> query,
    CancelSignal? cancel,
  ) async {
    final token = CancelToken();
    // ponytail: listener never removed; a signal lives for one request.
    if (cancel != null) {
      unawaited(cancel.whenCancelled.then((_) => token.cancel()));
    }
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: query,
        cancelToken: token,
      );
      return _parse(response.data);
    } on DioException catch (e) {
      return Left(_toErrors(e));
    }
  }

  Either<Errors, Page<Product>> _parse(Object? data) {
    try {
      if (data is! Map<String, dynamic>) throw const ParseException();
      final products = data['products'];
      final total = data['total'];
      if (products is! List<Object?> || total is! int) {
        throw const ParseException();
      }
      return Right(
        Page(
          items: [
            for (final p in products)
              if (p is Map<String, dynamic>)
                Product.fromJson(p)
              else
                throw const ParseException(),
          ],
          total: total,
        ),
      );
    } on Object {
      // json_serializable throws TypeError on missing or wrongly typed fields.
      return const Left(Errors([ParseException()]));
    }
  }

  Errors _toErrors(DioException e) => switch (e.type) {
    DioExceptionType.cancel => const Errors([]),
    DioExceptionType.badResponse => Errors([
      ServerException(e.response?.statusCode),
    ]),
    DioExceptionType.connectionTimeout ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate ||
    DioExceptionType.unknown => const Errors([NetworkException()]),
  };
}

/// The only `data` import allowed from `presentation` (AD-2).
@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) =>
    ProductRepositoryImpl(ref.watch(dioProvider));
