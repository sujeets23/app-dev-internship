import 'dart:async';
import '../domain/models/subscription_model.dart';

abstract class IPaymentService {
  Future<UserBillingProfile> fetchBillingProfile();
  Future<PaymentTransaction> processSubscriptionPayment({
    required SubscriptionTier tier,
    required String paymentMethod,
    required bool enableAutoPayMandate,
  });
  Future<PaymentTransaction> processMicroUnlock({
    required String unlockType, // 'boost_29' or 'rewind_49'
    required double amount,
    required String paymentMethod,
  });
  Future<bool> cancelAutoPayMandate(String mandateId);
}

class ProductionPaymentService implements IPaymentService {
  final String baseUrl;
  ProductionPaymentService({this.baseUrl = 'https://api.date2.app'});

  @override
  Future<UserBillingProfile> fetchBillingProfile() =>
      throw UnimplementedError('Backend offline');

  @override
  Future<PaymentTransaction> processSubscriptionPayment({
    required SubscriptionTier tier,
    required String paymentMethod,
    required bool enableAutoPayMandate,
  }) =>
      throw UnimplementedError('POST /v1/payments/subscriptions backend offline');

  @override
  Future<PaymentTransaction> processMicroUnlock({
    required String unlockType,
    required double amount,
    required String paymentMethod,
  }) =>
      throw UnimplementedError('Backend offline');

  @override
  Future<bool> cancelAutoPayMandate(String mandateId) =>
      throw UnimplementedError('Backend offline');
}

class MockPaymentService implements IPaymentService {
  UserBillingProfile _profile = UserBillingProfile(
    activeTier: SubscriptionTier.free,
    renewalDate: null,
    isAutoPayActive: false,
    autoPayMandateId: null,
    inGracePeriod: false,
    transactionHistory: [
      PaymentTransaction(
        transactionId: 'txn_init_001',
        description: 'Account Setup Free Plan',
        amount: 0.0,
        date: DateTime.now().subtract(const Duration(days: 14)),
        method: 'Free Tier',
        status: 'Success',
      ),
    ],
  );

  @override
  Future<UserBillingProfile> fetchBillingProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _profile;
  }

  @override
  Future<PaymentTransaction> processSubscriptionPayment({
    required SubscriptionTier tier,
    required String paymentMethod,
    required bool enableAutoPayMandate,
  }) async {
    // Razorpay test mode simulation with 0.8s gateway response
    await Future.delayed(const Duration(milliseconds: 800));

    final double price = tier == SubscriptionTier.pro ? 100.0 : 50.0;
    final String tierName = tier == SubscriptionTier.pro ? 'Pro Plan' : 'Basic Plan';
    final txnId = 'razor_pay_${DateTime.now().millisecondsSinceEpoch}';

    final txn = PaymentTransaction(
      transactionId: txnId,
      description: '$tierName Monthly Subscription',
      amount: price,
      date: DateTime.now(),
      method: paymentMethod,
      status: 'Success',
      invoiceUrl: 'https://invoices.date2.app/$txnId.pdf',
    );

    _profile = _profile.copyWith(
      activeTier: tier,
      renewalDate: DateTime.now().add(const Duration(days: 30)),
      isAutoPayActive: enableAutoPayMandate,
      autoPayMandateId: enableAutoPayMandate ? 'AUTOPAY_MANDATE_${DateTime.now().millisecondsSinceEpoch}' : null,
      inGracePeriod: false,
      transactionHistory: [txn, ..._profile.transactionHistory],
    );

    return txn;
  }

  @override
  Future<PaymentTransaction> processMicroUnlock({
    required String unlockType,
    required double amount,
    required String paymentMethod,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final String desc = unlockType == 'boost_29'
        ? 'Profile Super Boost (1-Hour Top Placement)'
        : 'Incognito Rewind (Un-swipe & Revisit Deck)';
    final txnId = 'unlock_${DateTime.now().millisecondsSinceEpoch}';

    final txn = PaymentTransaction(
      transactionId: txnId,
      description: desc,
      amount: amount,
      date: DateTime.now(),
      method: paymentMethod,
      status: 'Success',
    );

    _profile = _profile.copyWith(
      transactionHistory: [txn, ..._profile.transactionHistory],
    );

    return txn;
  }

  @override
  Future<bool> cancelAutoPayMandate(String mandateId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _profile = _profile.copyWith(
      isAutoPayActive: false,
      clearAutoPayMandate: true,
    );
    return true;
  }
}
