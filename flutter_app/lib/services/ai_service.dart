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

  String get _proxyUrl {
    const customProxy = String.fromEnvironment('AI_PROXY_URL');
    if (customProxy.trim().isNotEmpty) {
      return customProxy.trim();
    }
    return 'https://us-central1-aura-coach-ashu-7.cloudfunctions.net/callGeminiProxy';
  }

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
      if (imageBytes != null) {
        body['imageBase64'] = base64Encode(imageBytes);
        body['mimeType'] = mimeType ?? 'image/jpeg';
      }

      final response = await http.post(
        Uri.parse(_processAiCommandUrl),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

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

      final headers = await _getAuthHeaders();
      final proxyResponse = await http.post(
        Uri.parse(_proxyUrl),
        headers: headers,
        body: jsonEncode(proxyPayload),
      ).timeout(const Duration(seconds: 30));

      if (proxyResponse.statusCode == 200) {
        final data = jsonDecode(proxyResponse.body);
        final rawText = data['text'] as String?;
        if (rawText != null && rawText.trim().isNotEmpty) {
          _logResponse(method, 200, timer.elapsedMilliseconds, rawText);
          final cleanJson = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
          return jsonDecode(cleanJson) as Map<String, dynamic>;
        }
        throw Exception('Empty response from AI proxy.');
      } else {
        _logError(method, 'Proxy returned status ${proxyResponse.statusCode}: ${proxyResponse.body}');
        throw Exception('AURA backend proxy error: ${proxyResponse.statusCode}');
      }
    } catch (e) {
      _logError(method, e);
      rethrow;
    }
  }

  Future<String> _callGeminiText(String method, String prompt,
      {String? systemInstruction}) async {
    _logRequest(method, prompt);
    final timer = Stopwatch()..start();

    final fullPrompt = systemInstruction != null
        ? 'SYSTEM INSTRUCTION:\n$systemInstruction\n\nUSER REQUEST:\n$prompt'
        : prompt;

    try {
      final headers = await _getAuthHeaders();
      final proxyResponse = await http.post(
        Uri.parse(_proxyUrl),
        headers: headers,
        body: jsonEncode({
          'prompt': fullPrompt,
          'model': modelName,
          'isJson': false,
        }),
      ).timeout(const Duration(seconds: 30));

      if (proxyResponse.statusCode == 200) {
        final data = jsonDecode(proxyResponse.body);
        final rawText = data['text'] as String?;
        if (rawText != null && rawText.trim().isNotEmpty) {
          _logResponse(method, 200, timer.elapsedMilliseconds, rawText);
          return rawText.trim();
        }
        throw Exception('Empty text response from AI proxy.');
      } else {
        _logError(method, 'Proxy returned status ${proxyResponse.statusCode}: ${proxyResponse.body}');
        throw Exception('AURA backend proxy error: ${proxyResponse.statusCode}');
      }
    } catch (e) {
      _logError(method, e);
      rethrow;
    }
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

    final soul = contextState.profile.coachSoul;
    String soulName;
    String coachInstruction;
    switch (soul) {
      case CoachSoul.supporter:
        soulName = 'The Supporter';
        coachInstruction =
            'You are AURA (The Supporter), an empathetic, warm, and gentle personal fitness coach and elite trainer. '
            'Your tone is encouraging, validating, and focused on celebrating small wins and self-compassion. '
            'In "coachResponse", speak warmly, authentically, and conversationally directly to your client.';
        break;
      case CoachSoul.pro:
        soulName = 'The Pro';
        coachInstruction =
            'You are AURA (The Pro), a direct, no-nonsense, and results-driven personal fitness coach and elite trainer. '
            'Your tone is direct, metrics-focused, action-oriented, and highly motivating. '
            'In "coachResponse", be punchy, clear, and action-oriented directly to your client.';
        break;
      case CoachSoul.teacher:
        soulName = 'The Teacher';
        coachInstruction =
            'You are AURA (The Teacher), an analytical, educational, and scientific personal fitness coach and elite trainer. '
            'Your tone is educational, insightful, and explaining the science behind fitness, recovery, and nutrition. '
            'In "coachResponse", provide informative, clear explanations directly to your client.';
        break;
    }

    final prompt = '''
You are $soulName, an elite personal trainer and health coach for AURA. Your client is talking to you. Speak directly to them, matching their energy. Be conversational, empathetic, and human.

You also possess a silent superpower: you can update their fitness app's database. After you decide how to respond to the client, silently append the necessary system actions to keep their dashboard up to date.

CLIENT WORKING MEMORY & CONTEXT:
${_buildSystemContext(contextState)}

INCOMING USER MESSAGE:
"$userPrompt"

$imageInstructions

AVAILABLE SYSTEM ACTIONS (Silently append when necessary to update the user's dashboard):
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
   - "targetDate": Optional string ("YYYY-MM-DD", "yesterday", or "today"). If the user says "Yesterday I ate...", "For yesterday log...", set targetDate to "yesterday" or the target ISO date string. Defaults to today if unstated.

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

9. "removeMeal": Call when the user explicitly asks to remove, delete, or drop a specific meal item from a day's food log (e.g., "remove the halwa", "delete the protein shake from yesterday").
   Parameters:
   - "mealName": string (e.g. "halwa", "paneer gravy", "protein shake")
   - "targetDate": Optional string ("YYYY-MM-DD", "yesterday", or "today")

10. "updateMealPortion": Call when the user requests a portion adjustment or macro edit for a specific logged meal item (e.g. "adjust halwa to 50g", "change protein shake to 30g protein").
    Parameters:
    - "mealName": string
    - "calories": number
    - "proteinG": number
    - "carbsG": number
    - "fatG": number
    - "targetDate": Optional string ("YYYY-MM-DD", "yesterday", or "today")

NATURAL RECOVERY & READINESS DIRECTIVE:
1. Do NOT read, track, or cite background recovery scores, sleep logs, or soreness numbers unless the client brings them up.
2. Assume the client is in normal, healthy operating condition unless they explicitly state otherwise in chat.
3. If the client mentions feeling sore, tired, stressed, or injured, respond empathetically, ask how their body is feeling, and adapt their plan accordingly.
4. Speak naturally about energy, form, safety, and progressive overload without quoting background metric formulas or percentage figures.

CRITICAL INSTRUCTION: Return a single JSON object. You MUST write your "coachResponse" FIRST, before listing any "actions":
{
  "coachResponse": "Write your natural, empathetic response directly to the user here. Use the tone of $soulName. Do not use robotic language.",
  "actions": [
    {
      "functionName": string,
      "arguments": { ... }
    }
  ]
}
''';

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
        contextState.nutrition.meals.fold<num>(0, (sum, m) => sum + m.proteinG);
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
Recovery Status: ${contextState.recovery.status}
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
    final allNotes = <dynamic>{
      ...p.dislikedExercises.map((d) => 'AVOID: $d'),
      ...ctx.deduced.dislikedExercises.map((d) => 'AVOID: $d'),
      ...p.personalNotes,
      ...ctx.deduced.personalNotes,
    }.toList();
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

    try {
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
    } catch (e) {
      _logError('generateAIWeeklyPlan (Using Fallback Baseline Plan)', e);
      // Fallback deterministic plan matching user's training frequency & equipment
      final List<WeeklyDayPlan> fallbackDays = [];
      final trainingDayIndices = p.daysPerWeek == 4 ? [0, 1, 3, 4] : [0, 2, 4]; // Mon/Tue/Thu/Fri or Mon/Wed/Fri
      for (int i = 0; i < 7; i++) {
        final isTraining = trainingDayIndices.contains(i);
        fallbackDays.add(WeeklyDayPlan(
          dayName: dayNames[i],
          date: dates[i],
          title: isTraining ? 'Bodyweight Hypertrophy & Core' : 'Rest & Recovery',
          focusArea: isTraining ? (i % 2 == 0 ? 'Upper Body Push' : 'Lower Body & Core') : 'Active Recovery',
          isRestDay: !isTraining,
          exerciseNames: isTraining
              ? ['Push-ups', 'Bodyweight Squats', 'Plank Hold', 'Glute Bridges', 'Lunges']
              : [],
          nutritionFocus: isTraining
              ? 'Target protein baseline (${contextState.nutrition.targetProteinG}g) with workout hydration'
              : 'Maintenance calories with light recovery focus',
        ));
      }
      return WeeklyPlan(
        weekId: weekId,
        startDate: dates.first,
        endDate: dates.last,
        overview: 'Adaptive 7-day body transformation baseline customized for ${p.name}.',
        coachNote: 'Plan generated using baseline adaptive rules.',
        days: fallbackDays,
        createdAt: DateTime.now().toIso8601String(),
      );
    }
  }

  @override
  Future<DailyWorkout> parseWorkoutFromNaturalText(
      String naturalText, TransformationEngineState contextState,
      {String? targetDate}) async {
    final dateStr = targetDate ?? DateTime.now().toIso8601String().split('T')[0];
    final soul = contextState.profile.coachSoul;

    final prompt = '''
You are AURA AI Coach. The user typed what they did for their workout in natural language:
"$naturalText"

Current User Profile:
- Goal: ${contextState.profile.goal.name}
- Coach Tone: ${soul.displayName}

Your task:
Extract the workout into a structured DailyWorkout format.
For each exercise mentioned, identify:
- name: standard exercise name (e.g. "Barbell Bench Press", "Dumbbell Lateral Raise", "Pull-ups", "Treadmill Run")
- targetMuscle: (e.g. "Chest", "Shoulders", "Back", "Legs", "Full Body", "Cardio")
- equipmentRequired: (e.g. "barbell", "dumbbell", "bodyweight", "cables", "machine", "cardio")
- sets: Array of completed sets. Each set must have:
  - setNumber (1, 2, 3...)
  - targetReps (integer reps, or estimated)
  - targetWeightKg (weight used in kg, 0.0 if bodyweight or cardio)
  - completed: true
- notes: brief notes if relevant

Return strictly a JSON object matching this schema:
{
  "title": "Extracted Workout Title (e.g. Upper Body Push Session)",
  "focusArea": "Focus (e.g. Chest & Shoulders)",
  "estimatedDurationMin": 45,
  "status": "completed",
  "adaptationNote": "Logged via free-text AI",
  "exercises": [
    {
      "id": "ex_1",
      "name": "Barbell Bench Press",
      "targetMuscle": "Chest",
      "equipmentRequired": "barbell",
      "sets": [
        {"setNumber": 1, "targetReps": 10, "targetWeightKg": 60.0, "completed": true},
        {"setNumber": 2, "targetReps": 10, "targetWeightKg": 60.0, "completed": true},
        {"setNumber": 3, "targetReps": 8, "targetWeightKg": 65.0, "completed": true}
      ],
      "notes": ""
    }
  ]
}
''';

    try {
      final json = await _callGeminiJson('parseWorkoutFromNaturalText', prompt);
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
        focusArea: "Custom Workout",
        estimatedDurationMin: 45,
        status: WorkoutStatus.completed,
        exercises: [
          Exercise(
            id: 'ex_custom_1',
            name: naturalText.length > 30 ? naturalText.substring(0, 30) : naturalText,
            targetMuscle: "Full Body",
            equipmentRequired: "bodyweight",
            sets: [
              ExerciseSet(setNumber: 1, targetReps: 10, targetWeightKg: 0.0, completed: true),
              ExerciseSet(setNumber: 2, targetReps: 10, targetWeightKg: 0.0, completed: true),
              ExerciseSet(setNumber: 3, targetReps: 10, targetWeightKg: 0.0, completed: true),
            ],
            notes: naturalText,
          )
        ],
        adaptationNote: naturalText,
      );
    }
  }

  @override
  Future<WeeklyDebrief> generateWeeklyDebrief(
      TransformationEngineState contextState) async {
    try {
      final statePayload = _buildStatePayload(contextState);
      final json = await _callProcessAiCommand(
        command: 'generateWeeklyDebrief',
        statePayload: statePayload,
      );
      return WeeklyDebrief.fromJson(json);
    } catch (e) {
      debugPrint('[AURA AI] processAiCommand generateWeeklyDebrief fallback: $e');
      final prompt = '''
Analyze this user's weekly trajectory and synthesize an authentic Narrative Weekly Debrief:
Context:
${_buildSystemContext(contextState)}

Connect the dots between different domains:
1. Explain how sleep/recovery impacted workout load and strength.
2. Evaluate protein and calorie adherence relative to training load.
3. Provide 1 actionable focus point for next week.
Return strictly JSON:
{
  "headline": string,
  "narrative": string (3 paragraphs),
  "keyAchievement": string,
  "primaryNextStep": string,
  "adherenceScore": number (0-100)
}
''';
      try {
        final json = await _callGeminiJson('generateWeeklyDebrief', prompt);
        return WeeklyDebrief.fromJson(json);
      } catch (err) {
        final soul = contextState.profile.coachSoul;
        String fallbackNarrative;
        switch (soul) {
          case CoachSoul.supporter:
            fallbackNarrative = "You made meaningful strides this week! Even when life got busy, you showed up for your body. Next week, let's focus on prioritizing restful sleep so you feel energized every morning.";
            break;
          case CoachSoul.pro:
            fallbackNarrative = "Solid baseline execution across the board. Your training compliance is moving in the right direction. To accelerate results next week, lock in your daily protein numbers immediately post-workout.";
            break;
          case CoachSoul.teacher:
            fallbackNarrative = "Neuromuscular adaptation requires balanced recovery cycles. Your training stimulus created productive adaptations, and focusing on sleep consistency next week will optimize protein synthesis and muscle recovery.";
            break;
        }
        return WeeklyDebrief(
          headline: 'Weekly Synthesis & Next Steps',
          narrative: fallbackNarrative,
          keyAchievement: 'Consistent weekly routine engagement',
          primaryNextStep: 'Lock in 8 hours of sleep and daily protein target',
          adherenceScore: 82,
        );
      }
    }
  }

  @override
  Future<LifestyleIntakeResult> parseLifestyleIntake(
    String text,
    UserProfile currentProfile, {
    List<Map<String, String>>? conversationHistory,
  }) async {
    final existingEquipment = currentProfile.equipmentList.map((e) => e.name).toList();
    final existingDays = currentProfile.daysPerWeek;

    try {
      final json = await _callProcessAiCommand(
        command: 'parseLifestyleIntake',
        message: text,
      );
      return LifestyleIntakeResult.fromJson(json);
    } catch (e) {
      debugPrint('[AURA AI] processAiCommand parseLifestyleIntake fallback: $e');
      
      final historyStr = (conversationHistory != null && conversationHistory.isNotEmpty)
          ? conversationHistory
              .map((m) => '${m['sender'] == 'user' ? 'User' : 'AURA'}: ${m['text']}')
              .join('\n')
          : 'User: $text';

      final prompt = '''
The user is having an interactive onboarding interview with AURA (the personal wellness coach).
Current Calibrated State:
- Days per Week: $existingDays
- Available Equipment: ${existingEquipment.join(', ')}
- Primary Goal: ${currentProfile.goal.name}
- Target Physique: ${currentProfile.targetPhysique}
- Dietary Preference: ${currentProfile.dietaryPreference}

Full Conversation Transcript so far:
$historyStr

User's Latest Message: "$text"

Instructions:
1. CONVERSATION CONTINUITY & MEMORY:
   - Preserve previously established variables (e.g. if the user previously said "3 days" or "full gym", DO NOT reset or forget them unless the user explicitly updates them).
   - If the user responds with physique goals (e.g. "Diwali", "bigger arms", "V shape", "lean"), acknowledge them warmly and incorporate into targetPhysique and followUpQuestion.
2. COMPLETION CRITERIA:
   - Intake is complete (isComplete: true) ONLY when both training frequency (daysPerWeek: 2-6) and available equipment are firmly known.
   - If both are known, confirm with an enthusiastic summary and tell them they are ready to choose their coach persona.
   - If something is still missing, ask for the missing item in followUpQuestion.
3. DYNAMIC QUICK REPLIES:
   - Generate 2 to 3 concise, relevant suggestion pills (dynamicQuickReplies) that directly answer or relate to what you asked in followUpQuestion.
   - For example:
     * If asking about schedule: ["3 days a week", "4 days a week", "5 days a week"]
     * If asking about equipment: ["Full commercial gym", "Dumbbells & bench at home", "Bodyweight only"]
     * If complete: ["Ready to pick my coach!", "I also want to focus on core", "I prefer 30-min workouts"]

Return strictly JSON:
{
  "isComplete": boolean,
  "daysPerWeek": number,
  "equipment": ["string"],
  "targetPhysique": string or null,
  "missingFields": ["string"],
  "followUpQuestion": "string",
  "dynamicQuickReplies": ["string"]
}
''';
      try {
        final json = await _callGeminiJson('parseLifestyleIntake', prompt);
        final result = LifestyleIntakeResult.fromJson(json);
        // Merge with existing state if model omitted them
        final finalDays = (result.daysPerWeek > 0) ? result.daysPerWeek : existingDays;
        final finalEq = (result.equipment.isNotEmpty) ? result.equipment : existingEquipment;
        final isReallyComplete = finalDays >= 2 && finalEq.isNotEmpty && result.isComplete;
        
        return LifestyleIntakeResult(
          isComplete: isReallyComplete,
          daysPerWeek: finalDays,
          equipment: finalEq,
          missingFields: result.missingFields,
          followUpQuestion: result.followUpQuestion,
          dynamicQuickReplies: result.dynamicQuickReplies.isNotEmpty
              ? result.dynamicQuickReplies
              : (isReallyComplete
                  ? ["Ready to pick my coach!", "I also want to focus on arms", "I prefer 45-min sessions"]
                  : ["3 days, full gym", "4 days, dumbbells at home", "5 days, bodyweight"]),
          targetPhysique: result.targetPhysique ?? currentProfile.targetPhysique,
        );
      } catch (err) {
        final lower = text.toLowerCase();
        int days = existingDays;
        if (lower.contains('2 day') || lower.contains('twice')) days = 2;
        if (lower.contains('3 day') || lower.contains('thrice')) days = 3;
        if (lower.contains('4 day')) days = 4;
        if (lower.contains('5 day')) days = 5;
        if (lower.contains('6 day')) days = 6;

        final List<String> eq = List<String>.from(existingEquipment);
        if (lower.contains('dumbbell') || lower.contains('weights')) {
          if (!eq.contains('Dumbbells')) eq.add('Dumbbells');
        }
        if (lower.contains('band')) {
          if (!eq.contains('Resistance Bands')) eq.add('Resistance Bands');
        }
        if (lower.contains('gym') || lower.contains('commercial')) {
          eq.clear();
          eq.addAll(['Barbell', 'Dumbbells', 'Cable Machine', 'Weight Machines', 'Bodyweight']);
        }

        if (eq.isEmpty) {
          eq.addAll(['Bodyweight', 'Dumbbells']);
        }

        final isComplete = days >= 2 && eq.isNotEmpty;
        return LifestyleIntakeResult(
          isComplete: isComplete,
          daysPerWeek: days,
          equipment: eq,
          missingFields: isComplete ? [] : ['daysPerWeek'],
          followUpQuestion: isComplete
              ? "Awesome! Calibrated to $days days/week with ${eq.take(3).join(', ')}. Ready to choose your coach persona?"
              : "Got it! How many days per week would you like to train?",
          dynamicQuickReplies: isComplete
              ? ["Ready to choose my coach!", "I also want bigger arms", "I prefer morning workouts"]
              : ["3 days a week", "4 days a week", "5 days a week"],
          targetPhysique: lower.contains('v shape') || lower.contains('arms')
              ? 'V-Shape Physique & Bigger Arms'
              : currentProfile.targetPhysique,
        );
      }
    }
  }
}
