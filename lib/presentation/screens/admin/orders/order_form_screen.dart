import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../providers/admin_order_provider.dart';
import '../../../providers/admin_supplier_provider.dart';
import '../../../providers/admin_product_provider.dart';
import '../../../../data/models/supplier_model.dart';
import '../../../../data/models/product_model.dart';

class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key});

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  Supplier? _selectedSupplier;
  bool _isSaving = false;

  final List<_OrderItemEntry> _items = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminSupplierProvider.notifier).loadSuppliers();
      ref.read(adminProductProvider.notifier).loadProducts();
    });
    _items.add(_OrderItemEntry());
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a supplier')),
      );
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    try {
      final itemsList = _items
          .where((item) => item.selectedProduct != null)
          .map((item) => {
                'productId': item.selectedProduct!.id,
                'quantity': int.tryParse(item.quantityController.text) ?? 1,
                'unitCost': double.tryParse(item.unitCostController.text) ?? 0,
                if (item.expirationDate != null)
                  'expirationDate': item.expirationDate!.toIso8601String(),
              })
          .toList();

      await ref.read(adminOrderProvider.notifier).createOrder({
        'supplierId': _selectedSupplier!.id,
        'items': itemsList,
        'notes': _notesController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.createNewOrder} successful')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplierState = ref.watch(adminSupplierProvider);
    final productState = ref.watch(adminProductProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createNewOrder)),
      body: SingleChildScrollView(
        padding: AppTheme.paddingM,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Supplier dropdown
              DropdownButtonFormField<Supplier>(
                value: _selectedSupplier,
                decoration: InputDecoration(labelText: l10n.selectSupplier),
                items: supplierState.suppliers
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSupplier = v),
                validator: (v) =>
                    v == null ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: AppTheme.spacingL),

              Text(l10n.orderItems, style: AppTheme.headingSmall),
              const SizedBox(height: AppTheme.spacingS),

              ..._items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: Padding(
                    padding: AppTheme.paddingM,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Item ${i + 1}', style: AppTheme.bodyLarge),
                            if (_items.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: AppTheme.errorRed),
                                onPressed: () {
                                  setState(() {
                                    _items[i].dispose();
                                    _items.removeAt(i);
                                  });
                                },
                              ),
                          ],
                        ),
                        DropdownButtonFormField<Product>(
                          value: item.selectedProduct,
                          decoration:
                              InputDecoration(labelText: l10n.productName),
                          items: productState.products
                              .map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p.name,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => item.selectedProduct = v),
                          validator: (v) =>
                              v == null ? l10n.fieldRequired : null,
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: item.quantityController,
                                decoration:
                                    InputDecoration(labelText: l10n.quantity),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return l10n.fieldRequired;
                                  if (int.tryParse(v) == null)
                                    return l10n.invalidNumber;
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                            Expanded(
                              child: TextFormField(
                                controller: item.unitCostController,
                                decoration:
                                    InputDecoration(labelText: l10n.unitPrice),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return l10n.fieldRequired;
                                  if (double.tryParse(v) == null)
                                    return l10n.invalidNumber;
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now()
                                  .add(const Duration(days: 30)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 3650)),
                            );
                            if (picked != null) {
                              setState(() => item.expirationDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.expirationDate,
                              suffixIcon:
                                  const Icon(Icons.calendar_today, size: 20),
                            ),
                            child: Text(
                              item.expirationDate != null
                                  ? '${item.expirationDate!.day}/${item.expirationDate!.month}/${item.expirationDate!.year}'
                                  : l10n.optional,
                              style: item.expirationDate != null
                                  ? AppTheme.bodyMedium
                                  : AppTheme.bodyMedium
                                      .copyWith(color: AppTheme.mediumGrey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              TextButton.icon(
                icon: const Icon(Icons.add),
                label: Text(l10n.addItem),
                onPressed: () => setState(() => _items.add(_OrderItemEntry())),
              ),
              const SizedBox(height: AppTheme.spacingM),

              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: l10n.notesOptional),
                maxLines: 3,
              ),
              const SizedBox(height: AppTheme.spacingL),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.createOrder),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderItemEntry {
  Product? selectedProduct;
  final quantityController = TextEditingController(text: '1');
  final unitCostController = TextEditingController();
  DateTime? expirationDate;

  void dispose() {
    quantityController.dispose();
    unitCostController.dispose();
  }
}
