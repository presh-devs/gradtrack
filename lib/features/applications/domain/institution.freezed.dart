// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'institution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Institution {

 String get id; String get name; String? get country; String? get defaultTz;
/// Create a copy of Institution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InstitutionCopyWith<Institution> get copyWith => _$InstitutionCopyWithImpl<Institution>(this as Institution, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Institution;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Institution&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.country, _this.country) || other.country == _this.country)&&(identical(other.defaultTz, _this.defaultTz) || other.defaultTz == _this.defaultTz));
}


@override
int get hashCode {
  final _this = this as Institution;
  return Object.hash(runtimeType,_this.id,_this.name,_this.country,_this.defaultTz);
}

@override
String toString() {
  final _this = this as Institution;
  return 'Institution(id: ${_this.id}, name: ${_this.name}, country: ${_this.country}, defaultTz: ${_this.defaultTz})';
}


}

/// @nodoc
abstract mixin class $InstitutionCopyWith<$Res>  {
  factory $InstitutionCopyWith(Institution value, $Res Function(Institution) _then) = _$InstitutionCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? country, String? defaultTz
});




}
/// @nodoc
class _$InstitutionCopyWithImpl<$Res>
    implements $InstitutionCopyWith<$Res> {
  _$InstitutionCopyWithImpl(this._self, this._then);

  final Institution _self;
  final $Res Function(Institution) _then;

/// Create a copy of Institution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? country = freezed,Object? defaultTz = freezed,}) {
  return _then(Institution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,defaultTz: freezed == defaultTz ? _self.defaultTz : defaultTz // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Institution].
extension InstitutionPatterns on Institution {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Institution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Institution() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Institution value)  $default,){
final _that = this;
switch (_that) {
case _Institution():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Institution value)?  $default,){
final _that = this;
switch (_that) {
case _Institution() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? country,  String? defaultTz)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Institution() when $default != null:
return $default(_that.id,_that.name,_that.country,_that.defaultTz);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? country,  String? defaultTz)  $default,) {final _that = this;
switch (_that) {
case _Institution():
return $default(_that.id,_that.name,_that.country,_that.defaultTz);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? country,  String? defaultTz)?  $default,) {final _that = this;
switch (_that) {
case _Institution() when $default != null:
return $default(_that.id,_that.name,_that.country,_that.defaultTz);case _:
  return null;

}
}

}

/// @nodoc


class _Institution implements Institution {
  const _Institution({required this.id, required this.name, this.country, this.defaultTz});
  

@override final  String id;
@override final  String name;
@override final  String? country;
@override final  String? defaultTz;

/// Create a copy of Institution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InstitutionCopyWith<_Institution> get copyWith => __$InstitutionCopyWithImpl<_Institution>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Institution&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.country, country) || other.country == country)&&(identical(other.defaultTz, defaultTz) || other.defaultTz == defaultTz));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,country,defaultTz);
}

@override
String toString() {
    return 'Institution(id: $id, name: $name, country: $country, defaultTz: $defaultTz)';
}


}

/// @nodoc
abstract mixin class _$InstitutionCopyWith<$Res> implements $InstitutionCopyWith<$Res> {
  factory _$InstitutionCopyWith(_Institution value, $Res Function(_Institution) _then) = __$InstitutionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? country, String? defaultTz
});




}
/// @nodoc
class __$InstitutionCopyWithImpl<$Res>
    implements _$InstitutionCopyWith<$Res> {
  __$InstitutionCopyWithImpl(this._self, this._then);

  final _Institution _self;
  final $Res Function(_Institution) _then;

/// Create a copy of Institution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? country = freezed,Object? defaultTz = freezed,}) {
  return _then(_Institution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,defaultTz: freezed == defaultTz ? _self.defaultTz : defaultTz // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
