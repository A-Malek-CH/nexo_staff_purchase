import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../providers/admin_order_provider.dart';
import '../../../../data/models/order_model.dart';

class OrderConfirmationScreen extends ConsumerStatefulWidget {
  final Order order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  ConsumerState<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState
    extends ConsumerState<OrderConfirmationScreen> {
  final _notesController = TextEditingController();
  File? _billFile;
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() => _billFile = File(picked.path));
    }
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    try {
      await ref.read(adminOrderProvider.notifier).confirmPayment(
            widget.order.id,
            billFile: _billFile,
            notes: _notesController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment confirmed successfully')),
        );
        context.pop();
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
      appBar: AppBar(title: const Text('Confirm Payment')),
      body: SingleChildScrollView(
        padding: AppTheme.paddingM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary
            Card(
              child: Padding(
                padding: AppTheme.paddingM,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.orderSummary, style: AppTheme.headingSmall),
                    const Divider(),
                    Text('Order: ${widget.order.orderNumber}'),
                    Text('Supplier: ${widget.order.supplierId.name}'),
                    Text(
                      'Total: \$${widget.order.totalAmount.toStringAsFixed(2)}',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Bill upload
            Text(l10n.billReceiptPhoto, style: AppTheme.headingSmall),
            const SizedBox(height: AppTheme.spacingS),
            if (_billFile != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppTheme.cardBorderRadius,
                    child: Image.file(_billFile!,
                        height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => _billFile = null),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: Text(l10n.takePhoto),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: Text(l10n.chooseFromGallery),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
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
                onPressed: _isSaving ? null : _confirm,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Confirm Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
