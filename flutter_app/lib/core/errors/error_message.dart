import 'package:flutter_app/core/errors/base_exception.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';

/// Localized text for [error]: widgets never build it.
String errorMessage(Object error, Translations t) {
  if (error is! Errors || error.exceptions.isEmpty) return t.errors.generic;
  return switch (error.exceptions.first) {
    NetworkException() => t.errors.network,
    ServerException() => t.errors.server,
    ParseException() => t.errors.parse,
  };
}
