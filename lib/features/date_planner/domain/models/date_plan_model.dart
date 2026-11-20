class ItineraryStop {
  final int stepNumber;
  final String timeSlot;
  final String venueName;
  final String neighborhood;
  final String activityTitle;
  final String description;
  final double estimatedCost;
  final int durationMinutes;
  final bool isQueerFriendlyPartner;
  final String? partnerDiscountDetails;
  final String? imageUrl;

  const ItineraryStop({
    required this.stepNumber,
    required this.timeSlot,
    required this.venueName,
    required this.neighborhood,
    required this.activityTitle,
    required this.description,
    required this.estimatedCost,
    required this.durationMinutes,
    this.isQueerFriendlyPartner = false,
    this.partnerDiscountDetails,
    this.imageUrl,
  });
}

class DatePlan {
  final String id;
  final String title;
  final String neighborhood;
  final String vibe;
  final String dietary;
  final double budgetLimit;
  final double totalEstimatedCost;
  final List<ItineraryStop> stops;
  final DateTime createdAt;
  final String? digitalVoucherCode;
  final bool isVoucherRedeemed;

  const DatePlan({
    required this.id,
    required this.title,
    required this.neighborhood,
    required this.vibe,
    required this.dietary,
    required this.budgetLimit,
    required this.totalEstimatedCost,
    required this.stops,
    required this.createdAt,
    this.digitalVoucherCode,
    this.isVoucherRedeemed = false,
  });

  DatePlan copyWith({
    String? id,
    String? title,
    String? neighborhood,
    String? vibe,
    String? dietary,
    double? budgetLimit,
    double? totalEstimatedCost,
    List<ItineraryStop>? stops,
    DateTime? createdAt,
    String? digitalVoucherCode,
    bool? isVoucherRedeemed,
  }) {
    return DatePlan(
      id: id ?? this.id,
      title: title ?? this.title,
      neighborhood: neighborhood ?? this.neighborhood,
      vibe: vibe ?? this.vibe,
      dietary: dietary ?? this.dietary,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      totalEstimatedCost: totalEstimatedCost ?? this.totalEstimatedCost,
      stops: stops ?? this.stops,
      createdAt: createdAt ?? this.createdAt,
      digitalVoucherCode: digitalVoucherCode ?? this.digitalVoucherCode,
      isVoucherRedeemed: isVoucherRedeemed ?? this.isVoucherRedeemed,
    );
  }
}
