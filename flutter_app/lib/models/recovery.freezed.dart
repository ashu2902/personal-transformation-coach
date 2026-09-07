// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recovery.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecoveryCheckIn {
  String get date;
  double get sleepHours;
  int get sleepQuality;
  int get muscleSoreness;
  int get energyLevel;
  int get stressLevel;
  int get recoveryScore;
  String get status;

  /// Create a copy of RecoveryCheckIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecoveryCheckInCopyWith<RecoveryCheckIn> get copyWith =>
      _$RecoveryCheckInCopyWithImpl<RecoveryCheckIn>(
          this as RecoveryCheckIn, _$identity);

  /// Serializes this RecoveryCheckIn to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RecoveryCheckIn &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.sleepHours, sleepHours) ||
                other.sleepHours == sleepHours) &&
            (identical(other.sleepQuality, sleepQuality) ||
                other.sleepQuality == sleepQuality) &&
            (identical(other.muscleSoreness, muscleSoreness) ||
                other.muscleSoreness == muscleSoreness) &&
            (identical(other.energyLevel, energyLevel) ||
                other.energyLevel == energyLevel) &&
            (identical(other.stressLevel, stressLevel) ||
                other.stressLevel == stressLevel) &&
            (identical(other.recoveryScore, recoveryScore) ||
                other.recoveryScore == recoveryScore) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, sleepHours, sleepQuality,
      muscleSoreness, energyLevel, stressLevel, recoveryScore, status);

  @override
  String toString() {
    return 'RecoveryCheckIn(date: $date, sleepHours: $sleepHours, sleepQuality: $sleepQuality, muscleSoreness: $muscleSoreness, energyLevel: $energyLevel, stressLevel: $stressLevel, recoveryScore: $recoveryScore, status: $status)';
  }
}

/// @nodoc
abstract mixin class $RecoveryCheckInCopyWith<$Res> {
  factory $RecoveryCheckInCopyWith(
          RecoveryCheckIn value, $Res Function(RecoveryCheckIn) _then) =
      _$RecoveryCheckInCopyWithImpl;
  @useResult
  $Res call(
      {String date,
      double sleepHours,
      int sleepQuality,
      int muscleSoreness,
      int energyLevel,
      int stressLevel,
      int recoveryScore,
      String status});
}

/// @nodoc
class _$RecoveryCheckInCopyWithImpl<$Res>
    implements $RecoveryCheckInCopyWith<$Res> {
  _$RecoveryCheckInCopyWithImpl(this._self, this._then);

  final RecoveryCheckIn _self;
  final $Res Function(RecoveryCheckIn) _then;

  /// Create a copy of RecoveryCheckIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? sleepHours = null,
    Object? sleepQuality = null,
    Object? muscleSoreness = null,
    Object? energyLevel = null,
    Object? stressLevel = null,
    Object? recoveryScore = null,
    Object? status = null,
  }) {
    return _then(_self.copyWith(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      sleepHours: null == sleepHours
          ? _self.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as double,
      sleepQuality: null == sleepQuality
          ? _self.sleepQuality
          : sleepQuality // ignore: cast_nullable_to_non_nullable
              as int,
      muscleSoreness: null == muscleSoreness
          ? _self.muscleSoreness
          : muscleSoreness // ignore: cast_nullable_to_non_nullable
              as int,
      energyLevel: null == energyLevel
          ? _self.energyLevel
          : energyLevel // ignore: cast_nullable_to_non_nullable
              as int,
      stressLevel: null == stressLevel
          ? _self.stressLevel
          : stressLevel // ignore: cast_nullable_to_non_nullable
              as int,
      recoveryScore: null == recoveryScore
          ? _self.recoveryScore
          : recoveryScore // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [RecoveryCheckIn].
extension RecoveryCheckInPatterns on RecoveryCheckIn {
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
    TResult Function(_RecoveryCheckIn value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecoveryCheckIn() when $default != null:
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
    TResult Function(_RecoveryCheckIn value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecoveryCheckIn():
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
    TResult? Function(_RecoveryCheckIn value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecoveryCheckIn() when $default != null:
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
            String date,
            double sleepHours,
            int sleepQuality,
            int muscleSoreness,
            int energyLevel,
            int stressLevel,
            int recoveryScore,
            String status)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecoveryCheckIn() when $default != null:
        return $default(
            _that.date,
            _that.sleepHours,
            _that.sleepQuality,
            _that.muscleSoreness,
            _that.energyLevel,
            _that.stressLevel,
            _that.recoveryScore,
            _that.status);
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
            String date,
            double sleepHours,
            int sleepQuality,
            int muscleSoreness,
            int energyLevel,
            int stressLevel,
            int recoveryScore,
            String status)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecoveryCheckIn():
        return $default(
            _that.date,
            _that.sleepHours,
            _that.sleepQuality,
            _that.muscleSoreness,
            _that.energyLevel,
            _that.stressLevel,
            _that.recoveryScore,
            _that.status);
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
            String date,
            double sleepHours,
            int sleepQuality,
            int muscleSoreness,
            int energyLevel,
            int stressLevel,
            int recoveryScore,
            String status)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecoveryCheckIn() when $default != null:
        return $default(
            _that.date,
            _that.sleepHours,
            _that.sleepQuality,
            _that.muscleSoreness,
            _that.energyLevel,
            _that.stressLevel,
            _that.recoveryScore,
            _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _RecoveryCheckIn extends RecoveryCheckIn {
  const _RecoveryCheckIn(
      {required this.date,
      required this.sleepHours,
      required this.sleepQuality,
      required this.muscleSoreness,
      required this.energyLevel,
      required this.stressLevel,
      required this.recoveryScore,
      required this.status})
      : super._();
  factory _RecoveryCheckIn.fromJson(Map<String, dynamic> json) =>
      _$RecoveryCheckInFromJson(json);

  @override
  final String date;
  @override
  final double sleepHours;
  @override
  final int sleepQuality;
  @override
  final int muscleSoreness;
  @override
  final int energyLevel;
  @override
  final int stressLevel;
  @override
  final int recoveryScore;
  @override
  final String status;

  /// Create a copy of RecoveryCheckIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecoveryCheckInCopyWith<_RecoveryCheckIn> get copyWith =>
      __$RecoveryCheckInCopyWithImpl<_RecoveryCheckIn>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RecoveryCheckInToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RecoveryCheckIn &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.sleepHours, sleepHours) ||
                other.sleepHours == sleepHours) &&
            (identical(other.sleepQuality, sleepQuality) ||
                other.sleepQuality == sleepQuality) &&
            (identical(other.muscleSoreness, muscleSoreness) ||
                other.muscleSoreness == muscleSoreness) &&
            (identical(other.energyLevel, energyLevel) ||
                other.energyLevel == energyLevel) &&
            (identical(other.stressLevel, stressLevel) ||
                other.stressLevel == stressLevel) &&
            (identical(other.recoveryScore, recoveryScore) ||
                other.recoveryScore == recoveryScore) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, sleepHours, sleepQuality,
      muscleSoreness, energyLevel, stressLevel, recoveryScore, status);

  @override
  String toString() {
    return 'RecoveryCheckIn(date: $date, sleepHours: $sleepHours, sleepQuality: $sleepQuality, muscleSoreness: $muscleSoreness, energyLevel: $energyLevel, stressLevel: $stressLevel, recoveryScore: $recoveryScore, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$RecoveryCheckInCopyWith<$Res>
    implements $RecoveryCheckInCopyWith<$Res> {
  factory _$RecoveryCheckInCopyWith(
          _RecoveryCheckIn value, $Res Function(_RecoveryCheckIn) _then) =
      __$RecoveryCheckInCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String date,
      double sleepHours,
      int sleepQuality,
      int muscleSoreness,
      int energyLevel,
      int stressLevel,
      int recoveryScore,
      String status});
}

/// @nodoc
class __$RecoveryCheckInCopyWithImpl<$Res>
    implements _$RecoveryCheckInCopyWith<$Res> {
  __$RecoveryCheckInCopyWithImpl(this._self, this._then);

  final _RecoveryCheckIn _self;
  final $Res Function(_RecoveryCheckIn) _then;

  /// Create a copy of RecoveryCheckIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? date = null,
    Object? sleepHours = null,
    Object? sleepQuality = null,
    Object? muscleSoreness = null,
    Object? energyLevel = null,
    Object? stressLevel = null,
    Object? recoveryScore = null,
    Object? status = null,
  }) {
    return _then(_RecoveryCheckIn(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      sleepHours: null == sleepHours
          ? _self.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as double,
      sleepQuality: null == sleepQuality
          ? _self.sleepQuality
          : sleepQuality // ignore: cast_nullable_to_non_nullable
              as int,
      muscleSoreness: null == muscleSoreness
          ? _self.muscleSoreness
          : muscleSoreness // ignore: cast_nullable_to_non_nullable
              as int,
      energyLevel: null == energyLevel
          ? _self.energyLevel
          : energyLevel // ignore: cast_nullable_to_non_nullable
              as int,
      stressLevel: null == stressLevel
          ? _self.stressLevel
          : stressLevel // ignore: cast_nullable_to_non_nullable
              as int,
      recoveryScore: null == recoveryScore
          ? _self.recoveryScore
          : recoveryScore // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$ProgressEntry {
  String get date;
  double get weightKg;
  double? get bodyFatPercent;
  double? get waistCm;
  String? get notes;
  WorkoutStatus? get workoutStatus;

  /// Create a copy of ProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProgressEntryCopyWith<ProgressEntry> get copyWith =>
      _$ProgressEntryCopyWithImpl<ProgressEntry>(
          this as ProgressEntry, _$identity);

  /// Serializes this ProgressEntry to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProgressEntry &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.bodyFatPercent, bodyFatPercent) ||
                other.bodyFatPercent == bodyFatPercent) &&
            (identical(other.waistCm, waistCm) || other.waistCm == waistCm) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.workoutStatus, workoutStatus) ||
                other.workoutStatus == workoutStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, weightKg, bodyFatPercent,
      waistCm, notes, workoutStatus);

  @override
  String toString() {
    return 'ProgressEntry(date: $date, weightKg: $weightKg, bodyFatPercent: $bodyFatPercent, waistCm: $waistCm, notes: $notes, workoutStatus: $workoutStatus)';
  }
}

/// @nodoc
abstract mixin class $ProgressEntryCopyWith<$Res> {
  factory $ProgressEntryCopyWith(
          ProgressEntry value, $Res Function(ProgressEntry) _then) =
      _$ProgressEntryCopyWithImpl;
  @useResult
  $Res call(
      {String date,
      double weightKg,
      double? bodyFatPercent,
      double? waistCm,
      String? notes,
      WorkoutStatus? workoutStatus});
}

/// @nodoc
class _$ProgressEntryCopyWithImpl<$Res>
    implements $ProgressEntryCopyWith<$Res> {
  _$ProgressEntryCopyWithImpl(this._self, this._then);

  final ProgressEntry _self;
  final $Res Function(ProgressEntry) _then;

  /// Create a copy of ProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? weightKg = null,
    Object? bodyFatPercent = freezed,
    Object? waistCm = freezed,
    Object? notes = freezed,
    Object? workoutStatus = freezed,
  }) {
    return _then(_self.copyWith(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      weightKg: null == weightKg
          ? _self.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      bodyFatPercent: freezed == bodyFatPercent
          ? _self.bodyFatPercent
          : bodyFatPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      waistCm: freezed == waistCm
          ? _self.waistCm
          : waistCm // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutStatus: freezed == workoutStatus
          ? _self.workoutStatus
          : workoutStatus // ignore: cast_nullable_to_non_nullable
              as WorkoutStatus?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ProgressEntry].
extension ProgressEntryPatterns on ProgressEntry {
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
    TResult Function(_ProgressEntry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProgressEntry() when $default != null:
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
    TResult Function(_ProgressEntry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProgressEntry():
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
    TResult? Function(_ProgressEntry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProgressEntry() when $default != null:
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
    TResult Function(String date, double weightKg, double? bodyFatPercent,
            double? waistCm, String? notes, WorkoutStatus? workoutStatus)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProgressEntry() when $default != null:
        return $default(_that.date, _that.weightKg, _that.bodyFatPercent,
            _that.waistCm, _that.notes, _that.workoutStatus);
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
    TResult Function(String date, double weightKg, double? bodyFatPercent,
            double? waistCm, String? notes, WorkoutStatus? workoutStatus)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProgressEntry():
        return $default(_that.date, _that.weightKg, _that.bodyFatPercent,
            _that.waistCm, _that.notes, _that.workoutStatus);
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
    TResult? Function(String date, double weightKg, double? bodyFatPercent,
            double? waistCm, String? notes, WorkoutStatus? workoutStatus)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProgressEntry() when $default != null:
        return $default(_that.date, _that.weightKg, _that.bodyFatPercent,
            _that.waistCm, _that.notes, _that.workoutStatus);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ProgressEntry extends ProgressEntry {
  const _ProgressEntry(
      {required this.date,
      required this.weightKg,
      this.bodyFatPercent,
      this.waistCm,
      this.notes,
      this.workoutStatus})
      : super._();
  factory _ProgressEntry.fromJson(Map<String, dynamic> json) =>
      _$ProgressEntryFromJson(json);

  @override
  final String date;
  @override
  final double weightKg;
  @override
  final double? bodyFatPercent;
  @override
  final double? waistCm;
  @override
  final String? notes;
  @override
  final WorkoutStatus? workoutStatus;

  /// Create a copy of ProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProgressEntryCopyWith<_ProgressEntry> get copyWith =>
      __$ProgressEntryCopyWithImpl<_ProgressEntry>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProgressEntryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProgressEntry &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.bodyFatPercent, bodyFatPercent) ||
                other.bodyFatPercent == bodyFatPercent) &&
            (identical(other.waistCm, waistCm) || other.waistCm == waistCm) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.workoutStatus, workoutStatus) ||
                other.workoutStatus == workoutStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, weightKg, bodyFatPercent,
      waistCm, notes, workoutStatus);

  @override
  String toString() {
    return 'ProgressEntry(date: $date, weightKg: $weightKg, bodyFatPercent: $bodyFatPercent, waistCm: $waistCm, notes: $notes, workoutStatus: $workoutStatus)';
  }
}

/// @nodoc
abstract mixin class _$ProgressEntryCopyWith<$Res>
    implements $ProgressEntryCopyWith<$Res> {
  factory _$ProgressEntryCopyWith(
          _ProgressEntry value, $Res Function(_ProgressEntry) _then) =
      __$ProgressEntryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String date,
      double weightKg,
      double? bodyFatPercent,
      double? waistCm,
      String? notes,
      WorkoutStatus? workoutStatus});
}

/// @nodoc
class __$ProgressEntryCopyWithImpl<$Res>
    implements _$ProgressEntryCopyWith<$Res> {
  __$ProgressEntryCopyWithImpl(this._self, this._then);

  final _ProgressEntry _self;
  final $Res Function(_ProgressEntry) _then;

  /// Create a copy of ProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? date = null,
    Object? weightKg = null,
    Object? bodyFatPercent = freezed,
    Object? waistCm = freezed,
    Object? notes = freezed,
    Object? workoutStatus = freezed,
  }) {
    return _then(_ProgressEntry(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      weightKg: null == weightKg
          ? _self.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      bodyFatPercent: freezed == bodyFatPercent
          ? _self.bodyFatPercent
          : bodyFatPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      waistCm: freezed == waistCm
          ? _self.waistCm
          : waistCm // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutStatus: freezed == workoutStatus
          ? _self.workoutStatus
          : workoutStatus // ignore: cast_nullable_to_non_nullable
              as WorkoutStatus?,
    ));
  }
}

// dart format on
