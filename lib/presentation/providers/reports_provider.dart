import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/order_model.dart';
import '../../data/models/task_model.dart';
import '../../data/models/transfer_model.dart';
import '../../data/repositories/admin_order_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/transfer_repository.dart';

enum ReportDataType { orders, tasks, transfers }

class ReportsState {
  final bool includeOrders;
  final bool includeTasks;
  final bool includeTransfers;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isGenerating;
  final String? error;
  final String? successMessage;

  const ReportsState({
    this.includeOrders = true,
    this.includeTasks = false,
    this.includeTransfers = false,
    this.startDate,
    this.endDate,
    this.isGenerating = false,
    this.error,
    this.successMessage,
  });

  ReportsState copyWith({
    bool? includeOrders,
    bool? includeTasks,
    bool? includeTransfers,
    DateTime? startDate,
    DateTime? endDate,
    bool? isGenerating,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return ReportsState(
      includeOrders: includeOrders ?? this.includeOrders,
      includeTasks: includeTasks ?? this.includeTasks,
      includeTransfers: includeTransfers ?? this.includeTransfers,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      isGenerating: isGenerating ?? this.isGenerating,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier(
    ref.read(adminOrderRepositoryProvider),
    ref.read(taskRepositoryProvider),
    ref.read(transferRepositoryProvider),
  );
});

class ReportsNotifier extends StateNotifier<ReportsState> {
  final AdminOrderRepository _orderRepo;
  final TaskRepository _taskRepo;
  final TransferRepository _transferRepo;

  ReportsNotifier(this._orderRepo, this._taskRepo, this._transferRepo)
      : super(const ReportsState());

  void toggleDataType(ReportDataType type, bool value) {
    switch (type) {
      case ReportDataType.orders:
        state = state.copyWith(includeOrders: value);
      case ReportDataType.tasks:
        state = state.copyWith(includeTasks: value);
      case ReportDataType.transfers:
        state = state.copyWith(includeTransfers: value);
    }
  }

  void setStartDate(DateTime? date) {
    if (date == null) {
      state = state.copyWith(clearStartDate: true);
    } else {
      state = state.copyWith(startDate: date);
    }
  }

  void setEndDate(DateTime? date) {
    if (date == null) {
      state = state.copyWith(clearEndDate: true);
    } else {
      state = state.copyWith(endDate: date);
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  Future<void> generateReport({
    required String ordersSheetLabel,
    required String tasksSheetLabel,
    required String transfersSheetLabel,
    required Map<String, String> orderHeaders,
    required Map<String, String> taskHeaders,
    required Map<String, String> transferHeaders,
    required String fileNamePrefix,
  }) async {
    if (!state.includeOrders && !state.includeTasks && !state.includeTransfers) {
      state = state.copyWith(error: 'noDataSelected');
      return;
    }
    if (state.startDate == null || state.endDate == null) {
      state = state.copyWith(error: 'noDateRange');
      return;
    }

    state = state.copyWith(isGenerating: true, clearError: true, clearSuccess: true);

    try {
      final excel = Excel.createExcel();
      // Remove default sheet
      excel.delete('Sheet1');

      final dateFormat = DateFormat('yyyy-MM-dd');
      final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
      final start = state.startDate!;
      final end = DateTime(
        state.endDate!.year,
        state.endDate!.month,
        state.endDate!.day,
        23,
        59,
        59,
      );

      // ── Orders Sheet ───────────────────────────────────────────────────────
      if (state.includeOrders) {
        final orders = await _orderRepo.getAllOrders(limit: 1000);
        final filtered = orders.where((o) =>
            o.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
            o.createdAt.isBefore(end.add(const Duration(seconds: 1)))).toList();

        final sheet = excel[ordersSheetLabel];
        _addHeaderRow(sheet, [
          orderHeaders['orderNumber']!,
          orderHeaders['supplier']!,
          orderHeaders['staff']!,
          orderHeaders['status']!,
          orderHeaders['totalAmount']!,
          orderHeaders['items']!,
          orderHeaders['createdAt']!,
          orderHeaders['expectedDate']!,
          orderHeaders['paidDate']!,
        ]);

        for (final order in filtered) {
          final itemsSummary = order.items
              .map((i) => '${i.productId.name} x${i.quantity}')
              .join(', ');
          sheet.appendRow([
            TextCellValue(order.orderNumber),
            TextCellValue(order.supplierId.name),
            TextCellValue(order.staffId?.name ?? ''),
            TextCellValue(order.status),
            DoubleCellValue(order.totalAmount),
            TextCellValue(itemsSummary),
            TextCellValue(dateTimeFormat.format(order.createdAt.toLocal())),
            TextCellValue(order.expectedDate != null
                ? dateFormat.format(order.expectedDate!.toLocal())
                : ''),
            TextCellValue(order.paidDate != null
                ? dateFormat.format(order.paidDate!.toLocal())
                : ''),
          ]);
        }
      }

      // ── Tasks Sheet ────────────────────────────────────────────────────────
      if (state.includeTasks) {
        final tasks = await _taskRepo.getTasks();
        final filtered = tasks.where((t) =>
            t.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.createdAt.isBefore(end.add(const Duration(seconds: 1)))).toList();

        final sheet = excel[tasksSheetLabel];
        _addHeaderRow(sheet, [
          taskHeaders['taskNumber']!,
          taskHeaders['staff']!,
          taskHeaders['description']!,
          taskHeaders['status']!,
          taskHeaders['createdAt']!,
          taskHeaders['deadline']!,
        ]);

        for (final task in filtered) {
          sheet.appendRow([
            TextCellValue(task.taskNumber),
            TextCellValue(task.staffId?.fullname ?? ''),
            TextCellValue(task.description ?? ''),
            TextCellValue(task.status),
            TextCellValue(dateTimeFormat.format(task.createdAt.toLocal())),
            TextCellValue(task.deadline != null
                ? dateFormat.format(task.deadline!.toLocal())
                : ''),
          ]);
        }
      }

      // ── Transfers Sheet ────────────────────────────────────────────────────
      if (state.includeTransfers) {
        final transfers = await _transferRepo.getTransfers();
        final filtered = transfers.where((t) =>
            t.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.createdAt.isBefore(end.add(const Duration(seconds: 1)))).toList();

        final sheet = excel[transfersSheetLabel];
        _addHeaderRow(sheet, [
          transferHeaders['transferId']!,
          transferHeaders['from']!,
          transferHeaders['to']!,
          transferHeaders['items']!,
          transferHeaders['quantity']!,
          transferHeaders['assignedTo']!,
          transferHeaders['status']!,
          transferHeaders['startTime']!,
          transferHeaders['createdAt']!,
        ]);

        for (final transfer in filtered) {
          final itemsSummary = transfer.items
              .map((i) => '${i.productName ?? ''} x${i.quantity ?? 0}')
              .join(', ');
          sheet.appendRow([
            TextCellValue(transfer.id),
            TextCellValue(transfer.takenFrom.name),
            TextCellValue(transfer.takenTo.name),
            TextCellValue(itemsSummary),
            IntCellValue(transfer.quantity),
            TextCellValue(transfer.assignedTo.fullname),
            TextCellValue(transfer.status),
            TextCellValue(dateTimeFormat.format(transfer.startTime.toLocal())),
            TextCellValue(dateTimeFormat.format(transfer.createdAt.toLocal())),
          ]);
        }
      }

      // ── Save & Share ───────────────────────────────────────────────────────
      final bytes = excel.encode();
      if (bytes == null) throw Exception('Failed to encode Excel file');

      final dir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${dir.path}/${fileNamePrefix}_$timestamp.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
        ),
      );

      state = state.copyWith(
        isGenerating: false,
        successMessage: 'reportGenerated',
      );
    } catch (e) {
      state = state.copyWith(isGenerating: false, error: e.toString());
    }
  }

  void _addHeaderRow(Sheet sheet, List<String> headers) {
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#FF8C42'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );
    final row = headers.map((h) {
      final cell = TextCellValue(h);
      return cell;
    }).toList();
    sheet.appendRow(row);

    // Apply header style to the first row
    for (var col = 0; col < headers.length; col++) {
      final cellRef = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
      );
      cellRef.cellStyle = headerStyle;
    }
  }
}
