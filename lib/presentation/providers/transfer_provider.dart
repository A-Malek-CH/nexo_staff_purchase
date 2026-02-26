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

  TransfersState({
    this.transfers = const [],
    this.isLoading = false,
    this.error,
  });

  TransfersState copyWith({
    List<Transfer>? transfers,
    bool? isLoading,
    String? error,
  }) {
    return TransfersState(
      transfers: transfers ?? this.transfers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<Transfer> get pendingTransfers =>
      transfers.where((t) => t.status == 'pending').toList();

  List<Transfer> get inProgressTransfers =>
      transfers.where((t) => t.status == 'in_progress').toList();

  /// Pending transfers first, then the rest.
  List<Transfer> get sortedTransfers {
    final pending = transfers.where((t) => t.status == 'pending').toList();
    final others = transfers.where((t) => t.status != 'pending').toList();
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
