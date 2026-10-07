import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

/// "Not found" message with a way back to `/`; retrying could not help.
class NotFoundView extends StatelessWidget {
  const new({super.key});

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
              t.errors.notFound,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              style: tonalButtonStyle(context),
              onPressed: () => context.go('/'),
              child: Text(t.backToCatalog),
            ),
          ],
        ),
      ),
    );
  }
}
