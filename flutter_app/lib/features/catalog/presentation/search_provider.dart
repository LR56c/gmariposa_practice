import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stream_transform/stream_transform.dart';

part 'search_provider.g.dart';

/// Quiet time before a non-empty Search term triggers a query (NFR5).
const searchDebounce = Duration(milliseconds: 400);

/// Raw text of the search field; sync, no network (AD-5).
@Riverpod(keepAlive: true)
class SearchTerm extends _$SearchTerm {
  @override
  String build() => '';

  // ignore: use_setters_to_change_properties, a Notifier has no setter API.
  void set(String value) => state = value;
}

/// Trimmed [searchTermProvider], debounced; empty terms pass at once (AD-6).
@Riverpod(keepAlive: true)
Stream<String> debouncedTerm(Ref ref) {
  final controller = StreamController<String>();
  ref
    ..onDispose(controller.close)
    ..listen(searchTermProvider, (_, next) => controller.add(next.trim()));
  return controller.stream
      .switchMap(
        (term) => term.isEmpty
            ? Stream.value(term)
            : Future<String>.delayed(searchDebounce, () => term).asStream(),
      )
      .startWith('')
      .distinct();
}
