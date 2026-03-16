import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/staff_member_model.dart';
import '../../data/repositories/staff_repository.dart';

final staffProvider = StateNotifierProvider<StaffNotifier, StaffState>((ref) {
  return StaffNotifier(ref.read(staffRepositoryProvider));
});

final staffDetailProvider = FutureProvider.family<StaffMember, String>((ref, id) async {
  return ref.read(staffRepositoryProvider).getStaffById(id);
});

class StaffState {
  final List<StaffMember> staffMembers;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final bool showInactive;

  StaffState({
    this.staffMembers = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.showInactive = false,
  });

  StaffState copyWith({
    List<StaffMember>? staffMembers,
    bool? isLoading,
    String? error,
    String? searchQuery,
    bool? showInactive,
  }) {
    return StaffState(
      staffMembers: staffMembers ?? this.staffMembers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      showInactive: showInactive ?? this.showInactive,
    );
  }

  List<StaffMember> get filteredStaff {
    var list = staffMembers;
    if (!showInactive) {
      list = list.where((s) => s.isActive).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where((s) =>
              s.fullname.toLowerCase().contains(q) ||
              s.email.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }
}

class StaffNotifier extends StateNotifier<StaffState> {
  final StaffRepository _repo;

  StaffNotifier(this._repo) : super(StaffState());

  Future<void> loadStaff() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final members = await _repo.getStaff();
      state = state.copyWith(staffMembers: members, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshStaff() async {
    await loadStaff();
  }

  Future<void> createStaff(Map<String, dynamic> data, {File? avatarFile}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newMember = await _repo.createStaff(data);
      if (avatarFile != null) {
        await _repo.uploadAvatar(newMember.id, avatarFile);
      }
      await loadStaff();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateStaff(String id, Map<String, dynamic> data, {File? avatarFile}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.updateStaff(id, data);
      if (avatarFile != null) {
        await _repo.uploadAvatar(id, avatarFile);
      }
      await loadStaff();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteStaff(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.deleteStaff(id);
      await loadStaff();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void searchStaff(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleShowInactive() {
    state = state.copyWith(showInactive: !state.showInactive);
  }
}
