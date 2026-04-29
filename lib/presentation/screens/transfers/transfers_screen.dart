import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/transfer_provider.dart';
import '../../widgets/app_bottom_nav.dart';

class TransfersScreen extends ConsumerStatefulWidget {
  const TransfersScreen({super.key});

  @override
  ConsumerState<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends ConsumerState<TransfersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(transfersProvider.notifier).loadTransfers();
    });
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final transfersState = ref.read(transfersProvider);
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      initialDateRange: transfersState.filterStartDate != null &&
              transfersState.filterEndDate != null
          ? DateTimeRange(
              start: transfersState.filterStartDate!,
              end: transfersState.filterEndDate!,
            )
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryOrange,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref
          .read(transfersProvider.notifier)
          .setDateFilter(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transfersState = ref.watch(transfersProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transfers),
        actions: [
          if (transfersState.hasDateFilter)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: l10n.clearDateFilter,
              onPressed: () =>
                  ref.read(transfersProvider.notifier).clearDateFilter(),
            ),
          IconButton(
            icon: Icon(
              Icons.date_range,
              color: transfersState.hasDateFilter
                  ? AppTheme.primaryOrange
                  : null,
            ),
            tooltip: l10n.filterByDate,
            onPressed: () => _pickDateRange(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (transfersState.hasDateFilter)
            Container(
              width: double.infinity,
              color: AppTheme.primaryOrange.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
              child: Row(
                children: [
                  const Icon(Icons.date_range,
                      size: 16, color: AppTheme.primaryOrange),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      _buildDateRangeLabel(transfersState, l10n),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${transfersState.sortedTransfers.length} ${l10n.results}',
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.primaryOrange),
                  ),
                ],
              ),
            ),
          // List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(transfersProvider.notifier).refreshTransfers(),
              child: transfersState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : transfersState.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 64, color: AppTheme.errorRed),
                              const SizedBox(height: AppTheme.spacingM),
                              Text(transfersState.error!,
                                  style: AppTheme.bodyMedium),
                              const SizedBox(height: AppTheme.spacingM),
                              ElevatedButton(
                                onPressed: () => ref
                                    .read(transfersProvider.notifier)
                                    .refreshTransfers(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : transfersState.sortedTransfers.isEmpty
                          // sortedTransfers already incorporates the date filter via dateFilteredTransfers
                          ? Center(
                              child: Text(
                                transfersState.hasDateFilter
                                    ? l10n.noTransfersInPeriod
                                    : l10n.noTransfersFound,
                                style: AppTheme.bodyMedium,
                              ),
                            )
                          : ListView.builder(
                              padding: AppTheme.paddingM,
                              itemCount: transfersState.sortedTransfers.length,
                              itemBuilder: (context, index) {
                                final transfer =
                                    transfersState.sortedTransfers[index];
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          _getStatusColor(transfer.status)
                                              .withOpacity(0.2),
                                      child: Icon(
                                        Icons.swap_horiz,
                                        color:
                                            _getStatusColor(transfer.status),
                                      ),
                                    ),
                                    title: Text(
                                      '${transfer.takenFrom.name} → ${transfer.takenTo.name}',
                                      style: AppTheme.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time,
                                                size: 14,
                                                color: AppTheme.mediumGrey),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateHelper.formatDeadline(
                                                  transfer.startTime),
                                              style: AppTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            _StatusChip(
                                              label: transfer.status
                                                  .toUpperCase()
                                                  .replaceAll('_', ' '),
                                              color: _getStatusColor(
                                                  transfer.status),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Qty: ${transfer.quantity}',
                                              style: AppTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                        if (transfer.items.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              '${transfer.items.length} item(s)',
                                              style: AppTheme.bodySmall,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing:
                                        const Icon(Icons.chevron_right),
                                    onTap: () => context
                                        .push('/transfers/${transfer.id}'),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  String _buildDateRangeLabel(TransfersState state, AppLocalizations l10n) {
    final start = state.filterStartDate;
    final end = state.filterEndDate;
    if (start != null && end != null) {
      return '${DateHelper.formatDate(start)} – ${DateHelper.formatDate(end)}';
    } else if (start != null) {
      return '${l10n.from}: ${DateHelper.formatDate(start)}';
    } else if (end != null) {
      return '${l10n.to}: ${DateHelper.formatDate(end)}';
    }
    return '';
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
