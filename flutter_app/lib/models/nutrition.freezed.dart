// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MealItem {
  String get name;
  int get calories;
  int get proteinG;
  int get carbsG;
  int get fatG;

  /// Create a copy of MealItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MealItemCopyWith<MealItem> get copyWith =>
      _$MealItemCopyWithImpl<MealItem>(this as MealItem, _$identity);

  /// Serializes this MealItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MealItem &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.proteinG, proteinG) ||
                other.proteinG == proteinG) &&
            (identical(other.carbsG, carbsG) || other.carbsG == carbsG) &&
            (identical(other.fatG, fatG) || other.fatG == fatG));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, calories, proteinG, carbsG, fatG);

  @override
  String toString() {
    return 'MealItem(name: $name, calories: $calories, proteinG: $proteinG, carbsG: $carbsG, fatG: $fatG)';
  }
}

/// @nodoc
abstract mixin class $MealItemCopyWith<$Res> {
  factory $MealItemCopyWith(MealItem value, $Res Function(MealItem) _then) =
      _$MealItemCopyWithImpl;
  @useResult
  $Res call({String name, int calories, int proteinG, int carbsG, int fatG});
}

/// @nodoc
class _$MealItemCopyWithImpl<$Res> implements $MealItemCopyWith<$Res> {
  _$MealItemCopyWithImpl(this._self, this._then);

  final MealItem _self;
  final $Res Function(MealItem) _then;

  /// Create a copy of MealItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? calories = null,
    Object? proteinG = null,
    Object? carbsG = null,
    Object? fatG = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      calories: null == calories
          ? _self.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      proteinG: null == proteinG
          ? _self.proteinG
          : proteinG // ignore: cast_nullable_to_non_nullable
              as int,
      carbsG: null == carbsG
          ? _self.carbsG
          : carbsG // ignore: cast_nullable_to_non_nullable
              as int,
      fatG: null == fatG
          ? _self.fatG
          : fatG // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [MealItem].
extension MealItemPatterns on MealItem {
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
    TResult Function(_MealItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MealItem() when $default != null:
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
    TResult Function(_MealItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MealItem():
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
    TResult? Function(_MealItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MealItem() when $default != null:
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
            String name, int calories, int proteinG, int carbsG, int fatG)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MealItem() when $default != null:
        return $default(_that.name, _that.calories, _that.proteinG,
            _that.carbsG, _that.fatG);
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
            String name, int calories, int proteinG, int carbsG, int fatG)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MealItem():
        return $default(_that.name, _that.calories, _that.proteinG,
            _that.carbsG, _that.fatG);
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
            String name, int calories, int proteinG, int carbsG, int fatG)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MealItem() when $default != null:
        return $default(_that.name, _that.calories, _that.proteinG,
            _that.carbsG, _that.fatG);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _MealItem extends MealItem {
  const _MealItem(
      {required this.name,
      required this.calories,
      required this.proteinG,
      required this.carbsG,
      required this.fatG})
      : super._();
  factory _MealItem.fromJson(Map<String, dynamic> json) =>
      _$MealItemFromJson(json);

  @override
  final String name;
  @override
  final int calories;
  @override
  final int proteinG;
  @override
  final int carbsG;
  @override
  final int fatG;

  /// Create a copy of MealItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MealItemCopyWith<_MealItem> get copyWith =>
      __$MealItemCopyWithImpl<_MealItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MealItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MealItem &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.proteinG, proteinG) ||
                other.proteinG == proteinG) &&
            (identical(other.carbsG, carbsG) || other.carbsG == carbsG) &&
            (identical(other.fatG, fatG) || other.fatG == fatG));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, calories, proteinG, carbsG, fatG);

  @override
  String toString() {
    return 'MealItem(name: $name, calories: $calories, proteinG: $proteinG, carbsG: $carbsG, fatG: $fatG)';
  }
}

/// @nodoc
abstract mixin class _$MealItemCopyWith<$Res>
    implements $MealItemCopyWith<$Res> {
  factory _$MealItemCopyWith(_MealItem value, $Res Function(_MealItem) _then) =
      __$MealItemCopyWithImpl;
  @override
  @useResult
  $Res call({String name, int calories, int proteinG, int carbsG, int fatG});
}

/// @nodoc
class __$MealItemCopyWithImpl<$Res> implements _$MealItemCopyWith<$Res> {
  __$MealItemCopyWithImpl(this._self, this._then);

  final _MealItem _self;
  final $Res Function(_MealItem) _then;

  /// Create a copy of MealItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? calories = null,
    Object? proteinG = null,
    Object? carbsG = null,
    Object? fatG = null,
  }) {
    return _then(_MealItem(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      calories: null == calories
          ? _self.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      proteinG: null == proteinG
          ? _self.proteinG
          : proteinG // ignore: cast_nullable_to_non_nullable
              as int,
      carbsG: null == carbsG
          ? _self.carbsG
          : carbsG // ignore: cast_nullable_to_non_nullable
              as int,
      fatG: null == fatG
          ? _self.fatG
          : fatG // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$DailyNutrition {
  String get date;
  int get targetCalories;
  int get targetProteinG;
  int get targetCarbsG;
  int get targetFatG;
  int get waterMl;
  int get targetWaterMl;
  List<MealItem> get meals;

  /// Create a copy of DailyNutrition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DailyNutritionCopyWith<DailyNutrition> get copyWith =>
      _$DailyNutritionCopyWithImpl<DailyNutrition>(
          this as DailyNutrition, _$identity);

  /// Serializes this DailyNutrition to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DailyNutrition &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.targetCalories, targetCalories) ||
                other.targetCalories == targetCalories) &&
            (identical(other.targetProteinG, targetProteinG) ||
                other.targetProteinG == targetProteinG) &&
            (identical(other.targetCarbsG, targetCarbsG) ||
                other.targetCarbsG == targetCarbsG) &&
            (identical(other.targetFatG, targetFatG) ||
                other.targetFatG == targetFatG) &&
            (identical(other.waterMl, waterMl) || other.waterMl == waterMl) &&
            (identical(other.targetWaterMl, targetWaterMl) ||
                other.targetWaterMl == targetWaterMl) &&
            const DeepCollectionEquality().equals(other.meals, meals));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      targetCalories,
      targetProteinG,
      targetCarbsG,
      targetFatG,
      waterMl,
      targetWaterMl,
      const DeepCollectionEquality().hash(meals));

  @override
  String toString() {
    return 'DailyNutrition(date: $date, targetCalories: $targetCalories, targetProteinG: $targetProteinG, targetCarbsG: $targetCarbsG, targetFatG: $targetFatG, waterMl: $waterMl, targetWaterMl: $targetWaterMl, meals: $meals)';
  }
}

/// @nodoc
abstract mixin class $DailyNutritionCopyWith<$Res> {
  factory $DailyNutritionCopyWith(
          DailyNutrition value, $Res Function(DailyNutrition) _then) =
      _$DailyNutritionCopyWithImpl;
  @useResult
  $Res call(
      {String date,
      int targetCalories,
      int targetProteinG,
      int targetCarbsG,
      int targetFatG,
      int waterMl,
      int targetWaterMl,
      List<MealItem> meals});
}

/// @nodoc
class _$DailyNutritionCopyWithImpl<$Res>
    implements $DailyNutritionCopyWith<$Res> {
  _$DailyNutritionCopyWithImpl(this._self, this._then);

  final DailyNutrition _self;
  final $Res Function(DailyNutrition) _then;

  /// Create a copy of DailyNutrition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? targetCalories = null,
    Object? targetProteinG = null,
    Object? targetCarbsG = null,
    Object? targetFatG = null,
    Object? waterMl = null,
    Object? targetWaterMl = null,
    Object? meals = null,
  }) {
    return _then(_self.copyWith(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      targetCalories: null == targetCalories
          ? _self.targetCalories
          : targetCalories // ignore: cast_nullable_to_non_nullable
              as int,
      targetProteinG: null == targetProteinG
          ? _self.targetProteinG
          : targetProteinG // ignore: cast_nullable_to_non_nullable
              as int,
      targetCarbsG: null == targetCarbsG
          ? _self.targetCarbsG
          : targetCarbsG // ignore: cast_nullable_to_non_nullable
              as int,
      targetFatG: null == targetFatG
          ? _self.targetFatG
          : targetFatG // ignore: cast_nullable_to_non_nullable
              as int,
      waterMl: null == waterMl
          ? _self.waterMl
          : waterMl // ignore: cast_nullable_to_non_nullable
              as int,
      targetWaterMl: null == targetWaterMl
          ? _self.targetWaterMl
          : targetWaterMl // ignore: cast_nullable_to_non_nullable
              as int,
      meals: null == meals
          ? _self.meals
          : meals // ignore: cast_nullable_to_non_nullable
              as List<MealItem>,
    ));
  }
}

/// Adds pattern-matching-related methods to [DailyNutrition].
extension DailyNutritionPatterns on DailyNutrition {
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
    TResult Function(_DailyNutrition value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DailyNutrition() when $default != null:
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
    TResult Function(_DailyNutrition value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyNutrition():
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
    TResult? Function(_DailyNutrition value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyNutrition() when $default != null:
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
            int targetCalories,
            int targetProteinG,
            int targetCarbsG,
            int targetFatG,
            int waterMl,
            int targetWaterMl,
            List<MealItem> meals)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DailyNutrition() when $default != null:
        return $default(
            _that.date,
            _that.targetCalories,
            _that.targetProteinG,
            _that.targetCarbsG,
            _that.targetFatG,
            _that.waterMl,
            _that.targetWaterMl,
            _that.meals);
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
            int targetCalories,
            int targetProteinG,
            int targetCarbsG,
            int targetFatG,
            int waterMl,
            int targetWaterMl,
            List<MealItem> meals)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyNutrition():
        return $default(
            _that.date,
            _that.targetCalories,
            _that.targetProteinG,
            _that.targetCarbsG,
            _that.targetFatG,
            _that.waterMl,
            _that.targetWaterMl,
            _that.meals);
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
            int targetCalories,
            int targetProteinG,
            int targetCarbsG,
            int targetFatG,
            int waterMl,
            int targetWaterMl,
            List<MealItem> meals)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyNutrition() when $default != null:
        return $default(
            _that.date,
            _that.targetCalories,
            _that.targetProteinG,
            _that.targetCarbsG,
            _that.targetFatG,
            _that.waterMl,
            _that.targetWaterMl,
            _that.meals);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _DailyNutrition extends DailyNutrition {
  const _DailyNutrition(
      {required this.date,
      required this.targetCalories,
      required this.targetProteinG,
      required this.targetCarbsG,
      required this.targetFatG,
      this.waterMl = 0,
      this.targetWaterMl = 3200,
      final List<MealItem> meals = const []})
      : _meals = meals,
        super._();
  factory _DailyNutrition.fromJson(Map<String, dynamic> json) =>
      _$DailyNutritionFromJson(json);

  @override
  final String date;
  @override
  final int targetCalories;
  @override
  final int targetProteinG;
  @override
  final int targetCarbsG;
  @override
  final int targetFatG;
  @override
  @JsonKey()
  final int waterMl;
  @override
  @JsonKey()
  final int targetWaterMl;
  final List<MealItem> _meals;
  @override
  @JsonKey()
  List<MealItem> get meals {
    if (_meals is EqualUnmodifiableListView) return _meals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meals);
  }

  /// Create a copy of DailyNutrition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DailyNutritionCopyWith<_DailyNutrition> get copyWith =>
      __$DailyNutritionCopyWithImpl<_DailyNutrition>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DailyNutritionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DailyNutrition &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.targetCalories, targetCalories) ||
                other.targetCalories == targetCalories) &&
            (identical(other.targetProteinG, targetProteinG) ||
                other.targetProteinG == targetProteinG) &&
            (identical(other.targetCarbsG, targetCarbsG) ||
                other.targetCarbsG == targetCarbsG) &&
            (identical(other.targetFatG, targetFatG) ||
                other.targetFatG == targetFatG) &&
            (identical(other.waterMl, waterMl) || other.waterMl == waterMl) &&
            (identical(other.targetWaterMl, targetWaterMl) ||
                other.targetWaterMl == targetWaterMl) &&
            const DeepCollectionEquality().equals(other._meals, _meals));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      targetCalories,
      targetProteinG,
      targetCarbsG,
      targetFatG,
      waterMl,
      targetWaterMl,
      const DeepCollectionEquality().hash(_meals));

  @override
  String toString() {
    return 'DailyNutrition(date: $date, targetCalories: $targetCalories, targetProteinG: $targetProteinG, targetCarbsG: $targetCarbsG, targetFatG: $targetFatG, waterMl: $waterMl, targetWaterMl: $targetWaterMl, meals: $meals)';
  }
}

/// @nodoc
abstract mixin class _$DailyNutritionCopyWith<$Res>
    implements $DailyNutritionCopyWith<$Res> {
  factory _$DailyNutritionCopyWith(
          _DailyNutrition value, $Res Function(_DailyNutrition) _then) =
      __$DailyNutritionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String date,
      int targetCalories,
      int targetProteinG,
      int targetCarbsG,
      int targetFatG,
      int waterMl,
      int targetWaterMl,
      List<MealItem> meals});
}

/// @nodoc
class __$DailyNutritionCopyWithImpl<$Res>
    implements _$DailyNutritionCopyWith<$Res> {
  __$DailyNutritionCopyWithImpl(this._self, this._then);

  final _DailyNutrition _self;
  final $Res Function(_DailyNutrition) _then;

  /// Create a copy of DailyNutrition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? date = null,
    Object? targetCalories = null,
    Object? targetProteinG = null,
    Object? targetCarbsG = null,
    Object? targetFatG = null,
    Object? waterMl = null,
    Object? targetWaterMl = null,
    Object? meals = null,
  }) {
    return _then(_DailyNutrition(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      targetCalories: null == targetCalories
          ? _self.targetCalories
          : targetCalories // ignore: cast_nullable_to_non_nullable
              as int,
      targetProteinG: null == targetProteinG
          ? _self.targetProteinG
          : targetProteinG // ignore: cast_nullable_to_non_nullable
              as int,
      targetCarbsG: null == targetCarbsG
          ? _self.targetCarbsG
          : targetCarbsG // ignore: cast_nullable_to_non_nullable
              as int,
      targetFatG: null == targetFatG
          ? _self.targetFatG
          : targetFatG // ignore: cast_nullable_to_non_nullable
              as int,
      waterMl: null == waterMl
          ? _self.waterMl
          : waterMl // ignore: cast_nullable_to_non_nullable
              as int,
      targetWaterMl: null == targetWaterMl
          ? _self.targetWaterMl
          : targetWaterMl // ignore: cast_nullable_to_non_nullable
              as int,
      meals: null == meals
          ? _self._meals
          : meals // ignore: cast_nullable_to_non_nullable
              as List<MealItem>,
    ));
  }
}

// dart format on
