class ContextEnvelope {
  final String activeScreen; // 'workout', 'today', 'coach', 'profile', etc.
  final String? focusedExerciseId;
  final String? focusedExerciseName;
  final int? currentSetIndex;
  final String? activeWorkoutDate;
  final int? sessionElapsedSec;
  final String? todayWorkoutTitle;
  final String? activeMealId;
  final String? clientTimestamp;

  const ContextEnvelope({
    required this.activeScreen,
    this.focusedExerciseId,
    this.focusedExerciseName,
    this.currentSetIndex,
    this.activeWorkoutDate,
    this.sessionElapsedSec,
    this.todayWorkoutTitle,
    this.activeMealId,
    this.clientTimestamp,
  });

  factory ContextEnvelope.fromJson(Map<String, dynamic> json) {
    return ContextEnvelope(
      activeScreen: json['activeScreen']?.toString() ?? 'coach',
      focusedExerciseId: json['focusedExerciseId']?.toString(),
      focusedExerciseName: json['focusedExerciseName']?.toString(),
      currentSetIndex: (json['currentSetIndex'] as num?)?.toInt(),
      activeWorkoutDate: json['activeWorkoutDate']?.toString(),
      sessionElapsedSec: (json['sessionElapsedSec'] as num?)?.toInt(),
      todayWorkoutTitle: json['todayWorkoutTitle']?.toString(),
      activeMealId: json['activeMealId']?.toString(),
      clientTimestamp: json['clientTimestamp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'activeScreen': activeScreen,
    };
    if (focusedExerciseId != null) map['focusedExerciseId'] = focusedExerciseId;
    if (focusedExerciseName != null) map['focusedExerciseName'] = focusedExerciseName;
    if (currentSetIndex != null) map['currentSetIndex'] = currentSetIndex;
    if (activeWorkoutDate != null) map['activeWorkoutDate'] = activeWorkoutDate;
    if (sessionElapsedSec != null) map['sessionElapsedSec'] = sessionElapsedSec;
    if (todayWorkoutTitle != null) map['todayWorkoutTitle'] = todayWorkoutTitle;
    if (activeMealId != null) map['activeMealId'] = activeMealId;
    if (clientTimestamp != null) map['clientTimestamp'] = clientTimestamp;
    return map;
  }

  ContextEnvelope copyWith({
    String? activeScreen,
    String? focusedExerciseId,
    String? focusedExerciseName,
    int? currentSetIndex,
    String? activeWorkoutDate,
    int? sessionElapsedSec,
    String? todayWorkoutTitle,
    String? activeMealId,
    String? clientTimestamp,
  }) {
    return ContextEnvelope(
      activeScreen: activeScreen ?? this.activeScreen,
      focusedExerciseId: focusedExerciseId ?? this.focusedExerciseId,
      focusedExerciseName: focusedExerciseName ?? this.focusedExerciseName,
      currentSetIndex: currentSetIndex ?? this.currentSetIndex,
      activeWorkoutDate: activeWorkoutDate ?? this.activeWorkoutDate,
      sessionElapsedSec: sessionElapsedSec ?? this.sessionElapsedSec,
      todayWorkoutTitle: todayWorkoutTitle ?? this.todayWorkoutTitle,
      activeMealId: activeMealId ?? this.activeMealId,
      clientTimestamp: clientTimestamp ?? this.clientTimestamp,
    );
  }
}
