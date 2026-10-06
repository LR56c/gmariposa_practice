// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CatalogState {

 List<Product> get items; int get total; AsyncValue<void> get loadMore;
/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogStateCopyWith<CatalogState> get copyWith => _$CatalogStateCopyWithImpl<CatalogState>(this as CatalogState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CatalogState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogState&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.loadMore, _this.loadMore) || other.loadMore == _this.loadMore));
}


@override
int get hashCode {
  final _this = this as CatalogState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.total,_this.loadMore);
}

@override
String toString() {
  final _this = this as CatalogState;
  return 'CatalogState(items: ${_this.items}, total: ${_this.total}, loadMore: ${_this.loadMore})';
}


}

/// @nodoc
abstract mixin class $CatalogStateCopyWith<$Res>  {
  factory $CatalogStateCopyWith(CatalogState value, $Res Function(CatalogState) _then) = _$CatalogStateCopyWithImpl;
@useResult
$Res call({
 List<Product> items, int total, AsyncValue<void> loadMore
});




}
/// @nodoc
class _$CatalogStateCopyWithImpl<$Res>
    implements $CatalogStateCopyWith<$Res> {
  _$CatalogStateCopyWithImpl(this._self, this._then);

  final CatalogState _self;
  final $Res Function(CatalogState) _then;

/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? loadMore = null,}) {
  return _then(CatalogState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Product>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,loadMore: null == loadMore ? _self.loadMore : loadMore // ignore: cast_nullable_to_non_nullable
as AsyncValue<void>,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogState].
extension CatalogStatePatterns on CatalogState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogState value)  $default,){
final _that = this;
switch (_that) {
case _CatalogState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogState value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Product> items,  int total,  AsyncValue<void> loadMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
return $default(_that.items,_that.total,_that.loadMore);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Product> items,  int total,  AsyncValue<void> loadMore)  $default,) {final _that = this;
switch (_that) {
case _CatalogState():
return $default(_that.items,_that.total,_that.loadMore);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Product> items,  int total,  AsyncValue<void> loadMore)?  $default,) {final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
return $default(_that.items,_that.total,_that.loadMore);case _:
  return null;

}
}

}

/// @nodoc


class _CatalogState implements CatalogState {
  const _CatalogState({required  List<Product> items, required this.total, this.loadMore = const AsyncData<void>(null)}): _items = items;
  

 final  List<Product> _items;
@override List<Product> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;
@override@JsonKey() final  AsyncValue<void> loadMore;

/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogStateCopyWith<_CatalogState> get copyWith => __$CatalogStateCopyWithImpl<_CatalogState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogState&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.loadMore, loadMore) || other.loadMore == loadMore));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,loadMore);
}

@override
String toString() {
    return 'CatalogState(items: $items, total: $total, loadMore: $loadMore)';
}


}

/// @nodoc
abstract mixin class _$CatalogStateCopyWith<$Res> implements $CatalogStateCopyWith<$Res> {
  factory _$CatalogStateCopyWith(_CatalogState value, $Res Function(_CatalogState) _then) = __$CatalogStateCopyWithImpl;
@override @useResult
$Res call({
 List<Product> items, int total, AsyncValue<void> loadMore
});




}
/// @nodoc
class __$CatalogStateCopyWithImpl<$Res>
    implements _$CatalogStateCopyWith<$Res> {
  __$CatalogStateCopyWithImpl(this._self, this._then);

  final _CatalogState _self;
  final $Res Function(_CatalogState) _then;

/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? loadMore = null,}) {
  return _then(_CatalogState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Product>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,loadMore: null == loadMore ? _self.loadMore : loadMore // ignore: cast_nullable_to_non_nullable
as AsyncValue<void>,
  ));
}


}

// dart format on
