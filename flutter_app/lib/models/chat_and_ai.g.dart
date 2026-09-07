// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_and_ai.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
      id: json['id'] as String,
      sender: json['sender'] as String,
      text: json['text'] as String,
      timestamp: json['timestamp'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender': instance.sender,
      'text': instance.text,
      'timestamp': instance.timestamp,
      'createdAt': instance.createdAt?.toIso8601String(),
      'imageUrl': instance.imageUrl,
    };

_QuickLogParsedResult _$QuickLogParsedResultFromJson(
        Map<String, dynamic> json) =>
    _QuickLogParsedResult(
      workoutStatus:
          $enumDecodeNullable(_$WorkoutStatusEnumMap, json['workoutStatus']),
      workoutReason: json['workoutReason'] as String?,
      mealsToAdd: (json['mealsToAdd'] as List<dynamic>?)
              ?.map((e) => MealItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      skippedMeals: (json['skippedMeals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sleepHours: (json['sleepHours'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      energyLevel: (json['energyLevel'] as num?)?.toInt(),
      coachFeedback: json['coachFeedback'] as String,
    );

Map<String, dynamic> _$QuickLogParsedResultToJson(
        _QuickLogParsedResult instance) =>
    <String, dynamic>{
      'workoutStatus': _$WorkoutStatusEnumMap[instance.workoutStatus],
      'workoutReason': instance.workoutReason,
      'mealsToAdd': instance.mealsToAdd.map((e) => e.toJson()).toList(),
      'skippedMeals': instance.skippedMeals,
      'sleepHours': instance.sleepHours,
      'weightKg': instance.weightKg,
      'energyLevel': instance.energyLevel,
      'coachFeedback': instance.coachFeedback,
    };

const _$WorkoutStatusEnumMap = {
  WorkoutStatus.scheduled: 'scheduled',
  WorkoutStatus.completed: 'completed',
  WorkoutStatus.skipped: 'skipped',
  WorkoutStatus.adapted: 'adapted',
};

_AIActionCall _$AIActionCallFromJson(Map<String, dynamic> json) =>
    _AIActionCall(
      functionName: json['functionName'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AIActionCallToJson(_AIActionCall instance) =>
    <String, dynamic>{
      'functionName': instance.functionName,
      'arguments': instance.arguments,
    };

_PendingAction _$PendingActionFromJson(Map<String, dynamic> json) =>
    _PendingAction(
      id: json['id'] as String,
      actionType: json['actionType'] as String,
      description: json['description'] as String? ?? 'Pending Action',
      arguments: json['arguments'] as Map<String, dynamic>,
      status: json['status'] as String? ?? 'pending',
    );

Map<String, dynamic> _$PendingActionToJson(_PendingAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'actionType': instance.actionType,
      'description': instance.description,
      'arguments': instance.arguments,
      'status': instance.status,
    };

_AIOrchestratorResult _$AIOrchestratorResultFromJson(
        Map<String, dynamic> json) =>
    _AIOrchestratorResult(
      actions: (json['actions'] as List<dynamic>?)
              ?.map((e) => AIActionCall.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      coachResponse: json['coachResponse'] as String,
      pendingActions: (json['pendingActions'] as List<dynamic>?)
              ?.map((e) => PendingAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AIOrchestratorResultToJson(
        _AIOrchestratorResult instance) =>
    <String, dynamic>{
      'actions': instance.actions.map((e) => e.toJson()).toList(),
      'coachResponse': instance.coachResponse,
      'pendingActions': instance.pendingActions.map((e) => e.toJson()).toList(),
    };
