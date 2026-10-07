import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_app/core/cancel_signal.dart';
import 'package:flutter_app/core/errors/base_exception.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/features/products/data/dio_product_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

const _product = <String, Object?>{
  'id': 1,
  'title': 'Essence Mascara',
  'price': 10,
  'rating': 4.5,
  'thumbnail': 'https://img/1.png',
};

typedef _Respond = Future<ResponseBody> Function(
  RequestOptions,
  Future<void>? cancelled,
);

/// Answers every request with [respond]; records the last one.
class _FakeAdapter implements HttpClientAdapter {
  new(this.respond);

  final _Respond respond;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    last = options;
    return respond(options, cancelFuture);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object? body, [int status = 200]) => ResponseBody.fromString(
  body is String ? body : jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

(DioProductData, _FakeAdapter) _repo(_Respond respond) {
  final adapter = _FakeAdapter(respond);
  final dio = Dio(BaseOptions(baseUrl: 'https://test'))
    ..httpClientAdapter = adapter;
  return (DioProductData(dio), adapter);
}

Errors _left<T>(Either<Errors, T> result) =>
    result.fold((e) => e, (_) => fail('expected Left'));

void main() {
  group('success', () {
    test('list sends limit and skip and parses the page', () async {
      final (repo, adapter) = _repo(
        (_, _) async => _json({
          'products': [_product],
          'total': 40,
        }),
      );

      final page = (await repo.list(skip: 20)).getOrThrow();

      expect(adapter.last!.path, '/products');
      expect(adapter.last!.queryParameters, {'limit': 20, 'skip': 20});
      expect(page.total, 40);
      expect(page.items.single.title, 'Essence Mascara');
    });

    test('search, byCategory and getById hit their endpoints', () async {
      final (repo, adapter) = _repo(
        (o, _) async => _json(
          o.path == '/products/7'
              ? _product
              : {
                  'products': [_product],
                  'total': 1,
                },
        ),
      );

      await repo.search('mas');
      expect(adapter.last!.path, '/products/search');
      expect(adapter.last!.queryParameters['q'], 'mas');

      await repo.byCategory('beauty');
      expect(adapter.last!.path, '/products/category/beauty');

      await repo.getById(7);
      expect(adapter.last!.path, '/products/7');
    });
  });

  group('error mapping', () {
    Future<Errors> failWith(_Respond respond) async {
      final (repo, _) = _repo(respond);
      return _left(await repo.list());
    }

    test('404 is NotFoundException', () async {
      final errors = await failWith((_, _) async => _json({}, 404));

      expect(errors.exceptions.single, isA<NotFoundException>());
      expect(errors.isNotFound, isTrue);
    });

    test('other bad status is ServerException with its status', () async {
      final errors = await failWith((_, _) async => _json({}, 500));

      expect((errors.exceptions.single as ServerException).status, 500);
    });

    test('timeouts and connection errors are NetworkException', () async {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        final errors = await failWith(
          (o, _) async => throw DioException(requestOptions: o, type: type),
        );

        expect(
          errors.exceptions.single,
          isA<NetworkException>(),
          reason: '$type',
        );
      }
    });

    test('a body that is not JSON is ParseException', () async {
      final errors = await failWith((_, _) async => _json('<html>oops</html>'));

      expect(errors.exceptions.single, isA<ParseException>());
    });

    test('a wrong shape is ParseException', () async {
      final errors = await failWith(
        (_, _) async => _json({'products': <Object?>[], 'total': 'many'}),
      );

      expect(errors.exceptions.single, isA<ParseException>());
    });
  });

  test('cancelling mid-request is CancelledException', () async {
    final (repo, _) = _repo((o, cancelled) async {
      await cancelled;
      throw DioException.requestCancelled(requestOptions: o, reason: 'x');
    });
    final signal = CancelSignal();

    final future = repo.list(cancel: signal);
    signal
      ..cancel()
      ..cancel(); // idempotent
    final errors = _left(await future);

    expect(signal.isCancelled, isTrue);
    expect(errors.isCancelled, isTrue);
    expect(errors.exceptions.single, isA<CancelledException>());
  });
}
