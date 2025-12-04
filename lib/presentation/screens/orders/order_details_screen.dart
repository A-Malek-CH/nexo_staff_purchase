import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_helper.dart';
import '../../../data/models/order_model.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final Order order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: _buildOrderDetails(context, order),
    );
  }

  Widget _buildOrderDetails(BuildContext context, Order order) {
    return SingleChildScrollView(
      padding: AppTheme.paddingM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Card(
            child: Padding(
              padding: AppTheme.paddingM,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Order #${order.orderNumber}',
                          style: AppTheme.headingMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(order.status),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildInfoRow('Total Amount', '\$${order.totalAmount.toStringAsFixed(2)}'),
                  if (order.expectedDate != null)
                    _buildInfoRow('Expected Date', DateHelper.formatDate(order.expectedDate!)),
                  _buildInfoRow('Created', DateHelper.formatDate(order.createdAt)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Supplier Info
          Card(
            child: Padding(
              padding: AppTheme.paddingM,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Supplier Information', style: AppTheme.headingSmall),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildInfoRow('Name', order.supplierId.name),
                  if (order.supplierId.contactPerson != null)
                    _buildInfoRow('Contact Person', order.supplierId.contactPerson!),
                  if (order.supplierId.phone1 != null)
                    _buildInfoRow('Phone', order.supplierId.phone1!),
                  if (order.supplierId.phone2 != null)
                    _buildInfoRow('Phone 2', order.supplierId.phone2!),
                  if (order.supplierId.phone3 != null)
                    _buildInfoRow('Phone 3', order.supplierId.phone3!),
                  if (order.supplierId.email != null)
                    _buildInfoRow('Email', order.supplierId.email!),
                  if (order.supplierId.address != null)
                    _buildInfoRow('Address', order.supplierId.address!),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Products List
          Card(
            child: Padding(
              padding: AppTheme.paddingM,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Products (${order.items.length})', style: AppTheme.headingSmall),
                  const SizedBox(height: AppTheme.spacingM),
                  ...order.items.map((item) => _buildProductItem(item)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Notes
          if (order.notes != null && order.notes!.isNotEmpty)
            Card(
              child: Padding(
                padding: AppTheme.paddingM,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes', style: AppTheme.headingSmall),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(order.notes!, style: AppTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          if (order.notes != null && order.notes!.isNotEmpty)
            const SizedBox(height: AppTheme.spacingM),

          // Status History
          if (order.statusHistory.isNotEmpty)
            Card(
              child: Padding(
                padding: AppTheme.paddingM,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status History', style: AppTheme.headingSmall),
                    const SizedBox(height: AppTheme.spacingM),
                    ...order.statusHistory.map((entry) => _buildStatusHistoryEntry(entry)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppTheme.spacingL),

          // Action Button
          if (order.status == AppConstants.orderStatusAssigned)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/orders/submit', extra: order),
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirm Order'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        _getStatusLabel(status),
        style: AppTheme.bodySmall.copyWith(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.mediumGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(ProductOrder item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.productId.name,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('Quantity: ${item.quantity}', style: AppTheme.bodySmall)),
              Flexible(
                child: Text(
                  '\$${item.unitCost.toStringAsFixed(2)} each',
                  style: AppTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('Remaining: ${item.remainingQte}', style: AppTheme.bodySmall)),
              Flexible(
                child: Text(
                  'Total: \$${(item.quantity * item.unitCost).toStringAsFixed(2)}',
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (item.expirationDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  item.isExpired ? Icons.warning : Icons.calendar_today,
                  size: 14,
                  color: item.isExpired ? AppTheme.errorRed : AppTheme.mediumGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  'Expires: ${DateHelper.formatDate(item.expirationDate!)}',
                  style: AppTheme.bodySmall.copyWith(
                    color: item.isExpired ? AppTheme.errorRed : null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusHistoryEntry(StatusHistoryEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(entry.to),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.from != null ? '${_getStatusLabel(entry.from!)} → ' : ''}${_getStatusLabel(entry.to)}',
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  DateHelper.formatDate(entry.at),
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.mediumGrey),
                ),
              ],
            ),
          ),
        ],
      ),
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

  String _getStatusLabel(String status) {
    switch (status) {
      case AppConstants.orderStatusNotAssigned:
        return 'Not Assigned';
      case AppConstants.orderStatusAssigned:
        return 'Assigned';
      case AppConstants.orderStatusConfirmed:
        return 'Confirmed';
      case AppConstants.orderStatusPaid:
        return 'Paid';
      case AppConstants.orderStatusCanceled:
        return 'Canceled';
      default:
        return status;
    }
  }
}
