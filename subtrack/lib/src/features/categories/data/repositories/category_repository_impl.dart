import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:subtrack/src/features/categories/data/services/category_service.dart';
import 'package:subtrack/src/features/categories/domain/entities/category.dart';
import 'package:subtrack/src/features/categories/domain/repositories/category_repository.dart';

part 'category_repository_impl.g.dart';

@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  return CategoryRepositoryImpl(ref.watch(categoryServiceProvider));
}

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryService _categoryService;

  CategoryRepositoryImpl(this._categoryService);

  @override
  Future<void> addCategory(Category category) {
    return _categoryService.addCategory(category);
  }

  @override
  Future<void> deleteCategory(int id) {
    return _categoryService.deleteCategory(id);
  }

  @override
  Future<List<Category>> getCategories() {
    return _categoryService.getCategories();
  }

  @override
  Future<Category> getCategory(int id) {
    return _categoryService.getCategory(id);
  }

  @override
  Future<void> updateCategory(Category category) {
    return _categoryService.updateCategory(category);
  }
}
