import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/transformation_state.dart';
import '../providers/analytics_provider.dart';
import '../services/analytics_service.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/common/common.dart';
import 'widgets/aura_orb.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _showScrollToBottom = false;

  late AnimationController _thinkingAnimController;

  @override
  void initState() {
    super.initState();
    _thinkingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scrollController.addListener(() {
      final isScrolledUp = _scrollController.hasClients && _scrollController.offset > 120;
      if (isScrolledUp != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = isScrolledUp;
        });
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _thinkingAnimController.dispose();
    super.dispose();
  }

  List<String> _getChipsForSoul(CoachSoul soul) {
    switch (soul) {
      case CoachSoul.supporter:
        return [
          "My legs are really sore.",
          "Had paneer + roti for dinner.",
          "I'm feeling low energy today.",
          "Celebrate a small win!",
        ];
      case CoachSoul.pro:
        return [
          "My legs are really sore.",
          "Logged 650 kcal, 40g protein.",
          "Swap to active recovery walk.",
          "Lock in today's workout.",
        ];
      case CoachSoul.teacher:
        return [
          "Why did today's plan adapt?",
          "Explain my protein target.",
          "DOMS in lower quadriceps.",
          "Analyze my recovery load.",
        ];
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // In reverse mode, 0.0 is the bottom
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _inputController.clear();
    final notifier = ref.read(transformationEngineProvider.notifier);

    // Track chat message event in Mixpanel
    ref.read(analyticsServiceProvider).logEvent(
      AuraAnalyticsEvents.chatMessageSent,
      properties: {
        'input_type': 'text',
        'length': text.length,
        'coach_soul': ref.read(transformationEngineProvider).profile.coachSoul.name,
      },
    );

    _scrollToBottom();
    await notifier.addChatMessage(text);
    _scrollToBottom();
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      final caption = _inputController.text.trim();
      _inputController.clear();

      final notifier = ref.read(transformationEngineProvider.notifier);

      // Track image upload in Mixpanel
      ref.read(analyticsServiceProvider).logEvent(
        AuraAnalyticsEvents.chatMessageSent,
        properties: {
          'input_type': 'image',
          'source': source.name,
          'has_caption': caption.isNotEmpty,
          'coach_soul': ref.read(transformationEngineProvider).profile.coachSoul.name,
        },
      );

      _scrollToBottom();
      await notifier.addChatMessage(
        caption.isEmpty ? 'Uploaded an image for analysis' : caption,
        imageBytes: bytes,
        mimeType: 'image/jpeg',
      );
      _scrollToBottom();
    } catch (e) {
      debugPrint('[AURA IMAGE PICKER ERROR] $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load image: $e'),
            backgroundColor: AuraColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transformationEngineProvider);
    final isThinking = state.isAiThinking;
    final auraTheme = context.auraTheme;
    final soul = state.profile.coachSoul;
    final isAdapted = state.adaptationNotice != null && state.adaptationNotice!.isNotEmpty;
    final actionChips = _getChipsForSoul(soul);

    final totalCount = state.chatMessages.length + (isThinking ? 1 : 0);

    return Stack(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.maxFluidContentWidth),
            child: Column(
              children: [
            // 1. SLIM & NON-INTRUSIVE COACH STATUS BAR (Only ~46px)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: auraTheme.surfaceCard,
                border: const Border(bottom: BorderSide(color: AuraColors.borderSubtle)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Persona Status Pill
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: auraTheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: auraTheme.primary.withOpacity(0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        soul.displayName,
                        style: AuraTypography.labelBold.copyWith(
                          color: auraTheme.primary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAdapted
                              ? AuraColors.actionGreen.withOpacity(0.15)
                              : auraTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isAdapted
                                ? AuraColors.actionGreen.withOpacity(0.4)
                                : AuraColors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          isAdapted ? 'Adaptive Active' : 'Real-time AI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isAdapted ? AuraColors.actionGreen : AuraColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Quick Coach Persona Hub trigger
                  InkWell(
                    onTap: () => _showCoachHubModal(context, soul, state),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(LucideIcons.slidersHorizontal, size: 14, color: auraTheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Coach Hub',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: auraTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. CONVERSATION MESSAGE LIST (Natively Pinned to Bottom with reverse: true)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true, // Offset 0 is at bottom (latest messages)
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: totalCount,
                itemBuilder: (context, index) {
                  // If thinking, render the dynamic AI thinking indicator at the bottom (index 0)
                  if (isThinking && index == 0) {
                    return _buildThinkingBubble(auraTheme, soul);
                  }

                  // Chronological message mapping for reverse list
                  final messageIndex = isThinking ? index - 1 : index;
                  final msg = state.chatMessages[state.chatMessages.length - 1 - messageIndex];
                  final isAi = msg.sender == 'ai';

                  // Determine in-line cards
                  final lowerText = msg.text.toLowerCase();
                  final isAdviceOrSuggestion = lowerText.contains('budget available') ||
                      lowerText.contains('recommend') ||
                      lowerText.contains('suggest') ||
                      lowerText.contains('what should you') ||
                      lowerText.contains('prioritize') ||
                      lowerText.contains('combine') ||
                      lowerText.contains('options');

                  final isPlanAdjustment = isAi &&
                      (lowerText.contains('workout adapted') ||
                          lowerText.contains('revised session') ||
                          lowerText.contains('swapped exercise') ||
                          lowerText.contains('adapted today’s workout'));

                  final isMealLog = isAi &&
                      !isAdviceOrSuggestion &&
                      (lowerText.contains('logged meal') ||
                          lowerText.contains('meal recorded') ||
                          lowerText.contains('recorded your meal') ||
                          lowerText.contains('added to your food log') ||
                          lowerText.contains('logged:'));

                  if (isAi) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // In-Chat AURA Orb Avatar
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0, right: 10.0),
                            child: AuraOrb(
                              soul: soul,
                              state: isAdapted ? OrbState.adapting : OrbState.idle,
                              size: 28,
                            ),
                          ),

                          // AI Message Bubble
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (msg.imageBytes != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.memory(
                                          msg.imageBytes!,
                                          height: 190,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                  Text(
                                    msg.text,
                                    style: AuraTypography.bodyLarge.copyWith(
                                      color: AuraColors.textPrimary,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    msg.formattedTime,
                                    style: AuraTypography.bodySmall.copyWith(
                                      fontSize: 10,
                                      color: AuraColors.textTertiary,
                                    ),
                                  ),

                                  // IN-LINE CARD: Decision Card for Plan Adjustment
                                  if (isPlanAdjustment)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: auraTheme.surfaceLight,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                              color: AuraColors.actionGreen.withOpacity(0.4)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(LucideIcons.gitFork,
                                                    color: AuraColors.actionGreen, size: 15),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'ADAPTED WORKOUT',
                                                  style: AuraTypography.sectionHeader.copyWith(
                                                    color: AuraColors.actionGreen,
                                                    fontSize: 10,
                                                    letterSpacing: 1.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            const Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Lower Body Strength',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AuraColors.textSecondary,
                                                      decoration: TextDecoration.lineThrough,
                                                    ),
                                                  ),
                                                ),
                                                Icon(LucideIcons.arrowRight,
                                                    size: 14, color: AuraColors.actionGreen),
                                                SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Active Recovery Walk',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: AuraColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            AuraButton(
                                              text: 'Accept Revised Plan',
                                              variant: AuraButtonVariant.primary,
                                              backgroundColor: AuraColors.actionGreen,
                                              textColor: Colors.black,
                                              width: double.infinity,
                                              onPressed: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Revised workout locked in for today!'),
                                                    backgroundColor: AuraColors.actionGreen,
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  // IN-LINE CARD: Meal Confirmation Card
                                  if (isMealLog && !isPlanAdjustment)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: auraTheme.surfaceLight,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AuraColors.borderSubtle),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(LucideIcons.utensils,
                                                    size: 14, color: auraTheme.primary),
                                                const SizedBox(width: 6),
                                                const Text(
                                                  'Meal Recorded',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: AuraColors.textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                _buildCompactActionBtn(
                                                  label: 'Keep',
                                                  color: AuraColors.actionGreen,
                                                  onTap: () {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Meal entry confirmed!'),
                                                        duration: Duration(seconds: 1),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                const SizedBox(width: 6),
                                                _buildCompactActionBtn(
                                                  label: 'Edit',
                                                  color: AuraColors.textSecondary,
                                                  onTap: () {
                                                    ref.read(analyticsServiceProvider).logEvent(
                                                      AuraAnalyticsEvents.portionCorrected,
                                                      properties: {
                                                        'action': 'edit_requested',
                                                      },
                                                    );
                                                    _sendMessage('I want to adjust the portion size.');
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // User Message Bubble (Right aligned)
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.82,
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: auraTheme.primary.withOpacity(0.18),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(4),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border.all(
                          color: auraTheme.primary.withOpacity(0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (msg.imageBytes != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  msg.imageBytes!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          Text(
                            msg.text,
                            style: AuraTypography.bodyLarge.copyWith(
                              color: AuraColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg.formattedTime,
                            style: AuraTypography.bodySmall.copyWith(
                              fontSize: 10,
                              color: AuraColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 3. CONTEXTUAL ACTION CHIPS (Floating Above Input)
            if (!isThinking)
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: actionChips.length,
                  itemBuilder: (ctx, idx) {
                    final prompt = actionChips[idx];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        backgroundColor: auraTheme.surfaceCard,
                        side: const BorderSide(color: AuraColors.borderSubtle),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        labelStyle: AuraTypography.labelBold.copyWith(
                          color: auraTheme.primary,
                          fontSize: 11,
                        ),
                        label: Text(prompt),
                        onPressed: () => _sendMessage(prompt),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 6),

            // 4. BOTTOM INPUT BAR (Camera + Gallery + Text + Express Actions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  // Photo / Media Trigger
                  GestureDetector(
                    onTap: () => _showMediaOptionsModal(context),
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: auraTheme.surfaceCard,
                        shape: BoxShape.circle,
                        border: Border.all(color: AuraColors.borderSubtle),
                      ),
                      child: Icon(LucideIcons.camera, color: auraTheme.primary, size: 18),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Express Shortcuts Button
                  GestureDetector(
                    onTap: () => _showExpressActionsModal(context),
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: auraTheme.surfaceCard,
                        shape: BoxShape.circle,
                        border: Border.all(color: AuraColors.borderSubtle),
                      ),
                      child: const Icon(LucideIcons.plus, color: AuraColors.textSecondary, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Input Textfield
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      onSubmitted: _sendMessage,
                      style: AuraTypography.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Ask AURA anything...',
                        hintStyle: AuraTypography.bodyMedium.copyWith(color: AuraColors.textTertiary),
                        filled: true,
                        fillColor: auraTheme.surfaceCard,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AuraColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: auraTheme.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send Button
                  GestureDetector(
                    onTap: () => _sendMessage(_inputController.text),
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: const BoxDecoration(
                        color: AuraColors.actionGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.arrowUp, color: Colors.black, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),

        // FLOATING "SCROLL TO LATEST" BUTTON (Appears when scrolled up)
        if (_showScrollToBottom)
          Positioned(
            bottom: 74,
            right: 16,
            child: GestureDetector(
              onTap: _scrollToBottom,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: auraTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: auraTheme.primary.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Latest',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: auraTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(LucideIcons.arrowDown, size: 13, color: auraTheme.primary),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ─── IN-CHAT AI THINKING INDICATOR (Swirling Micro Orb + Animated Wave) ───
  Widget _buildThinkingBubble(AuraThemeExtension auraTheme, CoachSoul soul) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0, right: 10.0),
            child: AuraOrb(
              soul: soul,
              state: OrbState.thinking,
              size: 28,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: auraTheme.surfaceCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: auraTheme.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AURA is synthesizing',
                      style: AuraTypography.bodySmall.copyWith(
                        color: auraTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildAnimatedDots(auraTheme.primary),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Evaluating metabolic state & progressive load...',
                  style: TextStyle(
                    fontSize: 10,
                    color: AuraColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots(Color color) {
    return AnimatedBuilder(
      animation: _thinkingAnimController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final val = ((_thinkingAnimController.value + delay) % 1.0);
            final scale = 0.5 + (0.5 * (val < 0.5 ? val * 2 : (1.0 - val) * 2));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 4 * scale,
              height: 4 * scale,
              decoration: BoxDecoration(
                color: color.withOpacity(scale),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCompactActionBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  // ─── AURA COACH HUB MODAL (Change Soul & Context Snapshot) ───
  void _showCoachHubModal(BuildContext context, CoachSoul currentSoul, TransformationEngineState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.surface1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('AURA Coach Intelligence Hub', style: AuraTypography.titleLarge),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18, color: AuraColors.textSecondary),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Switch persona style and view what AURA is actively tracking.',
                  style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Soul Selector Cards
                Text('COACH PERSONA', style: AuraTypography.sectionHeader.copyWith(fontSize: 10)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildSoulOption(
                      ctx,
                      soul: CoachSoul.supporter,
                      isSelected: currentSoul == CoachSoul.supporter,
                      label: 'Supporter',
                      color: const Color(0xFFA779FF),
                    ),
                    const SizedBox(width: 8),
                    _buildSoulOption(
                      ctx,
                      soul: CoachSoul.pro,
                      isSelected: currentSoul == CoachSoul.pro,
                      label: 'The Pro',
                      color: const Color(0xFF00E5FF),
                    ),
                    const SizedBox(width: 8),
                    _buildSoulOption(
                      ctx,
                      soul: CoachSoul.teacher,
                      isSelected: currentSoul == CoachSoul.teacher,
                      label: 'Teacher',
                      color: const Color(0xFF00BFA5),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                Text('ACTIVE CONTEXT IN MEMORY', style: AuraTypography.sectionHeader.copyWith(fontSize: 10)),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AuraColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AuraColors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Current Goal', style: TextStyle(fontSize: 12, color: AuraColors.textSecondary)),
                          Text(state.profile.goal.displayName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuraColors.textPrimary)),
                        ],
                      ),
                      const Divider(height: 16, color: AuraColors.borderSubtle),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recovery Score', style: TextStyle(fontSize: 12, color: AuraColors.textSecondary)),
                          Text('${state.recovery.recoveryScore}% (${state.recovery.status})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuraColors.actionGreen)),
                        ],
                      ),
                      const Divider(height: 16, color: AuraColors.borderSubtle),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Equipment Detected', style: TextStyle(fontSize: 12, color: AuraColors.textSecondary)),
                          Text('${state.profile.equipmentList.length} items mapped', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuraColors.textPrimary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSoulOption(
    BuildContext ctx, {
    required CoachSoul soul,
    required bool isSelected,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(transformationEngineProvider.notifier).updateCoachSoul(soul);
          Navigator.of(ctx).pop();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.18) : AuraColors.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : AuraColors.borderSubtle,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              AuraOrb(soul: soul, state: isSelected ? OrbState.pulsing : OrbState.idle, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : AuraColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMediaOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.surface1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Share Image with AURA', style: AuraTypography.titleLarge),
                const SizedBox(height: 4),
                Text('AURA analyzes meals, nutrition labels, and progress check-ins.', style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(LucideIcons.camera, color: AuraColors.actionGreen),
                  title: const Text('Take Photo (Camera)', style: TextStyle(color: AuraColors.textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Snap meal plate or label right now', style: TextStyle(color: AuraColors.textSecondary, fontSize: 12)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickAndSendImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.image, color: AuraColors.auraPurple),
                  title: const Text('Choose from Gallery', style: TextStyle(color: AuraColors.textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Select an existing photo from your library', style: TextStyle(color: AuraColors.textSecondary, fontSize: 12)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickAndSendImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExpressActionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.surface1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Express Quick Actions', style: AuraTypography.titleLarge),
                const SizedBox(height: 4),
                Text('Fast operational shortcuts for your transformation.', style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(LucideIcons.utensils, color: AuraColors.actionGreen),
                  title: const Text('Log Meal / Snack', style: TextStyle(color: AuraColors.textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Describe in natural language for AI macro extraction', style: TextStyle(color: AuraColors.textSecondary, fontSize: 12)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _inputController.text = 'Had ';
                    _inputController.selection = TextSelection.fromPosition(TextPosition(offset: _inputController.text.length));
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.droplets, color: AuraColors.water),
                  title: const Text('Add Hydration (+250ml)', style: TextStyle(color: AuraColors.textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Instantly record water intake', style: TextStyle(color: AuraColors.textSecondary, fontSize: 12)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    ref.read(transformationEngineProvider.notifier).addWater(250);
                    _sendMessage('Logged +250ml of water hydration.');
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.activity, color: AuraColors.warningAmber),
                  title: const Text('Report Soreness or Fatigue', style: TextStyle(color: AuraColors.textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Trigger automatic workout adaptation', style: TextStyle(color: AuraColors.textSecondary, fontSize: 12)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _sendMessage('My muscles are really sore today.');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
