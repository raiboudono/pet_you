import 'package:futter_you/features/category/model/category.dart';
import 'package:isar/isar.dart';

class CategoryRepository {
  CategoryRepository(this.isar);
  Isar isar;

  int assignId() => Isar.autoIncrement;

  List<Category?> categoriesAll() {
    return isar.categorys.where().findAllSync();
  }

  List<Category> categoriesSortByPositionAll() {
    return isar.categorys.where().sortByPosition().findAllSync();
  }

  void insertCategory(Category category) {
    isar.writeTxnSync(() => isar.categorys
        .putSync(category.copyWith(position: categoriesAll().length)));
  }

  List<List<int>> findCategoryTaskIds() {
    return isar.categorys.where().taskIdsProperty().findAllSync();
  }

  Category? findById(categoryId) {
    return isar.categorys.filter().idEqualTo(categoryId).findFirstSync();
  }

  List<Category> findByIds(categoryIds) {
    final categories = <Category>[];
    for (final categoryId in categoryIds) {
      final category = findById(categoryId);
      if (category != null) {
        categories.add(category);
      }
    }

    return categories;
  }

  // deleteCategory(Category category) {
  //   isar.writeTxnSync(() {
  //     isar.categorys.deleteSync(category.id);
  //   });
  // }
  deleteCategory(Category category) =>
      updateCategory(category.copyWith(visible: false));

  updateCategory(Category category) {
    isar.writeTxnSync(() {
      isar.categorys.putSync(category);
    });
  }
}
