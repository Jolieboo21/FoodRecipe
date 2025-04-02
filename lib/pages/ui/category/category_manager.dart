import 'package:flutter/foundation.dart';
import 'package:ct484_project/models/categories.model.dart';
import 'package:ct484_project/services/category.service.dart';

class CategoryManager with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<CategoryModel> _items = [];

  int get itemCount {
    return _items.length;
  }

  List<CategoryModel> get items {
    return [..._items];
  }

  Future<void> fetchCategories() async {
    try {
      _items = await _categoryService.fetchCategories();
      _items.forEach((category) {
        print('Category ID: ${category.id}'); // Thêm log
      });
      notifyListeners();
    } catch (error) {
      print('Lỗi khi lấy danh sách danh mục: $error');
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    final newCategory = await _categoryService.addCategory(category);
    if (newCategory != null) {
      _items.add(newCategory);
      notifyListeners();
    }
  }

  CategoryModel? findById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (error) {
      return null;
    }
  }

  // Thêm hàm xóa nếu cần
  Future<void> deleteCategory(String id) async {
    // Lưu ý: Hiện tại CategoryService chưa có hàm delete, bạn có thể thêm vào CategoryService nếu cần
    // final index = _items.indexWhere((item) => item.id == id);
    // if (index >= 0 && await _categoryService.deleteCategory(id)) {
    //   _items.removeAt(index);
    //   notifyListeners();
    // }
  }
}
