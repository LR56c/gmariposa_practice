import 'dart:async';

class CancelSignal {
  final _completer = Completer<void>();

  void cancel() {
    if (!_completer.isCompleted) _completer.complete();
  }

  bool get isCancelled => _completer.isCompleted;

  Future<void> get whenCancelled => _completer.future;
}
