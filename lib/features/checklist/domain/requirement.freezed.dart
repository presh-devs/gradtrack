// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'requirement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Requirement {

 String get id; String get applicationId; String get title;/// `requirements.kind`, e.g. `transcript`. See [requirementKindFor].
 String get kind; RequirementStatus get status;/// Depends on someone else: registrar, test agency, embassy.
 bool get external; int get sortOrder; String? get notes;
/// Create a copy of Requirement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequirementCopyWith<Requirement> get copyWith => _$RequirementCopyWithImpl<Requirement>(this as Requirement, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Requirement;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Requirement&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.applicationId, _this.applicationId) || other.applicationId == _this.applicationId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.external, _this.external) || other.external == _this.external)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}


@override
int get hashCode {
  final _this = this as Requirement;
  return Object.hash(runtimeType,_this.id,_this.applicationId,_this.title,_this.kind,_this.status,_this.external,_this.sortOrder,_this.notes);
}

@override
String toString() {
  final _this = this as Requirement;
  return 'Requirement(id: ${_this.id}, applicationId: ${_this.applicationId}, title: ${_this.title}, kind: ${_this.kind}, status: ${_this.status}, external: ${_this.external}, sortOrder: ${_this.sortOrder}, notes: ${_this.notes})';
}


}

/// @nodoc
abstract mixin class $RequirementCopyWith<$Res>  {
  factory $RequirementCopyWith(Requirement value, $Res Function(Requirement) _then) = _$RequirementCopyWithImpl;
@useResult
$Res call({
 String id, String applicationId, String title, String kind, RequirementStatus status, bool external, int sortOrder, String? notes
});




}
/// @nodoc
class _$RequirementCopyWithImpl<$Res>
    implements $RequirementCopyWith<$Res> {
  _$RequirementCopyWithImpl(this._self, this._then);

  final Requirement _self;
  final $Res Function(Requirement) _then;

/// Create a copy of Requirement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? applicationId = null,Object? title = null,Object? kind = null,Object? status = null,Object? external = null,Object? sortOrder = null,Object? notes = freezed,}) {
  return _then(Requirement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequirementStatus,external: null == external ? _self.external : external // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Requirement].
extension RequirementPatterns on Requirement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Requirement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Requirement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Requirement value)  $default,){
final _that = this;
switch (_that) {
case _Requirement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Requirement value)?  $default,){
final _that = this;
switch (_that) {
case _Requirement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String applicationId,  String title,  String kind,  RequirementStatus status,  bool external,  int sortOrder,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Requirement() when $default != null:
return $default(_that.id,_that.applicationId,_that.title,_that.kind,_that.status,_that.external,_that.sortOrder,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String applicationId,  String title,  String kind,  RequirementStatus status,  bool external,  int sortOrder,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _Requirement():
return $default(_that.id,_that.applicationId,_that.title,_that.kind,_that.status,_that.external,_that.sortOrder,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String applicationId,  String title,  String kind,  RequirementStatus status,  bool external,  int sortOrder,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _Requirement() when $default != null:
return $default(_that.id,_that.applicationId,_that.title,_that.kind,_that.status,_that.external,_that.sortOrder,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _Requirement extends Requirement {
  const _Requirement({required this.id, required this.applicationId, required this.title, this.kind = 'other', this.status = RequirementStatus.notStarted, this.external = false, this.sortOrder = 0, this.notes}): super._();
  

@override final  String id;
@override final  String applicationId;
@override final  String title;
/// `requirements.kind`, e.g. `transcript`. See [requirementKindFor].
@override@JsonKey() final  String kind;
@override@JsonKey() final  RequirementStatus status;
/// Depends on someone else: registrar, test agency, embassy.
@override@JsonKey() final  bool external;
@override@JsonKey() final  int sortOrder;
@override final  String? notes;

/// Create a copy of Requirement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequirementCopyWith<_Requirement> get copyWith => __$RequirementCopyWithImpl<_Requirement>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Requirement&&(identical(other.id, id) || other.id == id)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.title, title) || other.title == title)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.external, external) || other.external == external)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,applicationId,title,kind,status,external,sortOrder,notes);
}

@override
String toString() {
    return 'Requirement(id: $id, applicationId: $applicationId, title: $title, kind: $kind, status: $status, external: $external, sortOrder: $sortOrder, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$RequirementCopyWith<$Res> implements $RequirementCopyWith<$Res> {
  factory _$RequirementCopyWith(_Requirement value, $Res Function(_Requirement) _then) = __$RequirementCopyWithImpl;
@override @useResult
$Res call({
 String id, String applicationId, String title, String kind, RequirementStatus status, bool external, int sortOrder, String? notes
});




}
/// @nodoc
class __$RequirementCopyWithImpl<$Res>
    implements _$RequirementCopyWith<$Res> {
  __$RequirementCopyWithImpl(this._self, this._then);

  final _Requirement _self;
  final $Res Function(_Requirement) _then;

/// Create a copy of Requirement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? applicationId = null,Object? title = null,Object? kind = null,Object? status = null,Object? external = null,Object? sortOrder = null,Object? notes = freezed,}) {
  return _then(_Requirement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequirementStatus,external: null == external ? _self.external : external // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
