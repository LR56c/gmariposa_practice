import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // No automatic retry: "Reintentar" is the only retry (AD-5).
  runApp(ProviderScope(retry: (_, _) => null, child: const App()));
}
