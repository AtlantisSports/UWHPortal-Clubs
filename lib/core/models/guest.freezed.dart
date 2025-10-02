// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Guest {

 String get id; String get name; bool get waiverSigned;
/// Create a copy of Guest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuestCopyWith<Guest> get copyWith => _$GuestCopyWithImpl<Guest>(this as Guest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Guest&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.waiverSigned, waiverSigned) || other.waiverSigned == waiverSigned));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,waiverSigned);

@override
String toString() {
  return 'Guest(id: $id, name: $name, waiverSigned: $waiverSigned)';
}


}

/// @nodoc
abstract mixin class $GuestCopyWith<$Res>  {
  factory $GuestCopyWith(Guest value, $Res Function(Guest) _then) = _$GuestCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool waiverSigned
});




}
/// @nodoc
class _$GuestCopyWithImpl<$Res>
    implements $GuestCopyWith<$Res> {
  _$GuestCopyWithImpl(this._self, this._then);

  final Guest _self;
  final $Res Function(Guest) _then;

/// Create a copy of Guest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? waiverSigned = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,waiverSigned: null == waiverSigned ? _self.waiverSigned : waiverSigned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Guest].
extension GuestPatterns on Guest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NewPlayerGuest value)?  newPlayer,TResult Function( VisitorGuest value)?  visitor,TResult Function( ClubMemberGuest value)?  clubMember,TResult Function( DependentGuest value)?  dependent,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NewPlayerGuest() when newPlayer != null:
return newPlayer(_that);case VisitorGuest() when visitor != null:
return visitor(_that);case ClubMemberGuest() when clubMember != null:
return clubMember(_that);case DependentGuest() when dependent != null:
return dependent(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NewPlayerGuest value)  newPlayer,required TResult Function( VisitorGuest value)  visitor,required TResult Function( ClubMemberGuest value)  clubMember,required TResult Function( DependentGuest value)  dependent,}){
final _that = this;
switch (_that) {
case NewPlayerGuest():
return newPlayer(_that);case VisitorGuest():
return visitor(_that);case ClubMemberGuest():
return clubMember(_that);case DependentGuest():
return dependent(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NewPlayerGuest value)?  newPlayer,TResult? Function( VisitorGuest value)?  visitor,TResult? Function( ClubMemberGuest value)?  clubMember,TResult? Function( DependentGuest value)?  dependent,}){
final _that = this;
switch (_that) {
case NewPlayerGuest() when newPlayer != null:
return newPlayer(_that);case VisitorGuest() when visitor != null:
return visitor(_that);case ClubMemberGuest() when clubMember != null:
return clubMember(_that);case DependentGuest() when dependent != null:
return dependent(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String name,  bool waiverSigned)?  newPlayer,TResult Function( String id,  String name,  String? homeClub,  bool waiverSigned)?  visitor,TResult Function( String id,  String name,  String memberId,  bool hasPermission,  bool waiverSigned)?  clubMember,TResult Function( String id,  String name,  bool waiverSigned)?  dependent,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NewPlayerGuest() when newPlayer != null:
return newPlayer(_that.id,_that.name,_that.waiverSigned);case VisitorGuest() when visitor != null:
return visitor(_that.id,_that.name,_that.homeClub,_that.waiverSigned);case ClubMemberGuest() when clubMember != null:
return clubMember(_that.id,_that.name,_that.memberId,_that.hasPermission,_that.waiverSigned);case DependentGuest() when dependent != null:
return dependent(_that.id,_that.name,_that.waiverSigned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String name,  bool waiverSigned)  newPlayer,required TResult Function( String id,  String name,  String? homeClub,  bool waiverSigned)  visitor,required TResult Function( String id,  String name,  String memberId,  bool hasPermission,  bool waiverSigned)  clubMember,required TResult Function( String id,  String name,  bool waiverSigned)  dependent,}) {final _that = this;
switch (_that) {
case NewPlayerGuest():
return newPlayer(_that.id,_that.name,_that.waiverSigned);case VisitorGuest():
return visitor(_that.id,_that.name,_that.homeClub,_that.waiverSigned);case ClubMemberGuest():
return clubMember(_that.id,_that.name,_that.memberId,_that.hasPermission,_that.waiverSigned);case DependentGuest():
return dependent(_that.id,_that.name,_that.waiverSigned);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String name,  bool waiverSigned)?  newPlayer,TResult? Function( String id,  String name,  String? homeClub,  bool waiverSigned)?  visitor,TResult? Function( String id,  String name,  String memberId,  bool hasPermission,  bool waiverSigned)?  clubMember,TResult? Function( String id,  String name,  bool waiverSigned)?  dependent,}) {final _that = this;
switch (_that) {
case NewPlayerGuest() when newPlayer != null:
return newPlayer(_that.id,_that.name,_that.waiverSigned);case VisitorGuest() when visitor != null:
return visitor(_that.id,_that.name,_that.homeClub,_that.waiverSigned);case ClubMemberGuest() when clubMember != null:
return clubMember(_that.id,_that.name,_that.memberId,_that.hasPermission,_that.waiverSigned);case DependentGuest() when dependent != null:
return dependent(_that.id,_that.name,_that.waiverSigned);case _:
  return null;

}
}

}

/// @nodoc


class NewPlayerGuest implements Guest {
  const NewPlayerGuest({required this.id, required this.name, this.waiverSigned = false});
  

@override final  String id;
@override final  String name;
@override@JsonKey() final  bool waiverSigned;

/// Create a copy of Guest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewPlayerGuestCopyWith<NewPlayerGuest> get copyWith => _$NewPlayerGuestCopyWithImpl<NewPlayerGuest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewPlayerGuest&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.waiverSigned, waiverSigned) || other.waiverSigned == waiverSigned));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,waiverSigned);

@override
String toString() {
  return 'Guest.newPlayer(id: $id, name: $name, waiverSigned: $waiverSigned)';
}


}

/// @nodoc
abstract mixin class $NewPlayerGuestCopyWith<$Res> implements $GuestCopyWith<$Res> {
  factory $NewPlayerGuestCopyWith(NewPlayerGuest value, $Res Function(NewPlayerGuest) _then) = _$NewPlayerGuestCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool waiverSigned
});




}
/// @nodoc
class _$NewPlayerGuestCopyWithImpl<$Res>
    implements $NewPlayerGuestCopyWith<$Res> {
  _$NewPlayerGuestCopyWithImpl(this._self, this._then);

  final NewPlayerGuest _self;
  final $Res Function(NewPlayerGuest) _then;

/// Create a copy of Guest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? waiverSigned = null,}) {
  return _then(NewPlayerGuest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,waiverSigned: null == waiverSigned ? _self.waiverSigned : waiverSigned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class VisitorGuest implements Guest {
  const VisitorGuest({required this.id, required this.name, this.homeClub, this.waiverSigned = false});
  

@override final  String id;
@override final  String name;
 final  String? homeClub;
@override@JsonKey() final  bool waiverSigned;

/// Create a copy of Guest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisitorGuestCopyWith<VisitorGuest> get copyWith => _$VisitorGuestCopyWithImpl<VisitorGuest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisitorGuest&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.homeClub, homeClub) || other.homeClub == homeClub)&&(identical(other.waiverSigned, waiverSigned) || other.waiverSigned == waiverSigned));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,homeClub,waiverSigned);

@override
String toString() {
  return 'Guest.visitor(id: $id, name: $name, homeClub: $homeClub, waiverSigned: $waiverSigned)';
}


}

/// @nodoc
abstract mixin class $VisitorGuestCopyWith<$Res> implements $GuestCopyWith<$Res> {
  factory $VisitorGuestCopyWith(VisitorGuest value, $Res Function(VisitorGuest) _then) = _$VisitorGuestCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? homeClub, bool waiverSigned
});




}
/// @nodoc
class _$VisitorGuestCopyWithImpl<$Res>
    implements $VisitorGuestCopyWith<$Res> {
  _$VisitorGuestCopyWithImpl(this._self, this._then);

  final VisitorGuest _self;
  final $Res Function(VisitorGuest) _then;

/// Create a copy of Guest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? homeClub = freezed,Object? waiverSigned = null,}) {
  return _then(VisitorGuest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,homeClub: freezed == homeClub ? _self.homeClub : homeClub // ignore: cast_nullable_to_non_nullable
as String?,waiverSigned: null == waiverSigned ? _self.waiverSigned : waiverSigned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ClubMemberGuest implements Guest {
  const ClubMemberGuest({required this.id, required this.name, required this.memberId, this.hasPermission = true, this.waiverSigned = true});
  

@override final  String id;
@override final  String name;
 final  String memberId;
@JsonKey() final  bool hasPermission;
@override@JsonKey() final  bool waiverSigned;

/// Create a copy of Guest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubMemberGuestCopyWith<ClubMemberGuest> get copyWith => _$ClubMemberGuestCopyWithImpl<ClubMemberGuest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubMemberGuest&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.hasPermission, hasPermission) || other.hasPermission == hasPermission)&&(identical(other.waiverSigned, waiverSigned) || other.waiverSigned == waiverSigned));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,memberId,hasPermission,waiverSigned);

@override
String toString() {
  return 'Guest.clubMember(id: $id, name: $name, memberId: $memberId, hasPermission: $hasPermission, waiverSigned: $waiverSigned)';
}


}

/// @nodoc
abstract mixin class $ClubMemberGuestCopyWith<$Res> implements $GuestCopyWith<$Res> {
  factory $ClubMemberGuestCopyWith(ClubMemberGuest value, $Res Function(ClubMemberGuest) _then) = _$ClubMemberGuestCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String memberId, bool hasPermission, bool waiverSigned
});




}
/// @nodoc
class _$ClubMemberGuestCopyWithImpl<$Res>
    implements $ClubMemberGuestCopyWith<$Res> {
  _$ClubMemberGuestCopyWithImpl(this._self, this._then);

  final ClubMemberGuest _self;
  final $Res Function(ClubMemberGuest) _then;

/// Create a copy of Guest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? memberId = null,Object? hasPermission = null,Object? waiverSigned = null,}) {
  return _then(ClubMemberGuest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,hasPermission: null == hasPermission ? _self.hasPermission : hasPermission // ignore: cast_nullable_to_non_nullable
as bool,waiverSigned: null == waiverSigned ? _self.waiverSigned : waiverSigned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class DependentGuest implements Guest {
  const DependentGuest({required this.id, required this.name, this.waiverSigned = false});
  

@override final  String id;
@override final  String name;
@override@JsonKey() final  bool waiverSigned;

/// Create a copy of Guest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DependentGuestCopyWith<DependentGuest> get copyWith => _$DependentGuestCopyWithImpl<DependentGuest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DependentGuest&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.waiverSigned, waiverSigned) || other.waiverSigned == waiverSigned));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,waiverSigned);

@override
String toString() {
  return 'Guest.dependent(id: $id, name: $name, waiverSigned: $waiverSigned)';
}


}

/// @nodoc
abstract mixin class $DependentGuestCopyWith<$Res> implements $GuestCopyWith<$Res> {
  factory $DependentGuestCopyWith(DependentGuest value, $Res Function(DependentGuest) _then) = _$DependentGuestCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool waiverSigned
});




}
/// @nodoc
class _$DependentGuestCopyWithImpl<$Res>
    implements $DependentGuestCopyWith<$Res> {
  _$DependentGuestCopyWithImpl(this._self, this._then);

  final DependentGuest _self;
  final $Res Function(DependentGuest) _then;

/// Create a copy of Guest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? waiverSigned = null,}) {
  return _then(DependentGuest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,waiverSigned: null == waiverSigned ? _self.waiverSigned : waiverSigned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$PracticeGuestList {

 List<Guest> get guests;
/// Create a copy of PracticeGuestList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PracticeGuestListCopyWith<PracticeGuestList> get copyWith => _$PracticeGuestListCopyWithImpl<PracticeGuestList>(this as PracticeGuestList, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PracticeGuestList&&const DeepCollectionEquality().equals(other.guests, guests));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(guests));

@override
String toString() {
  return 'PracticeGuestList(guests: $guests)';
}


}

/// @nodoc
abstract mixin class $PracticeGuestListCopyWith<$Res>  {
  factory $PracticeGuestListCopyWith(PracticeGuestList value, $Res Function(PracticeGuestList) _then) = _$PracticeGuestListCopyWithImpl;
@useResult
$Res call({
 List<Guest> guests
});




}
/// @nodoc
class _$PracticeGuestListCopyWithImpl<$Res>
    implements $PracticeGuestListCopyWith<$Res> {
  _$PracticeGuestListCopyWithImpl(this._self, this._then);

  final PracticeGuestList _self;
  final $Res Function(PracticeGuestList) _then;

/// Create a copy of PracticeGuestList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? guests = null,}) {
  return _then(_self.copyWith(
guests: null == guests ? _self.guests : guests // ignore: cast_nullable_to_non_nullable
as List<Guest>,
  ));
}

}


/// Adds pattern-matching-related methods to [PracticeGuestList].
extension PracticeGuestListPatterns on PracticeGuestList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PracticeGuestList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PracticeGuestList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PracticeGuestList value)  $default,){
final _that = this;
switch (_that) {
case _PracticeGuestList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PracticeGuestList value)?  $default,){
final _that = this;
switch (_that) {
case _PracticeGuestList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Guest> guests)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PracticeGuestList() when $default != null:
return $default(_that.guests);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Guest> guests)  $default,) {final _that = this;
switch (_that) {
case _PracticeGuestList():
return $default(_that.guests);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Guest> guests)?  $default,) {final _that = this;
switch (_that) {
case _PracticeGuestList() when $default != null:
return $default(_that.guests);case _:
  return null;

}
}

}

/// @nodoc


class _PracticeGuestList extends PracticeGuestList {
  const _PracticeGuestList({final  List<Guest> guests = const <Guest>[]}): _guests = guests,super._();
  

 final  List<Guest> _guests;
@override@JsonKey() List<Guest> get guests {
  if (_guests is EqualUnmodifiableListView) return _guests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_guests);
}


/// Create a copy of PracticeGuestList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PracticeGuestListCopyWith<_PracticeGuestList> get copyWith => __$PracticeGuestListCopyWithImpl<_PracticeGuestList>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PracticeGuestList&&const DeepCollectionEquality().equals(other._guests, _guests));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_guests));

@override
String toString() {
  return 'PracticeGuestList(guests: $guests)';
}


}

/// @nodoc
abstract mixin class _$PracticeGuestListCopyWith<$Res> implements $PracticeGuestListCopyWith<$Res> {
  factory _$PracticeGuestListCopyWith(_PracticeGuestList value, $Res Function(_PracticeGuestList) _then) = __$PracticeGuestListCopyWithImpl;
@override @useResult
$Res call({
 List<Guest> guests
});




}
/// @nodoc
class __$PracticeGuestListCopyWithImpl<$Res>
    implements _$PracticeGuestListCopyWith<$Res> {
  __$PracticeGuestListCopyWithImpl(this._self, this._then);

  final _PracticeGuestList _self;
  final $Res Function(_PracticeGuestList) _then;

/// Create a copy of PracticeGuestList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? guests = null,}) {
  return _then(_PracticeGuestList(
guests: null == guests ? _self._guests : guests // ignore: cast_nullable_to_non_nullable
as List<Guest>,
  ));
}


}

// dart format on
