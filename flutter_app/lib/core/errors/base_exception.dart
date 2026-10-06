/// Base of every typed failure that can reach the UI.
sealed class BaseException implements Exception {
  /// Creates an exception with a human-readable [message] and a stable [code].
  const new(this.message, this.code);

  /// Human-readable description, for logs and for deriving UI copy.
  final String message;

  /// Stable identifier of the failure kind.
  final String code;
}

/// Timeout or no connection.
final class NetworkException extends BaseException {
  /// Creates a network failure.
  const new([String message = 'Network unavailable'])
    : super(message, 'network');
}

/// The server answered with a non-success status.
final class ServerException extends BaseException {
  /// Creates a server failure for [status].
  const new(this.status) : super('Server responded with $status', 'server');

  /// HTTP status code.
  final int? status;
}

/// The response body did not match the expected shape.
final class ParseException extends BaseException {
  /// Creates a parse failure.
  const new([String message = 'Invalid response format'])
    : super(message, 'parse');
}
