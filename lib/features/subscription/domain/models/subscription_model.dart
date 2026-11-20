enum SubscriptionTier {
  free,
  basic,
  pro,
}

class SubscriptionPlan {
  final SubscriptionTier tier;
  final String title;
  final double pricePerMonth;
  final String description;
  final List<String> features;
  final bool isRecommended;

  const SubscriptionPlan({
    required this.tier,
    required this.title,
    required this.pricePerMonth,
    required this.description,
    required this.features,
    this.isRecommended = false,
  });
}

class PaymentTransaction {
  final String transactionId;
  final String description;
  final double amount;
  final DateTime date;
  final String method; // 'UPI - Google Pay', 'UPI AutoPay', 'Razorpay Test'
  final String status; // 'Success', 'Pending', 'Failed'
  final String? invoiceUrl;

  const PaymentTransaction({
    required this.transactionId,
    required this.description,
    required this.amount,
    required this.date,
    required this.method,
    required this.status,
    this.invoiceUrl,
  });
}

class UserBillingProfile {
  final SubscriptionTier activeTier;
  final DateTime? renewalDate;
  final bool isAutoPayActive;
  final String? autoPayMandateId;
  final bool inGracePeriod;
  final List<PaymentTransaction> transactionHistory;

  const UserBillingProfile({
    required this.activeTier,
    this.renewalDate,
    this.isAutoPayActive = false,
    this.autoPayMandateId,
    this.inGracePeriod = false,
    this.transactionHistory = const [],
  });

  UserBillingProfile copyWith({
    SubscriptionTier? activeTier,
    DateTime? renewalDate,
    bool? isAutoPayActive,
    String? autoPayMandateId,
    bool clearAutoPayMandate = false,
    bool? inGracePeriod,
    List<PaymentTransaction>? transactionHistory,
  }) {
    return UserBillingProfile(
      activeTier: activeTier ?? this.activeTier,
      renewalDate: renewalDate ?? this.renewalDate,
      isAutoPayActive: isAutoPayActive ?? this.isAutoPayActive,
      autoPayMandateId: clearAutoPayMandate ? null : (autoPayMandateId ?? this.autoPayMandateId),
      inGracePeriod: inGracePeriod ?? this.inGracePeriod,
      transactionHistory: transactionHistory ?? this.transactionHistory,
    );
  }
}
