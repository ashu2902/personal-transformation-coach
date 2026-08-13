import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);
    final profile = state.profile;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Baseline Profile',
          style: GoogleFonts.syne(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: primaryColor,
                    child: Text(
                      profile.name.isNotEmpty ? profile.name.substring(0, 2).toUpperCase() : 'AV',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${profile.age} yrs • ${profile.heightCm.round()} cm • ${profile.weightKg} kg',
                          style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'TRANSFORMATION GOALS',
              style: GoogleFonts.syne(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),

            _buildDetailTile(
              context: context,
              icon: LucideIcons.target,
              title: 'Primary Goal',
              subtitle: profile.goal == GoalType.recomp
                  ? 'Body Recomposition'
                  : profile.goal == GoalType.fatLoss
                      ? 'Fat Loss & Lean Muscle'
                      : 'Muscle Mass Gain',
            ),
            _buildDetailTile(
              context: context,
              icon: LucideIcons.trophy,
              title: 'Target Physique',
              subtitle: profile.targetPhysique,
            ),
            _buildDetailTile(
              context: context,
              icon: LucideIcons.scale,
              title: 'Target Weight',
              subtitle: '${profile.targetWeightKg} kg (Current: ${profile.weightKg} kg)',
            ),

            const SizedBox(height: 24),
            Text(
              'TRAINING CONSTRAINTS',
              style: GoogleFonts.syne(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),

            _buildDetailTile(
              context: context,
              icon: LucideIcons.calendar,
              title: 'Weekly Frequency',
              subtitle: '${profile.daysPerWeek} days per week scheduled',
            ),
            _buildDetailTile(
              context: context,
              icon: LucideIcons.dumbbell,
              title: 'Available Equipment',
              subtitle: profile.availableEquipment.map((e) => e.name.toUpperCase()).join(', '),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  side: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Baseline updated automatically by active AI feedback loops.',
                        style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: primaryColor,
                    ),
                  );
                },
                icon: Icon(LucideIcons.sliders, size: 16, color: primaryColor),
                label: Text(
                  'Edit Baseline Profile',
                  style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(color: const Color(0xFFA1A1AA), fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
