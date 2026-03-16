import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../providers/analytics_provider.dart';
import '../../../widgets/admin_bottom_nav.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(analyticsProvider.notifier).loadAnalytics());
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.analytics)),
      body: analyticsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : analyticsState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(analyticsState.error!),
                      const SizedBox(height: AppTheme.spacingM),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(analyticsProvider.notifier).loadAnalytics(),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(analyticsProvider.notifier).loadAnalytics(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppTheme.paddingM,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order stats
                        if (analyticsState.orderStats != null) ...[
                          Text(l10n.totalOrders, style: AppTheme.headingSmall),
                          const SizedBox(height: AppTheme.spacingM),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: l10n.totalOrders,
                                  value: analyticsState.orderStats!.total
                                      .toString(),
                                  color: AppTheme.primaryOrange,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingM),
                              Expanded(
                                child: _StatCard(
                                  label: l10n.pendingOrders,
                                  value: analyticsState.orderStats!.pending
                                      .toString(),
                                  color: AppTheme.warningYellow,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: l10n.statusConfirmed,
                                  value: analyticsState.orderStats!.confirmed
                                      .toString(),
                                  color: AppTheme.successGreen,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingM),
                              Expanded(
                                child: _StatCard(
                                  label: l10n.statusPaid,
                                  value: analyticsState.orderStats!.paid
                                      .toString(),
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingL),
                        ],

                        // Category analytics
                        if (analyticsState.categoryAnalytics.isNotEmpty) ...[
                          Text(l10n.categoryAnalytics,
                              style: AppTheme.headingSmall),
                          const SizedBox(height: AppTheme.spacingM),
                          ...analyticsState.categoryAnalytics.map(
                            (cat) => Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppTheme.lightBeige,
                                  child: Icon(Icons.category,
                                      color: AppTheme.primaryOrange),
                                ),
                                title: Text(cat.categoryName),
                                subtitle: Text('Orders: ${cat.totalOrders}'),
                                trailing: Text(
                                  '\$${cat.totalAmount.toStringAsFixed(2)}',
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryOrange,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingL),
                        ],

                        // Monthly analytics
                        if (analyticsState.monthlyAnalytics.isNotEmpty) ...[
                          Text(l10n.monthlyAnalytics,
                              style: AppTheme.headingSmall),
                          const SizedBox(height: AppTheme.spacingM),
                          ...analyticsState.monthlyAnalytics.map(
                            (monthly) => Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppTheme.primaryOrange.withOpacity(0.1),
                                  child: Text(
                                    monthly.month.isNotEmpty
                                        ? monthly.month.substring(0, 3)
                                        : '?',
                                    style: const TextStyle(
                                      color: AppTheme.primaryOrange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                    '${monthly.month} ${monthly.year}'),
                                subtitle: Text(
                                    'Orders: ${monthly.totalOrders} • Paid: ${monthly.paidCount}'),
                                trailing: Text(
                                  '\$${monthly.totalAmount.toStringAsFixed(2)}',
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryOrange,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],

                        if (analyticsState.orderStats == null &&
                            analyticsState.categoryAnalytics.isEmpty &&
                            analyticsState.monthlyAnalytics.isEmpty)
                          Center(
                              child: Text(
                               l10n.noAnalyticsData,
                               style: AppTheme.bodyMedium,
                             ),
                          ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 5),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppTheme.paddingM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTheme.headingLarge.copyWith(color: color),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(label, style: AppTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
