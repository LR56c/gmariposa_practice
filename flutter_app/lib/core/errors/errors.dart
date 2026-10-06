import 'package:flutter_app/core/errors/base_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Container of the failures of one operation.
///
/// An empty list means the operation was cancelled, not that it failed.
class Errors implements Exception {
  /// Creates a container with [exceptions].
  const new(this.exceptions);

  /// The failures, in the order they happened.
  final List<BaseException> exceptions;

  /// Whether the operation was cancelled rather than failed.
  bool get isCancelled => exceptions.isEmpty;

  @override
  String toString() => 'Errors($exceptions)';
}

/// `fpdart` has no unwrap-or-throw; used by async providers' `build()`.
extension GetOrThrow<T> on Either<Errors, T> {
  /// Returns the right value or throws the [Errors].
  T getOrThrow() => fold((errors) => throw errors, (value) => value);
}
