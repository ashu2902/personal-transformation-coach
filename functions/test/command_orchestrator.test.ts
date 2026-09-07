import { test, describe } from "node:test";
import assert from "node:assert/strict";
import { defaultCommandRegistry } from "../src/commands/registry";
import { buildResolutionContext } from "../src/context/contextBuilder";
import { ExecutionContext } from "../src/commands/types";

// In-memory Mock Firestore for unit tests
function createMockFirestore() {
  const store: Record<string, any> = {};

  return {
    store,
    collection: (colName: string) => ({
      doc: (docId: string) => ({
        get: async () => ({
          exists: !!store[`${colName}/${docId}`],
          data: () => store[`${colName}/${docId}`] || {},
        }),
        set: async (data: any, options?: any) => {
          const key = `${colName}/${docId}`;
          if (options?.merge && store[key]) {
            store[key] = { ...store[key], ...data };
          } else {
            store[key] = data;
          }
        },
        update: async (data: any) => {
          const key = `${colName}/${docId}`;
          store[key] = { ...(store[key] || {}), ...data };
        },
        collection: (subColName: string) => ({
          doc: (subDocId: string) => ({
            get: async () => ({
              exists: !!store[`${colName}/${docId}/${subColName}/${subDocId}`],
              data: () => store[`${colName}/${docId}/${subColName}/${subDocId}`] || {},
            }),
            set: async (data: any, options?: any) => {
              const key = `${colName}/${docId}/${subColName}/${subDocId}`;
              if (options?.merge && store[key]) {
                store[key] = { ...store[key], ...data };
              } else {
                store[key] = data;
              }
            },
            update: async (data: any) => {
              const key = `${colName}/${docId}/${subColName}/${subDocId}`;
              store[key] = { ...(store[key] || {}), ...data };
            },
          }),
        }),
      }),
    }),
  };
}

describe("AURA Unified Command Orchestrator Tests", () => {
  const mockUid = "test_user_123";
  const todayStr = "2026-09-07";

  const baselineState = {
    profile: {
      name: "Ashutosh",
      goal: "recomp",
      daysPerWeek: 3,
      equipmentList: [{ name: "Dumbbells", category: "dumbbells" }],
      activeInjuries: [],
    },
    workout: {
      date: todayStr,
      title: "Lower Body Hypertrophy",
      focusArea: "Legs",
      estimatedDurationMin: 45,
      exercises: [
        {
          id: "ex_1",
          name: "Barbell Back Squat",
          targetMuscle: "Quadriceps & Glutes",
          equipmentRequired: "barbell",
          sets: [
            { setNumber: 1, targetReps: 8, targetWeightKg: 80, completed: false },
            { setNumber: 2, targetReps: 8, targetWeightKg: 80, completed: false },
            { setNumber: 3, targetReps: 8, targetWeightKg: 80, completed: false },
          ],
        },
        {
          id: "ex_2",
          name: "Bulgarian Split Squat",
          targetMuscle: "Quadriceps & Glutes",
          equipmentRequired: "dumbbells",
          sets: [
            { setNumber: 1, targetReps: 10, targetWeightKg: 16, completed: false },
            { setNumber: 2, targetReps: 10, targetWeightKg: 16, completed: false },
            { setNumber: 3, targetReps: 10, targetWeightKg: 16, completed: false },
          ],
        },
        {
          id: "ex_3",
          name: "Dumbbell Romanian Deadlift",
          targetMuscle: "Hamstrings",
          equipmentRequired: "dumbbells",
          sets: [
            { setNumber: 1, targetReps: 12, targetWeightKg: 20, completed: false },
            { setNumber: 2, targetReps: 12, targetWeightKg: 20, completed: false },
            { setNumber: 3, targetReps: 12, targetWeightKg: 20, completed: false },
          ],
        },
      ],
    },
    nutrition: {
      targetCalories: 2200,
      targetProteinG: 160,
      meals: [],
    },
    recovery: {
      sleepHours: 7.5,
      sleepQuality: 8,
      muscleSoreness: 2,
    },
  };

  test("Command Registry registers all domain commands and rejects unknowns", async () => {
    const list = defaultCommandRegistry.list();
    assert.ok(list.length >= 10, "Registry should have at least 10 commands registered");
    assert.ok(defaultCommandRegistry.get("workout.substituteExercise"), "Should find substitute command");
    assert.ok(defaultCommandRegistry.get("workout.adjustVolume"), "Should find adjust volume command");
    assert.ok(defaultCommandRegistry.get("nutrition.logMeal"), "Should find log meal command");
    assert.ok(defaultCommandRegistry.get("profile.updateEquipment"), "Should find update equipment command");

    // Unknown command
    const mockDb = createMockFirestore() as any;
    const resCtx = buildResolutionContext(mockUid, todayStr, baselineState, undefined, mockDb);
    const execCtx: ExecutionContext = { uid: mockUid, db: mockDb, todayStr, userState: baselineState };

    await assert.rejects(
      async () => {
        await defaultCommandRegistry.executeCommand("unknown.fakeCommand", {}, resCtx, execCtx);
      },
      /Unknown command/
    );
  });

  test("Target Resolution: Resolves 'this exercise', ordinals, and names", async () => {
    const mockDb = createMockFirestore() as any;

    // 1. Ordinal resolution
    const ctxOrdinal = buildResolutionContext(mockUid, todayStr, baselineState, undefined, mockDb);
    const first = ctxOrdinal.resolveExerciseTarget("the first exercise");
    assert.equal(first?.exercise.name, "Barbell Back Squat");

    const second = ctxOrdinal.resolveExerciseTarget("the second exercise");
    assert.equal(second?.exercise.name, "Bulgarian Split Squat");

    const last = ctxOrdinal.resolveExerciseTarget("the last exercise");
    assert.equal(last?.exercise.name, "Dumbbell Romanian Deadlift");

    // 2. Name resolution
    const byName = ctxOrdinal.resolveExerciseTarget("Bulgarian split squat");
    assert.equal(byName?.exercise.name, "Bulgarian Split Squat");

    // 3. Pronoun resolution via Context Envelope
    const ctxEnvelope = buildResolutionContext(
      mockUid,
      todayStr,
      baselineState,
      { activeScreen: "workout", focusedExerciseId: "ex_2", focusedExerciseName: "Bulgarian Split Squat" },
      mockDb
    );
    const implicit = ctxEnvelope.resolveExerciseTarget("this exercise");
    assert.equal(implicit?.exercise.name, "Bulgarian Split Squat");

    const itPronoun = ctxEnvelope.resolveExerciseTarget("it");
    assert.equal(itPronoun?.exercise.name, "Bulgarian Split Squat");
  });

  // ─── Test Scenario 1 (From User Specification) ───────────────────
  test("Test 1: Screen: WorkoutScreen, Focused: 'Bulgarian Split Squat', Prompt: 'This hurts my knee, swap it'", async () => {
    const mockDb = createMockFirestore() as any;
    mockDb.store[`users/${mockUid}/workouts/${todayStr}`] = JSON.parse(JSON.stringify(baselineState.workout));
    const envelope = {
      activeScreen: "workout",
      focusedExerciseId: "ex_2",
      focusedExerciseName: "Bulgarian Split Squat",
    };
    const resCtx = buildResolutionContext(mockUid, todayStr, baselineState, envelope, mockDb);
    const execCtx: ExecutionContext = { uid: mockUid, db: mockDb, todayStr, userState: baselineState, envelope };

    const { preview, result } = await defaultCommandRegistry.executeCommand(
      "workout.substituteExercise",
      {
        targetExercise: "this exercise",
        reason: "knee pain",
      },
      resCtx,
      execCtx
    );

    // Target resolved to focused exercise (Bulgarian Split Squat)
    assert.equal(preview.changes[0].target, "Bulgarian Split Squat");
    // Replacement is knee-friendly alternative (e.g. Dumbbell Box Step-Up or Goblet Squat)
    assert.ok(
      result.exercises[1].name.includes("Step-Up") || result.exercises[1].name.includes("Goblet Squat"),
      `Expected knee-friendly replacement, got ${result.exercises[1].name}`
    );
    // Set structure preserved (3 sets x 10 reps)
    assert.equal(result.exercises[1].sets.length, 3);
    assert.equal(result.exercises[1].sets[0].targetReps, 10);
    // Preview returned diff
    assert.ok(preview.changes[0].before.includes("Bulgarian Split Squat"));
    assert.ok(preview.changes[0].after.includes("Step-Up") || preview.changes[0].after.includes("Goblet"));
  });

  // ─── Test Scenario 2 (From User Specification) ───────────────────
  test("Test 2: Prompt: 'I\\'m exhausted, take it easy today'", async () => {
    const mockDb = createMockFirestore() as any;
    const resCtx = buildResolutionContext(mockUid, todayStr, baselineState, undefined, mockDb);
    const execCtx: ExecutionContext = { uid: mockUid, db: mockDb, todayStr, userState: baselineState };

    const { preview, result } = await defaultCommandRegistry.executeCommand(
      "workout.adapt",
      {
        reason: "I'm exhausted, take it easy today",
      },
      resCtx,
      execCtx
    );

    assert.equal(preview.commandName, "workout.adapt");
    assert.equal(preview.risk, "low");
    assert.ok(preview.summary.includes("deload") || preview.summary.includes("Adapted"));
    // Verify volume was deterministically reduced (fewer sets or trimmed weights)
    const originalSetCount = baselineState.workout.exercises.reduce((sum, e) => sum + e.sets.length, 0);
    const newSetCount = result.exercises.reduce((sum: number, e: any) => sum + e.sets.length, 0);
    assert.ok(newSetCount <= originalSetCount, "Expected volume reduction");
  });

  // ─── Test Scenario 3 (From User Specification) ───────────────────
  test("Test 3: Prompt: 'Ate 3 eggs and slept 6 hours' (Multi-Command)", async () => {
    const mockDb = createMockFirestore() as any;
    const resCtx = buildResolutionContext(mockUid, todayStr, baselineState, undefined, mockDb);
    const execCtx: ExecutionContext = { uid: mockUid, db: mockDb, todayStr, userState: baselineState };

    const incomingCommands = [
      {
        name: "nutrition.logMeal",
        parameters: {
          meals: [{ name: "3 eggs", calories: 225, proteinG: 18, carbsG: 2, fatG: 15 }],
        },
      },
      {
        name: "recovery.log",
        parameters: {
          sleepHours: 6,
        },
      },
    ];

    const chainResult = await defaultCommandRegistry.executeChain(incomingCommands, resCtx, execCtx);

    assert.equal(chainResult.executedCommands.length, 2);
    assert.equal(chainResult.previews.length, 2);
    assert.equal(chainResult.previews[0].commandName, "nutrition.logMeal");
    assert.equal(chainResult.previews[1].commandName, "recovery.log");
    assert.ok(chainResult.previews[0].summary.includes("3 eggs"));
    assert.ok(chainResult.previews[1].summary.includes("6h sleep"));
  });

  // ─── Test Scenario 4 (From User Specification) ───────────────────
  test("Test 4: Prompt: 'Bought a 20kg kettlebell and train 4 days a week' (High Risk Safety Gate)", async () => {
    const mockDb = createMockFirestore() as any;
    const resCtx = buildResolutionContext(mockUid, todayStr, baselineState, undefined, mockDb);
    const execCtx: ExecutionContext = { uid: mockUid, db: mockDb, todayStr, userState: baselineState };

    const incomingCommands = [
      {
        name: "profile.updateEquipment",
        parameters: {
          items: [{ name: "20kg kettlebell", category: "free_weight", weightKg: 20 }],
        },
      },
      {
        name: "profile.updateSchedule",
        parameters: {
          daysPerWeek: 4,
        },
      },
    ];

    const chainResult = await defaultCommandRegistry.executeChain(incomingCommands, resCtx, execCtx);

    assert.equal(chainResult.executedCommands.length, 2);
    assert.equal(chainResult.previews[0].risk, "high");
    assert.equal(chainResult.previews[1].risk, "high");

    // Both must create pending actions requiring explicit confirmation
    assert.equal(chainResult.pendingActions.length, 2);
    assert.equal(chainResult.pendingActions[0].actionType, "updateEquipment");
    assert.equal(chainResult.pendingActions[1].actionType, "updateSchedule");
    assert.equal(chainResult.pendingActions[0].status, "pending");
  });

  // ─── Test Scenario 5 (From User Specification) ───────────────────
  test("Test 5: From different screen: 'Make it 5kg heavier' (Context Envelope Resolution)", async () => {
    const mockDb = createMockFirestore() as any;
    mockDb.store[`users/${mockUid}/workouts/${todayStr}`] = JSON.parse(JSON.stringify(baselineState.workout));
    // User is on 'workout' or 'today' screen focusing on Bulgarian Split Squat
    const envelope = {
      activeScreen: "workout",
      focusedExerciseId: "ex_2",
      focusedExerciseName: "Bulgarian Split Squat",
    };
    const resCtx = buildResolutionContext(mockUid, todayStr, baselineState, envelope, mockDb);
    const execCtx: ExecutionContext = { uid: mockUid, db: mockDb, todayStr, userState: baselineState, envelope };

    const { preview, result } = await defaultCommandRegistry.executeCommand(
      "workout.adjustVolume",
      {
        targetExercise: "it",
        deltaWeightKg: 5,
      },
      resCtx,
      execCtx
    );

    assert.equal(preview.commandName, "workout.adjustVolume");
    assert.equal(preview.changes[0].target, "Bulgarian Split Squat");
    // Original weight was 16kg -> new weight should be 21kg
    assert.equal(result.exercises[1].sets[0].targetWeightKg, 21);
    assert.ok(preview.changes[0].description.includes("+5kg"));
  });
});
