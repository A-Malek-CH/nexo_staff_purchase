import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_order_provider.dart';
import '../../providers/staff_provider.dart';
import '../../providers/admin_product_provider.dart';
import '../../widgets/admin_bottom_nav.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminOrderProvider.notifier).loadOrders();
      ref.read(adminOrderProvider.notifier).loadStats();
      ref.read(staffProvider.notifier).loadStaff();
      ref.read(adminProductProvider.notifier).loadProducts();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(adminOrderProvider.notifier).loadOrders(),
      ref.read(adminOrderProvider.notifier).loadStats(),
      ref.read(staffProvider.notifier).loadStaff(),
      ref.read(adminProductProvider.notifier).loadProducts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final orderState = ref.watch(adminOrderProvider);
    final staffState = ref.watch(staffProvider);
    final productState = ref.watch(adminProductProvider);
    final l10n = AppLocalizations.of(context)!;

    final adminName = authState.user?.name ?? 'Admin';
    final totalOrders = orderState.stats?.total ?? orderState.orders.length;
    final pendingOrders = orderState.stats?.pending ?? 0;
    final totalStaff = staffState.staffMembers.where((s) => s.isActive).length;
    final lowStock = productState.lowStockProducts.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppTheme.paddingM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcomeBack(adminName),
                style: AppTheme.headingMedium,
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: l10n.totalOrders,
                      value: totalOrders.toString(),
                      icon: Icons.shopping_cart,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _StatCard(
                      title: l10n.pendingOrders,
                      value: pendingOrders.toString(),
                      icon: Icons.pending_actions,
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
                      title: l10n.totalStaff,
                      value: totalStaff.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _StatCard(
                      title: l10n.lowStock,
                      value: lowStock.toString(),
                      icon: Icons.inventory_2,
                      color: AppTheme.errorRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),

              Text(l10n.quickActions, style: AppTheme.headingSmall),
              const SizedBox(height: AppTheme.spacingM),

              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppTheme.spacingM,
                mainAxisSpacing: AppTheme.spacingM,
                children: [
                  _ActionButton(
                    icon: Icons.shopping_cart,
                    label: l10n.orderManagement,
                    onTap: () => context.go('/admin/orders'),
                  ),
                  _ActionButton(
                    icon: Icons.people,
                    label: l10n.staffManagement,
                    onTap: () => context.go('/admin/staff'),
                  ),
                  _ActionButton(
                    icon: Icons.business,
                    label: l10n.supplierManagement,
                    onTap: () => context.go('/admin/suppliers'),
                  ),
                  _ActionButton(
                    icon: Icons.inventory_2,
                    label: l10n.productManagement,
                    onTap: () => context.go('/admin/products'),
                  ),
                  _ActionButton(
                    icon: Icons.category,
                    label: l10n.categoryManagement,
                    onTap: () => context.go('/admin/categories'),
                  ),
                  _ActionButton(
                    icon: Icons.bar_chart,
                    label: l10n.analytics,
                    onTap: () => context.go('/admin/analytics'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: AppTheme.headingLarge.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(title, style: AppTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.cardBorderRadius,
        child: Padding(
          padding: AppTheme.paddingS,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.primaryOrange, size: 32),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                label,
                style: AppTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
