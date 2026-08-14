import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/transformation_state.dart';
import '../models/models.dart';

class WeeklyPlanScreen extends ConsumerWidget {
  const WeeklyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transformationEngineProvider);
    final plan = state.weeklyPlan;
    final isLoading = state.isAiThinking;
    final theme = Theme.of(context);
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Weekly Plan',
          style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: plan == null
          ? _buildEmptyState(context, ref, isLoading, theme)
          : _buildPlanView(context, ref, plan, todayStr, isLoading, theme),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, bool isLoading, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                LucideIcons.calendarDays,
                size: 48,
                color: theme.colorScheme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Weekly Plan Yet',
              style: GoogleFonts.syne(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a personalized 7-day workout and nutrition plan tailored to your goals.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        ref.read(transformationEngineProvider.notifier).generateWeeklyPlan();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.sparkles, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Generate My Plan',
                            style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanView(BuildContext context, WidgetRef ref, WeeklyPlan plan, String todayStr, bool isLoading, ThemeData theme) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Week label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${plan.weekId}  •  ${_formatDate(plan.startDate)} – ${_formatDate(plan.endDate)}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Overview
                Text(
                  plan.overview,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                if (plan.coachNote != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.messageSquare, size: 14, color: theme.colorScheme.secondary.withOpacity(0.7)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            plan.coachNote!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Regenerate button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            ref.read(transformationEngineProvider.notifier).generateWeeklyPlan();
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.refreshCw, size: 14),
                    label: Text(isLoading ? 'Generating...' : 'Regenerate', style: const TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Day cards
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final day = plan.days[index];
                final isToday = day.date == todayStr;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 60)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 12 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildDayCard(context, day, isToday, theme),
                );
              },
              childCount: plan.days.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(BuildContext context, WeeklyDayPlan day, bool isToday, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isToday
            ? Border.all(color: theme.colorScheme.primary.withOpacity(0.4), width: 1.5)
            : Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header row
            Row(
              children: [
                // Day name + date
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        day.dayName,
                        style: GoogleFonts.syne(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isToday ? theme.colorScheme.primary : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(day.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                if (day.isRestDay)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.moonStar, size: 12, color: Colors.white.withOpacity(0.4)),
                        const SizedBox(width: 4),
                        Text(
                          'REST',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Title + focus area
            Text(
              day.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: day.isRestDay ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.85),
              ),
            ),
            if (day.focusArea.isNotEmpty && !day.isRestDay) ...[
              const SizedBox(height: 4),
              Text(
                day.focusArea,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.secondary.withOpacity(0.6),
                ),
              ),
            ],
            // Exercise chips
            if (day.exerciseNames.isNotEmpty && !day.isRestDay) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: day.exerciseNames.map((name) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            // Nutrition focus
            if (day.nutritionFocus != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(LucideIcons.utensils, size: 12, color: theme.colorScheme.primary.withOpacity(0.5)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      day.nutritionFocus!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.4),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[d.month - 1]} ${d.day}';
    } catch (_) {
      return dateStr;
    }
  }
}
