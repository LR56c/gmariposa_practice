/// Base of every typed failure that can reach the UI.
sealed class BaseException implements Exception {
  const new(this.message, this.code);

  final String message;

  final String code;
}

/// Timeout or no connection.
final class NetworkException extends BaseException {
  const new([String message = 'Network unavailable'])
    : super(message, 'network');
}

/// The server answered with a non-success status.
final class ServerException extends BaseException {
  const new(this.status) : super('Server responded with $status', 'server');

  final int? status;
}

/// The response body did not match the expected shape.
final class ParseException extends BaseException {
  const new([String message = 'Invalid response format'])
    : super(message, 'parse');
}
