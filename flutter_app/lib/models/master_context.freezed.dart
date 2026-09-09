// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'master_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeducedKnowledge {
  String? get activityLevel;
  int? get sessionDurationMin;
  List<String> get preferredTrainingDays;
  String? get preferredTrainingStyle;
  String? get cardioPreference;
  List<String> get activeInjuries;
  List<String> get foodAllergies;
  List<String> get dislikedExercises;
  List<String> get preferredProteinSources;
  double? get sleepPatternAvg;
  int? get stressBaseline;
  List<String> get personalNotes;
  String? get lastUpdated;

  /// Create a copy of DeducedKnowledge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeducedKnowledgeCopyWith<DeducedKnowledge> get copyWith =>
      _$DeducedKnowledgeCopyWithImpl<DeducedKnowledge>(
          this as DeducedKnowledge, _$identity);

  /// Serializes this DeducedKnowledge to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeducedKnowledge &&
            (identical(other.activityLevel, activityLevel) ||
                other.activityLevel == activityLevel) &&
            (identical(other.sessionDurationMin, sessionDurationMin) ||
                other.sessionDurationMin == sessionDurationMin) &&
            const DeepCollectionEquality()
                .equals(other.preferredTrainingDays, preferredTrainingDays) &&
            (identical(other.preferredTrainingStyle, preferredTrainingStyle) ||
                other.preferredTrainingStyle == preferredTrainingStyle) &&
            (identical(other.cardioPreference, cardioPreference) ||
                other.cardioPreference == cardioPreference) &&
            const DeepCollectionEquality()
                .equals(other.activeInjuries, activeInjuries) &&
            const DeepCollectionEquality()
                .equals(other.foodAllergies, foodAllergies) &&
            const DeepCollectionEquality()
                .equals(other.dislikedExercises, dislikedExercises) &&
            const DeepCollectionEquality().equals(
                other.preferredProteinSources, preferredProteinSources) &&
            (identical(other.sleepPatternAvg, sleepPatternAvg) ||
                other.sleepPatternAvg == sleepPatternAvg) &&
            (identical(other.stressBaseline, stressBaseline) ||
                other.stressBaseline == stressBaseline) &&
            const DeepCollectionEquality()
                .equals(other.personalNotes, personalNotes) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      activityLevel,
      sessionDurationMin,
      const DeepCollectionEquality().hash(preferredTrainingDays),
      preferredTrainingStyle,
      cardioPreference,
      const DeepCollectionEquality().hash(activeInjuries),
      const DeepCollectionEquality().hash(foodAllergies),
      const DeepCollectionEquality().hash(dislikedExercises),
      const DeepCollectionEquality().hash(preferredProteinSources),
      sleepPatternAvg,
      stressBaseline,
      const DeepCollectionEquality().hash(personalNotes),
      lastUpdated);

  @override
  String toString() {
    return 'DeducedKnowledge(activityLevel: $activityLevel, sessionDurationMin: $sessionDurationMin, preferredTrainingDays: $preferredTrainingDays, preferredTrainingStyle: $preferredTrainingStyle, cardioPreference: $cardioPreference, activeInjuries: $activeInjuries, foodAllergies: $foodAllergies, dislikedExercises: $dislikedExercises, preferredProteinSources: $preferredProteinSources, sleepPatternAvg: $sleepPatternAvg, stressBaseline: $stressBaseline, personalNotes: $personalNotes, lastUpdated: $lastUpdated)';
  }
}

/// @nodoc
abstract mixin class $DeducedKnowledgeCopyWith<$Res> {
  factory $DeducedKnowledgeCopyWith(
          DeducedKnowledge value, $Res Function(DeducedKnowledge) _then) =
      _$DeducedKnowledgeCopyWithImpl;
  @useResult
  $Res call(
      {String? activityLevel,
      int? sessionDurationMin,
      List<String> preferredTrainingDays,
      String? preferredTrainingStyle,
      String? cardioPreference,
      List<String> activeInjuries,
      List<String> foodAllergies,
      List<String> dislikedExercises,
      List<String> preferredProteinSources,
      double? sleepPatternAvg,
      int? stressBaseline,
      List<String> personalNotes,
      String? lastUpdated});
}

/// @nodoc
class _$DeducedKnowledgeCopyWithImpl<$Res>
    implements $DeducedKnowledgeCopyWith<$Res> {
  _$DeducedKnowledgeCopyWithImpl(this._self, this._then);

  final DeducedKnowledge _self;
  final $Res Function(DeducedKnowledge) _then;

  /// Create a copy of DeducedKnowledge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activityLevel = freezed,
    Object? sessionDurationMin = freezed,
    Object? preferredTrainingDays = null,
    Object? preferredTrainingStyle = freezed,
    Object? cardioPreference = freezed,
    Object? activeInjuries = null,
    Object? foodAllergies = null,
    Object? dislikedExercises = null,
    Object? preferredProteinSources = null,
    Object? sleepPatternAvg = freezed,
    Object? stressBaseline = freezed,
    Object? personalNotes = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_self.copyWith(
      activityLevel: freezed == activityLevel
          ? _self.activityLevel
          : activityLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionDurationMin: freezed == sessionDurationMin
          ? _self.sessionDurationMin
          : sessionDurationMin // ignore: cast_nullable_to_non_nullable
              as int?,
      preferredTrainingDays: null == preferredTrainingDays
          ? _self.preferredTrainingDays
          : preferredTrainingDays // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredTrainingStyle: freezed == preferredTrainingStyle
          ? _self.preferredTrainingStyle
          : preferredTrainingStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      cardioPreference: freezed == cardioPreference
          ? _self.cardioPreference
          : cardioPreference // ignore: cast_nullable_to_non_nullable
              as String?,
      activeInjuries: null == activeInjuries
          ? _self.activeInjuries
          : activeInjuries // ignore: cast_nullable_to_non_nullable
              as List<String>,
      foodAllergies: null == foodAllergies
          ? _self.foodAllergies
          : foodAllergies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dislikedExercises: null == dislikedExercises
          ? _self.dislikedExercises
          : dislikedExercises // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredProteinSources: null == preferredProteinSources
          ? _self.preferredProteinSources
          : preferredProteinSources // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sleepPatternAvg: freezed == sleepPatternAvg
          ? _self.sleepPatternAvg
          : sleepPatternAvg // ignore: cast_nullable_to_non_nullable
              as double?,
      stressBaseline: freezed == stressBaseline
          ? _self.stressBaseline
          : stressBaseline // ignore: cast_nullable_to_non_nullable
              as int?,
      personalNotes: null == personalNotes
          ? _self.personalNotes
          : personalNotes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lastUpdated: freezed == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [DeducedKnowledge].
extension DeducedKnowledgePatterns on DeducedKnowledge {
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
    TResult Function(_DeducedKnowledge value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeducedKnowledge() when $default != null:
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
    TResult Function(_DeducedKnowledge value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeducedKnowledge():
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
    TResult? Function(_DeducedKnowledge value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeducedKnowledge() when $default != null:
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
            String? activityLevel,
            int? sessionDurationMin,
            List<String> preferredTrainingDays,
            String? preferredTrainingStyle,
            String? cardioPreference,
            List<String> activeInjuries,
            List<String> foodAllergies,
            List<String> dislikedExercises,
            List<String> preferredProteinSources,
            double? sleepPatternAvg,
            int? stressBaseline,
            List<String> personalNotes,
            String? lastUpdated)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeducedKnowledge() when $default != null:
        return $default(
            _that.activityLevel,
            _that.sessionDurationMin,
            _that.preferredTrainingDays,
            _that.preferredTrainingStyle,
            _that.cardioPreference,
            _that.activeInjuries,
            _that.foodAllergies,
            _that.dislikedExercises,
            _that.preferredProteinSources,
            _that.sleepPatternAvg,
            _that.stressBaseline,
            _that.personalNotes,
            _that.lastUpdated);
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
            String? activityLevel,
            int? sessionDurationMin,
            List<String> preferredTrainingDays,
            String? preferredTrainingStyle,
            String? cardioPreference,
            List<String> activeInjuries,
            List<String> foodAllergies,
            List<String> dislikedExercises,
            List<String> preferredProteinSources,
            double? sleepPatternAvg,
            int? stressBaseline,
            List<String> personalNotes,
            String? lastUpdated)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeducedKnowledge():
        return $default(
            _that.activityLevel,
            _that.sessionDurationMin,
            _that.preferredTrainingDays,
            _that.preferredTrainingStyle,
            _that.cardioPreference,
            _that.activeInjuries,
            _that.foodAllergies,
            _that.dislikedExercises,
            _that.preferredProteinSources,
            _that.sleepPatternAvg,
            _that.stressBaseline,
            _that.personalNotes,
            _that.lastUpdated);
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
            String? activityLevel,
            int? sessionDurationMin,
            List<String> preferredTrainingDays,
            String? preferredTrainingStyle,
            String? cardioPreference,
            List<String> activeInjuries,
            List<String> foodAllergies,
            List<String> dislikedExercises,
            List<String> preferredProteinSources,
            double? sleepPatternAvg,
            int? stressBaseline,
            List<String> personalNotes,
            String? lastUpdated)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeducedKnowledge() when $default != null:
        return $default(
            _that.activityLevel,
            _that.sessionDurationMin,
            _that.preferredTrainingDays,
            _that.preferredTrainingStyle,
            _that.cardioPreference,
            _that.activeInjuries,
            _that.foodAllergies,
            _that.dislikedExercises,
            _that.preferredProteinSources,
            _that.sleepPatternAvg,
            _that.stressBaseline,
            _that.personalNotes,
            _that.lastUpdated);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DeducedKnowledge extends DeducedKnowledge {
  const _DeducedKnowledge(
      {this.activityLevel,
      this.sessionDurationMin,
      final List<String> preferredTrainingDays = const [],
      this.preferredTrainingStyle,
      this.cardioPreference,
      final List<String> activeInjuries = const [],
      final List<String> foodAllergies = const [],
      final List<String> dislikedExercises = const [],
      final List<String> preferredProteinSources = const [],
      this.sleepPatternAvg,
      this.stressBaseline,
      final List<String> personalNotes = const [],
      this.lastUpdated})
      : _preferredTrainingDays = preferredTrainingDays,
        _activeInjuries = activeInjuries,
        _foodAllergies = foodAllergies,
        _dislikedExercises = dislikedExercises,
        _preferredProteinSources = preferredProteinSources,
        _personalNotes = personalNotes,
        super._();
  factory _DeducedKnowledge.fromJson(Map<String, dynamic> json) =>
      _$DeducedKnowledgeFromJson(json);

  @override
  final String? activityLevel;
  @override
  final int? sessionDurationMin;
  final List<String> _preferredTrainingDays;
  @override
  @JsonKey()
  List<String> get preferredTrainingDays {
    if (_preferredTrainingDays is EqualUnmodifiableListView)
      return _preferredTrainingDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredTrainingDays);
  }

  @override
  final String? preferredTrainingStyle;
  @override
  final String? cardioPreference;
  final List<String> _activeInjuries;
  @override
  @JsonKey()
  List<String> get activeInjuries {
    if (_activeInjuries is EqualUnmodifiableListView) return _activeInjuries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeInjuries);
  }

  final List<String> _foodAllergies;
  @override
  @JsonKey()
  List<String> get foodAllergies {
    if (_foodAllergies is EqualUnmodifiableListView) return _foodAllergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_foodAllergies);
  }

  final List<String> _dislikedExercises;
  @override
  @JsonKey()
  List<String> get dislikedExercises {
    if (_dislikedExercises is EqualUnmodifiableListView)
      return _dislikedExercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dislikedExercises);
  }

  final List<String> _preferredProteinSources;
  @override
  @JsonKey()
  List<String> get preferredProteinSources {
    if (_preferredProteinSources is EqualUnmodifiableListView)
      return _preferredProteinSources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredProteinSources);
  }

  @override
  final double? sleepPatternAvg;
  @override
  final int? stressBaseline;
  final List<String> _personalNotes;
  @override
  @JsonKey()
  List<String> get personalNotes {
    if (_personalNotes is EqualUnmodifiableListView) return _personalNotes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_personalNotes);
  }

  @override
  final String? lastUpdated;

  /// Create a copy of DeducedKnowledge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeducedKnowledgeCopyWith<_DeducedKnowledge> get copyWith =>
      __$DeducedKnowledgeCopyWithImpl<_DeducedKnowledge>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DeducedKnowledgeToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeducedKnowledge &&
            (identical(other.activityLevel, activityLevel) ||
                other.activityLevel == activityLevel) &&
            (identical(other.sessionDurationMin, sessionDurationMin) ||
                other.sessionDurationMin == sessionDurationMin) &&
            const DeepCollectionEquality()
                .equals(other._preferredTrainingDays, _preferredTrainingDays) &&
            (identical(other.preferredTrainingStyle, preferredTrainingStyle) ||
                other.preferredTrainingStyle == preferredTrainingStyle) &&
            (identical(other.cardioPreference, cardioPreference) ||
                other.cardioPreference == cardioPreference) &&
            const DeepCollectionEquality()
                .equals(other._activeInjuries, _activeInjuries) &&
            const DeepCollectionEquality()
                .equals(other._foodAllergies, _foodAllergies) &&
            const DeepCollectionEquality()
                .equals(other._dislikedExercises, _dislikedExercises) &&
            const DeepCollectionEquality().equals(
                other._preferredProteinSources, _preferredProteinSources) &&
            (identical(other.sleepPatternAvg, sleepPatternAvg) ||
                other.sleepPatternAvg == sleepPatternAvg) &&
            (identical(other.stressBaseline, stressBaseline) ||
                other.stressBaseline == stressBaseline) &&
            const DeepCollectionEquality()
                .equals(other._personalNotes, _personalNotes) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      activityLevel,
      sessionDurationMin,
      const DeepCollectionEquality().hash(_preferredTrainingDays),
      preferredTrainingStyle,
      cardioPreference,
      const DeepCollectionEquality().hash(_activeInjuries),
      const DeepCollectionEquality().hash(_foodAllergies),
      const DeepCollectionEquality().hash(_dislikedExercises),
      const DeepCollectionEquality().hash(_preferredProteinSources),
      sleepPatternAvg,
      stressBaseline,
      const DeepCollectionEquality().hash(_personalNotes),
      lastUpdated);

  @override
  String toString() {
    return 'DeducedKnowledge(activityLevel: $activityLevel, sessionDurationMin: $sessionDurationMin, preferredTrainingDays: $preferredTrainingDays, preferredTrainingStyle: $preferredTrainingStyle, cardioPreference: $cardioPreference, activeInjuries: $activeInjuries, foodAllergies: $foodAllergies, dislikedExercises: $dislikedExercises, preferredProteinSources: $preferredProteinSources, sleepPatternAvg: $sleepPatternAvg, stressBaseline: $stressBaseline, personalNotes: $personalNotes, lastUpdated: $lastUpdated)';
  }
}

/// @nodoc
abstract mixin class _$DeducedKnowledgeCopyWith<$Res>
    implements $DeducedKnowledgeCopyWith<$Res> {
  factory _$DeducedKnowledgeCopyWith(
          _DeducedKnowledge value, $Res Function(_DeducedKnowledge) _then) =
      __$DeducedKnowledgeCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? activityLevel,
      int? sessionDurationMin,
      List<String> preferredTrainingDays,
      String? preferredTrainingStyle,
      String? cardioPreference,
      List<String> activeInjuries,
      List<String> foodAllergies,
      List<String> dislikedExercises,
      List<String> preferredProteinSources,
      double? sleepPatternAvg,
      int? stressBaseline,
      List<String> personalNotes,
      String? lastUpdated});
}

/// @nodoc
class __$DeducedKnowledgeCopyWithImpl<$Res>
    implements _$DeducedKnowledgeCopyWith<$Res> {
  __$DeducedKnowledgeCopyWithImpl(this._self, this._then);

  final _DeducedKnowledge _self;
  final $Res Function(_DeducedKnowledge) _then;

  /// Create a copy of DeducedKnowledge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? activityLevel = freezed,
    Object? sessionDurationMin = freezed,
    Object? preferredTrainingDays = null,
    Object? preferredTrainingStyle = freezed,
    Object? cardioPreference = freezed,
    Object? activeInjuries = null,
    Object? foodAllergies = null,
    Object? dislikedExercises = null,
    Object? preferredProteinSources = null,
    Object? sleepPatternAvg = freezed,
    Object? stressBaseline = freezed,
    Object? personalNotes = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_DeducedKnowledge(
      activityLevel: freezed == activityLevel
          ? _self.activityLevel
          : activityLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionDurationMin: freezed == sessionDurationMin
          ? _self.sessionDurationMin
          : sessionDurationMin // ignore: cast_nullable_to_non_nullable
              as int?,
      preferredTrainingDays: null == preferredTrainingDays
          ? _self._preferredTrainingDays
          : preferredTrainingDays // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredTrainingStyle: freezed == preferredTrainingStyle
          ? _self.preferredTrainingStyle
          : preferredTrainingStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      cardioPreference: freezed == cardioPreference
          ? _self.cardioPreference
          : cardioPreference // ignore: cast_nullable_to_non_nullable
              as String?,
      activeInjuries: null == activeInjuries
          ? _self._activeInjuries
          : activeInjuries // ignore: cast_nullable_to_non_nullable
              as List<String>,
      foodAllergies: null == foodAllergies
          ? _self._foodAllergies
          : foodAllergies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dislikedExercises: null == dislikedExercises
          ? _self._dislikedExercises
          : dislikedExercises // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredProteinSources: null == preferredProteinSources
          ? _self._preferredProteinSources
          : preferredProteinSources // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sleepPatternAvg: freezed == sleepPatternAvg
          ? _self.sleepPatternAvg
          : sleepPatternAvg // ignore: cast_nullable_to_non_nullable
              as double?,
      stressBaseline: freezed == stressBaseline
          ? _self.stressBaseline
          : stressBaseline // ignore: cast_nullable_to_non_nullable
              as int?,
      personalNotes: null == personalNotes
          ? _self._personalNotes
          : personalNotes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lastUpdated: freezed == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$RollingSummary {
  int get periodDays;
  double get workoutComplianceRate;
  int get workoutsCompleted;
  int get workoutsSkipped;
  double? get avgSessionDurationMin;
  List<Map<String, dynamic>> get recentWorkouts;
  Map<String, dynamic> get nutritionAvg;
  Map<String, dynamic> get recoveryAvg;
  List<Map<String, dynamic>> get weightTrend;
  String? get lastUpdated;

  /// Create a copy of RollingSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RollingSummaryCopyWith<RollingSummary> get copyWith =>
      _$RollingSummaryCopyWithImpl<RollingSummary>(
          this as RollingSummary, _$identity);

  /// Serializes this RollingSummary to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RollingSummary &&
            (identical(other.periodDays, periodDays) ||
                other.periodDays == periodDays) &&
            (identical(other.workoutComplianceRate, workoutComplianceRate) ||
                other.workoutComplianceRate == workoutComplianceRate) &&
            (identical(other.workoutsCompleted, workoutsCompleted) ||
                other.workoutsCompleted == workoutsCompleted) &&
            (identical(other.workoutsSkipped, workoutsSkipped) ||
                other.workoutsSkipped == workoutsSkipped) &&
            (identical(other.avgSessionDurationMin, avgSessionDurationMin) ||
                other.avgSessionDurationMin == avgSessionDurationMin) &&
            const DeepCollectionEquality()
                .equals(other.recentWorkouts, recentWorkouts) &&
            const DeepCollectionEquality()
                .equals(other.nutritionAvg, nutritionAvg) &&
            const DeepCollectionEquality()
                .equals(other.recoveryAvg, recoveryAvg) &&
            const DeepCollectionEquality()
                .equals(other.weightTrend, weightTrend) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      periodDays,
      workoutComplianceRate,
      workoutsCompleted,
      workoutsSkipped,
      avgSessionDurationMin,
      const DeepCollectionEquality().hash(recentWorkouts),
      const DeepCollectionEquality().hash(nutritionAvg),
      const DeepCollectionEquality().hash(recoveryAvg),
      const DeepCollectionEquality().hash(weightTrend),
      lastUpdated);

  @override
  String toString() {
    return 'RollingSummary(periodDays: $periodDays, workoutComplianceRate: $workoutComplianceRate, workoutsCompleted: $workoutsCompleted, workoutsSkipped: $workoutsSkipped, avgSessionDurationMin: $avgSessionDurationMin, recentWorkouts: $recentWorkouts, nutritionAvg: $nutritionAvg, recoveryAvg: $recoveryAvg, weightTrend: $weightTrend, lastUpdated: $lastUpdated)';
  }
}

/// @nodoc
abstract mixin class $RollingSummaryCopyWith<$Res> {
  factory $RollingSummaryCopyWith(
          RollingSummary value, $Res Function(RollingSummary) _then) =
      _$RollingSummaryCopyWithImpl;
  @useResult
  $Res call(
      {int periodDays,
      double workoutComplianceRate,
      int workoutsCompleted,
      int workoutsSkipped,
      double? avgSessionDurationMin,
      List<Map<String, dynamic>> recentWorkouts,
      Map<String, dynamic> nutritionAvg,
      Map<String, dynamic> recoveryAvg,
      List<Map<String, dynamic>> weightTrend,
      String? lastUpdated});
}

/// @nodoc
class _$RollingSummaryCopyWithImpl<$Res>
    implements $RollingSummaryCopyWith<$Res> {
  _$RollingSummaryCopyWithImpl(this._self, this._then);

  final RollingSummary _self;
  final $Res Function(RollingSummary) _then;

  /// Create a copy of RollingSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? periodDays = null,
    Object? workoutComplianceRate = null,
    Object? workoutsCompleted = null,
    Object? workoutsSkipped = null,
    Object? avgSessionDurationMin = freezed,
    Object? recentWorkouts = null,
    Object? nutritionAvg = null,
    Object? recoveryAvg = null,
    Object? weightTrend = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_self.copyWith(
      periodDays: null == periodDays
          ? _self.periodDays
          : periodDays // ignore: cast_nullable_to_non_nullable
              as int,
      workoutComplianceRate: null == workoutComplianceRate
          ? _self.workoutComplianceRate
          : workoutComplianceRate // ignore: cast_nullable_to_non_nullable
              as double,
      workoutsCompleted: null == workoutsCompleted
          ? _self.workoutsCompleted
          : workoutsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsSkipped: null == workoutsSkipped
          ? _self.workoutsSkipped
          : workoutsSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      avgSessionDurationMin: freezed == avgSessionDurationMin
          ? _self.avgSessionDurationMin
          : avgSessionDurationMin // ignore: cast_nullable_to_non_nullable
              as double?,
      recentWorkouts: null == recentWorkouts
          ? _self.recentWorkouts
          : recentWorkouts // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      nutritionAvg: null == nutritionAvg
          ? _self.nutritionAvg
          : nutritionAvg // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      recoveryAvg: null == recoveryAvg
          ? _self.recoveryAvg
          : recoveryAvg // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      weightTrend: null == weightTrend
          ? _self.weightTrend
          : weightTrend // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      lastUpdated: freezed == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [RollingSummary].
extension RollingSummaryPatterns on RollingSummary {
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
    TResult Function(_RollingSummary value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RollingSummary() when $default != null:
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
    TResult Function(_RollingSummary value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RollingSummary():
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
    TResult? Function(_RollingSummary value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RollingSummary() when $default != null:
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
            int periodDays,
            double workoutComplianceRate,
            int workoutsCompleted,
            int workoutsSkipped,
            double? avgSessionDurationMin,
            List<Map<String, dynamic>> recentWorkouts,
            Map<String, dynamic> nutritionAvg,
            Map<String, dynamic> recoveryAvg,
            List<Map<String, dynamic>> weightTrend,
            String? lastUpdated)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RollingSummary() when $default != null:
        return $default(
            _that.periodDays,
            _that.workoutComplianceRate,
            _that.workoutsCompleted,
            _that.workoutsSkipped,
            _that.avgSessionDurationMin,
            _that.recentWorkouts,
            _that.nutritionAvg,
            _that.recoveryAvg,
            _that.weightTrend,
            _that.lastUpdated);
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
            int periodDays,
            double workoutComplianceRate,
            int workoutsCompleted,
            int workoutsSkipped,
            double? avgSessionDurationMin,
            List<Map<String, dynamic>> recentWorkouts,
            Map<String, dynamic> nutritionAvg,
            Map<String, dynamic> recoveryAvg,
            List<Map<String, dynamic>> weightTrend,
            String? lastUpdated)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RollingSummary():
        return $default(
            _that.periodDays,
            _that.workoutComplianceRate,
            _that.workoutsCompleted,
            _that.workoutsSkipped,
            _that.avgSessionDurationMin,
            _that.recentWorkouts,
            _that.nutritionAvg,
            _that.recoveryAvg,
            _that.weightTrend,
            _that.lastUpdated);
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
            int periodDays,
            double workoutComplianceRate,
            int workoutsCompleted,
            int workoutsSkipped,
            double? avgSessionDurationMin,
            List<Map<String, dynamic>> recentWorkouts,
            Map<String, dynamic> nutritionAvg,
            Map<String, dynamic> recoveryAvg,
            List<Map<String, dynamic>> weightTrend,
            String? lastUpdated)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RollingSummary() when $default != null:
        return $default(
            _that.periodDays,
            _that.workoutComplianceRate,
            _that.workoutsCompleted,
            _that.workoutsSkipped,
            _that.avgSessionDurationMin,
            _that.recentWorkouts,
            _that.nutritionAvg,
            _that.recoveryAvg,
            _that.weightTrend,
            _that.lastUpdated);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _RollingSummary extends RollingSummary {
  const _RollingSummary(
      {this.periodDays = 7,
      this.workoutComplianceRate = 0.0,
      this.workoutsCompleted = 0,
      this.workoutsSkipped = 0,
      this.avgSessionDurationMin,
      final List<Map<String, dynamic>> recentWorkouts = const [],
      final Map<String, dynamic> nutritionAvg = const {},
      final Map<String, dynamic> recoveryAvg = const {},
      final List<Map<String, dynamic>> weightTrend = const [],
      this.lastUpdated})
      : _recentWorkouts = recentWorkouts,
        _nutritionAvg = nutritionAvg,
        _recoveryAvg = recoveryAvg,
        _weightTrend = weightTrend,
        super._();
  factory _RollingSummary.fromJson(Map<String, dynamic> json) =>
      _$RollingSummaryFromJson(json);

  @override
  @JsonKey()
  final int periodDays;
  @override
  @JsonKey()
  final double workoutComplianceRate;
  @override
  @JsonKey()
  final int workoutsCompleted;
  @override
  @JsonKey()
  final int workoutsSkipped;
  @override
  final double? avgSessionDurationMin;
  final List<Map<String, dynamic>> _recentWorkouts;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get recentWorkouts {
    if (_recentWorkouts is EqualUnmodifiableListView) return _recentWorkouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentWorkouts);
  }

  final Map<String, dynamic> _nutritionAvg;
  @override
  @JsonKey()
  Map<String, dynamic> get nutritionAvg {
    if (_nutritionAvg is EqualUnmodifiableMapView) return _nutritionAvg;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_nutritionAvg);
  }

  final Map<String, dynamic> _recoveryAvg;
  @override
  @JsonKey()
  Map<String, dynamic> get recoveryAvg {
    if (_recoveryAvg is EqualUnmodifiableMapView) return _recoveryAvg;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_recoveryAvg);
  }

  final List<Map<String, dynamic>> _weightTrend;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get weightTrend {
    if (_weightTrend is EqualUnmodifiableListView) return _weightTrend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weightTrend);
  }

  @override
  final String? lastUpdated;

  /// Create a copy of RollingSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RollingSummaryCopyWith<_RollingSummary> get copyWith =>
      __$RollingSummaryCopyWithImpl<_RollingSummary>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RollingSummaryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RollingSummary &&
            (identical(other.periodDays, periodDays) ||
                other.periodDays == periodDays) &&
            (identical(other.workoutComplianceRate, workoutComplianceRate) ||
                other.workoutComplianceRate == workoutComplianceRate) &&
            (identical(other.workoutsCompleted, workoutsCompleted) ||
                other.workoutsCompleted == workoutsCompleted) &&
            (identical(other.workoutsSkipped, workoutsSkipped) ||
                other.workoutsSkipped == workoutsSkipped) &&
            (identical(other.avgSessionDurationMin, avgSessionDurationMin) ||
                other.avgSessionDurationMin == avgSessionDurationMin) &&
            const DeepCollectionEquality()
                .equals(other._recentWorkouts, _recentWorkouts) &&
            const DeepCollectionEquality()
                .equals(other._nutritionAvg, _nutritionAvg) &&
            const DeepCollectionEquality()
                .equals(other._recoveryAvg, _recoveryAvg) &&
            const DeepCollectionEquality()
                .equals(other._weightTrend, _weightTrend) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      periodDays,
      workoutComplianceRate,
      workoutsCompleted,
      workoutsSkipped,
      avgSessionDurationMin,
      const DeepCollectionEquality().hash(_recentWorkouts),
      const DeepCollectionEquality().hash(_nutritionAvg),
      const DeepCollectionEquality().hash(_recoveryAvg),
      const DeepCollectionEquality().hash(_weightTrend),
      lastUpdated);

  @override
  String toString() {
    return 'RollingSummary(periodDays: $periodDays, workoutComplianceRate: $workoutComplianceRate, workoutsCompleted: $workoutsCompleted, workoutsSkipped: $workoutsSkipped, avgSessionDurationMin: $avgSessionDurationMin, recentWorkouts: $recentWorkouts, nutritionAvg: $nutritionAvg, recoveryAvg: $recoveryAvg, weightTrend: $weightTrend, lastUpdated: $lastUpdated)';
  }
}

/// @nodoc
abstract mixin class _$RollingSummaryCopyWith<$Res>
    implements $RollingSummaryCopyWith<$Res> {
  factory _$RollingSummaryCopyWith(
          _RollingSummary value, $Res Function(_RollingSummary) _then) =
      __$RollingSummaryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int periodDays,
      double workoutComplianceRate,
      int workoutsCompleted,
      int workoutsSkipped,
      double? avgSessionDurationMin,
      List<Map<String, dynamic>> recentWorkouts,
      Map<String, dynamic> nutritionAvg,
      Map<String, dynamic> recoveryAvg,
      List<Map<String, dynamic>> weightTrend,
      String? lastUpdated});
}

/// @nodoc
class __$RollingSummaryCopyWithImpl<$Res>
    implements _$RollingSummaryCopyWith<$Res> {
  __$RollingSummaryCopyWithImpl(this._self, this._then);

  final _RollingSummary _self;
  final $Res Function(_RollingSummary) _then;

  /// Create a copy of RollingSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? periodDays = null,
    Object? workoutComplianceRate = null,
    Object? workoutsCompleted = null,
    Object? workoutsSkipped = null,
    Object? avgSessionDurationMin = freezed,
    Object? recentWorkouts = null,
    Object? nutritionAvg = null,
    Object? recoveryAvg = null,
    Object? weightTrend = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_RollingSummary(
      periodDays: null == periodDays
          ? _self.periodDays
          : periodDays // ignore: cast_nullable_to_non_nullable
              as int,
      workoutComplianceRate: null == workoutComplianceRate
          ? _self.workoutComplianceRate
          : workoutComplianceRate // ignore: cast_nullable_to_non_nullable
              as double,
      workoutsCompleted: null == workoutsCompleted
          ? _self.workoutsCompleted
          : workoutsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsSkipped: null == workoutsSkipped
          ? _self.workoutsSkipped
          : workoutsSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      avgSessionDurationMin: freezed == avgSessionDurationMin
          ? _self.avgSessionDurationMin
          : avgSessionDurationMin // ignore: cast_nullable_to_non_nullable
              as double?,
      recentWorkouts: null == recentWorkouts
          ? _self._recentWorkouts
          : recentWorkouts // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      nutritionAvg: null == nutritionAvg
          ? _self._nutritionAvg
          : nutritionAvg // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      recoveryAvg: null == recoveryAvg
          ? _self._recoveryAvg
          : recoveryAvg // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      weightTrend: null == weightTrend
          ? _self._weightTrend
          : weightTrend // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      lastUpdated: freezed == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$MasterContext {
  DeducedKnowledge get deduced;
  RollingSummary get rollingSummary;

  /// Create a copy of MasterContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MasterContextCopyWith<MasterContext> get copyWith =>
      _$MasterContextCopyWithImpl<MasterContext>(
          this as MasterContext, _$identity);

  /// Serializes this MasterContext to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MasterContext &&
            (identical(other.deduced, deduced) || other.deduced == deduced) &&
            (identical(other.rollingSummary, rollingSummary) ||
                other.rollingSummary == rollingSummary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, deduced, rollingSummary);

  @override
  String toString() {
    return 'MasterContext(deduced: $deduced, rollingSummary: $rollingSummary)';
  }
}

/// @nodoc
abstract mixin class $MasterContextCopyWith<$Res> {
  factory $MasterContextCopyWith(
          MasterContext value, $Res Function(MasterContext) _then) =
      _$MasterContextCopyWithImpl;
  @useResult
  $Res call({DeducedKnowledge deduced, RollingSummary rollingSummary});

  $DeducedKnowledgeCopyWith<$Res> get deduced;
  $RollingSummaryCopyWith<$Res> get rollingSummary;
}

/// @nodoc
class _$MasterContextCopyWithImpl<$Res>
    implements $MasterContextCopyWith<$Res> {
  _$MasterContextCopyWithImpl(this._self, this._then);

  final MasterContext _self;
  final $Res Function(MasterContext) _then;

  /// Create a copy of MasterContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deduced = null,
    Object? rollingSummary = null,
  }) {
    return _then(_self.copyWith(
      deduced: null == deduced
          ? _self.deduced
          : deduced // ignore: cast_nullable_to_non_nullable
              as DeducedKnowledge,
      rollingSummary: null == rollingSummary
          ? _self.rollingSummary
          : rollingSummary // ignore: cast_nullable_to_non_nullable
              as RollingSummary,
    ));
  }

  /// Create a copy of MasterContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeducedKnowledgeCopyWith<$Res> get deduced {
    return $DeducedKnowledgeCopyWith<$Res>(_self.deduced, (value) {
      return _then(_self.copyWith(deduced: value));
    });
  }

  /// Create a copy of MasterContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RollingSummaryCopyWith<$Res> get rollingSummary {
    return $RollingSummaryCopyWith<$Res>(_self.rollingSummary, (value) {
      return _then(_self.copyWith(rollingSummary: value));
    });
  }
}

/// Adds pattern-matching-related methods to [MasterContext].
extension MasterContextPatterns on MasterContext {
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
    TResult Function(_MasterContext value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MasterContext() when $default != null:
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
    TResult Function(_MasterContext value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MasterContext():
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
    TResult? Function(_MasterContext value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MasterContext() when $default != null:
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
    TResult Function(DeducedKnowledge deduced, RollingSummary rollingSummary)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MasterContext() when $default != null:
        return $default(_that.deduced, _that.rollingSummary);
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
    TResult Function(DeducedKnowledge deduced, RollingSummary rollingSummary)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MasterContext():
        return $default(_that.deduced, _that.rollingSummary);
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
    TResult? Function(DeducedKnowledge deduced, RollingSummary rollingSummary)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MasterContext() when $default != null:
        return $default(_that.deduced, _that.rollingSummary);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MasterContext extends MasterContext {
  const _MasterContext(
      {this.deduced = const DeducedKnowledge(),
      this.rollingSummary = const RollingSummary()})
      : super._();
  factory _MasterContext.fromJson(Map<String, dynamic> json) =>
      _$MasterContextFromJson(json);

  @override
  @JsonKey()
  final DeducedKnowledge deduced;
  @override
  @JsonKey()
  final RollingSummary rollingSummary;

  /// Create a copy of MasterContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MasterContextCopyWith<_MasterContext> get copyWith =>
      __$MasterContextCopyWithImpl<_MasterContext>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MasterContextToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MasterContext &&
            (identical(other.deduced, deduced) || other.deduced == deduced) &&
            (identical(other.rollingSummary, rollingSummary) ||
                other.rollingSummary == rollingSummary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, deduced, rollingSummary);

  @override
  String toString() {
    return 'MasterContext(deduced: $deduced, rollingSummary: $rollingSummary)';
  }
}

/// @nodoc
abstract mixin class _$MasterContextCopyWith<$Res>
    implements $MasterContextCopyWith<$Res> {
  factory _$MasterContextCopyWith(
          _MasterContext value, $Res Function(_MasterContext) _then) =
      __$MasterContextCopyWithImpl;
  @override
  @useResult
  $Res call({DeducedKnowledge deduced, RollingSummary rollingSummary});

  @override
  $DeducedKnowledgeCopyWith<$Res> get deduced;
  @override
  $RollingSummaryCopyWith<$Res> get rollingSummary;
}

/// @nodoc
class __$MasterContextCopyWithImpl<$Res>
    implements _$MasterContextCopyWith<$Res> {
  __$MasterContextCopyWithImpl(this._self, this._then);

  final _MasterContext _self;
  final $Res Function(_MasterContext) _then;

  /// Create a copy of MasterContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? deduced = null,
    Object? rollingSummary = null,
  }) {
    return _then(_MasterContext(
      deduced: null == deduced
          ? _self.deduced
          : deduced // ignore: cast_nullable_to_non_nullable
              as DeducedKnowledge,
      rollingSummary: null == rollingSummary
          ? _self.rollingSummary
          : rollingSummary // ignore: cast_nullable_to_non_nullable
              as RollingSummary,
    ));
  }

  /// Create a copy of MasterContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeducedKnowledgeCopyWith<$Res> get deduced {
    return $DeducedKnowledgeCopyWith<$Res>(_self.deduced, (value) {
      return _then(_self.copyWith(deduced: value));
    });
  }

  /// Create a copy of MasterContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RollingSummaryCopyWith<$Res> get rollingSummary {
    return $RollingSummaryCopyWith<$Res>(_self.rollingSummary, (value) {
      return _then(_self.copyWith(rollingSummary: value));
    });
  }
}

// dart format on
