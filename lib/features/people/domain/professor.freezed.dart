// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'professor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Professor {

 String get id; String get institutionId; String get institutionName; String get name; String? get academicTitle; String? get department; String? get email; String? get profileUrl; String? get researchInterests; String? get notes; ProfessorStance get stance; OutreachState get state; DateTime? get lastSentAt; DateTime? get lastReplyAt;/// When to follow up if there's no reply (null = no reminder).
 DateTime? get followUpAt;/// Applications this professor is relevant to (`application_professors`).
 List<String> get applicationIds;
/// Create a copy of Professor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfessorCopyWith<Professor> get copyWith => _$ProfessorCopyWithImpl<Professor>(this as Professor, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Professor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Professor&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.institutionId, _this.institutionId) || other.institutionId == _this.institutionId)&&(identical(other.institutionName, _this.institutionName) || other.institutionName == _this.institutionName)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.academicTitle, _this.academicTitle) || other.academicTitle == _this.academicTitle)&&(identical(other.department, _this.department) || other.department == _this.department)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.profileUrl, _this.profileUrl) || other.profileUrl == _this.profileUrl)&&(identical(other.researchInterests, _this.researchInterests) || other.researchInterests == _this.researchInterests)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.stance, _this.stance) || other.stance == _this.stance)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.lastSentAt, _this.lastSentAt) || other.lastSentAt == _this.lastSentAt)&&(identical(other.lastReplyAt, _this.lastReplyAt) || other.lastReplyAt == _this.lastReplyAt)&&(identical(other.followUpAt, _this.followUpAt) || other.followUpAt == _this.followUpAt)&&const DeepCollectionEquality().equals(other.applicationIds, _this.applicationIds));
}


@override
int get hashCode {
  final _this = this as Professor;
  return Object.hash(runtimeType,_this.id,_this.institutionId,_this.institutionName,_this.name,_this.academicTitle,_this.department,_this.email,_this.profileUrl,_this.researchInterests,_this.notes,_this.stance,_this.state,_this.lastSentAt,_this.lastReplyAt,_this.followUpAt,const DeepCollectionEquality().hash(_this.applicationIds));
}

@override
String toString() {
  final _this = this as Professor;
  return 'Professor(id: ${_this.id}, institutionId: ${_this.institutionId}, institutionName: ${_this.institutionName}, name: ${_this.name}, academicTitle: ${_this.academicTitle}, department: ${_this.department}, email: ${_this.email}, profileUrl: ${_this.profileUrl}, researchInterests: ${_this.researchInterests}, notes: ${_this.notes}, stance: ${_this.stance}, state: ${_this.state}, lastSentAt: ${_this.lastSentAt}, lastReplyAt: ${_this.lastReplyAt}, followUpAt: ${_this.followUpAt}, applicationIds: ${_this.applicationIds})';
}


}

/// @nodoc
abstract mixin class $ProfessorCopyWith<$Res>  {
  factory $ProfessorCopyWith(Professor value, $Res Function(Professor) _then) = _$ProfessorCopyWithImpl;
@useResult
$Res call({
 String id, String institutionId, String institutionName, String name, String? academicTitle, String? department, String? email, String? profileUrl, String? researchInterests, String? notes, ProfessorStance stance, OutreachState state, DateTime? lastSentAt, DateTime? lastReplyAt, DateTime? followUpAt, List<String> applicationIds
});




}
/// @nodoc
class _$ProfessorCopyWithImpl<$Res>
    implements $ProfessorCopyWith<$Res> {
  _$ProfessorCopyWithImpl(this._self, this._then);

  final Professor _self;
  final $Res Function(Professor) _then;

/// Create a copy of Professor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? institutionId = null,Object? institutionName = null,Object? name = null,Object? academicTitle = freezed,Object? department = freezed,Object? email = freezed,Object? profileUrl = freezed,Object? researchInterests = freezed,Object? notes = freezed,Object? stance = null,Object? state = null,Object? lastSentAt = freezed,Object? lastReplyAt = freezed,Object? followUpAt = freezed,Object? applicationIds = null,}) {
  return _then(Professor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,institutionId: null == institutionId ? _self.institutionId : institutionId // ignore: cast_nullable_to_non_nullable
as String,institutionName: null == institutionName ? _self.institutionName : institutionName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,academicTitle: freezed == academicTitle ? _self.academicTitle : academicTitle // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,profileUrl: freezed == profileUrl ? _self.profileUrl : profileUrl // ignore: cast_nullable_to_non_nullable
as String?,researchInterests: freezed == researchInterests ? _self.researchInterests : researchInterests // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,stance: null == stance ? _self.stance : stance // ignore: cast_nullable_to_non_nullable
as ProfessorStance,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OutreachState,lastSentAt: freezed == lastSentAt ? _self.lastSentAt : lastSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReplyAt: freezed == lastReplyAt ? _self.lastReplyAt : lastReplyAt // ignore: cast_nullable_to_non_nullable
as DateTime?,followUpAt: freezed == followUpAt ? _self.followUpAt : followUpAt // ignore: cast_nullable_to_non_nullable
as DateTime?,applicationIds: null == applicationIds ? _self.applicationIds : applicationIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Professor].
extension ProfessorPatterns on Professor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Professor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Professor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Professor value)  $default,){
final _that = this;
switch (_that) {
case _Professor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Professor value)?  $default,){
final _that = this;
switch (_that) {
case _Professor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String institutionId,  String institutionName,  String name,  String? academicTitle,  String? department,  String? email,  String? profileUrl,  String? researchInterests,  String? notes,  ProfessorStance stance,  OutreachState state,  DateTime? lastSentAt,  DateTime? lastReplyAt,  DateTime? followUpAt,  List<String> applicationIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Professor() when $default != null:
return $default(_that.id,_that.institutionId,_that.institutionName,_that.name,_that.academicTitle,_that.department,_that.email,_that.profileUrl,_that.researchInterests,_that.notes,_that.stance,_that.state,_that.lastSentAt,_that.lastReplyAt,_that.followUpAt,_that.applicationIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String institutionId,  String institutionName,  String name,  String? academicTitle,  String? department,  String? email,  String? profileUrl,  String? researchInterests,  String? notes,  ProfessorStance stance,  OutreachState state,  DateTime? lastSentAt,  DateTime? lastReplyAt,  DateTime? followUpAt,  List<String> applicationIds)  $default,) {final _that = this;
switch (_that) {
case _Professor():
return $default(_that.id,_that.institutionId,_that.institutionName,_that.name,_that.academicTitle,_that.department,_that.email,_that.profileUrl,_that.researchInterests,_that.notes,_that.stance,_that.state,_that.lastSentAt,_that.lastReplyAt,_that.followUpAt,_that.applicationIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String institutionId,  String institutionName,  String name,  String? academicTitle,  String? department,  String? email,  String? profileUrl,  String? researchInterests,  String? notes,  ProfessorStance stance,  OutreachState state,  DateTime? lastSentAt,  DateTime? lastReplyAt,  DateTime? followUpAt,  List<String> applicationIds)?  $default,) {final _that = this;
switch (_that) {
case _Professor() when $default != null:
return $default(_that.id,_that.institutionId,_that.institutionName,_that.name,_that.academicTitle,_that.department,_that.email,_that.profileUrl,_that.researchInterests,_that.notes,_that.stance,_that.state,_that.lastSentAt,_that.lastReplyAt,_that.followUpAt,_that.applicationIds);case _:
  return null;

}
}

}

/// @nodoc


class _Professor extends Professor {
  const _Professor({required this.id, required this.institutionId, required this.institutionName, required this.name, this.academicTitle, this.department, this.email, this.profileUrl, this.researchInterests, this.notes, this.stance = ProfessorStance.unknown, this.state = OutreachState.toContact, this.lastSentAt, this.lastReplyAt, this.followUpAt,  List<String> applicationIds = const <String>[]}): _applicationIds = applicationIds,super._();
  

@override final  String id;
@override final  String institutionId;
@override final  String institutionName;
@override final  String name;
@override final  String? academicTitle;
@override final  String? department;
@override final  String? email;
@override final  String? profileUrl;
@override final  String? researchInterests;
@override final  String? notes;
@override@JsonKey() final  ProfessorStance stance;
@override@JsonKey() final  OutreachState state;
@override final  DateTime? lastSentAt;
@override final  DateTime? lastReplyAt;
/// When to follow up if there's no reply (null = no reminder).
@override final  DateTime? followUpAt;
/// Applications this professor is relevant to (`application_professors`).
 final  List<String> _applicationIds;
/// Applications this professor is relevant to (`application_professors`).
@override@JsonKey() List<String> get applicationIds {
  if (_applicationIds is EqualUnmodifiableListView) return _applicationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_applicationIds);
}


/// Create a copy of Professor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfessorCopyWith<_Professor> get copyWith => __$ProfessorCopyWithImpl<_Professor>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Professor&&(identical(other.id, id) || other.id == id)&&(identical(other.institutionId, institutionId) || other.institutionId == institutionId)&&(identical(other.institutionName, institutionName) || other.institutionName == institutionName)&&(identical(other.name, name) || other.name == name)&&(identical(other.academicTitle, academicTitle) || other.academicTitle == academicTitle)&&(identical(other.department, department) || other.department == department)&&(identical(other.email, email) || other.email == email)&&(identical(other.profileUrl, profileUrl) || other.profileUrl == profileUrl)&&(identical(other.researchInterests, researchInterests) || other.researchInterests == researchInterests)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.stance, stance) || other.stance == stance)&&(identical(other.state, state) || other.state == state)&&(identical(other.lastSentAt, lastSentAt) || other.lastSentAt == lastSentAt)&&(identical(other.lastReplyAt, lastReplyAt) || other.lastReplyAt == lastReplyAt)&&(identical(other.followUpAt, followUpAt) || other.followUpAt == followUpAt)&&const DeepCollectionEquality().equals(other.applicationIds, _applicationIds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,institutionId,institutionName,name,academicTitle,department,email,profileUrl,researchInterests,notes,stance,state,lastSentAt,lastReplyAt,followUpAt,const DeepCollectionEquality().hash(_applicationIds));
}

@override
String toString() {
    return 'Professor(id: $id, institutionId: $institutionId, institutionName: $institutionName, name: $name, academicTitle: $academicTitle, department: $department, email: $email, profileUrl: $profileUrl, researchInterests: $researchInterests, notes: $notes, stance: $stance, state: $state, lastSentAt: $lastSentAt, lastReplyAt: $lastReplyAt, followUpAt: $followUpAt, applicationIds: $applicationIds)';
}


}

/// @nodoc
abstract mixin class _$ProfessorCopyWith<$Res> implements $ProfessorCopyWith<$Res> {
  factory _$ProfessorCopyWith(_Professor value, $Res Function(_Professor) _then) = __$ProfessorCopyWithImpl;
@override @useResult
$Res call({
 String id, String institutionId, String institutionName, String name, String? academicTitle, String? department, String? email, String? profileUrl, String? researchInterests, String? notes, ProfessorStance stance, OutreachState state, DateTime? lastSentAt, DateTime? lastReplyAt, DateTime? followUpAt, List<String> applicationIds
});




}
/// @nodoc
class __$ProfessorCopyWithImpl<$Res>
    implements _$ProfessorCopyWith<$Res> {
  __$ProfessorCopyWithImpl(this._self, this._then);

  final _Professor _self;
  final $Res Function(_Professor) _then;

/// Create a copy of Professor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? institutionId = null,Object? institutionName = null,Object? name = null,Object? academicTitle = freezed,Object? department = freezed,Object? email = freezed,Object? profileUrl = freezed,Object? researchInterests = freezed,Object? notes = freezed,Object? stance = null,Object? state = null,Object? lastSentAt = freezed,Object? lastReplyAt = freezed,Object? followUpAt = freezed,Object? applicationIds = null,}) {
  return _then(_Professor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,institutionId: null == institutionId ? _self.institutionId : institutionId // ignore: cast_nullable_to_non_nullable
as String,institutionName: null == institutionName ? _self.institutionName : institutionName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,academicTitle: freezed == academicTitle ? _self.academicTitle : academicTitle // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,profileUrl: freezed == profileUrl ? _self.profileUrl : profileUrl // ignore: cast_nullable_to_non_nullable
as String?,researchInterests: freezed == researchInterests ? _self.researchInterests : researchInterests // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,stance: null == stance ? _self.stance : stance // ignore: cast_nullable_to_non_nullable
as ProfessorStance,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OutreachState,lastSentAt: freezed == lastSentAt ? _self.lastSentAt : lastSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReplyAt: freezed == lastReplyAt ? _self.lastReplyAt : lastReplyAt // ignore: cast_nullable_to_non_nullable
as DateTime?,followUpAt: freezed == followUpAt ? _self.followUpAt : followUpAt // ignore: cast_nullable_to_non_nullable
as DateTime?,applicationIds: null == applicationIds ? _self._applicationIds : applicationIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$ProfessorDraft {

/// Existing institution, or null to create one named [institutionName].
 String? get institutionId; String get institutionName; String get name; String? get academicTitle; String? get department; String? get email; String? get profileUrl; String? get researchInterests; String? get notes;
/// Create a copy of ProfessorDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfessorDraftCopyWith<ProfessorDraft> get copyWith => _$ProfessorDraftCopyWithImpl<ProfessorDraft>(this as ProfessorDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProfessorDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfessorDraft&&(identical(other.institutionId, _this.institutionId) || other.institutionId == _this.institutionId)&&(identical(other.institutionName, _this.institutionName) || other.institutionName == _this.institutionName)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.academicTitle, _this.academicTitle) || other.academicTitle == _this.academicTitle)&&(identical(other.department, _this.department) || other.department == _this.department)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.profileUrl, _this.profileUrl) || other.profileUrl == _this.profileUrl)&&(identical(other.researchInterests, _this.researchInterests) || other.researchInterests == _this.researchInterests)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}


@override
int get hashCode {
  final _this = this as ProfessorDraft;
  return Object.hash(runtimeType,_this.institutionId,_this.institutionName,_this.name,_this.academicTitle,_this.department,_this.email,_this.profileUrl,_this.researchInterests,_this.notes);
}

@override
String toString() {
  final _this = this as ProfessorDraft;
  return 'ProfessorDraft(institutionId: ${_this.institutionId}, institutionName: ${_this.institutionName}, name: ${_this.name}, academicTitle: ${_this.academicTitle}, department: ${_this.department}, email: ${_this.email}, profileUrl: ${_this.profileUrl}, researchInterests: ${_this.researchInterests}, notes: ${_this.notes})';
}


}

/// @nodoc
abstract mixin class $ProfessorDraftCopyWith<$Res>  {
  factory $ProfessorDraftCopyWith(ProfessorDraft value, $Res Function(ProfessorDraft) _then) = _$ProfessorDraftCopyWithImpl;
@useResult
$Res call({
 String? institutionId, String institutionName, String name, String? academicTitle, String? department, String? email, String? profileUrl, String? researchInterests, String? notes
});




}
/// @nodoc
class _$ProfessorDraftCopyWithImpl<$Res>
    implements $ProfessorDraftCopyWith<$Res> {
  _$ProfessorDraftCopyWithImpl(this._self, this._then);

  final ProfessorDraft _self;
  final $Res Function(ProfessorDraft) _then;

/// Create a copy of ProfessorDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? institutionId = freezed,Object? institutionName = null,Object? name = null,Object? academicTitle = freezed,Object? department = freezed,Object? email = freezed,Object? profileUrl = freezed,Object? researchInterests = freezed,Object? notes = freezed,}) {
  return _then(ProfessorDraft(
institutionId: freezed == institutionId ? _self.institutionId : institutionId // ignore: cast_nullable_to_non_nullable
as String?,institutionName: null == institutionName ? _self.institutionName : institutionName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,academicTitle: freezed == academicTitle ? _self.academicTitle : academicTitle // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,profileUrl: freezed == profileUrl ? _self.profileUrl : profileUrl // ignore: cast_nullable_to_non_nullable
as String?,researchInterests: freezed == researchInterests ? _self.researchInterests : researchInterests // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfessorDraft].
extension ProfessorDraftPatterns on ProfessorDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfessorDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfessorDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfessorDraft value)  $default,){
final _that = this;
switch (_that) {
case _ProfessorDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfessorDraft value)?  $default,){
final _that = this;
switch (_that) {
case _ProfessorDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? institutionId,  String institutionName,  String name,  String? academicTitle,  String? department,  String? email,  String? profileUrl,  String? researchInterests,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfessorDraft() when $default != null:
return $default(_that.institutionId,_that.institutionName,_that.name,_that.academicTitle,_that.department,_that.email,_that.profileUrl,_that.researchInterests,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? institutionId,  String institutionName,  String name,  String? academicTitle,  String? department,  String? email,  String? profileUrl,  String? researchInterests,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _ProfessorDraft():
return $default(_that.institutionId,_that.institutionName,_that.name,_that.academicTitle,_that.department,_that.email,_that.profileUrl,_that.researchInterests,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? institutionId,  String institutionName,  String name,  String? academicTitle,  String? department,  String? email,  String? profileUrl,  String? researchInterests,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _ProfessorDraft() when $default != null:
return $default(_that.institutionId,_that.institutionName,_that.name,_that.academicTitle,_that.department,_that.email,_that.profileUrl,_that.researchInterests,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _ProfessorDraft extends ProfessorDraft {
  const _ProfessorDraft({this.institutionId, this.institutionName = '', this.name = '', this.academicTitle, this.department, this.email, this.profileUrl, this.researchInterests, this.notes}): super._();
  

/// Existing institution, or null to create one named [institutionName].
@override final  String? institutionId;
@override@JsonKey() final  String institutionName;
@override@JsonKey() final  String name;
@override final  String? academicTitle;
@override final  String? department;
@override final  String? email;
@override final  String? profileUrl;
@override final  String? researchInterests;
@override final  String? notes;

/// Create a copy of ProfessorDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfessorDraftCopyWith<_ProfessorDraft> get copyWith => __$ProfessorDraftCopyWithImpl<_ProfessorDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfessorDraft&&(identical(other.institutionId, institutionId) || other.institutionId == institutionId)&&(identical(other.institutionName, institutionName) || other.institutionName == institutionName)&&(identical(other.name, name) || other.name == name)&&(identical(other.academicTitle, academicTitle) || other.academicTitle == academicTitle)&&(identical(other.department, department) || other.department == department)&&(identical(other.email, email) || other.email == email)&&(identical(other.profileUrl, profileUrl) || other.profileUrl == profileUrl)&&(identical(other.researchInterests, researchInterests) || other.researchInterests == researchInterests)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,institutionId,institutionName,name,academicTitle,department,email,profileUrl,researchInterests,notes);
}

@override
String toString() {
    return 'ProfessorDraft(institutionId: $institutionId, institutionName: $institutionName, name: $name, academicTitle: $academicTitle, department: $department, email: $email, profileUrl: $profileUrl, researchInterests: $researchInterests, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$ProfessorDraftCopyWith<$Res> implements $ProfessorDraftCopyWith<$Res> {
  factory _$ProfessorDraftCopyWith(_ProfessorDraft value, $Res Function(_ProfessorDraft) _then) = __$ProfessorDraftCopyWithImpl;
@override @useResult
$Res call({
 String? institutionId, String institutionName, String name, String? academicTitle, String? department, String? email, String? profileUrl, String? researchInterests, String? notes
});




}
/// @nodoc
class __$ProfessorDraftCopyWithImpl<$Res>
    implements _$ProfessorDraftCopyWith<$Res> {
  __$ProfessorDraftCopyWithImpl(this._self, this._then);

  final _ProfessorDraft _self;
  final $Res Function(_ProfessorDraft) _then;

/// Create a copy of ProfessorDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? institutionId = freezed,Object? institutionName = null,Object? name = null,Object? academicTitle = freezed,Object? department = freezed,Object? email = freezed,Object? profileUrl = freezed,Object? researchInterests = freezed,Object? notes = freezed,}) {
  return _then(_ProfessorDraft(
institutionId: freezed == institutionId ? _self.institutionId : institutionId // ignore: cast_nullable_to_non_nullable
as String?,institutionName: null == institutionName ? _self.institutionName : institutionName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,academicTitle: freezed == academicTitle ? _self.academicTitle : academicTitle // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,profileUrl: freezed == profileUrl ? _self.profileUrl : profileUrl // ignore: cast_nullable_to_non_nullable
as String?,researchInterests: freezed == researchInterests ? _self.researchInterests : researchInterests // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
