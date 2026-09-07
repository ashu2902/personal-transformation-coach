import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';

abstract class AIService {
  Future<AIOrchestratorResult> processCoachMessage(
      String userPrompt, TransformationEngineState contextState,
      {Uint8List? imageBytes, String? imageUrl, String? mimeType});
  Future<String> generateCoachResponse(
      String userPrompt, TransformationEngineState contextState);
  Future<QuickLogParsedResult> parseQuickLog(
      String rawText, TransformationEngineState contextState);
  Future<void> adaptWorkoutWithAI(
      String adaptationRequest, TransformationEngineState contextState,
      {List<EquipmentType>? explicitEquipment, double? maxWeightKg});
  Future<DailyWorkout> parseWorkoutFromNaturalText(
      String naturalText, TransformationEngineState contextState,
      {String? targetDate});
  Future<String> generateEngineDailyInsight(
      TransformationEngineState contextState);
  Future<void> generateAIInitialWorkout(UserProfile profile);
  Future<void> generateAIMetabolicPlan(UserProfile profile);
  Future<String> synthesizeAITodayFocus(TransformationEngineState contextState);
  Future<void> generateAIAdaptedNutrition(
      TransformationEngineState contextState, String reason);
  Future<void> generateAIAdaptedWorkout(
      TransformationEngineState contextState, String reason);
  Future<WeeklyPlan?> generateAIWeeklyPlan(
      TransformationEngineState contextState);
  Future<MealItem> estimateAIMealNutrition(String mealDescription);
  Future<WeeklyDebrief> generateWeeklyDebrief(TransformationEngineState contextState);
  Future<LifestyleIntakeResult> parseLifestyleIntake(
    String text,
    UserProfile currentProfile, {
    List<Map<String, String>>? conversationHistory,
  });
}

class GeminiAIProvider implements AIService {
  GeminiAIProvider();

  String get _processAiCommandUrl {
    const customUrl = String.fromEnvironment('AI_COMMAND_URL');
    if (customUrl.trim().isNotEmpty) {
      return customUrl.trim();
    }
    return 'https://us-central1-aura-coach-ashu-7.cloudfunctions.net/processAiCommand';
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      try {
        final cred = await FirebaseAuth.instance.signInAnonymously();
        user = cred.user;
      } catch (e) {
        debugPrint('[AURA AI] Anonymous auth fallback error: $e');
      }
    }
    final token = await user?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _callProcessAiCommand({
    required String command,
    String? message,
    List<Map<String, dynamic>>? history,
    Uint8List? imageBytes,
    String? imageUrl,
    String? mimeType,
  }) async {
    final timer = Stopwatch()..start();
    _logRequest('processAiCommand:$command', message ?? '');
    try {
      final headers = await _getAuthHeaders();
      final body = <String, dynamic>{
        'command': command,
      };
      if (message != null) body['message'] = message;
      if (history != null) body['history'] = history;
      if (imageUrl != null) {
        body['imageUrl'] = imageUrl;
      } else if (imageBytes != null) {
        body['imageBase64'] = base64Encode(imageBytes);
        body['mimeType'] = mimeType ?? 'image/jpeg';
      }

      final response = await http.post(
        Uri.parse(_processAiCommandUrl),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logResponse('processAiCommand:$command', 200, timer.elapsedMilliseconds, response.body);
        return data as Map<String, dynamic>;
      }
      throw Exception('processAiCommand returned status ${response.statusCode}: ${response.body}');
    } catch (e) {
      _logError('processAiCommand:$command', e);
      rethrow;
    }
  }

  void _logRequest(String method, String prompt) {
    debugPrint('\n===== 🚀 [AURA AI PROXY REQUEST: $method] =====');
    debugPrint('Prompt:\n$prompt');
    debugPrint('================================================\n');
  }

  void _logResponse(String method, int statusCode, int ms, String body) {
    debugPrint('\n===== ✅ [AURA AI PROXY RESPONSE: $method] =====');
    debugPrint('Status: $statusCode | Latency: ${ms}ms');
    debugPrint('Body:\n$body');
    debugPrint('=================================================\n');
  }

  void _logError(String method, dynamic error) {
    debugPrint('\n===== ❌ [AURA AI PROXY ERROR: $method] =====');
    debugPrint('Error: $error');
    debugPrint('==============================================\n');
  }

  @override
  Future<AIOrchestratorResult> processCoachMessage(
      String userPrompt, TransformationEngineState contextState,
      {Uint8List? imageBytes, String? imageUrl, String? mimeType}) async {
    try {
      final parsed = await _callProcessAiCommand(
        command: 'chatMessage',
        message: userPrompt,
        imageBytes: imageBytes,
        imageUrl: imageUrl,
        mimeType: mimeType,
      );

      final List<PendingAction> pending = [];
      if (parsed['pendingActions'] is List) {
        for (var pa in parsed['pendingActions']) {
          if (pa is Map) {
            pending.add(PendingAction.fromJson(Map<String, dynamic>.from(pa)));
          }
        }
      }

      return AIOrchestratorResult(
        coachResponse: parsed['coachResponse']?.toString() ?? 'Got it.',
        actions: const [],
        pendingActions: pending,
      );
    } catch (e) {
      _logError('processCoachMessage', e);
      rethrow;
    }
  }

  @override
  Future<String> generateCoachResponse(
      String userPrompt, TransformationEngineState contextState) async {
    try {
      final res = await _callProcessAiCommand(
        command: 'generateCoachResponse',
        message: userPrompt,
      );
      return res['response']?.toString() ?? 'Got it!';
    } catch (e) {
      _logError('generateCoachResponse', e);
      rethrow;
    }
  }

  @override
  Future<QuickLogParsedResult> parseQuickLog(
      String rawText, TransformationEngineState contextState) async {
    try {
      final parsed = await _callProcessAiCommand(
        command: 'parseQuickLog',
        message: rawText,
      );
      WorkoutStatus? status;
      if (parsed['workoutStatus'] == 'completed') status = WorkoutStatus.completed;
      if (parsed['workoutStatus'] == 'skipped') status = WorkoutStatus.skipped;

      final List<MealItem> mealsToAdd = (parsed['mealsToAdd'] as List? ?? []).map((m) => MealItem(
        name: m['name']?.toString() ?? '',
        calories: (m['calories'] as num?)?.toInt() ?? 0,
        proteinG: (m['proteinG'] as num?)?.toInt() ?? 0,
        carbsG: (m['carbsG'] as num?)?.toInt() ?? 0,
        fatG: (m['fatG'] as num?)?.toInt() ?? 0,
      )).toList();

      return QuickLogParsedResult(
        workoutStatus: status,
        workoutReason: parsed['workoutReason']?.toString(),
        mealsToAdd: mealsToAdd,
        skippedMeals: (parsed['skippedMeals'] as List? ?? []).map((e) => e.toString()).toList(),
        sleepHours: (parsed['sleepHours'] as num?)?.toDouble(),
        weightKg: (parsed['weightKg'] as num?)?.toDouble(),
        energyLevel: (parsed['energyLevel'] as num?)?.toInt(),
        coachFeedback: parsed['coachFeedback']?.toString() ?? 'Recorded.',
      );
    } catch (e) {
      _logError('parseQuickLog', e);
      rethrow;
    }
  }

  @override
  Future<void> adaptWorkoutWithAI(
      String adaptationRequest, TransformationEngineState contextState,
      {List<EquipmentType>? explicitEquipment, double? maxWeightKg}) async {
    try {
      await _callProcessAiCommand(
        command: 'adaptWorkoutWithAI',
        message: adaptationRequest,
      );
    } catch (e) {
      _logError('adaptWorkoutWithAI', e);
      rethrow;
    }
  }

  @override
  Future<String> generateEngineDailyInsight(
      TransformationEngineState contextState) async {
    try {
      final res = await _callProcessAiCommand(
        command: 'generateEngineDailyInsight',
      );
      return res['insight']?.toString() ?? 'Keep going!';
    } catch (e) {
      _logError('generateEngineDailyInsight', e);
      rethrow;
    }
  }

  @override
  Future<void> generateAIInitialWorkout(UserProfile profile) async {
    try {
      await _callProcessAiCommand(
        command: 'generateAIInitialWorkout',
      );
    } catch (e) {
      _logError('generateAIInitialWorkout', e);
      rethrow;
    }
  }

  @override
  Future<void> generateAIMetabolicPlan(UserProfile profile) async {
    try {
      await _callProcessAiCommand(
        command: 'generateMetabolicPlan',
      );
    } catch (e) {
      _logError('generateAIMetabolicPlan', e);
      rethrow;
    }
  }

  @override
  Future<String> synthesizeAITodayFocus(
      TransformationEngineState contextState) async {
    try {
      final res = await _callProcessAiCommand(
        command: 'synthesizeTodayFocus',
      );
      return res['focus']?.toString() ?? "Let's win today!";
    } catch (e) {
      return "Let's win today!";
    }
  }

  @override
  Future<void> generateAIAdaptedNutrition(
      TransformationEngineState contextState, String reason) async {
    try {
      await _callProcessAiCommand(
        command: 'generateAdaptedNutrition',
        message: reason,
      );
    } catch (e) {
      _logError('generateAIAdaptedNutrition', e);
      rethrow;
    }
  }

  @override
  Future<void> generateAIAdaptedWorkout(
      TransformationEngineState contextState, String reason) async {
    try {
      await _callProcessAiCommand(
        command: 'generateAdaptedWorkout',
        message: reason,
      );
    } catch (e) {
      _logError('generateAIAdaptedWorkout', e);
      rethrow;
    }
  }

  @override
  Future<MealItem> estimateAIMealNutrition(String mealDescription) async {
    try {
      final parsed = await _callProcessAiCommand(
        command: 'estimateMeal',
        message: mealDescription,
      );
      final cleanName = (parsed['name'] as String?)?.trim().isNotEmpty == true
          ? parsed['name'] as String
          : mealDescription;
      final cal = (parsed['calories'] as num?)?.toInt() ?? 300;
      final prot = (parsed['proteinG'] as num?)?.toInt() ?? 15;
      final carbs = (parsed['carbsG'] as num?)?.toInt() ?? 30;
      final fat = (parsed['fatG'] as num?)?.toInt() ?? 10;
      return MealItem(
        name: cleanName,
        calories: cal,
        proteinG: prot,
        carbsG: carbs,
        fatG: fat,
      );
    } catch (e) {
      _logError('estimateAIMealNutrition', e);
      return MealItem(
        name: mealDescription,
        calories: 300,
        proteinG: 20,
        carbsG: 30,
        fatG: 10,
      );
    }
  }

  @override
  Future<WeeklyPlan?> generateAIWeeklyPlan(
      TransformationEngineState contextState) async {
    try {
      final json = await _callProcessAiCommand(
        command: 'generateWeeklyPlan',
      );
      final startDateStr = json['startDate']?.toString() ?? '';
      DateTime? baseDate;
      if (startDateStr.isNotEmpty) {
        try {
          baseDate = DateTime.parse(startDateStr);
        } catch (_) {}
      }
      if (baseDate == null) {
        final now = DateTime.now();
        baseDate = now.subtract(Duration(days: now.weekday - 1));
      }

      final rawDays = (json['days'] as List? ?? []);
      final days = <WeeklyDayPlan>[];
      for (int i = 0; i < rawDays.length; i++) {
        final d = rawDays[i] as Map? ?? {};
        String dateStr = d['date']?.toString() ?? '';
        if (dateStr.isEmpty) {
          final calculatedDay = baseDate.add(Duration(days: i));
          dateStr = calculatedDay.toIso8601String().split('T')[0];
        }
        days.add(WeeklyDayPlan(
          dayName: d['dayName']?.toString() ?? '',
          date: dateStr,
          title: d['title']?.toString() ?? '',
          focusArea: d['focusArea']?.toString() ?? '',
          isRestDay: d['isRestDay'] == true,
          exerciseNames: (d['exerciseNames'] as List? ?? []).map((e) => e.toString()).toList(),
          nutritionFocus: d['nutritionFocus']?.toString(),
        ));
      }

      return WeeklyPlan(
        weekId: json['weekId']?.toString() ?? 'w_${DateTime.now().millisecondsSinceEpoch}',
        startDate: startDateStr.isNotEmpty ? startDateStr : baseDate.toIso8601String().split('T')[0],
        endDate: json['endDate']?.toString() ?? baseDate.add(const Duration(days: 6)).toIso8601String().split('T')[0],
        overview: json['overview']?.toString() ?? '',
        coachNote: json['coachNote']?.toString(),
        createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
        days: days,
      );
    } catch (e) {
      _logError('generateAIWeeklyPlan', e);
      rethrow;
    }
  }

  @override
  Future<DailyWorkout> parseWorkoutFromNaturalText(
      String naturalText, TransformationEngineState contextState,
      {String? targetDate}) async {
    final dateStr = targetDate ?? DateTime.now().toIso8601String().split('T')[0];
    try {
      final json = await _callProcessAiCommand(
        command: 'parseNaturalWorkout',
        message: naturalText,
      );
      final rawExercises = json['exercises'] as List? ?? [];
      final exercises = rawExercises.map((e) {
        final rawSets = e['sets'] as List? ?? [];
        final sets = rawSets.map((s) {
          return ExerciseSet(
            setNumber: (s['setNumber'] as num?)?.toInt() ?? 1,
            targetReps: (s['targetReps'] as num?)?.toInt() ?? 10,
            targetWeightKg: (s['targetWeightKg'] as num?)?.toDouble() ?? 0.0,
            completed: s['completed'] ?? true,
          );
        }).toList();

        return Exercise(
          id: e['id']?.toString() ?? 'ex_${DateTime.now().millisecondsSinceEpoch}',
          name: e['name']?.toString() ?? 'Exercise',
          targetMuscle: e['targetMuscle']?.toString() ?? 'Full Body',
          equipmentRequired: e['equipmentRequired']?.toString() ?? 'bodyweight',
          sets: sets.isNotEmpty
              ? sets
              : [const ExerciseSet(setNumber: 1, targetReps: 10, targetWeightKg: 0.0, completed: true)],
          notes: e['notes']?.toString(),
        );
      }).toList();

      return DailyWorkout(
        id: 'natural_log_${dateStr}_${DateTime.now().millisecondsSinceEpoch}',
        date: dateStr,
        title: json['title']?.toString() ?? "Today's Logged Workout",
        focusArea: json['focusArea']?.toString() ?? "Completed Workout",
        estimatedDurationMin: (json['estimatedDurationMin'] as num?)?.toInt() ?? 45,
        status: WorkoutStatus.completed,
        exercises: exercises,
        adaptationNote: json['adaptationNote']?.toString() ?? naturalText,
      );
    } catch (e) {
      debugPrint('[AURA AI] parseWorkoutFromNaturalText failed: $e');
      return DailyWorkout(
        id: 'natural_log_${dateStr}_${DateTime.now().millisecondsSinceEpoch}',
        date: dateStr,
        title: "Logged Workout Session",
        focusArea: "General",
        estimatedDurationMin: 45,
        status: WorkoutStatus.completed,
        exercises: const [],
        adaptationNote: "Manually logged: $naturalText",
      );
    }
  }

  @override
  Future<WeeklyDebrief> generateWeeklyDebrief(TransformationEngineState contextState) async {
    try {
      final json = await _callProcessAiCommand(
        command: 'generateWeeklyDebrief',
      );
      return WeeklyDebrief.fromJson(json);
    } catch (e) {
      debugPrint('[AURA AI] generateWeeklyDebrief failed: $e');
      return const WeeklyDebrief(
        headline: 'Weekly Synthesis',
        narrative: "You made meaningful strides this week!",
        keyAchievement: 'Consistent weekly routine engagement',
        primaryNextStep: 'Lock in 8 hours of sleep and daily protein target',
        adherenceScore: 82,
      );
    }
  }

  @override
  Future<LifestyleIntakeResult> parseLifestyleIntake(
    String text,
    UserProfile currentProfile, {
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      final json = await _callProcessAiCommand(
        command: 'parseLifestyleIntake',
        message: text,
        history: conversationHistory,
      );
      return LifestyleIntakeResult.fromJson(json);
    } catch (e) {
      debugPrint('[AURA AI] parseLifestyleIntake failed: $e');
      return LifestyleIntakeResult(
        isComplete: false,
        daysPerWeek: currentProfile.daysPerWeek,
        equipment: currentProfile.equipmentList.map((e) => e.name).toList(),
        missingFields: const ['daysPerWeek'],
        followUpQuestion: "Got it! Let's continue calibrating.",
        dynamicQuickReplies: const ["3 days a week", "4 days a week", "5 days a week"],
        targetPhysique: currentProfile.targetPhysique,
      );
    }
  }
}
