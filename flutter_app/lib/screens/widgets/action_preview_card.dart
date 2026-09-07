import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/command_preview.dart';
import '../../theme/theme.dart';

class ActionPreviewCard extends StatelessWidget {
  final CommandPreview preview;
  final VoidCallback? onUndo;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const ActionPreviewCard({
    super.key,
    required this.preview,
    this.onUndo,
    this.onApprove,
    this.onReject,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'workout':
        return LucideIcons.dumbbell;
      case 'nutrition':
        return LucideIcons.utensils;
      case 'recovery':
        return LucideIcons.moon;
      case 'profile':
        return LucideIcons.userCheck;
      default:
        return LucideIcons.sparkles;
    }
  }

  String _getCategoryTitle(CommandPreview p) {
    if (p.isHighRisk) return 'ACTION CONFIRMATION REQUIRED';
    switch (p.category.toLowerCase()) {
      case 'workout':
        return 'WORKOUT ADJUSTED';
      case 'nutrition':
        return 'FUEL LOGGED';
      case 'recovery':
        return 'RECOVERY SYNCED';
      case 'profile':
        return 'PROFILE UPDATED';
      default:
        return 'ACTION APPLIED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auraTheme = context.auraTheme;
    final isHighRisk = preview.isHighRisk;
    final accentColor = isHighRisk ? const Color(0xFFFFB340) : auraTheme.primary;

    return Container(
      margin: const EdgeInsets.only(top: 10.0, bottom: 6.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: auraTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: isHighRisk ? 0.8 : 0.4),
          width: isHighRisk ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isHighRisk ? 0.15 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header: Category, Icon & Status ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_getCategoryIcon(preview.category), color: accentColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _getCategoryTitle(preview),
                    style: AuraTypography.sectionHeader.copyWith(
                      color: accentColor,
                      fontSize: 11,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  isHighRisk ? 'Requires Approval' : 'Auto-applied ✓',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ─── Summary ───
          Text(
            preview.summary,
            style: AuraTypography.bodyMedium.copyWith(
              color: AuraColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),

          // ─── Diff Changes ───
          if (preview.changes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: auraTheme.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AuraColors.borderSubtle),
              ),
              child: Column(
                children: preview.changes.map((change) {
                  final hasBefore = change.before != null && change.before.toString().isNotEmpty;
                  final hasAfter = change.after != null && change.after.toString().isNotEmpty;

                  if (hasBefore && hasAfter) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              change.before.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AuraColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Icon(LucideIcons.arrowRight, size: 13, color: accentColor),
                          ),
                          Expanded(
                            child: Text(
                              change.after.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: auraTheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(
                      children: [
                        Text(
                          '${change.target}: ',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AuraColors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            change.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AuraColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // ─── Warnings ───
          if (preview.warnings.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...preview.warnings.map(
              (w) => Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertCircle, size: 12, color: AuraColors.textTertiary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        w,
                        style: AuraTypography.bodySmall.copyWith(
                          fontSize: 11,
                          color: AuraColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ─── Interactive Action Buttons ───
          if (isHighRisk) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onReject != null)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AuraColors.textSecondary,
                        side: const BorderSide(color: AuraColors.borderSubtle),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: onReject,
                      child: const Text('Reject', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                if (onReject != null && onApprove != null) const SizedBox(width: 8),
                if (onApprove != null)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: onApprove,
                      child: const Text('Confirm & Apply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ] else if (onUndo != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(LucideIcons.undo2, size: 12, color: AuraColors.textSecondary),
                label: const Text('Undo', style: TextStyle(fontSize: 11, color: AuraColors.textSecondary)),
                onPressed: onUndo,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
