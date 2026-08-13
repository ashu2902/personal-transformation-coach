import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';

class RecoveryScreen extends ConsumerStatefulWidget {
  const RecoveryScreen({super.key});

  @override
  ConsumerState<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends ConsumerState<RecoveryScreen> {
  late double _sleepHours;
  late double _energy;
  late double _soreness;
  late double _stress;

  @override
  void initState() {
    super.initState();
    final recovery = ref.read(transformationEngineProvider).recovery;
    _sleepHours = recovery.sleepHours;
    _energy = recovery.energyLevel.toDouble();
    _soreness = recovery.muscleSoreness.toDouble();
    _stress = recovery.stressLevel.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transformationEngineProvider);
    final notifier = ref.read(transformationEngineProvider.notifier);
    final recovery = state.recovery;

    final isOptimal = recovery.recoveryScore >= 75;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F17),
        elevation: 0,
        title: const Text('Recovery & Readiness', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score Display Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141923),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isOptimal ? const Color(0x4010B981) : const Color(0x40F59E0B)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isOptimal ? const Color(0x2010B981) : const Color(0x20F59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${recovery.recoveryScore}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isOptimal ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recovery.status,
                          style: TextStyle(
                            color: isOptimal ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOptimal
                              ? 'Your body is well-rested and ready for a great workout today!'
                              : 'You have higher fatigue today. A lighter session or extra rest is recommended.',
                          style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('30-SECOND RECOVERY CHECK-IN', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),

            _buildSliderTile('Sleep Duration', '${_sleepHours.toStringAsFixed(1)} hrs', LucideIcons.moon, _sleepHours, 4.0, 12.0, (val) {
              setState(() => _sleepHours = val);
            }),
            _buildSliderTile('Energy Level', '${_energy.toInt()} / 10', LucideIcons.zap, _energy, 1.0, 10.0, (val) {
              setState(() => _energy = val);
            }),
            _buildSliderTile('Muscle Soreness', '${_soreness.toInt()} / 10', LucideIcons.flame, _soreness, 1.0, 10.0, (val) {
              setState(() => _soreness = val);
            }),
            _buildSliderTile('Stress Level', '${_stress.toInt()} / 10', LucideIcons.brain, _stress, 1.0, 10.0, (val) {
              setState(() => _stress = val);
            }),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  notifier.updateRecoveryCheckIn(
                    sleepHours: _sleepHours,
                    sleepQuality: 8,
                    muscleSoreness: _soreness.toInt(),
                    energyLevel: _energy.toInt(),
                    stressLevel: _stress.toInt(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recovery & Readiness updated! Plan adapted automatically.')),
                  );
                },
                icon: const Icon(LucideIcons.check, size: 18),
                label: const Text('Save Check-In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderTile(String label, String valueText, IconData icon, double currentVal, double min, double max, ValueChanged<double> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141923),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2638)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: const Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Text(valueText, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          Slider(
            value: currentVal,
            min: min,
            max: max,
            activeColor: const Color(0xFF10B981),
            inactiveColor: const Color(0xFF1E2638),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
