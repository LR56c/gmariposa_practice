import 'package:flutter_app/core/errors/base_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Container of the failures of one operation.
///
/// An empty list means the operation was cancelled, not that it failed.
class Errors implements Exception {
  const new(this.exceptions);

  final List<BaseException> exceptions;

  bool get isCancelled => exceptions.isEmpty;

  @override
  String toString() => 'Errors($exceptions)';
}

/// `fpdart` has no unwrap-or-throw; used by async providers' `build()`.
extension GetOrThrow<T> on Either<Errors, T> {
  T getOrThrow() => fold((errors) => throw errors, (value) => value);
}
