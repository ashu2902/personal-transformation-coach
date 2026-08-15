import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../providers/transformation_state.dart';
import '../models/models.dart';

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
}

class GeminiAIProvider implements AIService {
  final String modelName;

  GeminiAIProvider({
    this.modelName = 'gemini-2.0-flash',
  });

  String get _proxyUrl {
    const customProxy = String.fromEnvironment('AI_PROXY_URL');
    if (customProxy.trim().isNotEmpty) {
      return customProxy.trim();
    }
    return 'https://us-central1-aura-coach-ashu-7.cloudfunctions.net/callGeminiProxy';
  }

  void _logRequest(String method, String prompt) {
    debugPrint('\n===== 🚀 [AURA AI PROXY REQUEST: $method] =====');
    debugPrint('Proxy URL: $_proxyUrl | Model: $modelName | Time: ${DateTime.now().toIso8601String()}');
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

  Future<Map<String, dynamic>> _callGeminiJson(
      String method, String prompt,
      {String? systemInstruction, Uint8List? imageBytes, String? mimeType}) async {
    _logRequest(method, prompt + (imageBytes != null ? '\n[IMAGE ATTACHED: ${imageBytes.length} bytes]' : ''));
    final timer = Stopwatch()..start();

    final fullPrompt = systemInstruction != null
        ? 'SYSTEM INSTRUCTION:\n$systemInstruction\n\nUSER REQUEST:\n$prompt'
        : prompt;

    try {
      final proxyPayload = <String, dynamic>{
        'prompt': fullPrompt,
        'model': modelName,
        'isJson': true,
      };
      if (imageBytes != null) {
        proxyPayload['imageBase64'] = base64Encode(imageBytes);
        proxyPayload['mimeType'] = mimeType ?? 'image/jpeg';
      }

      final proxyResponse = await http.post(
        Uri.parse(_proxyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(proxyPayload),
      );

      if (proxyResponse.statusCode == 200) {
        final data = jsonDecode(proxyResponse.body);
        final rawText = data['text'] as String?;
        if (rawText != null && rawText.trim().isNotEmpty) {
          _logResponse(method, 200, timer.elapsedMilliseconds, rawText);
          final cleanJson = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
          return jsonDecode(cleanJson) as Map<String, dynamic>;
        }
      } else {
        _logError(method, 'Proxy returned status ${proxyResponse.statusCode}: ${proxyResponse.body}');
        throw Exception('AURA backend proxy error: ${proxyResponse.statusCode}');
      }
    } catch (e) {
      _logError(method, e);
      rethrow;
    }

    throw Exception('AURA AI service temporarily unavailable. Please retry.');
  }

  Future<String> _callGeminiText(String method, String prompt,
      {String? systemInstruction}) async {
    _logRequest(method, prompt);
    final timer = Stopwatch()..start();

    final fullPrompt = systemInstruction != null
        ? 'SYSTEM INSTRUCTION:\n$systemInstruction\n\nUSER REQUEST:\n$prompt'
        : prompt;

    try {
      final proxyResponse = await http.post(
        Uri.parse(_proxyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': fullPrompt,
          'model': modelName,
          'isJson': false,
        }),
      );

      if (proxyResponse.statusCode == 200) {
        final data = jsonDecode(proxyResponse.body);
        final rawText = data['text'] as String?;
        if (rawText != null && rawText.trim().isNotEmpty) {
          _logResponse(method, 200, timer.elapsedMilliseconds, rawText);
          return rawText.trim();
        }
      } else {
        _logError(method, 'Proxy returned status ${proxyResponse.statusCode}: ${proxyResponse.body}');
        throw Exception('AURA backend proxy error: ${proxyResponse.statusCode}');
      }
    } catch (e) {
      _logError(method, e);
      rethrow;
    }

    throw Exception('AURA AI service temporarily unavailable. Please retry.');
  }

  @override
  Future<AIOrchestratorResult> processCoachMessage(
      String userPrompt, TransformationEngineState contextState,
      {Uint8List? imageBytes, String? mimeType}) async {
    final imageInstructions = imageBytes != null ? '''
MULTIMODAL IMAGE ATTACHED:
The user has attached an image with caption/note: "$userPrompt".
Examine the image carefully:
1. Food Plate / Meal / Snack: Identify all visible ingredients, estimate portion sizes, calories, protein, carbs, and fat, and generate a "logNutrition" action.
2. Nutrition Facts Label: Read calories, protein, carbs, and fat per serving and call "logNutrition".
3. Workout Display / Smartwatch Summary: Extract duration, calories burned, workout type, and call "updateWorkoutStatus" with status="completed".
4. Physique / Progress Photo: Provide encouraging, supportive observations on consistency.
''' : '';

    final prompt = '''
You are the AI Transformation Coach Orchestrator for AURA.
Your job is to analyze the user's message in the context of their profile, workout, nutrition, and recovery, and decide what action(s) to execute, if any, along with an empathetic coach reply.

USER TRANSFORMATION CONTEXT:
${_buildSystemContext(contextState)}

INCOMING USER MESSAGE:
"$userPrompt"

$imageInstructions

AVAILABLE FUNCTIONS / ACTIONS:
1. "updateEquipment": Call when the user mentions having new, limited, or specific workout equipment (e.g. "I only have a 10kg weight bag", "no gym today, only dumbbells", "I have dumbbells and bodyweight", "resistance bands and a pull up bar").
   Parameters:
   - "items": Array of objects [{"name": string (e.g. "10kg Workout Bag", "Dumbbells", "Bodyweight", "Resistance Bands"), "category": "free_weight" | "bodyweight" | "bands" | "cables" | "machine" | "other", "weightKg": number or null, "notes": string or null}]

2. "adaptWorkout": Call when the user wants to adapt/update/modify their workout, requests exercise substitutions, reports aches/pains/injuries, or has equipment constraints that require recalculating the workout exercises and weights.
   Parameters:
   - "reason": String describing why and how to adapt (e.g., "Adjust for 10kg weight bag limit, cap all dumbbell weights at 10kg", or "Lower back pain, replace deadlifts").
   - "maxWeightKg": Optional number if a maximum weight limit is set (e.g. 10.0).

3. "logNutrition": Call when the user explicitly mentions meals, food eaten, or water drunk.
   Parameters:
   - "meals": Array of objects [{"name": string, "calories": number, "proteinG": number, "carbsG": number, "fatG": number}]
   - "waterMl": Optional number of ml of water added.

4. "logRecovery": Call when the user mentions sleep hours/quality, soreness, energy, or stress.
   Parameters:
   - "sleepHours": Optional number
   - "sleepQuality": Optional number (1-10)
   - "muscleSoreness": Optional number (1-10)
   - "energyLevel": Optional number (1-10)
   - "stressLevel": Optional number (1-10)

5. "logWeight": Call ONLY IF the user explicitly stated their current scale weight in this message (e.g. "weighed in at 74.5kg", "current weight is 75kg").
   CRITICAL SAFETY RULE: NEVER extract target weight (e.g. 80kg) or context weight from the background profile as a new logged weight! If the user did not explicitly state a new body weight measurement in their message, DO NOT call logWeight.
   Parameters:
   - "weightKg": number

6. "updateWorkoutStatus": Call when the user explicitly states they finished/completed today's workout or skipped it.
   Parameters:
   - "status": "completed" | "skipped"

7. "updateMasterContext": Call when the user reveals a personal preference, habit, limitation, or fact about themselves that should be remembered for future planning. Examples: "I hate burpees", "I'm lactose intolerant", "I work night shifts", "I prefer morning workouts".
   Parameters:
   - "field": One of ["activityLevel", "preferredTrainingStyle", "cardioPreference", "activeInjuries", "foodAllergies", "dislikedExercises", "preferredProteinSources", "personalNotes", "preferredTrainingDays"]
   - "action": "set" | "append"
   - "value": string or array of strings

8. "regenerateWeeklyPlan": Call when structural profile parameters are changed (e.g., equipment is updated, injuries are logged/updated, or long-term training goals/preferences are modified) indicating that the user's 7-day schedule/weekly plan should be recalculated and rebuilt.
   Parameters: none.

SEQUENCING RULE:
If the user specifies equipment changes and asks to adapt the workout, return ["updateEquipment", "adaptWorkout"] in that order!
If structural changes (equipment, goals, injuries) are made, you should include "regenerateWeeklyPlan" in the actions.
If the user's message is pure conversation, general Q&A, or encouragement without data to log or workouts to change, return "actions": [].

Return JSON:
{
  "actions": [
    {
      "functionName": string,
      "arguments": { ... }
    }
  ],
  "coachResponse": string (2-3 warm, supportive sentences in your coach personality answering the user and confirming any changes made)
}
''';

    final soul = contextState.profile.coachSoul;
    String coachInstruction;
    switch (soul) {
      case CoachSoul.supporter:
        coachInstruction =
            'You are AURA, an empathetic, warm, and gentle personal fitness coach (The Supporter). '
            'Your tone is encouraging, validating, and focused on celebrating small wins and self-compassion. '
            'In "coachResponse", speak warmly and clearly.';
        break;
      case CoachSoul.pro:
        coachInstruction =
            'You are AURA, a direct, no-nonsense, and results-driven personal fitness coach (The Pro). '
            'Your tone is direct, metrics-focused, and highly motivating. '
            'In "coachResponse", be punchy and action-oriented.';
        break;
      case CoachSoul.teacher:
        coachInstruction =
            'You are AURA, an analytical, educational, and scientific personal fitness coach (The Teacher). '
            'Your tone is educational, insightful, and explaining the science behind fitness and nutrition. '
            'In "coachResponse", provide informative, clear explanations.';
        break;
    }

    try {
      final parsed = await _callGeminiJson(
        'processCoachMessage',
        prompt,
        systemInstruction: coachInstruction,
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
      final coachResp = parsed['coachResponse']?.toString() ??
          parsed['response']?.toString() ??
          parsed['message']?.toString() ??
          'I have updated your transformation plan!';
      return AIOrchestratorResult(actions: actions, coachResponse: coachResp);
    } catch (e) {
      _logError('processCoachMessage', e);
      rethrow;
    }
  }

  @override
  Future<String> generateCoachResponse(
      String userPrompt, TransformationEngineState contextState) async {
    final soul = contextState.profile.coachSoul;
    String systemInstruction;
    
    switch (soul) {
      case CoachSoul.supporter:
        systemInstruction = 
            'You are AURA, an empathetic, warm, and gentle personal fitness coach (The Supporter). '
            'Your tone is encouraging, validating, and focused on celebrating small wins and self-compassion. '
            'Always be kind and conversational. Use simple language. Keep answers warm and concise (2-3 sentences max).';
        break;
      case CoachSoul.pro:
        systemInstruction = 
            'You are AURA, a direct, no-nonsense, and results-driven personal fitness coach (The Pro). '
            'Your tone is direct, metrics-focused, action-oriented, and highly motivating. '
            'Cut the fluff, focus on target goals, and call out execution. Keep answers extremely concise (1-2 punchy sentences max).';
        break;
      case CoachSoul.teacher:
        systemInstruction = 
            'You are AURA, an analytical, educational, and scientific personal fitness coach (The Teacher). '
            'Your tone is educational, insightful, and explaining the "why" and "how" behind physiology, recovery, and nutrition. '
            'Be informative but keep it clear and easy to understand. Keep answers concise (2-3 sentences max).';
        break;
    }

    try {
      return await _callGeminiText(
        'generateCoachResponse',
        'User Transformation Context:\n${_buildSystemContext(contextState)}\n\nUser Message: $userPrompt',
        systemInstruction: systemInstruction,
      );
    } catch (e) {
      _logError('generateCoachResponse', e);
      rethrow;
    }
  }

  @override
  Future<QuickLogParsedResult> parseQuickLog(
      String rawText, TransformationEngineState contextState) async {
    final prompt = '''
User Context:
${_buildSystemContext(contextState)}

Analyze this natural language daily fitness log entry: "$rawText"
Scheduled Workout for today: ${contextState.workout.title}

Extract structured data. Return JSON:
{
  "workoutStatus": "completed" | "skipped" | "adapted" | null,
  "workoutReason": string or null,
  "mealsToAdd": [{"name": string, "calories": number, "proteinG": number, "carbsG": number, "fatG": number}],
  "skippedMeals": [string],
  "sleepHours": number or null,
  "weightKg": number or null,
  "energyLevel": number (1-5) or null,
  "coachFeedback": string (1-2 sentences feedback written in your specific personality style)
}
''';

    final soul = contextState.profile.coachSoul;
    String coachInstruction = '';
    switch (soul) {
      case CoachSoul.supporter:
        coachInstruction = 
            'You are AURA, an empathetic, warm, and gentle personal fitness coach (The Supporter). '
            'Your tone is encouraging and focused on self-compassion. '
            'In the "coachFeedback" field, write 1-2 empathetic, warm sentences celebrating progress or supporting a struggle.';
        break;
      case CoachSoul.pro:
        coachInstruction = 
            'You are AURA, a direct, no-nonsense, and results-driven personal fitness coach (The Pro). '
            'Your tone is direct, action-oriented, and metrics-focused. '
            'In the "coachFeedback" field, write 1-2 direct, motivating, and punchy sentences keeping them on track.';
        break;
      case CoachSoul.teacher:
        coachInstruction = 
            'You are AURA, an analytical, educational, and scientific personal fitness coach (The Teacher). '
            'Your tone is analytical, clear, and explanatory. '
            'In the "coachFeedback" field, write 1-2 educational sentences explaining the science/physiology behind their log entry.';
        break;
    }

    try {
      final parsed = await _callGeminiJson('parseQuickLog', prompt, systemInstruction: coachInstruction);
      WorkoutStatus? status;
      if (parsed['workoutStatus'] == 'completed') {
        status = WorkoutStatus.completed;
      }
      if (parsed['workoutStatus'] == 'skipped') {
        status = WorkoutStatus.skipped;
      }
      if (parsed['workoutStatus'] == 'adapted') {
        status = WorkoutStatus.adapted;
      }
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
        skipped =
            (parsed['skippedMeals'] as List).map((e) => e.toString()).toList();
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
  Future<DailyWorkout> adaptWorkoutWithAI(
      String adaptationRequest, TransformationEngineState contextState,
      {List<EquipmentType>? explicitEquipment, double? maxWeightKg}) async {
    final effectiveEquipment = explicitEquipment ?? contextState.profile.availableEquipment;
    final weightConstraint = maxWeightKg != null
        ? 'STRICT CONSTRAINT: The user has a maximum equipment weight limit of ${maxWeightKg}kg (e.g. 10kg weight bag). All prescribed dumbbell/weighted exercises must use <= ${maxWeightKg}kg.'
        : '';

    final prompt = '''
User Request: "$adaptationRequest"
Current Workout: "${contextState.workout.title}" — ${contextState.workout.focusArea}
Current Exercises: ${contextState.workout.exercises.map((e) => e.name).join(', ')}
Available Equipment: ${contextState.profile.equipmentList.map((e) => e.toString()).join(', ')}
Active Safeguards: ${contextState.profile.activeInjuries.isEmpty ? 'None' : contextState.profile.activeInjuries.join(', ')}
$weightConstraint

Adapt the workout accordingly. If equipment is limited (e.g. weight bag, dumbbells), prescribe effective functional and hypertrophy movements tailored to what they have.
Return JSON:
{
  "title": string,
  "adaptationNote": string,
  "exercises": [{"name": string, "targetMuscle": string, "equipmentRequired": string (e.g. "10kg Workout Bag", "Bodyweight", "Dumbbells"), "targetSets": number, "targetReps": number, "targetWeightKg": number, "notes": string}]
}
''';
    try {
      final parsed = await _callGeminiJson('adaptWorkoutWithAI', prompt);
      return _parseWorkoutJson(
          parsed, contextState.workout, contextState.profile,
          overrideEquipment: effectiveEquipment);
    } catch (e) {
      _logError('adaptWorkoutWithAI', e);
      rethrow;
    }
  }

  @override
  Future<String> generateEngineDailyInsight(
      TransformationEngineState contextState) async {
    final totalProt =
        contextState.nutrition.meals.fold(0, (sum, m) => sum + m.proteinG);
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
  "exercises": [{"name": string, "targetMuscle": string, "equipmentRequired": "bodyweight" | "dumbbells" | "barbell" | "cables" | "machines", "targetSets": number, "targetReps": number, "targetWeightKg": number, "notes": string}]
}
''';
    try {
      final parsed = await _callGeminiJson('generateAIInitialWorkout', prompt);
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final title =
          parsed['title']?.toString() ?? '${profile.daysPerWeek}-Day AI Plan';
      final focus = parsed['focusArea']?.toString() ?? 'Full Body';
      final duration = (parsed['estimatedDurationMin'] as num?)?.toInt() ?? 45;
      final note = parsed['adaptationNote']?.toString() ??
          'Tailored for ${profile.name} by AURA AI';
      final exercises = _parseExerciseList(
          parsed['exercises'], focus, profile.availableEquipment, 'ai_init');
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
  Future<String> synthesizeAITodayFocus(
      TransformationEngineState contextState) async {
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
  Future<DailyNutrition> generateAIAdaptedNutrition(
      TransformationEngineState contextState, String reason) async {
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
      final parsed =
          await _callGeminiJson('generateAIAdaptedNutrition', prompt);
      debugPrint(
          '[GEMINI ADAPT NUTRITION] Reason: ${parsed['adaptationReason']}');
      return n.copyWith(
        targetCalories:
            (parsed['targetCalories'] as num?)?.toInt() ?? n.targetCalories,
        targetProteinG:
            (parsed['targetProteinG'] as num?)?.toInt() ?? n.targetProteinG,
        targetCarbsG:
            (parsed['targetCarbsG'] as num?)?.toInt() ?? n.targetCarbsG,
        targetFatG: (parsed['targetFatG'] as num?)?.toInt() ?? n.targetFatG,
        targetWaterMl:
            (parsed['targetWaterMl'] as num?)?.toInt() ?? n.targetWaterMl,
      );
    } catch (e) {
      _logError('generateAIAdaptedNutrition', e);
      rethrow;
    }
  }

  @override
  Future<MealItem> estimateAIMealNutrition(String mealDescription) async {
    final prompt = '''
Analyze the following food/meal description, identify all ingredients and portion sizes, and calculate accurate macronutrients:
Meal: "$mealDescription"

Return strictly valid JSON:
{
  "name": string (concise clean meal title, e.g. "Chicken Burrito Bowl"),
  "calories": number (total kcal),
  "proteinG": number (grams of protein),
  "carbsG": number (grams of carbs),
  "fatG": number (grams of fat),
  "reasoning": string (1-sentence breakdown of portions)
}
''';
    try {
      final parsed = await _callGeminiJson('estimateAIMealNutrition', prompt);
      final cleanName = (parsed['name'] as String?)?.trim().isNotEmpty == true
          ? parsed['name'] as String
          : mealDescription;
      final cal = (parsed['calories'] as num?)?.toInt() ?? 300;
      final prot = (parsed['proteinG'] as num?)?.toInt() ?? 15;
      final carbs = (parsed['carbsG'] as num?)?.toInt() ?? 30;
      final fat = (parsed['fatG'] as num?)?.toInt() ?? 10;

      debugPrint('[GEMINI MEAL ESTIMATION] $cleanName -> ${cal}kcal, P:${prot}g, C:${carbs}g, F:${fat}g');

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
        calories: 320,
        proteinG: 18,
        carbsG: 35,
        fatG: 10,
      );
    }
  }

  @override
  Future<DailyWorkout> generateAIAdaptedWorkout(
      TransformationEngineState contextState, String reason) async {
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
      return _parseWorkoutJson(
          parsed, contextState.workout, contextState.profile);
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
    final p = state.profile;
    final w = state.workout;
    final n = state.nutrition;
    final r = state.recovery;
    final ctx = state.masterContext;
    final totalCal = n.meals.fold(0, (sum, m) => sum + m.calories);
    final totalProt = n.meals.fold(0, (sum, m) => sum + m.proteinG);

    final exercisesStr = w.exercises.isEmpty
        ? 'No exercises prescribed yet.'
        : w.exercises.map((e) {
            final firstSet = e.sets.isNotEmpty ? e.sets.first : null;
            final repsStr = firstSet != null ? '${firstSet.targetReps} reps' : 'N/A';
            final weightStr = firstSet != null ? '${firstSet.targetWeightKg}kg' : 'N/A';
            return '- ${e.name} (${e.targetMuscle} • ${e.equipmentRequired}): ${e.sets.length} sets x $repsStr @ $weightStr. Notes: ${e.notes ?? "none"}';
          }).join('\n');

    final mealsStr = n.meals.isEmpty
        ? 'No meals logged yet today.'
        : n.meals.map((m) => '- ${m.name}: ${m.calories} kcal (P: ${m.proteinG}g, C: ${m.carbsG}g, F: ${m.fatG}g)').join('\n');

    final equipDescriptions = p.equipmentList.isEmpty
        ? '• Bodyweight'
        : p.equipmentList.map((e) {
            final w = e.weightKg != null ? ' (${e.weightKg}kg)' : '';
            final notes = e.notes != null ? ' - ${e.notes}' : '';
            return '• ${e.name}$w$notes';
          }).join('\n');

    final injuryList = p.activeInjuries.isNotEmpty
        ? p.activeInjuries
        : ctx.deduced.activeInjuries;
    final injuryStr = injuryList.isEmpty
        ? 'None reported.'
        : injuryList.map((i) => '• $i').join('\n');

    final allNotes = [
      ...p.dislikedExercises.map((d) => 'Dislikes: $d'),
      ...ctx.deduced.dislikedExercises.map((d) => 'Dislikes: $d'),
      ...p.personalNotes,
      ...ctx.deduced.personalNotes,
    ].toSet().toList();
    final notesStr = allNotes.isEmpty ? 'No additional notes recorded yet.' : allNotes.map((n) => '• $n').join('\n');

    return '''
[CANONICAL USER PROFILE & STATE]
Name: ${p.name} | Gender: ${p.gender} | Age: ${p.age} | Weight: ${p.weightKg}kg → ${p.targetWeightKg}kg
Goal: ${p.goal.name} (${p.targetPhysique})
Experience Level: ${p.experienceLevel.name}
Dietary Preference: ${p.dietaryPreference}
Coach Personality/Soul: ${p.coachSoul.name}

[CANONICAL AVAILABLE EQUIPMENT & GEAR]
$equipDescriptions

[KNOWN INJURIES & MOBILITY LIMITS]
$injuryStr

[PERSONAL PREFERENCES & NOTES]
$notesStr

[CURRENT WORKOUT PLAN FOR TODAY]
Title: ${w.title}
Status: ${w.status.name}
Focus Area: ${w.focusArea}
Adaptation Note: ${w.adaptationNote ?? 'None'}
Prescribed Exercises:
$exercisesStr

[CURRENT NUTRITION STATUS]
Target: ${n.targetCalories} kcal | Protein: ${n.targetProteinG}g | Carbs: ${n.targetCarbsG}g | Fat: ${n.targetFatG}g
Logged Today: $totalCal / ${n.targetCalories} kcal | Protein: $totalProt / ${n.targetProteinG}g | Water: ${n.waterMl} / ${n.targetWaterMl} ml
Logged Meals:
$mealsStr

[CURRENT RECOVERY STATUS]
Recovery Score: ${r.recoveryScore}%
Status Label: ${r.status}
Sleep: ${r.sleepHours} hrs (Quality: ${r.sleepQuality}/10)
Muscle Soreness: ${r.muscleSoreness}/10
Energy Level: ${r.energyLevel}/10
Stress Level: ${r.stressLevel}/10

[AURA SYSTEM NOTICES]
Recent AI Adaptation Notice: ${state.adaptationNotice ?? 'None'}
''';
  }

  @override
  Future<WeeklyPlan> generateAIWeeklyPlan(
      TransformationEngineState contextState) async {
    final p = contextState.profile;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekNumber = ((monday.difference(DateTime(monday.year, 1, 1)).inDays) / 7).ceil() + 1;
    final weekId = '${monday.year}-W${weekNumber.toString().padLeft(2, '0')}';

    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dates = List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return d.toIso8601String().split('T')[0];
    });

    final ctx = contextState.masterContext;
    final allNotes = [
      ...p.dislikedExercises.map((d) => 'AVOID: $d'),
      ...ctx.deduced.dislikedExercises.map((d) => 'AVOID: $d'),
      ...p.personalNotes,
      ...ctx.deduced.personalNotes,
    ].toSet().toList();
    final deducedNotes = allNotes.isNotEmpty
        ? 'User preferences & constraints: ${allNotes.join("; ")}'
        : 'No additional notes.';
    final injuryList = p.activeInjuries.isNotEmpty ? p.activeInjuries : ctx.deduced.activeInjuries;
    final injuryStr = injuryList.isNotEmpty
        ? 'INJURIES to work around: ${injuryList.join(", ")}'
        : '';

    final prompt = '''
Generate a 7-day workout and nutrition plan for this user:

Name: ${p.name} | Age: ${p.age} | Gender: ${p.gender}
Weight: ${p.weightKg}kg → ${p.targetWeightKg}kg | Height: ${p.heightCm}cm
Goal: ${p.goal.name} | Target Physique: ${p.targetPhysique}
Training Days/Week: ${p.daysPerWeek}
Equipment: ${p.equipmentList.map((e) => e.toString()).join(', ')}
Experience: ${p.experienceLevel.name}
Dietary Preference: ${p.dietaryPreference}
$deducedNotes
$injuryStr

Week: $weekId (${dates.first} to ${dates.last})
Days: ${dayNames.join(', ')}
Dates: ${dates.join(', ')}

Rules:
- CRITICAL: ONLY prescribe exercises executable with the user's available equipment: ${p.equipmentList.isEmpty ? 'Bodyweight only' : p.equipmentList.map((e) => e.name).join(', ')}. NEVER prescribe gym machines, cables, or barbells if the user only has dumbbells or bodyweight!
- Exactly ${p.daysPerWeek} training days and ${7 - p.daysPerWeek} rest/active recovery days
- Rest days should be strategically placed (not all bunched together)
- Each training day should have a clear focus (e.g., Upper Push, Lower Pull, Full Body)
- List 4-6 exercise names per training day matching the user's exact equipment constraints
- Today is ${dayNames[DateTime.now().weekday - 1]} (${dates[DateTime.now().weekday - 1]}): align today's title/focus with the active session
- Include a nutritionFocus per day (e.g., "High protein, moderate carbs" or "Calorie surplus, extra carbs post-workout")
- The overview should be 1-2 sentences summarizing the week's strategy

Return JSON:
{
  "overview": "string",
  "coachNote": "string or null",
  "days": [
    {
      "dayName": "Monday",
      "date": "${dates[0]}",
      "title": "string",
      "focusArea": "string",
      "isRestDay": false,
      "exerciseNames": ["Exercise 1", "Exercise 2", ...],
      "nutritionFocus": "string"
    },
    ... (7 total)
  ]
}
''';

    final parsed = await _callGeminiJson('generateAIWeeklyPlan', prompt);

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
  }
}
