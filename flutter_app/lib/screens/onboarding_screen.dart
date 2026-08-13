import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/models.dart';
import '../providers/transformation_state.dart';
import '../services/firebase_service.dart';
import 'widgets/aura_orb.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0; // 0: Spark, 1: Assessment, 2: Choose Soul, 3: Sunk-Cost Reveal, 4: Calibration

  // Assessment Data
  String _selectedObstacle = "I don't know where to start";
  double _heightCm = 175;
  double _weightKg = 75;
  GoalType _selectedGoal = GoalType.recomp;

  // Coach Soul selection
  CoachSoul _selectedSoul = CoachSoul.supporter;

  // Calibration State
  int _calibrationProgressStep = 1;
  String? _calibrationError;

  void _runCalibrationAndComplete() async {
    setState(() {
      _currentStep = 4;
      _calibrationProgressStep = 1;
    });

    final profile = UserProfile(
      name: 'Vance',
      age: 26,
      gender: 'other',
      heightCm: _heightCm,
      weightKg: _weightKg,
      targetWeightKg: _selectedGoal == GoalType.fatLoss ? _weightKg - 5 : _weightKg + 5,
      goal: _selectedGoal,
      daysPerWeek: 3,
      targetPhysique: _selectedGoal == GoalType.fatLoss ? 'Lean & Toned' : 'Strong & Active',
      availableEquipment: [EquipmentType.bodyweight, EquipmentType.dumbbells],
      experienceLevel: ExperienceLevel.beginner,
      coachSoul: _selectedSoul,
    );

    try {
      final notifier = ref.read(transformationEngineProvider.notifier);
      final aiService = notifier.aiService;

      // Step 1: Firebase Auth & Firestore write
      final auth = FirebaseAuthService();
      final firestore = FirebaseFirestoreService();
      final uid = await auth.signInWithGoogle();
      if (uid != null) {
        await firestore.saveUserProfile(uid, profile);
      }

      // Step 2: Metabolic Plan
      if (mounted) setState(() => _calibrationProgressStep = 2);
      final nutrition = await aiService.generateAIMetabolicPlan(profile);

      // Step 3: Workout Plan
      if (mounted) setState(() => _calibrationProgressStep = 3);
      final workout = await aiService.generateAIInitialWorkout(profile);

      // Step 4: Launch
      if (mounted) setState(() => _calibrationProgressStep = 4);
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        notifier.completeOnboardingWithPlan(profile, nutrition, workout);
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
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0E), // Deep Void
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.03),
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
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentStep) {
      case 0:
        return _buildSparkScreen();
      case 1:
        return _buildAssessmentScreen();
      case 2:
        return _buildSoulScreen();
      case 3:
        return _buildSunkCostScreen();
      case 4:
        return _buildCalibrationLoadingScreen();
      default:
        return const SizedBox();
    }
  }

  // SCREEN 1: THE SPARK
  Widget _buildSparkScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        AuraOrb(soul: CoachSoul.supporter, state: OrbState.pulsing, size: 220),
        const SizedBox(height: 48),
        Text(
          'Hi, I’m AURA.',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'I’m here to help you get moving, eating well, and feeling better. No math, no complex plans. Just one step at a time.',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFA1A1AA),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 4,
            ),
            onPressed: () => setState(() => _currentStep = 1),
            child: Text(
              "Let's start",
              style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // SCREEN 2: THE ASSESSMENT (CONVERSATIONAL)
  Widget _buildAssessmentScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(
          child: AuraOrb(soul: CoachSoul.supporter, state: OrbState.pulsing, size: 90),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF141217),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Text(
            "First, tell me what's the biggest thing stopping you right now?",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ..._buildObstacleChips(),
        const SizedBox(height: 32),
        Text(
          'Your Starting Point',
          style: GoogleFonts.syne(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildSliderCard(
          label: 'Height',
          value: _heightCm,
          min: 120,
          max: 220,
          unit: 'cm',
          onChanged: (val) => setState(() => _heightCm = val),
        ),
        const SizedBox(height: 12),
        _buildSliderCard(
          label: 'Weight',
          value: _weightKg,
          min: 40,
          max: 180,
          unit: 'kg',
          onChanged: (val) => setState(() => _weightKg = val),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFA3), // Neon Cyan-Green
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => setState(() => _currentStep = 2),
                child: Text('Continue', style: GoogleFonts.syne(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSliderCard({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141217),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13)),
              Text(
                '${value.round()} $unit',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: const Color(0xFF00FFA3),
            inactiveColor: Colors.white.withOpacity(0.1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildObstacleChips() {
    final list = [
      "I'm always tired",
      "I don't know where to start",
      "I've tried and quit before",
    ];

    return list.map((item) {
      final isSelected = _selectedObstacle == item;
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedObstacle = item;
            if (item == "I'm always tired") {
              _selectedGoal = GoalType.recomp;
            } else if (item == "I've tried and quit before") {
              _selectedGoal = GoalType.recomp;
            } else {
              _selectedGoal = GoalType.fatLoss;
            }
          });
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00FFA3).withOpacity(0.15) : const Color(0xFF141217),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF00FFA3) : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Text(
            item,
            style: GoogleFonts.plusJakartaSans(
              color: isSelected ? const Color(0xFF00FFA3) : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      );
    }).toList();
  }

  // SCREEN 3: CHOOSE YOUR COACH'S SOUL
  Widget _buildSoulScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          "Choose Your Coach's Soul",
          style: GoogleFonts.syne(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'How do you want me to talk to you?',
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 13),
        ),
        const SizedBox(height: 32),
        _buildSoulCard(
          soul: CoachSoul.supporter,
          title: 'The Supporter',
          description: 'Gentle, encouraging, and celebrates small wins.',
          colorsLabel: 'Sage / Lavender Orb',
        ),
        const SizedBox(height: 12),
        _buildSoulCard(
          soul: CoachSoul.pro,
          title: 'The Pro',
          description: 'Direct, keep-on-track, and highly metrics-focused.',
          colorsLabel: 'Electric Blue / Neon Magenta Orb',
        ),
        const SizedBox(height: 12),
        _buildSoulCard(
          soul: CoachSoul.teacher,
          title: 'The Teacher',
          description: 'Educational, analytical, and explains how your body works.',
          colorsLabel: 'Teal / Silver Orb',
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => setState(() => _currentStep = 1),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFA3),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => setState(() => _currentStep = 3),
                child: Text('Continue', style: GoogleFonts.syne(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSoulCard({
    required CoachSoul soul,
    required String title,
    required String description,
    required String colorsLabel,
  }) {
    final isSelected = _selectedSoul == soul;
    Color borderColor = Colors.white.withOpacity(0.08);
    Color highlightColor = Colors.transparent;

    if (isSelected) {
      switch (soul) {
        case CoachSoul.supporter:
          borderColor = const Color(0xFF9A7EB8);
          highlightColor = const Color(0xFF9A7EB8).withOpacity(0.1);
          break;
        case CoachSoul.pro:
          borderColor = const Color(0xFFFF007A);
          highlightColor = const Color(0xFFFF007A).withOpacity(0.1);
          break;
        case CoachSoul.teacher:
          borderColor = const Color(0xFF00BFA5);
          highlightColor = const Color(0xFF00BFA5).withOpacity(0.1);
          break;
      }
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedSoul = soul),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? highlightColor : const Color(0xFF141217),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            AuraOrb(soul: soul, state: OrbState.pulsing, size: 60),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.syne(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 12),
                  ),
                  const SizedBox(height: 6),
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

  // SCREEN 4: THE SUNK-COST REVEAL
  Widget _buildSunkCostScreen() {
    String goalText = _selectedGoal == GoalType.fatLoss ? 'Fat Loss' : 'Body Recomposition';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(
          child: AuraOrb(soul: _selectedSoul, state: OrbState.pulsing, size: 90),
        ),
        const SizedBox(height: 24),
        Text(
          "I've built your first 7 days.",
          style: GoogleFonts.syne(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "It focuses on $goalText. Ready to see today's plan?",
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 13),
        ),
        const SizedBox(height: 24),
        Stack(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: const Color(0xFF141217),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (index) {
                            return Column(
                              children: [
                                Text('Day ${index + 1}', style: const TextStyle(color: Colors.white30, fontSize: 10)),
                                const SizedBox(height: 8),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Icon(LucideIcons.check, size: 12, color: Colors.white30),
                                ),
                              ],
                            );
                          }),
                        ),
                        Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0x7F0B0B0E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.lock, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 4,
            ),
            onPressed: _runCalibrationAndComplete,
            icon: const Icon(LucideIcons.logIn, size: 18),
            label: Text(
              "Continue with Google",
              style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _currentStep = 2),
            child: Text(
              'Back to soul selection',
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // SCREEN 5: CALIBRATION LOADING SCREEN
  Widget _buildCalibrationLoadingScreen() {
    String stepText = '';
    switch (_calibrationProgressStep) {
      case 1:
        stepText = 'Initializing secure coach link...';
        break;
      case 2:
        stepText = 'Generating custom vegetarian metabolic profile...';
        break;
      case 3:
        stepText = 'Designing time-based active daily routine...';
        break;
      case 4:
        stepText = 'Completing calibration...';
        break;
    }

    if (_calibrationError != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.alertTriangle, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            'Calibration Failed',
            style: GoogleFonts.syne(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _calibrationError!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _calibrationError = null;
              });
              _runCalibrationAndComplete();
            },
            child: const Text('Try Again'),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        AuraOrb(soul: _selectedSoul, state: OrbState.swirling, size: 200),
        const SizedBox(height: 48),
        Text(
          'CALIBRATING AURA',
          style: GoogleFonts.syne(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          stepText,
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 140,
            height: 4,
            child: LinearProgressIndicator(
              value: _calibrationProgressStep / 4.0,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                _selectedSoul == CoachSoul.supporter
                    ? const Color(0xFF9A7EB8)
                    : _selectedSoul == CoachSoul.pro
                        ? const Color(0xFFFF007A)
                        : const Color(0xFF00BFA5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
