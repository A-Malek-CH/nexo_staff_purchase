import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/task_provider.dart';
import '../../providers/transfer_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/transfer_model.dart';
import '../../../data/models/order_model.dart';

class QuickAccessScreen extends ConsumerStatefulWidget {
  const QuickAccessScreen({super.key});

  @override
  ConsumerState<QuickAccessScreen> createState() => _QuickAccessScreenState();
}

class _QuickAccessScreenState extends ConsumerState<QuickAccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tasksProvider.notifier).loadTasks();
      ref.read(transfersProvider.notifier).loadTransfers();
      ref.read(ordersProvider.notifier).loadOrders();
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(tasksProvider.notifier).refreshTasks(),
      ref.read(transfersProvider.notifier).refreshTransfers(),
      ref.read(ordersProvider.notifier).refreshOrders(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);
    final transfersState = ref.watch(transfersProvider);
    final ordersState = ref.watch(ordersProvider);
    final l10n = AppLocalizations.of(context)!;

    final pendingTasks = tasksState.tasks
        .where((t) =>
            t.status == AppConstants.taskStatusPending ||
            t.status == AppConstants.taskStatusInProgress)
        .toList();

    final pendingTransfers = transfersState.pendingTransfers;

    final pendingOrders = ordersState.orders
        .where((o) => o.status == AppConstants.orderStatusAssigned)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickAccess),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppTheme.paddingM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tasks Section
              _SectionCard(
                title: l10n.tasks,
                pendingCount: pendingTasks.length,
                icon: Icons.assignment,
                color: AppTheme.primaryOrange,
                isLoading: tasksState.isLoading,
                viewAllLabel: l10n.viewAll,
                onViewAll: () => context.push('/tasks'),
                emptyMessage: l10n.noPendingTasks,
                child: pendingTasks.isEmpty
                    ? null
                    : Column(
                        children: pendingTasks
                            .take(3)
                            .map((task) => _TaskTile(task: task))
                            .toList(),
                      ),
              ),
              const SizedBox(height: AppTheme.spacingM),

              // Transfers Section
              _SectionCard(
                title: l10n.transfers,
                pendingCount: pendingTransfers.length,
                icon: Icons.swap_horiz,
                color: AppTheme.warningYellow,
                isLoading: transfersState.isLoading,
                viewAllLabel: l10n.viewAll,
                onViewAll: () => context.push('/transfers'),
                emptyMessage: l10n.noPendingTransfers,
                child: pendingTransfers.isEmpty
                    ? null
                    : Column(
                        children: pendingTransfers
                            .take(3)
                            .map((transfer) => _TransferTile(transfer: transfer))
                            .toList(),
                      ),
              ),
              const SizedBox(height: AppTheme.spacingM),

              // Orders Section
              _SectionCard(
                title: l10n.orders,
                pendingCount: pendingOrders.length,
                icon: Icons.shopping_cart,
                color: Colors.blue,
                isLoading: ordersState.isLoading,
                viewAllLabel: l10n.viewAll,
                onViewAll: () => context.push('/orders'),
                emptyMessage: l10n.noPendingOrders,
                child: pendingOrders.isEmpty
                    ? null
                    : Column(
                        children: pendingOrders
                            .take(3)
                            .map((order) => _OrderTile(order: order))
                            .toList(),
                      ),
              ),
              const SizedBox(height: AppTheme.spacingM),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

// ── Section card wrapper ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final int pendingCount;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final String viewAllLabel;
  final VoidCallback onViewAll;
  final String emptyMessage;
  final Widget? child;

  const _SectionCard({
    required this.title,
    required this.pendingCount,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.viewAllLabel,
    required this.onViewAll,
    required this.emptyMessage,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  title,
                  style: AppTheme.headingSmall.copyWith(
                    fontSize: 16,
                    color: color,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                if (pendingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pendingCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    foregroundColor: color,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(viewAllLabel),
                ),
              ],
            ),
          ),
          // Body
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(AppTheme.spacingM),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (child == null)
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Center(
                child: Text(emptyMessage, style: AppTheme.bodySmall),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
              child: child!,
            ),
        ],
      ),
    );
  }
}

// ── Task tile ─────────────────────────────────────────────────────────────────

class _TaskTile extends ConsumerWidget {
  final Task task;

  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue = task.deadline != null &&
        DateHelper.isOverdue(task.deadline!) &&
        task.status != AppConstants.taskStatusCompleted;
    final color = _statusColor(task.status);

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(_statusIcon(task.status), size: 16, color: color),
      ),
      title: Text(task.taskNumber, style: AppTheme.bodyLarge.copyWith(fontSize: 14)),
      subtitle: task.deadline != null
          ? Text(
              DateHelper.formatDeadline(task.deadline!),
              style: AppTheme.bodySmall
                  .copyWith(color: isOverdue ? AppTheme.errorRed : null),
            )
          : null,
      trailing: _StatusChip(
        label: task.status.toUpperCase().replaceAll('_', ' '),
        color: color,
      ),
      onTap: () => context.push('/tasks/${task.id}'),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case AppConstants.taskStatusCompleted:
        return AppTheme.successGreen;
      case AppConstants.taskStatusInProgress:
        return AppTheme.primaryOrange;
      case AppConstants.taskStatusCancelled:
        return AppTheme.errorRed;
      default:
        return AppTheme.mediumGrey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case AppConstants.taskStatusCompleted:
        return Icons.check_circle;
      case AppConstants.taskStatusInProgress:
        return Icons.pending;
      case AppConstants.taskStatusCancelled:
        return Icons.cancel;
      default:
        return Icons.assignment;
    }
  }
}

// ── Transfer tile ─────────────────────────────────────────────────────────────

class _TransferTile extends ConsumerWidget {
  final Transfer transfer;

  const _TransferTile({required this.transfer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _statusColor(transfer.status);

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(Icons.swap_horiz, size: 16, color: color),
      ),
      title: Text(
        '${transfer.takenFrom.name} → ${transfer.takenTo.name}',
        style: AppTheme.bodyLarge.copyWith(fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateHelper.formatDeadline(transfer.startTime),
        style: AppTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusChip(
            label: transfer.status.toUpperCase().replaceAll('_', ' '),
            color: color,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 16),
        ],
      ),
      onTap: () => context.push('/transfers/${transfer.id}'),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'arrived':
        return AppTheme.successGreen;
      case 'in_progress':
        return Colors.blue;
      case 'canceled':
        return AppTheme.errorRed;
      default:
        return AppTheme.warningYellow;
    }
  }
}

// ── Order tile ────────────────────────────────────────────────────────────────

class _OrderTile extends ConsumerWidget {
  final Order order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue = order.expectedDate != null &&
        DateHelper.isOverdue(order.expectedDate!) &&
        order.status == AppConstants.orderStatusAssigned;
    final color = _statusColor(order.status);

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(Icons.shopping_cart, size: 16, color: color),
      ),
      title: Text(order.orderNumber,
          style: AppTheme.bodyLarge.copyWith(fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(order.supplierId.name, style: AppTheme.bodySmall),
          if (order.expectedDate != null)
            Text(
              DateHelper.formatDeadline(order.expectedDate!),
              style: AppTheme.bodySmall
                  .copyWith(color: isOverdue ? AppTheme.errorRed : null),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusChip(
            label: order.status.toUpperCase(),
            color: color,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 16),
        ],
      ),
      onTap: () => context.push('/orders/details', extra: order),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
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
}

// ── Shared status chip ────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 9,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
