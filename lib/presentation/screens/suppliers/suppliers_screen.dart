import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: AppTheme.primaryOrange),
            SizedBox(height: 16),
            Text('Suppliers list will be displayed here', style: AppTheme.bodyMedium),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
