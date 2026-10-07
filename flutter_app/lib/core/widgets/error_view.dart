import 'package:flutter/material.dart';
import 'package:flutter_app/core/errors/error_message.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/theme/app_theme.dart';

class ErrorView extends StatelessWidget {
  const new({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorMessage(error, t),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              style: tonalButtonStyle(context),
              onPressed: onRetry,
              child: Text(t.retry),
            ),
          ],
        ),
      ),
    );
  }
}
