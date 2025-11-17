import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/supplier_model.dart';
import '../services/supplier_service.dart';

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepository(ref.read(supplierServiceProvider));
});

class SupplierRepository {
  final SupplierService _supplierService;

  SupplierRepository(this._supplierService);

  Future<List<Supplier>> getSuppliers({
    String? search,
    int page = 1,
  }) async {
    return await _supplierService.getSuppliers(
      search: search,
      page: page,
    );
  }

  Future<Supplier> getSupplierById(String id) async {
    return await _supplierService.getSupplierById(id);
  }
}
