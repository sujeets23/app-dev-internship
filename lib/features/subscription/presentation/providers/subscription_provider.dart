import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/payment_service.dart';
import '../../domain/models/subscription_model.dart';

final paymentServiceProvider = Provider<IPaymentService>((ref) {
  return MockPaymentService();
});

final availablePlansProvider = Provider<List<SubscriptionPlan>>((ref) {
  return const [
    SubscriptionPlan(
      tier: SubscriptionTier.free,
      title: 'Free Plan',
      pricePerMonth: 0,
      description: 'Essential inclusive dating & discovery features.',
      features: [
        'Basic Discovery Deck (15 daily swipes)',
        'Biometric Assurance verification badge',
        'Standard text chat with mutual matches',
        'Access to Companion Marketplace (Standard escrow fees apply)',
      ],
      isRecommended: false,
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.basic,
      title: 'Basic Plan',
      pricePerMonth: 50,
      description: 'Extended discovery & verified match priority.',
      features: [
        'Unlimited swipes in Discovery Deck',
        'Up to 3 Companion bookings per month',
        'AI Date Planner (Up to 5 itinerary generations)',
        'Instant bill discount access at partner cafes',
        'See who liked your profile first',
      ],
      isRecommended: false,
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.pro,
      title: 'Pro Plan',
      pricePerMonth: 100,
      description: 'The ultimate inclusive experience with VIP privileges.',
      features: [
        'Full Incognito Privacy Shield control & deck isolation',
        'Unlimited AI Date Planner & 10% instant partner vouchers',
        'Priority Companion Escrow scheduling & VIP emergency concierge',
        'Unlimited mutual video calls with real-time TFLite AI shield',
        'Profile boost highlight & 5 free monthly rewinds',
        'UPI AutoPay recurring renewal with 48h grace protection',
      ],
      isRecommended: true,
    ),
  ];
});

class BillingNotifier extends AsyncNotifier<UserBillingProfile> {
  IPaymentService get _service => ref.read(paymentServiceProvider);

  @override
  Future<UserBillingProfile> build() async {
    return _service.fetchBillingProfile();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _service.fetchBillingProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<PaymentTransaction> subscribe({
    required SubscriptionTier tier,
    required String paymentMethod,
    required bool enableAutoPay,
  }) async {
    final txn = await _service.processSubscriptionPayment(
      tier: tier,
      paymentMethod: paymentMethod,
      enableAutoPayMandate: enableAutoPay,
    );
    await refresh();
    return txn;
  }

  Future<PaymentTransaction> purchaseMicroUnlock({
    required String unlockType,
    required double amount,
    required String paymentMethod,
  }) async {
    final txn = await _service.processMicroUnlock(
      unlockType: unlockType,
      amount: amount,
      paymentMethod: paymentMethod,
    );
    await refresh();
    return txn;
  }

  Future<bool> cancelMandate() async {
    final current = state.value;
    if (current?.autoPayMandateId == null) return false;

    final success = await _service.cancelAutoPayMandate(current!.autoPayMandateId!);
    if (success) {
      await refresh();
    }
    return success;
  }
}

final billingProfileProvider =
    AsyncNotifierProvider<BillingNotifier, UserBillingProfile>(
  BillingNotifier.new,
);
