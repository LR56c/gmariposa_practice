sealed class BaseException implements Exception {
  const new(this.message, this.code);

  final String message;

  final String code;
}

final class NetworkException extends BaseException {
  const new([String message = 'Network unavailable'])
    : super(message, 'network');
}

final class ServerException extends BaseException {
  const new(this.status) : super('Server responded with $status', 'server');

  final int? status;
}

final class NotFoundException extends BaseException {
  const new() : super('Not found', 'notFound');
}

final class ParseException extends BaseException {
  const new([String message = 'Invalid response format'])
    : super(message, 'parse');
}
