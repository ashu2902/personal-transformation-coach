import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../providers/transformation_state.dart';
import '../models/models.dart';
import '../engine/engine_calculators.dart';

abstract class AIService {
  Future<String> generateCoachResponse(String userPrompt, TransformationEngineState contextState);
  Future<QuickLogParsedResult> parseQuickLog(String rawText, TransformationEngineState contextState);
  Future<DailyWorkout> adaptWorkoutWithAI(String adaptationRequest, TransformationEngineState contextState);
  Future<String> generateEngineDailyInsight(TransformationEngineState contextState);
  Future<DailyWorkout> generateAIInitialWorkout(UserProfile profile);
  Future<DailyNutrition> generateAIMetabolicPlan(UserProfile profile);
  Future<String> synthesizeAITodayFocus(TransformationEngineState contextState);
}

class GeminiAIProvider implements AIService {
  final String apiKey;
  final String modelName;

  static const String _defaultEnvApiKey = 'REDACTED_API_KEY';

  String get _effectiveApiKey {
    if (apiKey.trim().isNotEmpty) return apiKey.trim();
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.trim().isNotEmpty) return envKey.trim();
    return _defaultEnvApiKey;
  }

  GeminiAIProvider({
    required this.apiKey,
    this.modelName = 'gemini-3.6-flash',
  });

  void _logAIRequest(String methodName, String prompt) {
    debugPrint('\n=================== 🚀 [GEMINI AI REQUEST: $methodName] ===================');
    debugPrint('Model: $modelName');
    debugPrint('Timestamp: ${DateTime.now().toIso8601String()}');
    debugPrint('Prompt:\n$prompt');
    debugPrint('=========================================================================\n');
  }

  void _logAIResponse(String methodName, int statusCode, int durationMs, String responseBody) {
    debugPrint('\n=================== ✅ [GEMINI AI RESPONSE: $methodName] ===================');
    debugPrint('Status Code: $statusCode | Latency: ${durationMs}ms');
    debugPrint('Response Body:\n$responseBody');
    debugPrint('=========================================================================\n');
  }

  void _logAIError(String methodName, dynamic error) {
    debugPrint('\n=================== ⚠️ [GEMINI AI ERROR/FALLBACK: $methodName] ===================');
    debugPrint('Error Details: $error');
    debugPrint('Action: Falling back to offline rule engine.');
    debugPrint('============================================================================\n');
  }

  @override
  Future<String> generateCoachResponse(String userPrompt, TransformationEngineState contextState) async {
    if (_effectiveApiKey.isEmpty) {
      _logAIError('generateCoachResponse', 'GEMINI_API_KEY is empty');
      return RuleEngineAIProvider().generateCoachResponse(userPrompt, contextState);
    }

    final systemContext = _buildSystemContext(contextState);
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$_effectiveApiKey');
    final fullPrompt = 'System:\nYou are AURA, a friendly fitness coach.\n\nUser Context:\n$systemContext\n\nUser Message: $userPrompt';
    
    _logAIRequest('generateCoachResponse', fullPrompt);
    final timer = Stopwatch()..start();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {
                'text':
                    'You are AURA, a friendly and encouraging fitness coach. Speak in simple, everyday language without fitness jargon or technical terms. Keep your answers warm, concise (2-3 simple sentences max), and easy to understand for everyday people.'
              }
            ]
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': 'User Transformation State Context:\n$systemContext\n\nUser Message: $userPrompt'}
              ]
            }
          ]
        }),
      );

      _logAIResponse('generateCoachResponse', response.statusCode, timer.elapsedMilliseconds, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final replyText = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (replyText != null && replyText.toString().isNotEmpty) {
          return replyText.toString().trim();
        }
      }
    } catch (e) {
      _logAIError('generateCoachResponse', e);
    }

    return RuleEngineAIProvider().generateCoachResponse(userPrompt, contextState);
  }

  @override
  Future<QuickLogParsedResult> parseQuickLog(String rawText, TransformationEngineState contextState) async {
    if (_effectiveApiKey.isEmpty) {
      _logAIError('parseQuickLog', 'GEMINI_API_KEY is empty');
      return RuleEngineAIProvider().parseQuickLog(rawText, contextState);
    }

    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$_effectiveApiKey');
    final prompt = '''
Analyze this natural language daily fitness log entry: "$rawText".
User Context:
Name: ${contextState.profile.name}
Today Workout Scheduled: ${contextState.workout.title}

Extract structured changes. Return JSON:
{
  "workoutStatus": "completed" | "skipped" | "adapted" | null,
  "workoutReason": string or null,
  "mealsToAdd": [{"name": string, "calories": number, "proteinG": number, "carbsG": number, "fatG": number}],
  "skippedMeals": [string],
  "sleepHours": number or null,
  "weightKg": number or null,
  "energyLevel": number (1-5) or null,
  "coachFeedback": string (1-2 empathetic sentences acknowledging what happened)
}
''';

    _logAIRequest('parseQuickLog', prompt);
    final timer = Stopwatch()..start();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'generationConfig': {
            'responseMimeType': 'application/json',
          },
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': prompt}]
            }
          ]
        }),
      );

      _logAIResponse('parseQuickLog', response.statusCode, timer.elapsedMilliseconds, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jsonText = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (jsonText != null) {
          final parsed = jsonDecode(jsonText.toString());

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
            coachFeedback: parsed['coachFeedback']?.toString() ?? 'Express log updated!',
          );
        }
      }
    } catch (e) {
      _logAIError('parseQuickLog', e);
    }

    return RuleEngineAIProvider().parseQuickLog(rawText, contextState);
  }

  @override
  Future<DailyWorkout> adaptWorkoutWithAI(String adaptationRequest, TransformationEngineState contextState) async {
    if (_effectiveApiKey.isEmpty) {
      _logAIError('adaptWorkoutWithAI', 'GEMINI_API_KEY is empty');
      return RuleEngineAIProvider().adaptWorkoutWithAI(adaptationRequest, contextState);
    }

    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$_effectiveApiKey');
    final prompt = '''
User Request to Adapt Workout: "$adaptationRequest"
Current Workout: "${contextState.workout.title}"
Current Focus: ${contextState.workout.focusArea}
Current Exercises: ${contextState.workout.exercises.map((e) => e.name).join(', ')}

Adapt today's workout accordingly. Return JSON with this schema:
{
  "title": string,
  "adaptationNote": string,
  "exercises": [
    {
      "name": string,
      "targetSets": number,
      "targetReps": number,
      "targetWeightKg": number,
      "notes": string
    }
  ]
}
''';

    _logAIRequest('adaptWorkoutWithAI', prompt);
    final timer = Stopwatch()..start();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'generationConfig': {'responseMimeType': 'application/json'},
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': prompt}]
            }
          ]
        }),
      );

      _logAIResponse('adaptWorkoutWithAI', response.statusCode, timer.elapsedMilliseconds, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jsonText = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (jsonText != null) {
          final parsed = jsonDecode(jsonText.toString());
          final title = parsed['title']?.toString() ?? '${contextState.workout.title} (AI Adapted)';
          final note = parsed['adaptationNote']?.toString() ?? 'Adapted via Gemini 3.6 Flash';

          List<Exercise> adaptedExercises = [];
          if (parsed['exercises'] is List) {
            int idCounter = 1;
            for (var ex in parsed['exercises']) {
              final exName = ex['name']?.toString() ?? 'Adapted Exercise';
              final setNum = (ex['targetSets'] as num?)?.toInt() ?? 3;
              final repNum = (ex['targetReps'] as num?)?.toInt() ?? 10;
              final weight = (ex['targetWeightKg'] as num?)?.toDouble() ?? 20.0;
              final notes = ex['notes']?.toString() ?? 'AI Prescription';

              List<ExerciseSet> sets = List.generate(
                setNum,
                (i) => ExerciseSet(setNumber: i + 1, targetReps: repNum, targetWeightKg: weight),
              );

              adaptedExercises.add(Exercise(
                id: 'ai_ex_$idCounter',
                name: exName,
                targetMuscle: contextState.workout.focusArea,
                equipmentRequired: EquipmentType.dumbbells,
                sets: sets,
                notes: notes,
              ));
              idCounter++;
            }
          }

          if (adaptedExercises.isNotEmpty) {
            return contextState.workout.copyWith(
              title: title,
              status: WorkoutStatus.adapted,
              adaptationNote: note,
              exercises: adaptedExercises,
            );
          }
        }
      }
    } catch (e) {
      _logAIError('adaptWorkoutWithAI', e);
    }

    return RuleEngineAIProvider().adaptWorkoutWithAI(adaptationRequest, contextState);
  }

  @override
  Future<String> generateEngineDailyInsight(TransformationEngineState contextState) async {
    if (_effectiveApiKey.isEmpty) {
      _logAIError('generateEngineDailyInsight', 'GEMINI_API_KEY is empty');
      return RuleEngineAIProvider().generateEngineDailyInsight(contextState);
    }

    final totalProt = contextState.nutrition.meals.fold(0, (sum, m) => sum + m.proteinG);
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$_effectiveApiKey');
    final prompt = '''
Synthesize a 1-2 sentence daily coach focus briefing for ${contextState.profile.name}.
Context:
Goal: ${contextState.profile.goal.name}
Today Workout: ${contextState.workout.title} (Status: ${contextState.workout.status.name})
Recovery Readiness: ${contextState.recovery.recoveryScore}% (Sleep: ${contextState.recovery.sleepHours} hrs)
Protein Progress: ${totalProt}g / ${contextState.nutrition.targetProteinG}g

Keep it warm, encouraging, plain English, and action-oriented.
''';

    _logAIRequest('generateEngineDailyInsight', prompt);
    final timer = Stopwatch()..start();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': prompt}]
            }
          ]
        }),
      );

      _logAIResponse('generateEngineDailyInsight', response.statusCode, timer.elapsedMilliseconds, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final replyText = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (replyText != null && replyText.toString().isNotEmpty) {
          return replyText.toString().trim();
        }
      }
    } catch (e) {
      _logAIError('generateEngineDailyInsight', e);
    }

    return RuleEngineAIProvider().generateEngineDailyInsight(contextState);
  }

  @override
  Future<DailyWorkout> generateAIInitialWorkout(UserProfile profile) async {
    if (_effectiveApiKey.isEmpty) {
      _logAIError('generateAIInitialWorkout', 'GEMINI_API_KEY is empty');
      return RuleEngineAIProvider().generateAIInitialWorkout(profile);
    }

    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$_effectiveApiKey');
    final prompt = '''
Generate a highly personalized initial workout plan for:
Name: ${profile.name}
Goal: ${profile.goal.name} (Target Physique: ${profile.targetPhysique})
Experience Level: ${profile.experienceLevel.name}
Working Weight Baselines (kg): Bench: ${profile.benchPress1RMKg ?? 'N/A'}, Squat: ${profile.squat1RMKg ?? 'N/A'}, Deadlift: ${profile.deadlift1RMKg ?? 'N/A'}
Active Joint Safeguards/Injuries: ${profile.activeInjuries.isEmpty ? 'None' : profile.activeInjuries.join(', ')}
Days Per Week: ${profile.daysPerWeek}
Equipment Available: ${profile.availableEquipment.map((e) => e.name).join(', ')}

Prescribe 4-5 targeted exercises customized for their baseline and joint safety. Return JSON with this schema:
{
  "title": string,
  "focusArea": string,
  "estimatedDurationMin": number,
  "adaptationNote": string,
  "exercises": [
    {
      "name": string,
      "targetMuscle": string,
      "targetSets": number,
      "targetReps": number,
      "targetWeightKg": number,
      "notes": string
    }
  ]
}
''';

    _logAIRequest('generateAIInitialWorkout', prompt);
    final timer = Stopwatch()..start();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'generationConfig': {'responseMimeType': 'application/json'},
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': prompt}]
            }
          ]
        }),
      );

      _logAIResponse('generateAIInitialWorkout', response.statusCode, timer.elapsedMilliseconds, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jsonText = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (jsonText != null) {
          final parsed = jsonDecode(jsonText.toString());
          final title = parsed['title']?.toString() ?? '${profile.daysPerWeek}-Day PPL (Gemini AI Initial Plan)';
          final focus = parsed['focusArea']?.toString() ?? 'Chest, Shoulders & Triceps';
          final duration = (parsed['estimatedDurationMin'] as num?)?.toInt() ?? 45;
          final note = parsed['adaptationNote']?.toString() ?? 'Tailored for ${profile.name} via Gemini 3.6 Flash';

          List<Exercise> exercises = [];
          if (parsed['exercises'] is List) {
            int idCounter = 1;
            for (var ex in parsed['exercises']) {
              final exName = ex['name']?.toString() ?? 'Exercise';
              final muscle = ex['targetMuscle']?.toString() ?? focus;
              final setNum = (ex['targetSets'] as num?)?.toInt() ?? 3;
              final repNum = (ex['targetReps'] as num?)?.toInt() ?? 10;
              final weight = (ex['targetWeightKg'] as num?)?.toDouble() ?? 30.0;
              final notes = ex['notes']?.toString() ?? 'Gemini AI Prescription';

              List<ExerciseSet> sets = List.generate(
                setNum,
                (i) => ExerciseSet(setNumber: i + 1, targetReps: repNum, targetWeightKg: weight),
              );

              exercises.add(Exercise(
                id: 'ai_init_ex_$idCounter',
                name: exName,
                targetMuscle: muscle,
                equipmentRequired: profile.availableEquipment.isNotEmpty ? profile.availableEquipment.first : EquipmentType.dumbbells,
                sets: sets,
                notes: notes,
              ));
              idCounter++;
            }
          }

          if (exercises.isNotEmpty) {
            final todayStr = DateTime.now().toIso8601String().split('T')[0];
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
          }
        }
      }
    } catch (e) {
      _logAIError('generateAIInitialWorkout', e);
    }

    return RuleEngineAIProvider().generateAIInitialWorkout(profile);
  }

  @override
  Future<DailyNutrition> generateAIMetabolicPlan(UserProfile profile) async {
    if (_effectiveApiKey.isEmpty) {
      _logAIError('generateAIMetabolicPlan', 'GEMINI_API_KEY is empty');
      return RuleEngineAIProvider().generateAIMetabolicPlan(profile);
    }

    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$_effectiveApiKey');
    final prompt = '''
Calculate optimal daily calories and macronutrient targets for:
Name: ${profile.name}, Age: ${profile.age}, Height: ${profile.heightCm}cm, Weight: ${profile.weightKg}kg (Target: ${profile.targetWeightKg}kg)
Primary Goal: ${profile.goal.name} (Target Physique: ${profile.targetPhysique})
Training Frequency: ${profile.daysPerWeek} days/week

Return JSON:
{
  "targetCalories": number,
  "targetProteinG": number,
  "targetCarbsG": number,
  "targetFatG": number
}
''';

    _logAIRequest('generateAIMetabolicPlan', prompt);
    final timer = Stopwatch()..start();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'generationConfig': {'responseMimeType': 'application/json'},
          'contents': [{'role': 'user', 'parts': [{'text': prompt}]}]
        }),
      );

      _logAIResponse('generateAIMetabolicPlan', response.statusCode, timer.elapsedMilliseconds, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jsonText = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (jsonText != null) {
          final parsed = jsonDecode(jsonText.toString());
          final todayStr = DateTime.now().toIso8601String().split('T')[0];
          return DailyNutrition(
            date: todayStr,
            targetCalories: (parsed['targetCalories'] as num?)?.toInt() ?? 2200,
            targetProteinG: (parsed['targetProteinG'] as num?)?.toInt() ?? 160,
            targetCarbsG: (parsed['targetCarbsG'] as num?)?.toInt() ?? 220,
            targetFatG: (parsed['targetFatG'] as num?)?.toInt() ?? 60,
            meals: [],
          );
        }
      }
    } catch (e) {
      _logAIError('generateAIMetabolicPlan', e);
    }

    return RuleEngineAIProvider().generateAIMetabolicPlan(profile);
  }

  @override
  Future<String> synthesizeAITodayFocus(TransformationEngineState contextState) async {
    if (_effectiveApiKey.isEmpty) {
      _logAIError('synthesizeAITodayFocus', 'GEMINI_API_KEY is empty');
      return RuleEngineAIProvider().synthesizeAITodayFocus(contextState);
    }

    final systemContext = _buildSystemContext(contextState);
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$_effectiveApiKey');
    final prompt = 'Based on the user state context below, generate a 1-sentence action-focused daily strategy briefing for today:\n$systemContext';

    _logAIRequest('synthesizeAITodayFocus', prompt);
    final timer = Stopwatch()..start();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'role': 'user', 'parts': [{'text': prompt}]}]
        }),
      );

      _logAIResponse('synthesizeAITodayFocus', response.statusCode, timer.elapsedMilliseconds, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final replyText = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (replyText != null && replyText.toString().trim().isNotEmpty) {
          return replyText.toString().trim();
        }
      }
    } catch (e) {
      _logAIError('synthesizeAITodayFocus', e);
    }

    return RuleEngineAIProvider().synthesizeAITodayFocus(contextState);
  }

  String _buildSystemContext(TransformationEngineState state) {
    final p = state.profile;
    final w = state.workout;
    final n = state.nutrition;
    final r = state.recovery;

    final totalCal = n.meals.fold(0, (sum, m) => sum + m.calories);
    final totalProt = n.meals.fold(0, (sum, m) => sum + m.proteinG);

    return '''
User Name: ${p.name}
Goal: ${p.goal.name} (Target Physique: ${p.targetPhysique})
Current Weight: ${p.weightKg} kg (Target: ${p.targetWeightKg} kg)
Today Workout: ${w.title} (Status: ${w.status.name})
Today Nutrition: $totalCal / ${n.targetCalories} kcal, Protein: $totalProt / ${n.targetProteinG}g
Recovery Score: ${r.recoveryScore}% (${r.status})
Adaptation Notice: ${state.adaptationNotice ?? 'None'}
''';
  }
}

class RuleEngineAIProvider implements AIService {
  @override
  Future<String> generateCoachResponse(String userPrompt, TransformationEngineState contextState) async {
    final query = userPrompt.toLowerCase();
    final p = contextState.profile;
    final w = contextState.workout;
    final n = contextState.nutrition;
    final r = contextState.recovery;

    final totalProt = n.meals.fold(0, (sum, m) => sum + m.proteinG);
    final remainingProt = (n.targetProteinG - totalProt).clamp(0, 999);

    if (query.contains('protein') || query.contains('eat') || query.contains('food')) {
      if (remainingProt == 0) {
        return "Awesome work, ${p.name}! You've already met your daily target of ${n.targetProteinG}g protein. Focus on hydration and rest now.";
      }
      return "You currently have ${remainingProt}g of protein left to reach your ${n.targetProteinG}g goal. Try adding a whey shake (30g P), Greek yogurt (20g P), or chicken breast (45g P).";
    }

    if (query.contains('workout') || query.contains('train') || query.contains('exercise') || query.contains('swap')) {
      if (w.status == WorkoutStatus.completed) {
        return "Today's training session (${w.title}) is already completed! Rest up so your muscles can adapt and recover.";
      }
      return "Today's scheduled session is '${w.title}' (${w.focusArea}). You can tap the swap icon next to any exercise to choose alternatives matching your equipment.";
    }

    if (query.contains('sore') || query.contains('sleep') || query.contains('recover') || query.contains('tired')) {
      if (r.recoveryScore < 50) {
        return "Your readiness score is low (${r.recoveryScore}%). Systemic fatigue is high, so today's workout has been auto-scaled to an active recovery deload session.";
      }
      return "Your recovery readiness is at ${r.recoveryScore}% (${r.status}). You slept ${r.sleepHours} hours last night and are in a solid zone to train.";
    }

    if (query.contains('weight') || query.contains('progress') || query.contains('stall')) {
      final diff = (p.targetWeightKg - p.weightKg).abs();
      return "You are currently at ${p.weightKg} kg, ${diff.toStringAsFixed(1)} kg away from your target of ${p.targetWeightKg} kg (${p.targetPhysique}). Trust the 14-day trend averages!";
    }

    return "System context active for ${p.name}. Currently targeting ${n.targetCalories} kcal and ${w.title}. How else can I guide your transformation today?";
  }

  @override
  Future<QuickLogParsedResult> parseQuickLog(String rawText, TransformationEngineState contextState) async {
    final text = rawText.toLowerCase();

    WorkoutStatus? status;
    String? reason;
    if (text.contains('skip') || text.contains('missed gym') || text.contains('no gym') || text.contains('rest day')) {
      status = WorkoutStatus.skipped;
      reason = "Logged via Express AI Log";
    } else if (text.contains('finished') || text.contains('done') || text.contains('completed') || text.contains('hit gym') || text.contains('trained')) {
      status = WorkoutStatus.completed;
    }

    List<MealItem> meals = [];
    if (text.contains('pizza')) {
      meals.add(MealItem(name: 'Pizza Slices', calories: 650, proteinG: 24, carbsG: 70, fatG: 28));
    }
    if (text.contains('burger')) {
      meals.add(MealItem(name: 'Burger & Fries', calories: 750, proteinG: 32, carbsG: 65, fatG: 35));
    }
    if (text.contains('shake') || text.contains('protein')) {
      meals.add(MealItem(name: 'Whey Protein Shake', calories: 180, proteinG: 30, carbsG: 4, fatG: 2));
    }
    if (text.contains('eggs') || text.contains('egg')) {
      meals.add(MealItem(name: 'Eggs & Toast', calories: 380, proteinG: 22, carbsG: 28, fatG: 16));
    }
    if (text.contains('chicken')) {
      meals.add(MealItem(name: 'Chicken Rice Bowl', calories: 550, proteinG: 45, carbsG: 50, fatG: 10));
    }

    List<String> skippedMeals = [];
    if (text.contains('missed lunch') || text.contains('skipped lunch')) skippedMeals.add('lunch');
    if (text.contains('missed breakfast') || text.contains('skipped breakfast')) skippedMeals.add('breakfast');

    double? sleep;
    final sleepMatch = RegExp(r'(\d+\.?\d*)\s*(?:hrs|hours|hr|h\b)').firstMatch(text);
    if (sleepMatch != null) {
      sleep = double.tryParse(sleepMatch.group(1) ?? '');
    }

    double? weight;
    final weightMatch = RegExp(r'(\d+\.?\d*)\s*kg').firstMatch(text) ?? RegExp(r'weight\s*(\d+\.?\d*)').firstMatch(text);
    if (weightMatch != null) {
      weight = double.tryParse(weightMatch.group(1) ?? '');
    }

    String feedback = "Express log parsed! ";
    if (status == WorkoutStatus.skipped) {
      feedback += "No worries about skipping the gym today—rest is key for long-term progress. ";
    } else if (status == WorkoutStatus.completed) {
      feedback += "Great job completing your workout today! ";
    }
    if (meals.isNotEmpty) {
      feedback += "Added ${meals.length} meal item(s) to your daily nutrition log. ";
    }

    return QuickLogParsedResult(
      workoutStatus: status,
      workoutReason: reason,
      mealsToAdd: meals,
      skippedMeals: skippedMeals,
      sleepHours: sleep,
      weightKg: weight,
      coachFeedback: feedback.trim(),
    );
  }

  @override
  Future<DailyWorkout> adaptWorkoutWithAI(String adaptationRequest, TransformationEngineState contextState) async {
    final scaledExercises = contextState.workout.exercises.map((ex) {
      final reducedSets = ex.sets.map((s) => s.copyWith(targetWeightKg: (s.targetWeightKg * 0.9).roundToDouble())).toList();
      return ex.copyWith(sets: reducedSets, notes: 'Adapted for $adaptationRequest');
    }).toList();

    return contextState.workout.copyWith(
      title: '${contextState.workout.title} (Adapted)',
      status: WorkoutStatus.adapted,
      adaptationNote: 'Adapted for: $adaptationRequest',
      exercises: scaledExercises,
    );
  }

  @override
  Future<String> generateEngineDailyInsight(TransformationEngineState contextState) async {
    final r = contextState.recovery;
    final w = contextState.workout;
    return "Readiness is at ${r.recoveryScore}%. Focus on executing ${w.title} and hitting your target protein goal today!";
  }

  @override
  Future<DailyWorkout> generateAIInitialWorkout(UserProfile profile) async {
    return EngineCalculators.generateWorkoutForSplit(
      goal: profile.goal,
      availableEquipment: profile.availableEquipment,
      daysPerWeek: profile.daysPerWeek,
    );
  }

  @override
  Future<DailyNutrition> generateAIMetabolicPlan(UserProfile profile) async {
    return EngineCalculators.calculateInitialNutrition(
      weightKg: profile.weightKg,
      heightCm: profile.heightCm,
      ageYears: profile.age,
      goal: profile.goal,
      daysPerWeek: profile.daysPerWeek,
    );
  }

  @override
  Future<String> synthesizeAITodayFocus(TransformationEngineState contextState) async {
    final w = contextState.workout;
    final r = contextState.recovery;
    return "Readiness is at ${r.recoveryScore}%. Execute ${w.title} and reach your daily target protein goal.";
  }
}
