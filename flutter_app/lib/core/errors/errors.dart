import 'package:flutter_app/core/errors/base_exception.dart';
import 'package:fpdart/fpdart.dart';

class Errors implements Exception {
  const new(this.exceptions);

  final List<BaseException> exceptions;

  bool get isCancelled => exceptions.isEmpty;

  @override
  String toString() => 'Errors($exceptions)';
}

extension GetOrThrow<T> on Either<Errors, T> {
  T getOrThrow() => fold((errors) => throw errors, (value) => value);
}
