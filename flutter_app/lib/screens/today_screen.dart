import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/common/common.dart';
import 'widgets/aura_orb.dart';
import 'weekly_plan_screen.dart';

class TodayScreen extends ConsumerWidget {
  final Function(int tabIndex, {int subIndex})? onNavigateToTab;

  const TodayScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);
    final notifier = ref.read(transformationEngineProvider.notifier);
    final auraTheme = context.auraTheme;
    final soul = state.profile.coachSoul;

    final now = DateTime.now();
    final todayStr = DateFormat('EEEE, MMMM d').format(now);

    final workout = state.workout;
    final nutrition = state.nutrition;
    final recovery = state.recovery;

    final totalCal = nutrition.meals.fold(0, (sum, m) => sum + m.calories);
    final totalProt = nutrition.meals.fold(0, (sum, m) => sum + m.proteinG);
    final remainingCal = (nutrition.targetCalories - totalCal).clamp(0, 9999);
    final protPercent = (totalProt / (nutrition.targetProteinG > 0 ? nutrition.targetProteinG : 150)).clamp(0.0, 1.0);

    final isWelcomeNotice = state.adaptationNotice != null &&
        (state.adaptationNotice!.contains('Welcome back') ||
            state.adaptationNotice!.contains('Welcome to AURA') ||
            state.adaptationNotice!.contains('synced'));
    final isAdapted = !isWelcomeNotice &&
        state.adaptationNotice != null &&
        state.adaptationNotice!.isNotEmpty;
    final isWorkoutDone = workout.status == WorkoutStatus.completed;

    final weeklyPlan = state.weeklyPlan;
    final recentTracking = state.getRecentDaysTrackingStatus(7);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 120.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP BAR: Date, Greeting, Ambient AURA Orb
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todayStr.toUpperCase(),
                        style: AuraTypography.sectionHeader.copyWith(
                          color: auraTheme.primary,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Good ${now.hour < 12 ? 'morning' : now.hour < 17 ? 'afternoon' : 'evening'}, ${state.profile.name}',
                        style: AuraTypography.displayMedium.copyWith(fontSize: 22),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => onNavigateToTab?.call(3), // Navigate to Coach chat
                    child: Hero(
                      tag: 'aura_orb_hero',
                      child: AuraOrb(
                        soul: soul,
                        state: isAdapted ? OrbState.adapting : OrbState.idle,
                        size: 42,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. PILLAR 1 TOP: 7-DAY INTERACTIVE HORIZONTAL WEEK STRIP
              _buildInteractiveWeekStrip(
                context: context,
                weeklyPlan: weeklyPlan,
                recentTracking: recentTracking,
                auraTheme: auraTheme,
                now: now,
              ),
              const SizedBox(height: 20),

              // 3. HERO ADAPTED PRESCRIPTION CARD (The Core Centerpiece)
              AuraCard(
                padding: const EdgeInsets.all(22),
                backgroundColor: auraTheme.surfaceCard,
                borderColor: isAdapted
                    ? AuraColors.actionGreen.withValues(alpha: 0.45)
                    : auraTheme.primary.withValues(alpha: 0.28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prescription Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isAdapted ? AuraColors.actionGreen : auraTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isAdapted ? "AURA'S ADAPTED PRESCRIPTION" : "TODAY'S PRESCRIPTION",
                              style: AuraTypography.sectionHeader.copyWith(
                                color: isAdapted ? AuraColors.actionGreen : auraTheme.primary,
                                fontSize: 11,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (isAdapted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AuraColors.actionGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AuraColors.actionGreen.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'Adapted',
                              style: AuraTypography.bodySmall.copyWith(
                                color: AuraColors.actionGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Workout Title
                    Text(
                      workout.title,
                      style: AuraTypography.displayMedium.copyWith(
                        fontSize: 23,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(LucideIcons.dumbbell, size: 14, color: auraTheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          workout.focusArea,
                          style: AuraTypography.bodyMedium.copyWith(
                            color: AuraColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AuraColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(LucideIcons.clock, size: 14, color: AuraColors.textTertiary),
                        const SizedBox(width: 6),
                        Text(
                          '${workout.estimatedDurationMin} min • ${workout.exercises.length} Exercises',
                          style: AuraTypography.bodySmall.copyWith(color: AuraColors.textTertiary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Dynamic Coach Reasoning Bubble
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: auraTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AuraColors.borderSubtle),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(LucideIcons.sparkles, size: 16, color: auraTheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isAdapted
                                  ? state.adaptationNotice!
                                  : (soul == CoachSoul.supporter
                                      ? "You slept ${recovery.sleepHours.round()}h—wonderful! Focus on steady, enjoyable tempo to build consistency today."
                                      : soul == CoachSoul.pro
                                          ? "Energy state optimal. Execute each set with crisp control, focusing on progressive intensity."
                                          : "Targeting compound muscular recruitment and joint stability based on your recovery baseline."),
                              style: AuraTypography.bodySmall.copyWith(
                                color: AuraColors.textPrimary.withValues(alpha: 0.95),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Primary Action CTA
                    AuraButton(
                      text: isWorkoutDone ? "Workout Completed!" : "Start Today's Session",
                      icon: isWorkoutDone ? LucideIcons.checkCheck : LucideIcons.play,
                      variant: isWorkoutDone ? AuraButtonVariant.secondary : AuraButtonVariant.primary,
                      backgroundColor: isWorkoutDone ? AuraColors.surface2 : AuraColors.actionGreen,
                      textColor: isWorkoutDone ? AuraColors.textSecondary : Colors.black,
                      width: double.infinity,
                      height: 52,
                      onPressed: isWorkoutDone
                          ? null
                          : () {
                              onNavigateToTab?.call(1); // Open Workout Session Mode
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. DUAL GLANCEABLE WIDGETS (Fuel + Recovery Grid)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT: FUEL BALANCE
                  Expanded(
                    child: AuraCard(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: auraTheme.surfaceCard,
                      borderColor: AuraColors.borderSubtle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "TODAY'S FUEL",
                                style: AuraTypography.sectionHeader.copyWith(
                                  fontSize: 10,
                                  color: AuraColors.textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => onNavigateToTab?.call(3),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AuraColors.actionGreen.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(LucideIcons.camera, size: 14, color: AuraColors.actionGreen),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            remainingCal > 0
                                ? "${NumberFormat('#,###').format(remainingCal)} kcal"
                                : "Target Met",
                            style: AuraTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            remainingCal > 0 ? "remaining" : "calories logged",
                            style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 12),

                          // Protein Mini Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Protein', style: TextStyle(fontSize: 11, color: AuraColors.textSecondary)),
                              Text('$totalProt / ${nutrition.targetProteinG}g',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AuraColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: protPercent,
                              minHeight: 5,
                              backgroundColor: AuraColors.protein.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(AuraColors.protein),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Quick Log Food Action
                          InkWell(
                            onTap: () => onNavigateToTab?.call(3),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                              decoration: BoxDecoration(
                                color: auraTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AuraColors.borderSubtle),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.plus, size: 12, color: AuraColors.actionGreen),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Log Food with AI',
                                    style: AuraTypography.bodySmall.copyWith(
                                      color: AuraColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // RIGHT: RECOVERY READINESS
                  Expanded(
                    child: AuraCard(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: auraTheme.surfaceCard,
                      borderColor: AuraColors.borderSubtle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "READINESS",
                                style: AuraTypography.sectionHeader.copyWith(
                                  fontSize: 10,
                                  color: AuraColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${recovery.recoveryScore}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: recovery.recoveryScore >= 75
                                      ? AuraColors.actionGreen
                                      : AuraColors.warningAmber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Sleep Quick Tap
                          InkWell(
                            onTap: () => _showSleepModal(context, ref),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.moon, size: 14, color: AuraColors.recovery),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${recovery.sleepHours.toStringAsFixed(1)}h sleep',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AuraColors.textPrimary)),
                                        Text(recovery.sleepHours >= 7 ? 'Optimal' : 'Low rest',
                                            style: const TextStyle(fontSize: 10, color: AuraColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  const Icon(LucideIcons.edit2, size: 12, color: AuraColors.textTertiary),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 12, color: AuraColors.borderSubtle),

                          // Hydration Quick Tap
                          InkWell(
                            onTap: () {
                              notifier.addWater(250);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Logged +250ml water!'),
                                  backgroundColor: AuraColors.actionGreen,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.droplets, size: 14, color: AuraColors.water),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${nutrition.waterMl} ml',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AuraColors.textPrimary)),
                                        const Text('+250ml quick add',
                                            style: TextStyle(fontSize: 10, color: AuraColors.water)),
                                      ],
                                    ),
                                  ),
                                  const Icon(LucideIcons.plusCircle, size: 14, color: AuraColors.water),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 12, color: AuraColors.borderSubtle),

                          // Soreness Quick Tap
                          InkWell(
                            onTap: () => _showSorenessModal(context, ref),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.activity, size: 14, color: AuraColors.warningAmber),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(recovery.muscleSoreness > 0 ? '${recovery.muscleSoreness}/10 soreness' : 'No Soreness',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AuraColors.textPrimary)),
                                        const Text('Tap to rate',
                                            style: TextStyle(fontSize: 10, color: AuraColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  const Icon(LucideIcons.chevronRight, size: 12, color: AuraColors.textTertiary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 7-DAY INTERACTIVE WEEK STRIP ───
  Widget _buildInteractiveWeekStrip({
    required BuildContext context,
    required WeeklyPlan? weeklyPlan,
    required List<DayTrackingStatus> recentTracking,
    required AuraThemeExtension auraTheme,
    required DateTime now,
  }) {
    // Find Monday of the current week
    final int currentWeekday = now.weekday; // 1 = Mon, 7 = Sun
    final monday = now.subtract(Duration(days: currentWeekday - 1));

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return AuraCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      backgroundColor: auraTheme.surfaceCard,
      borderColor: AuraColors.borderSubtle,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'THIS WEEK',
                style: AuraTypography.sectionHeader.copyWith(
                  fontSize: 10,
                  color: AuraColors.textSecondary,
                  letterSpacing: 1.1,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WeeklyPlanScreen()),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'View 7-Day Plan',
                      style: AuraTypography.bodySmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: auraTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(LucideIcons.chevronRight, size: 13, color: auraTheme.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final dayDate = monday.add(Duration(days: i));
              final isToday = dayDate.day == now.day && dayDate.month == now.month && dayDate.year == now.year;
              final isPast = dayDate.isBefore(DateTime(now.year, now.month, now.day));

              // Plan day info if available
              final planDay = (weeklyPlan != null && i < weeklyPlan.days.length) ? weeklyPlan.days[i] : null;
              final isRestDay = planDay?.isRestDay ?? (i == 3 || i == 6);

              // Check if completed in history
              final isTracked = recentTracking.any((t) =>
                  t.date == DateFormat('yyyy-MM-dd').format(dayDate) && t.isTracked);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (planDay != null) {
                      _showDayDetailModal(context, planDay, isToday, auraTheme);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isToday
                          ? auraTheme.primary.withValues(alpha: 0.18)
                          : isTracked
                              ? AuraColors.actionGreen.withValues(alpha: 0.10)
                              : AuraColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isToday
                            ? auraTheme.primary
                            : isTracked
                                ? AuraColors.actionGreen.withValues(alpha: 0.3)
                                : AuraColors.borderSubtle,
                        width: isToday ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          dayLabels[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isToday ? auraTheme.primary : AuraColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${dayDate.day}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                            color: isToday ? Colors.white : AuraColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Status Dot / Indicator
                        if (isTracked)
                          const Icon(LucideIcons.check, size: 10, color: AuraColors.actionGreen)
                        else if (isRestDay)
                          const Icon(LucideIcons.moon, size: 9, color: AuraColors.recovery)
                        else if (isPast)
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AuraColors.textTertiary,
                            ),
                          )
                        else
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isToday ? auraTheme.primary : AuraColors.borderSubtle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showDayDetailModal(BuildContext context, WeeklyDayPlan day, bool isToday, AuraThemeExtension auraTheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.surface1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      day.dayName.toUpperCase(),
                      style: AuraTypography.sectionHeader.copyWith(color: auraTheme.primary),
                    ),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: auraTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: auraTheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Active Day',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: auraTheme.primary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(day.title, style: AuraTypography.displaySmall),
                const SizedBox(height: 4),
                Text(day.focusArea, style: AuraTypography.bodyMedium.copyWith(color: AuraColors.textSecondary)),
                const SizedBox(height: 16),
                if (day.isRestDay)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AuraColors.recovery.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.moon, size: 18, color: AuraColors.recovery),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Rest & Recovery Protocol: High hydration, light walking, and mobility.',
                            style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Planned Exercises:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuraColors.textSecondary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: day.exerciseNames.map((name) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AuraColors.surface2,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AuraColors.borderSubtle),
                            ),
                            child: Text(name, style: const TextStyle(fontSize: 12, color: AuraColors.textPrimary)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                if (isToday && !day.isRestDay)
                  AuraButton(
                    text: 'Start Workout',
                    variant: AuraButtonVariant.primary,
                    backgroundColor: AuraColors.actionGreen,
                    textColor: Colors.black,
                    width: double.infinity,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      onNavigateToTab?.call(1);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSleepModal(BuildContext context, WidgetRef ref) {
    double tempSleep = ref.read(transformationEngineProvider).recovery.sleepHours;
    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.surface1,
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
                  Text('Log Sleep', style: AuraTypography.displaySmall),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Duration', style: TextStyle(color: AuraColors.textSecondary)),
                      Text('${tempSleep.toStringAsFixed(1)} hours', style: AuraTypography.titleMedium),
                    ],
                  ),
                  Slider(
                    value: tempSleep,
                    min: 4,
                    max: 12,
                    divisions: 16,
                    activeColor: AuraColors.actionGreen,
                    inactiveColor: AuraColors.borderSubtle,
                    onChanged: (val) => setModalState(() => tempSleep = val),
                  ),
                  const SizedBox(height: 16),
                  AuraButton(
                    text: 'Save Sleep',
                    variant: AuraButtonVariant.primary,
                    backgroundColor: AuraColors.actionGreen,
                    textColor: Colors.black,
                    width: double.infinity,
                    onPressed: () {
                      ref.read(transformationEngineProvider.notifier).updateSleep(tempSleep);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSorenessModal(BuildContext context, WidgetRef ref) {
    int tempSoreness = ref.read(transformationEngineProvider).recovery.muscleSoreness;
    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.surface1,
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
                  Text('Rate Muscle Soreness', style: AuraTypography.displaySmall),
                  const SizedBox(height: 8),
                  Text('AURA will adjust workout volume if soreness is elevated.', style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      final rating = (index + 1) * 2;
                      final isSelected = tempSoreness == rating;
                      return GestureDetector(
                        onTap: () => setModalState(() => tempSoreness = rating),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? AuraColors.actionGreen : AuraColors.surface2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? AuraColors.actionGreen : AuraColors.borderSubtle),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : AuraColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  AuraButton(
                    text: 'Save Soreness',
                    variant: AuraButtonVariant.primary,
                    backgroundColor: AuraColors.actionGreen,
                    textColor: Colors.black,
                    width: double.infinity,
                    onPressed: () {
                      ref.read(transformationEngineProvider.notifier).updateSoreness(tempSoreness);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
