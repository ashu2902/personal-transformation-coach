import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/workout.dart';
import '../../models/weekly_plan.dart';
import '../../providers/transformation_state.dart';
import '../../theme/theme.dart';
import '../../widgets/common/common.dart';

/// Comprehensive modal bottom sheet allowing users to view, complete,
/// backfill, skip, or undo workout tracking for any day of the week.
void showWorkoutDayDetailSheet({
  required BuildContext context,
  required WidgetRef ref,
  required WeeklyDayPlan? planDay,
  required DailyWorkout? actualWorkout,
  required bool isToday,
  required bool isCompleted,
  required bool isSkipped,
  required String dateStr,
  required AuraThemeExtension auraTheme,
  VoidCallback? onOpenWorkout,
}) {
  final nowStr = DateTime.now().toIso8601String().split('T')[0];
  final isPast = dateStr.compareTo(nowStr) < 0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AuraColors.surface1,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
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
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Day name + Status Badge
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
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: auraTheme.primary,
                        ),
                      ),
                    )
                  else if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.check, size: 11, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
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
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AuraColors.textTertiary,
                        ),
                      ),
                    )
                  else if (isRest)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AuraColors.recovery.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Rest Day',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AuraColors.recovery,
                        ),
                      ),
                    )
                  else if (isPast)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AuraColors.warningAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Missed / Unlogged',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AuraColors.warningAmber,
                        ),
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

              // Completed Workout Details
              if (isCompleted && actualWorkout != null && actualWorkout.exercises.isNotEmpty) ...[
                const Text(
                  'Logged Workout Sets:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuraColors.textSecondary),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: actualWorkout.exercises.length,
                    itemBuilder: (context, idx) {
                      final ex = actualWorkout.exercises[idx];
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
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AuraColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              setsStr,
                              style: TextStyle(
                                fontSize: 12,
                                color: auraTheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Reversible / Undo completion CTA
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await ref.read(transformationEngineProvider.notifier).undoPastWorkoutStatus(dateStr);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reverted workout for $dateStr.'),
                            backgroundColor: AuraColors.surface2,
                          ),
                        );
                      }
                    },
                    icon: const Icon(LucideIcons.rotateCcw, size: 14, color: AuraColors.textTertiary),
                    label: const Text(
                      'Undo / Mark Incomplete',
                      style: TextStyle(fontSize: 12, color: AuraColors.textTertiary),
                    ),
                  ),
                ),
              ] else if (isRest && !isCompleted) ...[
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
                ),
                if (isPast) ...[
                  const SizedBox(height: 16),
                  AuraButton(
                    text: 'I Worked Out on Rest Day (AI Log)',
                    icon: LucideIcons.sparkles,
                    variant: AuraButtonVariant.secondary,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      showNaturalWorkoutLogModal(
                        context,
                        ref,
                        targetDate: dateStr,
                        initialDayName: planDay?.dayName,
                      );
                    },
                  ),
                ],
              ] else if (isSkipped) ...[
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
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AuraButton(
                        text: 'Log Workout Instead',
                        icon: LucideIcons.plus,
                        variant: AuraButtonVariant.primary,
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await ref
                              .read(transformationEngineProvider.notifier)
                              .markPastWorkoutCompleted(dateStr, planDay: planDay);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logged "$title" for $dateStr.'),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ] else if (isPast && !isCompleted && !isRest) ...[
                // Uncompleted past workout: Provide direct actionability
                if (planDay != null && planDay.exerciseNames.isNotEmpty) ...[
                  const Text(
                    'Planned Routine:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuraColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: planDay.exerciseNames.map((name) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
                const SizedBox(height: 20),
                // 1-Tap Mark as Completed (Prescribed)
                AuraButton(
                  text: 'Mark as Completed (Prescribed)',
                  icon: LucideIcons.checkCheck,
                  variant: AuraButtonVariant.primary,
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await ref
                        .read(transformationEngineProvider.notifier)
                        .markPastWorkoutCompleted(dateStr, planDay: planDay);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Marked "$title" as completed for $dateStr!'),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AuraButton(
                        text: 'Log Custom / AI',
                        icon: LucideIcons.sparkles,
                        variant: AuraButtonVariant.secondary,
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          showNaturalWorkoutLogModal(
                            context,
                            ref,
                            targetDate: dateStr,
                            initialDayName: planDay?.dayName,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AuraButton(
                        text: 'Mark as Skipped',
                        icon: LucideIcons.minus,
                        variant: AuraButtonVariant.secondary,
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await ref
                              .read(transformationEngineProvider.notifier)
                              .markPastWorkoutSkipped(dateStr);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Marked $dateStr as Skipped.'),
                                backgroundColor: AuraColors.surface2,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ] else if (planDay != null) ...[
                const Text(
                  'Planned Exercises:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuraColors.textSecondary),
                ),
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
              const SizedBox(height: 20),
              if (isToday && !isRest && !isCompleted)
                AuraButton(
                  text: 'Start Workout',
                  variant: AuraButtonVariant.primary,
                  onPressed: () {
                    Navigator.of(ctx).pop();
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

/// Natural language AI workout logging bottom sheet
void showNaturalWorkoutLogModal(
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
                              showWorkoutConfirmationSheet(
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

/// Confirmation sheet before persisting parsed workout
void showWorkoutConfirmationSheet(
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
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.clipboardCheck, color: auraTheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'REVIEW PARSED WORKOUT',
                          style: AuraTypography.sectionHeader.copyWith(
                            color: auraTheme.primary,
                            letterSpacing: 1.1,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: auraTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: auraTheme.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.calendar, size: 14, color: auraTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Target Date: ${targetDate ?? workout.date}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: auraTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(workout.title, style: AuraTypography.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '${workout.focusArea}  •  ~${workout.estimatedDurationMin} mins',
                  style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Exercises & Sets:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuraColors.textSecondary),
                ),
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
