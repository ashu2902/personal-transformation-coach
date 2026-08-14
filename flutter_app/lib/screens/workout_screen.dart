import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';
import '../engine/exercise_database.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);
    final notifier = ref.read(transformationEngineProvider.notifier);
    final workout = state.workout;

    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final isTrackedToday = state.isProgressTrackedForDate(todayStr);
    final isCompleted =
        state.effectiveTodayWorkoutStatus == WorkoutStatus.completed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141923),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E2638)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0x2010B981)
                        : const Color(0x203B82F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted
                        ? LucideIcons.checkCircle2
                        : LucideIcons.dumbbell,
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : const Color(0xFF3B82F6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(workout.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.clock,
                              size: 12, color: Color(0xFFA1A1AA)),
                          const SizedBox(width: 4),
                          Text('${workout.estimatedDurationMin} min',
                              style: const TextStyle(
                                  color: Color(0xFFA1A1AA), fontSize: 12)),
                          const SizedBox(width: 10),
                          const Icon(LucideIcons.target,
                              size: 12, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Text(workout.focusArea,
                              style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0x1DF59E0B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x40F59E0B)),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.info, color: Color(0xFFF59E0B), size: 16),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          'Tap to mark today\'s training as active & tracked',
                          style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                    Icon(LucideIcons.chevronRight,
                        color: Color(0xFFF59E0B), size: 16),
                  ],
                ),
              ),
            ),

          // AI Workout Adapt Button Banner
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x1510B981),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x4010B981)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.sparkles, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dynamic AI Adaptation Engine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('Adapt exercises for injuries, time limits, or equipment', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 11)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showAIAdaptationBottomSheet(context, ref),
                  icon: const Icon(LucideIcons.sliders, size: 14),
                  label: const Text('Adapt AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
          ),

          // Exercise List
          const Text('EXERCISES',
              style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 10),

          ...workout.exercises.map((ex) {
            final completedSetsCount = ex.sets.where((s) => s.completed).length;
            final isExDone = completedSetsCount == ex.sets.length;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF141923),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isExDone
                        ? const Color(0x4010B981)
                        : const Color(0xFF1E2638)),
              ),
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
                            Text(ex.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              '${ex.targetMuscle} • ${ex.equipmentRequired.toUpperCase()}',
                              style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.repeat,
                                size: 16, color: Color(0xFFA1A1AA)),
                            tooltip: 'Substitute Exercise',
                            onPressed: () => _showSubstitutionModal(context, ex,
                                state.profile.availableEquipment, notifier),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isExDone
                                  ? const Color(0x2010B981)
                                  : const Color(0xFF1E2638),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$completedSetsCount / ${ex.sets.length} Sets',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isExDone
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFA1A1AA),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (ex.notes != null && ex.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(ex.notes!,
                        style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 10,
                            fontStyle: FontStyle.italic)),
                  ],
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF1E2638), height: 1),
                  const SizedBox(height: 8),
                  ...ex.sets.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final set = entry.value;
                    return InkWell(
                      onTap: () => notifier.updateExerciseSet(
                          ex.id, idx, !set.completed),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: set.completed
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF1E2638),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: set.completed
                                  ? const Icon(LucideIcons.check, color: Colors.black, size: 14)
                                  : Text(
                                      '${set.setNumber}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${set.targetWeightKg > 0 ? '${set.targetWeightKg} kg' : 'Bodyweight'}  ×  ${set.targetReps} reps',
                                style: TextStyle(
                                  color: set.completed
                                      ? Colors.white
                                      : const Color(0xFFA1A1AA),
                                  fontSize: 13,
                                  fontWeight: set.completed
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            Icon(
                              set.completed
                                  ? LucideIcons.checkCircle2
                                  : LucideIcons.circle,
                              size: 20,
                              color: set.completed
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF3F4B66),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showSubstitutionModal(
      BuildContext context,
      Exercise currentEx,
      List<EquipmentType> userEquipment,
      TransformationEngineNotifier notifier) {
    final subs = ExerciseDatabase.getSubstitutions(
      currentExerciseName: currentEx.name,
      availableEquipment: userEquipment,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141923),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Substitute: ${currentEx.name}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  IconButton(
                    icon: const Icon(LucideIcons.x,
                        color: Color(0xFFA1A1AA), size: 18),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Biomechanical alternatives matching your equipment:',
                  style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 11)),
              const SizedBox(height: 14),
              if (subs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                      'No matching alternatives found for current equipment.',
                      style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12)),
                )
              else
                ...subs.map((sub) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0F17),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E2638)),
                    ),
                    child: ListTile(
                      title: Text(sub.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      subtitle: Text(
                          '${sub.targetMuscle} • ${sub.equipment.name.toUpperCase()}',
                          style: const TextStyle(
                              color: Color(0xFF10B981), fontSize: 11)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        onPressed: () {
                          notifier.substituteExercise(currentEx.id, sub);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Swap',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
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
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141923),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.sparkles, color: Color(0xFF10B981), size: 20),
                      SizedBox(width: 8),
                      Text('Adapt Workout with AURA AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: Color(0xFFA1A1AA), size: 18),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Tell Aura how to adapt today\'s session (equipment, time limits, sore muscles, etc.):', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Dumbbells Only',
                  'Sore Shoulders',
                  '20-Min Express Workout',
                  'Protect Lower Back',
                ].map((chip) {
                  return ActionChip(
                    backgroundColor: const Color(0xFF0B0F17),
                    side: const BorderSide(color: Color(0xFF1E2638)),
                    label: Text(chip, style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      controller.text = chip;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. "Only have dumbbells today, skip heavy squats"',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF0B0F17),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final nav = Navigator.of(ctx);
                    final req = controller.text.trim();
                    if (req.isNotEmpty) {
                      nav.pop();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('⚡ AURA AI adapting your workout program...'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                      await ref.read(transformationEngineProvider.notifier).adaptTodayWorkoutWithAI(req);
                    }
                  },
                  icon: const Icon(LucideIcons.sparkles, size: 16),
                  label: const Text('Generate AI Adapted Workout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
