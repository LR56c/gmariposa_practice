import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // English is a deferred library: the sync API throws until it is loaded.
  test('the English locale loads asynchronously', () async {
    addTearDown(() => LocaleSettings.setLocaleSync(AppLocale.es));

    await LocaleSettings.setLocale(AppLocale.en);

    expect(AppLocale.en.translations.retry, 'Retry');
  });
}
