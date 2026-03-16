import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.read(categoryServiceProvider));
});

class CategoryRepository {
  final CategoryService _service;

  CategoryRepository(this._service);

  Future<List<Category>> getCategories() async {
    return _service.getCategories();
  }

  Future<Category> createCategory(Map<String, dynamic> data) async {
    return _service.createCategory(data);
  }

  Future<Category> updateCategory(String id, Map<String, dynamic> data) async {
    return _service.updateCategory(id, data);
  }

  Future<void> deleteCategory(String id) async {
    return _service.deleteCategory(id);
  }
}
