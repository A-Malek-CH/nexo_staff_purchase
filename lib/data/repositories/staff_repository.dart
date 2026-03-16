import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/staff_member_model.dart';
import '../services/staff_service.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository(ref.read(staffServiceProvider));
});

class StaffRepository {
  final StaffService _service;

  StaffRepository(this._service);

  Future<List<StaffMember>> getStaff({bool? isActive, String? search}) async {
    return _service.getStaff(isActive: isActive, search: search);
  }

  Future<StaffMember> getStaffById(String id) async {
    return _service.getStaffById(id);
  }

  Future<StaffMember> createStaff(Map<String, dynamic> data) async {
    return _service.createStaff(data);
  }

  Future<StaffMember> updateStaff(String id, Map<String, dynamic> data) async {
    return _service.updateStaff(id, data);
  }

  Future<void> deleteStaff(String id) async {
    return _service.deleteStaff(id);
  }

  Future<StaffMember> uploadAvatar(String id, File imageFile) async {
    return _service.uploadAvatar(id, imageFile);
  }
}
