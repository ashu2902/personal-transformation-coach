import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/models.dart';
import '../providers/transformation_state.dart';
import '../providers/analytics_provider.dart';
import '../services/analytics_service.dart';
import '../theme/theme.dart';
import '../widgets/common/common.dart';
import 'widgets/aura_orb.dart';
import 'widgets/curated_meal_card.dart';

class MealCurationScreen extends ConsumerStatefulWidget {
  const MealCurationScreen({super.key});

  @override
  ConsumerState<MealCurationScreen> createState() => _MealCurationScreenState();
}

class _MealChatMessage {
  final String sender; // 'coach' or 'user'
  final String text;
  final DateTime timestamp;
  final CuratedMealPlan? plan;
  final List<String> quickReplies;

  const _MealChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.plan,
    this.quickReplies = const [],
  });

  Map<String, dynamic> toHistoryMap() {
    return {
      'sender': sender,
      'text': text,
    };
  }
}

class _MealCurationScreenState extends ConsumerState<MealCurationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_MealChatMessage> _messages = [];
  bool _isGenerating = false;
  List<String> _currentQuickReplies = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initConversation();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initConversation() {
    final state = ref.read(transformationEngineProvider);
    final soul = state.profile.coachSoul;
    final workout = state.workout;
    final nutrition = state.nutrition;

    // Log Mixpanel event
    ref.read(analyticsServiceProvider).logEvent(
      AuraAnalyticsEvents.mealCurationStarted,
      properties: {
        'today_workout': workout.title,
        'target_calories': nutrition.targetCalories,
        'target_protein_g': nutrition.targetProteinG,
        'coach_soul': soul.name,
      },
    );

    if (nutrition.curatedMealPlan != null) {
      final existingPlan = nutrition.curatedMealPlan!;
      final greeting = _getSoulWelcomeBackGreeting(soul, workout, existingPlan);
      setState(() {
        _messages.add(
          _MealChatMessage(
            sender: 'coach',
            text: greeting,
            timestamp: DateTime.now(),
            plan: existingPlan,
            quickReplies: [
              'Swap to lighter meals',
              'Increase protein portions',
              'Quick 15-min prep options',
              'Start fresh with new plan',
            ],
          ),
        );
        _currentQuickReplies = [
          'Swap to lighter meals',
          'Increase protein portions',
          'Quick 15-min prep options',
          'Start fresh with new plan',
        ];
      });
    } else {
      final initialGreeting = _getSoulInitialGreeting(soul, workout, nutrition);
      final defaultChips = [
        '3 meals + 1 shake',
        '2 large meals (IF)',
        '4 balanced meals',
        'Quick 15-min prep',
        'High protein focus',
      ];
      setState(() {
        _messages.add(
          _MealChatMessage(
            sender: 'coach',
            text: initialGreeting,
            timestamp: DateTime.now(),
            quickReplies: defaultChips,
          ),
        );
        _currentQuickReplies = defaultChips;
      });
    }
  }

  String _getSoulInitialGreeting(CoachSoul soul, DailyWorkout workout, DailyNutrition nutrition) {
    final isRest = workout.isRestDay;
    final workoutInfo = isRest
        ? 'Rest & Active Recovery'
        : '${workout.title} (${workout.focusArea})';

    switch (soul) {
      case CoachSoul.supporter:
        return 'Hey! For today\'s **$workoutInfo**, we have a target of **${nutrition.targetCalories} kcal** and **${nutrition.targetProteinG}g protein**.\n\n'
            'How would you like to structure your meals today? Feel free to pick how many meals feel easiest, or mention any cravings or schedule constraints!';
      case CoachSoul.pro:
        return 'Locked in for **$workoutInfo**. Metabolic target: **${nutrition.targetCalories} kcal**, **${nutrition.targetProteinG}g protein**.\n\n'
            'Tell me your preferred feeding window and meal frequency so we can dial in your fuel distribution with zero wasted calories.';
      case CoachSoul.teacher:
        return 'To optimize muscle protein synthesis and energy substrates for **$workoutInfo**, our baseline requires **${nutrition.targetCalories} kcal** with **${nutrition.targetProteinG}g protein**.\n\n'
            'How many meals would you like to divide this across today, and do you have any specific food or timing preferences?';
    }
  }

  String _getSoulWelcomeBackGreeting(CoachSoul soul, DailyWorkout workout, CuratedMealPlan plan) {
    switch (soul) {
      case CoachSoul.supporter:
        return 'Here is your active curated meal plan for today! You have **${plan.meals.length} meals** planned (${plan.totalCalories} kcal, ${plan.totalProteinG}g protein).\n\n'
            'Want to make any tweaks, swap an ingredient, or are you ready to conquer the day?';
      case CoachSoul.pro:
        return 'Current fuel protocol loaded: **${plan.meals.length} meals** calibrated for **${workout.title}**.\n\n'
            'Review below. If you need any macro reallocation or substitution, let me know.';
      case CoachSoul.teacher:
        return 'Here is your current physiological fueling strategy for **${workout.title}** totaling **${plan.totalCalories} kcal** and **${plan.totalProteinG}g protein**.\n\n'
            'Let me know if you\'d like to adjust the macronutrient distribution or prep complexity.';
    }
  }

  void _sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || _isGenerating) return;

    _textController.clear();
    setState(() {
      _messages.add(
        _MealChatMessage(
          sender: 'user',
          text: cleanText,
          timestamp: DateTime.now(),
        ),
      );
      _isGenerating = true;
      _currentQuickReplies = [];
    });
    _scrollToBottom();

    try {
      final historyList = _messages.map((m) => m.toHistoryMap()).toList();
      final result = await ref
          .read(transformationEngineProvider.notifier)
          .sendMealCurationMessage(cleanText, history: historyList);

      if (!mounted) return;

      setState(() {
        _isGenerating = false;
        _messages.add(
          _MealChatMessage(
            sender: 'coach',
            text: result.coachResponse,
            timestamp: DateTime.now(),
            plan: result.curatedMealPlan,
            quickReplies: result.dynamicQuickReplies,
          ),
        );
        _currentQuickReplies = result.dynamicQuickReplies;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _messages.add(
          _MealChatMessage(
            sender: 'coach',
            text: 'I ran into an issue connecting to your metabolic plan: $e. Please try again!',
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transformationEngineProvider);
    final soul = state.profile.coachSoul;
    final auraTheme = context.auraTheme;
    final workout = state.workout;
    final nutrition = state.nutrition;

    return Scaffold(
      backgroundColor: auraTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: auraTheme.surfaceCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Curate Today\'s Meals',
              style: AuraTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${nutrition.targetCalories} kcal • ${nutrition.targetProteinG}g P • ${workout.isRestDay ? 'Rest' : workout.title}',
              style: AuraTypography.bodySmall.copyWith(
                color: auraTheme.primary,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: AuraOrb(
                soul: soul,
                state: _isGenerating ? OrbState.pulsing : OrbState.idle,
                size: 32,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Context Banner (Workout & Macro targets)
            _buildContextBanner(context, workout, nutrition, auraTheme),

            // Chat Message Stream
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: _messages.length + (_isGenerating ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isGenerating) {
                    return _buildThinkingBubble(context, soul, auraTheme);
                  }
                  final msg = _messages[index];
                  return _buildMessageItem(context, msg, soul, auraTheme);
                },
              ),
            ),

            // Quick Reply Suggestions
            if (_currentQuickReplies.isNotEmpty && !_isGenerating)
              Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _currentQuickReplies.length,
                  itemBuilder: (ctx, idx) {
                    final chipText = _currentQuickReplies[idx];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        backgroundColor: auraTheme.surfaceCard,
                        side: BorderSide(
                          color: auraTheme.primary.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        label: Text(
                          chipText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: auraTheme.primary,
                          ),
                        ),
                        onPressed: () => _sendMessage(chipText),
                      ),
                    );
                  },
                ),
              ),

            // Bottom Input Bar
            _buildInputBar(context, auraTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildContextBanner(
    BuildContext context,
    DailyWorkout workout,
    DailyNutrition nutrition,
    AuraThemeExtension auraTheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: auraTheme.surfaceCard,
        border: const Border(
          bottom: BorderSide(color: AuraColors.borderSubtle),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                workout.isRestDay ? LucideIcons.moonStar : LucideIcons.dumbbell,
                size: 13,
                color: workout.isRestDay ? AuraColors.textTertiary : auraTheme.primary,
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.45),
                child: Text(
                  workout.isRestDay ? 'Rest / Active Recovery' : workout.title,
                  style: AuraTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AuraColors.textPrimary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildMiniMacroBadge('${nutrition.targetCalories} kcal', auraTheme.energyAccent),
              const SizedBox(width: 4),
              _buildMiniMacroBadge('${nutrition.targetProteinG}g P', auraTheme.proteinAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMacroBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    _MealChatMessage msg,
    CoachSoul soul,
    AuraThemeExtension auraTheme,
  ) {
    final isCoach = msg.sender == 'coach';

    if (!isCoach) {
      // User message
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: auraTheme.primary.withValues(alpha: 0.18),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(
              color: auraTheme.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            msg.text,
            style: AuraTypography.bodyMedium.copyWith(
              color: AuraColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Coach message
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuraOrb(
                soul: soul,
                state: OrbState.idle,
                size: 26,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: auraTheme.surfaceCard,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: AuraColors.borderSubtle),
                  ),
                  child: MarkdownBody(
                    data: msg.text,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      p: AuraTypography.bodyMedium.copyWith(
                        color: AuraColors.textPrimary,
                        height: 1.4,
                      ),
                      strong: AuraTypography.bodyMedium.copyWith(
                        color: auraTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // If this message delivered or contains a CuratedMealPlan
          if (msg.plan != null) ...[
            const SizedBox(height: 12),
            _buildCuratedPlanPreview(context, msg.plan!, auraTheme),
          ],
        ],
      ),
    );
  }

  Widget _buildCuratedPlanPreview(
    BuildContext context,
    CuratedMealPlan plan,
    AuraThemeExtension auraTheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 34, top: 4, bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: auraTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: auraTheme.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(LucideIcons.sparkles, size: 15, color: auraTheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        plan.title,
                        style: AuraTypography.titleMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: auraTheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AuraColors.actionGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.checkCheck, size: 12, color: AuraColors.actionGreen),
                    const SizedBox(width: 4),
                    Text(
                      'ACTIVE ON BOARD',
                      style: AuraTypography.sectionHeader.copyWith(
                        fontSize: 9,
                        color: AuraColors.actionGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (plan.overview.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              plan.overview,
              style: AuraTypography.bodySmall.copyWith(
                color: AuraColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Macro Totals Summary Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: auraTheme.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroTotal('${plan.totalCalories} kcal', 'TOTAL CAL', auraTheme.energyAccent),
                _buildMacroTotal('${plan.totalProteinG}g', 'PROTEIN', auraTheme.proteinAccent),
                _buildMacroTotal('${plan.totalCarbsG}g', 'CARBS', AuraColors.carbs),
                _buildMacroTotal('${plan.totalFatG}g', 'FAT', AuraColors.fat),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Meal Cards List
          ...plan.meals.map((meal) {
            return CuratedMealCard(
              meal: meal,
              onLog: () {
                ref.read(transformationEngineProvider.notifier).logCuratedMeal(meal);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logged ${meal.name} (+${meal.calories} kcal) to today\'s fuel!'),
                    backgroundColor: auraTheme.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
                setState(() {});
              },
            );
          }),

          const SizedBox(height: 6),
          // Action Button: Done & View on Board
          AuraButton(
            text: 'Done & Return to Today\'s Board',
            icon: LucideIcons.check,
            variant: AuraButtonVariant.primary,
            width: double.infinity,
            height: 44,
            borderRadius: 10,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMacroTotal(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AuraTypography.bodySmall.copyWith(
            fontSize: 9,
            color: AuraColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildThinkingBubble(
    BuildContext context,
    CoachSoul soul,
    AuraThemeExtension auraTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          AuraOrb(
            soul: soul,
            state: OrbState.pulsing,
            size: 26,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: auraTheme.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AuraColors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(auraTheme.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AURA is calibrating your meals...',
                  style: AuraTypography.bodySmall.copyWith(
                    color: AuraColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, AuraThemeExtension auraTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: auraTheme.surfaceCard,
        border: const Border(
          top: BorderSide(color: AuraColors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              textCapitalization: TextCapitalization.sentences,
              style: AuraTypography.bodyMedium.copyWith(color: AuraColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Describe meal preferences or ask for changes...',
                hintStyle: AuraTypography.bodySmall.copyWith(color: AuraColors.textDisabled),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: auraTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AuraColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AuraColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: auraTheme.primary),
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isGenerating ? null : () => _sendMessage(_textController.text),
            icon: Icon(
              LucideIcons.send,
              color: _isGenerating ? AuraColors.textDisabled : auraTheme.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
