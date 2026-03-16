import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/supplier_model.dart';
import '../services/admin_supplier_service.dart';

final adminSupplierRepositoryProvider = Provider<AdminSupplierRepository>((ref) {
  return AdminSupplierRepository(ref.read(adminSupplierServiceProvider));
});

class AdminSupplierRepository {
  final AdminSupplierService _service;

  AdminSupplierRepository(this._service);

  Future<List<Supplier>> getSuppliers({String? search, bool? isActive}) async {
    return _service.getSuppliers(search: search, isActive: isActive);
  }

  Future<Supplier> getSupplierById(String id) async {
    return _service.getSupplierById(id);
  }

  Future<Supplier> createSupplier(Map<String, dynamic> data) async {
    return _service.createSupplier(data);
  }

  Future<Supplier> updateSupplier(String id, Map<String, dynamic> data) async {
    return _service.updateSupplier(id, data);
  }

  Future<void> deleteSupplier(String id) async {
    return _service.deleteSupplier(id);
  }
}
