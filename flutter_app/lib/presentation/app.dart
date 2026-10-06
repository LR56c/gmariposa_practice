import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/presentation/router.dart';

/// Root widget of the application.
class App extends StatelessWidget {
  /// Creates the root widget.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mini Catálogo',
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
