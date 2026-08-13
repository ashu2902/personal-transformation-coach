import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../providers/transformation_state.dart';
import '../models/models.dart';

abstract class AIService {
  Future<String> generateCoachResponse(String userPrompt, TransformationEngineState contextState);
  Future<QuickLogParsedResult> parseQuickLog(String rawText, TransformationEngineState contextState);
  Future<DailyWorkout> adaptWorkoutWithAI(String adaptationRequest, TransformationEngineState contextState);
  Future<String> generateEngineDailyInsight(TransformationEngineState contextState);
  Future<DailyWorkout> generateAIInitialWorkout(UserProfile profile);
  Future<DailyNutrition> generateAIMetabolicPlan(UserProfile profile);
  Future<String> synthesizeAITodayFocus(TransformationEngineState contextState);
  Future<DailyNutrition> generateAIAdaptedNutrition(TransformationEngineState contextState, String reason);
  Future<DailyWorkout> generateAIAdaptedWorkout(TransformationEngineState contextState, String reason);
}

class GeminiAIProvider implements AIService {
  final String apiKey;
  final String modelName;

  GeminiAIProvider({
    required this.apiKey,
    this.modelName = 'gemini-3.6-flash',
  });

  String get _effectiveApiKey {
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.trim().isNotEmpty && !envKey.contains('REDACTED')) return envKey.trim();
    if (apiKey.trim().isNotEmpty && !apiKey.contains('REDACTED')) return apiKey.trim();
    return '';
  }

  Uri get _url => Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$_effectiveApiKey');

  void _logRequest(String method, String prompt) {
    debugPrint('\n===== 🚀 [GEMINI AI REQUEST: $method] =====');
    debugPrint('Model: $modelName | Time: ${DateTime.now().toIso8601String()}');
    debugPrint('Prompt:\n$prompt');
    debugPrint('===========================================\n');
  }

  void _logResponse(String method, int statusCode, int ms, String body) {
    debugPrint('\n===== ✅ [GEMINI AI RESPONSE: $method] =====');
    debugPrint('Status: $statusCode | Latency: ${ms}ms');
    debugPrint('Body:\n$body');
    debugPrint('============================================\n');
  }

  void _logError(String method, dynamic error) {
    debugPrint('\n===== ❌ [GEMINI AI ERROR: $method] =====');
    debugPrint('Error: $error');
    debugPrint('=========================================\n');
  }

  Future<Map<String, dynamic>> _callGeminiJson(String method, String prompt) async {
    _logRequest(method, prompt);
    final timer = Stopwatch()..start();
    final response = await http.post(
      _url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'generationConfig': {'responseMimeType': 'application/json'},
        'contents': [{'role': 'user', 'parts': [{'text': prompt}]}],
      }),
    );
    _logResponse(method, response.statusCode, timer.elapsedMilliseconds, response.body);
    if (response.statusCode != 200) {
      throw Exception('Gemini API error ${response.statusCode}: ${response.body}');
    }
    final data = jsonDecode(response.body);
    final jsonText = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
    if (jsonText == null) throw Exception('Gemini returned empty JSON for $method');
    return jsonDecode(jsonText.toString()) as Map<String, dynamic>;
  }

  Future<String> _callGeminiText(String method, String prompt, {String? systemInstruction}) async {
    _logRequest(method, prompt);
    final timer = Stopwatch()..start();
    final body = <String, dynamic>{
      'contents': [{'role': 'user', 'parts': [{'text': prompt}]}],
    };
    if (systemInstruction != null) {
      body['system_instruction'] = {'parts': [{'text': systemInstruction}]};
    }
    final response = await http.post(
      _url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    _logResponse(method, response.statusCode, timer.elapsedMilliseconds, response.body);
    if (response.statusCode != 200) {
      throw Exception('Gemini API error ${response.statusCode}: ${response.body}');
    }
    final data = jsonDecode(response.body);
    final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
    if (text == null || text.toString().trim().isEmpty) {
      throw Exception('Gemini returned empty text for $method');
    }
    return text.toString().trim();
  }

  @override
  Future<String> generateCoachResponse(String userPrompt, TransformationEngineState contextState) async {
    try {
      return await _callGeminiText(
        'generateCoachResponse',
        'User Transformation Context:\n${_buildSystemContext(contextState)}\n\nUser Message: $userPrompt',
        systemInstruction:
            'You are AURA, a friendly and encouraging personal fitness coach. Speak in simple, everyday language without technical jargon. Keep answers warm, concise (2-3 sentences max), and easy to understand for everyday people.',
      );
    } catch (e) {
      _logError('generateCoachResponse', e);
      rethrow;
    }
  }

  @override
  Future<QuickLogParsedResult> parseQuickLog(String rawText, TransformationEngineState contextState) async {
    final prompt = '''
Analyze this natural language daily fitness log entry: "$rawText"
User: ${contextState.profile.name}, Scheduled Workout: ${contextState.workout.title}

Extract structured data. Return JSON:
{
  "workoutStatus": "completed" | "skipped" | "adapted" | null,
  "workoutReason": string or null,
  "mealsToAdd": [{"name": string, "calories": number, "proteinG": number, "carbsG": number, "fatG": number}],
  "skippedMeals": [string],
  "sleepHours": number or null,
  "weightKg": number or null,
  "energyLevel": number (1-5) or null,
  "coachFeedback": string (1-2 empathetic sentences)
}
''';
    try {
      final parsed = await _callGeminiJson('parseQuickLog', prompt);
      WorkoutStatus? status;
      if (parsed['workoutStatus'] == 'completed') status = WorkoutStatus.completed;
      if (parsed['workoutStatus'] == 'skipped') status = WorkoutStatus.skipped;
      if (parsed['workoutStatus'] == 'adapted') status = WorkoutStatus.adapted;
      List<MealItem> meals = [];
      if (parsed['mealsToAdd'] is List) {
        for (var m in parsed['mealsToAdd']) {
          meals.add(MealItem(
            name: m['name']?.toString() ?? 'Logged Item',
            calories: (m['calories'] as num?)?.toInt() ?? 300,
            proteinG: (m['proteinG'] as num?)?.toInt() ?? 20,
            carbsG: (m['carbsG'] as num?)?.toInt() ?? 30,
            fatG: (m['fatG'] as num?)?.toInt() ?? 10,
          ));
        }
      }
      List<String> skipped = [];
      if (parsed['skippedMeals'] is List) {
        skipped = (parsed['skippedMeals'] as List).map((e) => e.toString()).toList();
      }
      return QuickLogParsedResult(
        workoutStatus: status,
        workoutReason: parsed['workoutReason']?.toString(),
        mealsToAdd: meals,
        skippedMeals: skipped,
        sleepHours: (parsed['sleepHours'] as num?)?.toDouble(),
        weightKg: (parsed['weightKg'] as num?)?.toDouble(),
        energyLevel: (parsed['energyLevel'] as num?)?.toInt(),
        coachFeedback: parsed['coachFeedback']?.toString() ?? 'Log updated!',
      );
    } catch (e) {
      _logError('parseQuickLog', e);
      rethrow;
    }
  }

  @override
  Future<DailyWorkout> adaptWorkoutWithAI(String adaptationRequest, TransformationEngineState contextState) async {
    final prompt = '''
User Request: "$adaptationRequest"
Current Workout: "${contextState.workout.title}" — ${contextState.workout.focusArea}
Current Exercises: ${contextState.workout.exercises.map((e) => e.name).join(', ')}
Available Equipment: ${contextState.profile.availableEquipment.map((e) => e.name).join(', ')}
Active Safeguards: ${contextState.profile.activeInjuries.isEmpty ? 'None' : contextState.profile.activeInjuries.join(', ')}

Adapt the workout accordingly. Return JSON:
{
  "title": string,
  "adaptationNote": string,
  "exercises": [{"name": string, "targetMuscle": string, "targetSets": number, "targetReps": number, "targetWeightKg": number, "notes": string}]
}
''';
    try {
      final parsed = await _callGeminiJson('adaptWorkoutWithAI', prompt);
      return _parseWorkoutJson(parsed, contextState.workout, contextState.profile);
    } catch (e) {
      _logError('adaptWorkoutWithAI', e);
      rethrow;
    }
  }

  @override
  Future<String> generateEngineDailyInsight(TransformationEngineState contextState) async {
    final totalProt = contextState.nutrition.meals.fold(0, (sum, m) => sum + m.proteinG);
    final prompt = '''
Write a 1-2 sentence daily coach briefing for ${contextState.profile.name}.
Goal: ${contextState.profile.goal.name} | Workout: ${contextState.workout.title} (${contextState.workout.status.name})
Recovery: ${contextState.recovery.recoveryScore}% | Protein: ${totalProt}g / ${contextState.nutrition.targetProteinG}g
Keep it warm, encouraging, plain English, and action-focused.
''';
    try {
      return await _callGeminiText('generateEngineDailyInsight', prompt);
    } catch (e) {
      _logError('generateEngineDailyInsight', e);
      rethrow;
    }
  }

  @override
  Future<DailyWorkout> generateAIInitialWorkout(UserProfile profile) async {
    final prompt = '''
Generate a highly personalized initial workout day for:
Name: ${profile.name}, Gender: ${profile.gender}, Age: ${profile.age}
Goal: ${profile.goal.name} (Target Physique: ${profile.targetPhysique})
Experience: ${profile.experienceLevel.name}
Lifting Baselines (kg): Bench=${profile.benchPress1RMKg ?? 'N/A'}, Squat=${profile.squat1RMKg ?? 'N/A'}, Deadlift=${profile.deadlift1RMKg ?? 'N/A'}
Joint Safeguards: ${profile.activeInjuries.isEmpty ? 'None' : profile.activeInjuries.join(', ')}
Training Days/Week: ${profile.daysPerWeek}
Available Equipment: ${profile.availableEquipment.map((e) => e.name).join(', ')}

Prescribe 4-5 targeted exercises customized to their baseline, gender, and joint safety. Return JSON:
{
  "title": string,
  "focusArea": string,
  "estimatedDurationMin": number,
  "adaptationNote": string,
  "exercises": [{"name": string, "targetMuscle": string, "targetSets": number, "targetReps": number, "targetWeightKg": number, "notes": string}]
}
''';
    try {
      final parsed = await _callGeminiJson('generateAIInitialWorkout', prompt);
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final title = parsed['title']?.toString() ?? '${profile.daysPerWeek}-Day AI Plan';
      final focus = parsed['focusArea']?.toString() ?? 'Full Body';
      final duration = (parsed['estimatedDurationMin'] as num?)?.toInt() ?? 45;
      final note = parsed['adaptationNote']?.toString() ?? 'Tailored for ${profile.name} by AURA AI';
      final exercises = _parseExerciseList(parsed['exercises'], focus, profile.availableEquipment, 'ai_init');
      return DailyWorkout(
        id: 'workout_$todayStr',
        date: todayStr,
        title: title,
        focusArea: focus,
        estimatedDurationMin: duration,
        status: WorkoutStatus.adapted,
        adaptationNote: note,
        exercises: exercises,
      );
    } catch (e) {
      _logError('generateAIInitialWorkout', e);
      rethrow;
    }
  }

  @override
  Future<DailyNutrition> generateAIMetabolicPlan(UserProfile profile) async {
    final prompt = '''
Calculate optimal daily calories and macros for this person using the Mifflin-St Jeor equation, appropriate gender correction, and goal-based deficit/surplus:
Name: ${profile.name}
Gender: ${profile.gender}
Age: ${profile.age} years
Height: ${profile.heightCm} cm
Current Weight: ${profile.weightKg} kg
Target Weight: ${profile.targetWeightKg} kg
Goal: ${profile.goal.name} (Target Physique: ${profile.targetPhysique})
Training Frequency: ${profile.daysPerWeek} days/week

Apply correct gender-specific BMR formula. Return JSON:
{
  "targetCalories": number,
  "targetProteinG": number,
  "targetCarbsG": number,
  "targetFatG": number,
  "targetWaterMl": number,
  "reasoning": string (1 sentence explaining the calorie target)
}
''';
    try {
      final parsed = await _callGeminiJson('generateAIMetabolicPlan', prompt);
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
  Future<String> synthesizeAITodayFocus(TransformationEngineState contextState) async {
    try {
      return await _callGeminiText(
        'synthesizeAITodayFocus',
        'Based on the context below, write one action-focused sentence for ${contextState.profile.name}\'s day:\n${_buildSystemContext(contextState)}',
      );
    } catch (e) {
      _logError('synthesizeAITodayFocus', e);
      rethrow;
    }
  }

  @override
  Future<DailyNutrition> generateAIAdaptedNutrition(TransformationEngineState contextState, String reason) async {
    final p = contextState.profile;
    final n = contextState.nutrition;
    final history = contextState.progressHistory;
    final prompt = '''
Adapt the nutrition plan for ${p.name} (${p.gender}, ${p.age}y, ${p.weightKg}kg) because: "$reason"
Current targets: ${n.targetCalories} kcal, ${n.targetProteinG}g protein, ${n.targetCarbsG}g carbs, ${n.targetFatG}g fat
Goal: ${p.goal.name}
Weight history (last entries): ${history.length > 3 ? history.sublist(history.length - 3).map((h) => '${h.date}: ${h.weightKg}kg').join(', ') : 'insufficient data'}

Adjust targets intelligently. Return JSON:
{
  "targetCalories": number,
  "targetProteinG": number,
  "targetCarbsG": number,
  "targetFatG": number,
  "targetWaterMl": number,
  "adaptationReason": string
}
''';
    try {
      final parsed = await _callGeminiJson('generateAIAdaptedNutrition', prompt);
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
  Future<DailyWorkout> generateAIAdaptedWorkout(TransformationEngineState contextState, String reason) async {
    final prompt = '''
Adapt the workout for ${contextState.profile.name} because: "$reason"
Current workout: "${contextState.workout.title}" — ${contextState.workout.focusArea}
Recovery score: ${contextState.recovery.recoveryScore}% | Sleep: ${contextState.recovery.sleepHours}hrs
Available Equipment: ${contextState.profile.availableEquipment.map((e) => e.name).join(', ')}
Safeguards: ${contextState.profile.activeInjuries.isEmpty ? 'None' : contextState.profile.activeInjuries.join(', ')}

Return JSON:
{
  "title": string,
  "adaptationNote": string,
  "exercises": [{"name": string, "targetMuscle": string, "targetSets": number, "targetReps": number, "targetWeightKg": number, "notes": string}]
}
''';
    try {
      final parsed = await _callGeminiJson('generateAIAdaptedWorkout', prompt);
      return _parseWorkoutJson(parsed, contextState.workout, contextState.profile);
    } catch (e) {
      _logError('generateAIAdaptedWorkout', e);
      rethrow;
    }
  }

  DailyWorkout _parseWorkoutJson(Map<String, dynamic> parsed, DailyWorkout current, UserProfile profile) {
    final title = parsed['title']?.toString() ?? '${current.title} (AI Adapted)';
    final note = parsed['adaptationNote']?.toString() ?? 'Adapted by AURA AI';
    final exercises = _parseExerciseList(parsed['exercises'], current.focusArea, profile.availableEquipment, 'ai_adapt');
    if (exercises.isEmpty) throw Exception('Gemini returned empty exercise list');
    return current.copyWith(
      title: title,
      status: WorkoutStatus.adapted,
      adaptationNote: note,
      exercises: exercises,
    );
  }

  List<Exercise> _parseExerciseList(dynamic rawList, String fallbackMuscle, List<EquipmentType> equipment, String idPrefix) {
    final List<Exercise> exercises = [];
    if (rawList is! List) return exercises;
    int idCounter = 1;
    for (var ex in rawList) {
      final name = ex['name']?.toString() ?? 'Exercise';
      final muscle = ex['targetMuscle']?.toString() ?? fallbackMuscle;
      final setNum = (ex['targetSets'] as num?)?.toInt() ?? 3;
      final repNum = (ex['targetReps'] as num?)?.toInt() ?? 10;
      final weight = (ex['targetWeightKg'] as num?)?.toDouble() ?? 20.0;
      final notes = ex['notes']?.toString() ?? 'AI Prescribed';
      final sets = List.generate(
        setNum,
        (i) => ExerciseSet(setNumber: i + 1, targetReps: repNum, targetWeightKg: weight),
      );
      exercises.add(Exercise(
        id: '${idPrefix}_$idCounter',
        name: name,
        targetMuscle: muscle,
        equipmentRequired: equipment.isNotEmpty ? equipment.first : EquipmentType.dumbbells,
        sets: sets,
        notes: notes,
      ));
      idCounter++;
    }
    return exercises;
  }

  String _buildSystemContext(TransformationEngineState state) {
    final p = state.profile;
    final w = state.workout;
    final n = state.nutrition;
    final r = state.recovery;
    final totalCal = n.meals.fold(0, (sum, m) => sum + m.calories);
    final totalProt = n.meals.fold(0, (sum, m) => sum + m.proteinG);
    return '''
Name: ${p.name} | Gender: ${p.gender} | Age: ${p.age} | Weight: ${p.weightKg}kg → ${p.targetWeightKg}kg
Goal: ${p.goal.name} (${p.targetPhysique})
Workout: ${w.title} (${w.status.name}) | Focus: ${w.focusArea}
Nutrition: $totalCal / ${n.targetCalories} kcal | Protein: $totalProt / ${n.targetProteinG}g
Recovery: ${r.recoveryScore}% (${r.status}) | Sleep: ${r.sleepHours}hrs
Adaptation: ${state.adaptationNotice ?? 'None'}
''';
  }
}
