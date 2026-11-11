// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Profile {

 String? get displayName; String? get email;/// IANA zone used for the digest's "today" and send hour.
 String get timezone; bool get digestEnabled;/// Local hour (0–23) the digest is sent.
 int get digestHour;/// Send even when nothing needs attention ("All clear today").
 bool get digestSendWhenEmpty;/// True until the user saves settings once. The zone of a never-edited
/// profile is the sign-up default (UTC), not a choice.
 bool get neverEdited;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Profile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.digestEnabled, _this.digestEnabled) || other.digestEnabled == _this.digestEnabled)&&(identical(other.digestHour, _this.digestHour) || other.digestHour == _this.digestHour)&&(identical(other.digestSendWhenEmpty, _this.digestSendWhenEmpty) || other.digestSendWhenEmpty == _this.digestSendWhenEmpty)&&(identical(other.neverEdited, _this.neverEdited) || other.neverEdited == _this.neverEdited));
}


@override
int get hashCode {
  final _this = this as Profile;
  return Object.hash(runtimeType,_this.displayName,_this.email,_this.timezone,_this.digestEnabled,_this.digestHour,_this.digestSendWhenEmpty,_this.neverEdited);
}

@override
String toString() {
  final _this = this as Profile;
  return 'Profile(displayName: ${_this.displayName}, email: ${_this.email}, timezone: ${_this.timezone}, digestEnabled: ${_this.digestEnabled}, digestHour: ${_this.digestHour}, digestSendWhenEmpty: ${_this.digestSendWhenEmpty}, neverEdited: ${_this.neverEdited})';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String? displayName, String? email, String timezone, bool digestEnabled, int digestHour, bool digestSendWhenEmpty, bool neverEdited
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = freezed,Object? email = freezed,Object? timezone = null,Object? digestEnabled = null,Object? digestHour = null,Object? digestSendWhenEmpty = null,Object? neverEdited = null,}) {
  return _then(Profile(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,digestEnabled: null == digestEnabled ? _self.digestEnabled : digestEnabled // ignore: cast_nullable_to_non_nullable
as bool,digestHour: null == digestHour ? _self.digestHour : digestHour // ignore: cast_nullable_to_non_nullable
as int,digestSendWhenEmpty: null == digestSendWhenEmpty ? _self.digestSendWhenEmpty : digestSendWhenEmpty // ignore: cast_nullable_to_non_nullable
as bool,neverEdited: null == neverEdited ? _self.neverEdited : neverEdited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? displayName,  String? email,  String timezone,  bool digestEnabled,  int digestHour,  bool digestSendWhenEmpty,  bool neverEdited)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.displayName,_that.email,_that.timezone,_that.digestEnabled,_that.digestHour,_that.digestSendWhenEmpty,_that.neverEdited);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? displayName,  String? email,  String timezone,  bool digestEnabled,  int digestHour,  bool digestSendWhenEmpty,  bool neverEdited)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.displayName,_that.email,_that.timezone,_that.digestEnabled,_that.digestHour,_that.digestSendWhenEmpty,_that.neverEdited);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? displayName,  String? email,  String timezone,  bool digestEnabled,  int digestHour,  bool digestSendWhenEmpty,  bool neverEdited)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.displayName,_that.email,_that.timezone,_that.digestEnabled,_that.digestHour,_that.digestSendWhenEmpty,_that.neverEdited);case _:
  return null;

}
}

}

/// @nodoc


class _Profile implements Profile {
  const _Profile({this.displayName, this.email, this.timezone = 'UTC', this.digestEnabled = true, this.digestHour = 7, this.digestSendWhenEmpty = false, this.neverEdited = false});
  

@override final  String? displayName;
@override final  String? email;
/// IANA zone used for the digest's "today" and send hour.
@override@JsonKey() final  String timezone;
@override@JsonKey() final  bool digestEnabled;
/// Local hour (0–23) the digest is sent.
@override@JsonKey() final  int digestHour;
/// Send even when nothing needs attention ("All clear today").
@override@JsonKey() final  bool digestSendWhenEmpty;
/// True until the user saves settings once. The zone of a never-edited
/// profile is the sign-up default (UTC), not a choice.
@override@JsonKey() final  bool neverEdited;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.digestEnabled, digestEnabled) || other.digestEnabled == digestEnabled)&&(identical(other.digestHour, digestHour) || other.digestHour == digestHour)&&(identical(other.digestSendWhenEmpty, digestSendWhenEmpty) || other.digestSendWhenEmpty == digestSendWhenEmpty)&&(identical(other.neverEdited, neverEdited) || other.neverEdited == neverEdited));
}


@override
int get hashCode {
    return Object.hash(runtimeType,displayName,email,timezone,digestEnabled,digestHour,digestSendWhenEmpty,neverEdited);
}

@override
String toString() {
    return 'Profile(displayName: $displayName, email: $email, timezone: $timezone, digestEnabled: $digestEnabled, digestHour: $digestHour, digestSendWhenEmpty: $digestSendWhenEmpty, neverEdited: $neverEdited)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String? displayName, String? email, String timezone, bool digestEnabled, int digestHour, bool digestSendWhenEmpty, bool neverEdited
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = freezed,Object? email = freezed,Object? timezone = null,Object? digestEnabled = null,Object? digestHour = null,Object? digestSendWhenEmpty = null,Object? neverEdited = null,}) {
  return _then(_Profile(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,digestEnabled: null == digestEnabled ? _self.digestEnabled : digestEnabled // ignore: cast_nullable_to_non_nullable
as bool,digestHour: null == digestHour ? _self.digestHour : digestHour // ignore: cast_nullable_to_non_nullable
as int,digestSendWhenEmpty: null == digestSendWhenEmpty ? _self.digestSendWhenEmpty : digestSendWhenEmpty // ignore: cast_nullable_to_non_nullable
as bool,neverEdited: null == neverEdited ? _self.neverEdited : neverEdited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
