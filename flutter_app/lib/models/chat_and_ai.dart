import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'workout.dart';
import 'nutrition.dart';
import 'command_preview.dart';

part 'chat_and_ai.freezed.dart';
part 'chat_and_ai.g.dart';

@freezed
abstract class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required String sender,
    required String text,
    String? timestamp,
    DateTime? createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false) Uint8List? imageBytes,
    String? imageUrl,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

  factory ChatMessage.create({
    required String id,
    required String sender,
    required String text,
    String? timestamp,
    DateTime? createdAt,
    Uint8List? imageBytes,
    String? imageUrl,
  }) {
    final effectiveCreatedAt = createdAt ??
        (timestamp != null && timestamp != 'Just now'
            ? DateTime.tryParse(timestamp) ?? DateTime.now()
            : DateTime.now());
    final effectiveTimestamp = (timestamp != null && timestamp != 'Just now')
        ? timestamp
        : (createdAt ?? DateTime.now()).toIso8601String();

    return ChatMessage(
      id: id,
      sender: sender,
      text: text,
      timestamp: effectiveTimestamp,
      createdAt: effectiveCreatedAt,
      imageBytes: imageBytes,
      imageUrl: imageUrl,
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final date = createdAt ?? DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 45 && diff.inSeconds >= -5) {
      return 'Just now';
    } else if (diff.inMinutes < 60 && diff.inMinutes >= 0 && date.day == now.day && date.month == now.month && date.year == now.year) {
      return '${diff.inMinutes}m ago';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day) {
      final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return 'Yesterday $hour:$minute $period';
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final monthStr = months[date.month - 1];
      final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$monthStr ${date.day}, $hour:$minute $period';
    }
  }
}

@freezed
abstract class QuickLogParsedResult with _$QuickLogParsedResult {
  const QuickLogParsedResult._();

  const factory QuickLogParsedResult({
    WorkoutStatus? workoutStatus,
    String? workoutReason,
    @Default([]) List<MealItem> mealsToAdd,
    @Default([]) List<String> skippedMeals,
    double? sleepHours,
    double? weightKg,
    int? energyLevel,
    required String coachFeedback,
  }) = _QuickLogParsedResult;

  factory QuickLogParsedResult.fromJson(Map<String, dynamic> json) => _$QuickLogParsedResultFromJson(json);
}

@freezed
abstract class AIActionCall with _$AIActionCall {
  const AIActionCall._();

  const factory AIActionCall({
    required String functionName,
    required Map<String, dynamic> arguments,
  }) = _AIActionCall;

  factory AIActionCall.fromJson(Map<String, dynamic> json) => _$AIActionCallFromJson(json);
}

@freezed
abstract class PendingAction with _$PendingAction {
  const PendingAction._();

  const factory PendingAction({
    required String id,
    required String actionType,
    @Default('Pending Action') String description,
    required Map<String, dynamic> arguments,
    @Default('pending') String status,
  }) = _PendingAction;

  factory PendingAction.fromJson(Map<String, dynamic> json) => _$PendingActionFromJson(json);
}

@freezed
abstract class AIOrchestratorResult with _$AIOrchestratorResult {
  const AIOrchestratorResult._();

  const factory AIOrchestratorResult({
    @Default([]) List<AIActionCall> actions,
    required String coachResponse,
    @Default([]) List<PendingAction> pendingActions,
  }) = _AIOrchestratorResult;

  factory AIOrchestratorResult.fromJson(Map<String, dynamic> json) => _$AIOrchestratorResultFromJson(json);
}

class UnifiedAIOrchestratorResult extends AIOrchestratorResult {
  @override
  final List<AIActionCall> actions;
  @override
  final String coachResponse;
  @override
  final List<PendingAction> pendingActions;
  final List<CommandPreview> previews;

  const UnifiedAIOrchestratorResult({
    this.actions = const [],
    required this.coachResponse,
    this.pendingActions = const [],
    this.previews = const [],
  }) : super._();

  @override
  Map<String, dynamic> toJson() => {
    'actions': actions.map((a) => a.toJson()).toList(),
    'coachResponse': coachResponse,
    'pendingActions': pendingActions.map((p) => p.toJson()).toList(),
    'previews': previews.map((p) => p.toJson()).toList(),
  };
}

class WeeklyDebrief {
  final String headline;
  final String narrative;
  final String keyAchievement;
  final String primaryNextStep;
  final int adherenceScore;

  const WeeklyDebrief({
    required this.headline,
    required this.narrative,
    required this.keyAchievement,
    required this.primaryNextStep,
    required this.adherenceScore,
  });

  factory WeeklyDebrief.fromJson(Map<String, dynamic> json) {
    return WeeklyDebrief(
      headline: json['headline']?.toString() ?? 'Weekly Calibration Summary',
      narrative: json['narrative']?.toString() ?? 'You stayed committed to your targets this week. Great work!',
      keyAchievement: json['keyAchievement']?.toString() ?? 'Consistent training compliance',
      primaryNextStep: json['primaryNextStep']?.toString() ?? 'Maintain hydration and sleep consistency',
      adherenceScore: (json['adherenceScore'] as num?)?.toInt() ?? 85,
    );
  }

  Map<String, dynamic> toJson() => {
    'headline': headline,
    'narrative': narrative,
    'keyAchievement': keyAchievement,
    'primaryNextStep': primaryNextStep,
    'adherenceScore': adherenceScore,
  };

  WeeklyDebrief copyWith({
    String? headline,
    String? narrative,
    String? keyAchievement,
    String? primaryNextStep,
    int? adherenceScore,
  }) {
    return WeeklyDebrief(
      headline: headline ?? this.headline,
      narrative: narrative ?? this.narrative,
      keyAchievement: keyAchievement ?? this.keyAchievement,
      primaryNextStep: primaryNextStep ?? this.primaryNextStep,
      adherenceScore: adherenceScore ?? this.adherenceScore,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyDebrief &&
          runtimeType == other.runtimeType &&
          headline == other.headline &&
          narrative == other.narrative &&
          keyAchievement == other.keyAchievement &&
          primaryNextStep == other.primaryNextStep &&
          adherenceScore == other.adherenceScore;

  @override
  int get hashCode =>
      headline.hashCode ^
      narrative.hashCode ^
      keyAchievement.hashCode ^
      primaryNextStep.hashCode ^
      adherenceScore.hashCode;
}

class LifestyleIntakeResult {
  final bool isComplete;
  final int daysPerWeek;
  final List<String> equipment;
  final List<String> missingFields;
  final String followUpQuestion;
  final List<String> dynamicQuickReplies;
  final String? targetPhysique;
  final List<String> lifestyleNotes;

  const LifestyleIntakeResult({
    required this.isComplete,
    required this.daysPerWeek,
    this.equipment = const [],
    this.missingFields = const [],
    required this.followUpQuestion,
    this.dynamicQuickReplies = const [],
    this.targetPhysique,
    this.lifestyleNotes = const [],
  });

  factory LifestyleIntakeResult.fromJson(Map<String, dynamic> json) {
    final rawEq = json['equipment'];
    final List<String> eqList = [];
    if (rawEq is List) {
      for (var e in rawEq) {
        if (e is String) {
          eqList.add(e);
        } else if (e is Map && e['name'] != null) {
          eqList.add(e['name'].toString());
        }
      }
    }
    final rawMissing = json['missingFields'];
    final List<String> missingList = [];
    if (rawMissing is List) {
      for (var m in rawMissing) {
        missingList.add(m.toString());
      }
    }
    final rawReplies = json['dynamicQuickReplies'] ?? json['quickReplies'] ?? json['suggestedReplies'];
    final List<String> quickReplies = [];
    if (rawReplies is List) {
      for (var r in rawReplies) {
        if (r != null && r.toString().trim().isNotEmpty) {
          quickReplies.add(r.toString().trim());
        }
      }
    }
    final rawNotes = json['lifestyleNotes'] ?? json['notes'] ?? json['constraints'];
    final List<String> notesList = [];
    if (rawNotes is List) {
      for (var n in rawNotes) {
        if (n != null && n.toString().trim().isNotEmpty) {
          notesList.add(n.toString().trim());
        }
      }
    }
    return LifestyleIntakeResult(
      isComplete: json['isComplete'] == true,
      daysPerWeek: (json['daysPerWeek'] as num?)?.toInt() ?? 4,
      equipment: eqList.isNotEmpty ? eqList : const ['Bodyweight', 'Dumbbells'],
      missingFields: missingList,
      followUpQuestion: json['followUpQuestion']?.toString() ?? 'Got it! How many days per week would you like to train?',
      dynamicQuickReplies: quickReplies,
      targetPhysique: json['targetPhysique']?.toString(),
      lifestyleNotes: notesList,
    );
  }

  Map<String, dynamic> toJson() => {
    'isComplete': isComplete,
    'daysPerWeek': daysPerWeek,
    'equipment': equipment,
    'missingFields': missingFields,
    'followUpQuestion': followUpQuestion,
    'dynamicQuickReplies': dynamicQuickReplies,
    'targetPhysique': targetPhysique,
    'lifestyleNotes': lifestyleNotes,
  };

  LifestyleIntakeResult copyWith({
    bool? isComplete,
    int? daysPerWeek,
    List<String>? equipment,
    List<String>? missingFields,
    String? followUpQuestion,
    List<String>? dynamicQuickReplies,
    String? targetPhysique,
    List<String>? lifestyleNotes,
  }) {
    return LifestyleIntakeResult(
      isComplete: isComplete ?? this.isComplete,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      equipment: equipment ?? this.equipment,
      missingFields: missingFields ?? this.missingFields,
      followUpQuestion: followUpQuestion ?? this.followUpQuestion,
      dynamicQuickReplies: dynamicQuickReplies ?? this.dynamicQuickReplies,
      targetPhysique: targetPhysique ?? this.targetPhysique,
      lifestyleNotes: lifestyleNotes ?? this.lifestyleNotes,
    );
  }
}

class TodayFocus {
  final String primaryActionTitle;
  final String primaryActionDescription;
  final String category; // 'TRAIN', 'EAT', 'RECOVER', 'ADAPT'
  final bool isDeloadAdvised;

  const TodayFocus({
    required this.primaryActionTitle,
    required this.primaryActionDescription,
    required this.category,
    this.isDeloadAdvised = false,
  });

  factory TodayFocus.fromJson(Map<String, dynamic> json) => TodayFocus(
    primaryActionTitle: json['primaryActionTitle']?.toString() ?? '',
    primaryActionDescription: json['primaryActionDescription']?.toString() ?? '',
    category: json['category']?.toString() ?? 'TRAIN',
    isDeloadAdvised: json['isDeloadAdvised'] == true,
  );

  Map<String, dynamic> toJson() => {
    'primaryActionTitle': primaryActionTitle,
    'primaryActionDescription': primaryActionDescription,
    'category': category,
    'isDeloadAdvised': isDeloadAdvised,
  };

  TodayFocus copyWith({
    String? primaryActionTitle,
    String? primaryActionDescription,
    String? category,
    bool? isDeloadAdvised,
  }) {
    return TodayFocus(
      primaryActionTitle: primaryActionTitle ?? this.primaryActionTitle,
      primaryActionDescription: primaryActionDescription ?? this.primaryActionDescription,
      category: category ?? this.category,
      isDeloadAdvised: isDeloadAdvised ?? this.isDeloadAdvised,
    );
  }
}


