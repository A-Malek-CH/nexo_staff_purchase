import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/transfer_provider.dart';

class TransferDetailsScreen extends ConsumerStatefulWidget {
  final String transferId;

  const TransferDetailsScreen({
    super.key,
    required this.transferId,
  });

  @override
  ConsumerState<TransferDetailsScreen> createState() =>
      _TransferDetailsScreenState();
}

class _TransferDetailsScreenState
    extends ConsumerState<TransferDetailsScreen> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final transferAsync =
        ref.watch(transferDetailProvider(widget.transferId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transferDetails),
      ),
      body: transferAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: AppTheme.errorRed),
              const SizedBox(height: AppTheme.spacingM),
              Text(error.toString(), style: AppTheme.bodyMedium),
              const SizedBox(height: AppTheme.spacingM),
              ElevatedButton(
                onPressed: () => ref
                    .invalidate(transferDetailProvider(widget.transferId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (transfer) => SingleChildScrollView(
          padding: AppTheme.paddingM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: AppTheme.paddingM,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.swap_horiz,
                                  color: AppTheme.primaryOrange),
                              const SizedBox(width: 8),
                              Text('Transfer',
                                  style: AppTheme.headingMedium),
                            ],
                          ),
                          _buildStatusBadge(transfer.status),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildInfoRow('From', transfer.takenFrom.name),
                      _buildInfoRow('To', transfer.takenTo.name),
                      if (transfer.takenFrom.location != null)
                        _buildInfoRow(
                            'From Location', transfer.takenFrom.location!),
                      if (transfer.takenTo.location != null)
                        _buildInfoRow(
                            'To Location', transfer.takenTo.location!),
                      _buildInfoRow('Quantity', transfer.quantity.toString()),
                      _buildInfoRow('Assigned To',
                          transfer.assignedTo.fullname),
                      _buildInfoRow('Start Time',
                          DateHelper.formatDeadline(transfer.startTime)),
                      _buildInfoRow('Created',
                          DateHelper.formatDate(transfer.createdAt)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),

              // Items Card
              if (transfer.items.isNotEmpty)
                Card(
                  child: Padding(
                    padding: AppTheme.paddingM,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Items', style: AppTheme.headingSmall),
                        const SizedBox(height: AppTheme.spacingS),
                        ...transfer.items.map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle,
                                      size: 8,
                                      color: AppTheme.primaryOrange),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.productName ?? 'Unknown Product',
                                      style: AppTheme.bodyMedium,
                                    ),
                                  ),
                                  if (item.quantity != null)
                                    Text(
                                      'x${item.quantity}',
                                      style: AppTheme.bodySmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              if (transfer.items.isNotEmpty)
                const SizedBox(height: AppTheme.spacingM),

              // Action Button
              if (transfer.status == 'pending')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isUpdating
                        ? null
                        : () => _updateStatus(
                            context, l10n, transfer.id, 'in_progress',
                            l10n.startTransfer,
                            'Mark this transfer as In Progress?'),
                    icon: _isUpdating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(
                        _isUpdating ? l10n.updating : l10n.startTransfer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              if (transfer.status == 'in_progress')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isUpdating
                        ? null
                        : () => _updateStatus(
                            context, l10n, transfer.id, 'arrived',
                            l10n.markAsArrived,
                            'Mark this transfer as Arrived?'),
                    icon: _isUpdating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(
                        _isUpdating ? l10n.updating : l10n.markAsArrived),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              const SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, AppLocalizations l10n,
      String transferId, String newStatus, String actionTitle,
      String confirmMessage) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(actionTitle),
        content: Text(confirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isUpdating = true);
    try {
      await ref
          .read(transfersProvider.notifier)
          .updateTransferStatus(transferId, newStatus);
      ref.invalidate(transferDetailProvider(widget.transferId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.transferUpdatedSuccess),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
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
        status.toUpperCase().replaceAll('_', ' '),
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
            width: 110,
            child: Text(
              '$label:',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.mediumGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'arrived':
        return AppTheme.successGreen;
      case 'in_progress':
        return Colors.blue;
      case 'canceled':
        return AppTheme.errorRed;
      case 'pending':
      default:
        return AppTheme.warningYellow;
    }
  }
}
