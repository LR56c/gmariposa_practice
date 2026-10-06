import 'package:flutter/material.dart';

/// Root widget of the application.
class App extends StatelessWidget {
  /// Creates the root widget.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Catalog',
      home: Scaffold(body: Center(child: Text('Catalog'))),
    );
  }
}
