import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../providers/category_provider.dart';
import '../../../../data/models/category_model.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final Category? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  bool _isSaving = false;

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.category?.name ?? '');
    _descController =
        TextEditingController(text: widget.category?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
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
      };

      if (isEditing) {
        await ref
            .read(categoryProvider.notifier)
            .updateCategory(widget.category!.id, data);
      } else {
        await ref.read(categoryProvider.notifier).createCategory(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? '${l10n.editCategory} successful'
                : '${l10n.createCategory} successful'),
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
        title: Text(isEditing ? l10n.editCategory : l10n.createCategory),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.paddingM,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.categoryName),
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _descController,
                decoration:
                    InputDecoration(labelText: l10n.categoryDescription),
                maxLines: 3,
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
                      : Text(isEditing ? l10n.save : l10n.createCategory),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
