// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attention_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AttentionItem {

 AttentionType get type; String get itemId; String get title; String get reason; DateTime get dueAt; int get score; String? get applicationId; String? get professorId; String? get context; String? get dueZone;
/// Create a copy of AttentionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttentionItemCopyWith<AttentionItem> get copyWith => _$AttentionItemCopyWithImpl<AttentionItem>(this as AttentionItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AttentionItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttentionItem&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.itemId, _this.itemId) || other.itemId == _this.itemId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.dueAt, _this.dueAt) || other.dueAt == _this.dueAt)&&(identical(other.score, _this.score) || other.score == _this.score)&&(identical(other.applicationId, _this.applicationId) || other.applicationId == _this.applicationId)&&(identical(other.professorId, _this.professorId) || other.professorId == _this.professorId)&&(identical(other.context, _this.context) || other.context == _this.context)&&(identical(other.dueZone, _this.dueZone) || other.dueZone == _this.dueZone));
}


@override
int get hashCode {
  final _this = this as AttentionItem;
  return Object.hash(runtimeType,_this.type,_this.itemId,_this.title,_this.reason,_this.dueAt,_this.score,_this.applicationId,_this.professorId,_this.context,_this.dueZone);
}

@override
String toString() {
  final _this = this as AttentionItem;
  return 'AttentionItem(type: ${_this.type}, itemId: ${_this.itemId}, title: ${_this.title}, reason: ${_this.reason}, dueAt: ${_this.dueAt}, score: ${_this.score}, applicationId: ${_this.applicationId}, professorId: ${_this.professorId}, context: ${_this.context}, dueZone: ${_this.dueZone})';
}


}

/// @nodoc
abstract mixin class $AttentionItemCopyWith<$Res>  {
  factory $AttentionItemCopyWith(AttentionItem value, $Res Function(AttentionItem) _then) = _$AttentionItemCopyWithImpl;
@useResult
$Res call({
 AttentionType type, String itemId, String title, String reason, DateTime dueAt, int score, String? applicationId, String? professorId, String? context, String? dueZone
});




}
/// @nodoc
class _$AttentionItemCopyWithImpl<$Res>
    implements $AttentionItemCopyWith<$Res> {
  _$AttentionItemCopyWithImpl(this._self, this._then);

  final AttentionItem _self;
  final $Res Function(AttentionItem) _then;

/// Create a copy of AttentionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? itemId = null,Object? title = null,Object? reason = null,Object? dueAt = null,Object? score = null,Object? applicationId = freezed,Object? professorId = freezed,Object? context = freezed,Object? dueZone = freezed,}) {
  return _then(AttentionItem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AttentionType,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,dueAt: null == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,applicationId: freezed == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String?,professorId: freezed == professorId ? _self.professorId : professorId // ignore: cast_nullable_to_non_nullable
as String?,context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String?,dueZone: freezed == dueZone ? _self.dueZone : dueZone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttentionItem].
extension AttentionItemPatterns on AttentionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttentionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttentionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttentionItem value)  $default,){
final _that = this;
switch (_that) {
case _AttentionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttentionItem value)?  $default,){
final _that = this;
switch (_that) {
case _AttentionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AttentionType type,  String itemId,  String title,  String reason,  DateTime dueAt,  int score,  String? applicationId,  String? professorId,  String? context,  String? dueZone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttentionItem() when $default != null:
return $default(_that.type,_that.itemId,_that.title,_that.reason,_that.dueAt,_that.score,_that.applicationId,_that.professorId,_that.context,_that.dueZone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AttentionType type,  String itemId,  String title,  String reason,  DateTime dueAt,  int score,  String? applicationId,  String? professorId,  String? context,  String? dueZone)  $default,) {final _that = this;
switch (_that) {
case _AttentionItem():
return $default(_that.type,_that.itemId,_that.title,_that.reason,_that.dueAt,_that.score,_that.applicationId,_that.professorId,_that.context,_that.dueZone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AttentionType type,  String itemId,  String title,  String reason,  DateTime dueAt,  int score,  String? applicationId,  String? professorId,  String? context,  String? dueZone)?  $default,) {final _that = this;
switch (_that) {
case _AttentionItem() when $default != null:
return $default(_that.type,_that.itemId,_that.title,_that.reason,_that.dueAt,_that.score,_that.applicationId,_that.professorId,_that.context,_that.dueZone);case _:
  return null;

}
}

}

/// @nodoc


class _AttentionItem implements AttentionItem {
  const _AttentionItem({required this.type, required this.itemId, required this.title, required this.reason, required this.dueAt, required this.score, this.applicationId, this.professorId, this.context, this.dueZone});
  

@override final  AttentionType type;
@override final  String itemId;
@override final  String title;
@override final  String reason;
@override final  DateTime dueAt;
@override final  int score;
@override final  String? applicationId;
@override final  String? professorId;
@override final  String? context;
@override final  String? dueZone;

/// Create a copy of AttentionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttentionItemCopyWith<_AttentionItem> get copyWith => __$AttentionItemCopyWithImpl<_AttentionItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttentionItem&&(identical(other.type, type) || other.type == type)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.title, title) || other.title == title)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.score, score) || other.score == score)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.professorId, professorId) || other.professorId == professorId)&&(identical(other.context, context) || other.context == context)&&(identical(other.dueZone, dueZone) || other.dueZone == dueZone));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,itemId,title,reason,dueAt,score,applicationId,professorId,context,dueZone);
}

@override
String toString() {
    return 'AttentionItem(type: $type, itemId: $itemId, title: $title, reason: $reason, dueAt: $dueAt, score: $score, applicationId: $applicationId, professorId: $professorId, context: $context, dueZone: $dueZone)';
}


}

/// @nodoc
abstract mixin class _$AttentionItemCopyWith<$Res> implements $AttentionItemCopyWith<$Res> {
  factory _$AttentionItemCopyWith(_AttentionItem value, $Res Function(_AttentionItem) _then) = __$AttentionItemCopyWithImpl;
@override @useResult
$Res call({
 AttentionType type, String itemId, String title, String reason, DateTime dueAt, int score, String? applicationId, String? professorId, String? context, String? dueZone
});




}
/// @nodoc
class __$AttentionItemCopyWithImpl<$Res>
    implements _$AttentionItemCopyWith<$Res> {
  __$AttentionItemCopyWithImpl(this._self, this._then);

  final _AttentionItem _self;
  final $Res Function(_AttentionItem) _then;

/// Create a copy of AttentionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? itemId = null,Object? title = null,Object? reason = null,Object? dueAt = null,Object? score = null,Object? applicationId = freezed,Object? professorId = freezed,Object? context = freezed,Object? dueZone = freezed,}) {
  return _then(_AttentionItem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AttentionType,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,dueAt: null == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,applicationId: freezed == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String?,professorId: freezed == professorId ? _self.professorId : professorId // ignore: cast_nullable_to_non_nullable
as String?,context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String?,dueZone: freezed == dueZone ? _self.dueZone : dueZone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
