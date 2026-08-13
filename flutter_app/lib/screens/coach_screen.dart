import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';
import 'widgets/aura_orb.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScanningWatch = false;

  static const List<String> _actionChips = [
    "I'm feeling sore.",
    "What should I eat for dinner?",
    "I don't want to do my walk today.",
  ];

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

  void _triggerWatchScan() async {
    setState(() {
      _isScanningWatch = true;
    });

    final notifier = ref.read(transformationEngineProvider.notifier);
    
    notifier.appendUserMessage('📎 Sent a screenshot of my Apple Watch activity summary.');
    _scrollToBottom();
    
    await notifier.simulateWatchScreenshotScan();
    
    setState(() {
      _isScanningWatch = false;
    });
    _scrollToBottom();
  }

  // Get notifier state helper
  TransformationEngineNotifier get stateNotifier => ref.read(transformationEngineProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transformationEngineProvider);
    final isThinking = state.isAiThinking;

    // Dynamically retrieve accent colors for chosen coach soul
    Color activePrimary;
    Color activeSecondary;
    switch (state.profile.coachSoul) {
      case CoachSoul.supporter:
        activePrimary = const Color(0xFF8EA885);
        activeSecondary = const Color(0xFF9A7EB8);
        break;
      case CoachSoul.pro:
        activePrimary = const Color(0xFF00B2FF);
        activeSecondary = const Color(0xFFFF007A);
        break;
      case CoachSoul.teacher:
        activePrimary = const Color(0xFF00BFA5);
        activeSecondary = const Color(0xFFB0BEC5);
        break;
    }

    // Determine Orb state
    OrbState orbState = OrbState.pulsing;
    if (_isScanningWatch || isThinking) {
      orbState = OrbState.swirling;
    }

    return Column(
      children: [
        // The Top Third: Large AURA Orb
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                activePrimary.withOpacity(0.08),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Hero(
                tag: 'aura_orb_hero',
                child: AuraOrb(
                  soul: state.profile.coachSoul,
                  state: orbState,
                  size: 110,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                state.profile.coachSoul == CoachSoul.supporter
                    ? 'The Supporter'
                    : state.profile.coachSoul == CoachSoul.pro
                        ? 'The Pro'
                        : 'The Teacher',
                style: GoogleFonts.syne(
                  color: activePrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isThinking ? 'AURA is analyzing...' : 'AURA is active',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        // Chat stream
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: state.chatMessages.length,
            itemBuilder: (context, index) {
              final msg = state.chatMessages[index];
              final isAi = msg.sender == 'ai';
              final isScanPlaceholder = _isScanningWatch && index == state.chatMessages.length - 1 && !isAi;

              return Align(
                alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAi ? Theme.of(context).cardColor : activePrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isAi ? Radius.zero : const Radius.circular(16),
                      bottomRight: isAi ? const Radius.circular(16) : Radius.zero,
                    ),
                    border: Border.all(
                      color: isAi ? Colors.white.withOpacity(0.06) : activePrimary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isScanPlaceholder)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(LucideIcons.camera, color: Colors.white70, size: 14),
                                SizedBox(width: 8),
                                Text('Activity screenshot attached', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Scanning Laser Animation simulation
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 80,
                                    width: double.infinity,
                                    color: Colors.white10,
                                    child: const Center(
                                      child: Icon(LucideIcons.image, color: Colors.white30, size: 30),
                                    ),
                                  ),
                                  const Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 30,
                                    child: Divider(
                                      color: Color(0xFF00FFA3),
                                      thickness: 2,
                                      height: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Scanning screenshot metrics...', style: TextStyle(color: Colors.white38, fontSize: 11)),
                          ],
                        )
                      else
                        Text(
                          msg.text,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.45,
                            fontWeight: isAi ? FontWeight.normal : FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        msg.timestamp,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: Colors.white30,
                        ),
                      ),
                      // If this is the protein or snack size prompt, render selection chips!
                      if (isAi && msg.text.contains('Was it a big bowl or a small one?'))
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Row(
                            children: [
                              _buildInlineChoiceBtn(
                                label: 'Small',
                                color: activePrimary,
                                onTap: () => _sendMessage('It was a small bowl.'),
                              ),
                              const SizedBox(width: 8),
                              _buildInlineChoiceBtn(
                                label: 'Medium',
                                color: activePrimary,
                                onTap: () => _sendMessage('It was a medium bowl.'),
                              ),
                              const SizedBox(width: 8),
                              _buildInlineChoiceBtn(
                                label: 'Big',
                                color: activePrimary,
                                onTap: () => _sendMessage('It was a big bowl.'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Action Suggestions Row (Floating above input)
        if (!isThinking)
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _actionChips.length,
              itemBuilder: (ctx, idx) {
                final prompt = _actionChips[idx];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: Theme.of(context).cardColor,
                    side: BorderSide(color: Colors.white.withOpacity(0.08)),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      color: activePrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    label: Text(prompt),
                    onPressed: () => _sendMessage(prompt),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),

        // Bottom Input Field Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Photo attachment button (Watch screenshot trigger)
              GestureDetector(
                onTap: _triggerWatchScan,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: const Icon(LucideIcons.camera, color: Colors.white70, size: 20),
                ),
              ),
              const SizedBox(width: 10),

              // Input field
              Expanded(
                child: TextField(
                  controller: _inputController,
                  onSubmitted: _sendMessage,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white30),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: activePrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Send button
              GestureDetector(
                onTap: () => _sendMessage(_inputController.text),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: activePrimary,
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

  Widget _buildInlineChoiceBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
