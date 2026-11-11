// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'letters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Recommender {

 String get id; String get name; String? get academicTitle; String? get email;/// Their institution, free text ("University of Lagos").
 String? get institution;/// "Final-year project supervisor"
 String? get relationship; String? get notes; int get letters; int get submitted;
/// Create a copy of Recommender
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommenderCopyWith<Recommender> get copyWith => _$RecommenderCopyWithImpl<Recommender>(this as Recommender, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Recommender;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recommender&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.academicTitle, _this.academicTitle) || other.academicTitle == _this.academicTitle)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.institution, _this.institution) || other.institution == _this.institution)&&(identical(other.relationship, _this.relationship) || other.relationship == _this.relationship)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.letters, _this.letters) || other.letters == _this.letters)&&(identical(other.submitted, _this.submitted) || other.submitted == _this.submitted));
}


@override
int get hashCode {
  final _this = this as Recommender;
  return Object.hash(runtimeType,_this.id,_this.name,_this.academicTitle,_this.email,_this.institution,_this.relationship,_this.notes,_this.letters,_this.submitted);
}

@override
String toString() {
  final _this = this as Recommender;
  return 'Recommender(id: ${_this.id}, name: ${_this.name}, academicTitle: ${_this.academicTitle}, email: ${_this.email}, institution: ${_this.institution}, relationship: ${_this.relationship}, notes: ${_this.notes}, letters: ${_this.letters}, submitted: ${_this.submitted})';
}


}

/// @nodoc
abstract mixin class $RecommenderCopyWith<$Res>  {
  factory $RecommenderCopyWith(Recommender value, $Res Function(Recommender) _then) = _$RecommenderCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? academicTitle, String? email, String? institution, String? relationship, String? notes, int letters, int submitted
});




}
/// @nodoc
class _$RecommenderCopyWithImpl<$Res>
    implements $RecommenderCopyWith<$Res> {
  _$RecommenderCopyWithImpl(this._self, this._then);

  final Recommender _self;
  final $Res Function(Recommender) _then;

/// Create a copy of Recommender
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? academicTitle = freezed,Object? email = freezed,Object? institution = freezed,Object? relationship = freezed,Object? notes = freezed,Object? letters = null,Object? submitted = null,}) {
  return _then(Recommender(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,academicTitle: freezed == academicTitle ? _self.academicTitle : academicTitle // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,institution: freezed == institution ? _self.institution : institution // ignore: cast_nullable_to_non_nullable
as String?,relationship: freezed == relationship ? _self.relationship : relationship // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,letters: null == letters ? _self.letters : letters // ignore: cast_nullable_to_non_nullable
as int,submitted: null == submitted ? _self.submitted : submitted // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Recommender].
extension RecommenderPatterns on Recommender {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recommender value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recommender() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recommender value)  $default,){
final _that = this;
switch (_that) {
case _Recommender():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recommender value)?  $default,){
final _that = this;
switch (_that) {
case _Recommender() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? academicTitle,  String? email,  String? institution,  String? relationship,  String? notes,  int letters,  int submitted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recommender() when $default != null:
return $default(_that.id,_that.name,_that.academicTitle,_that.email,_that.institution,_that.relationship,_that.notes,_that.letters,_that.submitted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? academicTitle,  String? email,  String? institution,  String? relationship,  String? notes,  int letters,  int submitted)  $default,) {final _that = this;
switch (_that) {
case _Recommender():
return $default(_that.id,_that.name,_that.academicTitle,_that.email,_that.institution,_that.relationship,_that.notes,_that.letters,_that.submitted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? academicTitle,  String? email,  String? institution,  String? relationship,  String? notes,  int letters,  int submitted)?  $default,) {final _that = this;
switch (_that) {
case _Recommender() when $default != null:
return $default(_that.id,_that.name,_that.academicTitle,_that.email,_that.institution,_that.relationship,_that.notes,_that.letters,_that.submitted);case _:
  return null;

}
}

}

/// @nodoc


class _Recommender extends Recommender {
  const _Recommender({required this.id, required this.name, this.academicTitle, this.email, this.institution, this.relationship, this.notes, this.letters = 0, this.submitted = 0}): super._();
  

@override final  String id;
@override final  String name;
@override final  String? academicTitle;
@override final  String? email;
/// Their institution, free text ("University of Lagos").
@override final  String? institution;
/// "Final-year project supervisor"
@override final  String? relationship;
@override final  String? notes;
@override@JsonKey() final  int letters;
@override@JsonKey() final  int submitted;

/// Create a copy of Recommender
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommenderCopyWith<_Recommender> get copyWith => __$RecommenderCopyWithImpl<_Recommender>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recommender&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.academicTitle, academicTitle) || other.academicTitle == academicTitle)&&(identical(other.email, email) || other.email == email)&&(identical(other.institution, institution) || other.institution == institution)&&(identical(other.relationship, relationship) || other.relationship == relationship)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.letters, letters) || other.letters == letters)&&(identical(other.submitted, submitted) || other.submitted == submitted));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,academicTitle,email,institution,relationship,notes,letters,submitted);
}

@override
String toString() {
    return 'Recommender(id: $id, name: $name, academicTitle: $academicTitle, email: $email, institution: $institution, relationship: $relationship, notes: $notes, letters: $letters, submitted: $submitted)';
}


}

/// @nodoc
abstract mixin class _$RecommenderCopyWith<$Res> implements $RecommenderCopyWith<$Res> {
  factory _$RecommenderCopyWith(_Recommender value, $Res Function(_Recommender) _then) = __$RecommenderCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? academicTitle, String? email, String? institution, String? relationship, String? notes, int letters, int submitted
});




}
/// @nodoc
class __$RecommenderCopyWithImpl<$Res>
    implements _$RecommenderCopyWith<$Res> {
  __$RecommenderCopyWithImpl(this._self, this._then);

  final _Recommender _self;
  final $Res Function(_Recommender) _then;

/// Create a copy of Recommender
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? academicTitle = freezed,Object? email = freezed,Object? institution = freezed,Object? relationship = freezed,Object? notes = freezed,Object? letters = null,Object? submitted = null,}) {
  return _then(_Recommender(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,academicTitle: freezed == academicTitle ? _self.academicTitle : academicTitle // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,institution: freezed == institution ? _self.institution : institution // ignore: cast_nullable_to_non_nullable
as String?,relationship: freezed == relationship ? _self.relationship : relationship // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,letters: null == letters ? _self.letters : letters // ignore: cast_nullable_to_non_nullable
as int,submitted: null == submitted ? _self.submitted : submitted // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$RecommenderDraft {

 String get name; String? get academicTitle; String? get email; String? get institution; String? get relationship; String? get notes;
/// Create a copy of RecommenderDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommenderDraftCopyWith<RecommenderDraft> get copyWith => _$RecommenderDraftCopyWithImpl<RecommenderDraft>(this as RecommenderDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecommenderDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommenderDraft&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.academicTitle, _this.academicTitle) || other.academicTitle == _this.academicTitle)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.institution, _this.institution) || other.institution == _this.institution)&&(identical(other.relationship, _this.relationship) || other.relationship == _this.relationship)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}


@override
int get hashCode {
  final _this = this as RecommenderDraft;
  return Object.hash(runtimeType,_this.name,_this.academicTitle,_this.email,_this.institution,_this.relationship,_this.notes);
}

@override
String toString() {
  final _this = this as RecommenderDraft;
  return 'RecommenderDraft(name: ${_this.name}, academicTitle: ${_this.academicTitle}, email: ${_this.email}, institution: ${_this.institution}, relationship: ${_this.relationship}, notes: ${_this.notes})';
}


}

/// @nodoc
abstract mixin class $RecommenderDraftCopyWith<$Res>  {
  factory $RecommenderDraftCopyWith(RecommenderDraft value, $Res Function(RecommenderDraft) _then) = _$RecommenderDraftCopyWithImpl;
@useResult
$Res call({
 String name, String? academicTitle, String? email, String? institution, String? relationship, String? notes
});




}
/// @nodoc
class _$RecommenderDraftCopyWithImpl<$Res>
    implements $RecommenderDraftCopyWith<$Res> {
  _$RecommenderDraftCopyWithImpl(this._self, this._then);

  final RecommenderDraft _self;
  final $Res Function(RecommenderDraft) _then;

/// Create a copy of RecommenderDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? academicTitle = freezed,Object? email = freezed,Object? institution = freezed,Object? relationship = freezed,Object? notes = freezed,}) {
  return _then(RecommenderDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,academicTitle: freezed == academicTitle ? _self.academicTitle : academicTitle // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,institution: freezed == institution ? _self.institution : institution // ignore: cast_nullable_to_non_nullable
as String?,relationship: freezed == relationship ? _self.relationship : relationship // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecommenderDraft].
extension RecommenderDraftPatterns on RecommenderDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommenderDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommenderDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommenderDraft value)  $default,){
final _that = this;
switch (_that) {
case _RecommenderDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommenderDraft value)?  $default,){
final _that = this;
switch (_that) {
case _RecommenderDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? academicTitle,  String? email,  String? institution,  String? relationship,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommenderDraft() when $default != null:
return $default(_that.name,_that.academicTitle,_that.email,_that.institution,_that.relationship,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? academicTitle,  String? email,  String? institution,  String? relationship,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _RecommenderDraft():
return $default(_that.name,_that.academicTitle,_that.email,_that.institution,_that.relationship,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? academicTitle,  String? email,  String? institution,  String? relationship,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _RecommenderDraft() when $default != null:
return $default(_that.name,_that.academicTitle,_that.email,_that.institution,_that.relationship,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _RecommenderDraft extends RecommenderDraft {
  const _RecommenderDraft({this.name = '', this.academicTitle, this.email, this.institution, this.relationship, this.notes}): super._();
  

@override@JsonKey() final  String name;
@override final  String? academicTitle;
@override final  String? email;
@override final  String? institution;
@override final  String? relationship;
@override final  String? notes;

/// Create a copy of RecommenderDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommenderDraftCopyWith<_RecommenderDraft> get copyWith => __$RecommenderDraftCopyWithImpl<_RecommenderDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommenderDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.academicTitle, academicTitle) || other.academicTitle == academicTitle)&&(identical(other.email, email) || other.email == email)&&(identical(other.institution, institution) || other.institution == institution)&&(identical(other.relationship, relationship) || other.relationship == relationship)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,academicTitle,email,institution,relationship,notes);
}

@override
String toString() {
    return 'RecommenderDraft(name: $name, academicTitle: $academicTitle, email: $email, institution: $institution, relationship: $relationship, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$RecommenderDraftCopyWith<$Res> implements $RecommenderDraftCopyWith<$Res> {
  factory _$RecommenderDraftCopyWith(_RecommenderDraft value, $Res Function(_RecommenderDraft) _then) = __$RecommenderDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, String? academicTitle, String? email, String? institution, String? relationship, String? notes
});




}
/// @nodoc
class __$RecommenderDraftCopyWithImpl<$Res>
    implements _$RecommenderDraftCopyWith<$Res> {
  __$RecommenderDraftCopyWithImpl(this._self, this._then);

  final _RecommenderDraft _self;
  final $Res Function(_RecommenderDraft) _then;

/// Create a copy of RecommenderDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? academicTitle = freezed,Object? email = freezed,Object? institution = freezed,Object? relationship = freezed,Object? notes = freezed,}) {
  return _then(_RecommenderDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,academicTitle: freezed == academicTitle ? _self.academicTitle : academicTitle // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,institution: freezed == institution ? _self.institution : institution // ignore: cast_nullable_to_non_nullable
as String?,relationship: freezed == relationship ? _self.relationship : relationship // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$LetterRequest {

 String get id; String get applicationId; String get recommenderId; String get recommenderName; String? get recommenderTitle; LetterStatus get status; DateTime? get statusChangedAt; String? get notes;
/// Create a copy of LetterRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LetterRequestCopyWith<LetterRequest> get copyWith => _$LetterRequestCopyWithImpl<LetterRequest>(this as LetterRequest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LetterRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LetterRequest&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.applicationId, _this.applicationId) || other.applicationId == _this.applicationId)&&(identical(other.recommenderId, _this.recommenderId) || other.recommenderId == _this.recommenderId)&&(identical(other.recommenderName, _this.recommenderName) || other.recommenderName == _this.recommenderName)&&(identical(other.recommenderTitle, _this.recommenderTitle) || other.recommenderTitle == _this.recommenderTitle)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.statusChangedAt, _this.statusChangedAt) || other.statusChangedAt == _this.statusChangedAt)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}


@override
int get hashCode {
  final _this = this as LetterRequest;
  return Object.hash(runtimeType,_this.id,_this.applicationId,_this.recommenderId,_this.recommenderName,_this.recommenderTitle,_this.status,_this.statusChangedAt,_this.notes);
}

@override
String toString() {
  final _this = this as LetterRequest;
  return 'LetterRequest(id: ${_this.id}, applicationId: ${_this.applicationId}, recommenderId: ${_this.recommenderId}, recommenderName: ${_this.recommenderName}, recommenderTitle: ${_this.recommenderTitle}, status: ${_this.status}, statusChangedAt: ${_this.statusChangedAt}, notes: ${_this.notes})';
}


}

/// @nodoc
abstract mixin class $LetterRequestCopyWith<$Res>  {
  factory $LetterRequestCopyWith(LetterRequest value, $Res Function(LetterRequest) _then) = _$LetterRequestCopyWithImpl;
@useResult
$Res call({
 String id, String applicationId, String recommenderId, String recommenderName, String? recommenderTitle, LetterStatus status, DateTime? statusChangedAt, String? notes
});




}
/// @nodoc
class _$LetterRequestCopyWithImpl<$Res>
    implements $LetterRequestCopyWith<$Res> {
  _$LetterRequestCopyWithImpl(this._self, this._then);

  final LetterRequest _self;
  final $Res Function(LetterRequest) _then;

/// Create a copy of LetterRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? applicationId = null,Object? recommenderId = null,Object? recommenderName = null,Object? recommenderTitle = freezed,Object? status = null,Object? statusChangedAt = freezed,Object? notes = freezed,}) {
  return _then(LetterRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,recommenderId: null == recommenderId ? _self.recommenderId : recommenderId // ignore: cast_nullable_to_non_nullable
as String,recommenderName: null == recommenderName ? _self.recommenderName : recommenderName // ignore: cast_nullable_to_non_nullable
as String,recommenderTitle: freezed == recommenderTitle ? _self.recommenderTitle : recommenderTitle // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LetterStatus,statusChangedAt: freezed == statusChangedAt ? _self.statusChangedAt : statusChangedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LetterRequest].
extension LetterRequestPatterns on LetterRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LetterRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LetterRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LetterRequest value)  $default,){
final _that = this;
switch (_that) {
case _LetterRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LetterRequest value)?  $default,){
final _that = this;
switch (_that) {
case _LetterRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String applicationId,  String recommenderId,  String recommenderName,  String? recommenderTitle,  LetterStatus status,  DateTime? statusChangedAt,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LetterRequest() when $default != null:
return $default(_that.id,_that.applicationId,_that.recommenderId,_that.recommenderName,_that.recommenderTitle,_that.status,_that.statusChangedAt,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String applicationId,  String recommenderId,  String recommenderName,  String? recommenderTitle,  LetterStatus status,  DateTime? statusChangedAt,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _LetterRequest():
return $default(_that.id,_that.applicationId,_that.recommenderId,_that.recommenderName,_that.recommenderTitle,_that.status,_that.statusChangedAt,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String applicationId,  String recommenderId,  String recommenderName,  String? recommenderTitle,  LetterStatus status,  DateTime? statusChangedAt,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _LetterRequest() when $default != null:
return $default(_that.id,_that.applicationId,_that.recommenderId,_that.recommenderName,_that.recommenderTitle,_that.status,_that.statusChangedAt,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _LetterRequest implements LetterRequest {
  const _LetterRequest({required this.id, required this.applicationId, required this.recommenderId, required this.recommenderName, this.recommenderTitle, this.status = LetterStatus.planned, this.statusChangedAt, this.notes});
  

@override final  String id;
@override final  String applicationId;
@override final  String recommenderId;
@override final  String recommenderName;
@override final  String? recommenderTitle;
@override@JsonKey() final  LetterStatus status;
@override final  DateTime? statusChangedAt;
@override final  String? notes;

/// Create a copy of LetterRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LetterRequestCopyWith<_LetterRequest> get copyWith => __$LetterRequestCopyWithImpl<_LetterRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LetterRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.recommenderId, recommenderId) || other.recommenderId == recommenderId)&&(identical(other.recommenderName, recommenderName) || other.recommenderName == recommenderName)&&(identical(other.recommenderTitle, recommenderTitle) || other.recommenderTitle == recommenderTitle)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusChangedAt, statusChangedAt) || other.statusChangedAt == statusChangedAt)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,applicationId,recommenderId,recommenderName,recommenderTitle,status,statusChangedAt,notes);
}

@override
String toString() {
    return 'LetterRequest(id: $id, applicationId: $applicationId, recommenderId: $recommenderId, recommenderName: $recommenderName, recommenderTitle: $recommenderTitle, status: $status, statusChangedAt: $statusChangedAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$LetterRequestCopyWith<$Res> implements $LetterRequestCopyWith<$Res> {
  factory _$LetterRequestCopyWith(_LetterRequest value, $Res Function(_LetterRequest) _then) = __$LetterRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String applicationId, String recommenderId, String recommenderName, String? recommenderTitle, LetterStatus status, DateTime? statusChangedAt, String? notes
});




}
/// @nodoc
class __$LetterRequestCopyWithImpl<$Res>
    implements _$LetterRequestCopyWith<$Res> {
  __$LetterRequestCopyWithImpl(this._self, this._then);

  final _LetterRequest _self;
  final $Res Function(_LetterRequest) _then;

/// Create a copy of LetterRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? applicationId = null,Object? recommenderId = null,Object? recommenderName = null,Object? recommenderTitle = freezed,Object? status = null,Object? statusChangedAt = freezed,Object? notes = freezed,}) {
  return _then(_LetterRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,recommenderId: null == recommenderId ? _self.recommenderId : recommenderId // ignore: cast_nullable_to_non_nullable
as String,recommenderName: null == recommenderName ? _self.recommenderName : recommenderName // ignore: cast_nullable_to_non_nullable
as String,recommenderTitle: freezed == recommenderTitle ? _self.recommenderTitle : recommenderTitle // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LetterStatus,statusChangedAt: freezed == statusChangedAt ? _self.statusChangedAt : statusChangedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
