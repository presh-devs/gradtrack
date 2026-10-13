// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'application_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeadlineInput {

 DateTime? get date; int get hour; int get minute; String? get zone;
/// Create a copy of DeadlineInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeadlineInputCopyWith<DeadlineInput> get copyWith => _$DeadlineInputCopyWithImpl<DeadlineInput>(this as DeadlineInput, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeadlineInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeadlineInput&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.hour, _this.hour) || other.hour == _this.hour)&&(identical(other.minute, _this.minute) || other.minute == _this.minute)&&(identical(other.zone, _this.zone) || other.zone == _this.zone));
}


@override
int get hashCode {
  final _this = this as DeadlineInput;
  return Object.hash(runtimeType,_this.date,_this.hour,_this.minute,_this.zone);
}

@override
String toString() {
  final _this = this as DeadlineInput;
  return 'DeadlineInput(date: ${_this.date}, hour: ${_this.hour}, minute: ${_this.minute}, zone: ${_this.zone})';
}


}

/// @nodoc
abstract mixin class $DeadlineInputCopyWith<$Res>  {
  factory $DeadlineInputCopyWith(DeadlineInput value, $Res Function(DeadlineInput) _then) = _$DeadlineInputCopyWithImpl;
@useResult
$Res call({
 DateTime? date, int hour, int minute, String? zone
});




}
/// @nodoc
class _$DeadlineInputCopyWithImpl<$Res>
    implements $DeadlineInputCopyWith<$Res> {
  _$DeadlineInputCopyWithImpl(this._self, this._then);

  final DeadlineInput _self;
  final $Res Function(DeadlineInput) _then;

/// Create a copy of DeadlineInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = freezed,Object? hour = null,Object? minute = null,Object? zone = freezed,}) {
  return _then(DeadlineInput(
date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeadlineInput].
extension DeadlineInputPatterns on DeadlineInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeadlineInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeadlineInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeadlineInput value)  $default,){
final _that = this;
switch (_that) {
case _DeadlineInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeadlineInput value)?  $default,){
final _that = this;
switch (_that) {
case _DeadlineInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? date,  int hour,  int minute,  String? zone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeadlineInput() when $default != null:
return $default(_that.date,_that.hour,_that.minute,_that.zone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? date,  int hour,  int minute,  String? zone)  $default,) {final _that = this;
switch (_that) {
case _DeadlineInput():
return $default(_that.date,_that.hour,_that.minute,_that.zone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? date,  int hour,  int minute,  String? zone)?  $default,) {final _that = this;
switch (_that) {
case _DeadlineInput() when $default != null:
return $default(_that.date,_that.hour,_that.minute,_that.zone);case _:
  return null;

}
}

}

/// @nodoc


class _DeadlineInput extends DeadlineInput {
  const _DeadlineInput({this.date, this.hour = 23, this.minute = 59, this.zone}): super._();
  

@override final  DateTime? date;
@override@JsonKey() final  int hour;
@override@JsonKey() final  int minute;
@override final  String? zone;

/// Create a copy of DeadlineInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeadlineInputCopyWith<_DeadlineInput> get copyWith => __$DeadlineInputCopyWithImpl<_DeadlineInput>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeadlineInput&&(identical(other.date, date) || other.date == date)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.zone, zone) || other.zone == zone));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,hour,minute,zone);
}

@override
String toString() {
    return 'DeadlineInput(date: $date, hour: $hour, minute: $minute, zone: $zone)';
}


}

/// @nodoc
abstract mixin class _$DeadlineInputCopyWith<$Res> implements $DeadlineInputCopyWith<$Res> {
  factory _$DeadlineInputCopyWith(_DeadlineInput value, $Res Function(_DeadlineInput) _then) = __$DeadlineInputCopyWithImpl;
@override @useResult
$Res call({
 DateTime? date, int hour, int minute, String? zone
});




}
/// @nodoc
class __$DeadlineInputCopyWithImpl<$Res>
    implements _$DeadlineInputCopyWith<$Res> {
  __$DeadlineInputCopyWithImpl(this._self, this._then);

  final _DeadlineInput _self;
  final $Res Function(_DeadlineInput) _then;

/// Create a copy of DeadlineInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = freezed,Object? hour = null,Object? minute = null,Object? zone = freezed,}) {
  return _then(_DeadlineInput(
date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ApplicationDraft {

/// Existing institution, or null to create one named [institutionName].
 String? get institutionId; String get institutionName; String? get institutionCountry; String get programmeName; DegreeType get degree; ApplicationStage get stage; int get priority; DeadlineInput get deadline; DeadlineInput get fundingDeadline; String? get department; String? get researchArea; String? get programmeUrl; String? get portalUrl; String? get portalUsername; String? get fundingUrl; String? get feeAmount; String? get feeCurrency; FeeWaiver get feeWaiver; String? get notes;
/// Create a copy of ApplicationDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplicationDraftCopyWith<ApplicationDraft> get copyWith => _$ApplicationDraftCopyWithImpl<ApplicationDraft>(this as ApplicationDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ApplicationDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplicationDraft&&(identical(other.institutionId, _this.institutionId) || other.institutionId == _this.institutionId)&&(identical(other.institutionName, _this.institutionName) || other.institutionName == _this.institutionName)&&(identical(other.institutionCountry, _this.institutionCountry) || other.institutionCountry == _this.institutionCountry)&&(identical(other.programmeName, _this.programmeName) || other.programmeName == _this.programmeName)&&(identical(other.degree, _this.degree) || other.degree == _this.degree)&&(identical(other.stage, _this.stage) || other.stage == _this.stage)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.deadline, _this.deadline) || other.deadline == _this.deadline)&&(identical(other.fundingDeadline, _this.fundingDeadline) || other.fundingDeadline == _this.fundingDeadline)&&(identical(other.department, _this.department) || other.department == _this.department)&&(identical(other.researchArea, _this.researchArea) || other.researchArea == _this.researchArea)&&(identical(other.programmeUrl, _this.programmeUrl) || other.programmeUrl == _this.programmeUrl)&&(identical(other.portalUrl, _this.portalUrl) || other.portalUrl == _this.portalUrl)&&(identical(other.portalUsername, _this.portalUsername) || other.portalUsername == _this.portalUsername)&&(identical(other.fundingUrl, _this.fundingUrl) || other.fundingUrl == _this.fundingUrl)&&(identical(other.feeAmount, _this.feeAmount) || other.feeAmount == _this.feeAmount)&&(identical(other.feeCurrency, _this.feeCurrency) || other.feeCurrency == _this.feeCurrency)&&(identical(other.feeWaiver, _this.feeWaiver) || other.feeWaiver == _this.feeWaiver)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}


@override
int get hashCode {
  final _this = this as ApplicationDraft;
  return Object.hashAll([runtimeType,_this.institutionId,_this.institutionName,_this.institutionCountry,_this.programmeName,_this.degree,_this.stage,_this.priority,_this.deadline,_this.fundingDeadline,_this.department,_this.researchArea,_this.programmeUrl,_this.portalUrl,_this.portalUsername,_this.fundingUrl,_this.feeAmount,_this.feeCurrency,_this.feeWaiver,_this.notes]);
}

@override
String toString() {
  final _this = this as ApplicationDraft;
  return 'ApplicationDraft(institutionId: ${_this.institutionId}, institutionName: ${_this.institutionName}, institutionCountry: ${_this.institutionCountry}, programmeName: ${_this.programmeName}, degree: ${_this.degree}, stage: ${_this.stage}, priority: ${_this.priority}, deadline: ${_this.deadline}, fundingDeadline: ${_this.fundingDeadline}, department: ${_this.department}, researchArea: ${_this.researchArea}, programmeUrl: ${_this.programmeUrl}, portalUrl: ${_this.portalUrl}, portalUsername: ${_this.portalUsername}, fundingUrl: ${_this.fundingUrl}, feeAmount: ${_this.feeAmount}, feeCurrency: ${_this.feeCurrency}, feeWaiver: ${_this.feeWaiver}, notes: ${_this.notes})';
}


}

/// @nodoc
abstract mixin class $ApplicationDraftCopyWith<$Res>  {
  factory $ApplicationDraftCopyWith(ApplicationDraft value, $Res Function(ApplicationDraft) _then) = _$ApplicationDraftCopyWithImpl;
@useResult
$Res call({
 String? institutionId, String institutionName, String? institutionCountry, String programmeName, DegreeType degree, ApplicationStage stage, int priority, DeadlineInput deadline, DeadlineInput fundingDeadline, String? department, String? researchArea, String? programmeUrl, String? portalUrl, String? portalUsername, String? fundingUrl, String? feeAmount, String? feeCurrency, FeeWaiver feeWaiver, String? notes
});


$DeadlineInputCopyWith<$Res> get deadline;$DeadlineInputCopyWith<$Res> get fundingDeadline;

}
/// @nodoc
class _$ApplicationDraftCopyWithImpl<$Res>
    implements $ApplicationDraftCopyWith<$Res> {
  _$ApplicationDraftCopyWithImpl(this._self, this._then);

  final ApplicationDraft _self;
  final $Res Function(ApplicationDraft) _then;

/// Create a copy of ApplicationDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? institutionId = freezed,Object? institutionName = null,Object? institutionCountry = freezed,Object? programmeName = null,Object? degree = null,Object? stage = null,Object? priority = null,Object? deadline = null,Object? fundingDeadline = null,Object? department = freezed,Object? researchArea = freezed,Object? programmeUrl = freezed,Object? portalUrl = freezed,Object? portalUsername = freezed,Object? fundingUrl = freezed,Object? feeAmount = freezed,Object? feeCurrency = freezed,Object? feeWaiver = null,Object? notes = freezed,}) {
  return _then(ApplicationDraft(
institutionId: freezed == institutionId ? _self.institutionId : institutionId // ignore: cast_nullable_to_non_nullable
as String?,institutionName: null == institutionName ? _self.institutionName : institutionName // ignore: cast_nullable_to_non_nullable
as String,institutionCountry: freezed == institutionCountry ? _self.institutionCountry : institutionCountry // ignore: cast_nullable_to_non_nullable
as String?,programmeName: null == programmeName ? _self.programmeName : programmeName // ignore: cast_nullable_to_non_nullable
as String,degree: null == degree ? _self.degree : degree // ignore: cast_nullable_to_non_nullable
as DegreeType,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as ApplicationStage,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DeadlineInput,fundingDeadline: null == fundingDeadline ? _self.fundingDeadline : fundingDeadline // ignore: cast_nullable_to_non_nullable
as DeadlineInput,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,researchArea: freezed == researchArea ? _self.researchArea : researchArea // ignore: cast_nullable_to_non_nullable
as String?,programmeUrl: freezed == programmeUrl ? _self.programmeUrl : programmeUrl // ignore: cast_nullable_to_non_nullable
as String?,portalUrl: freezed == portalUrl ? _self.portalUrl : portalUrl // ignore: cast_nullable_to_non_nullable
as String?,portalUsername: freezed == portalUsername ? _self.portalUsername : portalUsername // ignore: cast_nullable_to_non_nullable
as String?,fundingUrl: freezed == fundingUrl ? _self.fundingUrl : fundingUrl // ignore: cast_nullable_to_non_nullable
as String?,feeAmount: freezed == feeAmount ? _self.feeAmount : feeAmount // ignore: cast_nullable_to_non_nullable
as String?,feeCurrency: freezed == feeCurrency ? _self.feeCurrency : feeCurrency // ignore: cast_nullable_to_non_nullable
as String?,feeWaiver: null == feeWaiver ? _self.feeWaiver : feeWaiver // ignore: cast_nullable_to_non_nullable
as FeeWaiver,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ApplicationDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeadlineInputCopyWith<$Res> get deadline {
  
  return $DeadlineInputCopyWith<$Res>(_self.deadline, (value) {
    return _then(_self.copyWith(deadline: value));
  });
}/// Create a copy of ApplicationDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeadlineInputCopyWith<$Res> get fundingDeadline {
  
  return $DeadlineInputCopyWith<$Res>(_self.fundingDeadline, (value) {
    return _then(_self.copyWith(fundingDeadline: value));
  });
}
}


/// Adds pattern-matching-related methods to [ApplicationDraft].
extension ApplicationDraftPatterns on ApplicationDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApplicationDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApplicationDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApplicationDraft value)  $default,){
final _that = this;
switch (_that) {
case _ApplicationDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApplicationDraft value)?  $default,){
final _that = this;
switch (_that) {
case _ApplicationDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? institutionId,  String institutionName,  String? institutionCountry,  String programmeName,  DegreeType degree,  ApplicationStage stage,  int priority,  DeadlineInput deadline,  DeadlineInput fundingDeadline,  String? department,  String? researchArea,  String? programmeUrl,  String? portalUrl,  String? portalUsername,  String? fundingUrl,  String? feeAmount,  String? feeCurrency,  FeeWaiver feeWaiver,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApplicationDraft() when $default != null:
return $default(_that.institutionId,_that.institutionName,_that.institutionCountry,_that.programmeName,_that.degree,_that.stage,_that.priority,_that.deadline,_that.fundingDeadline,_that.department,_that.researchArea,_that.programmeUrl,_that.portalUrl,_that.portalUsername,_that.fundingUrl,_that.feeAmount,_that.feeCurrency,_that.feeWaiver,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? institutionId,  String institutionName,  String? institutionCountry,  String programmeName,  DegreeType degree,  ApplicationStage stage,  int priority,  DeadlineInput deadline,  DeadlineInput fundingDeadline,  String? department,  String? researchArea,  String? programmeUrl,  String? portalUrl,  String? portalUsername,  String? fundingUrl,  String? feeAmount,  String? feeCurrency,  FeeWaiver feeWaiver,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _ApplicationDraft():
return $default(_that.institutionId,_that.institutionName,_that.institutionCountry,_that.programmeName,_that.degree,_that.stage,_that.priority,_that.deadline,_that.fundingDeadline,_that.department,_that.researchArea,_that.programmeUrl,_that.portalUrl,_that.portalUsername,_that.fundingUrl,_that.feeAmount,_that.feeCurrency,_that.feeWaiver,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? institutionId,  String institutionName,  String? institutionCountry,  String programmeName,  DegreeType degree,  ApplicationStage stage,  int priority,  DeadlineInput deadline,  DeadlineInput fundingDeadline,  String? department,  String? researchArea,  String? programmeUrl,  String? portalUrl,  String? portalUsername,  String? fundingUrl,  String? feeAmount,  String? feeCurrency,  FeeWaiver feeWaiver,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _ApplicationDraft() when $default != null:
return $default(_that.institutionId,_that.institutionName,_that.institutionCountry,_that.programmeName,_that.degree,_that.stage,_that.priority,_that.deadline,_that.fundingDeadline,_that.department,_that.researchArea,_that.programmeUrl,_that.portalUrl,_that.portalUsername,_that.fundingUrl,_that.feeAmount,_that.feeCurrency,_that.feeWaiver,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _ApplicationDraft extends ApplicationDraft {
  const _ApplicationDraft({this.institutionId, this.institutionName = '', this.institutionCountry, this.programmeName = '', this.degree = DegreeType.phd, this.stage = ApplicationStage.researching, this.priority = 2, this.deadline = const DeadlineInput(), this.fundingDeadline = const DeadlineInput(), this.department, this.researchArea, this.programmeUrl, this.portalUrl, this.portalUsername, this.fundingUrl, this.feeAmount, this.feeCurrency, this.feeWaiver = FeeWaiver.none, this.notes}): super._();
  

/// Existing institution, or null to create one named [institutionName].
@override final  String? institutionId;
@override@JsonKey() final  String institutionName;
@override final  String? institutionCountry;
@override@JsonKey() final  String programmeName;
@override@JsonKey() final  DegreeType degree;
@override@JsonKey() final  ApplicationStage stage;
@override@JsonKey() final  int priority;
@override@JsonKey() final  DeadlineInput deadline;
@override@JsonKey() final  DeadlineInput fundingDeadline;
@override final  String? department;
@override final  String? researchArea;
@override final  String? programmeUrl;
@override final  String? portalUrl;
@override final  String? portalUsername;
@override final  String? fundingUrl;
@override final  String? feeAmount;
@override final  String? feeCurrency;
@override@JsonKey() final  FeeWaiver feeWaiver;
@override final  String? notes;

/// Create a copy of ApplicationDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApplicationDraftCopyWith<_ApplicationDraft> get copyWith => __$ApplicationDraftCopyWithImpl<_ApplicationDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApplicationDraft&&(identical(other.institutionId, institutionId) || other.institutionId == institutionId)&&(identical(other.institutionName, institutionName) || other.institutionName == institutionName)&&(identical(other.institutionCountry, institutionCountry) || other.institutionCountry == institutionCountry)&&(identical(other.programmeName, programmeName) || other.programmeName == programmeName)&&(identical(other.degree, degree) || other.degree == degree)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.fundingDeadline, fundingDeadline) || other.fundingDeadline == fundingDeadline)&&(identical(other.department, department) || other.department == department)&&(identical(other.researchArea, researchArea) || other.researchArea == researchArea)&&(identical(other.programmeUrl, programmeUrl) || other.programmeUrl == programmeUrl)&&(identical(other.portalUrl, portalUrl) || other.portalUrl == portalUrl)&&(identical(other.portalUsername, portalUsername) || other.portalUsername == portalUsername)&&(identical(other.fundingUrl, fundingUrl) || other.fundingUrl == fundingUrl)&&(identical(other.feeAmount, feeAmount) || other.feeAmount == feeAmount)&&(identical(other.feeCurrency, feeCurrency) || other.feeCurrency == feeCurrency)&&(identical(other.feeWaiver, feeWaiver) || other.feeWaiver == feeWaiver)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,institutionId,institutionName,institutionCountry,programmeName,degree,stage,priority,deadline,fundingDeadline,department,researchArea,programmeUrl,portalUrl,portalUsername,fundingUrl,feeAmount,feeCurrency,feeWaiver,notes]);
}

@override
String toString() {
    return 'ApplicationDraft(institutionId: $institutionId, institutionName: $institutionName, institutionCountry: $institutionCountry, programmeName: $programmeName, degree: $degree, stage: $stage, priority: $priority, deadline: $deadline, fundingDeadline: $fundingDeadline, department: $department, researchArea: $researchArea, programmeUrl: $programmeUrl, portalUrl: $portalUrl, portalUsername: $portalUsername, fundingUrl: $fundingUrl, feeAmount: $feeAmount, feeCurrency: $feeCurrency, feeWaiver: $feeWaiver, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$ApplicationDraftCopyWith<$Res> implements $ApplicationDraftCopyWith<$Res> {
  factory _$ApplicationDraftCopyWith(_ApplicationDraft value, $Res Function(_ApplicationDraft) _then) = __$ApplicationDraftCopyWithImpl;
@override @useResult
$Res call({
 String? institutionId, String institutionName, String? institutionCountry, String programmeName, DegreeType degree, ApplicationStage stage, int priority, DeadlineInput deadline, DeadlineInput fundingDeadline, String? department, String? researchArea, String? programmeUrl, String? portalUrl, String? portalUsername, String? fundingUrl, String? feeAmount, String? feeCurrency, FeeWaiver feeWaiver, String? notes
});


@override $DeadlineInputCopyWith<$Res> get deadline;@override $DeadlineInputCopyWith<$Res> get fundingDeadline;

}
/// @nodoc
class __$ApplicationDraftCopyWithImpl<$Res>
    implements _$ApplicationDraftCopyWith<$Res> {
  __$ApplicationDraftCopyWithImpl(this._self, this._then);

  final _ApplicationDraft _self;
  final $Res Function(_ApplicationDraft) _then;

/// Create a copy of ApplicationDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? institutionId = freezed,Object? institutionName = null,Object? institutionCountry = freezed,Object? programmeName = null,Object? degree = null,Object? stage = null,Object? priority = null,Object? deadline = null,Object? fundingDeadline = null,Object? department = freezed,Object? researchArea = freezed,Object? programmeUrl = freezed,Object? portalUrl = freezed,Object? portalUsername = freezed,Object? fundingUrl = freezed,Object? feeAmount = freezed,Object? feeCurrency = freezed,Object? feeWaiver = null,Object? notes = freezed,}) {
  return _then(_ApplicationDraft(
institutionId: freezed == institutionId ? _self.institutionId : institutionId // ignore: cast_nullable_to_non_nullable
as String?,institutionName: null == institutionName ? _self.institutionName : institutionName // ignore: cast_nullable_to_non_nullable
as String,institutionCountry: freezed == institutionCountry ? _self.institutionCountry : institutionCountry // ignore: cast_nullable_to_non_nullable
as String?,programmeName: null == programmeName ? _self.programmeName : programmeName // ignore: cast_nullable_to_non_nullable
as String,degree: null == degree ? _self.degree : degree // ignore: cast_nullable_to_non_nullable
as DegreeType,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as ApplicationStage,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DeadlineInput,fundingDeadline: null == fundingDeadline ? _self.fundingDeadline : fundingDeadline // ignore: cast_nullable_to_non_nullable
as DeadlineInput,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,researchArea: freezed == researchArea ? _self.researchArea : researchArea // ignore: cast_nullable_to_non_nullable
as String?,programmeUrl: freezed == programmeUrl ? _self.programmeUrl : programmeUrl // ignore: cast_nullable_to_non_nullable
as String?,portalUrl: freezed == portalUrl ? _self.portalUrl : portalUrl // ignore: cast_nullable_to_non_nullable
as String?,portalUsername: freezed == portalUsername ? _self.portalUsername : portalUsername // ignore: cast_nullable_to_non_nullable
as String?,fundingUrl: freezed == fundingUrl ? _self.fundingUrl : fundingUrl // ignore: cast_nullable_to_non_nullable
as String?,feeAmount: freezed == feeAmount ? _self.feeAmount : feeAmount // ignore: cast_nullable_to_non_nullable
as String?,feeCurrency: freezed == feeCurrency ? _self.feeCurrency : feeCurrency // ignore: cast_nullable_to_non_nullable
as String?,feeWaiver: null == feeWaiver ? _self.feeWaiver : feeWaiver // ignore: cast_nullable_to_non_nullable
as FeeWaiver,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ApplicationDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeadlineInputCopyWith<$Res> get deadline {
  
  return $DeadlineInputCopyWith<$Res>(_self.deadline, (value) {
    return _then(_self.copyWith(deadline: value));
  });
}/// Create a copy of ApplicationDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeadlineInputCopyWith<$Res> get fundingDeadline {
  
  return $DeadlineInputCopyWith<$Res>(_self.fundingDeadline, (value) {
    return _then(_self.copyWith(fundingDeadline: value));
  });
}
}

// dart format on
