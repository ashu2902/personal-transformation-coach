// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_and_ai.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessage {
  String get id;
  String get sender;
  String get text;
  String? get timestamp;
  DateTime? get createdAt;
  @JsonKey(ignore: true)
  Uint8List? get imageBytes;
  String? get imageUrl;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other.imageBytes, imageBytes) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, sender, text, timestamp,
      createdAt, const DeepCollectionEquality().hash(imageBytes), imageUrl);

  @override
  String toString() {
    return 'ChatMessage(id: $id, sender: $sender, text: $text, timestamp: $timestamp, createdAt: $createdAt, imageBytes: $imageBytes, imageUrl: $imageUrl)';
  }
}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) _then) =
      _$ChatMessageCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String sender,
      String text,
      String? timestamp,
      DateTime? createdAt,
      @JsonKey(ignore: true) Uint8List? imageBytes,
      String? imageUrl});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res> implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sender = null,
    Object? text = null,
    Object? timestamp = freezed,
    Object? createdAt = freezed,
    Object? imageBytes = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _self.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      imageBytes: freezed == imageBytes
          ? _self.imageBytes
          : imageBytes // ignore: cast_nullable_to_non_nullable
              as Uint8List?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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
    TResult Function(_ChatMessage value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatMessage() when $default != null:
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
    TResult Function(_ChatMessage value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatMessage():
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
    TResult? Function(_ChatMessage value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatMessage() when $default != null:
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
            String sender,
            String text,
            String? timestamp,
            DateTime? createdAt,
            @JsonKey(ignore: true) Uint8List? imageBytes,
            String? imageUrl)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatMessage() when $default != null:
        return $default(_that.id, _that.sender, _that.text, _that.timestamp,
            _that.createdAt, _that.imageBytes, _that.imageUrl);
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
            String sender,
            String text,
            String? timestamp,
            DateTime? createdAt,
            @JsonKey(ignore: true) Uint8List? imageBytes,
            String? imageUrl)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatMessage():
        return $default(_that.id, _that.sender, _that.text, _that.timestamp,
            _that.createdAt, _that.imageBytes, _that.imageUrl);
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
            String sender,
            String text,
            String? timestamp,
            DateTime? createdAt,
            @JsonKey(ignore: true) Uint8List? imageBytes,
            String? imageUrl)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatMessage() when $default != null:
        return $default(_that.id, _that.sender, _that.text, _that.timestamp,
            _that.createdAt, _that.imageBytes, _that.imageUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ChatMessage extends ChatMessage {
  const _ChatMessage(
      {required this.id,
      required this.sender,
      required this.text,
      this.timestamp,
      this.createdAt,
      @JsonKey(ignore: true) this.imageBytes,
      this.imageUrl})
      : super._();
  factory _ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  @override
  final String id;
  @override
  final String sender;
  @override
  final String text;
  @override
  final String? timestamp;
  @override
  final DateTime? createdAt;
  @override
  @JsonKey(ignore: true)
  final Uint8List? imageBytes;
  @override
  final String? imageUrl;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChatMessageCopyWith<_ChatMessage> get copyWith =>
      __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChatMessageToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChatMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other.imageBytes, imageBytes) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, sender, text, timestamp,
      createdAt, const DeepCollectionEquality().hash(imageBytes), imageUrl);

  @override
  String toString() {
    return 'ChatMessage(id: $id, sender: $sender, text: $text, timestamp: $timestamp, createdAt: $createdAt, imageBytes: $imageBytes, imageUrl: $imageUrl)';
  }
}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(
          _ChatMessage value, $Res Function(_ChatMessage) _then) =
      __$ChatMessageCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String sender,
      String text,
      String? timestamp,
      DateTime? createdAt,
      @JsonKey(ignore: true) Uint8List? imageBytes,
      String? imageUrl});
}

/// @nodoc
class __$ChatMessageCopyWithImpl<$Res> implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? sender = null,
    Object? text = null,
    Object? timestamp = freezed,
    Object? createdAt = freezed,
    Object? imageBytes = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_ChatMessage(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _self.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      imageBytes: freezed == imageBytes
          ? _self.imageBytes
          : imageBytes // ignore: cast_nullable_to_non_nullable
              as Uint8List?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$QuickLogParsedResult {
  WorkoutStatus? get workoutStatus;
  String? get workoutReason;
  List<MealItem> get mealsToAdd;
  List<String> get skippedMeals;
  double? get sleepHours;
  double? get weightKg;
  int? get energyLevel;
  String get coachFeedback;

  /// Create a copy of QuickLogParsedResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuickLogParsedResultCopyWith<QuickLogParsedResult> get copyWith =>
      _$QuickLogParsedResultCopyWithImpl<QuickLogParsedResult>(
          this as QuickLogParsedResult, _$identity);

  /// Serializes this QuickLogParsedResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuickLogParsedResult &&
            (identical(other.workoutStatus, workoutStatus) ||
                other.workoutStatus == workoutStatus) &&
            (identical(other.workoutReason, workoutReason) ||
                other.workoutReason == workoutReason) &&
            const DeepCollectionEquality()
                .equals(other.mealsToAdd, mealsToAdd) &&
            const DeepCollectionEquality()
                .equals(other.skippedMeals, skippedMeals) &&
            (identical(other.sleepHours, sleepHours) ||
                other.sleepHours == sleepHours) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.energyLevel, energyLevel) ||
                other.energyLevel == energyLevel) &&
            (identical(other.coachFeedback, coachFeedback) ||
                other.coachFeedback == coachFeedback));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      workoutStatus,
      workoutReason,
      const DeepCollectionEquality().hash(mealsToAdd),
      const DeepCollectionEquality().hash(skippedMeals),
      sleepHours,
      weightKg,
      energyLevel,
      coachFeedback);

  @override
  String toString() {
    return 'QuickLogParsedResult(workoutStatus: $workoutStatus, workoutReason: $workoutReason, mealsToAdd: $mealsToAdd, skippedMeals: $skippedMeals, sleepHours: $sleepHours, weightKg: $weightKg, energyLevel: $energyLevel, coachFeedback: $coachFeedback)';
  }
}

/// @nodoc
abstract mixin class $QuickLogParsedResultCopyWith<$Res> {
  factory $QuickLogParsedResultCopyWith(QuickLogParsedResult value,
          $Res Function(QuickLogParsedResult) _then) =
      _$QuickLogParsedResultCopyWithImpl;
  @useResult
  $Res call(
      {WorkoutStatus? workoutStatus,
      String? workoutReason,
      List<MealItem> mealsToAdd,
      List<String> skippedMeals,
      double? sleepHours,
      double? weightKg,
      int? energyLevel,
      String coachFeedback});
}

/// @nodoc
class _$QuickLogParsedResultCopyWithImpl<$Res>
    implements $QuickLogParsedResultCopyWith<$Res> {
  _$QuickLogParsedResultCopyWithImpl(this._self, this._then);

  final QuickLogParsedResult _self;
  final $Res Function(QuickLogParsedResult) _then;

  /// Create a copy of QuickLogParsedResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutStatus = freezed,
    Object? workoutReason = freezed,
    Object? mealsToAdd = null,
    Object? skippedMeals = null,
    Object? sleepHours = freezed,
    Object? weightKg = freezed,
    Object? energyLevel = freezed,
    Object? coachFeedback = null,
  }) {
    return _then(_self.copyWith(
      workoutStatus: freezed == workoutStatus
          ? _self.workoutStatus
          : workoutStatus // ignore: cast_nullable_to_non_nullable
              as WorkoutStatus?,
      workoutReason: freezed == workoutReason
          ? _self.workoutReason
          : workoutReason // ignore: cast_nullable_to_non_nullable
              as String?,
      mealsToAdd: null == mealsToAdd
          ? _self.mealsToAdd
          : mealsToAdd // ignore: cast_nullable_to_non_nullable
              as List<MealItem>,
      skippedMeals: null == skippedMeals
          ? _self.skippedMeals
          : skippedMeals // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sleepHours: freezed == sleepHours
          ? _self.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as double?,
      weightKg: freezed == weightKg
          ? _self.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      energyLevel: freezed == energyLevel
          ? _self.energyLevel
          : energyLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      coachFeedback: null == coachFeedback
          ? _self.coachFeedback
          : coachFeedback // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [QuickLogParsedResult].
extension QuickLogParsedResultPatterns on QuickLogParsedResult {
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
    TResult Function(_QuickLogParsedResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QuickLogParsedResult() when $default != null:
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
    TResult Function(_QuickLogParsedResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuickLogParsedResult():
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
    TResult? Function(_QuickLogParsedResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuickLogParsedResult() when $default != null:
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
            WorkoutStatus? workoutStatus,
            String? workoutReason,
            List<MealItem> mealsToAdd,
            List<String> skippedMeals,
            double? sleepHours,
            double? weightKg,
            int? energyLevel,
            String coachFeedback)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QuickLogParsedResult() when $default != null:
        return $default(
            _that.workoutStatus,
            _that.workoutReason,
            _that.mealsToAdd,
            _that.skippedMeals,
            _that.sleepHours,
            _that.weightKg,
            _that.energyLevel,
            _that.coachFeedback);
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
            WorkoutStatus? workoutStatus,
            String? workoutReason,
            List<MealItem> mealsToAdd,
            List<String> skippedMeals,
            double? sleepHours,
            double? weightKg,
            int? energyLevel,
            String coachFeedback)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuickLogParsedResult():
        return $default(
            _that.workoutStatus,
            _that.workoutReason,
            _that.mealsToAdd,
            _that.skippedMeals,
            _that.sleepHours,
            _that.weightKg,
            _that.energyLevel,
            _that.coachFeedback);
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
            WorkoutStatus? workoutStatus,
            String? workoutReason,
            List<MealItem> mealsToAdd,
            List<String> skippedMeals,
            double? sleepHours,
            double? weightKg,
            int? energyLevel,
            String coachFeedback)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuickLogParsedResult() when $default != null:
        return $default(
            _that.workoutStatus,
            _that.workoutReason,
            _that.mealsToAdd,
            _that.skippedMeals,
            _that.sleepHours,
            _that.weightKg,
            _that.energyLevel,
            _that.coachFeedback);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _QuickLogParsedResult extends QuickLogParsedResult {
  const _QuickLogParsedResult(
      {this.workoutStatus,
      this.workoutReason,
      final List<MealItem> mealsToAdd = const [],
      final List<String> skippedMeals = const [],
      this.sleepHours,
      this.weightKg,
      this.energyLevel,
      required this.coachFeedback})
      : _mealsToAdd = mealsToAdd,
        _skippedMeals = skippedMeals,
        super._();
  factory _QuickLogParsedResult.fromJson(Map<String, dynamic> json) =>
      _$QuickLogParsedResultFromJson(json);

  @override
  final WorkoutStatus? workoutStatus;
  @override
  final String? workoutReason;
  final List<MealItem> _mealsToAdd;
  @override
  @JsonKey()
  List<MealItem> get mealsToAdd {
    if (_mealsToAdd is EqualUnmodifiableListView) return _mealsToAdd;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mealsToAdd);
  }

  final List<String> _skippedMeals;
  @override
  @JsonKey()
  List<String> get skippedMeals {
    if (_skippedMeals is EqualUnmodifiableListView) return _skippedMeals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skippedMeals);
  }

  @override
  final double? sleepHours;
  @override
  final double? weightKg;
  @override
  final int? energyLevel;
  @override
  final String coachFeedback;

  /// Create a copy of QuickLogParsedResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QuickLogParsedResultCopyWith<_QuickLogParsedResult> get copyWith =>
      __$QuickLogParsedResultCopyWithImpl<_QuickLogParsedResult>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QuickLogParsedResultToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QuickLogParsedResult &&
            (identical(other.workoutStatus, workoutStatus) ||
                other.workoutStatus == workoutStatus) &&
            (identical(other.workoutReason, workoutReason) ||
                other.workoutReason == workoutReason) &&
            const DeepCollectionEquality()
                .equals(other._mealsToAdd, _mealsToAdd) &&
            const DeepCollectionEquality()
                .equals(other._skippedMeals, _skippedMeals) &&
            (identical(other.sleepHours, sleepHours) ||
                other.sleepHours == sleepHours) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.energyLevel, energyLevel) ||
                other.energyLevel == energyLevel) &&
            (identical(other.coachFeedback, coachFeedback) ||
                other.coachFeedback == coachFeedback));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      workoutStatus,
      workoutReason,
      const DeepCollectionEquality().hash(_mealsToAdd),
      const DeepCollectionEquality().hash(_skippedMeals),
      sleepHours,
      weightKg,
      energyLevel,
      coachFeedback);

  @override
  String toString() {
    return 'QuickLogParsedResult(workoutStatus: $workoutStatus, workoutReason: $workoutReason, mealsToAdd: $mealsToAdd, skippedMeals: $skippedMeals, sleepHours: $sleepHours, weightKg: $weightKg, energyLevel: $energyLevel, coachFeedback: $coachFeedback)';
  }
}

/// @nodoc
abstract mixin class _$QuickLogParsedResultCopyWith<$Res>
    implements $QuickLogParsedResultCopyWith<$Res> {
  factory _$QuickLogParsedResultCopyWith(_QuickLogParsedResult value,
          $Res Function(_QuickLogParsedResult) _then) =
      __$QuickLogParsedResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {WorkoutStatus? workoutStatus,
      String? workoutReason,
      List<MealItem> mealsToAdd,
      List<String> skippedMeals,
      double? sleepHours,
      double? weightKg,
      int? energyLevel,
      String coachFeedback});
}

/// @nodoc
class __$QuickLogParsedResultCopyWithImpl<$Res>
    implements _$QuickLogParsedResultCopyWith<$Res> {
  __$QuickLogParsedResultCopyWithImpl(this._self, this._then);

  final _QuickLogParsedResult _self;
  final $Res Function(_QuickLogParsedResult) _then;

  /// Create a copy of QuickLogParsedResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? workoutStatus = freezed,
    Object? workoutReason = freezed,
    Object? mealsToAdd = null,
    Object? skippedMeals = null,
    Object? sleepHours = freezed,
    Object? weightKg = freezed,
    Object? energyLevel = freezed,
    Object? coachFeedback = null,
  }) {
    return _then(_QuickLogParsedResult(
      workoutStatus: freezed == workoutStatus
          ? _self.workoutStatus
          : workoutStatus // ignore: cast_nullable_to_non_nullable
              as WorkoutStatus?,
      workoutReason: freezed == workoutReason
          ? _self.workoutReason
          : workoutReason // ignore: cast_nullable_to_non_nullable
              as String?,
      mealsToAdd: null == mealsToAdd
          ? _self._mealsToAdd
          : mealsToAdd // ignore: cast_nullable_to_non_nullable
              as List<MealItem>,
      skippedMeals: null == skippedMeals
          ? _self._skippedMeals
          : skippedMeals // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sleepHours: freezed == sleepHours
          ? _self.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as double?,
      weightKg: freezed == weightKg
          ? _self.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      energyLevel: freezed == energyLevel
          ? _self.energyLevel
          : energyLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      coachFeedback: null == coachFeedback
          ? _self.coachFeedback
          : coachFeedback // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$AIActionCall {
  String get functionName;
  Map<String, dynamic> get arguments;

  /// Create a copy of AIActionCall
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AIActionCallCopyWith<AIActionCall> get copyWith =>
      _$AIActionCallCopyWithImpl<AIActionCall>(
          this as AIActionCall, _$identity);

  /// Serializes this AIActionCall to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AIActionCall &&
            (identical(other.functionName, functionName) ||
                other.functionName == functionName) &&
            const DeepCollectionEquality().equals(other.arguments, arguments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, functionName,
      const DeepCollectionEquality().hash(arguments));

  @override
  String toString() {
    return 'AIActionCall(functionName: $functionName, arguments: $arguments)';
  }
}

/// @nodoc
abstract mixin class $AIActionCallCopyWith<$Res> {
  factory $AIActionCallCopyWith(
          AIActionCall value, $Res Function(AIActionCall) _then) =
      _$AIActionCallCopyWithImpl;
  @useResult
  $Res call({String functionName, Map<String, dynamic> arguments});
}

/// @nodoc
class _$AIActionCallCopyWithImpl<$Res> implements $AIActionCallCopyWith<$Res> {
  _$AIActionCallCopyWithImpl(this._self, this._then);

  final AIActionCall _self;
  final $Res Function(AIActionCall) _then;

  /// Create a copy of AIActionCall
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? functionName = null,
    Object? arguments = null,
  }) {
    return _then(_self.copyWith(
      functionName: null == functionName
          ? _self.functionName
          : functionName // ignore: cast_nullable_to_non_nullable
              as String,
      arguments: null == arguments
          ? _self.arguments
          : arguments // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// Adds pattern-matching-related methods to [AIActionCall].
extension AIActionCallPatterns on AIActionCall {
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
    TResult Function(_AIActionCall value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIActionCall() when $default != null:
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
    TResult Function(_AIActionCall value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIActionCall():
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
    TResult? Function(_AIActionCall value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIActionCall() when $default != null:
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
    TResult Function(String functionName, Map<String, dynamic> arguments)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIActionCall() when $default != null:
        return $default(_that.functionName, _that.arguments);
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
    TResult Function(String functionName, Map<String, dynamic> arguments)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIActionCall():
        return $default(_that.functionName, _that.arguments);
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
    TResult? Function(String functionName, Map<String, dynamic> arguments)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIActionCall() when $default != null:
        return $default(_that.functionName, _that.arguments);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _AIActionCall extends AIActionCall {
  const _AIActionCall(
      {required this.functionName,
      required final Map<String, dynamic> arguments})
      : _arguments = arguments,
        super._();
  factory _AIActionCall.fromJson(Map<String, dynamic> json) =>
      _$AIActionCallFromJson(json);

  @override
  final String functionName;
  final Map<String, dynamic> _arguments;
  @override
  Map<String, dynamic> get arguments {
    if (_arguments is EqualUnmodifiableMapView) return _arguments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_arguments);
  }

  /// Create a copy of AIActionCall
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AIActionCallCopyWith<_AIActionCall> get copyWith =>
      __$AIActionCallCopyWithImpl<_AIActionCall>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AIActionCallToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AIActionCall &&
            (identical(other.functionName, functionName) ||
                other.functionName == functionName) &&
            const DeepCollectionEquality()
                .equals(other._arguments, _arguments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, functionName,
      const DeepCollectionEquality().hash(_arguments));

  @override
  String toString() {
    return 'AIActionCall(functionName: $functionName, arguments: $arguments)';
  }
}

/// @nodoc
abstract mixin class _$AIActionCallCopyWith<$Res>
    implements $AIActionCallCopyWith<$Res> {
  factory _$AIActionCallCopyWith(
          _AIActionCall value, $Res Function(_AIActionCall) _then) =
      __$AIActionCallCopyWithImpl;
  @override
  @useResult
  $Res call({String functionName, Map<String, dynamic> arguments});
}

/// @nodoc
class __$AIActionCallCopyWithImpl<$Res>
    implements _$AIActionCallCopyWith<$Res> {
  __$AIActionCallCopyWithImpl(this._self, this._then);

  final _AIActionCall _self;
  final $Res Function(_AIActionCall) _then;

  /// Create a copy of AIActionCall
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? functionName = null,
    Object? arguments = null,
  }) {
    return _then(_AIActionCall(
      functionName: null == functionName
          ? _self.functionName
          : functionName // ignore: cast_nullable_to_non_nullable
              as String,
      arguments: null == arguments
          ? _self._arguments
          : arguments // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
mixin _$PendingAction {
  String get id;
  String get actionType;
  String get description;
  Map<String, dynamic> get arguments;
  String get status;

  /// Create a copy of PendingAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PendingActionCopyWith<PendingAction> get copyWith =>
      _$PendingActionCopyWithImpl<PendingAction>(
          this as PendingAction, _$identity);

  /// Serializes this PendingAction to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PendingAction &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other.arguments, arguments) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, actionType, description,
      const DeepCollectionEquality().hash(arguments), status);

  @override
  String toString() {
    return 'PendingAction(id: $id, actionType: $actionType, description: $description, arguments: $arguments, status: $status)';
  }
}

/// @nodoc
abstract mixin class $PendingActionCopyWith<$Res> {
  factory $PendingActionCopyWith(
          PendingAction value, $Res Function(PendingAction) _then) =
      _$PendingActionCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String actionType,
      String description,
      Map<String, dynamic> arguments,
      String status});
}

/// @nodoc
class _$PendingActionCopyWithImpl<$Res>
    implements $PendingActionCopyWith<$Res> {
  _$PendingActionCopyWithImpl(this._self, this._then);

  final PendingAction _self;
  final $Res Function(PendingAction) _then;

  /// Create a copy of PendingAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? actionType = null,
    Object? description = null,
    Object? arguments = null,
    Object? status = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _self.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      arguments: null == arguments
          ? _self.arguments
          : arguments // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [PendingAction].
extension PendingActionPatterns on PendingAction {
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
    TResult Function(_PendingAction value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PendingAction() when $default != null:
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
    TResult Function(_PendingAction value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PendingAction():
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
    TResult? Function(_PendingAction value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PendingAction() when $default != null:
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
    TResult Function(String id, String actionType, String description,
            Map<String, dynamic> arguments, String status)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PendingAction() when $default != null:
        return $default(_that.id, _that.actionType, _that.description,
            _that.arguments, _that.status);
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
    TResult Function(String id, String actionType, String description,
            Map<String, dynamic> arguments, String status)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PendingAction():
        return $default(_that.id, _that.actionType, _that.description,
            _that.arguments, _that.status);
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
    TResult? Function(String id, String actionType, String description,
            Map<String, dynamic> arguments, String status)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PendingAction() when $default != null:
        return $default(_that.id, _that.actionType, _that.description,
            _that.arguments, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PendingAction extends PendingAction {
  const _PendingAction(
      {required this.id,
      required this.actionType,
      this.description = 'Pending Action',
      required final Map<String, dynamic> arguments,
      this.status = 'pending'})
      : _arguments = arguments,
        super._();
  factory _PendingAction.fromJson(Map<String, dynamic> json) =>
      _$PendingActionFromJson(json);

  @override
  final String id;
  @override
  final String actionType;
  @override
  @JsonKey()
  final String description;
  final Map<String, dynamic> _arguments;
  @override
  Map<String, dynamic> get arguments {
    if (_arguments is EqualUnmodifiableMapView) return _arguments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_arguments);
  }

  @override
  @JsonKey()
  final String status;

  /// Create a copy of PendingAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PendingActionCopyWith<_PendingAction> get copyWith =>
      __$PendingActionCopyWithImpl<_PendingAction>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PendingActionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PendingAction &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._arguments, _arguments) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, actionType, description,
      const DeepCollectionEquality().hash(_arguments), status);

  @override
  String toString() {
    return 'PendingAction(id: $id, actionType: $actionType, description: $description, arguments: $arguments, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$PendingActionCopyWith<$Res>
    implements $PendingActionCopyWith<$Res> {
  factory _$PendingActionCopyWith(
          _PendingAction value, $Res Function(_PendingAction) _then) =
      __$PendingActionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String actionType,
      String description,
      Map<String, dynamic> arguments,
      String status});
}

/// @nodoc
class __$PendingActionCopyWithImpl<$Res>
    implements _$PendingActionCopyWith<$Res> {
  __$PendingActionCopyWithImpl(this._self, this._then);

  final _PendingAction _self;
  final $Res Function(_PendingAction) _then;

  /// Create a copy of PendingAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? actionType = null,
    Object? description = null,
    Object? arguments = null,
    Object? status = null,
  }) {
    return _then(_PendingAction(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _self.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      arguments: null == arguments
          ? _self._arguments
          : arguments // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$AIOrchestratorResult {
  List<AIActionCall> get actions;
  String get coachResponse;
  List<PendingAction> get pendingActions;

  /// Create a copy of AIOrchestratorResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AIOrchestratorResultCopyWith<AIOrchestratorResult> get copyWith =>
      _$AIOrchestratorResultCopyWithImpl<AIOrchestratorResult>(
          this as AIOrchestratorResult, _$identity);

  /// Serializes this AIOrchestratorResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AIOrchestratorResult &&
            const DeepCollectionEquality().equals(other.actions, actions) &&
            (identical(other.coachResponse, coachResponse) ||
                other.coachResponse == coachResponse) &&
            const DeepCollectionEquality()
                .equals(other.pendingActions, pendingActions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(actions),
      coachResponse,
      const DeepCollectionEquality().hash(pendingActions));

  @override
  String toString() {
    return 'AIOrchestratorResult(actions: $actions, coachResponse: $coachResponse, pendingActions: $pendingActions)';
  }
}

/// @nodoc
abstract mixin class $AIOrchestratorResultCopyWith<$Res> {
  factory $AIOrchestratorResultCopyWith(AIOrchestratorResult value,
          $Res Function(AIOrchestratorResult) _then) =
      _$AIOrchestratorResultCopyWithImpl;
  @useResult
  $Res call(
      {List<AIActionCall> actions,
      String coachResponse,
      List<PendingAction> pendingActions});
}

/// @nodoc
class _$AIOrchestratorResultCopyWithImpl<$Res>
    implements $AIOrchestratorResultCopyWith<$Res> {
  _$AIOrchestratorResultCopyWithImpl(this._self, this._then);

  final AIOrchestratorResult _self;
  final $Res Function(AIOrchestratorResult) _then;

  /// Create a copy of AIOrchestratorResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actions = null,
    Object? coachResponse = null,
    Object? pendingActions = null,
  }) {
    return _then(_self.copyWith(
      actions: null == actions
          ? _self.actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<AIActionCall>,
      coachResponse: null == coachResponse
          ? _self.coachResponse
          : coachResponse // ignore: cast_nullable_to_non_nullable
              as String,
      pendingActions: null == pendingActions
          ? _self.pendingActions
          : pendingActions // ignore: cast_nullable_to_non_nullable
              as List<PendingAction>,
    ));
  }
}

/// Adds pattern-matching-related methods to [AIOrchestratorResult].
extension AIOrchestratorResultPatterns on AIOrchestratorResult {
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
    TResult Function(_AIOrchestratorResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIOrchestratorResult() when $default != null:
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
    TResult Function(_AIOrchestratorResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIOrchestratorResult():
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
    TResult? Function(_AIOrchestratorResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIOrchestratorResult() when $default != null:
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
    TResult Function(List<AIActionCall> actions, String coachResponse,
            List<PendingAction> pendingActions)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIOrchestratorResult() when $default != null:
        return $default(
            _that.actions, _that.coachResponse, _that.pendingActions);
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
    TResult Function(List<AIActionCall> actions, String coachResponse,
            List<PendingAction> pendingActions)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIOrchestratorResult():
        return $default(
            _that.actions, _that.coachResponse, _that.pendingActions);
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
    TResult? Function(List<AIActionCall> actions, String coachResponse,
            List<PendingAction> pendingActions)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIOrchestratorResult() when $default != null:
        return $default(
            _that.actions, _that.coachResponse, _that.pendingActions);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _AIOrchestratorResult extends AIOrchestratorResult {
  const _AIOrchestratorResult(
      {final List<AIActionCall> actions = const [],
      required this.coachResponse,
      final List<PendingAction> pendingActions = const []})
      : _actions = actions,
        _pendingActions = pendingActions,
        super._();
  factory _AIOrchestratorResult.fromJson(Map<String, dynamic> json) =>
      _$AIOrchestratorResultFromJson(json);

  final List<AIActionCall> _actions;
  @override
  @JsonKey()
  List<AIActionCall> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

  @override
  final String coachResponse;
  final List<PendingAction> _pendingActions;
  @override
  @JsonKey()
  List<PendingAction> get pendingActions {
    if (_pendingActions is EqualUnmodifiableListView) return _pendingActions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingActions);
  }

  /// Create a copy of AIOrchestratorResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AIOrchestratorResultCopyWith<_AIOrchestratorResult> get copyWith =>
      __$AIOrchestratorResultCopyWithImpl<_AIOrchestratorResult>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AIOrchestratorResultToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AIOrchestratorResult &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            (identical(other.coachResponse, coachResponse) ||
                other.coachResponse == coachResponse) &&
            const DeepCollectionEquality()
                .equals(other._pendingActions, _pendingActions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_actions),
      coachResponse,
      const DeepCollectionEquality().hash(_pendingActions));

  @override
  String toString() {
    return 'AIOrchestratorResult(actions: $actions, coachResponse: $coachResponse, pendingActions: $pendingActions)';
  }
}

/// @nodoc
abstract mixin class _$AIOrchestratorResultCopyWith<$Res>
    implements $AIOrchestratorResultCopyWith<$Res> {
  factory _$AIOrchestratorResultCopyWith(_AIOrchestratorResult value,
          $Res Function(_AIOrchestratorResult) _then) =
      __$AIOrchestratorResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<AIActionCall> actions,
      String coachResponse,
      List<PendingAction> pendingActions});
}

/// @nodoc
class __$AIOrchestratorResultCopyWithImpl<$Res>
    implements _$AIOrchestratorResultCopyWith<$Res> {
  __$AIOrchestratorResultCopyWithImpl(this._self, this._then);

  final _AIOrchestratorResult _self;
  final $Res Function(_AIOrchestratorResult) _then;

  /// Create a copy of AIOrchestratorResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? actions = null,
    Object? coachResponse = null,
    Object? pendingActions = null,
  }) {
    return _then(_AIOrchestratorResult(
      actions: null == actions
          ? _self._actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<AIActionCall>,
      coachResponse: null == coachResponse
          ? _self.coachResponse
          : coachResponse // ignore: cast_nullable_to_non_nullable
              as String,
      pendingActions: null == pendingActions
          ? _self._pendingActions
          : pendingActions // ignore: cast_nullable_to_non_nullable
              as List<PendingAction>,
    ));
  }
}

// dart format on
