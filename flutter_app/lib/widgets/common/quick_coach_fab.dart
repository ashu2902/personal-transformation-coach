import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/models.dart';
import '../../providers/transformation_state.dart';
import '../../providers/analytics_provider.dart';
import '../../services/analytics_service.dart';
import '../../screens/widgets/aura_orb.dart';

class QuickCoachFAB extends ConsumerWidget {
  final String? contextTag; // 'today', 'workout', etc.

  const QuickCoachFAB({
    super.key,
    this.contextTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);
    final soul = state.profile.coachSoul;

    return GestureDetector(
      onTap: () {
        ref.read(analyticsServiceProvider).logEvent(
          AuraAnalyticsEvents.screenViewed,
          properties: {
            'screen_name': 'quick_coach_modal',
            'source_context': contextTag ?? 'global',
          },
        );
        showQuickCoachModal(context, soul, contextTag: contextTag);
      },
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FFA3).withOpacity(0.35),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(alignment: Alignment.center, children: [
          AuraOrb(soul: soul, state: OrbState.pulsing, size: 58),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

void showQuickCoachModal(
  BuildContext context,
  CoachSoul soul, {
  String? contextTag,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _QuickCoachSheet(soul: soul, contextTag: contextTag),
  );
}

class _QuickCoachSheet extends ConsumerStatefulWidget {
  final CoachSoul soul;
  final String? contextTag;

  const _QuickCoachSheet({
    required this.soul,
    this.contextTag,
  });

  @override
  ConsumerState<_QuickCoachSheet> createState() => _QuickCoachSheetState();
}

class _QuickCoachSheetState extends ConsumerState<_QuickCoachSheet> {
  late TextEditingController _controller;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendDeviation(String text) async {
    if (text.trim().isEmpty || _isSubmitting) return;
    final prompt = text.trim();
    _controller.clear();
    setState(() => _isSubmitting = true);

    ref.read(analyticsServiceProvider).logEvent(
      AuraAnalyticsEvents.chatMessageSent,
      properties: {
        'input_type': 'quick_coach_fab',
        'length': prompt.length,
        'source': widget.contextTag ?? 'today_screen',
        'coach_soul': widget.soul.name,
      },
    );

    try {
      await ref
          .read(transformationEngineProvider.notifier)
          .addChatMessage(prompt);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF18181B),
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(LucideIcons.checkCircle2,
                    color: Color(0xFF00FFA3), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AURA adapted your program in real-time!',
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent.shade700,
            content: Text('Failed to send: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final isWorkout = widget.contextTag == 'workout';
    final suggestionChips = isWorkout
        ? [
            "Squat rack is taken, swap it",
            "Shoulder pain, swap press",
            "Low energy, deload 20%",
            "Only have 20 minutes left",
          ]
        : [
            "Ate lunch: 2 eggs & toast",
            "Slept poorly (5 hours), feel tired",
            "Had 500ml water",
            "Knee feels tight today",
          ];

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF121216),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF27272A), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AuraOrb(
                  soul: widget.soul,
                  state: _isSubmitting ? OrbState.pulsing : OrbState.idle,
                  size: 36),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Coach',
                    style: GoogleFonts.syne(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isWorkout
                        ? 'Workout Micro-Deviations'
                        : 'Instant Log & Program Adjustments',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFA1A1AA),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Context Suggestion Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: suggestionChips.map((chip) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => _sendDeviation(chip),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        chip,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFE4E4E7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Input field
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A20),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: isWorkout
                          ? 'e.g. "Equipment busy, need alternative"'
                          : 'Tell AURA anything...',
                      hintStyle:
                          const TextStyle(color: Colors.white30, fontSize: 13),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendDeviation,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _sendDeviation(_controller.text),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FFA3),
                    shape: BoxShape.circle,
                  ),
                  child: _isSubmitting
                      ? const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black),
                          ),
                        )
                      : const Icon(LucideIcons.send,
                          color: Colors.black, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
