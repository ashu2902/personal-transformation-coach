import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/common/common.dart';
import 'widgets/aura_orb.dart';
import 'weekly_plan_screen.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final progressRatio = totalGoalDelta > 0
        ? (currentProgressDelta / totalGoalDelta).clamp(0.08, 1.0)
        : 1.0;

    // 3. LIVE DYNAMIC DATA: Algorithmic Pattern Synthesis
    final pattern = _generateDynamicPattern(
      trackedCount: trackedCount,
      soul: soul,
      avgSleep: state.recovery.sleepHours,
      recoveryScore: state.recovery.recoveryScore,
    );

    return Scaffold(
      backgroundColor: auraTheme.scaffoldBackground,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.maxFluidContentWidth),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                      'INSIGHTS & PATTERNS',
                      style: AuraTypography.sectionHeader.copyWith(
                        color: auraTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Learned by AURA',
                      style: AuraTypography.displayMedium,
                    ),
                  ],
                ),
                AuraOrb(
                  soul: soul,
                  state: OrbState.idle,
                  size: 40,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 1. HERO INSIGHT CARD (Dynamic Interpretation First)
            AuraCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: auraTheme.surfaceCard,
              borderColor: auraTheme.primary.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: auraTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(LucideIcons.sparkles, color: auraTheme.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'CORE PATTERN IDENTIFIED',
                        style: AuraTypography.sectionHeader.copyWith(
                          color: auraTheme.primary,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pattern.quote,
                    style: AuraTypography.titleLarge.copyWith(
                      height: 1.35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pattern.explanation,
                    style: AuraTypography.bodyMedium.copyWith(
                      color: AuraColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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
                          color: AuraColors.actionGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.checkCircle2, color: AuraColors.actionGreen, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              '$trackedCount of 7 Completed',
                              style: AuraTypography.bodySmall.copyWith(
                                color: AuraColors.actionGreen,
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
                          '${diff.toStringAsFixed(1)} kg to target',
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
                      valueColor: const AlwaysStoppedAnimation<Color>(AuraColors.actionGreen),
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
                            color: auraTheme.primary.withOpacity(0.15),
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
                              '7-day prescription schedule',
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  ),
);
  }

  ({String quote, String explanation}) _generateDynamicPattern({
    required int trackedCount,
    required CoachSoul soul,
    required double avgSleep,
    required int recoveryScore,
  }) {
    String quote;
    String explanation;

    if (trackedCount >= 5) {
      quote = "“You are maintaining strong momentum with $trackedCount of 7 sessions completed. Adherence rate is at ${((trackedCount / 7) * 100).round()}%.”";
      switch (soul) {
        case CoachSoul.supporter:
          explanation = "Your routine is blossoming beautifully! Remember to listen to your body and celebrate this incredible consistency.";
          break;
        case CoachSoul.pro:
          explanation = "Weekly execution is locked in. Maintain this baseline load and ensure nutrition targets match training volume.";
          break;
        case CoachSoul.teacher:
          explanation = "Consistent progressive tension accelerates muscular hypertrophy and neuromuscular recruitment efficiency.";
          break;
      }
    } else if (trackedCount >= 2) {
      quote = "“You are establishing a steady baseline with $trackedCount sessions tracked this week. Recovery balance is healthy.”";
      switch (soul) {
        case CoachSoul.supporter:
          explanation = "Every workout completed is a victory. Focus on today's small action without worrying about perfection.";
          break;
        case CoachSoul.pro:
          explanation = "Solid foundation. Locking in your next session will push you into optimal weekly transformation velocity.";
          break;
        case CoachSoul.teacher:
          explanation = "Intermittent recovery allows structural tendon repair and glycogen replenishment before heavy loading.";
          break;
      }
    } else {
      quote = "“Low-friction phase: $trackedCount session logged this week. Today is a great opportunity to reactivate momentum.”";
      switch (soul) {
        case CoachSoul.supporter:
          explanation = "No pressure at all. Even a 10-minute stretch or light walk today helps you feel refreshed and connected.";
          break;
        case CoachSoul.pro:
          explanation = "Let's re-engage today. A 25-minute focused session will re-establish your forward trajectory.";
          break;
        case CoachSoul.teacher:
          explanation = "Brief muscular contractions increase GLUT-4 translocation and insulin sensitivity for up to 48 hours.";
          break;
      }
    }

    return (quote: quote, explanation: explanation);
  }

  Widget _buildDayBubble(String day, bool? completed, AuraThemeExtension theme, {String? label}) {
    Color bg = theme.surfaceLight;
    Color border = AuraColors.borderSubtle;
    Widget icon = Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuraColors.textSecondary));

    if (completed == true) {
      bg = AuraColors.actionGreen.withOpacity(0.2);
      border = AuraColors.actionGreen.withOpacity(0.6);
      icon = const Icon(LucideIcons.check, size: 14, color: AuraColors.actionGreen);
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
            color: completed == true ? AuraColors.actionGreen : AuraColors.textSecondary,
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
