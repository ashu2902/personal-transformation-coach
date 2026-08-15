import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/common/common.dart';
import 'widgets/aura_orb.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

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

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _inputController.clear();
    final notifier = ref.read(transformationEngineProvider.notifier);
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

    // Determine Orb state
    OrbState orbState = isThinking
        ? OrbState.thinking
        : (isAdapted ? OrbState.adapting : OrbState.idle);

    final actionChips = _getChipsForSoul(soul);

    return Column(
      children: [
        // 1. TOP COACH HEADER & REACTIVE ORB
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: auraTheme.surfaceCard,
            border: const Border(bottom: BorderSide(color: AuraColors.borderSubtle)),
          ),
          child: Column(
            children: [
              Hero(
                tag: 'aura_orb_hero',
                child: AuraOrb(
                  soul: soul,
                  state: orbState,
                  size: 88,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                soul.displayName,
                style: AuraTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: auraTheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isThinking
                    ? 'AURA is analyzing...'
                    : (isAdapted ? 'Prescription adapted for today' : 'AURA is active & listening'),
                style: AuraTypography.bodySmall.copyWith(
                  color: isAdapted ? AuraColors.actionGreen : AuraColors.textSecondary,
                  fontWeight: isAdapted ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),

        // 2. CONVERSATION MESSAGE LIST
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            itemCount: state.chatMessages.length,
            itemBuilder: (context, index) {
              final msg = state.chatMessages[index];
              final isAi = msg.sender == 'ai';

              // Determine if message triggers in-line actionable cards
              final isPlanAdjustment = isAi && (msg.text.toLowerCase().contains('adapted') || msg.text.toLowerCase().contains('swapped') || msg.text.toLowerCase().contains('adjusted today'));
              final isMealLog = isAi && (msg.text.toLowerCase().contains('logged') || msg.text.toLowerCase().contains('kcal') || msg.text.toLowerCase().contains('protein'));

              return Align(
                alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.88),
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAi ? auraTheme.surfaceCard : auraTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isAi ? Radius.zero : const Radius.circular(16),
                      bottomRight: isAi ? const Radius.circular(16) : Radius.zero,
                    ),
                    border: Border.all(
                      color: isAi ? AuraColors.borderSubtle : auraTheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Attached Image Preview
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
                          fontWeight: isAi ? FontWeight.normal : FontWeight.w600,
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

                      // IN-LINE STRUCTURED CARD: Decision Card for Plan Adjustment
                      if (isPlanAdjustment)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: auraTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AuraColors.actionGreen.withOpacity(0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.gitFork, color: AuraColors.actionGreen, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ADAPTED PRESCRIPTION',
                                      style: AuraTypography.sectionHeader.copyWith(
                                        color: AuraColors.actionGreen,
                                        fontSize: 10,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
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
                                    const Icon(LucideIcons.arrowRight, size: 14, color: AuraColors.actionGreen),
                                    const SizedBox(width: 6),
                                    const Expanded(
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
                                const SizedBox(height: 12),
                                AuraButton(
                                  text: 'Accept Revised Plan',
                                  variant: AuraButtonVariant.primary,
                                  backgroundColor: AuraColors.actionGreen,
                                  textColor: Colors.black,
                                  width: double.infinity,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Revised prescription locked in for today!'),
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

                      // IN-LINE STRUCTURED CARD: Meal Confirmation Card with Keep/Edit
                      if (isMealLog && !isPlanAdjustment)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
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
                                    Icon(LucideIcons.utensils, size: 16, color: auraTheme.primary),
                                    const SizedBox(width: 8),
                                    const Text('Meal Recorded', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuraColors.textPrimary)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildCompactActionBtn(
                                      label: 'Keep',
                                      color: AuraColors.actionGreen,
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Meal entry confirmed!'), duration: Duration(seconds: 1)),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 6),
                                    _buildCompactActionBtn(
                                      label: 'Edit',
                                      color: AuraColors.textSecondary,
                                      onTap: () => _sendMessage('I want to adjust the portion size.'),
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
              );
            },
          ),
        ),

        // 3. CONTEXTUAL ACTION CHIPS (Floating Above Input)
        if (!isThinking)
          SizedBox(
            height: 38,
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
        const SizedBox(height: 8),

        // 4. BOTTOM INPUT BAR (Camera + Gallery + Text + Express Actions)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Photo / Media Attachment Trigger (Camera & Gallery)
              GestureDetector(
                onTap: () => _showMediaOptionsModal(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: auraTheme.surfaceCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: AuraColors.borderSubtle),
                  ),
                  child: Icon(LucideIcons.camera, color: auraTheme.primary, size: 18),
                ),
              ),
              const SizedBox(width: 6),

              // Express shortcuts button
              GestureDetector(
                onTap: () => _showExpressActionsModal(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: auraTheme.surfaceCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: AuraColors.borderSubtle),
                  ),
                  child: Icon(LucideIcons.plus, color: AuraColors.textSecondary, size: 18),
                ),
              ),
              const SizedBox(width: 8),

              // Input field
              Expanded(
                child: TextField(
                  controller: _inputController,
                  onSubmitted: _sendMessage,
                  style: AuraTypography.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Tell AURA what happened...',
                    hintStyle: AuraTypography.bodyMedium.copyWith(color: AuraColors.textTertiary),
                    filled: true,
                    fillColor: auraTheme.surfaceCard,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

              // Send button
              GestureDetector(
                onTap: () => _sendMessage(_inputController.text),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AuraColors.actionGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.arrowUp, color: Colors.black, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
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
