import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SupplierDetailsScreen extends StatelessWidget {
  final String supplierId;

  const SupplierDetailsScreen({
    super.key,
    required this.supplierId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business, size: 64, color: AppTheme.primaryOrange),
            const SizedBox(height: 16),
            Text('Supplier ID: $supplierId', style: AppTheme.bodyLarge),
            const SizedBox(height: 8),
            const Text('Supplier details will be displayed here', style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
