import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'models/models.dart';
import 'services/analytics_service.dart';
import 'providers/analytics_provider.dart';
import 'providers/transformation_state.dart';
import 'theme/theme.dart';
import 'screens/widgets/aura_orb.dart';
import 'widgets/common/quick_coach_fab.dart';
import 'screens/today_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/coach_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Mixpanel Analytics
  final analytics = MixpanelAnalyticsService();
  await analytics.init();

  // If already authenticated on app launch, identify the session
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    await analytics.setUserId(currentUser.uid);
  }

  runApp(ProviderScope(
    overrides: [
      analyticsServiceProvider.overrideWithValue(analytics),
    ],
    child: const AuraPwaApp(),
  ));
}

class AuraSplashScreen extends ConsumerWidget {
  const AuraSplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);
    final soul = state.profile.coachSoul;

    return Scaffold(
      backgroundColor: AuraColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'aura_orb_hero',
              child: AuraOrb(
                soul: soul,
                state: OrbState.pulsing,
                size: 110,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'AURA',
              style: AuraTypography.displayMedium.copyWith(
                letterSpacing: 4.0,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AuraColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Calibrating Transformation Baseline...',
              style: AuraTypography.bodySmall.copyWith(
                color: AuraColors.textSecondary,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuraPwaApp extends ConsumerWidget {
  const AuraPwaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);

    return MaterialApp(
      title: 'AURA Transformation Coach',
      debugShowCheckedModeBanner: false,
      theme: getAuraTheme(state.profile.coachSoul),
      home: state.isInitializing
          ? const AuraSplashScreen()
          : (state.isOnboardingComplete ? const MainShell() : const OnboardingScreen()),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('[AURA LIFECYCLE] App resumed from background. Checking day status...');
      try {
        final container = ProviderScope.containerOf(context, listen: false);
        container.read(transformationEngineProvider.notifier).checkAndRefreshForNewDay();
      } catch (e) {
        debugPrint('[AURA LIFECYCLE] Failed to refresh day on resume: $e');
      }
    }
  }

  void _logScreen(WidgetRef ref, int index) {
    final names = ['today', 'coach', 'insights'];
    if (index >= 0 && index < names.length) {
      ref.read(analyticsServiceProvider).logScreenView(names[index]);
    }
  }

  void _openWorkoutScreen(WidgetRef ref) {
    ref.read(analyticsServiceProvider).logScreenView('workout_active');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WorkoutScreen(),
      ),
    );
  }

  void _navigateToTab(WidgetRef ref, int tabIndex, {int subIndex = 0}) {
    if (tabIndex >= 0 && tabIndex <= 2) {
      setState(() {
        _selectedIndex = tabIndex;
      });
      _logScreen(ref, tabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(transformationEngineProvider);
        final profile = state.profile;

        // Listen to soul/goal changes and update Mixpanel super properties
        ref.listen(transformationEngineProvider, (prev, next) {
          if (prev?.profile.coachSoul != next.profile.coachSoul ||
              prev?.profile.goal != next.profile.goal) {
            ref.read(analyticsServiceProvider).registerSuperProperties({
              'coach_soul': next.profile.coachSoul.name,
              'goal_type': next.profile.goal.name,
            });
          }
        });

        final List<Widget> screens = [
          TodayScreen(
            onNavigateToTab: (idx, {subIndex = 0}) => _navigateToTab(ref, idx, subIndex: subIndex),
            onOpenWorkout: () => _openWorkoutScreen(ref),
          ),
          const CoachScreen(),
          const InsightsScreen(),
        ];

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            // 1. If not on the Today tab, gesture back returns to Today tab
            if (_selectedIndex != 0) {
              setState(() {
                _selectedIndex = 0;
              });
              _logScreen(ref, 0);
              return;
            }

            // 2. If on Today tab (root), handle back gesture gracefully
            final now = DateTime.now();
            if (_lastBackPressTime == null ||
                now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
              _lastBackPressTime = now;
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Press back again to exit AURA',
                    style: TextStyle(color: AuraColors.textPrimary, fontSize: 13),
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AuraColors.surface2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AuraColors.borderSubtle),
                  ),
                ),
              );
              return;
            }

            // 3. Double-back within 2s on native platforms closes the app cleanly
            if (!kIsWeb) {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(LucideIcons.sparkles, color: Theme.of(context).colorScheme.primary, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AURA',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.8),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      ref.read(analyticsServiceProvider).logScreenView('profile');
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        profile.name.isNotEmpty ? profile.name.substring(0, 2).toUpperCase() : 'AV',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: AuraCurves.fluidEaseOut,
                );
                return FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.015, 0.0),
                      end: Offset.zero,
                    ).animate(curved),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_selectedIndex),
                child: screens[_selectedIndex],
              ),
            ),
            floatingActionButton: _selectedIndex == 0 ? const QuickCoachFAB(contextTag: 'today') : null,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() => _selectedIndex = index);
                _logScreen(ref, index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Theme.of(context).cardColor,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: AuraColors.textSecondary,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              items: const [
                BottomNavigationBarItem(icon: Icon(LucideIcons.compass, size: 20), label: 'Today'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.bot, size: 20), label: 'Coach'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.sparkles, size: 20), label: 'Insights'),
              ],
            ),
          ),
        );
      },
    );
  }
}
