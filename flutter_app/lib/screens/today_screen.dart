import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';
import 'widgets/aura_orb.dart';

class TodayScreen extends ConsumerWidget {
  final Function(int tabIndex, {int subIndex})? onNavigateToTab;

  const TodayScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);
    final notifier = ref.read(transformationEngineProvider.notifier);

    final todayStr = DateFormat('MMMM d').format(DateTime.now());

    final workout = state.workout;
    final nutrition = state.nutrition;
    final recovery = state.recovery;

    final totalCal = nutrition.meals.fold(0, (sum, m) => sum + m.calories);
    final totalProt = nutrition.meals.fold(0, (sum, m) => sum + m.proteinG);
    final remainingProt = (nutrition.targetProteinG - totalProt).clamp(0, 999);

    final calPercent = (totalCal / (nutrition.targetCalories > 0 ? nutrition.targetCalories : 2000)).clamp(0.0, 1.0);
    final protPercent = (totalProt / (nutrition.targetProteinG > 0 ? nutrition.targetProteinG : 150)).clamp(0.0, 1.0);

    // Dynamically retrieve accent colors for chosen coach soul
    Color activePrimary;
    Color activeSecondary;
    switch (state.profile.coachSoul) {
      case CoachSoul.supporter:
        activePrimary = const Color(0xFF8EA885);
        activeSecondary = const Color(0xFF9A7EB8);
        break;
      case CoachSoul.pro:
        activePrimary = const Color(0xFF00B2FF);
        activeSecondary = const Color(0xFFFF007A);
        break;
      case CoachSoul.teacher:
        activePrimary = const Color(0xFF00BFA5);
        activeSecondary = const Color(0xFFB0BEC5);
        break;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TODAY, $todayStr'.toUpperCase(),
                    style: GoogleFonts.syne(
                      color: activePrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome, ${state.profile.name}',
                    style: GoogleFonts.syne(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => onNavigateToTab?.call(3), // Navigate to Coach chat
                child: Hero(
                  tag: 'aura_orb_hero',
                  child: AuraOrb(
                    soul: state.profile.coachSoul,
                    state: OrbState.pulsing,
                    size: 44,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // AURA's Speech Note Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.messageCircle, color: activePrimary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.adaptationNotice ??
                        "You slept ${recovery.sleepHours.round()} hours—great job! Today is about a light walk to keep the momentum going.",
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // TODAY'S WORKOUT Section Header
          Text(
            "TODAY'S WORKOUT",
            style: GoogleFonts.syne(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // The Main Card (The "Move")
          GestureDetector(
            onTap: () => onNavigateToTab?.call(1, subIndex: 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    activePrimary.withOpacity(0.15),
                    activeSecondary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: activePrimary.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: activePrimary.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      workout.focusArea.toLowerCase().contains('walk') ? LucideIcons.footprints : LucideIcons.dumbbell,
                      color: activePrimary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    workout.title,
                    style: GoogleFonts.syne(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    workout.focusArea,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap card to view workout outline',
                    style: GoogleFonts.plusJakartaSans(
                      color: activePrimary.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // The "Fuel" Section (Progress Bars)
          Text(
            'FUEL',
            style: GoogleFonts.syne(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildFuelBar(
            context: context,
            label: 'Energy (Calories)',
            percentage: calPercent,
            caption: '${(calPercent * 100).round()}% fueled for the day.',
            activeColor: activePrimary,
            onTap: () => _showMetricDetails(
              context,
              'Energy Balance',
              '$totalCal / ${nutrition.targetCalories} kcal',
              [
                'Target: ${nutrition.targetCalories} kcal',
                'Consumed: $totalCal kcal',
                'Remaining: ${(nutrition.targetCalories - totalCal).clamp(0, 9999)} kcal',
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildFuelBar(
            context: context,
            label: 'Strength (Protein)',
            percentage: protPercent,
            caption: protPercent >= 1.0 ? 'Strength target achieved!' : 'Almost there! Need $remainingProt g more.',
            activeColor: activeSecondary,
            onTap: () => _showMetricDetails(
              context,
              'Strength Balance',
              '$totalProt / ${nutrition.targetProteinG} g Protein',
              [
                'Target: ${nutrition.targetProteinG} g',
                'Consumed: $totalProt g',
                'Remaining: $remainingProt g',
              ],
            ),
          ),
          const SizedBox(height: 28),

          // The "Body Check" Row
          Text(
            'BODY CHECK',
            style: GoogleFonts.syne(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBodyCheckBtn(
                context: context,
                icon: LucideIcons.moon,
                label: 'Sleep',
                onTap: () => _showSleepCheckIn(context, ref),
              ),
              _buildBodyCheckBtn(
                context: context,
                icon: LucideIcons.droplets,
                label: 'Water',
                onTap: () {
                  notifier.addWater(250);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added 250ml water!', style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.bold)),
                      backgroundColor: activePrimary,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              _buildBodyCheckBtn(
                context: context,
                icon: LucideIcons.activity,
                label: 'Aches',
                onTap: () => _showAchesCheckIn(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFuelBar({
    required BuildContext context,
    required String label,
    required double percentage,
    required String caption,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: GoogleFonts.syne(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const Icon(LucideIcons.chevronRight, color: Colors.white30, size: 16),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 10,
                width: double.infinity,
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              caption,
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyCheckBtn({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Icon(icon, color: Colors.white70, size: 22),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMetricDetails(BuildContext context, String title, String totalLabel, List<String> details) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F12),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.syne(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(totalLabel, style: GoogleFonts.syne(color: const Color(0xFF00FFA3), fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Divider(color: Colors.white10),
                const SizedBox(height: 8),
                ...details.map((d) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Text(d, style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14)),
                    )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.12)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onNavigateToTab?.call(1, subIndex: 1); // Open Nutrition sub-tab
                    },
                    child: Text('View Nutrition Logs', style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSleepCheckIn(BuildContext context, WidgetRef ref) {
    double tempSleep = ref.read(transformationEngineProvider).recovery.sleepHours;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F12),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Log Sleep', style: GoogleFonts.syne(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sleep Duration', style: GoogleFonts.plusJakartaSans(color: Colors.white70)),
                      Text('${tempSleep.toStringAsFixed(1)} hours', style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: tempSleep,
                    min: 4,
                    max: 12,
                    activeColor: const Color(0xFF9A7EB8),
                    onChanged: (v) => setModalState(() => tempSleep = v),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        final rec = ref.read(transformationEngineProvider).recovery;
                        ref.read(transformationEngineProvider.notifier).updateRecoveryCheckIn(
                          sleepHours: tempSleep,
                          sleepQuality: rec.sleepQuality,
                          muscleSoreness: rec.muscleSoreness,
                          energyLevel: rec.energyLevel,
                          stressLevel: rec.stressLevel,
                        );
                        Navigator.pop(context);
                      },
                      child: Text('Save Log', style: GoogleFonts.syne(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAchesCheckIn(BuildContext context, WidgetRef ref) {
    int tempSoreness = ref.read(transformationEngineProvider).recovery.muscleSoreness;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F12),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aches & Soreness', style: GoogleFonts.syne(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Muscle Soreness Level', style: GoogleFonts.plusJakartaSans(color: Colors.white70)),
                      Text('$tempSoreness / 10', style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: tempSoreness.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: const Color(0xFFFF007A),
                    onChanged: (v) => setModalState(() => tempSoreness = v.round()),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        final rec = ref.read(transformationEngineProvider).recovery;
                        ref.read(transformationEngineProvider.notifier).updateRecoveryCheckIn(
                          sleepHours: rec.sleepHours,
                          sleepQuality: rec.sleepQuality,
                          muscleSoreness: tempSoreness,
                          energyLevel: rec.energyLevel,
                          stressLevel: rec.stressLevel,
                        );
                        Navigator.pop(context);
                      },
                      child: Text('Save Log', style: GoogleFonts.syne(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
