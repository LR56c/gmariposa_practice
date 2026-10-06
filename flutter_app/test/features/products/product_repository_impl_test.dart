import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/errors/base_exception.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/features/products/data/product_repository_impl.dart';
import 'package:flutter_app/features/products/domain/page.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

/// Answers every request with [handler]'s result; no network.
class _FakeAdapter implements HttpClientAdapter {
  const new(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final response = handler(options);
    if (cancelFuture == null) return response;
    // Mimics dio's real adapters: a cancelled request throws DioException.
    return Future.any([
      response,
      cancelFuture.then(
        (_) => throw DioException.requestCancelled(
          requestOptions: options,
          reason: null,
        ),
      ),
    ]);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, {int status = 200}) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

ProductRepositoryImpl _repo(
  Future<ResponseBody> Function(RequestOptions) handler,
) => ProductRepositoryImpl(Dio()..httpClientAdapter = _FakeAdapter(handler));

Map<String, Object> _product({Object price = 9.99}) => {
  'id': 1,
  'title': 'Essence Mascara',
  'price': price,
  'rating': 4.94,
  'thumbnail': 'https://cdn.dummyjson.com/1.webp',
  'description': 'ignored',
};

Errors _left(Either<Errors, Page<Product>> result) =>
    result.match((e) => e, (_) => throw StateError('expected Left'));

void main() {
  test('list parses id, title, price, rating and image without loss', () async {
    final repo = _repo(
      (_) async => _json({
        'products': [_product()],
        'total': 194,
      }),
    );

    final page = (await repo.list()).getOrThrow();

    expect(page.total, 194);
    expect(page.items.single.id, 1);
    expect(page.items.single.title, 'Essence Mascara');
    expect(page.items.single.price, 9.99);
    expect(page.items.single.rating, 4.94);
    expect(page.items.single.imageUrl, 'https://cdn.dummyjson.com/1.webp');
  });

  test('search sends q, limit and skip', () async {
    late RequestOptions seen;
    final repo = _repo((o) async {
      seen = o;
      return _json({'products': <Object>[], 'total': 0});
    });

    await repo.search('phone', limit: 5, skip: 10);

    expect(seen.path, '/products/search');
    expect(seen.queryParameters, {'q': 'phone', 'limit': 5, 'skip': 10});
  });

  test('wrongly typed field becomes ParseException', () async {
    final repo = _repo(
      (_) async => _json({
        'products': [_product(price: 'cheap')],
        'total': 1,
      }),
    );

    final errors = _left(await repo.list());

    expect(errors.exceptions.single, isA<ParseException>());
  });

  test('missing required field becomes ParseException', () async {
    final broken = _product()..remove('title');
    final repo = _repo(
      (_) async => _json({
        'products': [broken],
        'total': 1,
      }),
    );

    final errors = _left(await repo.list());

    expect(errors.exceptions.single, isA<ParseException>());
  });

  test('non-success status becomes ServerException(status)', () async {
    final repo = _repo((_) async => _json({'message': 'boom'}, status: 503));

    final errors = _left(await repo.list());

    final failure = errors.exceptions.single;
    expect(failure, isA<ServerException>());
    expect((failure as ServerException).status, 503);
  });

  test('timeout becomes NetworkException', () async {
    final repo = _repo(
      (o) async => throw DioException.connectionTimeout(
        timeout: const Duration(seconds: 10),
        requestOptions: o,
      ),
    );

    final errors = _left(await repo.list());

    expect(errors.exceptions.single, isA<NetworkException>());
  });

  test('cancelled request is not reported as an error', () async {
    final never = Completer<ResponseBody>();
    final repo = _repo((_) => never.future);
    final signal = CancelSignal();

    final future = repo.list(cancel: signal);
    signal.cancel();

    final errors = _left(await future);
    expect(errors.isCancelled, isTrue);
  });
}
