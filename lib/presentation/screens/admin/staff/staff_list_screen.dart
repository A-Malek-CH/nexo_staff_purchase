import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../providers/staff_provider.dart';
import '../../../widgets/admin_bottom_nav.dart';
import '../../../../data/models/staff_member_model.dart';

class StaffListScreen extends ConsumerStatefulWidget {
  const StaffListScreen({super.key});

  @override
  ConsumerState<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends ConsumerState<StaffListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(staffProvider.notifier).loadStaff());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, StaffMember member) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: const TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(staffProvider.notifier).deleteStaff(member.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${member.fullname} deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffState = ref.watch(staffProvider);
    final l10n = AppLocalizations.of(context)!;
    final members = staffState.filteredStaff;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.staffManagement),
        actions: [
          IconButton(
            icon: Icon(
              staffState.showInactive ? Icons.visibility : Icons.visibility_off,
              color: staffState.showInactive ? AppTheme.primaryOrange : AppTheme.mediumGrey,
            ),
            tooltip: staffState.showInactive ? l10n.activeStaff : l10n.inactiveStaff,
            onPressed: () =>
                ref.read(staffProvider.notifier).toggleShowInactive(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: AppTheme.paddingM,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(staffProvider.notifier).searchStaff('');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => ref.read(staffProvider.notifier).searchStaff(v),
            ),
          ),
          Expanded(
            child: staffState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : staffState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(staffState.error!),
                            const SizedBox(height: AppTheme.spacingM),
                            ElevatedButton(
                              onPressed: () =>
                                  ref.read(staffProvider.notifier).loadStaff(),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      )
                    : members.isEmpty
                        ? Center(child: Text(l10n.staffList))
                        : RefreshIndicator(
                            onRefresh: () =>
                                ref.read(staffProvider.notifier).refreshStaff(),
                            child: ListView.builder(
                              itemCount: members.length,
                              itemBuilder: (context, index) {
                                final member = members[index];
                                return _StaffCard(
                                  member: member,
                                  onTap: () => context.push(
                                    '/admin/staff/${member.id}',
                                    extra: member,
                                  ),
                                  onDelete: () => _confirmDelete(context, member),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/staff/new'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final StaffMember member;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StaffCard({
    required this.member,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
          backgroundImage:
              member.avatar != null ? NetworkImage(member.avatar!) : null,
          child: member.avatar == null
              ? Text(
                  member.fullname.isNotEmpty
                      ? member.fullname[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(member.fullname, style: AppTheme.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.email, style: AppTheme.bodySmall),
            const SizedBox(height: 2),
            Row(
              children: [
                _RoleBadge(role: member.role),
                const SizedBox(width: AppTheme.spacingS),
                _StatusBadge(isActive: member.isActive),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: role == 'admin'
            ? AppTheme.primaryOrange.withOpacity(0.15)
            : Colors.blue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: role == 'admin' ? AppTheme.primaryOrange : Colors.blue,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.successGreen.withOpacity(0.15)
            : AppTheme.errorRed.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isActive ? AppTheme.successGreen : AppTheme.errorRed,
        ),
      ),
    );
  }
}
