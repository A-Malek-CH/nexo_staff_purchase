import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../providers/admin_product_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../../data/models/product_model.dart' hide Category;
import '../../../../data/models/category_model.dart' show Category;

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _priceController;
  late final TextEditingController _minQtyController;
  late final TextEditingController _recQtyController;
  late final TextEditingController _unitController;
  late final TextEditingController _notesController;
  String? _selectedCategoryId;
  bool _isActive = true;
  File? _imageFile;
  bool _isSaving = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _priceController =
        TextEditingController(text: p?.price?.toString() ?? '');
    _minQtyController =
        TextEditingController(text: p?.minQty?.toString() ?? '');
    _recQtyController =
        TextEditingController(text: p?.recommendedQty?.toString() ?? '');
    _unitController = TextEditingController(text: p?.unit ?? '');
    _notesController = TextEditingController(text: p?.notes ?? '');
    _selectedCategoryId = p?.categoryId?.id;
    _isActive = p?.isActive ?? true;

    Future.microtask(
        () => ref.read(categoryProvider.notifier).loadCategories());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _minQtyController.dispose();
    _recQtyController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        setState(() => _imageFile = File(picked.path));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    try {
      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'barcode': _barcodeController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0,
        'minQty': int.tryParse(_minQtyController.text) ?? 0,
        'recommendedQty': int.tryParse(_recQtyController.text) ?? 0,
        'unit': _unitController.text.trim(),
        'notes': _notesController.text.trim(),
        'isActive': _isActive,
        if (_selectedCategoryId != null) 'categoryId': _selectedCategoryId,
      };

      if (isEditing) {
        await ref.read(adminProductProvider.notifier).updateProduct(
              widget.product!.id,
              data,
              imageFile: _imageFile,
            );
      } else {
        await ref.read(adminProductProvider.notifier).createProduct(
              data,
              imageFile: _imageFile,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? '${l10n.editProduct} successful'
                : '${l10n.createProduct} successful'),
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
    final categoryState = ref.watch(categoryProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editProduct : l10n.createProduct),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.paddingM,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: AppTheme.cardBorderRadius,
                        child: Image.file(_imageFile!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover),
                      )
                    : widget.product?.imageUrl != null
                        ? ClipRRect(
                            borderRadius: AppTheme.cardBorderRadius,
                            child: Image.network(widget.product!.imageUrl!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover),
                          )
                        : Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppTheme.lightGrey,
                              borderRadius: AppTheme.cardBorderRadius,
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo,
                                    color: AppTheme.mediumGrey, size: 40),
                                SizedBox(height: AppTheme.spacingS),
                                Text('Tap to add image',
                                    style: TextStyle(
                                        color: AppTheme.mediumGrey)),
                              ],
                            ),
                          ),
              ),
              const SizedBox(height: AppTheme.spacingM),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.productName),
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _descController,
                decoration:
                    InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(labelText: 'Barcode'),
              ),
              const SizedBox(height: AppTheme.spacingM),

              DropdownButtonFormField<String?>(
                value: _selectedCategoryId,
                decoration: InputDecoration(labelText: l10n.category),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('No Category')),
                  ...categoryState.categories.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      )),
                ],
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
              const SizedBox(height: AppTheme.spacingM),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: l10n.price),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(labelText: 'Unit'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minQtyController,
                      decoration: const InputDecoration(labelText: 'Min Qty'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: TextFormField(
                      controller: _recQtyController,
                      decoration:
                          const InputDecoration(labelText: 'Recommended Qty'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),

              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: l10n.notes),
                maxLines: 2,
              ),
              const SizedBox(height: AppTheme.spacingM),

              SwitchListTile(
                title: const Text('Active'),
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
                      : Text(isEditing ? l10n.save : l10n.createProduct),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
