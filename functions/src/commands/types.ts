import * as admin from "firebase-admin";
import { z } from "zod";

export type CommandCategory = "workout" | "nutrition" | "recovery" | "profile";
export type CommandRisk = "low" | "high";

export interface ContextEnvelope {
  activeScreen?: string;          // 'workout', 'today', 'coach', 'profile', etc.
  focusedExerciseId?: string;     // e.g. 'ex_bb_squat', 'ex_bulgarian_split_squat'
  focusedExerciseName?: string;   // e.g. 'Bulgarian Split Squat'
  currentSetIndex?: number;       // 0-indexed or 1-indexed
  activeWorkoutDate?: string;     // 'YYYY-MM-DD'
  sessionElapsedSec?: number;
  todayWorkoutTitle?: string;
}

export interface CommandChange {
  target: string;
  description: string;
  before?: any;
  after?: any;
}

export interface CommandPreview {
  commandName: string;
  category: CommandCategory;
  risk: CommandRisk;
  summary: string;
  changes: CommandChange[];
  warnings?: string[];
  pendingActionId?: string;
}

export interface TargetExerciseResolution {
  exercise: any;
  index: number;
}

export interface ResolutionContext {
  uid: string;
  todayStr: string;
  userState: {
    profile: any;
    workout: any;
    nutrition: any;
    recovery: any;
  };
  envelope?: ContextEnvelope;
  db: admin.firestore.Firestore;
  resolveExerciseTarget: (targetNameOrPronoun?: string) => TargetExerciseResolution | null;
  resolveWorkoutTarget: (targetDateOrDescriptor?: string) => string;
  resolveSetTarget: (setIndexOrDescriptor?: string | number, exerciseIndex?: number) => number | null;
}

export interface ExecutionContext {
  uid: string;
  db: admin.firestore.Firestore;
  todayStr: string;
  userState: {
    profile: any;
    workout: any;
    nutrition: any;
    recovery: any;
  };
  envelope?: ContextEnvelope;
  lookupFoodMacros?: (foodName: string) => Promise<{ calories?: number; proteinG?: number; carbsG?: number; fatG?: number } | null>;
}

export interface CommandDefinition<TInput = any, TResolved = any> {
  name: string;
  category: CommandCategory;
  summary: string;
  risk: CommandRisk;
  inputSchema: z.ZodType<TInput>;
  resolve: (input: TInput, ctx: ResolutionContext) => Promise<TResolved>;
  preview: (resolved: TResolved, ctx: ResolutionContext) => Promise<CommandPreview>;
  execute: (resolved: TResolved, ctx: ExecutionContext) => Promise<{ success: boolean; result?: any; pendingAction?: any }>;
}
