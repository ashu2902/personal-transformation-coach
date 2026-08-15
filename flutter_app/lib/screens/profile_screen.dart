import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/common/common.dart';
import 'widgets/aura_orb.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);
    final notifier = ref.read(transformationEngineProvider.notifier);
    final profile = state.profile;
    final auraTheme = context.auraTheme;
    final soul = profile.coachSoul;

    return Scaffold(
      backgroundColor: auraTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: auraTheme.scaffoldBackground,
        elevation: 0,
        title: Text(
          'Profile & Persona',
          style: AuraTypography.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AuraColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Header Card
            AuraCard(
              padding: const EdgeInsets.all(18),
              backgroundColor: auraTheme.surfaceCard,
              borderColor: AuraColors.borderSubtle,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: auraTheme.primary,
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
                          style: AuraTypography.titleLarge.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${profile.age} yrs • ${profile.heightCm.round()} cm • ${profile.weightKg} kg',
                          style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  AuraOrb(
                    soul: soul,
                    state: OrbState.idle,
                    size: 38,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. COACH PERSONALITY SELECTOR (Interactive Persona Swapping)
            AuraSectionHeader(
              title: 'Active Coach Persona',
            ),
            const SizedBox(height: 4),
            Text(
              'Switching persona instantly shifts coaching tone, Orb presence, and visual themes.',
              style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPersonaCard(
                  context: context,
                  title: 'The Supporter',
                  subtitle: 'Warm & Empathetic',
                  soulEnum: CoachSoul.supporter,
                  activeSoul: soul,
                  onTap: () => notifier.updateCoachSoul(CoachSoul.supporter),
                ),
                const SizedBox(width: 8),
                _buildPersonaCard(
                  context: context,
                  title: 'The Pro',
                  subtitle: 'Crisp & Accountable',
                  soulEnum: CoachSoul.pro,
                  activeSoul: soul,
                  onTap: () => notifier.updateCoachSoul(CoachSoul.pro),
                ),
                const SizedBox(width: 8),
                _buildPersonaCard(
                  context: context,
                  title: 'The Teacher',
                  subtitle: 'Scientific & Analytical',
                  soulEnum: CoachSoul.teacher,
                  activeSoul: soul,
                  onTap: () => notifier.updateCoachSoul(CoachSoul.teacher),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. TRANSFORMATION GOALS
            AuraSectionHeader(
              title: 'Transformation Goals',
            ),
            const SizedBox(height: 8),
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
              subtitle: profile.targetPhysique.isNotEmpty ? profile.targetPhysique : 'Athletic V-Taper',
            ),
            _buildDetailTile(
              context: context,
              icon: LucideIcons.scale,
              title: 'Target Weight',
              subtitle: '${profile.targetWeightKg} kg (Current: ${profile.weightKg} kg)',
            ),
            const SizedBox(height: 24),

            // 4. PERSISTENT CONSTRAINTS & EQUIPMENT MEMORY
            AuraSectionHeader(
              title: 'Persistent Constraints & Gear',
            ),
            const SizedBox(height: 8),
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
              subtitle: profile.equipmentList.isNotEmpty
                  ? profile.equipmentList.map((e) => e.name).join(', ')
                  : 'Bodyweight & Resistance Bands',
            ),
            _buildDetailTile(
              context: context,
              icon: LucideIcons.shieldAlert,
              title: 'Mobility Limitations',
              subtitle: profile.activeInjuries.isNotEmpty
                  ? profile.activeInjuries.join(', ')
                  : 'None reported (Full range of motion)',
            ),
            const SizedBox(height: 24),

            // 5. ACCOUNT & AUTHENTICATION
            AuraSectionHeader(
              title: 'Account & Synchronization',
            ),
            const SizedBox(height: 8),
            AuraCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: auraTheme.surfaceCard,
              borderColor: AuraColors.borderSubtle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: notifier.isAuthenticated
                              ? AuraColors.actionGreen.withOpacity(0.15)
                              : AuraColors.warningAmber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          notifier.isAuthenticated ? LucideIcons.shieldCheck : LucideIcons.userX,
                          color: notifier.isAuthenticated ? AuraColors.actionGreen : AuraColors.warningAmber,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notifier.currentAuthEmail ?? 'Guest Athlete',
                              style: AuraTypography.labelBold.copyWith(fontSize: 14),
                            ),
                            Text(
                              notifier.isAuthenticated ? 'Synced with Cloud Firestore' : 'Local Guest Account',
                              style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!notifier.isAuthenticated)
                    AuraButton(
                      text: 'Sign In with Google',
                      variant: AuraButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () async {
                        try {
                          await notifier.signInWithGoogle();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Successfully signed in!'),
                                backgroundColor: AuraColors.actionGreen,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sign-in error: $e'),
                                backgroundColor: AuraColors.error,
                              ),
                            );
                          }
                        }
                      },
                    )
                  else
                    AuraButton(
                      text: 'Sign Out',
                      variant: AuraButtonVariant.outline,
                      width: double.infinity,
                      icon: LucideIcons.logOut,
                      onPressed: () async {
                        await notifier.signOut();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Signed out successfully.')),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required CoachSoul soulEnum,
    required CoachSoul activeSoul,
    required VoidCallback onTap,
  }) {
    final isSelected = soulEnum == activeSoul;
    final palette = AuraColors.getSoulPalette(soulEnum);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? palette.primary.withOpacity(0.18) : AuraColors.surface2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? palette.primary : AuraColors.borderSubtle,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? palette.primary : AuraColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  color: AuraColors.textSecondary,
                ),
              ),
            ],
          ),
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
    final auraTheme = context.auraTheme;
    return AuraCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      backgroundColor: auraTheme.surfaceCard,
      borderColor: AuraColors.borderSubtle,
      child: Row(
        children: [
          Icon(icon, size: 18, color: auraTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AuraTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
