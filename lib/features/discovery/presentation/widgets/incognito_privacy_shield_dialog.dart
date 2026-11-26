import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import '../providers/discovery_provider.dart';

/// Interactive modal sheet explaining and toggling the Incognito Privacy Shield.
/// Implements stack-isolation controls to isolate queer visibility from heterosexual discovery queues.
class IncognitoPrivacyShieldSheet extends ConsumerWidget {
  const IncognitoPrivacyShieldSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const IncognitoPrivacyShieldSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isIncognito = ref.watch(incognitoShieldProvider);
    final notifier = ref.read(incognitoShieldProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isIncognito
                        ? (isDark
                            ? AppColors.glanceableCyan.withValues(alpha: 0.18)
                            : AppColors.glacierLight)
                        : (isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isIncognito
                          ? AppColors.glanceableCyan
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isIncognito
                        ? Icons.shield_rounded
                        : Icons.shield_outlined,
                    color: isIncognito
                        ? AppColors.glanceableCyanDeep
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incognito Privacy Shield',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isIncognito
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isIncognito ? 'SHIELD ACTIVE' : 'SHIELD INACTIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: isIncognito
                                ? AppColors.success
                                : (isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isIncognito,
                  activeColor: AppColors.glanceableCyanDeep,
                  activeTrackColor: AppColors.glanceableCyan,
                  onChanged: (val) {
                    notifier.set(val);
                    ref.read(discoveryProvider.notifier).toggleIncognito(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val
                              ? 'Incognito Shield activated: Queue isolated.'
                              : 'Incognito Shield deactivated: Mixed queue restored.',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: val
                            ? AppColors.encreDeep
                            : AppColors.textSecondary,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Explanation Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_person_outlined,
                        size: 18,
                        color: AppColors.glanceableCyanDeep,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stack Isolation Guarantee',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When activated, your profile is shielded and excluded from heterosexual-only discovery queues. You will only be visible to and matched with queer, affirming, and non-binary community members.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Demo notice banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.amber.withValues(alpha: 0.1)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.amber,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Demo Mode: In this local preview, stack isolation filters the local mock candidate queue. It does not provide real server-side invisibility until connected to the production backend.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.amber[200] : Colors.brown[700],
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.glanceableCyan,
                  foregroundColor: AppColors.encreDeep,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
