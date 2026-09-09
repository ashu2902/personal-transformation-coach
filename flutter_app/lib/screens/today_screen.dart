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
import 'widgets/workout_day_detail_modal.dart';
import 'weekly_plan_screen.dart';
import '../services/app_version_service.dart';

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
        child: RefreshIndicator(
          color: auraTheme.primary,
          backgroundColor: auraTheme.surfaceCard,
          onRefresh: () => ref.read(transformationEngineProvider.notifier).refreshState(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                ref: ref,
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
                  showWorkoutConfirmationSheet(context, ref, parsed, targetDate: targetDate);
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
              const SizedBox(height: 24),

              // 7. DASHBOARD LATEST VERSION FOOTER
              _buildVersionFooter(context, ref, auraTheme),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildVersionFooter(BuildContext context, WidgetRef ref, AuraThemeExtension auraTheme) {
    final versionAsync = ref.watch(appVersionCheckProvider);

    return versionAsync.when(
      data: (result) {
        final isUpToDate = result.type == UpdateType.none;
        final displayVersion = result.latestVersion.isNotEmpty ? result.latestVersion : '1.0.1';

        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUpToDate)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: auraTheme.surfaceLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AuraColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AuraColors.actionGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Latest Version: v$displayVersion',
                          style: AuraTypography.bodySmall.copyWith(
                            color: AuraColors.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  InkWell(
                    onTap: () => AppVersionService.performUpdate(result.storeUrl),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AuraColors.actionGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AuraColors.actionGreen.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.arrowUpCircle, size: 13, color: AuraColors.actionGreen),
                          const SizedBox(width: 6),
                          Text(
                            'Update available: v${result.latestVersion} (Tap to update)',
                            style: AuraTypography.bodySmall.copyWith(
                              color: AuraColors.actionGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  'AURA Adaptive Wellness Coach',
                  style: AuraTypography.bodySmall.copyWith(
                    color: AuraColors.textTertiary.withValues(alpha: 0.45),
                    fontSize: 10,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: auraTheme.surfaceLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AuraColors.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AuraColors.actionGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Latest Version: v1.0.1',
                      style: AuraTypography.bodySmall.copyWith(
                        color: AuraColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'AURA Adaptive Wellness Coach',
                style: AuraTypography.bodySmall.copyWith(
                  color: AuraColors.textTertiary.withValues(alpha: 0.45),
                  fontSize: 10,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (_, __) => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'AURA Coach • v1.0.1',
            style: AuraTypography.bodySmall.copyWith(
              color: AuraColors.textTertiary.withValues(alpha: 0.5),
              fontSize: 11,
            ),
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
    required WidgetRef ref,
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
                    showWorkoutDayDetailSheet(
                      context: context,
                      ref: ref,
                      planDay: planDay,
                      actualWorkout: actualWorkout,
                      isToday: isToday,
                      isCompleted: isCompleted,
                      isSkipped: isSkipped,
                      dateStr: dayDateStr,
                      auraTheme: auraTheme,
                      onOpenWorkout: onOpenWorkout,
                    );
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
                            final state = ref.read(transformationEngineProvider);
                            final actualWorkout = state.getWorkoutForDate(dateStr);
                            final d = DateTime.tryParse(dateStr);
                            final weekdayIdx = d != null ? (d.weekday - 1).clamp(0, 6) : 0;
                            final planDay = (state.weeklyPlan != null && weekdayIdx < state.weeklyPlan!.days.length)
                                ? state.weeklyPlan!.days[weekdayIdx]
                                : null;
                            showWorkoutDayDetailSheet(
                              context: context,
                              ref: ref,
                              planDay: planDay,
                              actualWorkout: actualWorkout,
                              isToday: false,
                              isCompleted: false,
                              isSkipped: false,
                              dateStr: dateStr,
                              auraTheme: auraTheme,
                              onOpenWorkout: onOpenWorkout,
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
