import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/common/common.dart';
import 'widgets/aura_orb.dart';
import 'weekly_plan_screen.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  WeeklyDebrief? _debrief;
  bool _isLoadingDebrief = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeeklyDebrief();
    });
  }

  Future<void> _loadWeeklyDebrief() async {
    final state = ref.read(transformationEngineProvider);
    setState(() => _isLoadingDebrief = true);
    try {
      final debrief = await ref.read(transformationEngineProvider.notifier).aiService.generateWeeklyDebrief(state);
      if (mounted) {
        setState(() {
          _debrief = debrief;
          _isLoadingDebrief = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDebrief = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transformationEngineProvider);
    final auraTheme = context.auraTheme;
    final soul = state.profile.coachSoul;

    final currentWeight = state.profile.weightKg;
    final targetWeight = state.profile.targetWeightKg;
    final diff = (targetWeight - currentWeight).abs();

    // 1. LIVE DYNAMIC DATA: Weekly Tracking Status
    final recentDays = state.getRecentDaysTrackingStatus(7);
    final trackedCount = recentDays.where((d) => d.isTracked).length;

    // 2. LIVE DYNAMIC DATA: Weight Progress from Progress History
    final startWeight = state.progressHistory.isNotEmpty
        ? state.progressHistory.first.weightKg
        : (currentWeight > targetWeight ? currentWeight + 2.5 : currentWeight - 2.5);
    final totalGoalDelta = (targetWeight - startWeight).abs();
    final currentProgressDelta = (currentWeight - startWeight).abs();
    final progressRatio = state.profile.goal == GoalType.recomp
        ? (state.progressHistory.length / 30.0).clamp(0.05, 1.0) // 30-day active tracker
        : totalGoalDelta > 0
            ? (currentProgressDelta / totalGoalDelta).clamp(0.05, 1.0)
            : 1.0;

    return Scaffold(
      backgroundColor: auraTheme.scaffoldBackground,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.maxFluidContentWidth),
          child: RefreshIndicator(
            color: auraTheme.primary,
            backgroundColor: auraTheme.surfaceCard,
            onRefresh: () async {
              await ref.read(transformationEngineProvider.notifier).refreshState();
              _loadWeeklyDebrief();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Screen Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NARRATIVE INSIGHTS',
                          style: AuraTypography.sectionHeader.copyWith(
                            color: auraTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Weekly Debrief',
                          style: AuraTypography.displayMedium,
                        ),
                      ],
                    ),
                    AuraOrb(
                      soul: soul,
                      state: _isLoadingDebrief ? OrbState.pulsing : OrbState.idle,
                      size: 40,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 1. HERO: AI WEEKLY NARRATIVE DEBRIEF CARD
                _buildWeeklyDebriefHero(auraTheme, soul),
                const SizedBox(height: 20),

            // 2. LIVE MOMENTUM & CONSISTENCY (Dynamic from state)
            AuraCard(
              padding: const EdgeInsets.all(18),
              backgroundColor: auraTheme.surfaceCard,
              borderColor: AuraColors.borderSubtle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WEEKLY MOMENTUM',
                        style: AuraTypography.sectionHeader.copyWith(
                          color: AuraColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.checkCircle2, color: Theme.of(context).colorScheme.primary, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              '$trackedCount of 7 Completed',
                              style: AuraTypography.bodySmall.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: recentDays.map((dayStatus) {
                      final isToday = dayStatus.dayLabel == 'Today';
                      final initial = isToday ? 'T' : dayStatus.dayLabel.substring(0, 1);
                      final isDone = dayStatus.isTracked;
                      return _buildDayBubble(
                        initial,
                        isDone,
                        auraTheme,
                        label: isToday ? 'Today' : (isDone ? null : 'Rest'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: auraTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.heartHandshake, size: 16, color: auraTheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Rest days are active physiological recovery, not broken streaks.',
                            style: AuraTypography.bodySmall.copyWith(
                              color: AuraColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. PERSISTENT MODEL & CONSTRAINTS MEMORY (Live from UserProfile)
            AuraCard(
              padding: const EdgeInsets.all(18),
              backgroundColor: auraTheme.surfaceCard,
              borderColor: AuraColors.borderSubtle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.brain, color: auraTheme.primary, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'WHAT AURA HAS LEARNED ABOUT YOU',
                        style: AuraTypography.sectionHeader.copyWith(
                          color: AuraColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildMemoryChip(
                    icon: LucideIcons.dumbbell,
                    title: 'Active Gear',
                    subtitle: state.profile.equipmentList.isNotEmpty
                        ? state.profile.equipmentList.map((e) => e.name).join(', ')
                        : 'Bodyweight & Resistance Bands',
                  ),
                  const SizedBox(height: 10),
                  _buildMemoryChip(
                    icon: LucideIcons.shieldAlert,
                    title: 'Mobility Constraints',
                    subtitle: state.profile.activeInjuries.isNotEmpty
                        ? state.profile.activeInjuries.join(', ')
                        : 'None reported (Full range of motion)',
                  ),
                  const SizedBox(height: 10),
                  _buildMemoryChip(
                    icon: LucideIcons.utensils,
                    title: 'Dietary Baseline',
                    subtitle: state.profile.dietaryPreference.isNotEmpty
                        ? state.profile.dietaryPreference
                        : 'High-protein flexible balanced',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. SUPPORTING PROGRESS METRICS (Live from Progress History)
            AuraCard(
              padding: const EdgeInsets.all(18),
              backgroundColor: auraTheme.surfaceCard,
              borderColor: AuraColors.borderSubtle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROGRESS TRAJECTORY',
                            style: AuraTypography.sectionHeader.copyWith(
                              color: AuraColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currentWeight kg ➔ $targetWeight kg',
                            style: AuraTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: auraTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AuraColors.borderSubtle),
                        ),
                        child: Text(
                          state.profile.goal == GoalType.recomp
                              ? 'Body Recomposition Focus'
                              : '${diff.toStringAsFixed(1)} kg to target',
                          style: AuraTypography.bodySmall.copyWith(
                            color: auraTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress mini bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 8,
                      backgroundColor: auraTheme.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Start: ${startWeight.toStringAsFixed(1)} kg', style: AuraTypography.bodySmall.copyWith(color: AuraColors.textTertiary)),
                      Text('Target: ${targetWeight.toStringAsFixed(1)} kg', style: AuraTypography.bodySmall.copyWith(color: AuraColors.textTertiary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5. WEEKLY SCHEDULE DRILLDOWN CTA
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WeeklyPlanScreen()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: AuraCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: auraTheme.surfaceLight,
                borderColor: AuraColors.borderSubtle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: auraTheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(LucideIcons.calendarDays, color: auraTheme.primary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'View Adaptive Weekly Plan',
                              style: AuraTypography.titleMedium.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '7-day workout & training schedule',
                              style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(LucideIcons.chevronRight, color: AuraColors.textSecondary, size: 18),
                  ],
                ),
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildWeeklyDebriefHero(AuraThemeExtension auraTheme, CoachSoul soul) {
    if (_isLoadingDebrief && _debrief == null) {
      return AuraCard(
        padding: const EdgeInsets.all(20),
        backgroundColor: auraTheme.surfaceCard,
        borderColor: auraTheme.primary.withValues(alpha: 0.3),
        child: Column(
          children: [
            const SizedBox(height: 16),
            AuraOrb(soul: soul, state: OrbState.pulsing, size: 60),
            const SizedBox(height: 18),
            Text(
              'AURA is synthesizing your weekly debrief...',
              style: GoogleFonts.syne(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Connecting sleep, nutrition, and workout load telemetry',
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 12),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    final debrief = _debrief ??
        const WeeklyDebrief(
          headline: 'Weekly Synthesis & Trajectory',
          narrative: 'Your physical adaptations reflect steady commitment across this 7-day cycle. Recovery balance and nutrition compliance are stabilizing as your body integrates the weekly training volume.',
          keyAchievement: 'Consistent routine compliance',
          primaryNextStep: 'Lock in 8 hours of sleep and daily protein target',
          adherenceScore: 85,
        );

    return AuraCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: auraTheme.surfaceCard,
      borderColor: auraTheme.primary.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: auraTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.sparkles, color: auraTheme.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI WEEKLY SYNTHESIS',
                    style: AuraTypography.sectionHeader.copyWith(
                      color: auraTheme.primary,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.refreshCw,
                  size: 16,
                  color: _isLoadingDebrief ? auraTheme.primary : AuraColors.textSecondary,
                ),
                tooltip: 'Regenerate Debrief',
                onPressed: _isLoadingDebrief ? null : _loadWeeklyDebrief,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Headline
          Text(
            debrief.headline,
            style: GoogleFonts.syne(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Narrative in Coach Soul Voice
          Text(
            debrief.narrative,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFD4D4D8),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 14),

          // Key Achievement & Primary Next Step Badges
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00FFA3).withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.award, color: Color(0xFF00FFA3), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'ACHIEVEMENT',
                            style: GoogleFonts.syne(color: const Color(0xFF00FFA3), fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        debrief.keyAchievement,
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF60A5FA).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.arrowRightCircle, color: Color(0xFF60A5FA), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'NEXT WEEK FOCUS',
                            style: GoogleFonts.syne(color: const Color(0xFF60A5FA), fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        debrief.primaryNextStep,
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildDayBubble(String day, bool? completed, AuraThemeExtension theme, {String? label}) {
    Color bg = theme.surfaceLight;
    Color border = AuraColors.borderSubtle;
    Widget icon = Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuraColors.textSecondary));

    if (completed == true) {
      bg = Theme.of(context).colorScheme.primary.withValues(alpha: 0.2);
      border = Theme.of(context).colorScheme.primary.withValues(alpha: 0.6);
      icon = Icon(LucideIcons.check, size: 14, color: Theme.of(context).colorScheme.primary);
    } else if (completed == false) {
      bg = theme.surfaceLight;
      border = AuraColors.borderSubtle;
      icon = Text(day, style: const TextStyle(fontSize: 11, color: AuraColors.textTertiary));
    }

    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: border),
          ),
          child: Center(child: icon),
        ),
        const SizedBox(height: 4),
        Text(
          label ?? day,
          style: TextStyle(
            fontSize: 10,
            color: completed == true ? Theme.of(context).colorScheme.primary : AuraColors.textSecondary,
            fontWeight: label != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryChip({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AuraColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AuraColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AuraColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AuraColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AuraColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
