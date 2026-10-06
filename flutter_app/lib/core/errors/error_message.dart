import 'package:flutter_app/core/errors/errors.dart';

/// User-facing text for [error] (`EXPERIENCE.md`): widgets never build it.
String errorMessage(Object error) {
  final code = error is Errors && error.exceptions.isNotEmpty
      ? error.exceptions.first.code
      : null;
  return switch (code) {
    'network' => 'No se pudo conectar. Revisa tu conexión.',
    'parse' => 'No se pudo leer la respuesta. Inténtalo de nuevo.',
    _ => 'Algo salió mal. Inténtalo de nuevo.',
  };
}
