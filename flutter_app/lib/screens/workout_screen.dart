import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/transformation_state.dart';
import '../providers/analytics_provider.dart';
import '../services/analytics_service.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/common/common.dart';
import '../widgets/common/quick_coach_fab.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);
    final notifier = ref.read(transformationEngineProvider.notifier);
    final workout = state.workout;
    final auraTheme = context.auraTheme;

    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final isTrackedToday = state.isProgressTrackedForDate(todayStr);
    final isCompleted = state.effectiveTodayWorkoutStatus == WorkoutStatus.completed;

    final totalSets = workout.exercises.fold(0, (sum, ex) => sum + ex.sets.length);
    final completedSets = workout.exercises.fold(0, (sum, ex) => sum + ex.sets.where((s) => s.completed).length);
    final setProgress = totalSets > 0 ? (completedSets / totalSets).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: auraTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: auraTheme.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AuraColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Workout Session',
          style: AuraTypography.titleLarge.copyWith(fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              icon: Icon(LucideIcons.sparkles, size: 16, color: auraTheme.primary),
              label: Text(
                'Adapt AI',
                style: TextStyle(color: auraTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () => _showAIAdaptationBottomSheet(context, ref),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: auraTheme.surfaceCard,
          border: const Border(top: BorderSide(color: AuraColors.borderSubtle)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completedSets of $totalSets Sets Completed',
                    style: AuraTypography.bodySmall.copyWith(
                      color: AuraColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(setProgress * 100).round()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Theme.of(context).colorScheme.primary : auraTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: setProgress,
                  minHeight: 6,
                  backgroundColor: AuraColors.surface2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Theme.of(context).colorScheme.primary : auraTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AuraButton(
                text: isCompleted
                    ? 'Workout Completed ✓'
                    : 'Finish & Complete Workout ($completedSets/$totalSets Sets)',
                icon: isCompleted ? LucideIcons.checkCheck : LucideIcons.trophy,
                backgroundColor: isCompleted ? AuraColors.surface2 : auraTheme.primary,
                textColor: isCompleted ? AuraColors.textSecondary : Colors.black,
                variant: isCompleted ? AuraButtonVariant.secondary : AuraButtonVariant.primary,
                width: double.infinity,
                height: 50,
                onPressed: isCompleted
                    ? null
                    : () {
                        // Complete workout atomically (marks all sets, updates status & history, logs Mixpanel)
                        notifier.completeWorkout();

                        _showWorkoutCompletedDialog(context, state, workout);
                      },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const QuickCoachFAB(contextTag: 'workout'),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.maxFluidContentWidth),
          child: RefreshIndicator(
            color: auraTheme.primary,
            backgroundColor: auraTheme.surfaceCard,
            onRefresh: () => ref.read(transformationEngineProvider.notifier).refreshState(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // 1. Workout Overview Card
                AuraCard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: auraTheme.surfaceCard,
                  borderColor: AuraColors.borderSubtle,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                              : auraTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isCompleted ? LucideIcons.checkCircle2 : LucideIcons.dumbbell,
                          color: isCompleted ? Theme.of(context).colorScheme.primary : auraTheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.title,
                              style: AuraTypography.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(LucideIcons.clock, size: 12, color: AuraColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${workout.estimatedDurationMin} min',
                                  style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                                ),
                                const SizedBox(width: 10),
                                Icon(LucideIcons.target, size: 12, color: auraTheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  workout.focusArea,
                                  style: AuraTypography.bodySmall.copyWith(
                                    color: auraTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (!isTrackedToday && !isCompleted)
                  GestureDetector(
                    onTap: () => notifier.trackProgressForToday(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AuraColors.warningAmber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AuraColors.warningAmber.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.info, color: AuraColors.warningAmber, size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tap to mark today\'s training as active & tracked',
                              style: AuraTypography.labelBold.copyWith(
                                color: AuraColors.warningAmber,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Icon(LucideIcons.chevronRight, color: AuraColors.warningAmber, size: 16),
                        ],
                      ),
                    ),
                  ),

                // 2. Exercise Checklist
                const AuraSectionHeader(
                  title: 'Exercises & Sets',
                ),
                const SizedBox(height: 8),

                ...workout.exercises.map((ex) {
                  final completedSetsCount = ex.sets.where((s) => s.completed).length;
                  final isExDone = completedSetsCount == ex.sets.length;

                  return AuraCard(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    backgroundColor: auraTheme.surfaceCard,
                    borderColor: isExDone
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                        : AuraColors.borderSubtle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.name,
                                    style: AuraTypography.titleMedium.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${ex.targetMuscle} • ${ex.equipmentRequired.toUpperCase()}',
                                    style: AuraTypography.bodySmall.copyWith(
                                      color: auraTheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(LucideIcons.helpCircle, size: 18, color: auraTheme.primary),
                                  tooltip: 'How to Perform',
                                  onPressed: () {
                                    _showExerciseGuidanceModal(context, ex, state.profile.coachSoul);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.arrowLeftRight, size: 18, color: AuraColors.textSecondary),
                                  tooltip: 'Swap Exercise',
                                  onPressed: () {
                                    _showSubstitutionModal(
                                      context,
                                      ex,
                                      notifier,
                                    );
                                  },
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isExDone
                                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                                        : AuraColors.surface2,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$completedSetsCount/${ex.sets.length} Sets',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isExDone ? Theme.of(context).colorScheme.primary : AuraColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (ex.notes != null && ex.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            ex.notes!,
                            style: AuraTypography.bodySmall.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AuraColors.textSecondary,
                            ),
                          ),
                        ],
                        const Divider(height: 20, color: AuraColors.borderSubtle),

                        // Sets Row List
                        ...ex.sets.asMap().entries.map((entry) {
                          final setIndex = entry.key;
                          final setItem = entry.value;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AuraColors.surface2,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AuraColors.borderSubtle),
                                  ),
                                  child: Text(
                                    '${setIndex + 1}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AuraColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _showSetAdjustmentModal(context, notifier, ex, setIndex, setItem);
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          setItem.targetWeightKg > 0
                                              ? '${setItem.targetWeightKg} kg × ${setItem.targetReps} reps'
                                              : '${setItem.targetReps} reps',
                                          style: AuraTypography.bodyMedium.copyWith(
                                            decoration: setItem.completed ? TextDecoration.lineThrough : null,
                                            color: setItem.completed ? AuraColors.textTertiary : AuraColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(LucideIcons.edit2, size: 12, color: AuraColors.textTertiary),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    notifier.updateExerciseSet(ex.id, setIndex, !setItem.completed);
                                  },
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: setItem.completed ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: setItem.completed ? Theme.of(context).colorScheme.primary : AuraColors.borderSubtle,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: setItem.completed
                                        ? const Icon(LucideIcons.check, size: 16, color: Colors.black)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }

  void _showWorkoutCompletedDialog(
    BuildContext context,
    TransformationEngineState state,
    DailyWorkout workout,
  ) {
    final auraTheme = context.auraTheme;
    final soul = state.profile.coachSoul;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: auraTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                ),
                child: Icon(LucideIcons.trophy, color: Theme.of(context).colorScheme.primary, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Workout Logged!',
                style: AuraTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${workout.title} marked complete.',
                textAlign: TextAlign.center,
                style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: auraTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  soul == CoachSoul.supporter
                      ? "Outstanding consistency! Every completed session compounds into lifelong strength. Rest up and refuel!"
                      : soul == CoachSoul.pro
                          ? "Target volume completed. Solid mechanical execution. Stay disciplined with today's nutrition."
                          : "Stimulus achieved. Protein synthesis and cellular recovery are now actively engaged.",
                  textAlign: TextAlign.center,
                  style: AuraTypography.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AuraColors.textPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AuraButton(
                text: 'Done',
                backgroundColor: auraTheme.primary,
                textColor: Colors.black,
                width: double.infinity,
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).maybePop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubstitutionModal(
    BuildContext context,
    Exercise currentEx,
    TransformationEngineNotifier notifier,
  ) {
    final auraTheme = context.auraTheme;
    final availableEquipment = [
      EquipmentType.bodyweight,
      EquipmentType.dumbbells,
      EquipmentType.barbell,
      EquipmentType.cables,
      EquipmentType.machines,
    ];
    final subs = ExerciseDatabase.getSubstitutions(
      currentExerciseName: currentEx.name,
      availableEquipment: availableEquipment,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Swap "${currentEx.name}"',
                style: AuraTypography.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Select a biomechanically equivalent exercise:',
                style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
              ),
              const SizedBox(height: 16),
              if (subs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No matching equipment alternatives found.',
                      style: AuraTypography.bodyMedium.copyWith(color: AuraColors.textSecondary),
                    ),
                  ),
                )
              else
                ...subs.map((alt) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: auraTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(LucideIcons.repeat, color: auraTheme.primary, size: 18),
                    ),
                    title: Text(
                      alt.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AuraColors.textPrimary),
                    ),
                    subtitle: Text(
                      '${alt.targetMuscle} • ${alt.equipment.name.toUpperCase()}',
                      style: const TextStyle(fontSize: 12, color: AuraColors.textSecondary),
                    ),
                    trailing: AuraButton(
                      text: 'Select',
                      height: 32,
                      variant: AuraButtonVariant.secondary,
                      onPressed: () {
                        notifier.substituteExercise(currentEx.id, alt);
                        Navigator.pop(ctx);
                      },
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _showAIAdaptationBottomSheet(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    final auraTheme = context.auraTheme;
    final workout = ref.read(transformationEngineProvider).workout;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Workout Adaptation', style: AuraTypography.titleLarge),
                        Text(
                          'Tell AURA what to modify for today\'s session',
                          style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 3,
                style: const TextStyle(color: AuraColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. "My lower back is tight, swap deadlifts" or "Only have 20 minutes today"',
                  hintStyle: const TextStyle(color: AuraColors.textTertiary, fontSize: 13),
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
                text: 'Adapt Workout with AI',
                variant: AuraButtonVariant.primary,
                backgroundColor: auraTheme.primary,
                textColor: Colors.black,
                width: double.infinity,
                onPressed: () async {
                  final prompt = textController.text.trim();
                  if (prompt.isEmpty) return;
                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Text('AURA is adapting your workout...'),
                        ],
                      ),
                      backgroundColor: AuraColors.surface2,
                      duration: Duration(seconds: 4),
                    ),
                  );

                  await ref.read(transformationEngineProvider.notifier).adaptTodayWorkoutWithAI(
                    prompt,
                    contextEnvelope: ContextEnvelope(
                      activeScreen: 'workout',
                      activeWorkoutDate: workout.date,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSetAdjustmentModal(
    BuildContext context,
    TransformationEngineNotifier notifier,
    Exercise ex,
    int setIndex,
    ExerciseSet currentSet,
  ) {
    int reps = currentSet.targetReps;
    double weight = currentSet.targetWeightKg;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14141A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adjust Set #${setIndex + 1}',
                            style: GoogleFonts.syne(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ex.name,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFA1A1AA),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'MICRO-DEVIATION',
                          style: GoogleFonts.syne(
                            color: const Color(0xFF00FFA3),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Reps Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target Reps',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          _buildStepperBtn(
                            icon: LucideIcons.minus,
                            onTap: () {
                              if (reps > 1) {
                                setModalState(() => reps -= 1);
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              '$reps',
                              style: GoogleFonts.syne(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildStepperBtn(
                            icon: LucideIcons.plus,
                            onTap: () {
                              setModalState(() => reps += 1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Weight Stepper (if applicable)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target Weight (kg)',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          _buildStepperBtn(
                            icon: LucideIcons.minus,
                            onTap: () {
                              if (weight >= 2.5) {
                                setModalState(() => weight -= 2.5);
                              } else {
                                setModalState(() => weight = 0.0);
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0),
                            child: Text(
                              '${weight.toStringAsFixed(weight.truncateToDouble() == weight ? 0 : 1)} kg',
                              style: GoogleFonts.syne(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildStepperBtn(
                            icon: LucideIcons.plus,
                            onTap: () {
                              setModalState(() => weight += 2.5);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FFA3),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        notifier.updateSetTarget(
                          ex.id,
                          setIndex,
                          newReps: reps,
                          newWeightKg: weight,
                        );
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Save Adjustment',
                        style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStepperBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF22222A),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  void _showExerciseGuidanceModal(BuildContext context, Exercise ex, CoachSoul soul) {
    final auraTheme = context.auraTheme;
    final cues = ExerciseDatabase.resolveCues(ex);
    final videoUrl = ExerciseDatabase.resolveVideoUrl(ex);
    final coachTip = ExerciseDatabase.resolveCoachTip(ex, soul);
    final guideText = ExerciseDatabase.resolveInstructions(ex);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: auraTheme.surfaceCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AuraColors.borderSubtle),
        ),
        child: Column(
          children: [
            // Handle Bar
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AuraColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Modal Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: auraTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.bookOpen, color: auraTheme.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.name,
                          style: AuraTypography.titleLarge.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: auraTheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                ex.targetMuscle,
                                style: AuraTypography.bodySmall.copyWith(
                                  color: auraTheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AuraColors.surface2,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                ex.equipmentRequired.toUpperCase(),
                                style: AuraTypography.bodySmall.copyWith(
                                  color: AuraColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: AuraColors.textSecondary, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(color: AuraColors.borderSubtle, height: 20),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── 1. GLANCEABLE 3-CUE TRIAD CARD (3-Second In-Workout Review) ───
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AuraColors.surface2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AuraColors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.zap, size: 14, color: auraTheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                'FORM CUES (3-SEC REVIEW)',
                                style: AuraTypography.labelMedium.copyWith(
                                  color: auraTheme.primary,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Feel It In
                          _buildCueRow(
                            emoji: '🎯',
                            label: 'FEEL IT IN',
                            labelColor: auraTheme.primary,
                            content: cues.feelItIn,
                            highlight: true,
                          ),
                          const SizedBox(height: 10),

                          // Setup & Position
                          _buildCueRow(
                            emoji: '⚡',
                            label: 'KEY SETUP CUE',
                            labelColor: AuraColors.textSecondary,
                            content: cues.setupCue,
                            highlight: false,
                          ),
                          const SizedBox(height: 10),

                          // Avoid / Safety
                          _buildCueRow(
                            emoji: '⚠️',
                            label: 'AVOID',
                            labelColor: const Color(0xFFFFB020),
                            content: cues.avoidMistake,
                            highlight: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ─── 2. COACH PERSONA TIP CARD ───
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: auraTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: auraTheme.primary.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(LucideIcons.sparkles, size: 16, color: auraTheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'COACH ${soul.displayName.toUpperCase()} TIP',
                                  style: AuraTypography.labelSmall.copyWith(
                                    color: auraTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '"$coachTip"',
                                  style: AuraTypography.bodySmall.copyWith(
                                    color: AuraColors.textPrimary,
                                    fontStyle: FontStyle.italic,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ─── 3. VERIFIED TUTORIAL VIDEO BUTTON ───
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: const Icon(LucideIcons.play, size: 16, color: Colors.white),
                        label: const Text(
                          'Watch Video Form Tutorial',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                        onPressed: () async {
                          final uri = Uri.parse(videoUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── 4. DETAILED STEP-BY-STEP BREAKDOWN (Expandable) ───
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        collapsedTextColor: AuraColors.textSecondary,
                        textColor: auraTheme.primary,
                        iconColor: auraTheme.primary,
                        collapsedIconColor: AuraColors.textSecondary,
                        title: Text(
                          'Detailed Step-by-Step Instructions',
                          style: AuraTypography.titleSmall.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
                            child: MarkdownBody(
                              data: guideText,
                              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                                p: AuraTypography.bodyMedium.copyWith(color: AuraColors.textPrimary, height: 1.45),
                                strong: AuraTypography.bodyMedium.copyWith(color: auraTheme.primary, fontWeight: FontWeight.bold),
                                h1: AuraTypography.titleMedium.copyWith(color: auraTheme.primary, fontSize: 16),
                                h2: AuraTypography.titleSmall.copyWith(color: auraTheme.primary, fontSize: 14),
                                h3: AuraTypography.labelLarge.copyWith(color: auraTheme.primary, fontSize: 12),
                                listBullet: AuraTypography.bodyMedium.copyWith(color: auraTheme.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCueRow({
    required String emoji,
    required String label,
    required Color labelColor,
    required String content,
    required bool highlight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(
              label,
              style: AuraTypography.labelSmall.copyWith(
                color: labelColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            content,
            style: AuraTypography.bodySmall.copyWith(
              color: highlight ? Colors.white : AuraColors.textPrimary,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
