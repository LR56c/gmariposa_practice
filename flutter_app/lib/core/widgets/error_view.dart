import 'package:flutter/material.dart';
import 'package:flutter_app/core/errors/error_message.dart';

/// Error message derived from [error] plus a tonal "Reintentar" button.
class ErrorView extends StatelessWidget {
  /// Creates the view.
  const new({required this.error, required this.onRetry, super.key});

  /// Reloads the failed query.
  final Object error;

  /// What went wrong; the message is derived from it.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage(error), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
