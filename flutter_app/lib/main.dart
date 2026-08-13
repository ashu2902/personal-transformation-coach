import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'providers/transformation_state.dart';
import 'screens/today_screen.dart';
import 'screens/plan_log_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/coach_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AuraPwaApp()));
}

class AuraPwaApp extends ConsumerWidget {
  const AuraPwaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);

    return MaterialApp(
      title: 'AURA Transformation Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F17),
        cardColor: const Color(0xFF141923),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981), // Emerald-500
          secondary: Color(0xFF06B6D4), // Cyan-500
          surface: Color(0xFF141923),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
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
  int _planSubIndex = 0;

  void _navigateToTab(int tabIndex, {int subIndex = 0}) {
    setState(() {
      _selectedIndex = tabIndex;
      _planSubIndex = subIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(transformationEngineProvider);
        final profile = state.profile;

        final List<Widget> screens = [
          TodayScreen(onNavigateToTab: _navigateToTab),
          PlanLogScreen(key: ValueKey('plan_sub_$_planSubIndex'), initialSubIndex: _planSubIndex),
          const ProgressScreen(),
          const CoachScreen(),
        ];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF0B0F17),
            elevation: 0,
            title: Row(
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
                      child: const Icon(LucideIcons.sparkles, color: Color(0xFF10B981), size: 16),
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
                    backgroundColor: const Color(0xFF10B981),
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
            backgroundColor: const Color(0xFF141923),
            selectedItemColor: const Color(0xFF10B981),
            unselectedItemColor: const Color(0xFFA1A1AA),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: const [
              BottomNavigationBarItem(icon: Icon(LucideIcons.home, size: 20), label: 'Today'),
              BottomNavigationBarItem(icon: Icon(LucideIcons.layoutGrid, size: 20), label: 'Workouts'),
              BottomNavigationBarItem(icon: Icon(LucideIcons.trendingUp, size: 20), label: 'Progress'),
              BottomNavigationBarItem(icon: Icon(LucideIcons.bot, size: 20), label: 'Coach'),
            ],
          ),
        );
      },
    );
  }
}
