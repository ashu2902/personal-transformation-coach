import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';
import '../models/weekly_plan.dart';
import '../theme/theme.dart';
import '../widgets/common/common.dart';

class WeeklyPlanScreen extends ConsumerWidget {
  const WeeklyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);
    final plan = state.weeklyPlan;
    final isLoading = state.isAiThinking;
    final auraTheme = context.auraTheme;
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    return Scaffold(
      backgroundColor: auraTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: auraTheme.scaffoldBackground,
        elevation: 0,
        title: Text(
          'Weekly Plan',
          style: AuraTypography.titleLarge,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.maxFluidContentWidth),
          child: RefreshIndicator(
            color: auraTheme.primary,
            backgroundColor: auraTheme.surfaceCard,
            onRefresh: () => ref.read(transformationEngineProvider.notifier).refreshState(),
            child: plan == null
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: _buildEmptyState(context, ref, isLoading),
                    ),
                  )
                : _buildPlanView(context, ref, plan, todayStr, isLoading),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, bool isLoading) {
    final auraTheme = context.auraTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: auraTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                LucideIcons.calendarDays,
                size: 48,
                color: auraTheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Weekly Plan Yet',
              style: AuraTypography.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a personalized 7-day workout and nutrition plan tailored to your goals.',
              textAlign: TextAlign.center,
              style: AuraTypography.bodyMedium.copyWith(height: 1.5),
            ),
            const SizedBox(height: 32),
            AuraButton(
              text: 'Generate My Plan',
              icon: LucideIcons.sparkles,
              isLoading: isLoading,
              width: double.infinity,
              height: 52,
              onPressed: () {
                ref.read(transformationEngineProvider.notifier).generateWeeklyPlan();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanView(BuildContext context, WidgetRef ref, WeeklyPlan plan, String todayStr, bool isLoading) {
    final auraTheme = context.auraTheme;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Week label
                AuraStatBadge(
                  label: '${plan.weekId}  •  ${_formatDate(plan.startDate)} – ${_formatDate(plan.endDate)}',
                  color: auraTheme.primary,
                ),
                const SizedBox(height: 14),
                // Overview
                Text(
                  plan.overview,
                  style: AuraTypography.bodyLarge.copyWith(color: AuraColors.textPrimary.withValues(alpha: 0.85)),
                ),
                if (plan.coachNote != null) ...[
                  const SizedBox(height: 12),
                  AuraCard(
                    padding: const EdgeInsets.all(14),
                    borderRadius: 12,
                    backgroundColor: auraTheme.secondary.withValues(alpha: 0.06),
                    borderColor: auraTheme.secondary.withValues(alpha: 0.15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.messageSquare, size: 14, color: auraTheme.secondary.withValues(alpha: 0.7)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            plan.coachNote!,
                            style: AuraTypography.bodySmall.copyWith(
                              color: AuraColors.textSecondary,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Regenerate button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            ref.read(transformationEngineProvider.notifier).generateWeeklyPlan();
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(LucideIcons.refreshCw, size: 14, color: auraTheme.primary),
                    label: Text(
                      isLoading ? 'Generating...' : 'Regenerate',
                      style: AuraTypography.bodySmall.copyWith(color: auraTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Day cards
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final day = plan.days[index];
                final isToday = day.date == todayStr;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 250 + (index * 50)),
                  curve: AuraCurves.fluidEaseOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 12 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildDayCard(context, ref, day, isToday, todayStr),
                );
              },
              childCount: plan.days.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(BuildContext context, WidgetRef ref, WeeklyDayPlan day, bool isToday, String todayStr) {
    final auraTheme = context.auraTheme;
    final state = ref.watch(transformationEngineProvider);
    final isPast = day.date.compareTo(todayStr) < 0;
    final isCompleted = state.isWorkoutCompletedForDate(day.date);
    final isSkipped = state.isWorkoutSkippedForDate(day.date);
    final actualWorkout = state.getWorkoutForDate(day.date);

    final displayTitle = (isCompleted && actualWorkout != null) ? actualWorkout.title : day.title;
    final displayFocusArea = (isCompleted && actualWorkout != null) ? actualWorkout.focusArea : day.focusArea;
    final displayExercises = (isCompleted && actualWorkout != null && actualWorkout.exercises.isNotEmpty)
        ? actualWorkout.exercises.map((e) => e.name).toList()
        : day.exerciseNames;

    return AuraCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      borderColor: isToday ? auraTheme.primary.withValues(alpha: 0.4) : AuraColors.borderSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header row
          Row(
            children: [
              // Day name + date
              Expanded(
                child: Row(
                  children: [
                    Text(
                      day.dayName,
                      style: AuraTypography.titleMedium.copyWith(
                        color: isToday ? auraTheme.primary : AuraColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(day.date),
                      style: AuraTypography.bodySmall.copyWith(color: AuraColors.textTertiary),
                    ),
                  ],
                ),
              ),
              if (isToday)
                AuraStatBadge(
                  label: 'TODAY',
                  color: auraTheme.primary,
                  isFilled: true,
                )
              else if (isCompleted)
                AuraStatBadge(
                  label: 'COMPLETED',
                  icon: LucideIcons.check,
                  color: Theme.of(context).colorScheme.primary,
                )
              else if (isSkipped)
                const AuraStatBadge(
                  label: 'SKIPPED',
                  icon: LucideIcons.minus,
                  color: AuraColors.textTertiary,
                )
              else if (day.isRestDay)
                AuraStatBadge(
                  label: displayExercises.isNotEmpty ? 'ACTIVE RECOVERY' : 'REST',
                  icon: displayExercises.isNotEmpty ? LucideIcons.activity : LucideIcons.moonStar,
                  color: displayExercises.isNotEmpty ? auraTheme.secondary : AuraColors.textTertiary,
                )
              else if (isPast)
                const AuraStatBadge(
                  label: 'MISSED',
                  color: AuraColors.textTertiary,
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Title + focus area
          Text(
            displayTitle,
            style: AuraTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: (day.isRestDay && !isCompleted && displayExercises.isEmpty) ? AuraColors.textDisabled : AuraColors.textPrimary.withValues(alpha: 0.85),
            ),
          ),
          if (displayFocusArea.isNotEmpty && (!day.isRestDay || isCompleted || displayExercises.isNotEmpty)) ...[
            const SizedBox(height: 4),
            Text(
              displayFocusArea,
              style: AuraTypography.bodySmall.copyWith(color: auraTheme.secondary.withValues(alpha: 0.8)),
            ),
          ],
          // Exercise chips
          if (displayExercises.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: displayExercises.map((name) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: auraTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    name,
                    style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary, fontSize: 11),
                  ),
                );
              }).toList(),
            ),
          ],
          // Nutrition focus
          if (day.nutritionFocus != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(LucideIcons.utensils, size: 12, color: auraTheme.primary.withValues(alpha: 0.5)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    day.nutritionFocus!,
                    style: AuraTypography.bodySmall.copyWith(
                      color: AuraColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[d.month - 1]} ${d.day}';
    } catch (_) {
      return dateStr;
    }
  }
}
