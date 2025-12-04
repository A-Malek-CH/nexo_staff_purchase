import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_helper.dart';
import '../../providers/order_provider.dart';
import '../../widgets/app_bottom_nav.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ordersProvider.notifier).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                if (value == 'clear') {
                  _selectedStatus = null;
                  ref.read(ordersProvider.notifier).clearFilters();
                } else if (value.startsWith('status:')) {
                  _selectedStatus = value.split(':')[1];
                  ref.read(ordersProvider.notifier).loadOrders(status: _selectedStatus);
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear Filters'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                enabled: false,
                child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              PopupMenuItem(
                value: 'status:${AppConstants.orderStatusAssigned}',
                child: const Text('Assigned'),
              ),
              PopupMenuItem(
                value: 'status:${AppConstants.orderStatusConfirmed}',
                child: const Text('Confirmed'),
              ),
              PopupMenuItem(
                value: 'status:${AppConstants.orderStatusPaid}',
                child: const Text('Paid'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(ordersProvider.notifier).refreshOrders(),
        child: ordersState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ordersState.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
                        const SizedBox(height: AppTheme.spacingM),
                        Text(ordersState.error!, style: AppTheme.bodyMedium),
                        const SizedBox(height: AppTheme.spacingM),
                        ElevatedButton(
                          onPressed: () => ref.read(ordersProvider.notifier).refreshOrders(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : ordersState.orders.isEmpty
                    ? const Center(
                        child: Text('No orders found', style: AppTheme.bodyMedium),
                      )
                    : ListView.builder(
                        padding: AppTheme.paddingM,
                        itemCount: ordersState.orders.length,
                        itemBuilder: (context, index) {
                          final order = ordersState.orders[index];
                          final isOverdue = order.expectedDate != null &&
                              DateHelper.isOverdue(order.expectedDate!) &&
                              order.status == AppConstants.orderStatusAssigned;

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(order.status).withOpacity(0.2),
                                child: Icon(
                                  _getStatusIcon(order.status),
                                  color: _getStatusColor(order.status),
                                ),
                              ),
                              title: Text(
                                order.orderNumber,
                                style: AppTheme.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    order.supplierId.name,
                                    style: AppTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  if (order.expectedDate != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: isOverdue ? AppTheme.errorRed : AppTheme.mediumGrey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateHelper.formatDeadline(order.expectedDate!),
                                          style: AppTheme.bodySmall.copyWith(
                                            color: isOverdue ? AppTheme.errorRed : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      _StatusChip(
                                        label: _getStatusLabel(order.status),
                                        color: _getStatusColor(order.status),
                                      ),
                                      _StatusChip(
                                        label: '\$${order.totalAmount.toStringAsFixed(2)}',
                                        color: AppTheme.successGreen,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push('/orders/details', extra: order),
                            ),
                          );
                        },
                      ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.orderStatusNotAssigned:
        return AppTheme.mediumGrey;
      case AppConstants.orderStatusAssigned:
        return Colors.blue;
      case AppConstants.orderStatusConfirmed:
        return AppTheme.successGreen;
      case AppConstants.orderStatusPaid:
        return Colors.green.shade900;
      case AppConstants.orderStatusCanceled:
        return AppTheme.errorRed;
      default:
        return AppTheme.mediumGrey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case AppConstants.orderStatusNotAssigned:
        return Icons.pending_outlined;
      case AppConstants.orderStatusAssigned:
        return Icons.assignment_turned_in;
      case AppConstants.orderStatusConfirmed:
        return Icons.verified;
      case AppConstants.orderStatusPaid:
        return Icons.payment;
      case AppConstants.orderStatusCanceled:
        return Icons.cancel;
      default:
        return Icons.shopping_cart;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case AppConstants.orderStatusNotAssigned:
        return 'NOT ASSIGNED';
      case AppConstants.orderStatusAssigned:
        return 'ASSIGNED';
      case AppConstants.orderStatusConfirmed:
        return 'CONFIRMED';
      case AppConstants.orderStatusPaid:
        return 'PAID';
      case AppConstants.orderStatusCanceled:
        return 'CANCELED';
      default:
        return status.toUpperCase();
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
