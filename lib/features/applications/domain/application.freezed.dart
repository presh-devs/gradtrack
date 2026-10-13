// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'application.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Application {

 String get id; String get institutionId; String get institutionName; String get programmeName; DegreeType get degree; ApplicationStage get stage; String? get department; String? get researchArea; String? get country; String? get programmeUrl; String? get portalUrl; String? get portalUsername; String? get fundingUrl; Deadline? get deadline; Deadline? get fundingDeadline; ApplicationOutcome? get outcome; double? get feeAmount; String? get feeCurrency; FeeWaiver get feeWaiver; int get priority; int get requirementsDone; int get requirementsTotal; int get lettersSubmitted; int get lettersTotal; String? get notes;
/// Create a copy of Application
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplicationCopyWith<Application> get copyWith => _$ApplicationCopyWithImpl<Application>(this as Application, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Application;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Application&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.institutionId, _this.institutionId) || other.institutionId == _this.institutionId)&&(identical(other.institutionName, _this.institutionName) || other.institutionName == _this.institutionName)&&(identical(other.programmeName, _this.programmeName) || other.programmeName == _this.programmeName)&&(identical(other.degree, _this.degree) || other.degree == _this.degree)&&(identical(other.stage, _this.stage) || other.stage == _this.stage)&&(identical(other.department, _this.department) || other.department == _this.department)&&(identical(other.researchArea, _this.researchArea) || other.researchArea == _this.researchArea)&&(identical(other.country, _this.country) || other.country == _this.country)&&(identical(other.programmeUrl, _this.programmeUrl) || other.programmeUrl == _this.programmeUrl)&&(identical(other.portalUrl, _this.portalUrl) || other.portalUrl == _this.portalUrl)&&(identical(other.portalUsername, _this.portalUsername) || other.portalUsername == _this.portalUsername)&&(identical(other.fundingUrl, _this.fundingUrl) || other.fundingUrl == _this.fundingUrl)&&(identical(other.deadline, _this.deadline) || other.deadline == _this.deadline)&&(identical(other.fundingDeadline, _this.fundingDeadline) || other.fundingDeadline == _this.fundingDeadline)&&(identical(other.outcome, _this.outcome) || other.outcome == _this.outcome)&&(identical(other.feeAmount, _this.feeAmount) || other.feeAmount == _this.feeAmount)&&(identical(other.feeCurrency, _this.feeCurrency) || other.feeCurrency == _this.feeCurrency)&&(identical(other.feeWaiver, _this.feeWaiver) || other.feeWaiver == _this.feeWaiver)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.requirementsDone, _this.requirementsDone) || other.requirementsDone == _this.requirementsDone)&&(identical(other.requirementsTotal, _this.requirementsTotal) || other.requirementsTotal == _this.requirementsTotal)&&(identical(other.lettersSubmitted, _this.lettersSubmitted) || other.lettersSubmitted == _this.lettersSubmitted)&&(identical(other.lettersTotal, _this.lettersTotal) || other.lettersTotal == _this.lettersTotal)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}


@override
int get hashCode {
  final _this = this as Application;
  return Object.hashAll([runtimeType,_this.id,_this.institutionId,_this.institutionName,_this.programmeName,_this.degree,_this.stage,_this.department,_this.researchArea,_this.country,_this.programmeUrl,_this.portalUrl,_this.portalUsername,_this.fundingUrl,_this.deadline,_this.fundingDeadline,_this.outcome,_this.feeAmount,_this.feeCurrency,_this.feeWaiver,_this.priority,_this.requirementsDone,_this.requirementsTotal,_this.lettersSubmitted,_this.lettersTotal,_this.notes]);
}

@override
String toString() {
  final _this = this as Application;
  return 'Application(id: ${_this.id}, institutionId: ${_this.institutionId}, institutionName: ${_this.institutionName}, programmeName: ${_this.programmeName}, degree: ${_this.degree}, stage: ${_this.stage}, department: ${_this.department}, researchArea: ${_this.researchArea}, country: ${_this.country}, programmeUrl: ${_this.programmeUrl}, portalUrl: ${_this.portalUrl}, portalUsername: ${_this.portalUsername}, fundingUrl: ${_this.fundingUrl}, deadline: ${_this.deadline}, fundingDeadline: ${_this.fundingDeadline}, outcome: ${_this.outcome}, feeAmount: ${_this.feeAmount}, feeCurrency: ${_this.feeCurrency}, feeWaiver: ${_this.feeWaiver}, priority: ${_this.priority}, requirementsDone: ${_this.requirementsDone}, requirementsTotal: ${_this.requirementsTotal}, lettersSubmitted: ${_this.lettersSubmitted}, lettersTotal: ${_this.lettersTotal}, notes: ${_this.notes})';
}


}

/// @nodoc
abstract mixin class $ApplicationCopyWith<$Res>  {
  factory $ApplicationCopyWith(Application value, $Res Function(Application) _then) = _$ApplicationCopyWithImpl;
@useResult
$Res call({
 String id, String institutionId, String institutionName, String programmeName, DegreeType degree, ApplicationStage stage, String? department, String? researchArea, String? country, String? programmeUrl, String? portalUrl, String? portalUsername, String? fundingUrl, Deadline? deadline, Deadline? fundingDeadline, ApplicationOutcome? outcome, double? feeAmount, String? feeCurrency, FeeWaiver feeWaiver, int priority, int requirementsDone, int requirementsTotal, int lettersSubmitted, int lettersTotal, String? notes
});




}
/// @nodoc
class _$ApplicationCopyWithImpl<$Res>
    implements $ApplicationCopyWith<$Res> {
  _$ApplicationCopyWithImpl(this._self, this._then);

  final Application _self;
  final $Res Function(Application) _then;

/// Create a copy of Application
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? institutionId = null,Object? institutionName = null,Object? programmeName = null,Object? degree = null,Object? stage = null,Object? department = freezed,Object? researchArea = freezed,Object? country = freezed,Object? programmeUrl = freezed,Object? portalUrl = freezed,Object? portalUsername = freezed,Object? fundingUrl = freezed,Object? deadline = freezed,Object? fundingDeadline = freezed,Object? outcome = freezed,Object? feeAmount = freezed,Object? feeCurrency = freezed,Object? feeWaiver = null,Object? priority = null,Object? requirementsDone = null,Object? requirementsTotal = null,Object? lettersSubmitted = null,Object? lettersTotal = null,Object? notes = freezed,}) {
  return _then(Application(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,institutionId: null == institutionId ? _self.institutionId : institutionId // ignore: cast_nullable_to_non_nullable
as String,institutionName: null == institutionName ? _self.institutionName : institutionName // ignore: cast_nullable_to_non_nullable
as String,programmeName: null == programmeName ? _self.programmeName : programmeName // ignore: cast_nullable_to_non_nullable
as String,degree: null == degree ? _self.degree : degree // ignore: cast_nullable_to_non_nullable
as DegreeType,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as ApplicationStage,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,researchArea: freezed == researchArea ? _self.researchArea : researchArea // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,programmeUrl: freezed == programmeUrl ? _self.programmeUrl : programmeUrl // ignore: cast_nullable_to_non_nullable
as String?,portalUrl: freezed == portalUrl ? _self.portalUrl : portalUrl // ignore: cast_nullable_to_non_nullable
as String?,portalUsername: freezed == portalUsername ? _self.portalUsername : portalUsername // ignore: cast_nullable_to_non_nullable
as String?,fundingUrl: freezed == fundingUrl ? _self.fundingUrl : fundingUrl // ignore: cast_nullable_to_non_nullable
as String?,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as Deadline?,fundingDeadline: freezed == fundingDeadline ? _self.fundingDeadline : fundingDeadline // ignore: cast_nullable_to_non_nullable
as Deadline?,outcome: freezed == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as ApplicationOutcome?,feeAmount: freezed == feeAmount ? _self.feeAmount : feeAmount // ignore: cast_nullable_to_non_nullable
as double?,feeCurrency: freezed == feeCurrency ? _self.feeCurrency : feeCurrency // ignore: cast_nullable_to_non_nullable
as String?,feeWaiver: null == feeWaiver ? _self.feeWaiver : feeWaiver // ignore: cast_nullable_to_non_nullable
as FeeWaiver,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,requirementsDone: null == requirementsDone ? _self.requirementsDone : requirementsDone // ignore: cast_nullable_to_non_nullable
as int,requirementsTotal: null == requirementsTotal ? _self.requirementsTotal : requirementsTotal // ignore: cast_nullable_to_non_nullable
as int,lettersSubmitted: null == lettersSubmitted ? _self.lettersSubmitted : lettersSubmitted // ignore: cast_nullable_to_non_nullable
as int,lettersTotal: null == lettersTotal ? _self.lettersTotal : lettersTotal // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Application].
extension ApplicationPatterns on Application {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Application value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Application() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Application value)  $default,){
final _that = this;
switch (_that) {
case _Application():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Application value)?  $default,){
final _that = this;
switch (_that) {
case _Application() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String institutionId,  String institutionName,  String programmeName,  DegreeType degree,  ApplicationStage stage,  String? department,  String? researchArea,  String? country,  String? programmeUrl,  String? portalUrl,  String? portalUsername,  String? fundingUrl,  Deadline? deadline,  Deadline? fundingDeadline,  ApplicationOutcome? outcome,  double? feeAmount,  String? feeCurrency,  FeeWaiver feeWaiver,  int priority,  int requirementsDone,  int requirementsTotal,  int lettersSubmitted,  int lettersTotal,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Application() when $default != null:
return $default(_that.id,_that.institutionId,_that.institutionName,_that.programmeName,_that.degree,_that.stage,_that.department,_that.researchArea,_that.country,_that.programmeUrl,_that.portalUrl,_that.portalUsername,_that.fundingUrl,_that.deadline,_that.fundingDeadline,_that.outcome,_that.feeAmount,_that.feeCurrency,_that.feeWaiver,_that.priority,_that.requirementsDone,_that.requirementsTotal,_that.lettersSubmitted,_that.lettersTotal,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String institutionId,  String institutionName,  String programmeName,  DegreeType degree,  ApplicationStage stage,  String? department,  String? researchArea,  String? country,  String? programmeUrl,  String? portalUrl,  String? portalUsername,  String? fundingUrl,  Deadline? deadline,  Deadline? fundingDeadline,  ApplicationOutcome? outcome,  double? feeAmount,  String? feeCurrency,  FeeWaiver feeWaiver,  int priority,  int requirementsDone,  int requirementsTotal,  int lettersSubmitted,  int lettersTotal,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _Application():
return $default(_that.id,_that.institutionId,_that.institutionName,_that.programmeName,_that.degree,_that.stage,_that.department,_that.researchArea,_that.country,_that.programmeUrl,_that.portalUrl,_that.portalUsername,_that.fundingUrl,_that.deadline,_that.fundingDeadline,_that.outcome,_that.feeAmount,_that.feeCurrency,_that.feeWaiver,_that.priority,_that.requirementsDone,_that.requirementsTotal,_that.lettersSubmitted,_that.lettersTotal,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String institutionId,  String institutionName,  String programmeName,  DegreeType degree,  ApplicationStage stage,  String? department,  String? researchArea,  String? country,  String? programmeUrl,  String? portalUrl,  String? portalUsername,  String? fundingUrl,  Deadline? deadline,  Deadline? fundingDeadline,  ApplicationOutcome? outcome,  double? feeAmount,  String? feeCurrency,  FeeWaiver feeWaiver,  int priority,  int requirementsDone,  int requirementsTotal,  int lettersSubmitted,  int lettersTotal,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _Application() when $default != null:
return $default(_that.id,_that.institutionId,_that.institutionName,_that.programmeName,_that.degree,_that.stage,_that.department,_that.researchArea,_that.country,_that.programmeUrl,_that.portalUrl,_that.portalUsername,_that.fundingUrl,_that.deadline,_that.fundingDeadline,_that.outcome,_that.feeAmount,_that.feeCurrency,_that.feeWaiver,_that.priority,_that.requirementsDone,_that.requirementsTotal,_that.lettersSubmitted,_that.lettersTotal,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _Application extends Application {
  const _Application({required this.id, required this.institutionId, required this.institutionName, required this.programmeName, required this.degree, required this.stage, this.department, this.researchArea, this.country, this.programmeUrl, this.portalUrl, this.portalUsername, this.fundingUrl, this.deadline, this.fundingDeadline, this.outcome, this.feeAmount, this.feeCurrency, this.feeWaiver = FeeWaiver.none, this.priority = 2, this.requirementsDone = 0, this.requirementsTotal = 0, this.lettersSubmitted = 0, this.lettersTotal = 0, this.notes}): super._();
  

@override final  String id;
@override final  String institutionId;
@override final  String institutionName;
@override final  String programmeName;
@override final  DegreeType degree;
@override final  ApplicationStage stage;
@override final  String? department;
@override final  String? researchArea;
@override final  String? country;
@override final  String? programmeUrl;
@override final  String? portalUrl;
@override final  String? portalUsername;
@override final  String? fundingUrl;
@override final  Deadline? deadline;
@override final  Deadline? fundingDeadline;
@override final  ApplicationOutcome? outcome;
@override final  double? feeAmount;
@override final  String? feeCurrency;
@override@JsonKey() final  FeeWaiver feeWaiver;
@override@JsonKey() final  int priority;
@override@JsonKey() final  int requirementsDone;
@override@JsonKey() final  int requirementsTotal;
@override@JsonKey() final  int lettersSubmitted;
@override@JsonKey() final  int lettersTotal;
@override final  String? notes;

/// Create a copy of Application
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApplicationCopyWith<_Application> get copyWith => __$ApplicationCopyWithImpl<_Application>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Application&&(identical(other.id, id) || other.id == id)&&(identical(other.institutionId, institutionId) || other.institutionId == institutionId)&&(identical(other.institutionName, institutionName) || other.institutionName == institutionName)&&(identical(other.programmeName, programmeName) || other.programmeName == programmeName)&&(identical(other.degree, degree) || other.degree == degree)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.department, department) || other.department == department)&&(identical(other.researchArea, researchArea) || other.researchArea == researchArea)&&(identical(other.country, country) || other.country == country)&&(identical(other.programmeUrl, programmeUrl) || other.programmeUrl == programmeUrl)&&(identical(other.portalUrl, portalUrl) || other.portalUrl == portalUrl)&&(identical(other.portalUsername, portalUsername) || other.portalUsername == portalUsername)&&(identical(other.fundingUrl, fundingUrl) || other.fundingUrl == fundingUrl)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.fundingDeadline, fundingDeadline) || other.fundingDeadline == fundingDeadline)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.feeAmount, feeAmount) || other.feeAmount == feeAmount)&&(identical(other.feeCurrency, feeCurrency) || other.feeCurrency == feeCurrency)&&(identical(other.feeWaiver, feeWaiver) || other.feeWaiver == feeWaiver)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.requirementsDone, requirementsDone) || other.requirementsDone == requirementsDone)&&(identical(other.requirementsTotal, requirementsTotal) || other.requirementsTotal == requirementsTotal)&&(identical(other.lettersSubmitted, lettersSubmitted) || other.lettersSubmitted == lettersSubmitted)&&(identical(other.lettersTotal, lettersTotal) || other.lettersTotal == lettersTotal)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,institutionId,institutionName,programmeName,degree,stage,department,researchArea,country,programmeUrl,portalUrl,portalUsername,fundingUrl,deadline,fundingDeadline,outcome,feeAmount,feeCurrency,feeWaiver,priority,requirementsDone,requirementsTotal,lettersSubmitted,lettersTotal,notes]);
}

@override
String toString() {
    return 'Application(id: $id, institutionId: $institutionId, institutionName: $institutionName, programmeName: $programmeName, degree: $degree, stage: $stage, department: $department, researchArea: $researchArea, country: $country, programmeUrl: $programmeUrl, portalUrl: $portalUrl, portalUsername: $portalUsername, fundingUrl: $fundingUrl, deadline: $deadline, fundingDeadline: $fundingDeadline, outcome: $outcome, feeAmount: $feeAmount, feeCurrency: $feeCurrency, feeWaiver: $feeWaiver, priority: $priority, requirementsDone: $requirementsDone, requirementsTotal: $requirementsTotal, lettersSubmitted: $lettersSubmitted, lettersTotal: $lettersTotal, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$ApplicationCopyWith<$Res> implements $ApplicationCopyWith<$Res> {
  factory _$ApplicationCopyWith(_Application value, $Res Function(_Application) _then) = __$ApplicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String institutionId, String institutionName, String programmeName, DegreeType degree, ApplicationStage stage, String? department, String? researchArea, String? country, String? programmeUrl, String? portalUrl, String? portalUsername, String? fundingUrl, Deadline? deadline, Deadline? fundingDeadline, ApplicationOutcome? outcome, double? feeAmount, String? feeCurrency, FeeWaiver feeWaiver, int priority, int requirementsDone, int requirementsTotal, int lettersSubmitted, int lettersTotal, String? notes
});




}
/// @nodoc
class __$ApplicationCopyWithImpl<$Res>
    implements _$ApplicationCopyWith<$Res> {
  __$ApplicationCopyWithImpl(this._self, this._then);

  final _Application _self;
  final $Res Function(_Application) _then;

/// Create a copy of Application
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? institutionId = null,Object? institutionName = null,Object? programmeName = null,Object? degree = null,Object? stage = null,Object? department = freezed,Object? researchArea = freezed,Object? country = freezed,Object? programmeUrl = freezed,Object? portalUrl = freezed,Object? portalUsername = freezed,Object? fundingUrl = freezed,Object? deadline = freezed,Object? fundingDeadline = freezed,Object? outcome = freezed,Object? feeAmount = freezed,Object? feeCurrency = freezed,Object? feeWaiver = null,Object? priority = null,Object? requirementsDone = null,Object? requirementsTotal = null,Object? lettersSubmitted = null,Object? lettersTotal = null,Object? notes = freezed,}) {
  return _then(_Application(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,institutionId: null == institutionId ? _self.institutionId : institutionId // ignore: cast_nullable_to_non_nullable
as String,institutionName: null == institutionName ? _self.institutionName : institutionName // ignore: cast_nullable_to_non_nullable
as String,programmeName: null == programmeName ? _self.programmeName : programmeName // ignore: cast_nullable_to_non_nullable
as String,degree: null == degree ? _self.degree : degree // ignore: cast_nullable_to_non_nullable
as DegreeType,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as ApplicationStage,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,researchArea: freezed == researchArea ? _self.researchArea : researchArea // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,programmeUrl: freezed == programmeUrl ? _self.programmeUrl : programmeUrl // ignore: cast_nullable_to_non_nullable
as String?,portalUrl: freezed == portalUrl ? _self.portalUrl : portalUrl // ignore: cast_nullable_to_non_nullable
as String?,portalUsername: freezed == portalUsername ? _self.portalUsername : portalUsername // ignore: cast_nullable_to_non_nullable
as String?,fundingUrl: freezed == fundingUrl ? _self.fundingUrl : fundingUrl // ignore: cast_nullable_to_non_nullable
as String?,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as Deadline?,fundingDeadline: freezed == fundingDeadline ? _self.fundingDeadline : fundingDeadline // ignore: cast_nullable_to_non_nullable
as Deadline?,outcome: freezed == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as ApplicationOutcome?,feeAmount: freezed == feeAmount ? _self.feeAmount : feeAmount // ignore: cast_nullable_to_non_nullable
as double?,feeCurrency: freezed == feeCurrency ? _self.feeCurrency : feeCurrency // ignore: cast_nullable_to_non_nullable
as String?,feeWaiver: null == feeWaiver ? _self.feeWaiver : feeWaiver // ignore: cast_nullable_to_non_nullable
as FeeWaiver,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,requirementsDone: null == requirementsDone ? _self.requirementsDone : requirementsDone // ignore: cast_nullable_to_non_nullable
as int,requirementsTotal: null == requirementsTotal ? _self.requirementsTotal : requirementsTotal // ignore: cast_nullable_to_non_nullable
as int,lettersSubmitted: null == lettersSubmitted ? _self.lettersSubmitted : lettersSubmitted // ignore: cast_nullable_to_non_nullable
as int,lettersTotal: null == lettersTotal ? _self.lettersTotal : lettersTotal // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
