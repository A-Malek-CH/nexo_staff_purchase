import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../providers/admin_product_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../widgets/admin_bottom_nav.dart';
import '../../../../data/models/product_model.dart' hide Category;

class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({super.key});

  @override
  ConsumerState<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProductProvider.notifier).loadProducts();
      ref.read(categoryProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text(l10n.delete, style: const TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(adminProductProvider.notifier).deleteProduct(product.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.name} deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppTheme.errorRed),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(adminProductProvider);
    final categoryState = ref.watch(categoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final products = productState.filteredProducts;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.productManagement)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingM, AppTheme.spacingM, AppTheme.spacingM, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(adminProductProvider.notifier)
                              .searchProducts('');
                        },
                      )
                    : null,
              ),
              onChanged: (v) =>
                  ref.read(adminProductProvider.notifier).searchProducts(v),
            ),
          ),
          // Category filter
          if (categoryState.categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingM, AppTheme.spacingS, AppTheme.spacingM, 0),
              child: DropdownButtonFormField<String?>(
                value: productState.selectedCategoryId,
                decoration:
                    InputDecoration(labelText: l10n.category),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.noCategory)),
                  ...categoryState.categories.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      )),
                ],
                onChanged: (v) =>
                    ref.read(adminProductProvider.notifier).filterByCategory(v),
              ),
            ),
          Expanded(
            child: productState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(productState.error!),
                            const SizedBox(height: AppTheme.spacingM),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(adminProductProvider.notifier)
                                  .loadProducts(),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      )
                    : products.isEmpty
                        ? Center(child: Text(l10n.noProductsFound))
                        : RefreshIndicator(
                            onRefresh: () => ref
                                .read(adminProductProvider.notifier)
                                .loadProducts(),
                            child: ListView.builder(
                              itemCount: products.length,
                              itemBuilder: (ctx, i) {
                                final product = products[i];
                                return _ProductCard(
                                  product: product,
                                  onTap: () => context.push(
                                    '/admin/products/${product.id}',
                                    extra: product,
                                  ),
                                  onDelete: () =>
                                      _confirmDelete(context, product),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/products/new'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 4),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.currentStock != null &&
        product.minQty != null &&
        product.currentStock! < product.minQty!;

    return Card(
      child: ListTile(
        leading: product.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.inventory_2,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              )
            : const Icon(Icons.inventory_2, color: AppTheme.primaryOrange),
        title: Text(product.name, style: AppTheme.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.price != null)
              Text(
                '\$${product.price!.toStringAsFixed(2)}',
                style: AppTheme.bodySmall,
              ),
            Row(
              children: [
                Icon(
                  Icons.inventory,
                  size: 12,
                  color: isLowStock ? AppTheme.errorRed : AppTheme.successGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  'Stock: ${product.currentStock ?? 0}',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isLowStock ? AppTheme.errorRed : AppTheme.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
