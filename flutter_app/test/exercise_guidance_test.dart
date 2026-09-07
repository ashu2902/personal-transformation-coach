import 'package:flutter_test/flutter_test.dart';
import 'package:aura_transformation_engine/models/models.dart';

void main() {
  group('Canonical Exercise Knowledge Base & Stemmed Matcher', () {
    test('Resolves exact and alias matches for all 5 user test exercises', () {
      // 1. Shoulder Press Machine
      final shoulderPress = ExerciseDatabase.findDefinition('Shoulder Press Machine');
      expect(shoulderPress, isNotNull);
      expect(shoulderPress!.id, 'ex_mach_shoulder_press');
      expect(shoulderPress.targetMuscle, contains('Deltoids'));

      // 2. Incline Barbell Bench Press
      final inclineBench = ExerciseDatabase.findDefinition('Incline Barbell Bench Press');
      expect(inclineBench, isNotNull);
      expect(inclineBench!.id, 'ex_inc_bb_bench');
      expect(inclineBench.targetMuscle, contains('Upper Chest'));

      // 3. Dumbbell Lateral Raise
      final latRaise = ExerciseDatabase.findDefinition('Dumbbell Lateral Raise');
      expect(latRaise, isNotNull);
      expect(latRaise!.id, 'ex_db_lateral_raise');
      expect(latRaise.targetMuscle, contains('Lateral Deltoids'));

      // 4. Triceps Rope Pulldown
      final tricepsRope = ExerciseDatabase.findDefinition('Triceps Rope Pulldown');
      expect(tricepsRope, isNotNull);
      expect(tricepsRope!.id, 'ex_tricep_rope_pushdown');
      expect(tricepsRope.targetMuscle, contains('Triceps'));

      // 5. Flat Chest Press Machine
      final chestPress = ExerciseDatabase.findDefinition('Flat Chest Press Machine');
      expect(chestPress, isNotNull);
      expect(chestPress!.id, 'ex_mach_chest');
      expect(chestPress.targetMuscle, contains('Mid Chest'));
    });

    test('Resolves common real-world fitness aliases and abbreviations', () {
      expect(ExerciseDatabase.findDefinition('Machine Shoulder Press')?.id, 'ex_mach_shoulder_press');
      expect(ExerciseDatabase.findDefinition('Overhead Press Machine')?.id, 'ex_mach_shoulder_press');
      expect(ExerciseDatabase.findDefinition('Side Lateral Raise')?.id, 'ex_db_lateral_raise');
      expect(ExerciseDatabase.findDefinition('DB Lateral Raise')?.id, 'ex_db_lateral_raise');
      expect(ExerciseDatabase.findDefinition('Rope Pushdown')?.id, 'ex_tricep_rope_pushdown');
      expect(ExerciseDatabase.findDefinition('Cable Rope Pushdown')?.id, 'ex_tricep_rope_pushdown');
      expect(ExerciseDatabase.findDefinition('Chest Press Machine')?.id, 'ex_mach_chest');
      expect(ExerciseDatabase.findDefinition('Seated Chest Press')?.id, 'ex_mach_chest');
      expect(ExerciseDatabase.findDefinition('Incline Bench Press')?.id, 'ex_inc_bb_bench');
      expect(ExerciseDatabase.findDefinition('Leg Press')?.id, 'ex_leg_press');
      expect(ExerciseDatabase.findDefinition('Leg Extension')?.id, 'ex_leg_ext');
      expect(ExerciseDatabase.findDefinition('Hamstring Curl')?.id, 'ex_leg_curl');
      expect(ExerciseDatabase.findDefinition('Bulgarian Split Squat')?.id, 'ex_bulgarian_split_squat');
    });

    test('Returns structured 3-Cue Triad for defined exercises', () {
      const testEx = Exercise(
        id: 'test_1',
        name: 'Shoulder Press Machine',
        targetMuscle: 'Shoulders',
        equipmentRequired: 'machine',
        sets: [],
      );

      final cues = ExerciseDatabase.resolveCues(testEx);
      expect(cues.feelItIn, isNotEmpty);
      expect(cues.setupCue, isNotEmpty);
      expect(cues.avoidMistake, isNotEmpty);
      expect(cues.feelItIn, contains('deltoid'));
    });

    test('Returns verified direct YouTube tutorial video URLs', () {
      const testEx = Exercise(
        id: 'test_2',
        name: 'Triceps Rope Pulldown',
        targetMuscle: 'Triceps',
        equipmentRequired: 'cables',
        sets: [],
      );

      final videoUrl = ExerciseDatabase.resolveVideoUrl(testEx);
      expect(videoUrl, startsWith('https://www.youtube.com/watch?v='));
      expect(videoUrl, contains('vB5OHsJ3EME')); // Scott Herman tutorial ID
    });

    test('Dynamically adapts coach tip based on active CoachSoul', () {
      const testEx = Exercise(
        id: 'test_3',
        name: 'Incline Barbell Bench Press',
        targetMuscle: 'Upper Chest',
        equipmentRequired: 'barbell',
        sets: [],
      );

      final proTip = ExerciseDatabase.resolveCoachTip(testEx, CoachSoul.pro);
      final teacherTip = ExerciseDatabase.resolveCoachTip(testEx, CoachSoul.teacher);
      final supporterTip = ExerciseDatabase.resolveCoachTip(testEx, CoachSoul.supporter);

      expect(proTip, isNotEmpty);
      expect(teacherTip, isNotEmpty);
      expect(supporterTip, isNotEmpty);
      expect(proTip, isNot(equals(teacherTip)));
      expect(teacherTip, isNot(equals(supporterTip)));
    });

    test('Gracefully handles novel/unknown long-tail exercises without crashing', () {
      const novelEx = Exercise(
        id: 'novel_1',
        name: 'B-Stance Landmine Hack Squat',
        targetMuscle: 'Quads & Glutes',
        equipmentRequired: 'landmine',
        sets: [],
      );

      // Cues should be synthesized
      final cues = ExerciseDatabase.resolveCues(novelEx);
      expect(cues.feelItIn, contains('Quads & Glutes'));
      expect(cues.setupCue, contains('landmine'));
      expect(cues.avoidMistake, contains('momentum'));

      // Video should resolve to high-quality YouTube search on trusted channel
      final videoUrl = ExerciseDatabase.resolveVideoUrl(novelEx);
      expect(videoUrl, startsWith('https://www.youtube.com/results?search_query='));
      expect(videoUrl, contains('Renaissance%20Periodization'));

      // Instructions should be synthesized
      final instructions = ExerciseDatabase.resolveInstructions(novelEx);
      expect(instructions, contains('### Setup & Position'));
      expect(instructions, contains('### Movement Execution'));

      // Coach tip should adapt to soul
      final tip = ExerciseDatabase.resolveCoachTip(novelEx, CoachSoul.teacher);
      expect(tip, isNotEmpty);
    });
  });
}
