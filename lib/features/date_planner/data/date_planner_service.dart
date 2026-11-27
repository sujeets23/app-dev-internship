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
  static const Map<String, List<String>> _neighborhoodVenues = {
    'Bandra West, Mumbai': [
      'Subko Specialty Coffee & Craftery',
      'The Olive Bistro & Tapas',
      'Bandra Bandstand Sunset Promenade',
    ],
    'Colaba & Fort, Mumbai': [
      'Kala Ghoda Pavement Roasters',
      'Burma Burma Artisanal Kitchen',
      'Marine Drive Starlit Walk',
    ],
    'Indiranagar, Bengaluru': [
      'Araku Craft Coffee Collective',
      'The Reservoire Rooftop Courtyard',
      '100ft Road Boutique Dessert Walk',
    ],
    'Koramangala, Bengaluru': [
      'Third Wave Coffee Studio',
      'Bistro Claytopia & Patio',
      'Koramangala 4th Block Lantern Walk',
    ],
    'Hauz Khas, New Delhi': [
      'Coast Cafe Verandah Roasters',
      'Naivedyam & Hauz Khas Courtyards',
      'Deer Park Twilight Stroll',
    ],
    'Koregaon Park, Pune': [
      'Zen Cafe Botanical Courtyard',
      'Arthur\'s Theme & Bistro',
      'Osho Teerth Park Evening Walk',
    ],
  };

  @override
  Future<DatePlan> generateDatePlan({
    required double budget,
    required String neighborhood,
    required String vibe,
    required String dietary,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final venues = _neighborhoodVenues[neighborhood] ??
        const [
          'Local Partner Artisan Cafe',
          'Inclusive Neighborhood Bistro',
          'Public Twilight Promenade',
        ];

    // Strict budget ceiling: keep itemized total <= budget even at ₹500 min
    final double stop1Cost = (budget * 0.28).roundToDouble();
    final double stop2Cost = (budget * 0.50).roundToDouble();
    final double stop3Cost =
        ((budget - stop1Cost - stop2Cost) * 0.5).clamp(50.0, 400.0).roundToDouble();
    final double rawTotal = stop1Cost + stop2Cost + stop3Cost;
    final double totalEstimated =
        rawTotal > budget ? budget : rawTotal;

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
          venueName: venues[0],
          neighborhood: neighborhood,
          activityTitle: 'Warm Icebreaker & Specialty Brews ($vibe)',
          description:
              'Start with artisan coffee or chai and relaxed conversation in a verified queer-friendly space.',
          estimatedCost: stop1Cost,
          durationMinutes: 75,
          isQueerFriendlyPartner: true,
          partnerDiscountDetails: '10% Instant Bill Discount with Date² QR Voucher',
          imageUrl:
              'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
        ),
        ItineraryStop(
          stepNumber: 2,
          timeSlot: '07:00 PM - 08:30 PM',
          venueName: venues[1],
          neighborhood: neighborhood,
          activityTitle: '$vibe Shared Dining ($dietary)',
          description:
              'Enjoy curated small plates with $dietary-friendly options in an inviting public dining room.',
          estimatedCost: stop2Cost,
          durationMinutes: 90,
          isQueerFriendlyPartner: true,
          partnerDiscountDetails: '10% Instant Bill Discount with Date² QR Voucher',
          imageUrl:
              'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        ),
        ItineraryStop(
          stepNumber: 3,
          timeSlot: '08:45 PM - 09:30 PM',
          venueName: venues[2],
          neighborhood: neighborhood,
          activityTitle: 'Evening Stroll & Reflection',
          description:
              'Wind down along $neighborhood\'s lively public promenade to wrap up the evening comfortably.',
          estimatedCost: stop3Cost,
          durationMinutes: 45,
          isQueerFriendlyPartner: false,
          imageUrl:
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
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
