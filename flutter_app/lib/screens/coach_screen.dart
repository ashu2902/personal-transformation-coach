import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';

class CoachScreen extends ConsumerWidget {
  const CoachScreen({super.key});

  static const List<String> _quickPrompts = [
    'How can I get 40g more protein today?',
    'Can I substitute flat bench for incline dumbbells?',
    'Should I train today if muscle soreness is 6/10?',
    'Explain progressive overload strategy for next week',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);
    final notifier = ref.read(transformationEngineProvider.notifier);
    final inputController = TextEditingController();

    return Column(
      children: [
        // AI Header Sub-banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF141923),
            border: Border(bottom: BorderSide(color: Color(0xFF1E2638), width: 1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0x2010B981),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.bot, color: Color(0xFF10B981), size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AURA AI Transformation Coach', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Context active: User Baseline • Workouts • Nutrition • Recovery', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Message List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.chatMessages.length,
            itemBuilder: (context, index) {
              final msg = state.chatMessages[index];
              final isAi = msg.sender == 'ai';
              return Align(
                alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isAi ? const Color(0xFF141923) : const Color(0xFF10B981),
                    border: Border.all(color: isAi ? const Color(0xFF1E2638) : Colors.transparent),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isAi ? Radius.zero : const Radius.circular(16),
                      bottomRight: isAi ? const Radius.circular(16) : Radius.zero,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: TextStyle(
                          color: isAi ? Colors.white : Colors.black,
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: isAi ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg.timestamp,
                        style: TextStyle(
                          fontSize: 9,
                          color: isAi ? const Color(0xFF71717A) : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Animated AURA AI Thinking Indicator
        if (state.isAiThinking)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF141923),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x4010B981)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0x2010B981), shape: BoxShape.circle),
                      child: const Icon(LucideIcons.sparkles, color: Color(0xFF10B981), size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AURA is thinking...',
                      style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Quick Suggestion Chips
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _quickPrompts.length,
            itemBuilder: (ctx, idx) {
              final prompt = _quickPrompts[idx];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  backgroundColor: const Color(0xFF141923),
                  side: const BorderSide(color: Color(0xFF1E2638)),
                  labelStyle: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
                  label: Text(prompt),
                  onPressed: () => notifier.addChatMessage(prompt),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Input Field
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: inputController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Ask your coach...',
                    hintStyle: const TextStyle(color: Color(0xFF71717A)),
                    filled: true,
                    fillColor: const Color(0xFF141923),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E2638)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF10B981)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(12),
                ),
                icon: const Icon(LucideIcons.send, size: 18),
                onPressed: () {
                  if (inputController.text.trim().isNotEmpty) {
                    notifier.addChatMessage(inputController.text.trim());
                    inputController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
