import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/src/features/categories/data/repositories/category_repository_impl.dart';
import 'package:subtrack/src/features/categories/domain/entities/category.dart';

final initializationServiceProvider = Provider((ref) => InitializationService(ref));

class InitializationService {
  final Ref _ref;

  InitializationService(this._ref);

  Future<void> initializeApp() async {
    await _initializeCategories();
    // Add other initialization tasks here
  }

  Future<void> _initializeCategories() async {
    final categoryRepository = _ref.read(categoryRepositoryProvider);
    final existingCategories = await categoryRepository.getCategories();

    if (existingCategories.isEmpty) {
      final defaultCategories = [
        Category(id: 0, name: 'General', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        Category(id: 0, name: 'Entertainment', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        Category(id: 0, name: 'Utilities', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        Category(id: 0, name: 'Software', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        Category(id: 0, name: 'Food', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      ];

      for (final category in defaultCategories) {
        await categoryRepository.addCategory(category);
      }
    }
  }
}
