import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/category.dart';

import '../../../../constants/work/work.dart';

import '../../../infra/repository_provider.dart';
import '../../../infra/category/category_repository.dart';
import 'package:collection/collection.dart';

final categoryProvider =
    StateNotifierProvider<CategoryTaskStateNotifier, List<Category?>>((ref) {
  final repository = ref.watch(repositoryProvider(Work.category));
  return CategoryTaskStateNotifier(repository);
});

class CategoryTaskStateNotifier extends StateNotifier<List<Category?>> {
  CategoryTaskStateNotifier(this._repository)
      // : super(_repository.categoriesSortByPositionAll());
      : super(_repository.categoriesAll());

  final CategoryRepository _repository;

  int assignId() => _repository.assignId();

  void select(int index) => _repository.updateCategory(state[index]!);

  List<List<int?>> findCategoryTaskIds() => _repository.findCategoryTaskIds();

  void saveCategory(Category category) {
    final cts = _repository.categoriesAll();

    if (cts.isNotEmpty) {
      final ct = cts.firstWhereOrNull((ct) => ct!.name == category.name);
      if (ct != null) {
        _repository.updateCategory(ct.copyWith(visible: true));
      } else {
        _repository.insertCategory(category);
      }
    } else {
      _repository.insertCategory(category);
    }

    state = _repository.categoriesSortByPositionAll();
  }

  void updateCategory(Category category) {
    _repository.updateCategory(category);
    state = _repository.categoriesSortByPositionAll();
  }

  void removeCategory(Category category) {
    _repository.deleteCategory(category);
    state = _repository.categoriesSortByPositionAll();
  }

  Category? findById(categoryId) {
    return _repository.findById(categoryId);
  }

  List<Category?> findByIds(categoryIds) {
    final categories = _repository.findByIds(categoryIds);
    // state = [...categories];
    return categories;
  }

  findCategoryByPosition(int position) {}

  reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final targets = [...state];

    final c1 = targets[newIndex]!.copyWith(position: oldIndex);
    final c2 = targets[oldIndex]!.copyWith(position: newIndex);

    for (final category in [c1, c2]) {
      _repository.updateCategory(category);
    }

    state = _repository.categoriesSortByPositionAll();
  }
}
