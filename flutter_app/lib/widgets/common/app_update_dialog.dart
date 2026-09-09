import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/theme.dart';
import '../../services/app_version_service.dart';

class AppUpdateDialogs {
  /// Displays a non-dismissible blocker modal for forced breaking updates
  static void showForceUpdateDialog(
    BuildContext context, {
    required VersionCheckResult result,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: AuraColors.surface2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AuraColors.borderSubtle),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AuraColors.concernCoral.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.arrowUpCircle,
                      color: AuraColors.concernCoral,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Update Required',
                    style: AuraTypography.displaySmall.copyWith(
                      color: AuraColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    kIsWeb
                        ? 'A new version of AURA (v${result.latestVersion}) is available. Please refresh to continue using the application.'
                        : 'Your installed version is no longer supported. Please update to version ${result.latestVersion} from the store to continue.',
                    style: AuraTypography.bodyMedium.copyWith(
                      color: AuraColors.textSecondary,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AuraColors.actionGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => AppVersionService.performUpdate(result.storeUrl),
                      child: const Text(
                        kIsWeb ? 'Refresh Now' : 'Update in Store',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Displays a dismissible floating snackbar for optional updates
  static void showSoftUpdateNotification(
    BuildContext context, {
    required VersionCheckResult result,
  }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 12),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AuraColors.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AuraColors.borderSubtle),
        ),
        content: Row(
          children: [
            const Icon(
              LucideIcons.sparkles,
              color: AuraColors.actionGreen,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Version ${result.latestVersion} is available!',
                style: const TextStyle(
                  color: AuraColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: kIsWeb ? 'Refresh' : 'Update',
          textColor: AuraColors.actionGreen,
          onPressed: () => AppVersionService.performUpdate(result.storeUrl),
        ),
      ),
    );
  }
}
