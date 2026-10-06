import 'dart:async';

/// Pure-Dart cancellation handle, so `presentation` never imports `dio`.
class CancelSignal {
  final _completer = Completer<void>();

  /// Cancels the operation; calling it twice is harmless.
  void cancel() {
    if (!_completer.isCompleted) _completer.complete();
  }

  /// Whether [cancel] was called.
  bool get isCancelled => _completer.isCompleted;

  /// Completes when [cancel] is called.
  Future<void> get whenCancelled => _completer.future;
}
