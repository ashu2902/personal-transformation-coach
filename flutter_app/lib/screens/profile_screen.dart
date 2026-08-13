import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F17),
        elevation: 0,
        title: const Text('Transformation Baseline', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
            // User Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF141923),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E2638)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF10B981),
                    child: Text(
                      profile.name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.age} yrs • ${profile.heightCm.toStringAsFixed(0)} cm • ${profile.weightKg} kg',
                          style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('TRANSFORMATION GOALS', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 10),

            _buildDetailTile(
              icon: LucideIcons.target,
              title: 'Primary Goal',
              subtitle: profile.goal == GoalType.recomp
                  ? 'Body Recomposition'
                  : profile.goal == GoalType.fatLoss
                      ? 'Fat Loss & Lean Muscle'
                      : 'Muscle Mass Gain',
            ),
            _buildDetailTile(
              icon: LucideIcons.trophy,
              title: 'Target Physique',
              subtitle: profile.targetPhysique,
            ),
            _buildDetailTile(
              icon: LucideIcons.scale,
              title: 'Target Weight',
              subtitle: '${profile.targetWeightKg} kg (Current: ${profile.weightKg} kg)',
            ),

            const SizedBox(height: 20),
            const Text('TRAINING CONSTRAINTS', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 10),

            _buildDetailTile(
              icon: LucideIcons.calendar,
              title: 'Weekly Frequency',
              subtitle: '${profile.daysPerWeek} days per week scheduled',
            ),
            _buildDetailTile(
              icon: LucideIcons.dumbbell,
              title: 'Available Equipment',
              subtitle: profile.availableEquipment.map((e) => e.name.toUpperCase()).join(', '),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2638),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0xFF2E384E)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transformation Baseline updated automatically by Adaptation Engine.')),
                  );
                },
                icon: const Icon(LucideIcons.sliders, size: 16, color: Color(0xFF10B981)),
                label: const Text('Edit Transformation Baseline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({required IconData icon, required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141923),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2638)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF10B981)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 11)),
                Text(subtitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


