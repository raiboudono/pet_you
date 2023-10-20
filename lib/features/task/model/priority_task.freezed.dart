// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'priority_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PriorityTask _$PriorityTaskFromJson(Map<String, dynamic> json) {
  return _PriorityTask.fromJson(json);
}

/// @nodoc
mixin _$PriorityTask {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int? get categoryId => throw _privateConstructorUsedError;
  int? get taskId => throw _privateConstructorUsedError;
  int? get petId => throw _privateConstructorUsedError;
  int get executed => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  int get times => throw _privateConstructorUsedError;
  @Enumerated(EnumType.value, 'name')
  Status? get status => throw _privateConstructorUsedError;
  @enumerated
  Priority get priority => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PriorityTaskCopyWith<PriorityTask> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriorityTaskCopyWith<$Res> {
  factory $PriorityTaskCopyWith(
          PriorityTask value, $Res Function(PriorityTask) then) =
      _$PriorityTaskCopyWithImpl<$Res, PriorityTask>;
  @useResult
  $Res call(
      {int id,
      String name,
      int? categoryId,
      int? taskId,
      int? petId,
      int executed,
      String? memo,
      double progress,
      int times,
      @Enumerated(EnumType.value, 'name') Status? status,
      @enumerated Priority priority,
      DateTime? dueDate,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$PriorityTaskCopyWithImpl<$Res, $Val extends PriorityTask>
    implements $PriorityTaskCopyWith<$Res> {
  _$PriorityTaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? categoryId = freezed,
    Object? taskId = freezed,
    Object? petId = freezed,
    Object? executed = null,
    Object? memo = freezed,
    Object? progress = null,
    Object? times = null,
    Object? status = freezed,
    Object? priority = null,
    Object? dueDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      taskId: freezed == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int?,
      petId: freezed == petId
          ? _value.petId
          : petId // ignore: cast_nullable_to_non_nullable
              as int?,
      executed: null == executed
          ? _value.executed
          : executed // ignore: cast_nullable_to_non_nullable
              as int,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      times: null == times
          ? _value.times
          : times // ignore: cast_nullable_to_non_nullable
              as int,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as Status?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PriorityTaskCopyWith<$Res>
    implements $PriorityTaskCopyWith<$Res> {
  factory _$$_PriorityTaskCopyWith(
          _$_PriorityTask value, $Res Function(_$_PriorityTask) then) =
      __$$_PriorityTaskCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      int? categoryId,
      int? taskId,
      int? petId,
      int executed,
      String? memo,
      double progress,
      int times,
      @Enumerated(EnumType.value, 'name') Status? status,
      @enumerated Priority priority,
      DateTime? dueDate,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$_PriorityTaskCopyWithImpl<$Res>
    extends _$PriorityTaskCopyWithImpl<$Res, _$_PriorityTask>
    implements _$$_PriorityTaskCopyWith<$Res> {
  __$$_PriorityTaskCopyWithImpl(
      _$_PriorityTask _value, $Res Function(_$_PriorityTask) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? categoryId = freezed,
    Object? taskId = freezed,
    Object? petId = freezed,
    Object? executed = null,
    Object? memo = freezed,
    Object? progress = null,
    Object? times = null,
    Object? status = freezed,
    Object? priority = null,
    Object? dueDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$_PriorityTask(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      taskId: freezed == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int?,
      petId: freezed == petId
          ? _value.petId
          : petId // ignore: cast_nullable_to_non_nullable
              as int?,
      executed: null == executed
          ? _value.executed
          : executed // ignore: cast_nullable_to_non_nullable
              as int,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      times: null == times
          ? _value.times
          : times // ignore: cast_nullable_to_non_nullable
              as int,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as Status?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PriorityTask extends _PriorityTask {
  const _$_PriorityTask(
      {required this.id,
      required this.name,
      this.categoryId,
      this.taskId,
      this.petId,
      this.executed = 0,
      this.memo,
      this.progress = 0,
      this.times = 1,
      @Enumerated(EnumType.value, 'name') this.status,
      @enumerated this.priority = Priority.middle,
      this.dueDate,
      this.createdAt,
      this.updatedAt})
      : super._();

  factory _$_PriorityTask.fromJson(Map<String, dynamic> json) =>
      _$$_PriorityTaskFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final int? categoryId;
  @override
  final int? taskId;
  @override
  final int? petId;
  @override
  @JsonKey()
  final int executed;
  @override
  final String? memo;
  @override
  @JsonKey()
  final double progress;
  @override
  @JsonKey()
  final int times;
  @override
  @Enumerated(EnumType.value, 'name')
  final Status? status;
  @override
  @JsonKey()
  @enumerated
  final Priority priority;
  @override
  final DateTime? dueDate;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PriorityTask(id: $id, name: $name, categoryId: $categoryId, taskId: $taskId, petId: $petId, executed: $executed, memo: $memo, progress: $progress, times: $times, status: $status, priority: $priority, dueDate: $dueDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PriorityTask &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.petId, petId) || other.petId == petId) &&
            (identical(other.executed, executed) ||
                other.executed == executed) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.times, times) || other.times == times) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      categoryId,
      taskId,
      petId,
      executed,
      memo,
      progress,
      times,
      status,
      priority,
      dueDate,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PriorityTaskCopyWith<_$_PriorityTask> get copyWith =>
      __$$_PriorityTaskCopyWithImpl<_$_PriorityTask>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PriorityTaskToJson(
      this,
    );
  }
}

abstract class _PriorityTask extends PriorityTask {
  const factory _PriorityTask(
      {required final int id,
      required final String name,
      final int? categoryId,
      final int? taskId,
      final int? petId,
      final int executed,
      final String? memo,
      final double progress,
      final int times,
      @Enumerated(EnumType.value, 'name') final Status? status,
      @enumerated final Priority priority,
      final DateTime? dueDate,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$_PriorityTask;
  const _PriorityTask._() : super._();

  factory _PriorityTask.fromJson(Map<String, dynamic> json) =
      _$_PriorityTask.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  int? get categoryId;
  @override
  int? get taskId;
  @override
  int? get petId;
  @override
  int get executed;
  @override
  String? get memo;
  @override
  double get progress;
  @override
  int get times;
  @override
  @Enumerated(EnumType.value, 'name')
  Status? get status;
  @override
  @enumerated
  Priority get priority;
  @override
  DateTime? get dueDate;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$_PriorityTaskCopyWith<_$_PriorityTask> get copyWith =>
      throw _privateConstructorUsedError;
}
