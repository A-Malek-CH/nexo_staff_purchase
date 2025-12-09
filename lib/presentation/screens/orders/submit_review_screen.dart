import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order_provider.dart';

class SubmitReviewScreen extends ConsumerStatefulWidget {
  final Order order;

  const SubmitReviewScreen({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends ConsumerState<SubmitReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isSubmitting = false;
  
  // Maps to store edited values: itemId -> value
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, int> _editedQuantities = {};
  final Map<String, double> _editedPrices = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each item
    for (var item in widget.order.items) {
      _quantityControllers[item.id] = TextEditingController(
        text: item.quantity.toString(),
      );
      _priceControllers[item.id] = TextEditingController(
        text: item.unitCost.toStringAsFixed(2),
      );
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imagePickFailed(e.toString())),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _collectEditedValues() {
    // Collect edited values from controllers
    _editedQuantities.clear();
    _editedPrices.clear();
    
    for (var item in widget.order.items) {
      final qtyText = _quantityControllers[item.id]?.text ?? '';
      final priceText = _priceControllers[item.id]?.text ?? '';
      
      if (qtyText.isNotEmpty) {
        final qty = int.tryParse(qtyText);
        if (qty != null && qty != item.quantity) {
          _editedQuantities[item.id] = qty;
        }
      }
      
      if (priceText.isNotEmpty) {
        final price = double.tryParse(priceText);
        if (price != null && price != item.unitCost) {
          _editedPrices[item.id] = price;
        }
      }
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectImageRequired),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    _collectEditedValues();

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(ordersProvider.notifier).submitOrderForReview(
            widget.order.id,
            _selectedImage!,
            _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            editedQuantities: _editedQuantities,
            editedPrices: _editedPrices,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.orderConfirmedSuccess),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        // Navigate back to orders list and refresh
        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.orderConfirmFailed(e.toString())),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.confirmOrder),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.paddingM,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              Card(
                child: Padding(
                  padding: AppTheme.paddingM,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.orderSummary, style: AppTheme.headingSmall),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildInfoRow(l10n.orderNumber, widget.order.orderNumber),
                      _buildInfoRow(l10n.supplier, widget.order.supplierId.name),
                      _buildInfoRow(l10n.totalAmount, '\$${widget.order.totalAmount.toStringAsFixed(2)}'),
                      if (widget.order.expectedDate != null)
                        _buildInfoRow(l10n.expectedDate, DateHelper.formatDate(widget.order.expectedDate!)),
                      _buildInfoRow(l10n.products, '${widget.order.items.length} ${l10n.items}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Edit Price & Quantity Section
              Text(
                l10n.editPriceQuantity,
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                l10n.reviewAndAdjustHint,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.mediumGrey),
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              ...widget.order.items.map((item) => _buildEditableItemCard(item, l10n)),
              
              const SizedBox(height: AppTheme.spacingL),

              // Changes Summary
              _buildChangesSummary(l10n),
              
              const SizedBox(height: AppTheme.spacingL),

              // Image Upload Section
              Text(
                l10n.billReceiptPhoto,
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                l10n.uploadProofOfPurchase,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.mediumGrey),
              ),
              const SizedBox(height: AppTheme.spacingM),

              if (_selectedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: AppTheme.errorRed,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _showImageSourceDialog,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(l10n.selectImage),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
              const SizedBox(height: AppTheme.spacingL),

              // Notes Section
              Text(
                l10n.notesOptional,
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                l10n.addNotesHint,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.mediumGrey),
              ),
              const SizedBox(height: AppTheme.spacingM),

              TextFormField(
                controller: _notesController,
                maxLines: 6,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  hintText: l10n.enterNotesHere,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitOrder,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isSubmitting ? l10n.confirming : l10n.confirmOrder),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text(l10n.cancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.mediumGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableItemCard(ProductOrder item, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: AppTheme.paddingM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name
            Text(
              item.productId.name,
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            Row(
              children: [
                // Quantity Field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.quantity,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _quantityControllers[item.id],
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        enabled: !_isSubmitting,
                        decoration: InputDecoration(
                          hintText: item.quantity.toString(),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.fieldRequired;
                          }
                          final qty = int.tryParse(value);
                          if (qty == null) {
                            return l10n.invalidNumber;
                          }
                          if (qty <= 0) {
                            return l10n.numberMustBePositive;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.originalQuantity(item.quantity.toString()),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.mediumGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                
                // Unit Price Field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.unitPrice,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _priceControllers[item.id],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        enabled: !_isSubmitting,
                        decoration: InputDecoration(
                          hintText: item.unitCost.toStringAsFixed(2),
                          border: const OutlineInputBorder(),
                          prefixText: '\$ ',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.fieldRequired;
                          }
                          final price = double.tryParse(value);
                          if (price == null) {
                            return l10n.invalidNumber;
                          }
                          if (price <= 0) {
                            return l10n.numberMustBePositive;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.originalPrice(item.unitCost.toStringAsFixed(2)),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.mediumGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangesSummary(AppLocalizations l10n) {
    // Collect edited values inline for display purposes only
    final Map<String, int> tempEditedQuantities = {};
    final Map<String, double> tempEditedPrices = {};
    
    for (var item in widget.order.items) {
      final qtyText = _quantityControllers[item.id]?.text ?? '';
      final priceText = _priceControllers[item.id]?.text ?? '';
      
      if (qtyText.isNotEmpty) {
        final qty = int.tryParse(qtyText);
        if (qty != null && qty != item.quantity) {
          tempEditedQuantities[item.id] = qty;
        }
      }
      
      if (priceText.isNotEmpty) {
        final price = double.tryParse(priceText);
        if (price != null && price != item.unitCost) {
          tempEditedPrices[item.id] = price;
        }
      }
    }
    
    if (tempEditedQuantities.isEmpty && tempEditedPrices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: AppTheme.primaryOrange.withOpacity(0.1),
      child: Padding(
        padding: AppTheme.paddingM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.edit_note,
                  color: AppTheme.primaryOrange,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.changesSummary,
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            if (tempEditedQuantities.isEmpty && tempEditedPrices.isEmpty)
              Text(
                l10n.noChanges,
                style: AppTheme.bodyMedium,
              )
            else
              ...widget.order.items.where((item) {
                return tempEditedQuantities.containsKey(item.id) || 
                       tempEditedPrices.containsKey(item.id);
              }).map((item) {
                final changes = <String>[];
                
                if (tempEditedQuantities.containsKey(item.id)) {
                  changes.add('${l10n.quantity}: ${l10n.changedFrom(
                    item.quantity.toString(),
                    tempEditedQuantities[item.id].toString(),
                  )}');
                }
                
                if (tempEditedPrices.containsKey(item.id)) {
                  changes.add('${l10n.unitPrice}: ${l10n.changedFrom(
                    '\$${item.unitCost.toStringAsFixed(2)}',
                    '\$${tempEditedPrices[item.id]!.toStringAsFixed(2)}',
                  )}');
                }
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productId.name,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...changes.map((change) => Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          '• $change',
                          style: AppTheme.bodySmall,
                        ),
                      )),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
