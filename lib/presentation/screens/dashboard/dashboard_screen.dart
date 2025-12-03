import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/app_bottom_nav.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ordersProvider.notifier).loadOrders();
      ref.read(notificationsProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final ordersState = ref.watch(ordersProvider);
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Notifications Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              if (notificationsState.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.errorRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      notificationsState.unreadCount > 9
                          ? '9+'
                          : notificationsState.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(ordersProvider.notifier).refreshOrders(),
            ref.read(notificationsProvider.notifier).refreshNotifications(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppTheme.paddingM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Text(
                'Welcome back, ${authState.user?.name ?? "User"}!',
                style: AppTheme.headingMedium,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                DateHelper.formatDate(DateTime.now()),
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Today\'s Orders',
                      count: ordersState.todayOrders.length,
                      icon: Icons.today,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _StatCard(
                      title: 'Assigned',
                      count: ordersState.assignedOrders.length,
                      icon: Icons.assignment_turned_in,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Overdue',
                      count: ordersState.overdueOrders.length,
                      icon: Icons.warning_outlined,
                      color: AppTheme.warningYellow,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _StatCard(
                      title: 'Total Orders',
                      count: ordersState.orders.length,
                      icon: Icons.shopping_cart_outlined,
                      color: AppTheme.successGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.shopping_cart,
                      label: 'View Orders',
                      onPressed: () => context.push('/orders'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.inventory_2,
                      label: 'Products',
                      onPressed: () => context.push('/products'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.business,
                      label: 'Suppliers',
                      onPressed: () => context.push('/suppliers'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.person,
                      label: 'Profile',
                      onPressed: () => context.push('/profile'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Today's Orders Preview
              if (ordersState.todayOrders.isNotEmpty) ...[
                Text(
                  'Today\'s Orders',
                  style: AppTheme.headingSmall,
                ),
                const SizedBox(height: AppTheme.spacingM),
                ...ordersState.todayOrders.take(3).map((order) => Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.shopping_cart,
                          color: _getStatusColor(order.status),
                        ),
                        title: Text(order.orderNumber),
                        subtitle: Text(
                          order.expectedDate != null
                              ? 'Due: ${DateHelper.formatDeadline(order.expectedDate!)}'
                              : order.supplierId.name,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/orders/${order.id}'),
                      ),
                    )),
                const SizedBox(height: AppTheme.spacingM),
                TextButton(
                  onPressed: () => context.push('/orders'),
                  child: const Text('View All Orders'),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'not assigned':
        return AppTheme.mediumGrey;
      case 'assigned':
        return Colors.blue;
      case 'pending_review':
        return AppTheme.warningYellow;
      case 'verified':
        return AppTheme.successGreen;
      case 'paid':
        return Colors.green.shade900;
      case 'canceled':
        return AppTheme.errorRed;
      default:
        return AppTheme.mediumGrey;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
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
                  count.toString(),
                  style: AppTheme.headingLarge.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              title,
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppTheme.cardBorderRadius,
        child: Padding(
          padding: AppTheme.paddingM,
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: AppTheme.primaryOrange,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                label,
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
