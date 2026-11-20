import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/date_planner_service.dart';
import '../../domain/models/date_plan_model.dart';

final datePlannerServiceProvider = Provider<IDatePlannerService>((ref) {
  return MockDatePlannerService();
});

class DatePlannerInputs {
  final double budget;
  final String neighborhood;
  final String vibe;
  final String dietary;

  const DatePlannerInputs({
    this.budget = 1500.0,
    this.neighborhood = 'Bandra West, Mumbai',
    this.vibe = 'Romantic',
    this.dietary = 'Any',
  });

  DatePlannerInputs copyWith({
    double? budget,
    String? neighborhood,
    String? vibe,
    String? dietary,
  }) {
    return DatePlannerInputs(
      budget: budget ?? this.budget,
      neighborhood: neighborhood ?? this.neighborhood,
      vibe: vibe ?? this.vibe,
      dietary: dietary ?? this.dietary,
    );
  }
}

class DatePlannerInputsNotifier extends Notifier<DatePlannerInputs> {
  @override
  DatePlannerInputs build() => const DatePlannerInputs();

  void setBudget(double budget) => state = state.copyWith(budget: budget);
  void setNeighborhood(String n) => state = state.copyWith(neighborhood: n);
  void setVibe(String v) => state = state.copyWith(vibe: v);
  void setDietary(String d) => state = state.copyWith(dietary: d);
}

final datePlannerInputsProvider =
    NotifierProvider<DatePlannerInputsNotifier, DatePlannerInputs>(
  DatePlannerInputsNotifier.new,
);

class DatePlanNotifier extends AsyncNotifier<DatePlan?> {
  IDatePlannerService get _service => ref.read(datePlannerServiceProvider);

  @override
  Future<DatePlan?> build() async {
    return null;
  }

  Future<void> generate({
    required double budget,
    required String neighborhood,
    required String vibe,
    required String dietary,
  }) async {
    state = const AsyncValue.loading();
    try {
      final plan = await _service.generateDatePlan(
        budget: budget,
        neighborhood: neighborhood,
        vibe: vibe,
        dietary: dietary,
      );
      state = AsyncValue.data(plan);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> redeemVoucher() async {
    final current = state.value;
    if (current == null || current.digitalVoucherCode == null) return false;

    try {
      final success = await _service.redeemVoucher(
        planId: current.id,
        voucherCode: current.digitalVoucherCode!,
      );
      if (success) {
        state = AsyncValue.data(current.copyWith(isVoucherRedeemed: true));
      }
      return success;
    } catch (_) {
      return false;
    }
  }
}

final datePlanStateProvider =
    AsyncNotifierProvider<DatePlanNotifier, DatePlan?>(
  DatePlanNotifier.new,
);
