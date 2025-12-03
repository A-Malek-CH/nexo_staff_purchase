import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/product_service.dart';
import '../../../data/models/product_model.dart';
import '../../widgets/app_bottom_nav.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final productService = ref.read(productServiceProvider);
      final products = await productService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
                        const SizedBox(height: AppTheme.spacingM),
                        Text(_error!, style: AppTheme.bodyMedium),
                        const SizedBox(height: AppTheme.spacingM),
                        ElevatedButton(
                          onPressed: _loadProducts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _products.isEmpty
                    ? const Center(
                        child: Text('No products found', style: AppTheme.bodyMedium),
                      )
                    : ListView.builder(
                        padding: AppTheme.paddingM,
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                                backgroundImage: product.imageUrl != null
                                    ? NetworkImage(product.imageUrl!)
                                    : null,
                                child: product.imageUrl == null
                                    ? const Icon(Icons.inventory_2, color: AppTheme.primaryOrange)
                                    : null,
                              ),
                              title: Text(
                                product.name,
                                style: AppTheme.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  if (product.categoryName != null)
                                    Text(
                                      product.categoryName!,
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.mediumGrey,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.inventory,
                                        size: 14,
                                        color: AppTheme.mediumGrey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Stock: ${product.currentStock ?? 0} ${product.unit ?? "units"}',
                                        style: AppTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
