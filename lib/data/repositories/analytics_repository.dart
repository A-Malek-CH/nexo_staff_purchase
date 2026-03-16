import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../models/order_stats_model.dart';
import '../services/analytics_service.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.read(analyticsServiceProvider));
});

class AnalyticsRepository {
  final AnalyticsService _service;

  AnalyticsRepository(this._service);

  Future<List<CategoryAnalytics>> getCategoryAnalytics() async {
    return _service.getCategoryAnalytics();
  }

  Future<List<MonthlyAnalytics>> getMonthlyAnalytics() async {
    return _service.getMonthlyAnalytics();
  }

  Future<OrderStats> getOrderStats() async {
    return _service.getOrderStats();
  }
}
