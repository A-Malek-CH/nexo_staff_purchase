import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../providers/admin_supplier_provider.dart';
import '../../../../data/models/supplier_model.dart';

class SupplierFormScreen extends ConsumerStatefulWidget {
  final Supplier? supplier;

  const SupplierFormScreen({super.key, this.supplier});

  @override
  ConsumerState<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _contactController;
  late final TextEditingController _emailController;
  late final TextEditingController _phone1Controller;
  late final TextEditingController _phone2Controller;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _notesController;
  bool _isActive = true;
  bool _isSaving = false;

  bool get isEditing => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _nameController = TextEditingController(text: s?.name ?? '');
    _descController = TextEditingController(text: s?.description ?? '');
    _contactController = TextEditingController(text: s?.contactPerson ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _phone1Controller = TextEditingController(text: s?.phone1 ?? '');
    _phone2Controller = TextEditingController(text: s?.phone2 ?? '');
    _addressController = TextEditingController(text: s?.address ?? '');
    _cityController = TextEditingController(text: s?.city ?? '');
    _countryController = TextEditingController(text: s?.country ?? '');
    _notesController = TextEditingController(text: s?.notes ?? '');
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    try {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'contactPerson': _contactController.text.trim(),
        'email': _emailController.text.trim(),
        'phone1': _phone1Controller.text.trim(),
        'phone2': _phone2Controller.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
        'notes': _notesController.text.trim(),
        'isActive': _isActive,
      };

      if (isEditing) {
        await ref
            .read(adminSupplierProvider.notifier)
            .updateSupplier(widget.supplier!.id, data);
      } else {
        await ref.read(adminSupplierProvider.notifier).createSupplier(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? l10n.editSupplier + ' successful'
                : l10n.createSupplier + ' successful'),
          ),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editSupplier : l10n.createSupplier),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.paddingM,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.supplierName),
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _descController,
                decoration:
                    InputDecoration(labelText: l10n.supplierDescription),
                maxLines: 2,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _contactController,
                decoration:
                    InputDecoration(labelText: l10n.contactPerson),
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: l10n.email),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _phone1Controller,
                decoration: InputDecoration(labelText: '${l10n.phone} 1'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _phone2Controller,
                decoration: InputDecoration(labelText: '${l10n.phone} 2'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: l10n.staffAddress),
                maxLines: 2,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: l10n.supplierCity),
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(labelText: l10n.supplierCountry),
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: l10n.notes),
                maxLines: 3,
              ),
              const SizedBox(height: AppTheme.spacingM),
              SwitchListTile(
                title: Text(l10n.isActive),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                activeColor: AppTheme.primaryOrange,
              ),
              const SizedBox(height: AppTheme.spacingL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(isEditing ? l10n.save : l10n.createSupplier),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
