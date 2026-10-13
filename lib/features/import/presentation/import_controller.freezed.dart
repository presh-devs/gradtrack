// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImportWizardState {

 String get defaultZone; ImportStep get step; String? get sourceName; CsvTable? get table; Map<int, ImportField> get mapping; DateOrder get dateOrder; bool get seedRequirements; String? get sourceError;
/// Create a copy of ImportWizardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportWizardStateCopyWith<ImportWizardState> get copyWith => _$ImportWizardStateCopyWithImpl<ImportWizardState>(this as ImportWizardState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ImportWizardState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportWizardState&&(identical(other.defaultZone, _this.defaultZone) || other.defaultZone == _this.defaultZone)&&(identical(other.step, _this.step) || other.step == _this.step)&&(identical(other.sourceName, _this.sourceName) || other.sourceName == _this.sourceName)&&(identical(other.table, _this.table) || other.table == _this.table)&&const DeepCollectionEquality().equals(other.mapping, _this.mapping)&&(identical(other.dateOrder, _this.dateOrder) || other.dateOrder == _this.dateOrder)&&(identical(other.seedRequirements, _this.seedRequirements) || other.seedRequirements == _this.seedRequirements)&&(identical(other.sourceError, _this.sourceError) || other.sourceError == _this.sourceError));
}


@override
int get hashCode {
  final _this = this as ImportWizardState;
  return Object.hash(runtimeType,_this.defaultZone,_this.step,_this.sourceName,_this.table,const DeepCollectionEquality().hash(_this.mapping),_this.dateOrder,_this.seedRequirements,_this.sourceError);
}

@override
String toString() {
  final _this = this as ImportWizardState;
  return 'ImportWizardState(defaultZone: ${_this.defaultZone}, step: ${_this.step}, sourceName: ${_this.sourceName}, table: ${_this.table}, mapping: ${_this.mapping}, dateOrder: ${_this.dateOrder}, seedRequirements: ${_this.seedRequirements}, sourceError: ${_this.sourceError})';
}


}

/// @nodoc
abstract mixin class $ImportWizardStateCopyWith<$Res>  {
  factory $ImportWizardStateCopyWith(ImportWizardState value, $Res Function(ImportWizardState) _then) = _$ImportWizardStateCopyWithImpl;
@useResult
$Res call({
 String defaultZone, ImportStep step, String? sourceName, CsvTable? table, Map<int, ImportField> mapping, DateOrder dateOrder, bool seedRequirements, String? sourceError
});




}
/// @nodoc
class _$ImportWizardStateCopyWithImpl<$Res>
    implements $ImportWizardStateCopyWith<$Res> {
  _$ImportWizardStateCopyWithImpl(this._self, this._then);

  final ImportWizardState _self;
  final $Res Function(ImportWizardState) _then;

/// Create a copy of ImportWizardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultZone = null,Object? step = null,Object? sourceName = freezed,Object? table = freezed,Object? mapping = null,Object? dateOrder = null,Object? seedRequirements = null,Object? sourceError = freezed,}) {
  return _then(ImportWizardState(
defaultZone: null == defaultZone ? _self.defaultZone : defaultZone // ignore: cast_nullable_to_non_nullable
as String,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as ImportStep,sourceName: freezed == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String?,table: freezed == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as CsvTable?,mapping: null == mapping ? _self.mapping : mapping // ignore: cast_nullable_to_non_nullable
as Map<int, ImportField>,dateOrder: null == dateOrder ? _self.dateOrder : dateOrder // ignore: cast_nullable_to_non_nullable
as DateOrder,seedRequirements: null == seedRequirements ? _self.seedRequirements : seedRequirements // ignore: cast_nullable_to_non_nullable
as bool,sourceError: freezed == sourceError ? _self.sourceError : sourceError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportWizardState].
extension ImportWizardStatePatterns on ImportWizardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportWizardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportWizardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportWizardState value)  $default,){
final _that = this;
switch (_that) {
case _ImportWizardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportWizardState value)?  $default,){
final _that = this;
switch (_that) {
case _ImportWizardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String defaultZone,  ImportStep step,  String? sourceName,  CsvTable? table,  Map<int, ImportField> mapping,  DateOrder dateOrder,  bool seedRequirements,  String? sourceError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportWizardState() when $default != null:
return $default(_that.defaultZone,_that.step,_that.sourceName,_that.table,_that.mapping,_that.dateOrder,_that.seedRequirements,_that.sourceError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String defaultZone,  ImportStep step,  String? sourceName,  CsvTable? table,  Map<int, ImportField> mapping,  DateOrder dateOrder,  bool seedRequirements,  String? sourceError)  $default,) {final _that = this;
switch (_that) {
case _ImportWizardState():
return $default(_that.defaultZone,_that.step,_that.sourceName,_that.table,_that.mapping,_that.dateOrder,_that.seedRequirements,_that.sourceError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String defaultZone,  ImportStep step,  String? sourceName,  CsvTable? table,  Map<int, ImportField> mapping,  DateOrder dateOrder,  bool seedRequirements,  String? sourceError)?  $default,) {final _that = this;
switch (_that) {
case _ImportWizardState() when $default != null:
return $default(_that.defaultZone,_that.step,_that.sourceName,_that.table,_that.mapping,_that.dateOrder,_that.seedRequirements,_that.sourceError);case _:
  return null;

}
}

}

/// @nodoc


class _ImportWizardState extends ImportWizardState {
  const _ImportWizardState({required this.defaultZone, this.step = ImportStep.source, this.sourceName, this.table,  Map<int, ImportField> mapping = const <int, ImportField>{}, this.dateOrder = DateOrder.dayFirst, this.seedRequirements = true, this.sourceError}): _mapping = mapping,super._();
  

@override final  String defaultZone;
@override@JsonKey() final  ImportStep step;
@override final  String? sourceName;
@override final  CsvTable? table;
 final  Map<int, ImportField> _mapping;
@override@JsonKey() Map<int, ImportField> get mapping {
  if (_mapping is EqualUnmodifiableMapView) return _mapping;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_mapping);
}

@override@JsonKey() final  DateOrder dateOrder;
@override@JsonKey() final  bool seedRequirements;
@override final  String? sourceError;

/// Create a copy of ImportWizardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportWizardStateCopyWith<_ImportWizardState> get copyWith => __$ImportWizardStateCopyWithImpl<_ImportWizardState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportWizardState&&(identical(other.defaultZone, defaultZone) || other.defaultZone == defaultZone)&&(identical(other.step, step) || other.step == step)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.table, table) || other.table == table)&&const DeepCollectionEquality().equals(other.mapping, _mapping)&&(identical(other.dateOrder, dateOrder) || other.dateOrder == dateOrder)&&(identical(other.seedRequirements, seedRequirements) || other.seedRequirements == seedRequirements)&&(identical(other.sourceError, sourceError) || other.sourceError == sourceError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,defaultZone,step,sourceName,table,const DeepCollectionEquality().hash(_mapping),dateOrder,seedRequirements,sourceError);
}

@override
String toString() {
    return 'ImportWizardState(defaultZone: $defaultZone, step: $step, sourceName: $sourceName, table: $table, mapping: $mapping, dateOrder: $dateOrder, seedRequirements: $seedRequirements, sourceError: $sourceError)';
}


}

/// @nodoc
abstract mixin class _$ImportWizardStateCopyWith<$Res> implements $ImportWizardStateCopyWith<$Res> {
  factory _$ImportWizardStateCopyWith(_ImportWizardState value, $Res Function(_ImportWizardState) _then) = __$ImportWizardStateCopyWithImpl;
@override @useResult
$Res call({
 String defaultZone, ImportStep step, String? sourceName, CsvTable? table, Map<int, ImportField> mapping, DateOrder dateOrder, bool seedRequirements, String? sourceError
});




}
/// @nodoc
class __$ImportWizardStateCopyWithImpl<$Res>
    implements _$ImportWizardStateCopyWith<$Res> {
  __$ImportWizardStateCopyWithImpl(this._self, this._then);

  final _ImportWizardState _self;
  final $Res Function(_ImportWizardState) _then;

/// Create a copy of ImportWizardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultZone = null,Object? step = null,Object? sourceName = freezed,Object? table = freezed,Object? mapping = null,Object? dateOrder = null,Object? seedRequirements = null,Object? sourceError = freezed,}) {
  return _then(_ImportWizardState(
defaultZone: null == defaultZone ? _self.defaultZone : defaultZone // ignore: cast_nullable_to_non_nullable
as String,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as ImportStep,sourceName: freezed == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String?,table: freezed == table ? _self.table : table // ignore: cast_nullable_to_non_nullable
as CsvTable?,mapping: null == mapping ? _self._mapping : mapping // ignore: cast_nullable_to_non_nullable
as Map<int, ImportField>,dateOrder: null == dateOrder ? _self.dateOrder : dateOrder // ignore: cast_nullable_to_non_nullable
as DateOrder,seedRequirements: null == seedRequirements ? _self.seedRequirements : seedRequirements // ignore: cast_nullable_to_non_nullable
as bool,sourceError: freezed == sourceError ? _self.sourceError : sourceError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
