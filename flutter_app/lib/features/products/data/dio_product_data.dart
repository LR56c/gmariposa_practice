import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/errors/base_exception.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/core/page.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_app/features/products/domain/product_repository.dart';
import 'package:fpdart/fpdart.dart';

/// The only place that catches [DioException] (AD-3).
class DioProductData implements ProductRepository {
  const new(this._dio);

  final Dio _dio;

  @override
  Future<Either<Errors, Page<Product>>> list({
    int limit = 20,
    int skip = 0,
    CancelSignal? cancel,
  }) =>
      _get('/products', cancel, _toPage, query: {'limit': limit, 'skip': skip});

  @override
  Future<Either<Errors, Page<Product>>> search(
    String query, {
    int limit = 20,
    int skip = 0,
    CancelSignal? cancel,
  }) => _get(
    '/products/search',
    cancel,
    _toPage,
    query: {'q': query, 'limit': limit, 'skip': skip},
  );

  @override
  Future<Either<Errors, Product>> getById(int id, {CancelSignal? cancel}) =>
      _get('/products/$id', cancel, _toProduct);

  Future<Either<Errors, T>> _get<T>(
    String path,
    CancelSignal? cancel,
    T Function(Object? data) parse, {
    Map<String, Object>? query,
  }) async {
    final token = CancelToken();
    if (cancel != null) {
      unawaited(cancel.whenCancelled.then((_) => token.cancel()));
    }
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: query,
        cancelToken: token,
      );
      try {
        return Right(parse(response.data));
      } on Object {
        return const Left(Errors([ParseException()]));
      }
    } on DioException catch (e) {
      return Left(_toErrors(e));
    }
  }

  Product _toProduct(Object? data) => data is Map<String, dynamic>
      ? Product.fromJson(data)
      : throw const ParseException();

  Page<Product> _toPage(Object? data) {
    if (data is! Map<String, dynamic>) throw const ParseException();
    final products = data['products'];
    final total = data['total'];
    if (products is! List<Object?> || total is! int) {
      throw const ParseException();
    }
    return Page(
      items: [
        for (final p in products)
          if (p is Map<String, dynamic>)
            Product.fromJson(p)
          else
            throw const ParseException(),
      ],
      total: total,
    );
  }

  Errors _toErrors(DioException e) => switch (e.type) {
    DioExceptionType.cancel => const Errors([]),
    DioExceptionType.badResponse when e.response?.statusCode == 404 =>
      const Errors([NotFoundException()]),
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
