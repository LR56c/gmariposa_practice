import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Logs every provider lifecycle event, to trace state changes in DevTools.
final class LoggingProviderObserver extends ProviderObserver {
  const new();

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) =>
      _log(context, 'added: $value');

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) => _log(context, '$previousValue -> $newValue');

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) => _log(context, 'failed: $error', error: error, stackTrace: stackTrace);

  @override
  void didDisposeProvider(ProviderObserverContext context) =>
      _log(context, 'disposed');

  void _log(
    ProviderObserverContext context,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) => developer.log(
    '${context.provider.name ?? context.provider.runtimeType}: $message',
    name: 'riverpod',
    error: error,
    stackTrace: stackTrace,
  );
}
