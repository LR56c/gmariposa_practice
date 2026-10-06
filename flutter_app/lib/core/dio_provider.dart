import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

const dummyJsonBaseUrl = 'https://dummyjson.com';
const connectTimeout = Duration(seconds: 10);
const receiveTimeout = Duration(seconds: 10);

@Riverpod(keepAlive: true)
Dio dio(Ref ref) => Dio(
  BaseOptions(
    baseUrl: dummyJsonBaseUrl,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
  ),
);
