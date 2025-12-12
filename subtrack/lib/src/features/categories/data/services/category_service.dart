import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:subtrack/src/data/database.dart';
import 'package:subtrack/src/features/categories/domain/entities/category.dart';

part 'category_service.g.dart';

@riverpod
CategoryService categoryService(CategoryServiceRef ref) {
  return CategoryService(ref.watch(appDatabaseProvider));
}

class CategoryService {
  final AppDatabase _db;

  CategoryService(this._db);

  Future<List<Category>> getCategories() async {
    final categories = await _db.select(_db.categories).get();
    return categories.map((e) => _mapCategoryDataToEntity(e)).toList();
  }

  Future<Category> getCategory(int id) async {
    final categoryData = await (_db.select(_db.categories)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();
    return _mapCategoryDataToEntity(categoryData);
  }

  Future<void> addCategory(Category category) async {
    await _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            name: category.name,
          ),
        );
  }

  Future<void> updateCategory(Category category) async {
    await (_db.update(_db.categories)..where((tbl) => tbl.id.equals(category.id)))
        .write(
          CategoriesCompanion(
            name: Value(category.name),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteCategory(int id) async {
    await (_db.delete(_db.categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  Category _mapCategoryDataToEntity(CategoryData data) {
    return Category(
      id: data.id,
      name: data.name,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
