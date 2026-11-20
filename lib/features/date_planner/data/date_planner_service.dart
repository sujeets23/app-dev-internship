import 'dart:async';
import '../domain/models/date_plan_model.dart';

abstract class IDatePlannerService {
  Future<DatePlan> generateDatePlan({
    required double budget,
    required String neighborhood,
    required String vibe,
    required String dietary,
  });

  Future<bool> redeemVoucher({
    required String planId,
    required String voucherCode,
  });
}

class ProductionDatePlannerService implements IDatePlannerService {
  final String baseUrl;
  ProductionDatePlannerService({this.baseUrl = 'https://api.date2.app'});

  @override
  Future<DatePlan> generateDatePlan({
    required double budget,
    required String neighborhood,
    required String vibe,
    required String dietary,
  }) =>
      throw UnimplementedError('POST /v1/planner/generate backend offline');

  @override
  Future<bool> redeemVoucher({
    required String planId,
    required String voucherCode,
  }) =>
      throw UnimplementedError('POST /v1/venues/vouchers/redeem backend offline');
}

class MockDatePlannerService implements IDatePlannerService {
  @override
  Future<DatePlan> generateDatePlan({
    required double budget,
    required String neighborhood,
    required String vibe,
    required String dietary,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Dynamic cost balancing within selected budget
    final double stop1Cost = (budget * 0.28).clamp(200.0, 800.0).roundToDouble();
    final double stop2Cost = (budget * 0.52).clamp(400.0, 2500.0).roundToDouble();
    final double stop3Cost = (budget * 0.12).clamp(100.0, 400.0).roundToDouble();
    final double totalEstimated = stop1Cost + stop2Cost + stop3Cost;

    final planId = 'dp_${DateTime.now().millisecondsSinceEpoch}';

    return DatePlan(
      id: planId,
      title: '$vibe Evening in $neighborhood',
      neighborhood: neighborhood,
      vibe: vibe,
      dietary: dietary,
      budgetLimit: budget,
      totalEstimatedCost: totalEstimated,
      createdAt: DateTime.now(),
      digitalVoucherCode: 'DATE2-PARTNER-${(budget.toInt() * 7) % 9000 + 1000}',
      isVoucherRedeemed: false,
      stops: [
        ItineraryStop(
          stepNumber: 1,
          timeSlot: '05:30 PM - 06:45 PM',
          venueName: 'Subko Specialty Coffee & Craftery',
          neighborhood: neighborhood,
          activityTitle: 'Artisan Coffee & Warm Icebreaker',
          description:
              'Begin with specialty pour-over brew and warm conversations in a safe, queer-friendly atmosphere.',
          estimatedCost: stop1Cost,
          durationMinutes: 75,
          isQueerFriendlyPartner: true,
          partnerDiscountDetails: '10% Instant Bill Discount with Date² QR Voucher',
          imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
        ),
        ItineraryStop(
          stepNumber: 2,
          timeSlot: '07:00 PM - 08:30 PM',
          venueName: 'The Olive Bistro & Tapas',
          neighborhood: neighborhood,
          activityTitle: 'Candlelit Tapas & Shared Plates',
          description:
              'Enjoy Mediterranean small plates with $dietary curated pairings in an intimate outdoor patio garden.',
          estimatedCost: stop2Cost,
          durationMinutes: 90,
          isQueerFriendlyPartner: true,
          partnerDiscountDetails: '10% Instant Bill Discount with Date² QR Voucher',
          imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        ),
        ItineraryStop(
          stepNumber: 3,
          timeSlot: '08:45 PM - 09:30 PM',
          venueName: 'Bandra Seaside Promenade Walk',
          neighborhood: neighborhood,
          activityTitle: 'Starlit Promenade Stroll',
          description:
              'A peaceful seaside wind-down under the evening breeze to reflect on the date.',
          estimatedCost: stop3Cost,
          durationMinutes: 45,
          isQueerFriendlyPartner: false,
          imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
        ),
      ],
    );
  }

  @override
  Future<bool> redeemVoucher({
    required String planId,
    required String voucherCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }
}
