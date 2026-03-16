import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../providers/category_provider.dart';
import '../../../../data/models/category_model.dart';

class CategoriesListScreen extends ConsumerStatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  ConsumerState<CategoriesListScreen> createState() =>
      _CategoriesListScreenState();
}

class _CategoriesListScreenState extends ConsumerState<CategoriesListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(categoryProvider.notifier).loadCategories());
  }

  Future<void> _confirmDelete(BuildContext context, Category category) async {
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
        await ref
            .read(categoryProvider.notifier)
            .deleteCategory(category.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${category.name} deleted')),
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
    final catState = ref.watch(categoryProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoryManagement)),
      body: catState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : catState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(catState.error!),
                      const SizedBox(height: AppTheme.spacingM),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(categoryProvider.notifier).loadCategories(),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : catState.categories.isEmpty
                  ? Center(child: Text(l10n.categoryManagement))
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(categoryProvider.notifier).loadCategories(),
                      child: ListView.builder(
                        padding: AppTheme.paddingM,
                        itemCount: catState.categories.length,
                        itemBuilder: (ctx, i) {
                          final cat = catState.categories[i];
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppTheme.lightBeige,
                                child: Icon(Icons.category,
                                    color: AppTheme.primaryOrange),
                              ),
                              title: Text(cat.name, style: AppTheme.bodyLarge),
                              subtitle: cat.description != null
                                  ? Text(cat.description!,
                                      style: AppTheme.bodySmall)
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: AppTheme.primaryOrange),
                                    onPressed: () => context.push(
                                      '/admin/categories/${cat.id}',
                                      extra: cat,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: AppTheme.errorRed),
                                    onPressed: () =>
                                        _confirmDelete(context, cat),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/categories/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
