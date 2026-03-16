import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../providers/admin_order_provider.dart';
import '../../../widgets/admin_bottom_nav.dart';
import '../../../../data/models/order_model.dart';
import '../../../../core/constants/app_constants.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminOrderProvider.notifier).loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(adminOrderProvider);
    final l10n = AppLocalizations.of(context)!;

    final statusFilters = [
      null,
      AppConstants.orderStatusNotAssigned,
      AppConstants.orderStatusConfirmed,
      AppConstants.orderStatusPaid,
    ];
    final statusLabels = [
      'All',
      l10n.statusNotAssigned,
      l10n.statusConfirmed,
      l10n.statusPaid,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderManagement)),
      body: Column(
        children: [
          // Status filter chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
              itemCount: statusFilters.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppTheme.spacingS),
              itemBuilder: (ctx, i) {
                final isSelected = orderState.selectedStatus == statusFilters[i];
                return FilterChip(
                  label: Text(statusLabels[i]),
                  selected: isSelected,
                  onSelected: (_) => ref
                      .read(adminOrderProvider.notifier)
                      .filterByStatus(statusFilters[i]),
                  selectedColor: AppTheme.primaryOrange.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryOrange,
                );
              },
            ),
          ),

          Expanded(
            child: orderState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : orderState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(orderState.error!),
                            const SizedBox(height: AppTheme.spacingM),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(adminOrderProvider.notifier)
                                  .loadOrders(),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      )
                    : orderState.orders.isEmpty
                        ? Center(child: Text(l10n.noOrdersYet))
                        : RefreshIndicator(
                            onRefresh: () => ref
                                .read(adminOrderProvider.notifier)
                                .loadOrders(
                                    status: orderState.selectedStatus),
                            child: ListView.builder(
                              itemCount: orderState.orders.length,
                              itemBuilder: (ctx, i) {
                                final order = orderState.orders[i];
                                return _OrderCard(
                                  order: order,
                                  onTap: () => context.push(
                                    '/admin/orders/${order.id}',
                                    extra: order,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/orders/new'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  Color _statusColor(String status) {
    switch (status) {
      case 'not assigned':
        return AppTheme.mediumGrey;
      case 'assigned':
        return Colors.blue;
      case 'confirmed':
        return AppTheme.successGreen;
      case 'paid':
        return Colors.green.shade900;
      case 'canceled':
        return AppTheme.errorRed;
      default:
        return AppTheme.mediumGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(order.status).withOpacity(0.15),
          child: Icon(Icons.shopping_cart,
              color: _statusColor(order.status), size: 20),
        ),
        title: Text(order.orderNumber, style: AppTheme.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.supplierId.name, style: AppTheme.bodySmall),
            Text(
              '\$${order.totalAmount.toStringAsFixed(2)}',
              style: AppTheme.bodySmall,
            ),
          ],
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(order.status).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            order.status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _statusColor(order.status),
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
