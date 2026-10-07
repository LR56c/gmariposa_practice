import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/features/settings/presentation/widgets/settings_sheet.dart';

/// AppBar action that opens the settings modal (theme and language).
class SettingsIconButton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.t.settings,
      icon: const Icon(Icons.settings_outlined),
      onPressed: () => unawaited(showSettingsSheet(context)),
    );
  }
}
