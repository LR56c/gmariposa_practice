import 'package:flutter_app/features/catalog/presentation/providers/search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _wait(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  test('debounces typing, trims, and passes an empty term at once', () async {
    final container = ProviderContainer(retry: (_, _) => null);
    addTearDown(container.dispose);
    final emitted = <String>[];
    container.listen(
      debouncedTermProvider,
      (_, next) => emitted.add(next.value ?? ''),
    );
    final term = container.read(searchTermProvider.notifier);

    for (final text in ['s', 'sh', ' sho ']) {
      term.set(text);
      await _wait(50);
    }
    expect(emitted.where((e) => e.isNotEmpty), isEmpty);

    await _wait(searchDebounce.inMilliseconds);
    expect(emitted.where((e) => e.isNotEmpty), ['sho']);

    term.set('  ');
    await _wait(10);
    expect(emitted.last, '');
  });
}
