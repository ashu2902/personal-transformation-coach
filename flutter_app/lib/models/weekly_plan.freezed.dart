// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeeklyDayPlan {
  String get dayName;
  String get date;
  String get title;
  String get focusArea;
  bool get isRestDay;
  List<String> get exerciseNames;
  List<PlannedExercise> get plannedExercises;
  String? get nutritionFocus;

  /// Create a copy of WeeklyDayPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WeeklyDayPlanCopyWith<WeeklyDayPlan> get copyWith =>
      _$WeeklyDayPlanCopyWithImpl<WeeklyDayPlan>(
          this as WeeklyDayPlan, _$identity);

  /// Serializes this WeeklyDayPlan to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WeeklyDayPlan &&
            (identical(other.dayName, dayName) || other.dayName == dayName) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.focusArea, focusArea) ||
                other.focusArea == focusArea) &&
            (identical(other.isRestDay, isRestDay) ||
                other.isRestDay == isRestDay) &&
            const DeepCollectionEquality()
                .equals(other.exerciseNames, exerciseNames) &&
            const DeepCollectionEquality()
                .equals(other.plannedExercises, plannedExercises) &&
            (identical(other.nutritionFocus, nutritionFocus) ||
                other.nutritionFocus == nutritionFocus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      dayName,
      date,
      title,
      focusArea,
      isRestDay,
      const DeepCollectionEquality().hash(exerciseNames),
      const DeepCollectionEquality().hash(plannedExercises),
      nutritionFocus);

  @override
  String toString() {
    return 'WeeklyDayPlan(dayName: $dayName, date: $date, title: $title, focusArea: $focusArea, isRestDay: $isRestDay, exerciseNames: $exerciseNames, plannedExercises: $plannedExercises, nutritionFocus: $nutritionFocus)';
  }
}

/// @nodoc
abstract mixin class $WeeklyDayPlanCopyWith<$Res> {
  factory $WeeklyDayPlanCopyWith(
          WeeklyDayPlan value, $Res Function(WeeklyDayPlan) _then) =
      _$WeeklyDayPlanCopyWithImpl;
  @useResult
  $Res call(
      {String dayName,
      String date,
      String title,
      String focusArea,
      bool isRestDay,
      List<String> exerciseNames,
      List<PlannedExercise> plannedExercises,
      String? nutritionFocus});
}

/// @nodoc
class _$WeeklyDayPlanCopyWithImpl<$Res>
    implements $WeeklyDayPlanCopyWith<$Res> {
  _$WeeklyDayPlanCopyWithImpl(this._self, this._then);

  final WeeklyDayPlan _self;
  final $Res Function(WeeklyDayPlan) _then;

  /// Create a copy of WeeklyDayPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayName = null,
    Object? date = null,
    Object? title = null,
    Object? focusArea = null,
    Object? isRestDay = null,
    Object? exerciseNames = null,
    Object? plannedExercises = null,
    Object? nutritionFocus = freezed,
  }) {
    return _then(_self.copyWith(
      dayName: null == dayName
          ? _self.dayName
          : dayName // ignore: cast_nullable_to_non_nullable
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
      isRestDay: null == isRestDay
          ? _self.isRestDay
          : isRestDay // ignore: cast_nullable_to_non_nullable
              as bool,
      exerciseNames: null == exerciseNames
          ? _self.exerciseNames
          : exerciseNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      plannedExercises: null == plannedExercises
          ? _self.plannedExercises
          : plannedExercises // ignore: cast_nullable_to_non_nullable
              as List<PlannedExercise>,
      nutritionFocus: freezed == nutritionFocus
          ? _self.nutritionFocus
          : nutritionFocus // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [WeeklyDayPlan].
extension WeeklyDayPlanPatterns on WeeklyDayPlan {
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
    TResult Function(_WeeklyDayPlan value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WeeklyDayPlan() when $default != null:
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
    TResult Function(_WeeklyDayPlan value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WeeklyDayPlan():
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
    TResult? Function(_WeeklyDayPlan value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WeeklyDayPlan() when $default != null:
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
            String dayName,
            String date,
            String title,
            String focusArea,
            bool isRestDay,
            List<String> exerciseNames,
            List<PlannedExercise> plannedExercises,
            String? nutritionFocus)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WeeklyDayPlan() when $default != null:
        return $default(
            _that.dayName,
            _that.date,
            _that.title,
            _that.focusArea,
            _that.isRestDay,
            _that.exerciseNames,
            _that.plannedExercises,
            _that.nutritionFocus);
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
            String dayName,
            String date,
            String title,
            String focusArea,
            bool isRestDay,
            List<String> exerciseNames,
            List<PlannedExercise> plannedExercises,
            String? nutritionFocus)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WeeklyDayPlan():
        return $default(
            _that.dayName,
            _that.date,
            _that.title,
            _that.focusArea,
            _that.isRestDay,
            _that.exerciseNames,
            _that.plannedExercises,
            _that.nutritionFocus);
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
            String dayName,
            String date,
            String title,
            String focusArea,
            bool isRestDay,
            List<String> exerciseNames,
            List<PlannedExercise> plannedExercises,
            String? nutritionFocus)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WeeklyDayPlan() when $default != null:
        return $default(
            _that.dayName,
            _that.date,
            _that.title,
            _that.focusArea,
            _that.isRestDay,
            _that.exerciseNames,
            _that.plannedExercises,
            _that.nutritionFocus);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WeeklyDayPlan extends WeeklyDayPlan {
  const _WeeklyDayPlan(
      {required this.dayName,
      required this.date,
      required this.title,
      required this.focusArea,
      this.isRestDay = false,
      final List<String> exerciseNames = const [],
      final List<PlannedExercise> plannedExercises = const [],
      this.nutritionFocus})
      : _exerciseNames = exerciseNames,
        _plannedExercises = plannedExercises,
        super._();
  factory _WeeklyDayPlan.fromJson(Map<String, dynamic> json) =>
      _$WeeklyDayPlanFromJson(json);

  @override
  final String dayName;
  @override
  final String date;
  @override
  final String title;
  @override
  final String focusArea;
  @override
  @JsonKey()
  final bool isRestDay;
  final List<String> _exerciseNames;
  @override
  @JsonKey()
  List<String> get exerciseNames {
    if (_exerciseNames is EqualUnmodifiableListView) return _exerciseNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exerciseNames);
  }

  final List<PlannedExercise> _plannedExercises;
  @override
  @JsonKey()
  List<PlannedExercise> get plannedExercises {
    if (_plannedExercises is EqualUnmodifiableListView)
      return _plannedExercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_plannedExercises);
  }

  @override
  final String? nutritionFocus;

  /// Create a copy of WeeklyDayPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WeeklyDayPlanCopyWith<_WeeklyDayPlan> get copyWith =>
      __$WeeklyDayPlanCopyWithImpl<_WeeklyDayPlan>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WeeklyDayPlanToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WeeklyDayPlan &&
            (identical(other.dayName, dayName) || other.dayName == dayName) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.focusArea, focusArea) ||
                other.focusArea == focusArea) &&
            (identical(other.isRestDay, isRestDay) ||
                other.isRestDay == isRestDay) &&
            const DeepCollectionEquality()
                .equals(other._exerciseNames, _exerciseNames) &&
            const DeepCollectionEquality()
                .equals(other._plannedExercises, _plannedExercises) &&
            (identical(other.nutritionFocus, nutritionFocus) ||
                other.nutritionFocus == nutritionFocus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      dayName,
      date,
      title,
      focusArea,
      isRestDay,
      const DeepCollectionEquality().hash(_exerciseNames),
      const DeepCollectionEquality().hash(_plannedExercises),
      nutritionFocus);

  @override
  String toString() {
    return 'WeeklyDayPlan(dayName: $dayName, date: $date, title: $title, focusArea: $focusArea, isRestDay: $isRestDay, exerciseNames: $exerciseNames, plannedExercises: $plannedExercises, nutritionFocus: $nutritionFocus)';
  }
}

/// @nodoc
abstract mixin class _$WeeklyDayPlanCopyWith<$Res>
    implements $WeeklyDayPlanCopyWith<$Res> {
  factory _$WeeklyDayPlanCopyWith(
          _WeeklyDayPlan value, $Res Function(_WeeklyDayPlan) _then) =
      __$WeeklyDayPlanCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String dayName,
      String date,
      String title,
      String focusArea,
      bool isRestDay,
      List<String> exerciseNames,
      List<PlannedExercise> plannedExercises,
      String? nutritionFocus});
}

/// @nodoc
class __$WeeklyDayPlanCopyWithImpl<$Res>
    implements _$WeeklyDayPlanCopyWith<$Res> {
  __$WeeklyDayPlanCopyWithImpl(this._self, this._then);

  final _WeeklyDayPlan _self;
  final $Res Function(_WeeklyDayPlan) _then;

  /// Create a copy of WeeklyDayPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? dayName = null,
    Object? date = null,
    Object? title = null,
    Object? focusArea = null,
    Object? isRestDay = null,
    Object? exerciseNames = null,
    Object? plannedExercises = null,
    Object? nutritionFocus = freezed,
  }) {
    return _then(_WeeklyDayPlan(
      dayName: null == dayName
          ? _self.dayName
          : dayName // ignore: cast_nullable_to_non_nullable
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
      isRestDay: null == isRestDay
          ? _self.isRestDay
          : isRestDay // ignore: cast_nullable_to_non_nullable
              as bool,
      exerciseNames: null == exerciseNames
          ? _self._exerciseNames
          : exerciseNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      plannedExercises: null == plannedExercises
          ? _self._plannedExercises
          : plannedExercises // ignore: cast_nullable_to_non_nullable
              as List<PlannedExercise>,
      nutritionFocus: freezed == nutritionFocus
          ? _self.nutritionFocus
          : nutritionFocus // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$WeeklyPlan {
  String get weekId;
  String get startDate;
  String get endDate;
  String get overview;
  String? get coachNote;
  List<WeeklyDayPlan> get days;
  String get createdAt;

  /// Create a copy of WeeklyPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WeeklyPlanCopyWith<WeeklyPlan> get copyWith =>
      _$WeeklyPlanCopyWithImpl<WeeklyPlan>(this as WeeklyPlan, _$identity);

  /// Serializes this WeeklyPlan to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WeeklyPlan &&
            (identical(other.weekId, weekId) || other.weekId == weekId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.coachNote, coachNote) ||
                other.coachNote == coachNote) &&
            const DeepCollectionEquality().equals(other.days, days) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      weekId,
      startDate,
      endDate,
      overview,
      coachNote,
      const DeepCollectionEquality().hash(days),
      createdAt);

  @override
  String toString() {
    return 'WeeklyPlan(weekId: $weekId, startDate: $startDate, endDate: $endDate, overview: $overview, coachNote: $coachNote, days: $days, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $WeeklyPlanCopyWith<$Res> {
  factory $WeeklyPlanCopyWith(
          WeeklyPlan value, $Res Function(WeeklyPlan) _then) =
      _$WeeklyPlanCopyWithImpl;
  @useResult
  $Res call(
      {String weekId,
      String startDate,
      String endDate,
      String overview,
      String? coachNote,
      List<WeeklyDayPlan> days,
      String createdAt});
}

/// @nodoc
class _$WeeklyPlanCopyWithImpl<$Res> implements $WeeklyPlanCopyWith<$Res> {
  _$WeeklyPlanCopyWithImpl(this._self, this._then);

  final WeeklyPlan _self;
  final $Res Function(WeeklyPlan) _then;

  /// Create a copy of WeeklyPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekId = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? overview = null,
    Object? coachNote = freezed,
    Object? days = null,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      weekId: null == weekId
          ? _self.weekId
          : weekId // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _self.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _self.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      overview: null == overview
          ? _self.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as String,
      coachNote: freezed == coachNote
          ? _self.coachNote
          : coachNote // ignore: cast_nullable_to_non_nullable
              as String?,
      days: null == days
          ? _self.days
          : days // ignore: cast_nullable_to_non_nullable
              as List<WeeklyDayPlan>,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [WeeklyPlan].
extension WeeklyPlanPatterns on WeeklyPlan {
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
    TResult Function(_WeeklyPlan value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WeeklyPlan() when $default != null:
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
    TResult Function(_WeeklyPlan value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WeeklyPlan():
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
    TResult? Function(_WeeklyPlan value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WeeklyPlan() when $default != null:
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
            String weekId,
            String startDate,
            String endDate,
            String overview,
            String? coachNote,
            List<WeeklyDayPlan> days,
            String createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WeeklyPlan() when $default != null:
        return $default(_that.weekId, _that.startDate, _that.endDate,
            _that.overview, _that.coachNote, _that.days, _that.createdAt);
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
            String weekId,
            String startDate,
            String endDate,
            String overview,
            String? coachNote,
            List<WeeklyDayPlan> days,
            String createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WeeklyPlan():
        return $default(_that.weekId, _that.startDate, _that.endDate,
            _that.overview, _that.coachNote, _that.days, _that.createdAt);
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
            String weekId,
            String startDate,
            String endDate,
            String overview,
            String? coachNote,
            List<WeeklyDayPlan> days,
            String createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WeeklyPlan() when $default != null:
        return $default(_that.weekId, _that.startDate, _that.endDate,
            _that.overview, _that.coachNote, _that.days, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WeeklyPlan extends WeeklyPlan {
  const _WeeklyPlan(
      {required this.weekId,
      required this.startDate,
      required this.endDate,
      required this.overview,
      this.coachNote,
      required final List<WeeklyDayPlan> days,
      required this.createdAt})
      : _days = days,
        super._();
  factory _WeeklyPlan.fromJson(Map<String, dynamic> json) =>
      _$WeeklyPlanFromJson(json);

  @override
  final String weekId;
  @override
  final String startDate;
  @override
  final String endDate;
  @override
  final String overview;
  @override
  final String? coachNote;
  final List<WeeklyDayPlan> _days;
  @override
  List<WeeklyDayPlan> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  @override
  final String createdAt;

  /// Create a copy of WeeklyPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WeeklyPlanCopyWith<_WeeklyPlan> get copyWith =>
      __$WeeklyPlanCopyWithImpl<_WeeklyPlan>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WeeklyPlanToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WeeklyPlan &&
            (identical(other.weekId, weekId) || other.weekId == weekId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.coachNote, coachNote) ||
                other.coachNote == coachNote) &&
            const DeepCollectionEquality().equals(other._days, _days) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      weekId,
      startDate,
      endDate,
      overview,
      coachNote,
      const DeepCollectionEquality().hash(_days),
      createdAt);

  @override
  String toString() {
    return 'WeeklyPlan(weekId: $weekId, startDate: $startDate, endDate: $endDate, overview: $overview, coachNote: $coachNote, days: $days, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$WeeklyPlanCopyWith<$Res>
    implements $WeeklyPlanCopyWith<$Res> {
  factory _$WeeklyPlanCopyWith(
          _WeeklyPlan value, $Res Function(_WeeklyPlan) _then) =
      __$WeeklyPlanCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String weekId,
      String startDate,
      String endDate,
      String overview,
      String? coachNote,
      List<WeeklyDayPlan> days,
      String createdAt});
}

/// @nodoc
class __$WeeklyPlanCopyWithImpl<$Res> implements _$WeeklyPlanCopyWith<$Res> {
  __$WeeklyPlanCopyWithImpl(this._self, this._then);

  final _WeeklyPlan _self;
  final $Res Function(_WeeklyPlan) _then;

  /// Create a copy of WeeklyPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? weekId = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? overview = null,
    Object? coachNote = freezed,
    Object? days = null,
    Object? createdAt = null,
  }) {
    return _then(_WeeklyPlan(
      weekId: null == weekId
          ? _self.weekId
          : weekId // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _self.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _self.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      overview: null == overview
          ? _self.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as String,
      coachNote: freezed == coachNote
          ? _self.coachNote
          : coachNote // ignore: cast_nullable_to_non_nullable
              as String?,
      days: null == days
          ? _self._days
          : days // ignore: cast_nullable_to_non_nullable
              as List<WeeklyDayPlan>,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
