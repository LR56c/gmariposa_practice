import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

/// DummyJSON base URL.
const dummyJsonBaseUrl = 'https://dummyjson.com';

/// Connection timeout.
const connectTimeout = Duration(seconds: 10);

/// Response timeout.
const receiveTimeout = Duration(seconds: 10);

/// The single [Dio] of the app (AD-3).
@Riverpod(keepAlive: true)
Dio dio(Ref ref) => Dio(
  BaseOptions(
    baseUrl: dummyJsonBaseUrl,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
  ),
);
