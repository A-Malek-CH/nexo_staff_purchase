import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/analytics_model.dart';
import '../../data/models/order_stats_model.dart';
import '../../data/repositories/analytics_repository.dart';

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(ref.read(analyticsRepositoryProvider));
});

class AnalyticsState {
  final List<CategoryAnalytics> categoryAnalytics;
  final List<MonthlyAnalytics> monthlyAnalytics;
  final OrderStats? orderStats;
  final bool isLoading;
  final String? error;

  AnalyticsState({
    this.categoryAnalytics = const [],
    this.monthlyAnalytics = const [],
    this.orderStats,
    this.isLoading = false,
    this.error,
  });

  AnalyticsState copyWith({
    List<CategoryAnalytics>? categoryAnalytics,
    List<MonthlyAnalytics>? monthlyAnalytics,
    OrderStats? orderStats,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      categoryAnalytics: categoryAnalytics ?? this.categoryAnalytics,
      monthlyAnalytics: monthlyAnalytics ?? this.monthlyAnalytics,
      orderStats: orderStats ?? this.orderStats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final AnalyticsRepository _repo;

  AnalyticsNotifier(this._repo) : super(AnalyticsState());

  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _repo.getCategoryAnalytics(),
        _repo.getMonthlyAnalytics(),
        _repo.getOrderStats(),
      ]);
      state = state.copyWith(
        categoryAnalytics: results[0] as List<CategoryAnalytics>,
        monthlyAnalytics: results[1] as List<MonthlyAnalytics>,
        orderStats: results[2] as OrderStats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
