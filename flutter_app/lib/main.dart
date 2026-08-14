import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/transformation_state.dart';
import 'models/models.dart';
import 'screens/today_screen.dart';
import 'screens/plan_log_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/coach_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/weekly_plan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: AuraPwaApp()));
}

ThemeData getAuraTheme(CoachSoul soul) {
  Color primaryColor;
  Color secondaryColor;
  Color scaffoldBackgroundColor;
  Color cardColor;

  switch (soul) {
    case CoachSoul.supporter:
      primaryColor = const Color(0xFF8EA885); // Soft Sage Green
      secondaryColor = const Color(0xFF9A7EB8); // Soft Lavender-Purple
      scaffoldBackgroundColor = const Color(0xFF0C0A0D); // Warm Void
      cardColor = const Color(0xFF141217);
      break;
    case CoachSoul.pro:
      primaryColor = const Color(0xFF00B2FF); // Electric Blue
      secondaryColor = const Color(0xFFFF007A); // Neon Magenta
      scaffoldBackgroundColor = const Color(0xFF0B0B0E); // Deep Void
      cardColor = const Color(0xFF131317);
      break;
    case CoachSoul.teacher:
      primaryColor = const Color(0xFF00BFA5); // Vivid Teal
      secondaryColor = const Color(0xFFB0BEC5); // Cool Metallic Silver
      scaffoldBackgroundColor = const Color(0xFF0B0D0F); // Slate Void
      cardColor = const Color(0xFF131619);
      break;
  }

  final baseTheme = ThemeData.dark();
  return baseTheme.copyWith(
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    cardColor: cardColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardColor,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      baseTheme.textTheme.copyWith(
        displayLarge: GoogleFonts.syne(fontWeight: FontWeight.bold, letterSpacing: -0.02),
        displayMedium: GoogleFonts.syne(fontWeight: FontWeight.bold, letterSpacing: -0.02),
        displaySmall: GoogleFonts.syne(fontWeight: FontWeight.bold, letterSpacing: -0.02),
        headlineLarge: GoogleFonts.syne(fontWeight: FontWeight.bold, letterSpacing: -0.02),
        headlineMedium: GoogleFonts.syne(fontWeight: FontWeight.bold, letterSpacing: -0.02),
        headlineSmall: GoogleFonts.syne(fontWeight: FontWeight.bold, letterSpacing: -0.02),
        titleLarge: GoogleFonts.syne(fontWeight: FontWeight.bold, letterSpacing: -0.02),
      ),
    ),
  );
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
      home: state.isOnboardingComplete ? const MainShell() : const OnboardingScreen(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _navigateToTab(int tabIndex, {int subIndex = 0}) {
    if (tabIndex == 1) {
      // Push Workouts / Nutrition logs as a detailed sub-page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF0B0B0E),
              title: Text(
                subIndex == 0 ? 'Workout Outline' : 'Nutrition Balance',
                style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              elevation: 0,
            ),
            body: PlanLogScreen(key: ValueKey('plan_sub_$subIndex'), initialSubIndex: subIndex),
          ),
        ),
      );
    } else if (tabIndex == 2) {
      // Push Progress trends as a detailed sub-page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF0B0B0E),
              title: Text(
                'Progress Trends',
                style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              elevation: 0,
            ),
            body: const ProgressScreen(),
          ),
        ),
      );
    } else if (tabIndex == 3) {
      // Toggle to Coach screen index (now index 2)
      setState(() {
        _selectedIndex = 2;
      });
    } else {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(transformationEngineProvider);
        final profile = state.profile;

        final List<Widget> screens = [
          TodayScreen(onNavigateToTab: _navigateToTab),
          const WeeklyPlanScreen(),
          const CoachScreen(),
        ];

        return Scaffold(
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
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
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
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.02, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: screens[_selectedIndex],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).cardColor,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: const Color(0xFFA1A1AA),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: const [
              BottomNavigationBarItem(icon: Icon(LucideIcons.home, size: 20), label: 'Today'),
              BottomNavigationBarItem(icon: Icon(LucideIcons.calendarDays, size: 20), label: 'Plan'),
              BottomNavigationBarItem(icon: Icon(LucideIcons.bot, size: 20), label: 'Coach'),
            ],
          ),
        );
      },
    );
  }
}
