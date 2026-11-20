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

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Curated Itinerary',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.neonLime),
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
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.electricViolet,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          plan.vibe.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        plan.neighborhood,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    plan.title,
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estimated Total', style: TextStyle(color: AppColors.textMutedDark, fontSize: 11)),
                          Text(
                            '₹${plan.totalEstimatedCost.toInt()}',
                            style: TextStyle(
                              color: withinBudget ? AppColors.neonLime : Colors.orangeAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Budget Ceiling', style: TextStyle(color: AppColors.textMutedDark, fontSize: 11)),
                          Text(
                            '₹${plan.budgetLimit.toInt()}',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                color: AppColors.neonLime,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            ...plan.stops.map((stop) => _buildStopCard(context, stop)),

            const SizedBox(height: 20),

            // Partner Voucher CTA Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C194D), AppColors.surfaceDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.softPink.withValues(alpha: 0.6)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, color: AppColors.softPink, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '10% Instant Partner Bill Discount',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'Digital cryptographic voucher for Subko & partner cafes',
                              style: TextStyle(color: AppColors.textMutedDark, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.softPink,
                      foregroundColor: Colors.black,
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
                backgroundColor: AppColors.electricViolet,
                foregroundColor: Colors.white,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step pill & time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.neonLime,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'STOP ${stop.stepNumber}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  stop.timeSlot,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '${stop.durationMinutes} mins',
                  style: const TextStyle(color: AppColors.textMutedDark, fontSize: 11),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stop.activityTitle,
                  style: const TextStyle(
                    color: AppColors.softPink,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stop.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.35),
                ),
                const SizedBox(height: 10),
                if (stop.isQueerFriendlyPartner) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.electricViolet.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: AppColors.neonLime, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          stop.partnerDiscountDetails ?? 'Queer-Friendly Partner Venue',
                          style: const TextStyle(color: AppColors.neonLime, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Est. Cost: ', style: TextStyle(color: AppColors.textMutedDark, fontSize: 12)),
                    Text(
                      '₹${stop.estimatedCost.toInt()}',
                      style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 15),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
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
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a match to directly dispatch this curated itinerary with 10% partner discount:',
                style: TextStyle(color: AppColors.textMutedDark, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400'),
                ),
                title: const Text('Aarya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('Active now', style: TextStyle(color: AppColors.neonLime, fontSize: 11)),
                trailing: const Icon(Icons.send, color: AppColors.neonLime),
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
                    const SnackBar(
                      content: Text('🎉 Itinerary shared with Aarya!'),
                      backgroundColor: AppColors.electricViolet,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400'),
                ),
                title: const Text('Zayan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('Matched yesterday', style: TextStyle(color: AppColors.textMutedDark, fontSize: 11)),
                trailing: const Icon(Icons.send, color: AppColors.neonLime),
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
                    const SnackBar(
                      content: Text('🎉 Itinerary shared with Zayan!'),
                      backgroundColor: AppColors.electricViolet,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
