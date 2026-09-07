// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExerciseSet {
  int get setNumber;
  int get targetReps;
  int? get actualReps;
  double get targetWeightKg;
  double? get actualWeightKg;
  bool get completed;

  /// Create a copy of ExerciseSet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExerciseSetCopyWith<ExerciseSet> get copyWith =>
      _$ExerciseSetCopyWithImpl<ExerciseSet>(this as ExerciseSet, _$identity);

  /// Serializes this ExerciseSet to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExerciseSet &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.targetReps, targetReps) ||
                other.targetReps == targetReps) &&
            (identical(other.actualReps, actualReps) ||
                other.actualReps == actualReps) &&
            (identical(other.targetWeightKg, targetWeightKg) ||
                other.targetWeightKg == targetWeightKg) &&
            (identical(other.actualWeightKg, actualWeightKg) ||
                other.actualWeightKg == actualWeightKg) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, setNumber, targetReps,
      actualReps, targetWeightKg, actualWeightKg, completed);

  @override
  String toString() {
    return 'ExerciseSet(setNumber: $setNumber, targetReps: $targetReps, actualReps: $actualReps, targetWeightKg: $targetWeightKg, actualWeightKg: $actualWeightKg, completed: $completed)';
  }
}

/// @nodoc
abstract mixin class $ExerciseSetCopyWith<$Res> {
  factory $ExerciseSetCopyWith(
          ExerciseSet value, $Res Function(ExerciseSet) _then) =
      _$ExerciseSetCopyWithImpl;
  @useResult
  $Res call(
      {int setNumber,
      int targetReps,
      int? actualReps,
      double targetWeightKg,
      double? actualWeightKg,
      bool completed});
}

/// @nodoc
class _$ExerciseSetCopyWithImpl<$Res> implements $ExerciseSetCopyWith<$Res> {
  _$ExerciseSetCopyWithImpl(this._self, this._then);

  final ExerciseSet _self;
  final $Res Function(ExerciseSet) _then;

  /// Create a copy of ExerciseSet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? setNumber = null,
    Object? targetReps = null,
    Object? actualReps = freezed,
    Object? targetWeightKg = null,
    Object? actualWeightKg = freezed,
    Object? completed = null,
  }) {
    return _then(_self.copyWith(
      setNumber: null == setNumber
          ? _self.setNumber
          : setNumber // ignore: cast_nullable_to_non_nullable
              as int,
      targetReps: null == targetReps
          ? _self.targetReps
          : targetReps // ignore: cast_nullable_to_non_nullable
              as int,
      actualReps: freezed == actualReps
          ? _self.actualReps
          : actualReps // ignore: cast_nullable_to_non_nullable
              as int?,
      targetWeightKg: null == targetWeightKg
          ? _self.targetWeightKg
          : targetWeightKg // ignore: cast_nullable_to_non_nullable
              as double,
      actualWeightKg: freezed == actualWeightKg
          ? _self.actualWeightKg
          : actualWeightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      completed: null == completed
          ? _self.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [ExerciseSet].
extension ExerciseSetPatterns on ExerciseSet {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ExerciseSet value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExerciseSet() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ExerciseSet value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseSet():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ExerciseSet value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseSet() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int setNumber, int targetReps, int? actualReps,
            double targetWeightKg, double? actualWeightKg, bool completed)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExerciseSet() when $default != null:
        return $default(_that.setNumber, _that.targetReps, _that.actualReps,
            _that.targetWeightKg, _that.actualWeightKg, _that.completed);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int setNumber, int targetReps, int? actualReps,
            double targetWeightKg, double? actualWeightKg, bool completed)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseSet():
        return $default(_that.setNumber, _that.targetReps, _that.actualReps,
            _that.targetWeightKg, _that.actualWeightKg, _that.completed);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int setNumber, int targetReps, int? actualReps,
            double targetWeightKg, double? actualWeightKg, bool completed)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseSet() when $default != null:
        return $default(_that.setNumber, _that.targetReps, _that.actualReps,
            _that.targetWeightKg, _that.actualWeightKg, _that.completed);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ExerciseSet extends ExerciseSet {
  const _ExerciseSet(
      {required this.setNumber,
      required this.targetReps,
      this.actualReps,
      required this.targetWeightKg,
      this.actualWeightKg,
      this.completed = false})
      : super._();
  factory _ExerciseSet.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetFromJson(json);

  @override
  final int setNumber;
  @override
  final int targetReps;
  @override
  final int? actualReps;
  @override
  final double targetWeightKg;
  @override
  final double? actualWeightKg;
  @override
  @JsonKey()
  final bool completed;

  /// Create a copy of ExerciseSet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExerciseSetCopyWith<_ExerciseSet> get copyWith =>
      __$ExerciseSetCopyWithImpl<_ExerciseSet>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExerciseSetToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExerciseSet &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.targetReps, targetReps) ||
                other.targetReps == targetReps) &&
            (identical(other.actualReps, actualReps) ||
                other.actualReps == actualReps) &&
            (identical(other.targetWeightKg, targetWeightKg) ||
                other.targetWeightKg == targetWeightKg) &&
            (identical(other.actualWeightKg, actualWeightKg) ||
                other.actualWeightKg == actualWeightKg) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, setNumber, targetReps,
      actualReps, targetWeightKg, actualWeightKg, completed);

  @override
  String toString() {
    return 'ExerciseSet(setNumber: $setNumber, targetReps: $targetReps, actualReps: $actualReps, targetWeightKg: $targetWeightKg, actualWeightKg: $actualWeightKg, completed: $completed)';
  }
}

/// @nodoc
abstract mixin class _$ExerciseSetCopyWith<$Res>
    implements $ExerciseSetCopyWith<$Res> {
  factory _$ExerciseSetCopyWith(
          _ExerciseSet value, $Res Function(_ExerciseSet) _then) =
      __$ExerciseSetCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int setNumber,
      int targetReps,
      int? actualReps,
      double targetWeightKg,
      double? actualWeightKg,
      bool completed});
}

/// @nodoc
class __$ExerciseSetCopyWithImpl<$Res> implements _$ExerciseSetCopyWith<$Res> {
  __$ExerciseSetCopyWithImpl(this._self, this._then);

  final _ExerciseSet _self;
  final $Res Function(_ExerciseSet) _then;

  /// Create a copy of ExerciseSet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? setNumber = null,
    Object? targetReps = null,
    Object? actualReps = freezed,
    Object? targetWeightKg = null,
    Object? actualWeightKg = freezed,
    Object? completed = null,
  }) {
    return _then(_ExerciseSet(
      setNumber: null == setNumber
          ? _self.setNumber
          : setNumber // ignore: cast_nullable_to_non_nullable
              as int,
      targetReps: null == targetReps
          ? _self.targetReps
          : targetReps // ignore: cast_nullable_to_non_nullable
              as int,
      actualReps: freezed == actualReps
          ? _self.actualReps
          : actualReps // ignore: cast_nullable_to_non_nullable
              as int?,
      targetWeightKg: null == targetWeightKg
          ? _self.targetWeightKg
          : targetWeightKg // ignore: cast_nullable_to_non_nullable
              as double,
      actualWeightKg: freezed == actualWeightKg
          ? _self.actualWeightKg
          : actualWeightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      completed: null == completed
          ? _self.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$Exercise {
  String get id;
  String get name;
  String get targetMuscle;
  String get equipmentRequired;
  List<ExerciseSet> get sets;
  String? get notes;
  String? get instructions;
  String? get videoUrl;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExerciseCopyWith<Exercise> get copyWith =>
      _$ExerciseCopyWithImpl<Exercise>(this as Exercise, _$identity);

  /// Serializes this Exercise to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Exercise &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.targetMuscle, targetMuscle) ||
                other.targetMuscle == targetMuscle) &&
            (identical(other.equipmentRequired, equipmentRequired) ||
                other.equipmentRequired == equipmentRequired) &&
            const DeepCollectionEquality().equals(other.sets, sets) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.instructions, instructions) ||
                other.instructions == instructions) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      targetMuscle,
      equipmentRequired,
      const DeepCollectionEquality().hash(sets),
      notes,
      instructions,
      videoUrl);

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, targetMuscle: $targetMuscle, equipmentRequired: $equipmentRequired, sets: $sets, notes: $notes, instructions: $instructions, videoUrl: $videoUrl)';
  }
}

/// @nodoc
abstract mixin class $ExerciseCopyWith<$Res> {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) _then) =
      _$ExerciseCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String targetMuscle,
      String equipmentRequired,
      List<ExerciseSet> sets,
      String? notes,
      String? instructions,
      String? videoUrl});
}

/// @nodoc
class _$ExerciseCopyWithImpl<$Res> implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._self, this._then);

  final Exercise _self;
  final $Res Function(Exercise) _then;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? targetMuscle = null,
    Object? equipmentRequired = null,
    Object? sets = null,
    Object? notes = freezed,
    Object? instructions = freezed,
    Object? videoUrl = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      targetMuscle: null == targetMuscle
          ? _self.targetMuscle
          : targetMuscle // ignore: cast_nullable_to_non_nullable
              as String,
      equipmentRequired: null == equipmentRequired
          ? _self.equipmentRequired
          : equipmentRequired // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _self.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSet>,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      instructions: freezed == instructions
          ? _self.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _self.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Exercise].
extension ExercisePatterns on Exercise {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Exercise value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Exercise() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Exercise value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Exercise():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Exercise value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Exercise() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String targetMuscle,
            String equipmentRequired,
            List<ExerciseSet> sets,
            String? notes,
            String? instructions,
            String? videoUrl)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Exercise() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.targetMuscle,
            _that.equipmentRequired,
            _that.sets,
            _that.notes,
            _that.instructions,
            _that.videoUrl);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String targetMuscle,
            String equipmentRequired,
            List<ExerciseSet> sets,
            String? notes,
            String? instructions,
            String? videoUrl)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Exercise():
        return $default(
            _that.id,
            _that.name,
            _that.targetMuscle,
            _that.equipmentRequired,
            _that.sets,
            _that.notes,
            _that.instructions,
            _that.videoUrl);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String name,
            String targetMuscle,
            String equipmentRequired,
            List<ExerciseSet> sets,
            String? notes,
            String? instructions,
            String? videoUrl)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Exercise() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.targetMuscle,
            _that.equipmentRequired,
            _that.sets,
            _that.notes,
            _that.instructions,
            _that.videoUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Exercise extends Exercise {
  const _Exercise(
      {required this.id,
      required this.name,
      required this.targetMuscle,
      required this.equipmentRequired,
      required final List<ExerciseSet> sets,
      this.notes,
      this.instructions,
      this.videoUrl})
      : _sets = sets,
        super._();
  factory _Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String targetMuscle;
  @override
  final String equipmentRequired;
  final List<ExerciseSet> _sets;
  @override
  List<ExerciseSet> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  @override
  final String? notes;
  @override
  final String? instructions;
  @override
  final String? videoUrl;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExerciseCopyWith<_Exercise> get copyWith =>
      __$ExerciseCopyWithImpl<_Exercise>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExerciseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Exercise &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.targetMuscle, targetMuscle) ||
                other.targetMuscle == targetMuscle) &&
            (identical(other.equipmentRequired, equipmentRequired) ||
                other.equipmentRequired == equipmentRequired) &&
            const DeepCollectionEquality().equals(other._sets, _sets) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.instructions, instructions) ||
                other.instructions == instructions) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      targetMuscle,
      equipmentRequired,
      const DeepCollectionEquality().hash(_sets),
      notes,
      instructions,
      videoUrl);

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, targetMuscle: $targetMuscle, equipmentRequired: $equipmentRequired, sets: $sets, notes: $notes, instructions: $instructions, videoUrl: $videoUrl)';
  }
}

/// @nodoc
abstract mixin class _$ExerciseCopyWith<$Res>
    implements $ExerciseCopyWith<$Res> {
  factory _$ExerciseCopyWith(_Exercise value, $Res Function(_Exercise) _then) =
      __$ExerciseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String targetMuscle,
      String equipmentRequired,
      List<ExerciseSet> sets,
      String? notes,
      String? instructions,
      String? videoUrl});
}

/// @nodoc
class __$ExerciseCopyWithImpl<$Res> implements _$ExerciseCopyWith<$Res> {
  __$ExerciseCopyWithImpl(this._self, this._then);

  final _Exercise _self;
  final $Res Function(_Exercise) _then;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? targetMuscle = null,
    Object? equipmentRequired = null,
    Object? sets = null,
    Object? notes = freezed,
    Object? instructions = freezed,
    Object? videoUrl = freezed,
  }) {
    return _then(_Exercise(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      targetMuscle: null == targetMuscle
          ? _self.targetMuscle
          : targetMuscle // ignore: cast_nullable_to_non_nullable
              as String,
      equipmentRequired: null == equipmentRequired
          ? _self.equipmentRequired
          : equipmentRequired // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _self._sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSet>,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      instructions: freezed == instructions
          ? _self.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _self.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$DailyWorkout {
  String get id;
  String get date;
  String get title;
  String get focusArea;
  int get estimatedDurationMin;
  List<Exercise> get exercises;
  WorkoutStatus get status;
  String? get adaptationNote;

  /// Create a copy of DailyWorkout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DailyWorkoutCopyWith<DailyWorkout> get copyWith =>
      _$DailyWorkoutCopyWithImpl<DailyWorkout>(
          this as DailyWorkout, _$identity);

  /// Serializes this DailyWorkout to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DailyWorkout &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.focusArea, focusArea) ||
                other.focusArea == focusArea) &&
            (identical(other.estimatedDurationMin, estimatedDurationMin) ||
                other.estimatedDurationMin == estimatedDurationMin) &&
            const DeepCollectionEquality().equals(other.exercises, exercises) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.adaptationNote, adaptationNote) ||
                other.adaptationNote == adaptationNote));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      date,
      title,
      focusArea,
      estimatedDurationMin,
      const DeepCollectionEquality().hash(exercises),
      status,
      adaptationNote);

  @override
  String toString() {
    return 'DailyWorkout(id: $id, date: $date, title: $title, focusArea: $focusArea, estimatedDurationMin: $estimatedDurationMin, exercises: $exercises, status: $status, adaptationNote: $adaptationNote)';
  }
}

/// @nodoc
abstract mixin class $DailyWorkoutCopyWith<$Res> {
  factory $DailyWorkoutCopyWith(
          DailyWorkout value, $Res Function(DailyWorkout) _then) =
      _$DailyWorkoutCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String date,
      String title,
      String focusArea,
      int estimatedDurationMin,
      List<Exercise> exercises,
      WorkoutStatus status,
      String? adaptationNote});
}

/// @nodoc
class _$DailyWorkoutCopyWithImpl<$Res> implements $DailyWorkoutCopyWith<$Res> {
  _$DailyWorkoutCopyWithImpl(this._self, this._then);

  final DailyWorkout _self;
  final $Res Function(DailyWorkout) _then;

  /// Create a copy of DailyWorkout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? title = null,
    Object? focusArea = null,
    Object? estimatedDurationMin = null,
    Object? exercises = null,
    Object? status = null,
    Object? adaptationNote = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      focusArea: null == focusArea
          ? _self.focusArea
          : focusArea // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedDurationMin: null == estimatedDurationMin
          ? _self.estimatedDurationMin
          : estimatedDurationMin // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _self.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as WorkoutStatus,
      adaptationNote: freezed == adaptationNote
          ? _self.adaptationNote
          : adaptationNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [DailyWorkout].
extension DailyWorkoutPatterns on DailyWorkout {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DailyWorkout value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DailyWorkout() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DailyWorkout value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyWorkout():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DailyWorkout value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyWorkout() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String date,
            String title,
            String focusArea,
            int estimatedDurationMin,
            List<Exercise> exercises,
            WorkoutStatus status,
            String? adaptationNote)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DailyWorkout() when $default != null:
        return $default(
            _that.id,
            _that.date,
            _that.title,
            _that.focusArea,
            _that.estimatedDurationMin,
            _that.exercises,
            _that.status,
            _that.adaptationNote);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String date,
            String title,
            String focusArea,
            int estimatedDurationMin,
            List<Exercise> exercises,
            WorkoutStatus status,
            String? adaptationNote)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyWorkout():
        return $default(
            _that.id,
            _that.date,
            _that.title,
            _that.focusArea,
            _that.estimatedDurationMin,
            _that.exercises,
            _that.status,
            _that.adaptationNote);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String date,
            String title,
            String focusArea,
            int estimatedDurationMin,
            List<Exercise> exercises,
            WorkoutStatus status,
            String? adaptationNote)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyWorkout() when $default != null:
        return $default(
            _that.id,
            _that.date,
            _that.title,
            _that.focusArea,
            _that.estimatedDurationMin,
            _that.exercises,
            _that.status,
            _that.adaptationNote);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _DailyWorkout extends DailyWorkout {
  const _DailyWorkout(
      {required this.id,
      required this.date,
      required this.title,
      required this.focusArea,
      required this.estimatedDurationMin,
      required final List<Exercise> exercises,
      this.status = WorkoutStatus.scheduled,
      this.adaptationNote})
      : _exercises = exercises,
        super._();
  factory _DailyWorkout.fromJson(Map<String, dynamic> json) =>
      _$DailyWorkoutFromJson(json);

  @override
  final String id;
  @override
  final String date;
  @override
  final String title;
  @override
  final String focusArea;
  @override
  final int estimatedDurationMin;
  final List<Exercise> _exercises;
  @override
  List<Exercise> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  @JsonKey()
  final WorkoutStatus status;
  @override
  final String? adaptationNote;

  /// Create a copy of DailyWorkout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DailyWorkoutCopyWith<_DailyWorkout> get copyWith =>
      __$DailyWorkoutCopyWithImpl<_DailyWorkout>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DailyWorkoutToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DailyWorkout &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.focusArea, focusArea) ||
                other.focusArea == focusArea) &&
            (identical(other.estimatedDurationMin, estimatedDurationMin) ||
                other.estimatedDurationMin == estimatedDurationMin) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.adaptationNote, adaptationNote) ||
                other.adaptationNote == adaptationNote));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      date,
      title,
      focusArea,
      estimatedDurationMin,
      const DeepCollectionEquality().hash(_exercises),
      status,
      adaptationNote);

  @override
  String toString() {
    return 'DailyWorkout(id: $id, date: $date, title: $title, focusArea: $focusArea, estimatedDurationMin: $estimatedDurationMin, exercises: $exercises, status: $status, adaptationNote: $adaptationNote)';
  }
}

/// @nodoc
abstract mixin class _$DailyWorkoutCopyWith<$Res>
    implements $DailyWorkoutCopyWith<$Res> {
  factory _$DailyWorkoutCopyWith(
          _DailyWorkout value, $Res Function(_DailyWorkout) _then) =
      __$DailyWorkoutCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String date,
      String title,
      String focusArea,
      int estimatedDurationMin,
      List<Exercise> exercises,
      WorkoutStatus status,
      String? adaptationNote});
}

/// @nodoc
class __$DailyWorkoutCopyWithImpl<$Res>
    implements _$DailyWorkoutCopyWith<$Res> {
  __$DailyWorkoutCopyWithImpl(this._self, this._then);

  final _DailyWorkout _self;
  final $Res Function(_DailyWorkout) _then;

  /// Create a copy of DailyWorkout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? title = null,
    Object? focusArea = null,
    Object? estimatedDurationMin = null,
    Object? exercises = null,
    Object? status = null,
    Object? adaptationNote = freezed,
  }) {
    return _then(_DailyWorkout(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      focusArea: null == focusArea
          ? _self.focusArea
          : focusArea // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedDurationMin: null == estimatedDurationMin
          ? _self.estimatedDurationMin
          : estimatedDurationMin // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _self._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as WorkoutStatus,
      adaptationNote: freezed == adaptationNote
          ? _self.adaptationNote
          : adaptationNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
