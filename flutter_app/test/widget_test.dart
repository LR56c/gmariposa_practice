import 'package:flutter_app/presentation/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts and shows the placeholder', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Catalog'), findsOneWidget);
  });
}
