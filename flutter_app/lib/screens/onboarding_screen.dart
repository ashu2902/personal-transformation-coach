import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/models.dart';
import '../providers/transformation_state.dart';
import '../engine/engine_calculators.dart';
import '../services/ai_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0;

  // Step 1: Goal & Physique
  GoalType _selectedGoal = GoalType.recomp;
  String _selectedPhysique = 'Athletic & Lean';

  final List<String> _physiqueOptions = [
    'Athletic & Lean',
    'Toned & Defined',
    'Muscular & Strong',
    'Fit & Energetic',
  ];

  // Step 2: Body Profile
  final _nameController = TextEditingController(text: 'Alex Vance');
  final _heightController = TextEditingController(text: '178');
  final _weightController = TextEditingController(text: '76.5');
  final _targetWeightController = TextEditingController(text: '80.0');
  final int _age = 26;

  double get _heightCm => double.tryParse(_heightController.text) ?? 178;
  double get _weightKg => double.tryParse(_weightController.text) ?? 76.5;
  double get _targetWeightKg => double.tryParse(_targetWeightController.text) ?? 80.0;

  // Step 3: Experience & Strength Baseline
  ExperienceLevel _experienceLevel = ExperienceLevel.intermediate;
  final _benchController = TextEditingController(text: '');
  final _squatController = TextEditingController(text: '');
  final _deadliftController = TextEditingController(text: '');

  final Set<String> _selectedInjuries = {};
  final List<String> _injuryOptions = [
    'Lower Back Discomfort',
    'Shoulder Impingement',
    'Knee Joint Sensitivity',
    'Wrist / Forearm Pain',
  ];

  // Step 4: Equipment & Schedule
  int _daysPerWeek = 4;
  final Set<EquipmentType> _selectedEquipment = {
    EquipmentType.dumbbells,
    EquipmentType.barbell,
    EquipmentType.cables,
    EquipmentType.machines,
  };

  // Step 5: AI Calibration state & Animations
  bool _isCalibrating = false;
  int _calibrationProgressStep = 1;
  DailyNutrition? _aiGeneratedNutrition;
  DailyWorkout? _aiGeneratedWorkout;

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseGlow;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.94, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseGlow = Tween<double>(begin: 0.2, end: 0.75).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _benchController.dispose();
    _squatController.dispose();
    _deadliftController.dispose();
    super.dispose();
  }

  void _synthesizeAIPlan() async {
    setState(() {
      _isCalibrating = true;
      _calibrationProgressStep = 1;
      _currentStep = 4;
    });

    final name = _nameController.text.trim().isEmpty ? 'Alex Vance' : _nameController.text.trim();
    final bench = _benchController.text.trim().isEmpty ? null : double.tryParse(_benchController.text);
    final squat = _squatController.text.trim().isEmpty ? null : double.tryParse(_squatController.text);
    final deadlift = _deadliftController.text.trim().isEmpty ? null : double.tryParse(_deadliftController.text);

    final profile = UserProfile(
      name: name,
      age: _age,
      heightCm: _heightCm,
      weightKg: _weightKg,
      targetWeightKg: _targetWeightKg,
      goal: _selectedGoal,
      daysPerWeek: _daysPerWeek,
      targetPhysique: _selectedPhysique,
      availableEquipment: _selectedEquipment.toList(),
      experienceLevel: _experienceLevel,
      benchPress1RMKg: bench,
      squat1RMKg: squat,
      deadlift1RMKg: deadlift,
      activeInjuries: _selectedInjuries.toList(),
    );

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _calibrationProgressStep = 2);

    final aiService = GeminiAIProvider(apiKey: const String.fromEnvironment('GEMINI_API_KEY'));
    final nutrition = await aiService.generateAIMetabolicPlan(profile);

    if (mounted) setState(() => _calibrationProgressStep = 3);
    final workout = await aiService.generateAIInitialWorkout(profile);

    if (mounted) setState(() => _calibrationProgressStep = 4);
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      final notifier = ref.read(transformationEngineProvider.notifier);
      notifier.completeOnboardingWithPlan(profile, nutrition, workout);
    }
  }

  void _completeOnboarding(TransformationEngineNotifier notifier) async {
    setState(() => _isCalibrating = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final name = _nameController.text.trim().isEmpty ? 'Alex Vance' : _nameController.text.trim();
    final bench = _benchController.text.trim().isEmpty ? null : double.tryParse(_benchController.text);
    final squat = _squatController.text.trim().isEmpty ? null : double.tryParse(_squatController.text);
    final deadlift = _deadliftController.text.trim().isEmpty ? null : double.tryParse(_deadliftController.text);

    final profile = UserProfile(
      name: name,
      age: _age,
      heightCm: _heightCm,
      weightKg: _weightKg,
      targetWeightKg: _targetWeightKg,
      goal: _selectedGoal,
      daysPerWeek: _daysPerWeek,
      targetPhysique: _selectedPhysique,
      availableEquipment: _selectedEquipment.toList(),
      experienceLevel: _experienceLevel,
      benchPress1RMKg: bench,
      squat1RMKg: squat,
      deadlift1RMKg: deadlift,
      activeInjuries: _selectedInjuries.toList(),
    );

    notifier.completeOnboarding(profile);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(transformationEngineProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Progress Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0x2010B981),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(LucideIcons.sparkles, color: Color(0xFF10B981), size: 16),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'YOUR FIT SETUP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _currentStep == 4
                            ? 'AI PLAN SYNTHESIS'
                            : 'Step ${_currentStep == 5 ? 5 : _currentStep + 1} of 5',
                        style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (index) {
                      final stepMapIndex = _currentStep == 5 ? 4 : _currentStep;
                      final isActive = index <= stepMapIndex;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFF10B981) : const Color(0xFF1E2638),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Step Content with Smooth Motion Transition
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: SingleChildScrollView(
                        key: ValueKey<int>(_currentStep),
                        child: _buildStepContent(),
                      ),
                    ),
                  ),

                  // Navigation Footer Buttons (Hidden during live AI synthesis)
                  if (!_isCalibrating && _currentStep != 4) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFF2E384E)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => setState(() => _currentStep--),
                              child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              if (_currentStep < 3) {
                                setState(() => _currentStep++);
                              } else if (_currentStep == 3) {
                                _synthesizeAIPlan();
                              } else {
                                _completeOnboarding(notifier);
                              }
                            },
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _currentStep == 3
                                    ? 'Calculate My Plan ➔'
                                    : _currentStep == 5
                                        ? 'Accept Plan & Launch 🚀'
                                        : 'Continue',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildGoalStep();
      case 1:
        return _buildProfileStep();
      case 2:
        return _buildExperienceBaselineStep();
      case 3:
        return _buildEquipmentStep();
      case 4:
        return _buildCalibrationStep();
      case 5:
        return _buildPlanSummaryStep();
      default:
        return const SizedBox();
    }
  }

  // STEP 1: GOAL & TARGET PHYSIQUE
  Widget _buildGoalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What is your primary goal?',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'We will set up your daily calories, protein, and workout plan based on this.',
          style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
        ),
        const SizedBox(height: 20),
        _buildGoalCard(
          GoalType.recomp,
          'Lose Fat & Build Muscle',
          'Burn fat while toning and building muscle at the same time.',
          LucideIcons.zap,
        ),
        _buildGoalCard(
          GoalType.fatLoss,
          'Lose Fat',
          'Maximize calorie burning to lean down fast.',
          LucideIcons.flame,
        ),
        _buildGoalCard(
          GoalType.muscleGain,
          'Build Muscle & Strength',
          'Eat enough to gain lean mass and get stronger.',
          LucideIcons.dumbbell,
        ),
        const SizedBox(height: 20),
        const Text(
          'Target Physique Goal',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _physiqueOptions.map((physique) {
            final isSelected = _selectedPhysique == physique;
            return ChoiceChip(
              selected: isSelected,
              backgroundColor: const Color(0xFF141923),
              selectedColor: const Color(0x3010B981),
              side: BorderSide(color: isSelected ? const Color(0xFF10B981) : const Color(0xFF2E384E)),
              label: Text(
                physique,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF10B981) : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              onSelected: (_) => setState(() => _selectedPhysique = physique),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGoalCard(GoalType goal, String title, String subtitle, IconData icon) {
    final isSelected = _selectedGoal == goal;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141923),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1E2638), width: isSelected ? 1.5 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withAlpha(20),
                    blurRadius: 10,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0x2010B981) : const Color(0xFF1E2638),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? const Color(0xFF10B981) : const Color(0xFFA1A1AA), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 11)),
                ],
              ),
            ),
            Icon(
              isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
              color: isSelected ? const Color(0xFF10B981) : const Color(0xFF3F4B66),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: BODY PROFILE & LIVE BMR MATH
  Widget _buildProfileStep() {
    final bmr = EngineCalculators.calculateBMR(weightKg: _weightKg, heightCm: _heightCm, ageYears: _age);
    final nutrition = EngineCalculators.calculateInitialNutrition(
      weightKg: _weightKg,
      heightCm: _heightCm,
      ageYears: _age,
      goal: _selectedGoal,
      daysPerWeek: _daysPerWeek,
      targetWeightKg: _targetWeightKg,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Body Baseline',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Used to compute your metabolic baseline (BMR) and daily protein requirement.',
          style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
        ),
        const SizedBox(height: 20),

        // Name
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Your Name',
            labelStyle: const TextStyle(color: Color(0xFFA1A1AA)),
            filled: true,
            fillColor: const Color(0xFF141923),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),

        // Height, Current Weight & Target Weight Input Card Row
        Row(
          children: [
            Expanded(
              child: _buildBaselineInputField(
                controller: _heightController,
                label: 'Height',
                unit: 'cm',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBaselineInputField(
                controller: _weightController,
                label: 'Current Weight',
                unit: 'kg',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBaselineInputField(
                controller: _targetWeightController,
                label: 'Target Weight',
                unit: 'kg',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Real-Time Metabolic Preview Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0x2010B981),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x4010B981)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMetric('Base Calories', '${bmr.round()} kcal'),
              _buildStatMetric('Daily Calorie Target', '${nutrition.targetCalories} kcal'),
              _buildStatMetric('Protein Target', '${nutrition.targetProteinG}g P'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatMetric(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }



  Widget _buildBaselineInputField({
    required TextEditingController controller,
    required String label,
    String unit = 'kg',
    String hint = 'Optional',
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141923),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2638)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 12),
                  ),
                ),
              ),
              Text(
                unit,
                style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 3: EXPERIENCE LEVEL & LIFTING BASELINE (FOR EXISTING LIFTERS)
  Widget _buildExperienceBaselineStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Training Experience',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Whether you are starting out or experienced, we adjust your starting weights accordingly.',
          style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
        ),
        const SizedBox(height: 20),

        const Text('How long have you been training?', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        _buildExperienceOption(
          ExperienceLevel.beginner,
          'Beginner (< 1 Year)',
          'Getting started with workout basics.',
          LucideIcons.sprout,
        ),
        _buildExperienceOption(
          ExperienceLevel.intermediate,
          'Intermediate (1 - 3 Years)',
          'Train regularly and know your weights.',
          LucideIcons.trophy,
        ),
        _buildExperienceOption(
          ExperienceLevel.advanced,
          'Advanced (3+ Years)',
          'Experienced lifter training for years.',
          LucideIcons.crown,
        ),
        const SizedBox(height: 20),

        // Working Weight Baselines (Optional for Intermediate/Advanced)
        if (_experienceLevel != ExperienceLevel.beginner) ...[
          const Text(
            'Current Working Weight Baselines (Optional)',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildBaselineInputField(
                  controller: _benchController,
                  label: 'Bench Press',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBaselineInputField(
                  controller: _squatController,
                  label: 'Squat',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBaselineInputField(
                  controller: _deadliftController,
                  label: 'Deadlift',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],

        // Joint Protection & Injury Assessment
        const Text('Any Joints to Protect?', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _injuryOptions.map((injury) {
            final isSelected = _selectedInjuries.contains(injury);
            return FilterChip(
              selected: isSelected,
              backgroundColor: const Color(0xFF141923),
              selectedColor: const Color(0x30F59E0B),
              side: BorderSide(color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF2E384E)),
              label: Text(
                injury,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFFA1A1AA),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedInjuries.add(injury);
                  } else {
                    _selectedInjuries.remove(injury);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExperienceOption(ExperienceLevel level, String title, String subtitle, IconData icon) {
    final isSelected = _experienceLevel == level;
    return GestureDetector(
      onTap: () => setState(() => _experienceLevel = level),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF141923),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1E2638), width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF10B981) : const Color(0xFFA1A1AA), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 11)),
                ],
              ),
            ),
            Icon(
              isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
              color: isSelected ? const Color(0xFF10B981) : const Color(0xFF3F4B66),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // STEP 4: EQUIPMENT & SCHEDULE
  Widget _buildEquipmentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Where Will You Train?',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select your equipment so we only suggest exercises you can do.',
          style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
        ),
        const SizedBox(height: 20),

        const Text('How many days a week can you train?', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [3, 4, 5, 6].map((days) {
            final isSelected = _daysPerWeek == days;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _daysPerWeek = days),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF10B981) : const Color(0xFF141923),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '$days Days',
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        const Text('Available Equipment', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildEquipmentCheck(EquipmentType.dumbbells, 'Dumbbells', LucideIcons.dumbbell),
        _buildEquipmentCheck(EquipmentType.barbell, 'Barbell & Plates', LucideIcons.disc),
        _buildEquipmentCheck(EquipmentType.cables, 'Cable Machine', LucideIcons.activity),
        _buildEquipmentCheck(EquipmentType.machines, 'Gym Machines', LucideIcons.layoutGrid),
        _buildEquipmentCheck(EquipmentType.bodyweight, 'Bodyweight Only', LucideIcons.userCheck),
      ],
    );
  }

  Widget _buildEquipmentCheck(EquipmentType type, String title, IconData icon) {
    final isSelected = _selectedEquipment.contains(type);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            if (_selectedEquipment.length > 1) _selectedEquipment.remove(type);
          } else {
            _selectedEquipment.add(type);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF141923),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1E2638)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF10B981) : const Color(0xFFA1A1AA), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            Icon(
              isSelected ? LucideIcons.checkSquare : LucideIcons.square,
              color: isSelected ? const Color(0xFF10B981) : const Color(0xFF3F4B66),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // STEP 5: AI CALIBRATION SCREEN
  Widget _buildCalibrationStep() {
    double progressPercent = (_calibrationProgressStep / 4.0).clamp(0.15, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),

        // Glowing Pulsing AI Orb
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseScale.value,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0x6010B981), Color(0x2006B6D4), Colors.transparent],
                    stops: [0.2, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: _pulseGlow.value),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF10B981), width: 2),
                  ),
                  child: const Icon(LucideIcons.sparkles, color: Color(0xFF10B981), size: 34),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        const Text(
          'Gemini 3.6 Flash AI Synthesizing...',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Crafting a precision transformation blueprint for ${_nameController.text.trim()}',
          style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Animated Progress Bar
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF1E2638),
            borderRadius: BorderRadius.circular(3),
          ),
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.centerLeft,
            widthFactor: progressPercent,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: const [
                  BoxShadow(color: Color(0x8010B981), blurRadius: 6),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(progressPercent * 100).toInt()}% Complete',
            style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),

        // Staggered Animated Step Check Items
        _buildCalibrationCheckItem('Analyzing body composition & baseline stats', stepIndex: 1),
        _buildCalibrationCheckItem('Synthesizing caloric deficit & protein targets via Gemini 3.6', stepIndex: 2),
        _buildCalibrationCheckItem('Prescribing $_daysPerWeek-day workout split & joint safeguards', stepIndex: 3),
        _buildCalibrationCheckItem('Finalizing your personalized transformation blueprint', stepIndex: 4),
      ],
    );
  }

  Widget _buildCalibrationCheckItem(String label, {required int stepIndex}) {
    final bool isDone = _calibrationProgressStep > stepIndex;
    final bool isActive = _calibrationProgressStep == stepIndex;

    Color borderColor = const Color(0xFF1E2638);
    Color bgColor = const Color(0xFF141923);
    Color textColor = const Color(0xFF71717A);

    if (isDone) {
      borderColor = const Color(0x4010B981);
      bgColor = const Color(0x1010B981);
      textColor = Colors.white;
    } else if (isActive) {
      borderColor = const Color(0xFF06B6D4);
      bgColor = const Color(0x1506B6D4);
      textColor = const Color(0xFF38BDF8);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          if (isDone)
            const Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 18)
          else if (isActive)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF06B6D4)),
            )
          else
            const Icon(LucideIcons.circle, color: Color(0xFF3F4B66), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: isActive || isDone ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 6: PLAN REVIEW & APPROVAL SCREEN
  Widget _buildPlanSummaryStep() {
    final bmr = EngineCalculators.calculateBMR(weightKg: _weightKg, heightCm: _heightCm, ageYears: _age);
    final nutrition = _aiGeneratedNutrition ?? EngineCalculators.calculateInitialNutrition(
      weightKg: _weightKg,
      heightCm: _heightCm,
      ageYears: _age,
      goal: _selectedGoal,
      daysPerWeek: _daysPerWeek,
      targetWeightKg: _targetWeightKg,
    );
    final workoutTitle = _aiGeneratedWorkout?.title ?? '$_daysPerWeek-Day Push / Pull / Legs';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0x2010B981),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.fileCheck, color: Color(0xFF10B981), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Personalized Plan Summary',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Review your custom targets for ${_nameController.text.trim()}',
                    style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Goal & Target Physique Header Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF141923),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF10B981)),
          ),
          child: Row(
            children: [
              Expanded(child: _buildSummaryHeaderStat('Primary Goal', _selectedGoal.displayName.toUpperCase())),
              const SizedBox(width: 6),
              Expanded(child: _buildSummaryHeaderStat('Target Physique', _selectedPhysique)),
              const SizedBox(width: 6),
              Expanded(child: _buildSummaryHeaderStat('Target Weight', '$_targetWeightKg kg')),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Card 1: Daily Nutrition Targets
        const Text('🔥 DAILY NUTRITION PLAN', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF141923),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E2638)),
          ),
          child: Column(
            children: [
              _buildSummaryDetailRow('Daily Calorie Target', '${nutrition.targetCalories} kcal'),
              const Divider(color: Color(0xFF1E2638), height: 16),
              _buildSummaryDetailRow('Base Rest Calories', '${bmr.round()} kcal'),
              const Divider(color: Color(0xFF1E2638), height: 16),
              _buildSummaryDetailRow('Daily Protein Target', '${nutrition.targetProteinG}g P (${(nutrition.targetProteinG / _weightKg).toStringAsFixed(1)}g / kg)'),
              const Divider(color: Color(0xFF1E2638), height: 16),
              _buildSummaryDetailRow('Carbs & Fats Breakdown', '${nutrition.targetCarbsG}g Carbs • ${nutrition.targetFatG}g Fat'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Card 2: Weekly Workout Program
        const Text('🏋️ WORKOUT PROGRAM & SAFEGUARDS', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF141923),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E2638)),
          ),
          child: Column(
            children: [
              _buildSummaryDetailRow('Training Split', workoutTitle),
              const Divider(color: Color(0xFF1E2638), height: 16),
              _buildSummaryDetailRow('Joint Safeguards', _selectedInjuries.isEmpty ? 'None (All Lifts Unlocked)' : _selectedInjuries.join(', ')),
              if (_experienceLevel != ExperienceLevel.beginner) ...[
                const Divider(color: Color(0xFF1E2638), height: 16),
                _buildSummaryDetailRow(
                  'Lifting Baselines',
                  (_benchController.text.trim().isEmpty && _squatController.text.trim().isEmpty && _deadliftController.text.trim().isEmpty)
                      ? 'None Entered (Starting Safe)'
                      : [
                          if (_benchController.text.trim().isNotEmpty) 'Bench: ${_benchController.text}kg',
                          if (_squatController.text.trim().isNotEmpty) 'Squat: ${_squatController.text}kg',
                          if (_deadliftController.text.trim().isNotEmpty) 'DL: ${_deadliftController.text}kg',
                        ].join(' • '),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeaderStat(String title, String val) {
    return Column(
      children: [
        Text(title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(val, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildSummaryDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
