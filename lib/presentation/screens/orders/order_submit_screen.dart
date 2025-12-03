import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/order_provider.dart';

class OrderSubmitScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderSubmitScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderSubmitScreen> createState() => _OrderSubmitScreenState();
}

class _OrderSubmitScreenState extends ConsumerState<OrderSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(ordersProvider.notifier).submitOrderForReview(
            widget.orderId,
            _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order submitted for review successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit order: ${e.toString()}'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Order'),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.paddingM,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: AppTheme.paddingM,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Submit Order for Review',
                              style: AppTheme.headingSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        'You are about to submit this order for review. Once submitted, the order status will change to "Pending Review" and will be reviewed by an administrator.',
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),

              Text(
                'Notes (Optional)',
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Add any additional notes or comments about this order',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.mediumGrey),
              ),
              const SizedBox(height: AppTheme.spacingM),

              TextFormField(
                controller: _notesController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Enter your notes here...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),

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
                  label: Text(_isSubmitting ? 'Submitting...' : 'Submit for Review'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
