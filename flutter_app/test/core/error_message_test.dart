import 'package:flutter_app/core/errors/base_exception.dart';
import 'package:flutter_app/core/errors/error_message.dart';
import 'package:flutter_app/core/errors/errors.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Translations es;
  late Translations en;

  setUpAll(() async {
    es = await AppLocale.es.build();
    en = await AppLocale.en.build();
  });

  test('maps each failure to its localized text', () {
    expect(
      errorMessage(const Errors([NetworkException()]), es),
      es.errors.network,
    );
    expect(errorMessage(const Errors([ParseException()]), en), en.errors.parse);
    expect(
      errorMessage(const Errors([ServerException(500)]), en),
      en.errors.server,
    );
  });

  test('falls back to the generic text for unknown, empty or cancelled', () {
    expect(
      errorMessage(const Errors([CancelledException()]), es),
      es.errors.generic,
    );
    expect(errorMessage(StateError('x'), es), es.errors.generic);
    expect(errorMessage(const Errors([]), en), en.errors.generic);
  });
}
