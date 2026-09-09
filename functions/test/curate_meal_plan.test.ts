import { test, describe } from "node:test";
import assert from "node:assert/strict";
import { extractCleanJson } from "../src/aiGateway";

describe("Meal Plan Curation Conversational Flow Tests", () => {

  test("Turn 1: Initial conversation initiates linear data gathering without forcing rigid meal template", () => {
    // Simulated realistic response from AI Gateway for Turn 1
    const rawAiOutputTurn1 = `<think>
The user wants to curate meals for today. They haven't specified meal frequency, prep time or preferences yet.
I need to ask a friendly, coaching question with quick replies and not finalize the plan yet.
</think>
{
  "coachResponse": "Hey Alex! Let's dial in your fuel for today's Push Day. To make sure this fits your schedule, how would you like to space your meals today?",
  "dynamicQuickReplies": [
    "3 meals + 1 snack",
    "2 large meals + protein shake",
    "Quick 15-min meals",
    "High-protein post-workout focus"
  ],
  "isFinalPlan": false
}`;

    const cleaned = extractCleanJson(rawAiOutputTurn1);
    const parsed = JSON.parse(cleaned);

    assert.equal(parsed.isFinalPlan, false);
    assert.ok(parsed.coachResponse.includes("Alex"));
    assert.ok(Array.isArray(parsed.dynamicQuickReplies));
    assert.equal(parsed.dynamicQuickReplies.length, 4);
    assert.ok(parsed.dynamicQuickReplies.includes("3 meals + 1 snack"));
  });

  test("Turn 2: User specifies meal structure -> Generates complete curated plan matching targets", () => {
    // User picked "3 meals + 1 snack" and wanted quick meals
    const rawAiOutputTurn2 = `<think>
User selected 3 meals + 1 snack with quick preparation.
Target macros: 2400 kcal, 165g protein.
Workout: Push Day (Chest, Shoulders & Triceps).
We need to time carbohydrates and protein around the workout.
Meal 1: High protein breakfast (eggs, oats, whey) - 620 kcal, 45g protein.
Meal 2: Post-workout lunch (chicken breast, rice, greens) - 750 kcal, 55g protein.
Meal 3: Mid-afternoon high-protein snack (Greek yogurt, almonds, berries) - 380 kcal, 30g protein.
Meal 4: Balanced dinner (salmon or lean beef, sweet potato, asparagus) - 650 kcal, 40g protein.
Total Calories = 620 + 750 + 380 + 650 = 2400 kcal (exact target match!)
Total Protein = 45 + 55 + 30 + 40 = 170g protein (~165g target).
</think>
{
  "coachResponse": "Here is your customized fuel strategy for Push Day! We've built 3 high-impact meals plus a power snack to keep your energy high and support muscle protein synthesis.",
  "dynamicQuickReplies": ["Looks great!", "Can I swap the lunch?", "Adjust portion sizes"],
  "isFinalPlan": true,
  "curatedMealPlan": {
    "title": "Push Day Hypertrophy Fuel",
    "overview": "Timed carbohydrate surge pre/post workout with 170g lean protein distributed evenly across 4 feeding windows.",
    "totalCalories": 2400,
    "totalProteinG": 170,
    "totalCarbsG": 245,
    "totalFatG": 68,
    "meals": [
      {
        "id": "meal_1",
        "name": "Power Egg & Berry Oats",
        "slotName": "Pre-Workout Breakfast",
        "description": "3 whole eggs scrambled with spinach, plus 60g rolled oats cooked with 1 scoop vanilla whey and blueberries.",
        "calories": 620,
        "proteinG": 45,
        "carbsG": 65,
        "fatG": 18,
        "prepTime": "12 mins",
        "instructions": "Whisk eggs in a pan on medium heat. Microwave oats for 90 seconds, then stir in protein powder.",
        "tags": ["High Protein", "Sustained Energy"]
      },
      {
        "id": "meal_2",
        "name": "Grilled Chicken Rice Bowl",
        "slotName": "Post-Workout Lunch",
        "description": "200g seasoned chicken breast, 1.5 cups jasmine rice, and steamed zucchini with olive oil drizzle.",
        "calories": 750,
        "proteinG": 55,
        "carbsG": 90,
        "fatG": 16,
        "prepTime": "15 mins",
        "instructions": "Pan-sear chicken strips with paprika and garlic. Serve warm over pre-cooked jasmine rice.",
        "tags": ["Post-Workout Anabolic Window", "Clean Carb Re-feed"]
      },
      {
        "id": "meal_3",
        "name": "Greek Yogurt Berry Crunch",
        "slotName": "Afternoon Recovery Snack",
        "description": "250g plain 0% Greek yogurt, 25g raw almonds, and 1 tbsp honey.",
        "calories": 380,
        "proteinG": 30,
        "carbsG": 30,
        "fatG": 14,
        "prepTime": "3 mins",
        "instructions": "Scoop Greek yogurt into a bowl, top with crushed almonds and a light honey drizzle.",
        "tags": ["Zero Prep", "Slow Digesting Casein"]
      },
      {
        "id": "meal_4",
        "name": "Pan-Seared Salmon & Roast Sweet Potato",
        "slotName": "Evening Fuel",
        "description": "180g Atlantic salmon fillet, 200g baked sweet potato cubes, and roasted green beans.",
        "calories": 650,
        "proteinG": 40,
        "carbsG": 60,
        "fatG": 20,
        "prepTime": "20 mins",
        "instructions": "Sear salmon skin-side down for 4 mins, flip for 3 mins. Pair with microwave-steamed sweet potatoes.",
        "tags": ["Omega-3 Rich", "Overnight Muscle Recovery"]
      }
    ]
  }
}`;

    const cleaned = extractCleanJson(rawAiOutputTurn2);
    const parsed = JSON.parse(cleaned);

    assert.equal(parsed.isFinalPlan, true);
    assert.ok(parsed.curatedMealPlan);
    assert.equal(parsed.curatedMealPlan.meals.length, 4);
    assert.equal(parsed.curatedMealPlan.totalCalories, 2400);
    assert.equal(parsed.curatedMealPlan.totalProteinG, 170);

    // Validate meal macro sums match aggregate
    const computedCal = parsed.curatedMealPlan.meals.reduce((sum: number, m: any) => sum + m.calories, 0);
    const computedProt = parsed.curatedMealPlan.meals.reduce((sum: number, m: any) => sum + m.proteinG, 0);
    assert.equal(computedCal, 2400);
    assert.equal(computedProt, 170);

    // Verify all meals have required fields
    for (const meal of parsed.curatedMealPlan.meals) {
      assert.ok(meal.name.length > 0);
      assert.ok(meal.slotName.length > 0);
      assert.ok(meal.description.length > 0);
      assert.ok(meal.prepTime.length > 0);
      assert.ok(meal.instructions.length > 0);
      assert.ok(meal.tags.length > 0);
      assert.ok(meal.calories > 0);
      assert.ok(meal.proteinG > 0);
    }
  });
});
