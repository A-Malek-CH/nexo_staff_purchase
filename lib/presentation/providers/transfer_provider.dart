import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transfer_model.dart';
import '../../data/repositories/transfer_repository.dart';

final transferDetailProvider =
    FutureProvider.family<Transfer, String>((ref, transferId) async {
  return ref.read(transferRepositoryProvider).getTransferById(transferId);
});

final transfersProvider =
    StateNotifierProvider<TransfersNotifier, TransfersState>((ref) {
  return TransfersNotifier(ref.read(transferRepositoryProvider));
});

class TransfersState {
  final List<Transfer> transfers;
  final bool isLoading;
  final String? error;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  TransfersState({
    this.transfers = const [],
    this.isLoading = false,
    this.error,
    this.filterStartDate,
    this.filterEndDate,
  });

  TransfersState copyWith({
    List<Transfer>? transfers,
    bool? isLoading,
    String? error,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool clearDateFilter = false,
  }) {
    return TransfersState(
      transfers: transfers ?? this.transfers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterStartDate: clearDateFilter ? null : (filterStartDate ?? this.filterStartDate),
      filterEndDate: clearDateFilter ? null : (filterEndDate ?? this.filterEndDate),
    );
  }

  bool get hasDateFilter => filterStartDate != null || filterEndDate != null;

  List<Transfer> get dateFilteredTransfers {
    if (!hasDateFilter) return transfers;
    return transfers.where((t) {
      final date = t.startTime;
      if (filterStartDate != null) {
        final start = DateTime(filterStartDate!.year, filterStartDate!.month, filterStartDate!.day);
        if (date.isBefore(start)) return false;
      }
      if (filterEndDate != null) {
        final end = DateTime(filterEndDate!.year, filterEndDate!.month, filterEndDate!.day, 23, 59, 59);
        if (date.isAfter(end)) return false;
      }
      return true;
    }).toList();
  }

  List<Transfer> get pendingTransfers =>
      transfers.where((t) => t.status == 'pending').toList();

  List<Transfer> get inProgressTransfers =>
      transfers.where((t) => t.status == 'in_progress').toList();

  /// Pending transfers first, then the rest (respecting active date filter).
  List<Transfer> get sortedTransfers {
    final filtered = dateFilteredTransfers;
    final pending = filtered.where((t) => t.status == 'pending').toList();
    final others = filtered.where((t) => t.status != 'pending').toList();
    return [...pending, ...others];
  }
}

class TransfersNotifier extends StateNotifier<TransfersState> {
  final TransferRepository _transferRepository;

  TransfersNotifier(this._transferRepository) : super(TransfersState());

  Future<void> loadTransfers() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final transfers = await _transferRepository.getTransfers();
      state = state.copyWith(
        transfers: transfers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshTransfers() async {
    await loadTransfers();
  }

  void setDateFilter(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) {
      state = state.copyWith(clearDateFilter: true);
    } else {
      state = state.copyWith(
        filterStartDate: startDate,
        filterEndDate: endDate,
      );
    }
  }

  void clearDateFilter() {
    state = state.copyWith(clearDateFilter: true);
  }

  Future<void> updateTransferStatus(String transferId, String status) async {
    try {
      final updatedTransfer =
          await _transferRepository.updateTransferStatus(transferId, status);

      final updatedTransfers = state.transfers.map((transfer) {
        return transfer.id == transferId ? updatedTransfer : transfer;
      }).toList();

      state = state.copyWith(transfers: updatedTransfers);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}
