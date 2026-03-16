import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../providers/staff_provider.dart';
import '../../../../data/models/staff_member_model.dart';

class StaffFormScreen extends ConsumerStatefulWidget {
  final StaffMember? staffMember;

  const StaffFormScreen({super.key, this.staffMember});

  @override
  ConsumerState<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends ConsumerState<StaffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullnameController;
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  String _role = 'staff';
  bool _isActive = true;
  File? _avatarFile;
  bool _isSaving = false;

  bool get isEditing => widget.staffMember != null;

  @override
  void initState() {
    super.initState();
    final m = widget.staffMember;
    _fullnameController = TextEditingController(text: m?.fullname ?? '');
    _emailController = TextEditingController(text: m?.email ?? '');
    _phoneController = TextEditingController(text: m?.phone ?? '');
    _addressController = TextEditingController(text: m?.address ?? '');
    _role = m?.role ?? 'staff';
    _isActive = m?.isActive ?? true;
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
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
        setState(() => _avatarFile = File(picked.path));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isSaving = true);
    try {
      final data = <String, dynamic>{
        'fullname': _fullnameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone1': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'role': _role,
        'isActive': _isActive,
      };
      if (!isEditing && _passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      if (isEditing) {
        await ref
            .read(staffProvider.notifier)
            .updateStaff(widget.staffMember!.id, data, avatarFile: _avatarFile);
      } else {
        await ref
            .read(staffProvider.notifier)
            .createStaff(data, avatarFile: _avatarFile);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? '${l10n.editStaff} successful'
                : '${l10n.createStaff} successful'),
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
        title: Text(isEditing ? l10n.editStaff : l10n.createStaff),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.paddingM,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar picker
              GestureDetector(
                onTap: _pickAvatar,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                  backgroundImage:
                      _avatarFile != null ? FileImage(_avatarFile!) : null,
                  child: _avatarFile == null
                      ? const Icon(Icons.camera_alt,
                          size: 32, color: AppTheme.primaryOrange)
                      : null,
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),

              TextFormField(
                controller: _fullnameController,
                decoration: InputDecoration(labelText: l10n.staffName),
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: AppTheme.spacingM),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: l10n.staffEmail),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.emailRequired;
                  if (!v.contains('@')) return l10n.emailInvalid;
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingM),

              if (!isEditing) ...[
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: l10n.password),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.passwordRequired;
                    if (v.length < 6) return l10n.passwordMinLength;
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
              ],

              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: l10n.staffPhone),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppTheme.spacingM),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: l10n.staffAddress),
                maxLines: 2,
              ),
              const SizedBox(height: AppTheme.spacingM),

              DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(labelText: l10n.staffRole),
                items: const [
                  DropdownMenuItem(value: 'staff', child: Text('Staff')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'staff'),
              ),
              const SizedBox(height: AppTheme.spacingM),

              SwitchListTile(
                title: Text(l10n.staffActive),
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
                      : Text(isEditing ? l10n.save : l10n.createStaff),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
