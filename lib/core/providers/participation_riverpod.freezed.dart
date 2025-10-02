// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'participation_riverpod.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParticipationState {

 Map<String, ParticipationStatus> get participationStatusMap; Map<String, bool> get loadingStates; String? get error; Map<String, ParticipationStatus> get lastCommittedTarget; Map<String, int> get mockBaseYesOverrides;
/// Create a copy of ParticipationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParticipationStateCopyWith<ParticipationState> get copyWith => _$ParticipationStateCopyWithImpl<ParticipationState>(this as ParticipationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParticipationState&&const DeepCollectionEquality().equals(other.participationStatusMap, participationStatusMap)&&const DeepCollectionEquality().equals(other.loadingStates, loadingStates)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.lastCommittedTarget, lastCommittedTarget)&&const DeepCollectionEquality().equals(other.mockBaseYesOverrides, mockBaseYesOverrides));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(participationStatusMap),const DeepCollectionEquality().hash(loadingStates),error,const DeepCollectionEquality().hash(lastCommittedTarget),const DeepCollectionEquality().hash(mockBaseYesOverrides));

@override
String toString() {
  return 'ParticipationState(participationStatusMap: $participationStatusMap, loadingStates: $loadingStates, error: $error, lastCommittedTarget: $lastCommittedTarget, mockBaseYesOverrides: $mockBaseYesOverrides)';
}


}

/// @nodoc
abstract mixin class $ParticipationStateCopyWith<$Res>  {
  factory $ParticipationStateCopyWith(ParticipationState value, $Res Function(ParticipationState) _then) = _$ParticipationStateCopyWithImpl;
@useResult
$Res call({
 Map<String, ParticipationStatus> participationStatusMap, Map<String, bool> loadingStates, String? error, Map<String, ParticipationStatus> lastCommittedTarget, Map<String, int> mockBaseYesOverrides
});




}
/// @nodoc
class _$ParticipationStateCopyWithImpl<$Res>
    implements $ParticipationStateCopyWith<$Res> {
  _$ParticipationStateCopyWithImpl(this._self, this._then);

  final ParticipationState _self;
  final $Res Function(ParticipationState) _then;

/// Create a copy of ParticipationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? participationStatusMap = null,Object? loadingStates = null,Object? error = freezed,Object? lastCommittedTarget = null,Object? mockBaseYesOverrides = null,}) {
  return _then(_self.copyWith(
participationStatusMap: null == participationStatusMap ? _self.participationStatusMap : participationStatusMap // ignore: cast_nullable_to_non_nullable
as Map<String, ParticipationStatus>,loadingStates: null == loadingStates ? _self.loadingStates : loadingStates // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,lastCommittedTarget: null == lastCommittedTarget ? _self.lastCommittedTarget : lastCommittedTarget // ignore: cast_nullable_to_non_nullable
as Map<String, ParticipationStatus>,mockBaseYesOverrides: null == mockBaseYesOverrides ? _self.mockBaseYesOverrides : mockBaseYesOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [ParticipationState].
extension ParticipationStatePatterns on ParticipationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParticipationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParticipationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParticipationState value)  $default,){
final _that = this;
switch (_that) {
case _ParticipationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParticipationState value)?  $default,){
final _that = this;
switch (_that) {
case _ParticipationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, ParticipationStatus> participationStatusMap,  Map<String, bool> loadingStates,  String? error,  Map<String, ParticipationStatus> lastCommittedTarget,  Map<String, int> mockBaseYesOverrides)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParticipationState() when $default != null:
return $default(_that.participationStatusMap,_that.loadingStates,_that.error,_that.lastCommittedTarget,_that.mockBaseYesOverrides);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, ParticipationStatus> participationStatusMap,  Map<String, bool> loadingStates,  String? error,  Map<String, ParticipationStatus> lastCommittedTarget,  Map<String, int> mockBaseYesOverrides)  $default,) {final _that = this;
switch (_that) {
case _ParticipationState():
return $default(_that.participationStatusMap,_that.loadingStates,_that.error,_that.lastCommittedTarget,_that.mockBaseYesOverrides);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, ParticipationStatus> participationStatusMap,  Map<String, bool> loadingStates,  String? error,  Map<String, ParticipationStatus> lastCommittedTarget,  Map<String, int> mockBaseYesOverrides)?  $default,) {final _that = this;
switch (_that) {
case _ParticipationState() when $default != null:
return $default(_that.participationStatusMap,_that.loadingStates,_that.error,_that.lastCommittedTarget,_that.mockBaseYesOverrides);case _:
  return null;

}
}

}

/// @nodoc


class _ParticipationState implements ParticipationState {
  const _ParticipationState({final  Map<String, ParticipationStatus> participationStatusMap = const {}, final  Map<String, bool> loadingStates = const {}, this.error, final  Map<String, ParticipationStatus> lastCommittedTarget = const {}, final  Map<String, int> mockBaseYesOverrides = const {}}): _participationStatusMap = participationStatusMap,_loadingStates = loadingStates,_lastCommittedTarget = lastCommittedTarget,_mockBaseYesOverrides = mockBaseYesOverrides;
  

 final  Map<String, ParticipationStatus> _participationStatusMap;
@override@JsonKey() Map<String, ParticipationStatus> get participationStatusMap {
  if (_participationStatusMap is EqualUnmodifiableMapView) return _participationStatusMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_participationStatusMap);
}

 final  Map<String, bool> _loadingStates;
@override@JsonKey() Map<String, bool> get loadingStates {
  if (_loadingStates is EqualUnmodifiableMapView) return _loadingStates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_loadingStates);
}

@override final  String? error;
 final  Map<String, ParticipationStatus> _lastCommittedTarget;
@override@JsonKey() Map<String, ParticipationStatus> get lastCommittedTarget {
  if (_lastCommittedTarget is EqualUnmodifiableMapView) return _lastCommittedTarget;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_lastCommittedTarget);
}

 final  Map<String, int> _mockBaseYesOverrides;
@override@JsonKey() Map<String, int> get mockBaseYesOverrides {
  if (_mockBaseYesOverrides is EqualUnmodifiableMapView) return _mockBaseYesOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_mockBaseYesOverrides);
}


/// Create a copy of ParticipationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParticipationStateCopyWith<_ParticipationState> get copyWith => __$ParticipationStateCopyWithImpl<_ParticipationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParticipationState&&const DeepCollectionEquality().equals(other._participationStatusMap, _participationStatusMap)&&const DeepCollectionEquality().equals(other._loadingStates, _loadingStates)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._lastCommittedTarget, _lastCommittedTarget)&&const DeepCollectionEquality().equals(other._mockBaseYesOverrides, _mockBaseYesOverrides));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_participationStatusMap),const DeepCollectionEquality().hash(_loadingStates),error,const DeepCollectionEquality().hash(_lastCommittedTarget),const DeepCollectionEquality().hash(_mockBaseYesOverrides));

@override
String toString() {
  return 'ParticipationState(participationStatusMap: $participationStatusMap, loadingStates: $loadingStates, error: $error, lastCommittedTarget: $lastCommittedTarget, mockBaseYesOverrides: $mockBaseYesOverrides)';
}


}

/// @nodoc
abstract mixin class _$ParticipationStateCopyWith<$Res> implements $ParticipationStateCopyWith<$Res> {
  factory _$ParticipationStateCopyWith(_ParticipationState value, $Res Function(_ParticipationState) _then) = __$ParticipationStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, ParticipationStatus> participationStatusMap, Map<String, bool> loadingStates, String? error, Map<String, ParticipationStatus> lastCommittedTarget, Map<String, int> mockBaseYesOverrides
});




}
/// @nodoc
class __$ParticipationStateCopyWithImpl<$Res>
    implements _$ParticipationStateCopyWith<$Res> {
  __$ParticipationStateCopyWithImpl(this._self, this._then);

  final _ParticipationState _self;
  final $Res Function(_ParticipationState) _then;

/// Create a copy of ParticipationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? participationStatusMap = null,Object? loadingStates = null,Object? error = freezed,Object? lastCommittedTarget = null,Object? mockBaseYesOverrides = null,}) {
  return _then(_ParticipationState(
participationStatusMap: null == participationStatusMap ? _self._participationStatusMap : participationStatusMap // ignore: cast_nullable_to_non_nullable
as Map<String, ParticipationStatus>,loadingStates: null == loadingStates ? _self._loadingStates : loadingStates // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,lastCommittedTarget: null == lastCommittedTarget ? _self._lastCommittedTarget : lastCommittedTarget // ignore: cast_nullable_to_non_nullable
as Map<String, ParticipationStatus>,mockBaseYesOverrides: null == mockBaseYesOverrides ? _self._mockBaseYesOverrides : mockBaseYesOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
