import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/models.dart';
import '../providers/transformation_state.dart';
import '../providers/analytics_provider.dart';
import '../services/analytics_service.dart';
import '../services/firebase_service.dart';
import '../theme/theme.dart';
import 'widgets/aura_orb.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0;
  // 0: Spark (Welcome)
  // 1: Step A: Hard Constants (Identity, Body, Goal, Diet)
  // 2: Step B: State-Driven Interview (AI Chat with Orb: Schedule & Equipment)
  // 3: Coach Soul Selection (Supporter, Pro, Teacher)
  // 4: Plan Summary & Auth Gate
  // 5: Calibration Loading

  // User Parameters
  String _name = 'Athlete';
  int _age = 26;
  String _gender = 'male'; // 'male', 'female', 'other'
  double _heightCm = 175;
  double _weightKg = 75;

  GoalType _selectedGoal = GoalType.recomp;
  int _daysPerWeek = 4;
  String _dietaryPreference = 'nonVeg'; // 'nonVeg', 'vegetarian', 'vegan', 'eggetarian'

  // Equipment setup
  List<EquipmentItem> _interviewEquipmentList = [
    const EquipmentItem(name: 'Bodyweight', category: 'bodyweight'),
    const EquipmentItem(name: 'Dumbbells', category: 'free_weight'),
    const EquipmentItem(name: 'Resistance Bands', category: 'bands'),
  ];

  // AI Interview State
  final List<Map<String, String>> _interviewMessages = [
    {
      'sender': 'ai',
      'text': "Welcome! Let's dial in your routine. Tell me about your weekly schedule and what workout equipment you have access to.",
    }
  ];
  late TextEditingController _interviewInputController;
  bool _isInterviewThinking = false;
  bool _isLifestyleIntakeComplete = false;
  List<String> _dynamicQuickReplies = [
    '3 days, full commercial gym',
    '4 days, dumbbells & bands at home',
    '5 days, bodyweight & park',
  ];

  // Coach Soul
  CoachSoul _selectedSoul = CoachSoul.supporter;

  // Calibration State
  int _calibrationProgressStep = 1;
  String? _calibrationError;

  // Form Controllers
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '');
    _ageController = TextEditingController(text: _age.toString());
    _heightController = TextEditingController(text: _heightCm.round().toString());
    _weightController = TextEditingController(text: _weightKg.round().toString());
    _interviewInputController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logEvent(
        AuraAnalyticsEvents.onboardingStarted,
        properties: {
          'platform': kIsWeb ? 'flutter_pwa' : 'mobile',
        },
      );
    });
  }

  void _goToStep(int nextStep) {
    const stepNames = [
      'welcome',
      'hard_constants',
      'lifestyle_interview',
      'coach_soul',
      'plan_summary',
      'calibration_loading',
    ];
    final currentName = _currentStep < stepNames.length ? stepNames[_currentStep] : 'step_$_currentStep';
    ref.read(analyticsServiceProvider).logEvent(
      AuraAnalyticsEvents.onboardingStepCompleted,
      properties: {
        'step_index': _currentStep,
        'step_name': currentName,
        'next_step_index': nextStep,
      },
    );
    setState(() {
      _currentStep = nextStep;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _interviewInputController.dispose();
    super.dispose();
  }

  List<EquipmentItem> _buildFinalEquipmentList() {
    if (_interviewEquipmentList.isNotEmpty) {
      return _interviewEquipmentList;
    }
    return [
      const EquipmentItem(name: 'Bodyweight', category: 'bodyweight'),
      const EquipmentItem(name: 'Dumbbells', category: 'free_weight'),
    ];
  }

  void _sendInterviewMessage(String text) async {
    if (text.trim().isEmpty || _isInterviewThinking) return;
    final userText = text.trim();
    _interviewInputController.clear();
    setState(() {
      _interviewMessages.add({'sender': 'user', 'text': userText});
      _isInterviewThinking = true;
    });

    final currentProfile = UserProfile(
      name: _name.trim().isNotEmpty ? _name.trim() : 'Athlete',
      age: _age,
      gender: _gender,
      heightCm: _heightCm,
      weightKg: _weightKg,
      targetWeightKg: _getTargetWeight(),
      goal: _selectedGoal,
      daysPerWeek: _daysPerWeek,
      targetPhysique: _getTargetPhysique(),
      equipmentList: _interviewEquipmentList,
      experienceLevel: ExperienceLevel.beginner,
      coachSoul: _selectedSoul,
      dietaryPreference: _dietaryPreference,
    );

    try {
      final res = await ref.read(transformationEngineProvider.notifier).aiService.parseLifestyleIntake(
        userText,
        currentProfile,
        conversationHistory: _interviewMessages,
      );
      final List<EquipmentItem> parsedEq = res.equipment.map((e) => EquipmentItem.fromString(e)).toList();
      if (parsedEq.isEmpty) {
        parsedEq.add(const EquipmentItem(name: 'Bodyweight', category: 'bodyweight'));
      }

      setState(() {
        _daysPerWeek = res.daysPerWeek;
        _interviewEquipmentList = parsedEq;
        _isLifestyleIntakeComplete = res.isComplete && res.daysPerWeek >= 2 && parsedEq.isNotEmpty;
        if (res.dynamicQuickReplies.isNotEmpty) {
          _dynamicQuickReplies = res.dynamicQuickReplies;
        }
        _isInterviewThinking = false;
        _interviewMessages.add({
          'sender': 'ai',
          'text': res.followUpQuestion,
        });
      });
    } catch (e) {
      final isComplete = _daysPerWeek >= 2 && _interviewEquipmentList.isNotEmpty;
      setState(() {
        _isInterviewThinking = false;
        _isLifestyleIntakeComplete = isComplete;
        if (isComplete) {
          _dynamicQuickReplies = [
            "Ready to select my coach!",
            "I also want to focus on upper body",
            "I prefer 45-minute sessions",
          ];
        }
        _interviewMessages.add({
          'sender': 'ai',
          'text': "Got it! Calibrated to $_daysPerWeek days per week with your available gear. Ready to choose your coach persona?",
        });
      });
    }
  }

  String _getTargetPhysique() {
    switch (_selectedGoal) {
      case GoalType.fatLoss:
        return 'Lean & Toned';
      case GoalType.muscleGain:
        return 'Muscular V-Taper';
      case GoalType.recomp:
        return 'Athletic & Strong';
    }
  }

  double _getTargetWeight() {
    switch (_selectedGoal) {
      case GoalType.fatLoss:
        return (_weightKg - 5).clamp(30.0, 300.0);
      case GoalType.muscleGain:
        return (_weightKg + 4).clamp(30.0, 300.0);
      case GoalType.recomp:
        return _weightKg;
    }
  }

  void _runCalibrationAndComplete({bool useGoogleAuth = false, String? email, String? password}) async {
    setState(() {
      _currentStep = 5; // Calibration step
      _calibrationProgressStep = 1;
      _calibrationError = null;
    });

    final userName = _name.trim().isNotEmpty ? _name.trim() : 'Athlete';
    final equipList = _buildFinalEquipmentList();

    final profile = UserProfile(
      name: userName,
      age: _age,
      gender: _gender,
      heightCm: _heightCm,
      weightKg: _weightKg,
      targetWeightKg: _getTargetWeight(),
      goal: _selectedGoal,
      daysPerWeek: _daysPerWeek,
      targetPhysique: _getTargetPhysique(),
      equipmentList: equipList,
      experienceLevel: ExperienceLevel.beginner,
      coachSoul: _selectedSoul,
      dietaryPreference: _dietaryPreference,
    );

    try {
      final notifier = ref.read(transformationEngineProvider.notifier);
      final aiService = notifier.aiService;

      // Step 1: Firebase Auth & Firestore write
      final auth = FirebaseAuthService();
      final firestore = FirebaseFirestoreService();

      UserCredential? cred;
      if (useGoogleAuth) {
        cred = await auth.signInWithGoogle();
      } else if (email != null && email.isNotEmpty && password != null && password.isNotEmpty) {
        cred = await auth.signUpWithEmailAndPassword(email, password);
      } else {
        cred = await auth.signInAnonymously();
      }

      final uid = cred?.user?.uid ?? auth.uid ?? 'firebase_user_${DateTime.now().millisecondsSinceEpoch}';
      final effectiveName = (cred?.user?.displayName != null && cred!.user!.displayName!.trim().isNotEmpty)
          ? cred.user!.displayName!.trim()
          : userName;

      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final finalProfile = profile.copyWith(name: effectiveName, createdAtDateStr: todayStr);

      if (uid.isNotEmpty) {
        await firestore.saveUserProfile(uid, finalProfile);
      }

      // Step 2: Metabolic Plan
      if (mounted) setState(() => _calibrationProgressStep = 2);
      DailyNutrition nutrition;
      try {
        nutrition = await aiService.generateAIMetabolicPlan(finalProfile);
      } catch (e) {
        debugPrint('[AURA ONBOARDING] AI nutrition fallback triggered: $e');
        final todayStr = DateTime.now().toIso8601String().split('T')[0];
        nutrition = DailyNutrition(
          date: todayStr,
          targetCalories: finalProfile.goal == GoalType.fatLoss ? 1900 : 2300,
          targetProteinG: (finalProfile.weightKg * 1.8).round(),
          targetCarbsG: 220,
          targetFatG: 65,
          targetWaterMl: 3000,
          waterMl: 0,
          meals: [],
        );
      }

      // Step 3: Workout Plan
      if (mounted) setState(() => _calibrationProgressStep = 3);
      DailyWorkout workout;
      try {
        workout = await aiService.generateAIInitialWorkout(finalProfile);
      } catch (e) {
        debugPrint('[AURA ONBOARDING] AI workout fallback triggered: $e');
        final todayStr = DateTime.now().toIso8601String().split('T')[0];
        workout = DailyWorkout(
          id: 'workout_$todayStr',
          date: todayStr,
          title: 'Full Body Calibration',
          focusArea: 'Full Body',
          estimatedDurationMin: 45,
          status: WorkoutStatus.scheduled,
          adaptationNote: 'Calibrated for ${finalProfile.name}',
          exercises: [
            Exercise(
              id: 'init_1',
              name: 'Push-Ups',
              targetMuscle: 'Chest & Triceps',
              equipmentRequired: 'Bodyweight',
              sets: [
                ExerciseSet(setNumber: 1, targetReps: 12, targetWeightKg: 0),
                ExerciseSet(setNumber: 2, targetReps: 12, targetWeightKg: 0),
                ExerciseSet(setNumber: 3, targetReps: 10, targetWeightKg: 0),
              ],
            ),
            Exercise(
              id: 'init_2',
              name: 'Goblet Squats',
              targetMuscle: 'Quadriceps & Glutes',
              equipmentRequired: finalProfile.equipmentList.first.name,
              sets: [
                ExerciseSet(setNumber: 1, targetReps: 12, targetWeightKg: 10),
                ExerciseSet(setNumber: 2, targetReps: 12, targetWeightKg: 10),
                ExerciseSet(setNumber: 3, targetReps: 12, targetWeightKg: 10),
              ],
            ),
            Exercise(
              id: 'init_3',
              name: 'Dumbbell Bent-Over Row',
              targetMuscle: 'Upper Back & Lats',
              equipmentRequired: finalProfile.equipmentList.first.name,
              sets: [
                ExerciseSet(setNumber: 1, targetReps: 12, targetWeightKg: 10),
                ExerciseSet(setNumber: 2, targetReps: 12, targetWeightKg: 10),
                ExerciseSet(setNumber: 3, targetReps: 12, targetWeightKg: 10),
              ],
            ),
            Exercise(
              id: 'init_4',
              name: 'Plank Hold',
              targetMuscle: 'Core',
              equipmentRequired: 'Bodyweight',
              sets: [
                ExerciseSet(setNumber: 1, targetReps: 45, targetWeightKg: 0),
                ExerciseSet(setNumber: 2, targetReps: 45, targetWeightKg: 0),
              ],
            ),
          ],
        );
      }

      // Step 4: Launch
      if (mounted) setState(() => _calibrationProgressStep = 4);

      // Track with Mixpanel
      final analytics = ref.read(analyticsServiceProvider);
      await analytics.setUserId(uid);
      await analytics.setUserProperties({
        r'$name': finalProfile.name,
        'coach_soul': finalProfile.coachSoul.name,
        'goal_type': finalProfile.goal.name,
        'days_per_week': finalProfile.daysPerWeek,
        'dietary_preference': finalProfile.dietaryPreference,
        'experience_level': finalProfile.experienceLevel.name,
      });
      await analytics.registerSuperProperties({
        'coach_soul': finalProfile.coachSoul.name,
        'goal_type': finalProfile.goal.name,
      });

      await analytics.logEvent(
        AuraAnalyticsEvents.planCalibrated,
        properties: {
          'goal_type': finalProfile.goal.name,
          'target_calories': nutrition.targetCalories,
          'target_protein_g': nutrition.targetProteinG,
          'days_per_week': finalProfile.daysPerWeek,
          'equipment_count': finalProfile.equipmentList.length,
          'coach_soul': finalProfile.coachSoul.name,
        },
      );

      final signUpMethod = useGoogleAuth ? 'google' : (email != null ? 'email' : 'anonymous');
      await analytics.logEvent(
        AuraAnalyticsEvents.signUpCompleted,
        properties: {
          'sign_up_method': signUpMethod,
          'coach_soul': finalProfile.coachSoul.name,
          'goal_type': finalProfile.goal.name,
          'platform': kIsWeb ? 'flutter_pwa' : 'mobile',
        },
      );

      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        notifier.completeOnboardingWithPlan(finalProfile, nutrition, workout);
      }
    } catch (e) {
      debugPrint('[AURA ONBOARDING] Calibration failed: $e');
      if (mounted) {
        setState(() {
          _calibrationError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentStep > 0 && _currentStep < 6) {
          setState(() {
            _currentStep--;
          });
        }
      },
      child: Theme(
        data: getAuraTheme(_selectedSoul),
        child: Scaffold(
        backgroundColor: const Color(0xFF0B0B0E), // Deep Void
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.02),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentStep),
                    child: _buildCurrentScreen(),
                  ),
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentStep) {
      case 0:
        return _buildSparkScreen();
      case 1:
        return _buildHardConstantsScreen();
      case 2:
        return _buildInterviewScreen();
      case 3:
        return _buildSoulScreen();
      case 4:
        return _buildPlanSummaryScreen();
      case 5:
        return _buildCalibrationLoadingScreen();
      default:
        return const SizedBox();
    }
  }

  // ─── SCREEN 0: THE SPARK ───
  Widget _buildSparkScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const AuraOrb(soul: CoachSoul.supporter, state: OrbState.pulsing, size: 200),
        const SizedBox(height: 40),
        Text(
          'Hi, I’m AURA.',
          style: GoogleFonts.syne(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Your adaptive AI transformation coach. I build your training, balance your nutrition, and evolve with you every day.',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFA1A1AA),
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
              elevation: 3,
            ),
            onPressed: () => _goToStep(1),
            child: Text(
              "Let's Begin",
              style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Sign-in option for returning users
        TextButton(
          onPressed: () => _showSignInModal(context),
          child: RichText(
            text: TextSpan(
              text: 'Already an athlete with AURA? ',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFA1A1AA),
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: 'Sign In',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF39E6A3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ─── STEP A: THE HARD CONSTANTS (UI Forms) ───
  Widget _buildHardConstantsScreen() {
    final isNameValid = _nameController.text.trim().isNotEmpty;
    final isAgeValid = _age >= 14 && _age <= 99;
    final isHeightValid = _heightCm >= 100 && _heightCm <= 240;
    final isWeightValid = _weightKg >= 30 && _weightKg <= 280;
    final canProceed = isNameValid && isAgeValid && isHeightValid && isWeightValid;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: AuraOrb(soul: _selectedSoul, state: OrbState.pulsing, size: 70),
          ),
          const SizedBox(height: 20),
          Text(
            'Step A: Physical Metrics & Baseline',
            style: GoogleFonts.syne(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Strict physical parameters ensure mathematical accuracy for your metabolic targets.',
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Name Input
          _buildInputContainer(
            label: 'What should I call you?',
            child: TextField(
              controller: _nameController,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Enter your name or nickname',
                hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white30, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => setState(() => _name = val),
            ),
          ),
          const SizedBox(height: 14),

          // Gender Selection
          _buildInputContainer(
            label: 'Biological Sex (for metabolic BMR formula)',
            child: Row(
              children: [
                _buildRadioChip('Male', _gender == 'male', () => setState(() => _gender = 'male')),
                const SizedBox(width: 8),
                _buildRadioChip('Female', _gender == 'female', () => setState(() => _gender = 'female')),
                const SizedBox(width: 8),
                _buildRadioChip('Other', _gender == 'other', () => setState(() => _gender = 'other')),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Age & Height & Weight Row
          Row(
            children: [
              Expanded(
                child: _buildInputContainer(
                  label: 'Age',
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, suffixText: 'yrs', suffixStyle: TextStyle(color: Colors.white38)),
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null) setState(() => _age = parsed);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInputContainer(
                  label: 'Height',
                  child: TextField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, suffixText: 'cm', suffixStyle: TextStyle(color: Colors.white38)),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null) setState(() => _heightCm = parsed);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInputContainer(
                  label: 'Weight',
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, suffixText: 'kg', suffixStyle: TextStyle(color: Colors.white38)),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null) setState(() => _weightKg = parsed);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Goal Selection
          Text(
            'Primary Transformation Goal',
            style: GoogleFonts.syne(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildGoalCard(
            goal: GoalType.fatLoss,
            title: 'Burn Fat & Get Lean',
            subtitle: 'Calorie deficit targeting maximum fat burn while retaining muscle.',
            icon: LucideIcons.flame,
          ),
          const SizedBox(height: 8),
          _buildGoalCard(
            goal: GoalType.recomp,
            title: 'Lose Fat & Build Muscle (Recomp)',
            subtitle: 'High-protein balance for simultaneous fat loss and hypertrophy.',
            icon: LucideIcons.refreshCw,
          ),
          const SizedBox(height: 8),
          _buildGoalCard(
            goal: GoalType.muscleGain,
            title: 'Build Muscle & Strength',
            subtitle: 'Slight calorie surplus focusing on progressive overload and size.',
            icon: LucideIcons.dumbbell,
          ),
          const SizedBox(height: 20),

          // Dietary Baseline
          Text(
            'Dietary Preference',
            style: GoogleFonts.syne(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDietChip('Non-Veg', 'nonVeg'),
              _buildDietChip('Vegetarian', 'vegetarian'),
              _buildDietChip('Eggetarian', 'eggetarian'),
              _buildDietChip('Vegan', 'vegan'),
            ],
          ),
          const SizedBox(height: 32),

          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.12)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () => _goToStep(0),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canProceed ? AuraColors.getSoulPalette(_selectedSoul).primary : const Color(0xFF1E293B),
                    foregroundColor: canProceed ? Colors.black : Colors.white38,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: canProceed ? () => _goToStep(2) : null,
                  child: Text('Step B: AI Interview →', style: GoogleFonts.syne(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── STEP B: THE STATE-DRIVEN INTERVIEW (AI Chat) ───
  Widget _buildInterviewScreen() {
    final equipNames = _interviewEquipmentList.map((e) => e.name).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Center(
          child: AuraOrb(soul: _selectedSoul, state: _isInterviewThinking ? OrbState.pulsing : OrbState.idle, size: 80),
        ),
        const SizedBox(height: 14),
        Center(
          child: Column(
            children: [
              Text(
                'Step B: Lifestyle & Gear Intake',
                style: GoogleFonts.syne(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'AURA dynamically parses your equipment & training days.',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Live Calibrated Status Chip
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AuraColors.getSoulPalette(_selectedSoul).primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AuraColors.getSoulPalette(_selectedSoul).primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.checkCircle2, color: AuraColors.getSoulPalette(_selectedSoul).primary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Calibrated: $_daysPerWeek Days/Wk • $equipNames',
                  style: GoogleFonts.plusJakartaSans(color: AuraColors.getSoulPalette(_selectedSoul).primary, fontWeight: FontWeight.w600, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Chat Transcript Container
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF141217),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _interviewMessages.length + (_isInterviewThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isInterviewThinking && index == _interviewMessages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AuraColors.getSoulPalette(_selectedSoul).primary),
                          ),
                          const SizedBox(width: 8),
                          Text('AURA is parsing your routine...', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }

                final msg = _interviewMessages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: isUser ? AuraColors.getSoulPalette(_selectedSoul).primary.withOpacity(0.18) : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isUser ? AuraColors.getSoulPalette(_selectedSoul).primary.withOpacity(0.4) : Colors.transparent),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Dynamic Quick Suggestion Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _dynamicQuickReplies.map((reply) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildInspirationChip(reply),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),

        // Input Field
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF141217),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: TextField(
                  controller: _interviewInputController,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Tell AURA your schedule & gear...',
                    hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                    border: InputBorder.none,
                  ),
                  onSubmitted: _sendInterviewMessage,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _sendInterviewMessage(_interviewInputController.text),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AuraColors.getSoulPalette(_selectedSoul).primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.send, color: Colors.black, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Navigation
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.12)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _goToStep(1),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLifestyleIntakeComplete
                      ? AuraColors.getSoulPalette(_selectedSoul).primary
                      : const Color(0xFF27272A),
                  foregroundColor: _isLifestyleIntakeComplete ? Colors.black : const Color(0xFF71717A),
                  disabledBackgroundColor: const Color(0xFF27272A),
                  disabledForegroundColor: const Color(0xFF71717A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isLifestyleIntakeComplete ? () => _goToStep(3) : null,
                child: Text(
                  _isLifestyleIntakeComplete ? 'Select Coach Persona →' : 'Complete Intake to Continue',
                  style: GoogleFonts.syne(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _isLifestyleIntakeComplete ? Colors.black : const Color(0xFF71717A),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildInspirationChip(String text) {
    return GestureDetector(
      onTap: () {
        _interviewInputController.text = text;
        _interviewInputController.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF141217),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 11),
        ),
      ),
    );
  }

  // ─── SCREEN 3: CHOOSE COACH SOUL ───
  Widget _buildSoulScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Center(
          child: AuraOrb(soul: _selectedSoul, state: OrbState.pulsing, size: 70),
        ),
        const SizedBox(height: 24),
        Text(
          "Choose Your Coach's Soul",
          style: GoogleFonts.syne(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'How do you want AURA to communicate and keep you accountable?',
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 13),
        ),
        const SizedBox(height: 24),

        _buildSoulCard(
          soul: CoachSoul.supporter,
          title: 'The Supporter',
          description: 'Gentle, empathetic, and celebrates consistency and small wins.',
          colorsLabel: 'Sage / Lavender Orb',
        ),
        const SizedBox(height: 12),
        _buildSoulCard(
          soul: CoachSoul.pro,
          title: 'The Pro',
          description: 'Direct, metrics-driven, and maintains high discipline standards.',
          colorsLabel: 'Electric Blue / Neon Magenta Orb',
        ),
        const SizedBox(height: 12),
        _buildSoulCard(
          soul: CoachSoul.teacher,
          title: 'The Teacher',
          description: 'Educational, analytical, and explains the physiological why behind each plan.',
          colorsLabel: 'Teal / Silver Orb',
        ),
        const Spacer(),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.12)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () => _goToStep(2),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AuraColors.getSoulPalette(_selectedSoul).primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () => _goToStep(4),
                child: Text('Review Plan', style: GoogleFonts.syne(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ─── SCREEN 4: PLAN SUMMARY & AUTH ───
  Widget _buildPlanSummaryScreen() {
    final equipSummary = _buildFinalEquipmentList().map((e) => e.toString()).join(', ');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: AuraOrb(soul: _selectedSoul, state: OrbState.pulsing, size: 75),
          ),
          const SizedBox(height: 18),
          Text(
            "Calibration Ready for ${_name.trim().isNotEmpty ? _name.trim() : 'You'}",
            style: GoogleFonts.syne(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Review your parameters before AURA generates your live program:",
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Parameter Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF141217),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI CALIBRATION PROFILE',
                      style: GoogleFonts.syne(
                        color: AuraColors.getSoulPalette(_selectedSoul).primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Icon(LucideIcons.sparkles, color: AuraColors.getSoulPalette(_selectedSoul).primary, size: 14),
                  ],
                ),
                const SizedBox(height: 14),
                _buildSummaryRow(LucideIcons.user, 'Athlete', '${_name.trim().isNotEmpty ? _name.trim() : "Athlete"} (${_age}y, ${_gender.toUpperCase()})'),
                _buildSummaryRow(LucideIcons.scale, 'Metrics', '${_heightCm.round()} cm / ${_weightKg.round()} kg → Target: ${_getTargetWeight().round()} kg'),
                _buildSummaryRow(LucideIcons.target, 'Focus', '${_selectedGoal.displayName} (${_getTargetPhysique()})'),
                _buildSummaryRow(LucideIcons.calendar, 'Schedule', '$_daysPerWeek Days/Week'),
                _buildSummaryRow(LucideIcons.utensils, 'Nutrition', _dietaryPreference.toUpperCase()),
                _buildSummaryRow(LucideIcons.dumbbell, 'Equipment', equipSummary),
                _buildSummaryRow(LucideIcons.bot, 'Coach Tone', _selectedSoul.name.toUpperCase()),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Continue with Google
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () => _runCalibrationAndComplete(useGoogleAuth: true),
              icon: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                child: const Text('G', style: TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.w900, fontSize: 16)),
              ),
              label: Text("Continue with Google", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 10),

          // Activate as Guest
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AuraColors.getSoulPalette(_selectedSoul).primary,
                side: const BorderSide(color: Color(0x6000FFA3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () => _runCalibrationAndComplete(useGoogleAuth: false),
              child: Text("Activate as Guest", style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
          const SizedBox(height: 12),

          Center(
            child: TextButton(
              onPressed: () => _goToStep(3),
              child: Text('Edit soul selection', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 12)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── SCREEN 6: CALIBRATION LOADING ───
  Widget _buildCalibrationLoadingScreen() {
    String stepText = '';
    switch (_calibrationProgressStep) {
      case 1:
        stepText = 'Initializing secure state link for ${_name.trim().isNotEmpty ? _name.trim() : "you"}...';
        break;
      case 2:
        stepText = 'Calculating dynamic Mifflin-St Jeor metabolic baseline...';
        break;
      case 3:
        stepText = 'Designing personalized workout plan...';
        break;
      case 4:
        stepText = 'Launching AURA Transformation Engine...';
        break;
    }

    if (_calibrationError != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.alertTriangle, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            'Calibration Error',
            style: GoogleFonts.syne(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _calibrationError!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AuraColors.getSoulPalette(_selectedSoul).primary, foregroundColor: Colors.black),
            onPressed: () => _runCalibrationAndComplete(),
            child: const Text('Retry Calibration'),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AuraOrb(soul: _selectedSoul, state: OrbState.pulsing, size: 140),
        const SizedBox(height: 36),
        Text(
          'Calibrating AURA',
          style: GoogleFonts.syne(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          stepText,
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 180,
          child: LinearProgressIndicator(
            value: _calibrationProgressStep / 4.0,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(AuraColors.getSoulPalette(_selectedSoul).primary),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  // ─── REUSABLE UI HELPERS ───

  Widget _buildInputContainer({required String label, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141217),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  Widget _buildRadioChip(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AuraColors.getSoulPalette(_selectedSoul).primary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AuraColors.getSoulPalette(_selectedSoul).primary : Colors.white12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required GoalType goal,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedGoal == goal;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goal),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AuraColors.getSoulPalette(_selectedSoul).primary.withOpacity(0.10) : const Color(0xFF141217),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AuraColors.getSoulPalette(_selectedSoul).primary : Colors.white.withOpacity(0.08), width: isSelected ? 1.5 : 1.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AuraColors.getSoulPalette(_selectedSoul).primary.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? AuraColors.getSoulPalette(_selectedSoul).primary : Colors.white60, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietChip(String label, String value) {
    final isSelected = _dietaryPreference == value;
    return GestureDetector(
      onTap: () => setState(() => _dietaryPreference = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AuraColors.getSoulPalette(_selectedSoul).primary.withOpacity(0.15) : const Color(0xFF141217),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AuraColors.getSoulPalette(_selectedSoul).primary : Colors.white.withOpacity(0.08)),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected ? Colors.white : const Color(0xFFA1A1AA),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSoulCard({
    required CoachSoul soul,
    required String title,
    required String description,
    required String colorsLabel,
  }) {
    final isSelected = _selectedSoul == soul;
    final soulPalette = AuraColors.getSoulPalette(soul);
    final borderColor = isSelected ? soulPalette.secondary : Colors.white.withOpacity(0.08);
    final highlightColor = isSelected ? soulPalette.secondary.withOpacity(0.1) : Colors.transparent;

    return GestureDetector(
      onTap: () {
        ref.read(analyticsServiceProvider).logEvent(
          AuraAnalyticsEvents.soulSelected,
          properties: {
            'soul_name': soul.name,
            'previous_soul': _selectedSoul.name,
            'surface': 'onboarding',
          },
        );
        setState(() => _selectedSoul = soul);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? highlightColor : const Color(0xFF141217),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
        ),
        child: Row(
          children: [
            AuraOrb(soul: soul, state: OrbState.pulsing, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    colorsLabel,
                    style: GoogleFonts.plusJakartaSans(
                      color: isSelected ? borderColor : Colors.white24,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white60, size: 15),
          const SizedBox(width: 8),
          Text('$label: ', style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignInModal(BuildContext context) {
    bool isLoading = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121416),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.syne(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, color: Colors.white60, size: 20),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in with Google to sync your workouts, macros, and coaching history.',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFA1A1AA),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          errorMessage!,
                          style: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontSize: 12),
                        ),
                      ),

                    // Google Sign-In Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        ),
                        icon: Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          child: const Text('G', style: TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.w900, fontSize: 16)),
                        ),
                        label: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                              )
                            : Text(
                                'Continue with Google',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                setModalState(() {
                                  isLoading = true;
                                  errorMessage = null;
                                });
                                final success = await ref
                                    .read(transformationEngineProvider.notifier)
                                    .signInAndLoadUserProfile(useGoogleAuth: true);
                                if (!ctx.mounted) return;
                                if (success) {
                                  Navigator.of(ctx).pop();
                                } else {
                                  setModalState(() {
                                    isLoading = false;
                                    errorMessage = 'No saved profile found. Please tap "Let\'s Begin" to calibrate your baseline.';
                                  });
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
