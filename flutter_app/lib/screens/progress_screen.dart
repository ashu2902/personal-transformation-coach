import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);
    final notifier = ref.read(transformationEngineProvider.notifier);

    final weightController =
        TextEditingController(text: state.profile.weightKg.toString());
    final currentWeight = state.profile.weightKg;
    final targetWeight = state.profile.targetWeightKg;
    final diff = (targetWeight - currentWeight).abs();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trend Overview Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF141923),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E2638)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CURRENT WEIGHT',
                            style: TextStyle(
                                color: Color(0xFFA1A1AA),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0)),
                        const SizedBox(height: 2),
                        Text('$currentWeight kg',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('TARGET WEIGHT',
                            style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0)),
                        const SizedBox(height: 2),
                        Text('$targetWeight kg',
                            style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2638),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.trendingUp,
                          size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      Text(
                        '${diff.toStringAsFixed(1)} kg to target • Steady trend (+0.3 kg/wk average)',
                        style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Log Entry Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141923),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E2638)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('LOG TODAY\'S BODY WEIGHT',
                    style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          suffixText: 'kg',
                          suffixStyle: const TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold),
                          filled: true,
                          fillColor: const Color(0xFF0B0F17),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF1E2638))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final val = double.tryParse(weightController.text) ??
                            currentWeight;
                        final todayStr =
                            DateTime.now().toIso8601String().split('T')[0];
                        notifier.addProgressEntry(
                            ProgressEntry(date: todayStr, weightKg: val));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Weight recorded & day marked as active!')),
                        );
                      },
                      child: const Text('Save',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('ENTRY HISTORY',
              style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 10),

          ...state.progressHistory.reversed.map((p) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF141923),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E2638)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.calendar,
                            size: 14, color: Color(0xFFA1A1AA)),
                        const SizedBox(width: 8),
                        Text(p.date,
                            style: const TextStyle(
                                color: Color(0xFFA1A1AA), fontSize: 12)),
                      ],
                    ),
                    Text('${p.weightKg} kg',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
