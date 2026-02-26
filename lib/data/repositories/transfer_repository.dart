import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transfer_model.dart';
import '../services/transfer_service.dart';

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepository(ref.read(transferServiceProvider));
});

class TransferRepository {
  final TransferService _transferService;

  TransferRepository(this._transferService);

  Future<List<Transfer>> getTransfers({
    String? status,
    int page = 1,
  }) async {
    return await _transferService.getTransfers(
      status: status,
      page: page,
    );
  }

  Future<Transfer> getTransferById(String id) async {
    return await _transferService.getTransferById(id);
  }

  Future<Transfer> updateTransferStatus(String id, String status) async {
    return await _transferService.updateTransferStatus(id, status);
  }
}
