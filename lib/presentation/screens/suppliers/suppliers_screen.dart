import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/supplier_service.dart';
import '../../../data/models/supplier_model.dart';
import '../../widgets/app_bottom_nav.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supplierService = ref.read(supplierServiceProvider);
      final suppliers = await supplierService.getSuppliers();
      setState(() {
        _suppliers = suppliers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSuppliers,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
                        const SizedBox(height: AppTheme.spacingM),
                        Text(_error!, style: AppTheme.bodyMedium),
                        const SizedBox(height: AppTheme.spacingM),
                        ElevatedButton(
                          onPressed: _loadSuppliers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _suppliers.isEmpty
                    ? const Center(
                        child: Text('No suppliers found', style: AppTheme.bodyMedium),
                      )
                    : ListView.builder(
                        padding: AppTheme.paddingM,
                        itemCount: _suppliers.length,
                        itemBuilder: (context, index) {
                          final supplier = _suppliers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                            child: Padding(
                              padding: AppTheme.paddingM,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                                        backgroundImage: supplier.image != null
                                            ? NetworkImage(supplier.image!)
                                            : null,
                                        child: supplier.image == null
                                            ? const Icon(Icons.business, color: AppTheme.primaryOrange)
                                            : null,
                                      ),
                                      const SizedBox(width: AppTheme.spacingM),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              supplier.name,
                                              style: AppTheme.bodyLarge.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (supplier.contactPerson != null) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.person,
                                                    size: 14,
                                                    color: AppTheme.mediumGrey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    supplier.contactPerson!,
                                                    style: AppTheme.bodySmall.copyWith(
                                                      color: AppTheme.mediumGrey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppTheme.spacingM),
                                  if (_hasPhoneNumbers(supplier)) ...[
                                    const Divider(),
                                    const SizedBox(height: AppTheme.spacingS),
                                    ..._buildPhoneNumbers(supplier),
                                  ],
                                  if (supplier.address != null) ...[
                                    const SizedBox(height: 4),
                                    _buildInfoRow(Icons.location_on, supplier.address!),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  bool _hasPhoneNumbers(Supplier supplier) {
    return supplier.phone1 != null || 
           supplier.phone2 != null || 
           supplier.phone3 != null;
  }

  List<Widget> _buildPhoneNumbers(Supplier supplier) {
    final phones = [supplier.phone1, supplier.phone2, supplier.phone3]
        .where((phone) => phone != null)
        .toList();
    
    return List.generate(phones.length, (index) {
      return Padding(
        padding: EdgeInsets.only(top: index > 0 ? 4 : 0),
        child: _buildInfoRow(Icons.phone, phones[index]!),
      );
    });
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.mediumGrey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
