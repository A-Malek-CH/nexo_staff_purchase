import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../providers/reports_provider.dart';
import '../../../widgets/admin_bottom_nav.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsProvider);
    final notifier = ref.read(reportsProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy');

    // Show error/success messages via snackbar
    ref.listen(reportsProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        String message;
        if (next.error == 'noDataSelected') {
          message = l10n.noDataSelected;
        } else if (next.error == 'noDateRange') {
          message = l10n.noDateRange;
        } else {
          message = l10n.reportFailed(next.error!);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        notifier.clearMessages();
      }
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reportGenerated),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        notifier.clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reports)),
      body: SingleChildScrollView(
        padding: AppTheme.paddingM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Data Types Section ────────────────────────────────────────
            _SectionCard(
              title: l10n.selectDataTypes,
              icon: Icons.table_chart_outlined,
              child: Column(
                children: [
                  _DataTypeCheckbox(
                    label: l10n.ordersReport,
                    icon: Icons.shopping_cart_outlined,
                    value: state.includeOrders,
                    onChanged: (v) => notifier.toggleDataType(
                        ReportDataType.orders, v ?? false),
                  ),
                  _DataTypeCheckbox(
                    label: l10n.tasksReport,
                    icon: Icons.task_outlined,
                    value: state.includeTasks,
                    onChanged: (v) => notifier.toggleDataType(
                        ReportDataType.tasks, v ?? false),
                  ),
                  _DataTypeCheckbox(
                    label: l10n.transfersReport,
                    icon: Icons.swap_horiz_outlined,
                    value: state.includeTransfers,
                    onChanged: (v) => notifier.toggleDataType(
                        ReportDataType.transfers, v ?? false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // ── Date Range Section ────────────────────────────────────────
            _SectionCard(
              title: l10n.selectPeriod,
              icon: Icons.date_range_outlined,
              child: Column(
                children: [
                  _DatePickerRow(
                    label: l10n.startDate,
                    date: state.startDate,
                    maxDate: state.endDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: state.endDate ?? DateTime.now(),
                      );
                      notifier.setStartDate(picked);
                    },
                    onClear: () => notifier.setStartDate(null),
                    dateFormat: dateFormat,
                  ),
                  const Divider(height: 1),
                  _DatePickerRow(
                    label: l10n.endDate,
                    date: state.endDate,
                    minDate: state.startDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.endDate ?? DateTime.now(),
                        firstDate: state.startDate ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      notifier.setEndDate(picked);
                    },
                    onClear: () => notifier.setEndDate(null),
                    dateFormat: dateFormat,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),

            // ── Generate Button ───────────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: state.isGenerating
                    ? null
                    : () => notifier.generateReport(
                          ordersSheetLabel: l10n.sheetOrders,
                          tasksSheetLabel: l10n.sheetTasks,
                          transfersSheetLabel: l10n.sheetTransfers,
                          orderHeaders: {
                            'orderNumber': l10n.colOrderNumber,
                            'supplier': l10n.colSupplier,
                            'staff': l10n.colStaff,
                            'status': l10n.colStatus,
                            'totalAmount': l10n.colTotalAmount,
                            'items': l10n.colItems,
                            'createdAt': l10n.colCreatedAt,
                            'expectedDate': l10n.colExpectedDate,
                            'paidDate': l10n.colPaidDate,
                          },
                          taskHeaders: {
                            'taskNumber': l10n.colTaskNumber,
                            'staff': l10n.colStaff,
                            'description': l10n.colDescription,
                            'status': l10n.colStatus,
                            'createdAt': l10n.colCreatedAt,
                            'deadline': l10n.colDeadline,
                          },
                          transferHeaders: {
                            'transferId': l10n.colTransferId,
                            'from': l10n.colFrom,
                            'to': l10n.colTo,
                            'items': l10n.colItems,
                            'quantity': l10n.colQuantity,
                            'assignedTo': l10n.colAssignedTo,
                            'status': l10n.colStatus,
                            'startTime': l10n.colStartTime,
                            'createdAt': l10n.colCreatedAt,
                          },
                          fileNamePrefix: l10n.reportFileName,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: AppTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: state.isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.white,
                        ),
                      )
                    : const Icon(Icons.download_outlined),
                label: Text(
                  state.isGenerating
                      ? l10n.generating
                      : l10n.downloadReport,
                  style: AppTheme.bodyLarge
                      .copyWith(color: AppTheme.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 6),
    );
  }
}

// ── Private Widgets ─────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
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
              children: [
                Icon(icon, color: AppTheme.primaryOrange, size: 20),
                const SizedBox(width: AppTheme.spacingS),
                Text(title, style: AppTheme.headingSmall),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            child,
          ],
        ),
      ),
    );
  }
}

class _DataTypeCheckbox extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _DataTypeCheckbox({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppTheme.primaryOrange,
      secondary: Icon(icon, color: AppTheme.mediumGrey),
      title: Text(label, style: AppTheme.bodyLarge),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateTime? minDate;
  final DateTime? maxDate;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final DateFormat dateFormat;

  const _DatePickerRow({
    required this.label,
    required this.date,
    this.minDate,
    this.maxDate,
    required this.onTap,
    required this.onClear,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.calendar_today_outlined,
        color: date != null ? AppTheme.primaryOrange : AppTheme.mediumGrey,
      ),
      title: Text(label, style: AppTheme.bodyMedium),
      subtitle: Text(
        date != null ? dateFormat.format(date!) : '—',
        style: AppTheme.bodyLarge.copyWith(
          color: date != null ? AppTheme.darkGrey : AppTheme.mediumGrey,
        ),
      ),
      trailing: date != null
          ? IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClear,
              color: AppTheme.mediumGrey,
            )
          : null,
      onTap: onTap,
    );
  }
}
