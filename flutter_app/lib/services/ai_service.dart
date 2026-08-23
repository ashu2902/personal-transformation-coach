import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';

class WeeklyDebrief {
  final String headline;
  final String narrative;
  final String keyAchievement;
  final String primaryNextStep;
  final int adherenceScore;

  WeeklyDebrief({
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
}

class LifestyleIntakeResult {
  final bool isComplete;
  final int daysPerWeek;
  final List<String> equipment;
  final List<String> missingFields;
  final String followUpQuestion;
  final List<String> dynamicQuickReplies;
  final String? targetPhysique;

  LifestyleIntakeResult({
    required this.isComplete,
    required this.daysPerWeek,
    required this.equipment,
    required this.missingFields,
    required this.followUpQuestion,
    this.dynamicQuickReplies = const [],
    this.targetPhysique,
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
    return LifestyleIntakeResult(
      isComplete: json['isComplete'] == true,
      daysPerWeek: (json['daysPerWeek'] as num?)?.toInt() ?? 4,
      equipment: eqList.isNotEmpty ? eqList : ['Bodyweight', 'Dumbbells'],
      missingFields: missingList,
      followUpQuestion: json['followUpQuestion']?.toString() ?? 'Got it! How many days per week would you like to train?',
      dynamicQuickReplies: quickReplies,
      targetPhysique: json['targetPhysique']?.toString(),
    );
  }
}

abstract class AIService {
  Future<AIOrchestratorResult> processCoachMessage(
      String userPrompt, TransformationEngineState contextState,
      {Uint8List? imageBytes, String? mimeType});
  Future<String> generateCoachResponse(
      String userPrompt, TransformationEngineState contextState);
  Future<QuickLogParsedResult> parseQuickLog(
      String rawText, TransformationEngineState contextState);
  Future<DailyWorkout> adaptWorkoutWithAI(
      String adaptationRequest, TransformationEngineState contextState,
      {List<EquipmentType>? explicitEquipment, double? maxWeightKg});
  Future<DailyWorkout> parseWorkoutFromNaturalText(
      String naturalText, TransformationEngineState contextState,
      {String? targetDate});
  Future<String> generateEngineDailyInsight(
      TransformationEngineState contextState);
  Future<DailyWorkout> generateAIInitialWorkout(UserProfile profile);
  Future<DailyNutrition> generateAIMetabolicPlan(UserProfile profile);
  Future<String> synthesizeAITodayFocus(TransformationEngineState contextState);
  Future<DailyNutrition> generateAIAdaptedNutrition(
      TransformationEngineState contextState, String reason);
  Future<DailyWorkout> generateAIAdaptedWorkout(
      TransformationEngineState contextState, String reason);
  Future<WeeklyPlan> generateAIWeeklyPlan(
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
  final String modelName;

  GeminiAIProvider({
    this.modelName = 'gemini-3.6-flash',
  });


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

  Map<String, dynamic> _buildStatePayload(TransformationEngineState state) {
    return {
      'profile': {
        'name': state.profile.name,
        'gender': state.profile.gender,
        'age': state.profile.age,
        'heightCm': state.profile.heightCm,
        'weightKg': state.profile.weightKg,
        'targetWeightKg': state.profile.targetWeightKg,
        'goal': state.profile.goal.name,
        'coachSoul': state.profile.coachSoul.name,
        'equipmentList': state.profile.equipmentList.map((e) => e.name).toList(),
        'activeInjuries': state.profile.activeInjuries,
      },
      'workout': {
        'title': state.workout.title,
        'focusArea': state.workout.focusArea,
        'status': state.workout.status.name,
        'estimatedDurationMin': state.workout.estimatedDurationMin,
      },
      'nutrition': {
        'targetCalories': state.nutrition.targetCalories,
        'targetProteinG': state.nutrition.targetProteinG,
        'meals': state.nutrition.meals.map((m) => {
          'name': m.name,
          'calories': m.calories,
          'proteinG': m.proteinG,
          'carbsG': m.carbsG,
          'fatG': m.fatG,
        }).toList(),
      },
      'recovery': {
        'sleepHours': state.recovery.sleepHours,
        'muscleSoreness': state.recovery.muscleSoreness,
        'energyLevel': state.recovery.energyLevel,
        'recoveryScore': state.recovery.recoveryScore,
        'status': state.recovery.status,
      },
    };
  }

  Future<Map<String, dynamic>> _callProcessAiCommand({
    required String command,
    Map<String, dynamic>? statePayload,
    String? message,
    List<Map<String, dynamic>>? history,
    Uint8List? imageBytes,
    String? mimeType,
  }) async {
    final timer = Stopwatch()..start();
    _logRequest('processAiCommand:$command', message ?? '');
    try {
      final headers = await _getAuthHeaders();
      final body = <String, dynamic>{
        'command': command,
        'model': modelName,
      };
      if (statePayload != null) body['state'] = statePayload;
      if (message != null) body['message'] = message;
      if (history != null) body['history'] = history;
      if (imageBytes != null) {
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
  @override
  Future<AIOrchestratorResult> processCoachMessage(
      String userPrompt, TransformationEngineState contextState,
      {Uint8List? imageBytes, String? mimeType}) async {
    try {
      final parsed = await _callProcessAiCommand(
        command: 'chatMessage',
        message: userPrompt,
        statePayload: _buildStatePayload(contextState),
        imageBytes: imageBytes,
        mimeType: mimeType,
      );
      
      final List<AIActionCall> actions = [];
      if (parsed['actions'] is List) {
        for (var act in parsed['actions']) {
          if (act is Map) {
            final fnName = act['functionName']?.toString() ??
                act['name']?.toString() ??
                '';
            final args = (act['arguments'] is Map)
                ? Map<String, dynamic>.from(act['arguments'])
                : (act['parameters'] is Map)
                    ? Map<String, dynamic>.from(act['parameters'])
                    : <String, dynamic>{};
            if (fnName.isNotEmpty) {
              actions.add(AIActionCall(functionName: fnName, arguments: args));
            }
          }
        }
      }
      return AIOrchestratorResult(
        coachResponse: parsed['coachResponse']?.toString() ?? 'Got it.',
        actions: actions,
      );
    } catch (e) {
      _logError('processCoachMessage', e);
      rethrow;
    }
  }

  @override
  @override
  Future<String> generateCoachResponse(
      String userPrompt, TransformationEngineState contextState) async {
    try {
      final res = await _callProcessAiCommand(
        command: 'generateCoachResponse',
        message: userPrompt,
        statePayload: _buildStatePayload(contextState),
      );
      return res['response']?.toString() ?? 'Got it!';
    } catch (e) {
      _logError('generateCoachResponse', e);
      rethrow;
    }
  }

  @override
  @override
  Future<QuickLogParsedResult> parseQuickLog(
      String rawText, TransformationEngineState contextState) async {
    try {
      final parsed = await _callProcessAiCommand(
        command: 'parseQuickLog',
        message: rawText,
        statePayload: _buildStatePayload(contextState),
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
  @override
  Future<DailyWorkout> adaptWorkoutWithAI(
      String adaptationRequest, TransformationEngineState contextState,
      {List<EquipmentType>? explicitEquipment, double? maxWeightKg}) async {
    try {
      final parsed = await _callProcessAiCommand(
        command: 'adaptWorkoutWithAI',
        message: adaptationRequest,
        statePayload: _buildStatePayload(contextState),
      );
      return _parseWorkoutJson(parsed, contextState.workout, contextState.profile, overrideEquipment: explicitEquipment);
    } catch (e) {
      _logError('adaptWorkoutWithAI', e);
      rethrow;
    }
  }

  @override
  @override
  Future<String> generateEngineDailyInsight(
      TransformationEngineState contextState) async {
    try {
      final res = await _callProcessAiCommand(
        command: 'generateEngineDailyInsight',
        statePayload: _buildStatePayload(contextState),
      );
      return res['insight']?.toString() ?? 'Keep going!';
    } catch (e) {
      _logError('generateEngineDailyInsight', e);
      rethrow;
    }
  }

  @override
  @override
  Future<DailyWorkout> generateAIInitialWorkout(UserProfile profile) async {
    try {
      final parsed = await _callProcessAiCommand(
        command: 'generateAIInitialWorkout',
        statePayload: {'profile': {'name': profile.name, 'goal': profile.goal.name, 'equipmentList': profile.equipmentList.map((e) => {'name': e.name}).toList()}},
      );
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      return DailyWorkout(
        id: 'w_${DateTime.now().millisecondsSinceEpoch}',
        date: todayStr,
        title: parsed['title']?.toString() ?? 'Initial Plan',
        focusArea: parsed['focusArea']?.toString() ?? 'Full Body',
        estimatedDurationMin: (parsed['estimatedDurationMin'] as num?)?.toInt() ?? 45,
        status: WorkoutStatus.completed,
        exercises: [],
        adaptationNote: parsed['adaptationNote']?.toString() ?? 'Ready to start.',
      );
    } catch (e) {
      _logError('generateAIInitialWorkout', e);
      rethrow;
    }
  }

  @override
  @override
  Future<DailyNutrition> generateAIMetabolicPlan(UserProfile profile) async {
    try {
      final parsed = await _callProcessAiCommand(
        command: 'generateMetabolicPlan',
        statePayload: {'profile': {'name': profile.name, 'gender': profile.gender, 'age': profile.age, 'heightCm': profile.heightCm, 'weightKg': profile.weightKg, 'targetWeightKg': profile.targetWeightKg, 'goal': profile.goal.name, 'targetPhysique': profile.targetPhysique, 'daysPerWeek': profile.daysPerWeek}},
      );
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      debugPrint('[GEMINI NUTRITION] Reasoning: ${parsed['reasoning']}');
      return DailyNutrition(
        date: todayStr,
        targetCalories: (parsed['targetCalories'] as num?)?.toInt() ?? 2000,
        targetProteinG: (parsed['targetProteinG'] as num?)?.toInt() ?? 150,
        targetCarbsG: (parsed['targetCarbsG'] as num?)?.toInt() ?? 200,
        targetFatG: (parsed['targetFatG'] as num?)?.toInt() ?? 60,
        targetWaterMl: (parsed['targetWaterMl'] as num?)?.toInt() ?? 2800,
        waterMl: 0,
        meals: [],
      );
    } catch (e) {
      _logError('generateAIMetabolicPlan', e);
      rethrow;
    }
  }

  @override
  @override
  Future<String> synthesizeAITodayFocus(
      TransformationEngineState contextState) async {
    try {
      final res = await _callProcessAiCommand(
        command: 'synthesizeTodayFocus',
        statePayload: _buildStatePayload(contextState),
      );
      return res['focus']?.toString() ?? "Let's win today!";
    } catch (e) {
      return "Let's win today!";
    }
  }

  @override
  @override
  Future<DailyNutrition> generateAIAdaptedNutrition(
      TransformationEngineState contextState, String reason) async {
    try {
      final n = contextState.nutrition;
      final parsed = await _callProcessAiCommand(
        command: 'generateAdaptedNutrition',
        message: reason,
        statePayload: _buildStatePayload(contextState),
      );
      debugPrint('[GEMINI ADAPT NUTRITION] Reason: ${parsed['adaptationReason']}');
      return n.copyWith(
        targetCalories: (parsed['targetCalories'] as num?)?.toInt() ?? n.targetCalories,
        targetProteinG: (parsed['targetProteinG'] as num?)?.toInt() ?? n.targetProteinG,
        targetCarbsG: (parsed['targetCarbsG'] as num?)?.toInt() ?? n.targetCarbsG,
        targetFatG: (parsed['targetFatG'] as num?)?.toInt() ?? n.targetFatG,
        targetWaterMl: (parsed['targetWaterMl'] as num?)?.toInt() ?? n.targetWaterMl,
      );
    } catch (e) {
      _logError('generateAIAdaptedNutrition', e);
      rethrow;
    }
  }

  @override
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
  @override
  Future<DailyWorkout> generateAIAdaptedWorkout(
      TransformationEngineState contextState, String reason) async {
    try {
      final parsed = await _callProcessAiCommand(
        command: 'generateAdaptedWorkout',
        message: reason,
        statePayload: _buildStatePayload(contextState),
      );
      return _parseWorkoutJson(parsed, contextState.workout, contextState.profile);
    } catch (e) {
      _logError('generateAIAdaptedWorkout', e);
      rethrow;
    }
  }

  DailyWorkout _parseWorkoutJson(
      Map<String, dynamic> parsed, DailyWorkout current, UserProfile profile,
      {List<EquipmentType>? overrideEquipment}) {
    final title =
        parsed['title']?.toString() ?? '${current.title} (AI Adapted)';
    final note = parsed['adaptationNote']?.toString() ?? 'Adapted by AURA AI';
    final equipList = overrideEquipment ?? profile.availableEquipment;
    final exercises = _parseExerciseList(parsed['exercises'], current.focusArea,
        equipList, 'ai_adapt');
    if (exercises.isEmpty) {
      throw Exception('Gemini returned empty exercise list');
    }
    return current.copyWith(
      title: title,
      status: WorkoutStatus.adapted,
      adaptationNote: note,
      exercises: exercises,
    );
  }

  List<Exercise> _parseExerciseList(dynamic rawList, String fallbackMuscle,
      List<EquipmentType> equipment, String idPrefix) {
    final List<Exercise> exercises = [];
    if (rawList is! List) return exercises;
    int idCounter = 1;
    for (var ex in rawList) {
      final name = ex['name']?.toString() ?? 'Exercise';
      final muscle = ex['targetMuscle']?.toString() ?? fallbackMuscle;
      final setNum = (ex['targetSets'] as num?)?.toInt() ?? 3;
      final repNum = (ex['targetReps'] as num?)?.toInt() ?? 10;
      final weight = (ex['targetWeightKg'] as num?)?.toDouble() ?? 0.0;
      final notes = ex['notes']?.toString() ?? 'AI Prescribed';
      final sets = List.generate(
        setNum,
        (i) => ExerciseSet(
            setNumber: i + 1, targetReps: repNum, targetWeightKg: weight),
      );

      final equipStr = ex['equipmentRequired']?.toString();
      String reqEquip;
      if (equipStr != null && equipStr.trim().isNotEmpty) {
        reqEquip = equipStr.trim();
      } else {
        final lowerName = name.toLowerCase();
        if (weight == 0.0 || lowerName.contains('push-up') || lowerName.contains('plank') || lowerName.contains('bodyweight') || lowerName.contains('stretch') || lowerName.contains('bridge')) {
          reqEquip = 'Bodyweight';
        } else {
          reqEquip = equipment.isNotEmpty ? equipment.first.name : 'Dumbbells';
        }
      }

      exercises.add(Exercise(
        id: '${idPrefix}_$idCounter',
        name: name,
        targetMuscle: muscle,
        equipmentRequired: reqEquip,
        sets: sets,
        notes: notes,
      ));
      idCounter++;
    }
    return exercises;
  }

  String _buildSystemContext(TransformationEngineState state) {
    final buffer = StringBuffer();
    final p = state.profile;
    final w = state.workout;
    final n = state.nutrition;
    final r = state.recovery;
    final ctx = state.masterContext;

    // 1. High-Level Profile & Goal
    buffer.writeln('### CLIENT WORKING MEMORY ###');
    final goalDesc = p.goal.displayName;
    buffer.writeln('Client: ${p.name} (${p.gender}, ${p.age}y, ${p.weightKg}kg → Target: ${p.targetWeightKg}kg)');
    buffer.writeln('Goal: $goalDesc (Physique focus: ${p.targetPhysique}, Experience: ${p.experienceLevel.name}, Diet: ${p.dietaryPreference})');

    // 2. Physical & Recovery State
    final recoveryDescriptors = <String>[];
    if (r.sleepHours > 0) {
      final sleepStr = r.sleepHours % 1 == 0 ? r.sleepHours.toInt().toString() : r.sleepHours.toStringAsFixed(1);
      recoveryDescriptors.add('Slept $sleepStr hrs');
    }
    if (r.muscleSoreness > 0) {
      recoveryDescriptors.add('Soreness: ${r.muscleSoreness}/10');
    }
    if (r.energyLevel > 0) {
      recoveryDescriptors.add('Energy: ${r.energyLevel}/10');
    }
    if (recoveryDescriptors.isNotEmpty) {
      buffer.writeln('Physical & Recovery State: ${recoveryDescriptors.join(', ')} (Readiness: ${r.status}).');
    }

    final injuryList = <String>{
      ...p.activeInjuries,
      ...ctx.deduced.activeInjuries,
    }.toList();
    if (injuryList.isNotEmpty) {
      buffer.writeln('Active Limitations / Safeguards: ${injuryList.join(', ')}.');
    }

    final prefsList = <String>{
      ...p.dislikedExercises.map((d) => 'Dislikes $d'),
      ...ctx.deduced.dislikedExercises.map((d) => 'Dislikes $d'),
      ...p.personalNotes,
      ...ctx.deduced.personalNotes,
    }.toList();
    if (prefsList.isNotEmpty) {
      buffer.writeln('Preferences & Notes: ${prefsList.join('; ')}.');
    }

    // 3. Available Gear
    final gearStr = p.equipmentList.isEmpty
        ? 'Bodyweight only'
        : p.equipmentList.map((e) => e.toString()).join(', ');
    buffer.writeln('Available Equipment: $gearStr.');

    // 4. Today\'s Workout Context
    final isDone = w.status == WorkoutStatus.completed;
    final isSkipped = w.status == WorkoutStatus.skipped;
    final isAdapted = w.status == WorkoutStatus.adapted;
    final statusStr = isDone
        ? 'Completed'
        : isSkipped
            ? 'Skipped'
            : isAdapted
                ? 'Adapted for today'
                : 'Pending / Scheduled';
    buffer.writeln("Workout Today: ${w.title} (${w.focusArea}, ~${w.estimatedDurationMin} min) - Status: $statusStr.");
    if (w.adaptationNote != null && w.adaptationNote!.isNotEmpty && w.adaptationNote != 'None') {
      buffer.writeln('Workout Adaptation: ${w.adaptationNote}.');
    }

    // 5. Today\'s Nutrition Context (Synthesized delta math)
    final totalCal = n.meals.fold<num>(0, (sum, m) => sum + m.calories).toInt();
    final totalProt = n.meals.fold<num>(0, (sum, m) => sum + m.proteinG).toInt();
    final remCal = (n.targetCalories - totalCal).clamp(0, 9999);
    final remProt = (n.targetProteinG - totalProt).clamp(0, 999);
    buffer.writeln("Nutrition Today: $totalCal / ${n.targetCalories} kcal eaten ($remCal kcal remaining). Protein: $totalProt / ${n.targetProteinG}g ($remProt" "g remaining). Water: ${n.waterMl} / ${n.targetWaterMl} ml.");
    if (n.meals.isNotEmpty) {
      final mealSummary = n.meals.map((m) => '${m.name} (${m.calories}kcal, ${m.proteinG}g P)').join(', ');
      buffer.writeln('Logged Meals: $mealSummary.');
    }

    if (state.adaptationNotice != null && state.adaptationNotice!.isNotEmpty) {
      buffer.writeln('System Notice: ${state.adaptationNotice}.');
    }

    return buffer.toString();
  }

  @override
  @override
  Future<WeeklyPlan> generateAIWeeklyPlan(
      TransformationEngineState contextState) async {
    final String weekId = 'w_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final List<String> dates = List.generate(
        7, (i) => now.add(Duration(days: i)).toIso8601String().split('T')[0]);

    try {
      final parsed = await _callProcessAiCommand(
        command: 'generateWeeklyPlan',
        statePayload: _buildStatePayload(contextState),
      );

      final days = (parsed['days'] as List? ?? []).map((d) {
        return WeeklyDayPlan(
          dayName: d['dayName']?.toString() ?? '',
          date: d['date']?.toString() ?? '',
          title: d['title']?.toString() ?? 'Training Day',
          focusArea: d['focusArea']?.toString() ?? '',
          isRestDay: d['isRestDay'] == true,
          exerciseNames: (d['exerciseNames'] as List? ?? []).map((e) => e.toString()).toList(),
          nutritionFocus: d['nutritionFocus']?.toString(),
        );
      }).toList();

      return WeeklyPlan(
        weekId: weekId,
        startDate: dates.first,
        endDate: dates.last,
        overview: parsed['overview']?.toString() ?? 'Your personalized weekly plan.',
        coachNote: parsed['coachNote']?.toString(),
        days: days,
        createdAt: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      _logError('generateAIWeeklyPlan', e);
      return WeeklyPlan(
        weekId: weekId,
        startDate: dates.first,
        endDate: dates.last,
        overview: 'System fallback plan loaded.',
        days: [],
        createdAt: DateTime.now().toIso8601String(),
      );
    }
  }

  @override
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
              : [ExerciseSet(setNumber: 1, targetReps: 10, targetWeightKg: 0.0, completed: true)],
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
        exercises: [],
        adaptationNote: "Manually logged: $naturalText",
      );
    }
  }

  @override
  @override
  Future<WeeklyDebrief> generateWeeklyDebrief(TransformationEngineState contextState) async {
    try {
      final statePayload = _buildStatePayload(contextState);
      final json = await _callProcessAiCommand(
        command: 'generateWeeklyDebrief',
        statePayload: statePayload,
      );
      return WeeklyDebrief.fromJson(json);
    } catch (e) {
      debugPrint('[AURA AI] generateWeeklyDebrief failed: $e');
      return WeeklyDebrief(
        headline: 'Weekly Synthesis',
        narrative: "You made meaningful strides this week!",
        keyAchievement: 'Consistent weekly routine engagement',
        primaryNextStep: 'Lock in 8 hours of sleep and daily protein target',
        adherenceScore: 82,
      );
    }
  }

  @override
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
        statePayload: {
          'profile': {
            'daysPerWeek': currentProfile.daysPerWeek,
            'equipmentList': currentProfile.equipmentList.map((e) => {'name': e.name}).toList(),
            'targetPhysique': currentProfile.targetPhysique,
          }
        },
      );
      return LifestyleIntakeResult.fromJson(json);
    } catch (e) {
      debugPrint('[AURA AI] parseLifestyleIntake failed: $e');
      return LifestyleIntakeResult(
        isComplete: false,
        daysPerWeek: currentProfile.daysPerWeek,
        equipment: currentProfile.equipmentList.map((e) => e.name).toList(),
        missingFields: ['daysPerWeek'],
        followUpQuestion: "Got it! Let's continue calibrating.",
        dynamicQuickReplies: ["3 days a week", "4 days a week", "5 days a week"],
        targetPhysique: currentProfile.targetPhysique,
      );
    }
  }
}
