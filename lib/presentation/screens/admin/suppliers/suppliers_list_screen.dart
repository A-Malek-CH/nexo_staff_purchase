import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../providers/admin_supplier_provider.dart';
import '../../../widgets/admin_bottom_nav.dart';
import '../../../../data/models/supplier_model.dart';

class SuppliersListScreen extends ConsumerStatefulWidget {
  const SuppliersListScreen({super.key});

  @override
  ConsumerState<SuppliersListScreen> createState() => _SuppliersListScreenState();
}

class _SuppliersListScreenState extends ConsumerState<SuppliersListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(adminSupplierProvider.notifier).loadSuppliers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, Supplier supplier) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text(l10n.delete, style: const TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(adminSupplierProvider.notifier)
            .deleteSupplier(supplier.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${supplier.name} deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppTheme.errorRed),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplierState = ref.watch(adminSupplierProvider);
    final l10n = AppLocalizations.of(context)!;
    final suppliers = supplierState.filteredSuppliers;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.supplierManagement)),
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
                          ref
                              .read(adminSupplierProvider.notifier)
                              .searchSupplier('');
                        },
                      )
                    : null,
              ),
              onChanged: (v) =>
                  ref.read(adminSupplierProvider.notifier).searchSupplier(v),
            ),
          ),
          Expanded(
            child: supplierState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : supplierState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(supplierState.error!),
                            const SizedBox(height: AppTheme.spacingM),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(adminSupplierProvider.notifier)
                                  .loadSuppliers(),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      )
                    : suppliers.isEmpty
                        ? Center(child: Text(l10n.noSuppliersFound))
                        : RefreshIndicator(
                            onRefresh: () => ref
                                .read(adminSupplierProvider.notifier)
                                .loadSuppliers(),
                            child: ListView.builder(
                              itemCount: suppliers.length,
                              itemBuilder: (context, index) {
                                final supplier = suppliers[index];
                                return _SupplierCard(
                                  supplier: supplier,
                                  onTap: () => context.push(
                                    '/admin/suppliers/${supplier.id}',
                                    extra: supplier,
                                  ),
                                  onDelete: () =>
                                      _confirmDelete(context, supplier),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/suppliers/new'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 3),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SupplierCard({
    required this.supplier,
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
              supplier.image != null ? NetworkImage(supplier.image!) : null,
          child: supplier.image == null
              ? const Icon(Icons.business, color: AppTheme.primaryOrange)
              : null,
        ),
        title: Text(supplier.name, style: AppTheme.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supplier.contactPerson != null)
              Text(supplier.contactPerson!, style: AppTheme.bodySmall),
            if (supplier.phone1 != null)
              Text(supplier.phone1!, style: AppTheme.bodySmall),
            _StatusBadge(isActive: supplier.isActive),
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

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
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
