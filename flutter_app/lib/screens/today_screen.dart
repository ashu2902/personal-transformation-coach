import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';
import 'recovery_screen.dart';

class TodayScreen extends ConsumerWidget {
  final Function(int tabIndex, {int subIndex})? onNavigateToTab;

  const TodayScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);
    final notifier = ref.read(transformationEngineProvider.notifier);

    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final isTrackedToday = state.isProgressTrackedForDate(todayStr);

    final workout = state.workout;
    final nutrition = state.nutrition;
    final recovery = state.recovery;

    final totalCal = nutrition.meals.fold(0, (sum, m) => sum + m.calories);
    final totalProt = nutrition.meals.fold(0, (sum, m) => sum + m.proteinG);
    final remainingProt = (nutrition.targetProteinG - totalProt).clamp(0, 999);

    final isWorkoutDone =
        state.effectiveTodayWorkoutStatus == WorkoutStatus.completed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-header Greeting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TODAY',
                    style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Welcome back, ${state.profile.name}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => notifier.trackProgressForToday(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isTrackedToday
                        ? const Color(0x2010B981)
                        : const Color(0x20F59E0B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isTrackedToday
                            ? const Color(0x4010B981)
                            : const Color(0x40F59E0B)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isTrackedToday
                            ? LucideIcons.checkCircle2
                            : LucideIcons.circle,
                        size: 12,
                        color: isTrackedToday
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isTrackedToday ? 'Tracked Today' : 'Mark Tracked',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isTrackedToday
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ⚡ EXPRESS CONVERSATIONAL AI QUICK-LOG
          const ExpressQuickLogWidget(),
          const SizedBox(height: 16),

          if (state.adaptationNotice != null &&
              state.adaptationNotice!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0x1DF59E0B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x40F59E0B)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.sliders,
                      color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.adaptationNotice!,
                      style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // 🎯 1. FOCUS CARD (The #1 Action for Today)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2638), Color(0xFF141923)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF2E384E)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0x2010B981),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.compass,
                          size: 16, color: Color(0xFF10B981)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TODAY\'S PRIMARY FOCUS (${state.todayFocus.category})',
                      style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  state.todayFocus.primaryActionTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.3),
                ),
                const SizedBox(height: 6),
                Text(
                  state.todayFocus.primaryActionDescription,
                  style:
                      const TextStyle(color: Color(0xFFA1A1AA), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const Text('DAILY PILLARS',
              style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 10),

          // ⚡ 2. TRAIN CARD
          _buildPillarCard(
            icon: LucideIcons.dumbbell,
            iconColor: const Color(0xFF3B82F6),
            title: 'TRAIN',
            subtitle: workout.title,
            detail:
                '${workout.focusArea} • ${workout.estimatedDurationMin} min',
            badgeText: isWorkoutDone ? 'Completed' : 'Scheduled',
            badgeColor: isWorkoutDone
                ? const Color(0xFF10B981)
                : const Color(0xFF3B82F6),
            actionText: isWorkoutDone ? 'View Workout' : 'Start Workout',
            onTapAction: () {
              if (onNavigateToTab != null) {
                onNavigateToTab!(1,
                    subIndex: 0); // Tab 1 = Plan & Log (Workout)
              }
            },
          ),
          const SizedBox(height: 12),

          // 🥗 3. EAT CARD
          _buildPillarCard(
            icon: LucideIcons.apple,
            iconColor: const Color(0xFF10B981),
            title: 'EAT',
            subtitle: '$totalCal / ${nutrition.targetCalories} kcal',
            detail:
                'Protein: $totalProt / ${nutrition.targetProteinG}g (${remainingProt}g left)',
            badgeText: remainingProt == 0 ? 'Target Met' : 'In Progress',
            badgeColor: remainingProt == 0
                ? const Color(0xFF10B981)
                : const Color(0xFFF59E0B),
            actionText: 'Log Meals',
            onTapAction: () {
              if (onNavigateToTab != null) {
                onNavigateToTab!(1,
                    subIndex: 1); // Tab 1 = Plan & Log (Nutrition)
              }
            },
          ),
          const SizedBox(height: 12),

          // 🔋 4. RECOVER CARD
          _buildPillarCard(
            icon: LucideIcons.heartPulse,
            iconColor: const Color(0xFF6366F1),
            title: 'RECOVER',
            subtitle: '${recovery.recoveryScore}% Readiness',
            detail: '${recovery.status} • ${recovery.sleepHours}h Sleep',
            badgeText: recovery.recoveryScore >= 75 ? 'Optimal' : 'Needs Rest',
            badgeColor: recovery.recoveryScore >= 75
                ? const Color(0xFF10B981)
                : const Color(0xFFF59E0B),
            actionText: 'Check In',
            onTapAction: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RecoveryScreen()),
              );
            },
          ),
          const SizedBox(height: 20),

          // Clean 7-Day Activity Dot Bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF141923),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E2638)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('7-DAY RECENT CONSISTENCY',
                        style: TextStyle(
                            color: Color(0xFFA1A1AA),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0)),
                    Text('Consistency drives transformation',
                        style:
                            TextStyle(color: Color(0xFF71717A), fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: state.getRecentDaysTrackingStatus(7).map((day) {
                    return Column(
                      children: [
                        Text(day.dayLabel,
                            style: const TextStyle(
                                color: Color(0xFFA1A1AA), fontSize: 10)),
                        const SizedBox(height: 6),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: day.isTracked
                                ? const Color(0x2010B981)
                                : const Color(0xFF1E2638),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: day.isTracked
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF2E384E)),
                          ),
                          child: Icon(
                            day.isTracked ? LucideIcons.check : LucideIcons.x,
                            size: 14,
                            color: day.isTracked
                                ? const Color(0xFF10B981)
                                : const Color(0xFF52525B),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String detail,
    required String badgeText,
    required Color badgeColor,
    required String actionText,
    required VoidCallback onTapAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141923),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2638)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(38),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(title,
                      style: TextStyle(
                          color: iconColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(subtitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(detail,
              style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF2E384E)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: onTapAction,
              child: Text(actionText,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpressQuickLogWidget extends ConsumerStatefulWidget {
  const ExpressQuickLogWidget({super.key});

  @override
  ConsumerState<ExpressQuickLogWidget> createState() =>
      _ExpressQuickLogWidgetState();
}

class _ExpressQuickLogWidgetState extends ConsumerState<ExpressQuickLogWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isProcessing = false;
  QuickLogParsedResult? _lastResult;

  final List<String> _quickChips = [
    "Skipped gym, ate pizza for dinner, slept 6 hrs",
    "Finished workout, weight 74.5 kg, slept 8 hrs",
    "Missed lunch, took a whey shake",
  ];

  Future<void> _submitLog([String? textOverride]) async {
    final text = textOverride ?? _controller.text.trim();
    if (text.isEmpty || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _lastResult = null;
    });

    final notifier = ref.read(transformationEngineProvider.notifier);
    final result = await notifier.parseAndApplyQuickLog(text);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _lastResult = result;
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141923),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: const Color(0xFF10B981).withAlpha(100), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0x2010B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.sparkles,
                        size: 16, color: Color(0xFF10B981)),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '⚡ QUICK DAY LOG',
                    style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0),
                  ),
                ],
              ),
              const Text(
                'Easy AI Log',
                style: TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            maxLines: 2,
            decoration: InputDecoration(
              hintText:
                  'Type anything (e.g. "Skipped gym today, ate pizza, slept 6 hrs, weight 74.2 kg")',
              hintStyle:
                  const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF0B0F17),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF27272A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Suggestion Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickChips.map((chip) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ActionChip(
                    backgroundColor: const Color(0xFF1E2638),
                    side: const BorderSide(color: Color(0xFF2E384E)),
                    label: Text(
                      chip,
                      style: const TextStyle(
                          color: Color(0xFFA1A1AA), fontSize: 10),
                    ),
                    onPressed: () {
                      _controller.text = chip;
                      _submitLog(chip);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isProcessing ? null : () => _submitLog(),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(LucideIcons.send, size: 14),
              label: Text(
                _isProcessing ? 'Processing with AI...' : '✨ Express Log Day',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),

          // Parsed Results Preview Card
          if (_lastResult != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x2010B981),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x4010B981)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.checkCircle,
                          color: Color(0xFF10B981), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Logged State Updated Successfully!',
                        style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_lastResult!.workoutStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '• Workout: ${_lastResult!.workoutStatus!.name.toUpperCase()}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  if (_lastResult!.mealsToAdd.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '• Added Meals: ${_lastResult!.mealsToAdd.map((m) => "${m.name} (${m.calories} kcal)").join(", ")}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  if (_lastResult!.sleepHours != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '• Sleep: ${_lastResult!.sleepHours} hrs',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  if (_lastResult!.weightKg != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '• Weight: ${_lastResult!.weightKg} kg',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  const Divider(color: Color(0x4010B981), height: 12),
                  Text(
                    '🤖 "${_lastResult!.coachFeedback}"',
                    style: const TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 11,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
