import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';
import '../providers/analytics_provider.dart';
import '../services/analytics_service.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/common/common.dart';
import 'widgets/aura_orb.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _switchSoul(WidgetRef ref, CoachSoul newSoul, CoachSoul currentSoul) {
    if (newSoul == currentSoul) return;
    ref.read(transformationEngineProvider.notifier).updateCoachSoul(newSoul);

    // Track persona switch in Mixpanel
    final analytics = ref.read(analyticsServiceProvider);
    analytics.logEvent(
      AuraAnalyticsEvents.soulSwitched,
      properties: {
        'soul_name': newSoul.name,
        'previous_soul': currentSoul.name,
        'surface': 'profile',
      },
    );
    analytics.registerSuperProperties({
      'coach_soul': newSoul.name,
    });
  }

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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.maxFluidContentWidth),
          child: SingleChildScrollView(
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
            const AuraSectionHeader(
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
                  onTap: () => _switchSoul(ref, CoachSoul.supporter, soul),
                ),
                const SizedBox(width: 8),
                _buildPersonaCard(
                  context: context,
                  title: 'The Pro',
                  subtitle: 'Crisp & Accountable',
                  soulEnum: CoachSoul.pro,
                  activeSoul: soul,
                  onTap: () => _switchSoul(ref, CoachSoul.pro, soul),
                ),
                const SizedBox(width: 8),
                _buildPersonaCard(
                  context: context,
                  title: 'The Teacher',
                  subtitle: 'Scientific & Analytical',
                  soulEnum: CoachSoul.teacher,
                  activeSoul: soul,
                  onTap: () => _switchSoul(ref, CoachSoul.teacher, soul),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. TRANSFORMATION GOALS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AuraSectionHeader(
                  title: 'Transformation Goals',
                ),
                GestureDetector(
                  onTap: () => _showEditGoalModal(context, ref, profile, auraTheme),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: auraTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: auraTheme.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.edit3, size: 12, color: auraTheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Edit Goals',
                          style: AuraTypography.bodySmall.copyWith(
                            color: auraTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
              onTap: () => _showEditGoalModal(context, ref, profile, auraTheme),
            ),
            _buildDetailTile(
              context: context,
              icon: LucideIcons.trophy,
              title: 'Target Physique',
              subtitle: profile.targetPhysique.isNotEmpty ? profile.targetPhysique : 'Athletic V-Taper',
              onTap: () => _showEditGoalModal(context, ref, profile, auraTheme),
            ),
            _buildDetailTile(
              context: context,
              icon: LucideIcons.scale,
              title: 'Target Weight',
              subtitle: '${profile.targetWeightKg} kg (Current: ${profile.weightKg} kg)',
              onTap: () => _showEditGoalModal(context, ref, profile, auraTheme),
            ),
            const SizedBox(height: 24),

            // 4. PERSISTENT CONSTRAINTS & EQUIPMENT MEMORY
            const AuraSectionHeader(
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
            const AuraSectionHeader(
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
                              ? AuraColors.actionGreen.withValues(alpha: 0.15)
                              : AuraColors.warningAmber.withValues(alpha: 0.15),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: AuraCurves.fluidEaseOut,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? palette.primary.withValues(alpha: 0.18) : AuraColors.surface2,
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
    VoidCallback? onTap,
  }) {
    final auraTheme = context.auraTheme;
    return GestureDetector(
      onTap: onTap,
      child: AuraCard(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        borderRadius: 12,
        backgroundColor: auraTheme.surfaceCard,
        borderColor: onTap != null ? auraTheme.primary.withValues(alpha: 0.15) : AuraColors.borderSubtle,
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
            if (onTap != null)
              Icon(LucideIcons.chevronRight, size: 14, color: auraTheme.primary.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  void _showEditGoalModal(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    AuraThemeExtension auraTheme,
  ) {
    GoalType selectedGoal = profile.goal;
    String selectedPhysique = profile.targetPhysique.isNotEmpty ? profile.targetPhysique : 'Athletic V-Taper';
    double targetWeight = profile.targetWeightKg > 0 ? profile.targetWeightKg : profile.weightKg;
    int selectedDays = profile.daysPerWeek.clamp(3, 6);

    final physiqueOptions = [
      'Athletic V-Taper',
      'Lean & Defined',
      'Maximum Mass',
      'Functional Power',
      'Endurance & Tone',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: const Color(0xFF101214),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: AuraColors.borderSubtle),
              ),
              child: Column(
                children: [
                  // Handle
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AuraColors.textTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recalibrate Goals',
                              style: AuraTypography.titleMedium.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Adjust focus, target physique & frequency',
                              style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, color: AuraColors.textSecondary),
                          onPressed: () => Navigator.of(modalCtx).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AuraColors.borderSubtle, height: 24),

                  // Scrollable Body
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // 1. PRIMARY GOAL SELECTION
                        Text(
                          'PRIMARY FOCUS',
                          style: AuraTypography.sectionHeader.copyWith(
                            fontSize: 10,
                            letterSpacing: 1.1,
                            color: auraTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildGoalSelectOption(
                          title: 'Body Recomposition',
                          subtitle: 'Build lean muscle while trimming body fat',
                          icon: LucideIcons.refreshCw,
                          goal: GoalType.recomp,
                          current: selectedGoal,
                          auraTheme: auraTheme,
                          onTap: () => setModalState(() => selectedGoal = GoalType.recomp),
                        ),
                        _buildGoalSelectOption(
                          title: 'Fat Loss & Definition',
                          subtitle: 'Targeted caloric deficit with high protein retention',
                          icon: LucideIcons.flame,
                          goal: GoalType.fatLoss,
                          current: selectedGoal,
                          auraTheme: auraTheme,
                          onTap: () => setModalState(() => selectedGoal = GoalType.fatLoss),
                        ),
                        _buildGoalSelectOption(
                          title: 'Muscle Mass Gain',
                          subtitle: 'Progressive strength overload and caloric surplus',
                          icon: LucideIcons.dumbbell,
                          goal: GoalType.muscleGain,
                          current: selectedGoal,
                          auraTheme: auraTheme,
                          onTap: () => setModalState(() => selectedGoal = GoalType.muscleGain),
                        ),
                        const SizedBox(height: 20),

                        // 2. TARGET PHYSIQUE ARCHETYPE
                        Text(
                          'TARGET PHYSIQUE ARCHETYPE',
                          style: AuraTypography.sectionHeader.copyWith(
                            fontSize: 10,
                            letterSpacing: 1.1,
                            color: auraTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: physiqueOptions.map((opt) {
                            final isSelected = selectedPhysique == opt;
                            return GestureDetector(
                              onTap: () => setModalState(() => selectedPhysique = opt),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? auraTheme.primary.withValues(alpha: 0.18)
                                      : AuraColors.surface2,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? auraTheme.primary : AuraColors.borderSubtle,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Text(
                                  opt,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : AuraColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // 3. TARGET WEIGHT
                        Text(
                          'TARGET WEIGHT (KG)',
                          style: AuraTypography.sectionHeader.copyWith(
                            fontSize: 10,
                            letterSpacing: 1.1,
                            color: auraTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AuraCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          backgroundColor: AuraColors.surface2,
                          borderColor: AuraColors.borderSubtle,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${targetWeight.toStringAsFixed(1)} kg',
                                    style: AuraTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'Current weight: ${profile.weightKg} kg',
                                    style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(LucideIcons.minusCircle, color: AuraColors.textSecondary),
                                    onPressed: () {
                                      if (targetWeight > 40) {
                                        setModalState(() => targetWeight -= 0.5);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(LucideIcons.plusCircle, color: auraTheme.primary),
                                    onPressed: () {
                                      if (targetWeight < 200) {
                                        setModalState(() => targetWeight += 0.5);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 4. WEEKLY TRAINING FREQUENCY
                        Text(
                          'WEEKLY TRAINING FREQUENCY',
                          style: AuraTypography.sectionHeader.copyWith(
                            fontSize: 10,
                            letterSpacing: 1.1,
                            color: auraTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [3, 4, 5, 6].map((days) {
                            final isSelected = selectedDays == days;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setModalState(() => selectedDays = days),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? auraTheme.primary.withValues(alpha: 0.18)
                                        : AuraColors.surface2,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? auraTheme.primary : AuraColors.borderSubtle,
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '$days',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : AuraColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Days/wk',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: isSelected ? auraTheme.primary : AuraColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  // Bottom Action CTA
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: AuraButton(
                      text: 'Save & Recalibrate Plan',
                      icon: LucideIcons.sparkles,
                      variant: AuraButtonVariant.primary,
                      width: double.infinity,
                      height: 50,
                      onPressed: () async {
                        final previousGoal = profile.goal;
                        await ref.read(transformationEngineProvider.notifier).updateGoal(
                          goal: selectedGoal,
                          targetPhysique: selectedPhysique,
                          targetWeightKg: targetWeight,
                          daysPerWeek: selectedDays,
                        );

                        // Mixpanel Tracking per AGENTS.md
                        final analytics = ref.read(analyticsServiceProvider);
                        await analytics.registerSuperProperties({'goal_type': selectedGoal.name});
                        await analytics.setUserProperties({
                          'goal_type': selectedGoal.name,
                          'days_per_week': selectedDays,
                        });
                        await analytics.logEvent(
                          AuraAnalyticsEvents.goalUpdated,
                          properties: {
                            'previous_goal': previousGoal.name,
                            'new_goal': selectedGoal.name,
                            'target_physique': selectedPhysique,
                            'days_per_week': selectedDays,
                          },
                        );

                        if (context.mounted) {
                          Navigator.of(modalCtx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Goals recalibrated! Daily macros updated for ${selectedGoal.displayName}.'),
                              backgroundColor: AuraColors.actionGreen,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGoalSelectOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required GoalType goal,
    required GoalType current,
    required AuraThemeExtension auraTheme,
    required VoidCallback onTap,
  }) {
    final isSelected = goal == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? auraTheme.primary.withValues(alpha: 0.12) : AuraColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? auraTheme.primary : AuraColors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? auraTheme.primary.withValues(alpha: 0.20)
                    : AuraColors.surface2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? auraTheme.primary : AuraColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AuraColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AuraColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.checkCircle2, size: 18, color: auraTheme.primary),
          ],
        ),
      ),
    );
  }
}
