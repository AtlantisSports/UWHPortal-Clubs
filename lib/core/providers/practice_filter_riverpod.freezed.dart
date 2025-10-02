// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'practice_filter_riverpod.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PracticeFilterState {

 Set<String> get selectedLevels; Set<String> get selectedLocations;
/// Create a copy of PracticeFilterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PracticeFilterStateCopyWith<PracticeFilterState> get copyWith => _$PracticeFilterStateCopyWithImpl<PracticeFilterState>(this as PracticeFilterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PracticeFilterState&&const DeepCollectionEquality().equals(other.selectedLevels, selectedLevels)&&const DeepCollectionEquality().equals(other.selectedLocations, selectedLocations));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(selectedLevels),const DeepCollectionEquality().hash(selectedLocations));

@override
String toString() {
  return 'PracticeFilterState(selectedLevels: $selectedLevels, selectedLocations: $selectedLocations)';
}


}

/// @nodoc
abstract mixin class $PracticeFilterStateCopyWith<$Res>  {
  factory $PracticeFilterStateCopyWith(PracticeFilterState value, $Res Function(PracticeFilterState) _then) = _$PracticeFilterStateCopyWithImpl;
@useResult
$Res call({
 Set<String> selectedLevels, Set<String> selectedLocations
});




}
/// @nodoc
class _$PracticeFilterStateCopyWithImpl<$Res>
    implements $PracticeFilterStateCopyWith<$Res> {
  _$PracticeFilterStateCopyWithImpl(this._self, this._then);

  final PracticeFilterState _self;
  final $Res Function(PracticeFilterState) _then;

/// Create a copy of PracticeFilterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedLevels = null,Object? selectedLocations = null,}) {
  return _then(_self.copyWith(
selectedLevels: null == selectedLevels ? _self.selectedLevels : selectedLevels // ignore: cast_nullable_to_non_nullable
as Set<String>,selectedLocations: null == selectedLocations ? _self.selectedLocations : selectedLocations // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PracticeFilterState].
extension PracticeFilterStatePatterns on PracticeFilterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PracticeFilterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PracticeFilterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PracticeFilterState value)  $default,){
final _that = this;
switch (_that) {
case _PracticeFilterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PracticeFilterState value)?  $default,){
final _that = this;
switch (_that) {
case _PracticeFilterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<String> selectedLevels,  Set<String> selectedLocations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PracticeFilterState() when $default != null:
return $default(_that.selectedLevels,_that.selectedLocations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<String> selectedLevels,  Set<String> selectedLocations)  $default,) {final _that = this;
switch (_that) {
case _PracticeFilterState():
return $default(_that.selectedLevels,_that.selectedLocations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<String> selectedLevels,  Set<String> selectedLocations)?  $default,) {final _that = this;
switch (_that) {
case _PracticeFilterState() when $default != null:
return $default(_that.selectedLevels,_that.selectedLocations);case _:
  return null;

}
}

}

/// @nodoc


class _PracticeFilterState implements PracticeFilterState {
  const _PracticeFilterState({final  Set<String> selectedLevels = const {}, final  Set<String> selectedLocations = const {}}): _selectedLevels = selectedLevels,_selectedLocations = selectedLocations;
  

 final  Set<String> _selectedLevels;
@override@JsonKey() Set<String> get selectedLevels {
  if (_selectedLevels is EqualUnmodifiableSetView) return _selectedLevels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedLevels);
}

 final  Set<String> _selectedLocations;
@override@JsonKey() Set<String> get selectedLocations {
  if (_selectedLocations is EqualUnmodifiableSetView) return _selectedLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedLocations);
}


/// Create a copy of PracticeFilterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PracticeFilterStateCopyWith<_PracticeFilterState> get copyWith => __$PracticeFilterStateCopyWithImpl<_PracticeFilterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PracticeFilterState&&const DeepCollectionEquality().equals(other._selectedLevels, _selectedLevels)&&const DeepCollectionEquality().equals(other._selectedLocations, _selectedLocations));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selectedLevels),const DeepCollectionEquality().hash(_selectedLocations));

@override
String toString() {
  return 'PracticeFilterState(selectedLevels: $selectedLevels, selectedLocations: $selectedLocations)';
}


}

/// @nodoc
abstract mixin class _$PracticeFilterStateCopyWith<$Res> implements $PracticeFilterStateCopyWith<$Res> {
  factory _$PracticeFilterStateCopyWith(_PracticeFilterState value, $Res Function(_PracticeFilterState) _then) = __$PracticeFilterStateCopyWithImpl;
@override @useResult
$Res call({
 Set<String> selectedLevels, Set<String> selectedLocations
});




}
/// @nodoc
class __$PracticeFilterStateCopyWithImpl<$Res>
    implements _$PracticeFilterStateCopyWith<$Res> {
  __$PracticeFilterStateCopyWithImpl(this._self, this._then);

  final _PracticeFilterState _self;
  final $Res Function(_PracticeFilterState) _then;

/// Create a copy of PracticeFilterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedLevels = null,Object? selectedLocations = null,}) {
  return _then(_PracticeFilterState(
selectedLevels: null == selectedLevels ? _self._selectedLevels : selectedLevels // ignore: cast_nullable_to_non_nullable
as Set<String>,selectedLocations: null == selectedLocations ? _self._selectedLocations : selectedLocations // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
