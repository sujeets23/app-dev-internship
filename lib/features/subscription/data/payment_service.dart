import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/subscription_model.dart';

abstract class IPaymentService {
  Future<UserBillingProfile> fetchBillingProfile();
  Future<PaymentTransaction> processSubscriptionPayment({
    required SubscriptionTier tier,
    required String paymentMethod,
    required bool enableAutoPayMandate,
  });
  Future<PaymentTransaction> processMicroUnlock({
    required String unlockType, // 'boost_29', 'plan_29', or 'rewind_49'
    required double amount,
    required String paymentMethod,
  });
  Future<bool> cancelAutoPayMandate(String mandateId);
  Future<UserBillingProfile> setGracePeriodDemo(bool active);
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

  @override
  Future<UserBillingProfile> setGracePeriodDemo(bool active) =>
      throw UnimplementedError('Backend offline');
}

/// Simulated payment and subscription ledger service for frontend demo testing.
/// Clearly distinguishes simulated demo states from real Razorpay / UPI mandates.
class MockPaymentService implements IPaymentService {
  static const String _storageKey = 'date2_billing_profile_v1';
  final SharedPreferences? _prefs;
  bool _loadedFromPrefs = false;

  MockPaymentService([this._prefs]);

  UserBillingProfile _profile = UserBillingProfile(
    activeTier: SubscriptionTier.free,
    renewalDate: null,
    isAutoPayActive: false,
    autoPayMandateId: null,
    inGracePeriod: false,
    transactionHistory: [
      PaymentTransaction(
        transactionId: 'txn_init_001',
        description: 'Account Setup Free Plan (Demo)',
        amount: 0.0,
        date: DateTime.now().subtract(const Duration(days: 14)),
        method: 'Free Tier',
        status: 'Success',
      ),
    ],
  );

  void _ensureLoaded() {
    if (_loadedFromPrefs || _prefs == null) return;
    _loadedFromPrefs = true;
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final tier = SubscriptionTier.values.firstWhere(
        (t) => t.name == map['activeTier'],
        orElse: () => SubscriptionTier.free,
      );
      final txns = (map['transactionHistory'] as List<dynamic>? ?? [])
          .map((item) {
            final m = Map<String, dynamic>.from(item as Map);
            return PaymentTransaction(
              transactionId: m['transactionId'] as String,
              description: m['description'] as String,
              amount: (m['amount'] as num).toDouble(),
              date: DateTime.parse(m['date'] as String),
              method: m['method'] as String,
              status: m['status'] as String,
              invoiceUrl: m['invoiceUrl'] as String?,
            );
          })
          .toList();
      _profile = UserBillingProfile(
        activeTier: tier,
        renewalDate: map['renewalDate'] != null
            ? DateTime.tryParse(map['renewalDate'] as String)
            : null,
        isAutoPayActive: map['isAutoPayActive'] as bool? ?? false,
        autoPayMandateId: map['autoPayMandateId'] as String?,
        inGracePeriod: map['inGracePeriod'] as bool? ?? false,
        transactionHistory: txns,
      );
    } catch (_) {}
  }

  void _persist() {
    if (_prefs == null) return;
    final encoded = jsonEncode({
      'activeTier': _profile.activeTier.name,
      'renewalDate': _profile.renewalDate?.toIso8601String(),
      'isAutoPayActive': _profile.isAutoPayActive,
      'autoPayMandateId': _profile.autoPayMandateId,
      'inGracePeriod': _profile.inGracePeriod,
      'transactionHistory': _profile.transactionHistory
          .map((t) => {
                'transactionId': t.transactionId,
                'description': t.description,
                'amount': t.amount,
                'date': t.date.toIso8601String(),
                'method': t.method,
                'status': t.status,
                'invoiceUrl': t.invoiceUrl,
              })
          .toList(),
    });
    _prefs.setString(_storageKey, encoded);
  }

  @override
  Future<UserBillingProfile> fetchBillingProfile() async {
    _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 200));
    return _profile;
  }

  @override
  Future<PaymentTransaction> processSubscriptionPayment({
    required SubscriptionTier tier,
    required String paymentMethod,
    required bool enableAutoPayMandate,
  }) async {
    _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 500));

    final double price = tier == SubscriptionTier.pro ? 100.0 : 50.0;
    final String tierName = tier == SubscriptionTier.pro ? 'Pro Plan' : 'Basic Plan';
    final txnId = 'demo_pay_${DateTime.now().millisecondsSinceEpoch}';

    final txn = PaymentTransaction(
      transactionId: txnId,
      description: '$tierName Monthly Subscription (Demo)',
      amount: price,
      date: DateTime.now(),
      method: paymentMethod,
      status: 'Success',
      invoiceUrl: null,
    );

    _profile = _profile.copyWith(
      activeTier: tier,
      renewalDate: DateTime.now().add(const Duration(days: 30)),
      isAutoPayActive: enableAutoPayMandate,
      autoPayMandateId: enableAutoPayMandate
          ? 'DEMO_MANDATE_${DateTime.now().millisecondsSinceEpoch}'
          : null,
      clearAutoPayMandate: !enableAutoPayMandate,
      inGracePeriod: false,
      transactionHistory: [txn, ..._profile.transactionHistory],
    );
    _persist();
    return txn;
  }

  @override
  Future<PaymentTransaction> processMicroUnlock({
    required String unlockType,
    required double amount,
    required String paymentMethod,
  }) async {
    _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 450));

    final String desc;
    switch (unlockType) {
      case 'boost_29':
        desc = 'Profile Super Boost (1-Hour Top Placement • Demo)';
        break;
      case 'plan_29':
        desc = 'Single AI Date Plan Unlock (Demo)';
        break;
      default:
        desc = 'Incognito Rewind Pass (Demo)';
        break;
    }
    final txnId = 'demo_unlock_${DateTime.now().millisecondsSinceEpoch}';

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
    _persist();
    return txn;
  }

  @override
  Future<bool> cancelAutoPayMandate(String mandateId) async {
    _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 300));
    _profile = _profile.copyWith(
      isAutoPayActive: false,
      clearAutoPayMandate: true,
    );
    _persist();
    return true;
  }

  @override
  Future<UserBillingProfile> setGracePeriodDemo(bool active) async {
    _ensureLoaded();
    _profile = _profile.copyWith(inGracePeriod: active);
    _persist();
    return _profile;
  }
}
