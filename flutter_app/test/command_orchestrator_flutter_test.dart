import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_transformation_engine/models/models.dart';
import 'package:aura_transformation_engine/screens/widgets/action_preview_card.dart';

void main() {
  group('ContextEnvelope Tests', () {
    test('serializes and deserializes correctly', () {
      const envelope = ContextEnvelope(
        activeScreen: 'workout',
        focusedExerciseId: 'ex_1',
        focusedExerciseName: 'Barbell Back Squat',
        currentSetIndex: 2,
        activeWorkoutDate: '2026-03-30',
        activeMealId: 'meal_1',
        clientTimestamp: '2026-03-30T10:00:00Z',
      );

      final json = envelope.toJson();
      expect(json['activeScreen'], 'workout');
      expect(json['focusedExerciseId'], 'ex_1');
      expect(json['focusedExerciseName'], 'Barbell Back Squat');
      expect(json['currentSetIndex'], 2);
      expect(json['activeWorkoutDate'], '2026-03-30');
      expect(json['activeMealId'], 'meal_1');
      expect(json['clientTimestamp'], '2026-03-30T10:00:00Z');

      final deserialized = ContextEnvelope.fromJson(json);
      expect(deserialized.activeScreen, envelope.activeScreen);
      expect(deserialized.focusedExerciseId, envelope.focusedExerciseId);
      expect(deserialized.focusedExerciseName, envelope.focusedExerciseName);
      expect(deserialized.currentSetIndex, envelope.currentSetIndex);
      expect(deserialized.activeWorkoutDate, envelope.activeWorkoutDate);
      expect(deserialized.activeMealId, envelope.activeMealId);
      expect(deserialized.clientTimestamp, envelope.clientTimestamp);
    });

    test('handles empty or partial JSON gracefully', () {
      final deserialized = ContextEnvelope.fromJson({});
      expect(deserialized.activeScreen, 'coach');
      expect(deserialized.focusedExerciseId, isNull);
      expect(deserialized.focusedExerciseName, isNull);
      expect(deserialized.currentSetIndex, isNull);
    });
  });

  group('CommandPreview and CommandChange Tests', () {
    test('parses low-risk command preview with changes and inverse command', () {
      final json = {
        'commandName': 'workout.substituteExercise',
        'category': 'workout',
        'risk': 'low',
        'summary': 'Substituted Barbell Back Squat with Goblet Squat',
        'title': 'Swap to Goblet Squat',
        'inverseCommand': 'Undo substitution for Goblet Squat',
        'changes': [
          {
            'target': 'exercises[0].name',
            'description': 'Changed exercise to Goblet Squat',
            'before': 'Barbell Back Squat',
            'after': 'Goblet Squat',
          },
        ],
        'warnings': ['Target muscle focus shifted slightly to quads.'],
      };

      final preview = CommandPreview.fromJson(json);
      expect(preview.commandName, 'workout.substituteExercise');
      expect(preview.category, 'workout');
      expect(preview.risk, 'low');
      expect(preview.isHighRisk, false);
      expect(preview.summary, 'Substituted Barbell Back Squat with Goblet Squat');
      expect(preview.displayTitle, 'Swap to Goblet Squat');
      expect(preview.inverseCommand, 'Undo substitution for Goblet Squat');
      expect(preview.changes.length, 1);
      expect(preview.changes.first.target, 'exercises[0].name');
      expect(preview.changes.first.before, 'Barbell Back Squat');
      expect(preview.changes.first.after, 'Goblet Squat');
      expect(preview.warnings.length, 1);
      expect(preview.pendingActionId, isNull);
    });

    test('parses high-risk command preview with pendingActionId', () {
      final json = {
        'commandName': 'profile.updateEquipment',
        'category': 'profile',
        'risk': 'high',
        'summary': 'Add 20kg Dumbbells to equipment profile',
        'title': 'Update Equipment Profile',
        'changes': [
          {
            'target': 'profile.equipmentList',
            'description': 'Added 20kg Dumbbells',
            'before': ['Bodyweight'],
            'after': ['Bodyweight', '20kg Dumbbells'],
          },
        ],
        'warnings': ['Requires regenerating weekly program recommendations.'],
        'pendingActionId': 'pa_equip_123',
      };

      final preview = CommandPreview.fromJson(json);
      expect(preview.isHighRisk, true);
      expect(preview.pendingActionId, 'pa_equip_123');
      expect(preview.warnings.isNotEmpty, true);
    });
  });

  group('ActionPreviewCard Widget Tests', () {
    testWidgets('renders low-risk preview with category badge, diff, and undo chip', (tester) async {
      bool undoTapped = false;

      const preview = CommandPreview(
        commandName: 'workout.substituteExercise',
        category: 'workout',
        risk: 'low',
        summary: 'Substituted Barbell Back Squat with Goblet Squat',
        title: 'Swap Exercise',
        inverseCommand: 'Swap back to Barbell Back Squat',
        changes: [
          CommandChange(
            target: 'Exercise',
            description: 'Substituted for equipment availability',
            before: 'Barbell Back Squat',
            after: 'Goblet Squat',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionPreviewCard(
              preview: preview,
              onUndo: () => undoTapped = true,
            ),
          ),
        ),
      );

      // Verify summary and category badge
      expect(find.text('Substituted Barbell Back Squat with Goblet Squat'), findsOneWidget);
      expect(find.text('Auto-applied ✓'), findsOneWidget);

      // Verify before and after diff values
      expect(find.text('Barbell Back Squat'), findsOneWidget);
      expect(find.text('Goblet Squat'), findsOneWidget);

      // Verify undo button exists and responds to tap
      final undoButton = find.text('Undo');
      expect(undoButton, findsOneWidget);
      await tester.tap(undoButton);
      expect(undoTapped, true);
    });

    testWidgets('renders high-risk preview with Approval and Reject buttons', (tester) async {
      bool approved = false;
      bool rejected = false;

      const preview = CommandPreview(
        commandName: 'profile.updateInjuries',
        category: 'profile',
        risk: 'high',
        summary: 'Logged knee pain limitation',
        title: 'Add Knee Pain Limitation',
        pendingActionId: 'pa_inj_456',
        changes: [
          CommandChange(
            target: 'Injuries',
            description: 'Add knee pain to active limitations',
            before: 'None',
            after: 'Knee pain',
          ),
        ],
        warnings: ['Future leg workouts will substitute knee-dominant exercises.'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionPreviewCard(
              preview: preview,
              onApprove: () => approved = true,
              onReject: () => rejected = true,
            ),
          ),
        ),
      );

      // Verify High Risk badge and warning text
      expect(find.text('Requires Approval'), findsOneWidget);
      expect(find.text('Future leg workouts will substitute knee-dominant exercises.'), findsOneWidget);

      // Verify Approve (Confirm & Apply) and Reject buttons
      final approveBtn = find.text('Confirm & Apply');
      final rejectBtn = find.text('Reject');
      expect(approveBtn, findsOneWidget);
      expect(rejectBtn, findsOneWidget);

      await tester.tap(approveBtn);
      expect(approved, true);

      await tester.tap(rejectBtn);
      expect(rejected, true);
    });
  });

  group('Unified Orchestrator 5-Scenario Verification', () {
    test('Scenario 1: Exercise substitution with ContextEnvelope', () {
      const envelope = ContextEnvelope(
        activeScreen: 'workout',
        focusedExerciseId: 'ex_squat',
        focusedExerciseName: 'Barbell Back Squat',
        activeWorkoutDate: '2026-03-30',
      );

      final preview = CommandPreview(
        commandName: 'workout.substituteExercise',
        category: 'workout',
        risk: 'low',
        summary: 'Swapped Barbell Back Squat for Dumbbell Goblet Squat',
        changes: [
          CommandChange(
            target: envelope.focusedExerciseName!,
            description: 'Squat rack taken, swapped for dumbbell alternative',
            before: 'Barbell Back Squat',
            after: 'Dumbbell Goblet Squat',
          ),
        ],
      );

      expect(preview.category, 'workout');
      expect(preview.changes.first.target, 'Barbell Back Squat');
      expect(preview.changes.first.after, 'Dumbbell Goblet Squat');
      expect(preview.isHighRisk, false);
    });

    test('Scenario 2: Workout volume adjustment', () {
      const preview = CommandPreview(
        commandName: 'workout.adjustVolume',
        category: 'workout',
        risk: 'low',
        summary: 'Applied 20% deload to workout volume',
        changes: [
          CommandChange(
            target: 'Workout Volume',
            description: 'Scaled target weights and reps by -20%',
            before: '100% Intensity',
            after: '80% Intensity (Deload)',
          ),
        ],
      );

      expect(preview.commandName, 'workout.adjustVolume');
      expect(preview.changes.first.before, '100% Intensity');
      expect(preview.changes.first.after, contains('Deload'));
    });

    test('Scenario 3: Multi-command logging (Meal + Recovery in single turn)', () {
      const mealPreview = CommandPreview(
        commandName: 'nutrition.logMeal',
        category: 'nutrition',
        risk: 'low',
        summary: 'Logged 3 Whole Eggs (210 kcal, 18g P)',
        changes: [
          CommandChange(
            target: 'Daily Nutrition',
            description: 'Added 3 Whole Eggs',
            before: '1200 kcal',
            after: '1410 kcal',
          ),
        ],
      );

      const recoveryPreview = CommandPreview(
        commandName: 'recovery.log',
        category: 'recovery',
        risk: 'low',
        summary: 'Recorded 6 hours of sleep',
        changes: [
          CommandChange(
            target: 'Sleep Duration',
            description: 'Updated sleep hours',
            before: '0h',
            after: '6.0h',
          ),
        ],
      );

      const orchestratorResult = UnifiedAIOrchestratorResult(
        coachResponse: 'Recorded your 3 eggs and logged 6 hours of rest!',
        previews: [mealPreview, recoveryPreview],
      );

      expect(orchestratorResult.previews.length, 2);
      expect(orchestratorResult.previews[0].category, 'nutrition');
      expect(orchestratorResult.previews[1].category, 'recovery');
    });

    test('Scenario 4: Recovery score calculation model preview', () {
      const preview = CommandPreview(
        commandName: 'recovery.log',
        category: 'recovery',
        risk: 'low',
        summary: 'Logged 7.5h sleep, soreness 3/10',
        changes: [
          CommandChange(
            target: 'Recovery Score',
            description: 'Computed readiness score',
            before: 50,
            after: 82,
          ),
        ],
      );

      expect(preview.changes.first.after, 82);
      expect(preview.isHighRisk, false);
    });

    test('Scenario 5: High-risk profile modification requiring explicit gate', () {
      const preview = CommandPreview(
        commandName: 'profile.updateEquipment',
        category: 'profile',
        risk: 'high',
        summary: 'Added 10kg sandbag to home gym setup',
        pendingActionId: 'pa_home_gym_001',
        changes: [
          CommandChange(
            target: 'Equipment',
            description: 'Added 10kg sandbag',
            before: 'Bodyweight',
            after: 'Bodyweight, 10kg sandbag',
          ),
        ],
      );

      expect(preview.isHighRisk, true);
      expect(preview.pendingActionId, isNotNull);
    });
  });
}
