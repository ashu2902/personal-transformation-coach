// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EquipmentItem {
  String get name;
  String get category;
  double? get weightKg;
  String? get notes;

  /// Create a copy of EquipmentItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EquipmentItemCopyWith<EquipmentItem> get copyWith =>
      _$EquipmentItemCopyWithImpl<EquipmentItem>(
          this as EquipmentItem, _$identity);

  /// Serializes this EquipmentItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EquipmentItem &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, category, weightKg, notes);
}

/// @nodoc
abstract mixin class $EquipmentItemCopyWith<$Res> {
  factory $EquipmentItemCopyWith(
          EquipmentItem value, $Res Function(EquipmentItem) _then) =
      _$EquipmentItemCopyWithImpl;
  @useResult
  $Res call({String name, String category, double? weightKg, String? notes});
}

/// @nodoc
class _$EquipmentItemCopyWithImpl<$Res>
    implements $EquipmentItemCopyWith<$Res> {
  _$EquipmentItemCopyWithImpl(this._self, this._then);

  final EquipmentItem _self;
  final $Res Function(EquipmentItem) _then;

  /// Create a copy of EquipmentItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? category = null,
    Object? weightKg = freezed,
    Object? notes = freezed,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      weightKg: freezed == weightKg
          ? _self.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [EquipmentItem].
extension EquipmentItemPatterns on EquipmentItem {
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
    TResult Function(_EquipmentItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EquipmentItem() when $default != null:
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
    TResult Function(_EquipmentItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EquipmentItem():
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
    TResult? Function(_EquipmentItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EquipmentItem() when $default != null:
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
            String name, String category, double? weightKg, String? notes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EquipmentItem() when $default != null:
        return $default(
            _that.name, _that.category, _that.weightKg, _that.notes);
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
            String name, String category, double? weightKg, String? notes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EquipmentItem():
        return $default(
            _that.name, _that.category, _that.weightKg, _that.notes);
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
            String name, String category, double? weightKg, String? notes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EquipmentItem() when $default != null:
        return $default(
            _that.name, _that.category, _that.weightKg, _that.notes);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _EquipmentItem extends EquipmentItem {
  const _EquipmentItem(
      {required this.name,
      this.category = 'free_weight',
      this.weightKg,
      this.notes})
      : super._();
  factory _EquipmentItem.fromJson(Map<String, dynamic> json) =>
      _$EquipmentItemFromJson(json);

  @override
  final String name;
  @override
  @JsonKey()
  final String category;
  @override
  final double? weightKg;
  @override
  final String? notes;

  /// Create a copy of EquipmentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EquipmentItemCopyWith<_EquipmentItem> get copyWith =>
      __$EquipmentItemCopyWithImpl<_EquipmentItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$EquipmentItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EquipmentItem &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, category, weightKg, notes);
}

/// @nodoc
abstract mixin class _$EquipmentItemCopyWith<$Res>
    implements $EquipmentItemCopyWith<$Res> {
  factory _$EquipmentItemCopyWith(
          _EquipmentItem value, $Res Function(_EquipmentItem) _then) =
      __$EquipmentItemCopyWithImpl;
  @override
  @useResult
  $Res call({String name, String category, double? weightKg, String? notes});
}

/// @nodoc
class __$EquipmentItemCopyWithImpl<$Res>
    implements _$EquipmentItemCopyWith<$Res> {
  __$EquipmentItemCopyWithImpl(this._self, this._then);

  final _EquipmentItem _self;
  final $Res Function(_EquipmentItem) _then;

  /// Create a copy of EquipmentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? category = null,
    Object? weightKg = freezed,
    Object? notes = freezed,
  }) {
    return _then(_EquipmentItem(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      weightKg: freezed == weightKg
          ? _self.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$UserProfile {
  String get name;
  int get age;
  String get gender;
  double get heightCm;
  double get weightKg;
  double get targetWeightKg;
  GoalType get goal;
  int get daysPerWeek;
  String get targetPhysique;
  List<EquipmentItem> get equipmentList;
  ExperienceLevel get experienceLevel;
  double? get benchPress1RMKg;
  double? get squat1RMKg;
  double? get deadlift1RMKg;
  List<String> get activeInjuries;
  List<String> get dislikedExercises;
  List<String> get personalNotes;
  CoachSoul get coachSoul;
  String get dietaryPreference;
  String? get createdAtDateStr;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserProfileCopyWith<UserProfile> get copyWith =>
      _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserProfile &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.targetWeightKg, targetWeightKg) ||
                other.targetWeightKg == targetWeightKg) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.daysPerWeek, daysPerWeek) ||
                other.daysPerWeek == daysPerWeek) &&
            (identical(other.targetPhysique, targetPhysique) ||
                other.targetPhysique == targetPhysique) &&
            const DeepCollectionEquality()
                .equals(other.equipmentList, equipmentList) &&
            (identical(other.experienceLevel, experienceLevel) ||
                other.experienceLevel == experienceLevel) &&
            (identical(other.benchPress1RMKg, benchPress1RMKg) ||
                other.benchPress1RMKg == benchPress1RMKg) &&
            (identical(other.squat1RMKg, squat1RMKg) ||
                other.squat1RMKg == squat1RMKg) &&
            (identical(other.deadlift1RMKg, deadlift1RMKg) ||
                other.deadlift1RMKg == deadlift1RMKg) &&
            const DeepCollectionEquality()
                .equals(other.activeInjuries, activeInjuries) &&
            const DeepCollectionEquality()
                .equals(other.dislikedExercises, dislikedExercises) &&
            const DeepCollectionEquality()
                .equals(other.personalNotes, personalNotes) &&
            (identical(other.coachSoul, coachSoul) ||
                other.coachSoul == coachSoul) &&
            (identical(other.dietaryPreference, dietaryPreference) ||
                other.dietaryPreference == dietaryPreference) &&
            (identical(other.createdAtDateStr, createdAtDateStr) ||
                other.createdAtDateStr == createdAtDateStr));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        name,
        age,
        gender,
        heightCm,
        weightKg,
        targetWeightKg,
        goal,
        daysPerWeek,
        targetPhysique,
        const DeepCollectionEquality().hash(equipmentList),
        experienceLevel,
        benchPress1RMKg,
        squat1RMKg,
        deadlift1RMKg,
        const DeepCollectionEquality().hash(activeInjuries),
        const DeepCollectionEquality().hash(dislikedExercises),
        const DeepCollectionEquality().hash(personalNotes),
        coachSoul,
        dietaryPreference,
        createdAtDateStr
      ]);

  @override
  String toString() {
    return 'UserProfile(name: $name, age: $age, gender: $gender, heightCm: $heightCm, weightKg: $weightKg, targetWeightKg: $targetWeightKg, goal: $goal, daysPerWeek: $daysPerWeek, targetPhysique: $targetPhysique, equipmentList: $equipmentList, experienceLevel: $experienceLevel, benchPress1RMKg: $benchPress1RMKg, squat1RMKg: $squat1RMKg, deadlift1RMKg: $deadlift1RMKg, activeInjuries: $activeInjuries, dislikedExercises: $dislikedExercises, personalNotes: $personalNotes, coachSoul: $coachSoul, dietaryPreference: $dietaryPreference, createdAtDateStr: $createdAtDateStr)';
  }
}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) _then) =
      _$UserProfileCopyWithImpl;
  @useResult
  $Res call(
      {String name,
      int age,
      String gender,
      double heightCm,
      double weightKg,
      double targetWeightKg,
      GoalType goal,
      int daysPerWeek,
      String targetPhysique,
      List<EquipmentItem> equipmentList,
      ExperienceLevel experienceLevel,
      double? benchPress1RMKg,
      double? squat1RMKg,
      double? deadlift1RMKg,
      List<String> activeInjuries,
      List<String> dislikedExercises,
      List<String> personalNotes,
      CoachSoul coachSoul,
      String dietaryPreference,
      String? createdAtDateStr});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res> implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? age = null,
    Object? gender = null,
    Object? heightCm = null,
    Object? weightKg = null,
    Object? targetWeightKg = null,
    Object? goal = null,
    Object? daysPerWeek = null,
    Object? targetPhysique = null,
    Object? equipmentList = null,
    Object? experienceLevel = null,
    Object? benchPress1RMKg = freezed,
    Object? squat1RMKg = freezed,
    Object? deadlift1RMKg = freezed,
    Object? activeInjuries = null,
    Object? dislikedExercises = null,
    Object? personalNotes = null,
    Object? coachSoul = null,
    Object? dietaryPreference = null,
    Object? createdAtDateStr = freezed,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _self.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      heightCm: null == heightCm
          ? _self.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double,
      weightKg: null == weightKg
          ? _self.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      targetWeightKg: null == targetWeightKg
          ? _self.targetWeightKg
          : targetWeightKg // ignore: cast_nullable_to_non_nullable
              as double,
      goal: null == goal
          ? _self.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as GoalType,
      daysPerWeek: null == daysPerWeek
          ? _self.daysPerWeek
          : daysPerWeek // ignore: cast_nullable_to_non_nullable
              as int,
      targetPhysique: null == targetPhysique
          ? _self.targetPhysique
          : targetPhysique // ignore: cast_nullable_to_non_nullable
              as String,
      equipmentList: null == equipmentList
          ? _self.equipmentList
          : equipmentList // ignore: cast_nullable_to_non_nullable
              as List<EquipmentItem>,
      experienceLevel: null == experienceLevel
          ? _self.experienceLevel
          : experienceLevel // ignore: cast_nullable_to_non_nullable
              as ExperienceLevel,
      benchPress1RMKg: freezed == benchPress1RMKg
          ? _self.benchPress1RMKg
          : benchPress1RMKg // ignore: cast_nullable_to_non_nullable
              as double?,
      squat1RMKg: freezed == squat1RMKg
          ? _self.squat1RMKg
          : squat1RMKg // ignore: cast_nullable_to_non_nullable
              as double?,
      deadlift1RMKg: freezed == deadlift1RMKg
          ? _self.deadlift1RMKg
          : deadlift1RMKg // ignore: cast_nullable_to_non_nullable
              as double?,
      activeInjuries: null == activeInjuries
          ? _self.activeInjuries
          : activeInjuries // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dislikedExercises: null == dislikedExercises
          ? _self.dislikedExercises
          : dislikedExercises // ignore: cast_nullable_to_non_nullable
              as List<String>,
      personalNotes: null == personalNotes
          ? _self.personalNotes
          : personalNotes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      coachSoul: null == coachSoul
          ? _self.coachSoul
          : coachSoul // ignore: cast_nullable_to_non_nullable
              as CoachSoul,
      dietaryPreference: null == dietaryPreference
          ? _self.dietaryPreference
          : dietaryPreference // ignore: cast_nullable_to_non_nullable
              as String,
      createdAtDateStr: freezed == createdAtDateStr
          ? _self.createdAtDateStr
          : createdAtDateStr // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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
    TResult Function(_UserProfile value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserProfile() when $default != null:
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
    TResult Function(_UserProfile value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserProfile():
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
    TResult? Function(_UserProfile value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserProfile() when $default != null:
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
            String name,
            int age,
            String gender,
            double heightCm,
            double weightKg,
            double targetWeightKg,
            GoalType goal,
            int daysPerWeek,
            String targetPhysique,
            List<EquipmentItem> equipmentList,
            ExperienceLevel experienceLevel,
            double? benchPress1RMKg,
            double? squat1RMKg,
            double? deadlift1RMKg,
            List<String> activeInjuries,
            List<String> dislikedExercises,
            List<String> personalNotes,
            CoachSoul coachSoul,
            String dietaryPreference,
            String? createdAtDateStr)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserProfile() when $default != null:
        return $default(
            _that.name,
            _that.age,
            _that.gender,
            _that.heightCm,
            _that.weightKg,
            _that.targetWeightKg,
            _that.goal,
            _that.daysPerWeek,
            _that.targetPhysique,
            _that.equipmentList,
            _that.experienceLevel,
            _that.benchPress1RMKg,
            _that.squat1RMKg,
            _that.deadlift1RMKg,
            _that.activeInjuries,
            _that.dislikedExercises,
            _that.personalNotes,
            _that.coachSoul,
            _that.dietaryPreference,
            _that.createdAtDateStr);
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
            String name,
            int age,
            String gender,
            double heightCm,
            double weightKg,
            double targetWeightKg,
            GoalType goal,
            int daysPerWeek,
            String targetPhysique,
            List<EquipmentItem> equipmentList,
            ExperienceLevel experienceLevel,
            double? benchPress1RMKg,
            double? squat1RMKg,
            double? deadlift1RMKg,
            List<String> activeInjuries,
            List<String> dislikedExercises,
            List<String> personalNotes,
            CoachSoul coachSoul,
            String dietaryPreference,
            String? createdAtDateStr)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserProfile():
        return $default(
            _that.name,
            _that.age,
            _that.gender,
            _that.heightCm,
            _that.weightKg,
            _that.targetWeightKg,
            _that.goal,
            _that.daysPerWeek,
            _that.targetPhysique,
            _that.equipmentList,
            _that.experienceLevel,
            _that.benchPress1RMKg,
            _that.squat1RMKg,
            _that.deadlift1RMKg,
            _that.activeInjuries,
            _that.dislikedExercises,
            _that.personalNotes,
            _that.coachSoul,
            _that.dietaryPreference,
            _that.createdAtDateStr);
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
            String name,
            int age,
            String gender,
            double heightCm,
            double weightKg,
            double targetWeightKg,
            GoalType goal,
            int daysPerWeek,
            String targetPhysique,
            List<EquipmentItem> equipmentList,
            ExperienceLevel experienceLevel,
            double? benchPress1RMKg,
            double? squat1RMKg,
            double? deadlift1RMKg,
            List<String> activeInjuries,
            List<String> dislikedExercises,
            List<String> personalNotes,
            CoachSoul coachSoul,
            String dietaryPreference,
            String? createdAtDateStr)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserProfile() when $default != null:
        return $default(
            _that.name,
            _that.age,
            _that.gender,
            _that.heightCm,
            _that.weightKg,
            _that.targetWeightKg,
            _that.goal,
            _that.daysPerWeek,
            _that.targetPhysique,
            _that.equipmentList,
            _that.experienceLevel,
            _that.benchPress1RMKg,
            _that.squat1RMKg,
            _that.deadlift1RMKg,
            _that.activeInjuries,
            _that.dislikedExercises,
            _that.personalNotes,
            _that.coachSoul,
            _that.dietaryPreference,
            _that.createdAtDateStr);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _UserProfile extends UserProfile {
  const _UserProfile(
      {required this.name,
      required this.age,
      required this.gender,
      required this.heightCm,
      required this.weightKg,
      required this.targetWeightKg,
      required this.goal,
      required this.daysPerWeek,
      required this.targetPhysique,
      final List<EquipmentItem> equipmentList = const [
        EquipmentItem(name: 'Bodyweight', category: 'bodyweight')
      ],
      this.experienceLevel = ExperienceLevel.intermediate,
      this.benchPress1RMKg,
      this.squat1RMKg,
      this.deadlift1RMKg,
      final List<String> activeInjuries = const [],
      final List<String> dislikedExercises = const [],
      final List<String> personalNotes = const [],
      this.coachSoul = CoachSoul.supporter,
      this.dietaryPreference = 'nonVeg',
      this.createdAtDateStr})
      : _equipmentList = equipmentList,
        _activeInjuries = activeInjuries,
        _dislikedExercises = dislikedExercises,
        _personalNotes = personalNotes,
        super._();
  factory _UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  @override
  final String name;
  @override
  final int age;
  @override
  final String gender;
  @override
  final double heightCm;
  @override
  final double weightKg;
  @override
  final double targetWeightKg;
  @override
  final GoalType goal;
  @override
  final int daysPerWeek;
  @override
  final String targetPhysique;
  final List<EquipmentItem> _equipmentList;
  @override
  @JsonKey()
  List<EquipmentItem> get equipmentList {
    if (_equipmentList is EqualUnmodifiableListView) return _equipmentList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipmentList);
  }

  @override
  @JsonKey()
  final ExperienceLevel experienceLevel;
  @override
  final double? benchPress1RMKg;
  @override
  final double? squat1RMKg;
  @override
  final double? deadlift1RMKg;
  final List<String> _activeInjuries;
  @override
  @JsonKey()
  List<String> get activeInjuries {
    if (_activeInjuries is EqualUnmodifiableListView) return _activeInjuries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeInjuries);
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

  final List<String> _personalNotes;
  @override
  @JsonKey()
  List<String> get personalNotes {
    if (_personalNotes is EqualUnmodifiableListView) return _personalNotes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_personalNotes);
  }

  @override
  @JsonKey()
  final CoachSoul coachSoul;
  @override
  @JsonKey()
  final String dietaryPreference;
  @override
  final String? createdAtDateStr;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserProfileCopyWith<_UserProfile> get copyWith =>
      __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserProfileToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserProfile &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.targetWeightKg, targetWeightKg) ||
                other.targetWeightKg == targetWeightKg) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.daysPerWeek, daysPerWeek) ||
                other.daysPerWeek == daysPerWeek) &&
            (identical(other.targetPhysique, targetPhysique) ||
                other.targetPhysique == targetPhysique) &&
            const DeepCollectionEquality()
                .equals(other._equipmentList, _equipmentList) &&
            (identical(other.experienceLevel, experienceLevel) ||
                other.experienceLevel == experienceLevel) &&
            (identical(other.benchPress1RMKg, benchPress1RMKg) ||
                other.benchPress1RMKg == benchPress1RMKg) &&
            (identical(other.squat1RMKg, squat1RMKg) ||
                other.squat1RMKg == squat1RMKg) &&
            (identical(other.deadlift1RMKg, deadlift1RMKg) ||
                other.deadlift1RMKg == deadlift1RMKg) &&
            const DeepCollectionEquality()
                .equals(other._activeInjuries, _activeInjuries) &&
            const DeepCollectionEquality()
                .equals(other._dislikedExercises, _dislikedExercises) &&
            const DeepCollectionEquality()
                .equals(other._personalNotes, _personalNotes) &&
            (identical(other.coachSoul, coachSoul) ||
                other.coachSoul == coachSoul) &&
            (identical(other.dietaryPreference, dietaryPreference) ||
                other.dietaryPreference == dietaryPreference) &&
            (identical(other.createdAtDateStr, createdAtDateStr) ||
                other.createdAtDateStr == createdAtDateStr));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        name,
        age,
        gender,
        heightCm,
        weightKg,
        targetWeightKg,
        goal,
        daysPerWeek,
        targetPhysique,
        const DeepCollectionEquality().hash(_equipmentList),
        experienceLevel,
        benchPress1RMKg,
        squat1RMKg,
        deadlift1RMKg,
        const DeepCollectionEquality().hash(_activeInjuries),
        const DeepCollectionEquality().hash(_dislikedExercises),
        const DeepCollectionEquality().hash(_personalNotes),
        coachSoul,
        dietaryPreference,
        createdAtDateStr
      ]);

  @override
  String toString() {
    return 'UserProfile(name: $name, age: $age, gender: $gender, heightCm: $heightCm, weightKg: $weightKg, targetWeightKg: $targetWeightKg, goal: $goal, daysPerWeek: $daysPerWeek, targetPhysique: $targetPhysique, equipmentList: $equipmentList, experienceLevel: $experienceLevel, benchPress1RMKg: $benchPress1RMKg, squat1RMKg: $squat1RMKg, deadlift1RMKg: $deadlift1RMKg, activeInjuries: $activeInjuries, dislikedExercises: $dislikedExercises, personalNotes: $personalNotes, coachSoul: $coachSoul, dietaryPreference: $dietaryPreference, createdAtDateStr: $createdAtDateStr)';
  }
}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(
          _UserProfile value, $Res Function(_UserProfile) _then) =
      __$UserProfileCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String name,
      int age,
      String gender,
      double heightCm,
      double weightKg,
      double targetWeightKg,
      GoalType goal,
      int daysPerWeek,
      String targetPhysique,
      List<EquipmentItem> equipmentList,
      ExperienceLevel experienceLevel,
      double? benchPress1RMKg,
      double? squat1RMKg,
      double? deadlift1RMKg,
      List<String> activeInjuries,
      List<String> dislikedExercises,
      List<String> personalNotes,
      CoachSoul coachSoul,
      String dietaryPreference,
      String? createdAtDateStr});
}

/// @nodoc
class __$UserProfileCopyWithImpl<$Res> implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? age = null,
    Object? gender = null,
    Object? heightCm = null,
    Object? weightKg = null,
    Object? targetWeightKg = null,
    Object? goal = null,
    Object? daysPerWeek = null,
    Object? targetPhysique = null,
    Object? equipmentList = null,
    Object? experienceLevel = null,
    Object? benchPress1RMKg = freezed,
    Object? squat1RMKg = freezed,
    Object? deadlift1RMKg = freezed,
    Object? activeInjuries = null,
    Object? dislikedExercises = null,
    Object? personalNotes = null,
    Object? coachSoul = null,
    Object? dietaryPreference = null,
    Object? createdAtDateStr = freezed,
  }) {
    return _then(_UserProfile(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _self.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      heightCm: null == heightCm
          ? _self.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double,
      weightKg: null == weightKg
          ? _self.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      targetWeightKg: null == targetWeightKg
          ? _self.targetWeightKg
          : targetWeightKg // ignore: cast_nullable_to_non_nullable
              as double,
      goal: null == goal
          ? _self.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as GoalType,
      daysPerWeek: null == daysPerWeek
          ? _self.daysPerWeek
          : daysPerWeek // ignore: cast_nullable_to_non_nullable
              as int,
      targetPhysique: null == targetPhysique
          ? _self.targetPhysique
          : targetPhysique // ignore: cast_nullable_to_non_nullable
              as String,
      equipmentList: null == equipmentList
          ? _self._equipmentList
          : equipmentList // ignore: cast_nullable_to_non_nullable
              as List<EquipmentItem>,
      experienceLevel: null == experienceLevel
          ? _self.experienceLevel
          : experienceLevel // ignore: cast_nullable_to_non_nullable
              as ExperienceLevel,
      benchPress1RMKg: freezed == benchPress1RMKg
          ? _self.benchPress1RMKg
          : benchPress1RMKg // ignore: cast_nullable_to_non_nullable
              as double?,
      squat1RMKg: freezed == squat1RMKg
          ? _self.squat1RMKg
          : squat1RMKg // ignore: cast_nullable_to_non_nullable
              as double?,
      deadlift1RMKg: freezed == deadlift1RMKg
          ? _self.deadlift1RMKg
          : deadlift1RMKg // ignore: cast_nullable_to_non_nullable
              as double?,
      activeInjuries: null == activeInjuries
          ? _self._activeInjuries
          : activeInjuries // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dislikedExercises: null == dislikedExercises
          ? _self._dislikedExercises
          : dislikedExercises // ignore: cast_nullable_to_non_nullable
              as List<String>,
      personalNotes: null == personalNotes
          ? _self._personalNotes
          : personalNotes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      coachSoul: null == coachSoul
          ? _self.coachSoul
          : coachSoul // ignore: cast_nullable_to_non_nullable
              as CoachSoul,
      dietaryPreference: null == dietaryPreference
          ? _self.dietaryPreference
          : dietaryPreference // ignore: cast_nullable_to_non_nullable
              as String,
      createdAtDateStr: freezed == createdAtDateStr
          ? _self.createdAtDateStr
          : createdAtDateStr // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
