import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 64, color: AppTheme.primaryOrange),
            SizedBox(height: 16),
            Text('Products list will be displayed here', style: AppTheme.bodyMedium),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
