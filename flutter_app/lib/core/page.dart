// Freezed factories can't use the `new` constructor syntax.
// ignore_for_file: unnecessary_type_name_in_constructor

import 'package:freezed_annotation/freezed_annotation.dart';

part 'page.freezed.dart';

/// One page of results plus the API's overall [total].
@freezed
abstract class Page<T> with _$Page<T> {
  const factory Page({required List<T> items, required int total}) = _Page<T>;
}
