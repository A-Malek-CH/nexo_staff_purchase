import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/order_model.dart';
import '../../../providers/admin_order_provider.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderDetails)),
      body: SingleChildScrollView(
        padding: AppTheme.paddingM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header card
            Card(
              child: Padding(
                padding: AppTheme.paddingM,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(order.orderNumber, style: AppTheme.headingSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor(order.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.status.toUpperCase(),
                            style: TextStyle(
                              color: _statusColor(order.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _InfoRow(
                        label: l10n.supplier,
                        value: order.supplierId.name),
                    if (order.staffId != null)
                      _InfoRow(label: 'Staff', value: order.staffId!.fullname),
                    _InfoRow(
                      label: l10n.totalAmount,
                      value: '\$${order.totalAmount.toStringAsFixed(2)}',
                    ),
                    _InfoRow(
                      label: 'Created',
                      value: _formatDate(order.createdAt),
                    ),
                    if (order.notes != null && order.notes!.isNotEmpty)
                      _InfoRow(label: l10n.notes, value: order.notes!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Items
            Text(l10n.items, style: AppTheme.headingSmall),
            const SizedBox(height: AppTheme.spacingS),
            ...order.items.map((item) => Card(
                  child: ListTile(
                    title: Text(item.productId.name),
                    subtitle: Text(
                      'Qty: ${item.quantity} • \$${item.unitCost.toStringAsFixed(2)}/unit',
                    ),
                    trailing: item.expirationDate != null
                        ? Text(
                            'Exp: ${_formatDate(item.expirationDate!)}',
                            style: AppTheme.bodySmall,
                          )
                        : null,
                  ),
                )),

            if (order.statusHistory.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingM),
              Text('Status History', style: AppTheme.headingSmall),
              const SizedBox(height: AppTheme.spacingS),
              ...order.statusHistory.map(
                (entry) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.history, size: 16),
                  title: Text(
                    '${entry.from ?? 'Initial'} → ${entry.to}',
                    style: AppTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    _formatDate(entry.at),
                    style: AppTheme.bodySmall,
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppTheme.spacingL),

            // Action buttons
            if (order.status == 'confirmed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: Text('Confirm Payment'),
                  onPressed: () => context.push(
                    '/admin/orders/${order.id}/confirm',
                    extra: order,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: AppTheme.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value, style: AppTheme.bodyMedium)),
        ],
      ),
    );
  }
}
