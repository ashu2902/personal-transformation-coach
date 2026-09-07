import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../providers/transformation_state.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';
import '../models/weekly_plan.dart';
import '../theme/theme.dart';
import '../widgets/common/common.dart';
import '../widgets/common/quick_coach_fab.dart';
import 'weekly_plan_screen.dart';

class TodayScreen extends ConsumerWidget {
  final Function(int tabIndex, {int subIndex})? onNavigateToTab;
  final VoidCallback? onOpenWorkout;

  const TodayScreen({
    super.key,
    this.onNavigateToTab,
    this.onOpenWorkout,
  });

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

    final totalCal = nutrition.meals.fold<num>(0, (sum, m) => sum + m.calories);
    final totalProt = nutrition.meals.fold<num>(0, (sum, m) => sum + m.proteinG);
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
        constraints: BoxConstraints(maxWidth: context.maxFluidContentWidth),
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
                  Expanded(
                    child: Column(
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. PILLAR 1 TOP: 7-DAY INTERACTIVE HORIZONTAL WEEK STRIP
              _buildInteractiveWeekStrip(
                context: context,
                state: state,
                weeklyPlan: weeklyPlan,
                recentTracking: recentTracking,
                auraTheme: auraTheme,
                now: now,
              ),
              const SizedBox(height: 16),

              // UNLOGGED WORKOUTS BANNER (Only after initial sync completes)
              if (!state.isInitializing && state.unloggedPreviousDays.isNotEmpty) ...[
                _buildUnloggedWorkoutsBanner(
                  context: context,
                  ref: ref,
                  unloggedDays: state.unloggedPreviousDays,
                  auraTheme: auraTheme,
                ),
                const SizedBox(height: 16),
              ],

              // 3. HERO ADAPTED WORKOUT CARD (The Core Centerpiece)
              AuraCard(
                padding: const EdgeInsets.all(22),
                backgroundColor: auraTheme.surfaceCard,
                borderColor: isAdapted
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.45)
                    : auraTheme.primary.withValues(alpha: 0.28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Workout Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isAdapted ? Theme.of(context).colorScheme.primary : auraTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  isAdapted ? "AURA'S ADAPTED WORKOUT" : "TODAY'S WORKOUT",
                                  style: AuraTypography.sectionHeader.copyWith(
                                    color: isAdapted ? Theme.of(context).colorScheme.primary : auraTheme.primary,
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isAdapted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'Adapted',
                              style: AuraTypography.bodySmall.copyWith(
                                color: Theme.of(context).colorScheme.primary,
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.dumbbell, size: 14, color: auraTheme.primary),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                workout.focusArea,
                                style: AuraTypography.bodyMedium.copyWith(
                                  color: AuraColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AuraColors.textTertiary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(LucideIcons.clock, size: 14, color: AuraColors.textTertiary),
                            const SizedBox(width: 6),
                            Text(
                              '${workout.estimatedDurationMin} min • ${workout.exercises.length} Exercises',
                              style: AuraTypography.bodySmall.copyWith(color: AuraColors.textTertiary),
                            ),
                          ],
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
                                  : workout.exercises.isEmpty
                                      ? (soul == CoachSoul.supporter
                                          ? "Today is a rest day! Focus on active recovery, stay hydrated, and let your muscles rebuild."
                                          : soul == CoachSoul.pro
                                              ? "Rest day. Recovery is part of the work. Optimize your sleep and nutrition today."
                                              : "Muscles grow during rest. Today's protocol requires lowered mechanical strain to facilitate tissue synthesis.")
                                      : (soul == CoachSoul.supporter
                                          ? "You slept ${recovery.sleepHours.round()}h—wonderful! Focus on steady, enjoyable tempo to build consistency today."
                                          : soul == CoachSoul.pro
                                              ? "Energy state optimal. Execute each set with crisp control, focusing on progressive intensity."
                                              : "Metabolic and nervous systems are primed based on ${recovery.sleepHours}h sleep. We target mechanical tension today."),
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
                      backgroundColor: isWorkoutDone ? AuraColors.surface2 : auraTheme.primary,
                      textColor: isWorkoutDone ? AuraColors.textSecondary : Colors.black,
                      width: double.infinity,
                      height: 52,
                      onPressed: isWorkoutDone
                          ? null
                          : () {
                              onOpenWorkout?.call();
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. "HEY COACH..." CONVERSATIONAL AI HUB (Positioned right below today's workout)
              AuraCard(
                padding: const EdgeInsets.all(20),
                backgroundColor: auraTheme.surfaceCard,
                borderColor: auraTheme.primary.withValues(alpha: 0.25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [auraTheme.primary, auraTheme.secondary],
                                  ),
                                ),
                                child: const Icon(LucideIcons.bot, size: 13, color: Colors.black),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'HEY COACH...',
                                  style: AuraTypography.sectionHeader.copyWith(
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                    color: auraTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: auraTheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            soul == CoachSoul.supporter
                                ? 'The Supporter'
                                : (soul == CoachSoul.pro ? 'The Pro' : 'The Teacher'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: auraTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Need an adjustment, exercise swap, or meal advice?',
                      style: AuraTypography.bodySmall.copyWith(
                        color: AuraColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Quick-Prompt Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildCoachPromptChip(
                          icon: LucideIcons.activity,
                          label: "I'm sore today — adapt my session",
                          onTap: () {
                            notifier.addChatMessage("I'm sore today — please adapt my session.");
                            onNavigateToTab?.call(1);
                          },
                          auraTheme: auraTheme,
                        ),
                        _buildCoachPromptChip(
                          icon: LucideIcons.timer,
                          label: 'Only have 20 mins today',
                          onTap: () {
                            notifier.addChatMessage("I only have 20 mins today — please adapt my workout.");
                            onNavigateToTab?.call(1);
                          },
                          auraTheme: auraTheme,
                        ),
                        _buildCoachPromptChip(
                          icon: LucideIcons.utensils,
                          label: 'What should I eat for dinner?',
                          onTap: () {
                            notifier.addChatMessage("What should I eat for dinner based on my remaining macros?");
                            onNavigateToTab?.call(1);
                          },
                          auraTheme: auraTheme,
                        ),
                        _buildCoachPromptChip(
                          icon: LucideIcons.gitFork,
                          label: 'Swap an exercise',
                          onTap: () {
                            notifier.addChatMessage("I want to swap an exercise from today's workout.");
                            onNavigateToTab?.call(1);
                          },
                          auraTheme: auraTheme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Direct Tap-to-Chat Action Bar
                    GestureDetector(
                      onTap: () => onNavigateToTab?.call(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: auraTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: auraTheme.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.messageSquare, size: 15, color: auraTheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Ask your Coach anything...',
                                style: AuraTypography.bodySmall.copyWith(
                                  color: AuraColors.textTertiary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: auraTheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.arrowRight, size: 12, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. NATURAL LANGUAGE FREE-TEXT WORKOUT LOGGING
              NaturalWorkoutQuickLogCard(
                auraTheme: auraTheme,
                onWorkoutParsed: (parsed, {targetDate}) {
                  _showWorkoutConfirmationSheet(context, ref, parsed, targetDate: targetDate);
                },
              ),
              const SizedBox(height: 20),

              // 6. DAILY FUEL & MACROS (Clean Full-Width Card)
              AuraCard(
                padding: const EdgeInsets.all(20),
                backgroundColor: auraTheme.surfaceCard,
                borderColor: AuraColors.borderSubtle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Icon(LucideIcons.utensils, size: 14, color: auraTheme.primary),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  "TODAY'S FUEL & NUTRITION",
                                  style: AuraTypography.sectionHeader.copyWith(
                                    fontSize: 11,
                                    letterSpacing: 1.1,
                                    color: auraTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: remainingCal > 0
                                ? auraTheme.primary.withValues(alpha: 0.12)
                                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            remainingCal > 0 ? '${NumberFormat('#,###').format(remainingCal)} kcal left' : 'Target Met',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: remainingCal > 0 ? auraTheme.primary : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Main Calories & Progress Summary
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          NumberFormat('#,###').format(totalCal),
                          style: AuraTypography.displayMedium.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '/ ${NumberFormat('#,###').format(nutrition.targetCalories)} kcal',
                          style: AuraTypography.bodyMedium.copyWith(
                            color: AuraColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Protein Progress Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Protein Target',
                          style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary, fontSize: 12),
                        ),
                        Text(
                          '$totalProt / ${nutrition.targetProteinG}g (${(protPercent * 100).round()}%)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuraColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: protPercent,
                        minHeight: 6,
                        backgroundColor: AuraColors.protein.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(AuraColors.protein),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Actions: AI Food Log + Hydration Quick Add
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: () => showQuickCoachModal(context, state.profile.coachSoul, contextTag: 'log_food'),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: auraTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AuraColors.borderSubtle),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.camera, size: 14, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Log Food with AI',
                                    style: AuraTypography.bodySmall.copyWith(
                                      color: AuraColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () {
                              notifier.addWater(250);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Logged +250ml water!'),
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                color: AuraColors.water.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AuraColors.water.withValues(alpha: 0.25)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.droplets, size: 14, color: AuraColors.water),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+250ml (${nutrition.waterMl}ml)',
                                    style: const TextStyle(
                                      color: AuraColors.water,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoachPromptChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AuraThemeExtension auraTheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AuraColors.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AuraColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: auraTheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AuraColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 7-DAY INTERACTIVE WEEK STRIP ───
  Widget _buildInteractiveWeekStrip({
    required BuildContext context,
    required TransformationEngineState state,
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
                    const SizedBox(width: 4),
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
              final dayDateStr = DateFormat('yyyy-MM-dd').format(dayDate);
              final isToday = dayDate.day == now.day && dayDate.month == now.month && dayDate.year == now.year;
              final isPast = dayDate.isBefore(DateTime(now.year, now.month, now.day));

              // Plan day info if available
              final planDay = (weeklyPlan != null && i < weeklyPlan.days.length) ? weeklyPlan.days[i] : null;
              final isRestDay = planDay?.isRestDay ?? (i == 3 || i == 6);

              // Check if completed in history
              final isCompleted = state.isWorkoutCompletedForDate(dayDateStr);
              final isSkipped = state.isWorkoutSkippedForDate(dayDateStr);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    final actualWorkout = state.getWorkoutForDate(dayDateStr);
                    _showDayDetailModal(context, planDay, actualWorkout, isToday, isCompleted, isSkipped, dayDateStr, auraTheme);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isToday
                          ? auraTheme.primary.withValues(alpha: 0.18)
                          : isCompleted
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.10)
                              : isSkipped
                                  ? AuraColors.surface2.withValues(alpha: 0.5)
                                  : AuraColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isToday
                            ? auraTheme.primary
                            : isCompleted
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
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
                        if (isCompleted)
                          Icon(LucideIcons.check, size: 10, color: Theme.of(context).colorScheme.primary)
                        else if (isSkipped)
                          const Icon(LucideIcons.minus, size: 9, color: AuraColors.textTertiary)
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

  void _showDayDetailModal(
    BuildContext context,
    WeeklyDayPlan? planDay,
    DailyWorkout? actualWorkout,
    bool isToday,
    bool isCompleted,
    bool isSkipped,
    String dateStr,
    AuraThemeExtension auraTheme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.surface1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final title = (isCompleted && actualWorkout != null)
            ? actualWorkout.title
            : (planDay?.title ?? (isSkipped ? 'Rest / Skipped Session' : 'Scheduled Session'));
        final focusArea = (isCompleted && actualWorkout != null)
            ? actualWorkout.focusArea
            : (planDay?.focusArea ?? (isSkipped ? 'Rest' : 'Workout'));
        final isRest = planDay?.isRestDay ?? false;

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
                      (planDay?.dayName ?? dateStr).toUpperCase(),
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
                      )
                    else if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.check, size: 11, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Completed',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                      )
                    else if (isSkipped)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AuraColors.surface2,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Skipped',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AuraColors.textTertiary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: AuraTypography.displaySmall),
                if (focusArea.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(focusArea, style: AuraTypography.bodyMedium.copyWith(color: AuraColors.textSecondary)),
                ],
                const SizedBox(height: 16),
                if (isCompleted && actualWorkout != null && actualWorkout.exercises.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Logged Workout Sets:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuraColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      ...actualWorkout.exercises.map((ex) {
                        final setsStr = ex.sets
                            .map((s) => '${s.targetWeightKg > 0 ? "${s.targetWeightKg.toStringAsFixed(s.targetWeightKg % 1 == 0 ? 0 : 1)}kg × " : ""}${s.targetReps} reps')
                            .join(', ');
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AuraColors.surface2,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AuraColors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ex.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AuraColors.textPrimary),
                                ),
                              ),
                              Text(
                                setsStr,
                                style: TextStyle(fontSize: 12, color: auraTheme.primary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  )
                else if (isRest && !isCompleted)
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
                else if (isSkipped)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AuraColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.minus, size: 18, color: AuraColors.textTertiary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Session was marked as skipped for this day.',
                            style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (planDay != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Planned Exercises:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuraColors.textSecondary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: planDay.exerciseNames.map((name) {
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
                if (isToday && !isRest)
                  AuraButton(
                    text: 'Start Workout',
                    variant: AuraButtonVariant.primary,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onOpenWorkout?.call();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── UNLOGGED WORKOUTS PROMPT BANNER ───
  Widget _buildUnloggedWorkoutsBanner({
    required BuildContext context,
    required WidgetRef ref,
    required List<Map<String, String>> unloggedDays,
    required AuraThemeExtension auraTheme,
  }) {
    return AuraCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: auraTheme.surfaceCard,
      borderColor: AuraColors.warningAmber.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AuraColors.warningAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(LucideIcons.alertCircle, size: 14, color: AuraColors.warningAmber),
              ),
              const SizedBox(width: 8),
              Text(
                'UNLOGGED SESSIONS THIS WEEK',
                style: AuraTypography.sectionHeader.copyWith(
                  color: AuraColors.warningAmber,
                  fontSize: 10,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your transformation calibration accurate by logging or marking past days.',
            style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Column(
            children: unloggedDays.map((day) {
              final dateStr = day['date']!;
              final dayLabel = '${day['dayName']} (${day['displayDate']})';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: auraTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AuraColors.borderSubtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dayLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AuraColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            ref.read(transformationEngineProvider.notifier).markPastWorkoutSkipped(dateStr);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Marked $dayLabel as Rest/Skipped.'),
                                backgroundColor: AuraColors.surface2,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AuraColors.surface2,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AuraColors.borderSubtle),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(fontSize: 11, color: AuraColors.textSecondary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            _showNaturalWorkoutLogModal(
                              context,
                              ref,
                              targetDate: dateStr,
                              initialDayName: day['dayName'],
                            );
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: auraTheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: auraTheme.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.sparkles, size: 10, color: auraTheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Log Workout',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: auraTheme.primary,
                                  ),
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
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showNaturalWorkoutLogModal(
    BuildContext context,
    WidgetRef ref, {
    String? targetDate,
    String? initialDayName,
  }) {
    final auraTheme = context.auraTheme;
    final controller = TextEditingController();
    bool isParsing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: auraTheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(LucideIcons.sparkles, size: 16, color: auraTheme.primary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            initialDayName != null
                                ? 'LOG WORKOUT FOR $initialDayName'
                                : 'EXPRESS AI WORKOUT LOG',
                            style: AuraTypography.sectionHeader.copyWith(
                              color: auraTheme.primary,
                              letterSpacing: 1.1,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 18, color: AuraColors.textSecondary),
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type your exercises, weights, and reps in natural language.',
                    style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    autofocus: true,
                    style: const TextStyle(color: AuraColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. 4 sets bench press 60kg for 10 reps, 3 sets pull-ups 8 reps, 20 mins incline treadmill walk',
                      hintStyle: const TextStyle(color: AuraColors.textTertiary, fontSize: 12),
                      filled: true,
                      fillColor: AuraColors.surface2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AuraColors.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: auraTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuraButton(
                    text: isParsing ? 'Analyzing with AI...' : 'Parse & Review',
                    icon: isParsing ? null : LucideIcons.arrowRight,
                    variant: AuraButtonVariant.primary,
                    backgroundColor: auraTheme.primary,
                    textColor: Colors.black,
                    width: double.infinity,
                    onPressed: isParsing
                        ? null
                        : () async {
                            final text = controller.text.trim();
                            if (text.isEmpty) return;

                            setModalState(() => isParsing = true);
                            try {
                              final parsed = await ref
                                  .read(transformationEngineProvider.notifier)
                                  .parseWorkoutFromText(text, targetDate: targetDate);
                              if (sheetCtx.mounted) {
                                Navigator.of(sheetCtx).pop();
                                _showWorkoutConfirmationSheet(
                                  context,
                                  ref,
                                  parsed,
                                  targetDate: targetDate,
                                );
                              }
                            } catch (e) {
                              setModalState(() => isParsing = false);
                              if (sheetCtx.mounted) {
                                ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to parse workout: $e'),
                                    backgroundColor: AuraColors.error,
                                  ),
                                );
                              }
                            }
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

  void _showWorkoutConfirmationSheet(
    BuildContext context,
    WidgetRef ref,
    DailyWorkout workout, {
    String? targetDate,
  }) {
    final auraTheme = context.auraTheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: auraTheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(LucideIcons.sparkles, size: 16, color: auraTheme.primary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CONFIRM & COMMIT WORKOUT',
                            style: AuraTypography.sectionHeader.copyWith(
                              color: auraTheme.primary,
                              letterSpacing: 1.1,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 18, color: AuraColors.textSecondary),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    workout.title,
                    style: AuraTypography.displaySmall.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workout.focusArea} • ${workout.exercises.length} Exercises • ~${workout.estimatedDurationMin} min',
                    style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: AuraColors.borderSubtle),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: workout.exercises.length,
                      itemBuilder: (context, index) {
                        final ex = workout.exercises[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: auraTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AuraColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ex.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AuraColors.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AuraColors.surface2,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      ex.targetMuscle,
                                      style: const TextStyle(fontSize: 10, color: AuraColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: ex.sets.map((s) {
                                  final weightStr =
                                      s.targetWeightKg > 0 ? '${s.targetWeightKg.toStringAsFixed(0)}kg × ' : '';
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: auraTheme.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: auraTheme.primary.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      'Set ${s.setNumber}: $weightStr${s.targetReps} reps',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: auraTheme.primary,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuraButton(
                    text: 'Confirm & Save Workout',
                    icon: LucideIcons.checkCheck,
                    variant: AuraButtonVariant.primary,
                    backgroundColor: auraTheme.primary,
                    textColor: Colors.black,
                    width: double.infinity,
                    height: 50,
                    onPressed: () async {
                      await ref
                          .read(transformationEngineProvider.notifier)
                          .confirmAndSaveParsedWorkout(workout, targetDate: targetDate);
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Logged "${workout.title}" successfully!'),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
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

class NaturalWorkoutQuickLogCard extends ConsumerStatefulWidget {
  final AuraThemeExtension auraTheme;
  final Function(DailyWorkout workout, {String? targetDate}) onWorkoutParsed;

  const NaturalWorkoutQuickLogCard({
    super.key,
    required this.auraTheme,
    required this.onWorkoutParsed,
  });

  @override
  ConsumerState<NaturalWorkoutQuickLogCard> createState() => _NaturalWorkoutQuickLogCardState();
}

class _NaturalWorkoutQuickLogCardState extends ConsumerState<NaturalWorkoutQuickLogCard> {
  final TextEditingController _controller = TextEditingController();
  bool _isParsing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isParsing = true);
    try {
      final parsed =
          await ref.read(transformationEngineProvider.notifier).parseWorkoutFromText(text);
      if (mounted) {
        setState(() => _isParsing = false);
        _controller.clear();
        widget.onWorkoutParsed(parsed);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isParsing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to parse workout: $e'),
            backgroundColor: AuraColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuraCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: widget.auraTheme.surfaceCard,
      borderColor: AuraColors.borderSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(LucideIcons.sparkles, size: 14, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'EXPRESS AI WORKOUT LOG',
                    style: AuraTypography.sectionHeader.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 10,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              if (_isParsing)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Did a different workout? Type what you did and let AURA fill the sets.',
            style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.auraTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AuraColors.borderSubtle),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 13, color: AuraColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'e.g. 4 sets bench 70kg 10 reps, 3 sets pullups',
                      hintStyle: TextStyle(fontSize: 11, color: AuraColors.textTertiary),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _isParsing ? null : _submit,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 38,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.arrowRight, size: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
