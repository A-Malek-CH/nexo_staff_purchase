import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, size: 64, color: AppTheme.primaryOrange),
            const SizedBox(height: 16),
            Text('Product ID: $productId', style: AppTheme.bodyLarge),
            const SizedBox(height: 8),
            const Text('Product details will be displayed here', style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
