// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppError {

 String get message; String get details;
/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppErrorCopyWith<AppError> get copyWith => _$AppErrorCopyWithImpl<AppError>(this as AppError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppError&&(identical(other.message, message) || other.message == message)&&(identical(other.details, details) || other.details == details));
}


@override
int get hashCode => Object.hash(runtimeType,message,details);

@override
String toString() {
  return 'AppError(message: $message, details: $details)';
}


}

/// @nodoc
abstract mixin class $AppErrorCopyWith<$Res>  {
  factory $AppErrorCopyWith(AppError value, $Res Function(AppError) _then) = _$AppErrorCopyWithImpl;
@useResult
$Res call({
 String message, String details
});




}
/// @nodoc
class _$AppErrorCopyWithImpl<$Res>
    implements $AppErrorCopyWith<$Res> {
  _$AppErrorCopyWithImpl(this._self, this._then);

  final AppError _self;
  final $Res Function(AppError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? details = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppError].
extension AppErrorPatterns on AppError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NetworkError value)?  network,TResult Function( AuthenticationError value)?  authentication,TResult Function( AuthorizationError value)?  authorization,TResult Function( ValidationError value)?  validation,TResult Function( NotFoundError value)?  notFound,TResult Function( ConflictError value)?  conflict,TResult Function( RateLimitError value)?  rateLimit,TResult Function( ServerError value)?  server,TResult Function( TimeoutError value)?  timeout,TResult Function( OfflineError value)?  offline,TResult Function( UnknownError value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NetworkError() when network != null:
return network(_that);case AuthenticationError() when authentication != null:
return authentication(_that);case AuthorizationError() when authorization != null:
return authorization(_that);case ValidationError() when validation != null:
return validation(_that);case NotFoundError() when notFound != null:
return notFound(_that);case ConflictError() when conflict != null:
return conflict(_that);case RateLimitError() when rateLimit != null:
return rateLimit(_that);case ServerError() when server != null:
return server(_that);case TimeoutError() when timeout != null:
return timeout(_that);case OfflineError() when offline != null:
return offline(_that);case UnknownError() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NetworkError value)  network,required TResult Function( AuthenticationError value)  authentication,required TResult Function( AuthorizationError value)  authorization,required TResult Function( ValidationError value)  validation,required TResult Function( NotFoundError value)  notFound,required TResult Function( ConflictError value)  conflict,required TResult Function( RateLimitError value)  rateLimit,required TResult Function( ServerError value)  server,required TResult Function( TimeoutError value)  timeout,required TResult Function( OfflineError value)  offline,required TResult Function( UnknownError value)  unknown,}){
final _that = this;
switch (_that) {
case NetworkError():
return network(_that);case AuthenticationError():
return authentication(_that);case AuthorizationError():
return authorization(_that);case ValidationError():
return validation(_that);case NotFoundError():
return notFound(_that);case ConflictError():
return conflict(_that);case RateLimitError():
return rateLimit(_that);case ServerError():
return server(_that);case TimeoutError():
return timeout(_that);case OfflineError():
return offline(_that);case UnknownError():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NetworkError value)?  network,TResult? Function( AuthenticationError value)?  authentication,TResult? Function( AuthorizationError value)?  authorization,TResult? Function( ValidationError value)?  validation,TResult? Function( NotFoundError value)?  notFound,TResult? Function( ConflictError value)?  conflict,TResult? Function( RateLimitError value)?  rateLimit,TResult? Function( ServerError value)?  server,TResult? Function( TimeoutError value)?  timeout,TResult? Function( OfflineError value)?  offline,TResult? Function( UnknownError value)?  unknown,}){
final _that = this;
switch (_that) {
case NetworkError() when network != null:
return network(_that);case AuthenticationError() when authentication != null:
return authentication(_that);case AuthorizationError() when authorization != null:
return authorization(_that);case ValidationError() when validation != null:
return validation(_that);case NotFoundError() when notFound != null:
return notFound(_that);case ConflictError() when conflict != null:
return conflict(_that);case RateLimitError() when rateLimit != null:
return rateLimit(_that);case ServerError() when server != null:
return server(_that);case TimeoutError() when timeout != null:
return timeout(_that);case OfflineError() when offline != null:
return offline(_that);case UnknownError() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message,  String details,  int? statusCode)?  network,TResult Function( String message,  String details)?  authentication,TResult Function( String message,  String details)?  authorization,TResult Function( String message,  String details,  Map<String, String>? fieldErrors)?  validation,TResult Function( String message,  String details)?  notFound,TResult Function( String message,  String details)?  conflict,TResult Function( String message,  String details,  Duration? retryAfter)?  rateLimit,TResult Function( String message,  String details,  int? statusCode)?  server,TResult Function( String message,  String details)?  timeout,TResult Function( String message,  String details)?  offline,TResult Function( String message,  String details,  Object? originalError)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NetworkError() when network != null:
return network(_that.message,_that.details,_that.statusCode);case AuthenticationError() when authentication != null:
return authentication(_that.message,_that.details);case AuthorizationError() when authorization != null:
return authorization(_that.message,_that.details);case ValidationError() when validation != null:
return validation(_that.message,_that.details,_that.fieldErrors);case NotFoundError() when notFound != null:
return notFound(_that.message,_that.details);case ConflictError() when conflict != null:
return conflict(_that.message,_that.details);case RateLimitError() when rateLimit != null:
return rateLimit(_that.message,_that.details,_that.retryAfter);case ServerError() when server != null:
return server(_that.message,_that.details,_that.statusCode);case TimeoutError() when timeout != null:
return timeout(_that.message,_that.details);case OfflineError() when offline != null:
return offline(_that.message,_that.details);case UnknownError() when unknown != null:
return unknown(_that.message,_that.details,_that.originalError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message,  String details,  int? statusCode)  network,required TResult Function( String message,  String details)  authentication,required TResult Function( String message,  String details)  authorization,required TResult Function( String message,  String details,  Map<String, String>? fieldErrors)  validation,required TResult Function( String message,  String details)  notFound,required TResult Function( String message,  String details)  conflict,required TResult Function( String message,  String details,  Duration? retryAfter)  rateLimit,required TResult Function( String message,  String details,  int? statusCode)  server,required TResult Function( String message,  String details)  timeout,required TResult Function( String message,  String details)  offline,required TResult Function( String message,  String details,  Object? originalError)  unknown,}) {final _that = this;
switch (_that) {
case NetworkError():
return network(_that.message,_that.details,_that.statusCode);case AuthenticationError():
return authentication(_that.message,_that.details);case AuthorizationError():
return authorization(_that.message,_that.details);case ValidationError():
return validation(_that.message,_that.details,_that.fieldErrors);case NotFoundError():
return notFound(_that.message,_that.details);case ConflictError():
return conflict(_that.message,_that.details);case RateLimitError():
return rateLimit(_that.message,_that.details,_that.retryAfter);case ServerError():
return server(_that.message,_that.details,_that.statusCode);case TimeoutError():
return timeout(_that.message,_that.details);case OfflineError():
return offline(_that.message,_that.details);case UnknownError():
return unknown(_that.message,_that.details,_that.originalError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message,  String details,  int? statusCode)?  network,TResult? Function( String message,  String details)?  authentication,TResult? Function( String message,  String details)?  authorization,TResult? Function( String message,  String details,  Map<String, String>? fieldErrors)?  validation,TResult? Function( String message,  String details)?  notFound,TResult? Function( String message,  String details)?  conflict,TResult? Function( String message,  String details,  Duration? retryAfter)?  rateLimit,TResult? Function( String message,  String details,  int? statusCode)?  server,TResult? Function( String message,  String details)?  timeout,TResult? Function( String message,  String details)?  offline,TResult? Function( String message,  String details,  Object? originalError)?  unknown,}) {final _that = this;
switch (_that) {
case NetworkError() when network != null:
return network(_that.message,_that.details,_that.statusCode);case AuthenticationError() when authentication != null:
return authentication(_that.message,_that.details);case AuthorizationError() when authorization != null:
return authorization(_that.message,_that.details);case ValidationError() when validation != null:
return validation(_that.message,_that.details,_that.fieldErrors);case NotFoundError() when notFound != null:
return notFound(_that.message,_that.details);case ConflictError() when conflict != null:
return conflict(_that.message,_that.details);case RateLimitError() when rateLimit != null:
return rateLimit(_that.message,_that.details,_that.retryAfter);case ServerError() when server != null:
return server(_that.message,_that.details,_that.statusCode);case TimeoutError() when timeout != null:
return timeout(_that.message,_that.details);case OfflineError() when offline != null:
return offline(_that.message,_that.details);case UnknownError() when unknown != null:
return unknown(_that.message,_that.details,_that.originalError);case _:
  return null;

}
}

}

/// @nodoc


class NetworkError implements AppError {
  const NetworkError({required this.message, required this.details, this.statusCode});
  

@override final  String message;
@override final  String details;
 final  int? statusCode;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkErrorCopyWith<NetworkError> get copyWith => _$NetworkErrorCopyWithImpl<NetworkError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkError&&(identical(other.message, message) || other.message == message)&&(identical(other.details, details) || other.details == details)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode));
}


@override
int get hashCode => Object.hash(runtimeType,message,details,statusCode);

@override
String toString() {
  return 'AppError.network(message: $message, details: $details, statusCode: $statusCode)';
}


}

/// @nodoc
abstract mixin class $NetworkErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $NetworkErrorCopyWith(NetworkError value, $Res Function(NetworkError) _then) = _$NetworkErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, String details, int? statusCode
});




}
/// @nodoc
class _$NetworkErrorCopyWithImpl<$Res>
    implements $NetworkErrorCopyWith<$Res> {
  _$NetworkErrorCopyWithImpl(this._self, this._then);

  final NetworkError _self;
  final $Res Function(NetworkError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? details = null,Object? statusCode = freezed,}) {
  return _then(NetworkError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class AuthenticationError implements AppError {
  const AuthenticationError({required this.message, required this.details});
  

@override final  String message;
@override final  String details;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthenticationErrorCopyWith<AuthenticationError> get copyWith => _$AuthenticationErrorCopyWithImpl<AuthenticationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationError&&(identical(other.message, message) || other.message == message)&&(identical(other.details, details) || other.details == details));
}


@override
int get hashCode => Object.hash(runtimeType,message,details);

@override
String toString() {
  return 'AppError.authentication(message: $message, details: $details)';
}


}

/// @nodoc
abstract mixin class $AuthenticationErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $AuthenticationErrorCopyWith(AuthenticationError value, $Res Function(AuthenticationError) _then) = _$AuthenticationErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, String details
});




}
/// @nodoc
class _$AuthenticationErrorCopyWithImpl<$Res>
    implements $AuthenticationErrorCopyWith<$Res> {
  _$AuthenticationErrorCopyWithImpl(this._self, this._then);

  final AuthenticationError _self;
  final $Res Function(AuthenticationError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? details = null,}) {
  return _then(AuthenticationError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthorizationError implements AppError {
  const AuthorizationError({required this.message, required this.details});
  

@override final  String message;
@override final  String details;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthorizationErrorCopyWith<AuthorizationError> get copyWith => _$AuthorizationErrorCopyWithImpl<AuthorizationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthorizationError&&(identical(other.message, message) || other.message == message)&&(identical(other.details, details) || other.details == details));
}


@override
int get hashCode => Object.hash(runtimeType,message,details);

@override
String toString() {
  return 'AppError.authorization(message: $message, details: $details)';
}


}

/// @nodoc
abstract mixin class $AuthorizationErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $AuthorizationErrorCopyWith(AuthorizationError value, $Res Function(AuthorizationError) _then) = _$AuthorizationErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, String details
});




}
/// @nodoc
class _$AuthorizationErrorCopyWithImpl<$Res>
    implements $AuthorizationErrorCopyWith<$Res> {
  _$AuthorizationErrorCopyWithImpl(this._self, this._then);

  final AuthorizationError _self;
  final $Res Function(AuthorizationError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? details = null,}) {
  return _then(AuthorizationError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ValidationError implements AppError {
  const ValidationError({required this.message, required this.details, final  Map<String, String>? fieldErrors}): _fieldErrors = fieldErrors;
  

@override final  String message;
@override final  String details;
 final  Map<String, String>? _fieldErrors;
 Map<String, String>? get fieldErrors {
  final value = _fieldErrors;
  if (value == null) return null;
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationErrorCopyWith<ValidationError> get copyWith => _$ValidationErrorCopyWithImpl<ValidationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationError&&(identical(other.message, message) || other.message == message)&&(identical(other.details, details) || other.details == details)&&const DeepCollectionEquality().equals(other._fieldErrors, _fieldErrors));
}


@override
int get hashCode => Object.hash(runtimeType,message,details,const DeepCollectionEquality().hash(_fieldErrors));

@override
String toString() {
  return 'AppError.validation(message: $message, details: $details, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class $ValidationErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $ValidationErrorCopyWith(ValidationError value, $Res Function(ValidationError) _then) = _$ValidationErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, String details, Map<String, String>? fieldErrors
});




}
/// @nodoc
class _$ValidationErrorCopyWithImpl<$Res>
    implements $ValidationErrorCopyWith<$Res> {
  _$ValidationErrorCopyWithImpl(this._self, this._then);

  final ValidationError _self;
  final $Res Function(ValidationError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? details = null,Object? fieldErrors = freezed,}) {
  return _then(ValidationError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,fieldErrors: freezed == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}

/// @nodoc


class NotFoundError implements AppError {
  const NotFoundError({required this.message, required this.details});
  

@override final  String message;
@override final  String details;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotFoundErrorCopyWith<NotFoundError> get copyWith => _$NotFoundErrorCopyWithImpl<NotFoundError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFoundError&&(identical(other.message, message) || other.message == message)&&(identical(other.details, details) || other.details == details));
}


@override
int get hashCode => Object.hash(runtimeType,message,details);

@override
String toString() {
  return 'AppError.notFound(message: $message, details: $details)';
}


}

/// @nodoc
abstract mixin class $NotFoundErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $NotFoundErrorCopyWith(NotFoundError value, $Res Function(NotFoundError) _then) = _$NotFoundErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, String details
});




}
/// @nodoc
class _$NotFoundErrorCopyWithImpl<$Res>
    implements $NotFoundErrorCopyWith<$Res> {
  _$NotFoundErrorCopyWithImpl(this._self, this._then);

  final NotFoundError _self;
  final $Res Function(NotFoundError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? details = null,}) {
  return _then(NotFoundError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ConflictError implements AppError {
  const ConflictError({required this.message, required this.details});
  

@override final  String message;
@override final  String details;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConflictErrorCopyWith<ConflictError> get copyWith => _$ConflictErrorCopyWithImpl<ConflictError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConflictError&&(identical(other.message, message) || other.message == message)&&(identical(other.details, details) || other.details == details));
}


@override
int get hashCode => Object.hash(runtimeType,message,details);

@override
String toString() {
  return 'AppError.conflict(message: $message, details: $details)';
}


}

/// @nodoc
abstract mixin class $ConflictErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $ConflictErrorCopyWith(ConflictError value, $Res Function(ConflictError) _then) = _$ConflictErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, String details
});




}
/// @nodoc
class _$ConflictErrorCopyWithImpl<$Res>
    implements $ConflictErrorCopyWith<$Res> {
  _$ConflictErrorCopyWithImpl(this._self, this._then);

  final ConflictError _self;
  final $Res Function(ConflictError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? details = null,}) {
  return _then(ConflictError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RateLimitError implements AppError {
  const RateLimitError({required this.message, required this.details, this.retryAfter});
  

@override final  String message;
@override final  String details;
 final  Duration? retryAfter;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RateLimitErrorCopyWith<RateLimitError> get copyWith => _$RateLimitErrorCopyWithImpl<RateLimitError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RateLimitError&&(identical(other.message, message) || other.message == message)&&(identical(other.details, details) || other.details == details)&&(identical(other.retryAfter, retryAfter) || other.retryAfter == retryAfter));
}


@override
int get hashCode => Object.hash(runtimeType,message,details,retryAfter);

@override
String toString() {
  return 'AppError.rateLimit(message: $message, details: $details, retryAfter: $retryAfter)';
}


}

/// @nodoc
abstract mixin class $RateLimitErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $RateLimitErrorCopyWith(RateLimitError value, $Res Function(RateLimitError) _then) = _$RateLimitErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, String details, Duration? retryAfter
});




}
/// @nodoc
class _$RateLimitErrorCopyWithImpl<$Res>
    implements $RateLimitErrorCopyWith<$Res> {
  _$RateLimitErrorCopyWithImpl(this._self, this._then);

  final RateLimitError _self;
  final $Res Function(RateLimitError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? details = null,Object? retryAfter = freezed,}) {
  return _then(RateLimitError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,retryAfter: freezed == retryAfter ? _self.retryAfter : retryAfter // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

/// @nodoc


class ServerError implements AppError {
  const ServerError({required this.message, required this.details, this.statusCode});
  

@override final  String message;
@override final  String details;
 final  int? statusCode;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerErrorCopyWith<ServerError> get copyWith => _$ServerErrorCopyWithImpl<ServerError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerError&&(identical(other.message, message) || other.message == message)&&(identical(other.details, details) || other.details == details)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode));
}


@override
int get hashCode => Object.hash(runtimeType,message,details,statusCode);

@override
String toString() {
  return 'AppError.server(message: $message, details: $details, statusCode: $statusCode)';
}


}

/// @nodoc
abstract mixin class $ServerErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $ServerErrorCopyWith(ServerError value, $Res Function(ServerError) _then) = _$ServerErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, String details, int? statusCode
});




}
/// @nodoc
class _$ServerErrorCopyWithImpl<$Res>
    implements $ServerErrorCopyWith<$Res> {
  _$ServerErrorCopyWithImpl(this._self, this._then);

  final ServerError _self;
  final $Res Function(ServerError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? details = null,Object? statusCode = freezed,}) {
  return _then(ServerError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class TimeoutError implements AppError {
  const TimeoutError({required this.message, required this.details});
  

@override final  String message;
@override final  String details;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeoutErrorCopyWith<TimeoutError> get copyWith => _$TimeoutErrorCopyWithImpl<TimeoutError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeoutError&&(identical(other.message, message) || other.message == message)&&(identical(other.details, details) || other.details == details));
}


@override
int get hashCode => Object.hash(runtimeType,message,details);

@override
String toString() {
  return 'AppError.timeout(message: $message, details: $details)';
}


}

/// @nodoc
abstract mixin class $TimeoutErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $TimeoutErrorCopyWith(TimeoutError value, $Res Function(TimeoutError) _then) = _$TimeoutErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, String details
});




}
/// @nodoc
class _$TimeoutErrorCopyWithImpl<$Res>
    implements $TimeoutErrorCopyWith<$Res> {
  _$TimeoutErrorCopyWithImpl(this._self, this._then);

  final TimeoutError _self;
  final $Res Function(TimeoutError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? details = null,}) {
  return _then(TimeoutError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class OfflineError implements AppError {
  const OfflineError({required this.message, required this.details});
  

@override final  String message;
@override final  String details;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfflineErrorCopyWith<OfflineError> get copyWith => _$OfflineErrorCopyWithImpl<OfflineError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfflineError&&(identical(other.message, message) || other.message == message)&&(identical(other.details, details) || other.details == details));
}


@override
int get hashCode => Object.hash(runtimeType,message,details);

@override
String toString() {
  return 'AppError.offline(message: $message, details: $details)';
}


}

/// @nodoc
abstract mixin class $OfflineErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $OfflineErrorCopyWith(OfflineError value, $Res Function(OfflineError) _then) = _$OfflineErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, String details
});




}
/// @nodoc
class _$OfflineErrorCopyWithImpl<$Res>
    implements $OfflineErrorCopyWith<$Res> {
  _$OfflineErrorCopyWithImpl(this._self, this._then);

  final OfflineError _self;
  final $Res Function(OfflineError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? details = null,}) {
  return _then(OfflineError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UnknownError implements AppError {
  const UnknownError({required this.message, required this.details, this.originalError});
  

@override final  String message;
@override final  String details;
 final  Object? originalError;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownErrorCopyWith<UnknownError> get copyWith => _$UnknownErrorCopyWithImpl<UnknownError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownError&&(identical(other.message, message) || other.message == message)&&(identical(other.details, details) || other.details == details)&&const DeepCollectionEquality().equals(other.originalError, originalError));
}


@override
int get hashCode => Object.hash(runtimeType,message,details,const DeepCollectionEquality().hash(originalError));

@override
String toString() {
  return 'AppError.unknown(message: $message, details: $details, originalError: $originalError)';
}


}

/// @nodoc
abstract mixin class $UnknownErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $UnknownErrorCopyWith(UnknownError value, $Res Function(UnknownError) _then) = _$UnknownErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, String details, Object? originalError
});




}
/// @nodoc
class _$UnknownErrorCopyWithImpl<$Res>
    implements $UnknownErrorCopyWith<$Res> {
  _$UnknownErrorCopyWithImpl(this._self, this._then);

  final UnknownError _self;
  final $Res Function(UnknownError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? details = null,Object? originalError = freezed,}) {
  return _then(UnknownError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,originalError: freezed == originalError ? _self.originalError : originalError ,
  ));
}


}

/// @nodoc
mixin _$Result<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Result<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Result<$T>()';
}


}

/// @nodoc
class $ResultCopyWith<T,$Res>  {
$ResultCopyWith(Result<T> _, $Res Function(Result<T>) __);
}


/// Adds pattern-matching-related methods to [Result].
extension ResultPatterns<T> on Result<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Success<T> value)?  success,TResult Function( Failure<T> value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that);case Failure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Success<T> value)  success,required TResult Function( Failure<T> value)  failure,}){
final _that = this;
switch (_that) {
case Success():
return success(_that);case Failure():
return failure(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Success<T> value)?  success,TResult? Function( Failure<T> value)?  failure,}){
final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that);case Failure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( T data)?  success,TResult Function( AppError error)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that.data);case Failure() when failure != null:
return failure(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( T data)  success,required TResult Function( AppError error)  failure,}) {final _that = this;
switch (_that) {
case Success():
return success(_that.data);case Failure():
return failure(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( T data)?  success,TResult? Function( AppError error)?  failure,}) {final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that.data);case Failure() when failure != null:
return failure(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class Success<T> implements Result<T> {
  const Success(this.data);
  

 final  T data;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuccessCopyWith<T, Success<T>> get copyWith => _$SuccessCopyWithImpl<T, Success<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Success<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'Result<$T>.success(data: $data)';
}


}

/// @nodoc
abstract mixin class $SuccessCopyWith<T,$Res> implements $ResultCopyWith<T, $Res> {
  factory $SuccessCopyWith(Success<T> value, $Res Function(Success<T>) _then) = _$SuccessCopyWithImpl;
@useResult
$Res call({
 T data
});




}
/// @nodoc
class _$SuccessCopyWithImpl<T,$Res>
    implements $SuccessCopyWith<T, $Res> {
  _$SuccessCopyWithImpl(this._self, this._then);

  final Success<T> _self;
  final $Res Function(Success<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(Success<T>(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class Failure<T> implements Result<T> {
  const Failure(this.error);
  

 final  AppError error;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailureCopyWith<T, Failure<T>> get copyWith => _$FailureCopyWithImpl<T, Failure<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure<T>&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'Result<$T>.failure(error: $error)';
}


}

/// @nodoc
abstract mixin class $FailureCopyWith<T,$Res> implements $ResultCopyWith<T, $Res> {
  factory $FailureCopyWith(Failure<T> value, $Res Function(Failure<T>) _then) = _$FailureCopyWithImpl;
@useResult
$Res call({
 AppError error
});


$AppErrorCopyWith<$Res> get error;

}
/// @nodoc
class _$FailureCopyWithImpl<T,$Res>
    implements $FailureCopyWith<T, $Res> {
  _$FailureCopyWithImpl(this._self, this._then);

  final Failure<T> _self;
  final $Res Function(Failure<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(Failure<T>(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res> get error {
  
  return $AppErrorCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on
