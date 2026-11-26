import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/features/chat/presentation/providers/chat_provider.dart';
import '../../domain/models/date_plan_model.dart';
import 'voucher_screen.dart';

class ItineraryDetailScreen extends ConsumerWidget {
  final DatePlan plan;

  const ItineraryDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withinBudget = plan.totalEstimatedCost <= plan.budgetLimit;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accent = AppColors.adaptiveAccent(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Curated Itinerary',
          style: AppTypography.headlineMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: accent),
            tooltip: 'Share Itinerary to Match Chat',
            onPressed: () => _shareToMatchChat(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Summary Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.glacierBorder,
                ),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.accent : AppColors.glacierLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          plan.vibe.toUpperCase(),
                          style: TextStyle(
                            color: isDark ? AppColors.encreDeep : AppColors.glacierInk,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        plan.neighborhood,
                        style: TextStyle(color: mutedColor, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    plan.title,
                    style: AppTypography.headlineMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: AppColors.adaptiveBorder(isDark)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estimated Total', style: TextStyle(color: mutedColor, fontSize: 11)),
                          Text(
                            '₹${plan.totalEstimatedCost.toInt()}',
                            style: TextStyle(
                              color: withinBudget ? AppColors.success : AppColors.warning,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Budget Ceiling', style: TextStyle(color: mutedColor, fontSize: 11)),
                          Text(
                            '₹${plan.budgetLimit.toInt()}',
                            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Chronological Stops Timeline
            Text(
              'CHRONOLOGICAL ITINERARY TIMELINE',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: accent,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            ...plan.stops.map((stop) => _buildStopCard(context, stop)),

            const SizedBox(height: 20),

            // Partner Voucher CTA Card (Glanceable Deep Encre Card)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.encrePrismGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.encreBorderDark),
                boxShadow: AppColors.primaryShadow,
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.confirmation_number_outlined, color: AppColors.accent, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '10% Instant Partner Bill Discount',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'Digital cryptographic voucher for Subko & partner cafes',
                              style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.encreDeep,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VoucherScreen(plan: plan),
                        ),
                      );
                    },
                    child: const Text('View & Redeem Digital Voucher', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Share to Match Chat Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: AppColors.adaptiveOnAccent(isDark),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.send_rounded),
              label: const Text('Share Itinerary to Match Chat', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => _shareToMatchChat(context, ref),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStopCard(BuildContext context, ItineraryStop stop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final headerBg = isDark ? AppColors.encreElevated : AppColors.glacierLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accent = AppColors.adaptiveAccent(isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.adaptiveBorder(isDark)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step pill & time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'STOP ${stop.stepNumber}',
                    style: TextStyle(
                      color: AppColors.adaptiveOnAccent(isDark),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  stop.timeSlot,
                  style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  '${stop.durationMinutes} mins',
                  style: TextStyle(color: mutedColor, fontSize: 11),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.venueName,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stop.activityTitle,
                  style: TextStyle(
                    color: isDark ? AppColors.accentTeal : AppColors.glacierInk,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stop.description,
                  style: TextStyle(color: mutedColor, fontSize: 13, height: 1.35),
                ),
                const SizedBox(height: 10),
                if (stop.isQueerFriendlyPartner) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.adaptiveHighlightBg(isDark),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.glacierBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          color: isDark ? AppColors.accent : AppColors.accentInk,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          stop.partnerDiscountDetails ?? 'Queer-Friendly Partner Venue',
                          style: TextStyle(
                            color: isDark ? AppColors.accent : AppColors.glacierInk,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Est. Cost: ', style: TextStyle(color: mutedColor, fontSize: 12)),
                    Text(
                      '₹${stop.estimatedCost.toInt()}',
                      style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareToMatchChat(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accent = AppColors.adaptiveAccent(isDark);

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Date Plan into Chat',
                style: AppTypography.headlineMedium.copyWith(
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a match to directly dispatch this curated itinerary with 10% partner discount:',
                style: TextStyle(color: mutedColor, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400'),
                      ),
                      title: Text('Aarya', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Active now', style: TextStyle(color: AppColors.success, fontSize: 11)),
                      trailing: Icon(Icons.send, color: accent),
                      onTap: () {
                        ref.read(conversationMessagesProvider('conv_1').notifier).sendMessage(
                          'Hey Aarya, check out this date itinerary I generated for us on Date²! 🍷✨',
                          itinerarySnippet: {
                            'title': plan.title,
                            'summary': plan.stops.map((s) => s.venueName).join(' ➔ '),
                            'budget': plan.totalEstimatedCost.toInt().toString(),
                          },
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('🎉 Itinerary shared with Aarya!'),
                            backgroundColor: isDark ? AppColors.encreElevated : AppColors.primary,
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400'),
                      ),
                      title: Text('Zayan', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                      subtitle: Text('Matched yesterday', style: TextStyle(color: mutedColor, fontSize: 11)),
                      trailing: Icon(Icons.send, color: accent),
                      onTap: () {
                        ref.read(conversationMessagesProvider('conv_2').notifier).sendMessage(
                          'Hey Zayan, generated this date plan for us!',
                          itinerarySnippet: {
                            'title': plan.title,
                            'summary': plan.stops.map((s) => s.venueName).join(' ➔ '),
                            'budget': plan.totalEstimatedCost.toInt().toString(),
                          },
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('🎉 Itinerary shared with Zayan!'),
                            backgroundColor: isDark ? AppColors.encreElevated : AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
