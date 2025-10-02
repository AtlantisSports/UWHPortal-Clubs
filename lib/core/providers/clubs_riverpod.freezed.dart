// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clubs_riverpod.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClubsState {

 List<Club> get clubs; bool get isLoading; String? get error;
/// Create a copy of ClubsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubsStateCopyWith<ClubsState> get copyWith => _$ClubsStateCopyWithImpl<ClubsState>(this as ClubsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubsState&&const DeepCollectionEquality().equals(other.clubs, clubs)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(clubs),isLoading,error);

@override
String toString() {
  return 'ClubsState(clubs: $clubs, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class $ClubsStateCopyWith<$Res>  {
  factory $ClubsStateCopyWith(ClubsState value, $Res Function(ClubsState) _then) = _$ClubsStateCopyWithImpl;
@useResult
$Res call({
 List<Club> clubs, bool isLoading, String? error
});




}
/// @nodoc
class _$ClubsStateCopyWithImpl<$Res>
    implements $ClubsStateCopyWith<$Res> {
  _$ClubsStateCopyWithImpl(this._self, this._then);

  final ClubsState _self;
  final $Res Function(ClubsState) _then;

/// Create a copy of ClubsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clubs = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
clubs: null == clubs ? _self.clubs : clubs // ignore: cast_nullable_to_non_nullable
as List<Club>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubsState].
extension ClubsStatePatterns on ClubsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubsState value)  $default,){
final _that = this;
switch (_that) {
case _ClubsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubsState value)?  $default,){
final _that = this;
switch (_that) {
case _ClubsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Club> clubs,  bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubsState() when $default != null:
return $default(_that.clubs,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Club> clubs,  bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _ClubsState():
return $default(_that.clubs,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Club> clubs,  bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _ClubsState() when $default != null:
return $default(_that.clubs,_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ClubsState implements ClubsState {
  const _ClubsState({final  List<Club> clubs = const [], this.isLoading = false, this.error}): _clubs = clubs;
  

 final  List<Club> _clubs;
@override@JsonKey() List<Club> get clubs {
  if (_clubs is EqualUnmodifiableListView) return _clubs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clubs);
}

@override@JsonKey() final  bool isLoading;
@override final  String? error;

/// Create a copy of ClubsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubsStateCopyWith<_ClubsState> get copyWith => __$ClubsStateCopyWithImpl<_ClubsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubsState&&const DeepCollectionEquality().equals(other._clubs, _clubs)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_clubs),isLoading,error);

@override
String toString() {
  return 'ClubsState(clubs: $clubs, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ClubsStateCopyWith<$Res> implements $ClubsStateCopyWith<$Res> {
  factory _$ClubsStateCopyWith(_ClubsState value, $Res Function(_ClubsState) _then) = __$ClubsStateCopyWithImpl;
@override @useResult
$Res call({
 List<Club> clubs, bool isLoading, String? error
});




}
/// @nodoc
class __$ClubsStateCopyWithImpl<$Res>
    implements _$ClubsStateCopyWith<$Res> {
  __$ClubsStateCopyWithImpl(this._self, this._then);

  final _ClubsState _self;
  final $Res Function(_ClubsState) _then;

/// Create a copy of ClubsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clubs = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_ClubsState(
clubs: null == clubs ? _self._clubs : clubs // ignore: cast_nullable_to_non_nullable
as List<Club>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
