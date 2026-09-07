import { CommandDefinition, CommandPreview, ExecutionContext, ResolutionContext } from "./types";
import {
  workoutSubstituteExerciseCommand,
  workoutAdjustVolumeCommand,
  workoutAdaptCommand,
  workoutUpdateStatusCommand,
} from "./workoutCommands";
import {
  nutritionLogMealCommand,
  nutritionUpdatePortionCommand,
  nutritionRemoveMealCommand,
} from "./nutritionCommands";
import { recoveryLogCommand } from "./recoveryCommands";
import {
  profileUpdateEquipmentCommand,
  profileUpdateInjuriesCommand,
  profileUpdateGoalCommand,
  profileUpdateScheduleCommand,
  profileLogWeightCommand,
} from "./profileCommands";

export class CommandRegistry {
  private commands: Map<string, CommandDefinition> = new Map();
  private aliasMap: Map<string, string> = new Map();

  constructor() {
    this.registerDefaults();
  }

  private registerDefaults() {
    // Workout
    this.register(workoutSubstituteExerciseCommand);
    this.register(workoutAdjustVolumeCommand);
    this.register(workoutAdaptCommand);
    this.register(workoutUpdateStatusCommand);

    // Nutrition
    this.register(nutritionLogMealCommand);
    this.register(nutritionUpdatePortionCommand);
    this.register(nutritionRemoveMealCommand);

    // Recovery
    this.register(recoveryLogCommand);

    // Profile
    this.register(profileUpdateEquipmentCommand);
    this.register(profileUpdateInjuriesCommand);
    this.register(profileUpdateGoalCommand);
    this.register(profileUpdateScheduleCommand);
    this.register(profileLogWeightCommand);

    // Backward-compatibility aliases for legacy action names
    this.aliasMap.set("adaptWorkout", "workout.adapt");
    this.aliasMap.set("substituteExercise", "workout.substituteExercise");
    this.aliasMap.set("adjustVolume", "workout.adjustVolume");
    this.aliasMap.set("logNutrition", "nutrition.logMeal");
    this.aliasMap.set("updateMealPortion", "nutrition.updatePortion");
    this.aliasMap.set("removeMeal", "nutrition.removeMeal");
    this.aliasMap.set("logRecovery", "recovery.log");
    this.aliasMap.set("updateWorkoutStatus", "workout.updateStatus");
    this.aliasMap.set("updateEquipment", "profile.updateEquipment");
    this.aliasMap.set("updateInjuries", "profile.updateInjuries");
    this.aliasMap.set("updateGoal", "profile.updateGoal");
    this.aliasMap.set("updateSchedule", "profile.updateSchedule");
    this.aliasMap.set("logWeight", "profile.logWeight");
  }

  public register(cmd: CommandDefinition) {
    this.commands.set(cmd.name, cmd);
  }

  public get(name: string): CommandDefinition | undefined {
    const resolvedName = this.aliasMap.get(name) || name;
    return this.commands.get(resolvedName);
  }

  public list(): CommandDefinition[] {
    return Array.from(this.commands.values());
  }

  /**
   * Generates prompt documentation describing all available commands for Gemini.
   */
  public getToolDocumentation(): string {
    return this.list()
      .map(
        (cmd) =>
          `- ${cmd.name} (risk: ${cmd.risk}, category: ${cmd.category}): ${cmd.summary}`
      )
      .join("\n");
  }

  /**
   * Execute a single command through the 3-phase pipeline.
   */
  public async executeCommand(
    rawName: string,
    rawParameters: any,
    resCtx: ResolutionContext,
    execCtx: ExecutionContext
  ): Promise<{
    preview: CommandPreview;
    result?: any;
    pendingAction?: any;
  }> {
    const cmd = this.get(rawName);
    if (!cmd) {
      throw new Error(`Unknown command: '${rawName}'`);
    }

    // Phase 1: Input schema validation
    const parseResult = cmd.inputSchema.safeParse(rawParameters || {});
    if (!parseResult.success) {
      const issues = parseResult.error.issues.map((i) => `${i.path.join(".")}: ${i.message}`).join(", ");
      throw new Error(`Malformed input for '${cmd.name}': ${issues}`);
    }
    const validatedInput = parseResult.data;

    // Phase 2: Natural language resolution and preview diff generation
    const resolved = await cmd.resolve(validatedInput, resCtx);
    const preview = await cmd.preview(resolved, resCtx);

    // Phase 3: Governed Execution
    const execResult = await cmd.execute(resolved, execCtx);

    if (execResult.pendingAction) {
      preview.pendingActionId = execResult.pendingAction.id;
    }

    return {
      preview,
      result: execResult.result,
      pendingAction: execResult.pendingAction,
    };
  }

  /**
   * Execute a chain of multiple commands sequentially in one user turn.
   */
  public async executeChain(
    incomingCommands: Array<{ name?: string; functionName?: string; parameters?: any; arguments?: any }>,
    resCtx: ResolutionContext,
    execCtx: ExecutionContext
  ): Promise<{
    previews: CommandPreview[];
    pendingActions: any[];
    executedCommands: string[];
    errors?: Array<{ command: string; error: string }>;
  }> {
    const previews: CommandPreview[] = [];
    const pendingActions: any[] = [];
    const executedCommands: string[] = [];
    const errors: Array<{ command: string; error: string }> = [];

    for (const item of incomingCommands) {
      const name = item.name || item.functionName;
      const params = item.parameters || item.arguments || {};
      if (!name) continue;

      try {
        const { preview, pendingAction } = await this.executeCommand(name, params, resCtx, execCtx);
        previews.push(preview);
        executedCommands.push(preview.commandName);
        if (pendingAction) {
          pendingActions.push(pendingAction);
        }
      } catch (err: any) {
        console.error(`[COMMAND ERROR] ${name}:`, err);
        errors.push({ command: name, error: err?.message || String(err) });
      }
    }

    return {
      previews,
      pendingActions,
      executedCommands,
      errors: errors.length > 0 ? errors : undefined,
    };
  }
}

export const defaultCommandRegistry = new CommandRegistry();
