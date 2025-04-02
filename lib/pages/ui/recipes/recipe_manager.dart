import 'package:flutter/foundation.dart';
import 'package:ct484_project/services/recipe.service.dart'; // Sửa tên file import
import 'package:ct484_project/models/recipes.model.dart';
import 'package:ct484_project/models/categories.model.dart';
import 'dart:io';

class RecipeManager with ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  List<Recipe> _items = [];
  List<CategoryModel> _categories = [];
List<String> _recentlyViewedIds = [];
  List<Recipe> get items => _items;
  int get itemCount => _items.length;
  List<CategoryModel> get categories => _categories;

  Future<void> fetchRecipes({String? status, String? userId}) async {
    try {
      _items =
          await _recipeService.fetchRecipes(status: status, userId: userId);
      notifyListeners();
    } catch (error) {
      throw Exception('Lỗi khi lấy danh sách công thức: $error');
    }
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _recipeService.fetchCategories();
      notifyListeners();
    } catch (error) {
      throw Exception('Lỗi khi lấy danh sách danh mục: $error');
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      final newRecipe = await _recipeService.addRecipe(recipe);
      if (newRecipe != null) {
        _items.add(newRecipe);
        notifyListeners();
      }
    } catch (error) {
      throw Exception('Lỗi khi thêm công thức: $error');
    }
  }

  Future<CategoryModel?> addCategory(
      String categoryName, File? featuredImage) async {
    try {
      final newCategory =
          await _recipeService.addCategory(categoryName, featuredImage);
      if (newCategory != null) {
        _categories.add(newCategory);
        notifyListeners();
      }
      return newCategory;
    } catch (error) {
      throw Exception('Lỗi khi thêm danh mục: $error');
    }
  }

  Future<void> updateRecipeStatus(String recipeId, String status) async {
    try {
      final success = await _recipeService.updateRecipeStatus(recipeId, status);
      if (success) {
        // Làm mới danh sách thay vì cập nhật cục bộ
        await fetchRecipes(status: status);
      }
    } catch (error) {
      throw Exception('Lỗi khi cập nhật trạng thái công thức: $error');
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      final success = await _recipeService.deleteRecipe(id);
      if (success) {
        // Làm mới danh sách thay vì xóa cục bộ
        await fetchRecipes();
      }
    } catch (error) {
      throw Exception('Lỗi khi xóa công thức: $error');
    }
  }

Future<bool> likeRecipe(String recipeId) async {
    try {
      final index = _items.indexWhere((r) => r.id == recipeId);
      if (index == -1) {
        throw Exception('Công thức không tồn tại');
      }
      final recipe = _items[index];
      final success = await _recipeService.likeRecipe(recipeId, recipe.likes);
      if (success) {
        _items[index] = recipe.copyWith(likes: recipe.likes + 1);
        notifyListeners();
      }
      return success; // Trả về kết quả từ RecipeService
    } catch (error) {
      print('Error in RecipeManager.likeRecipe: $error');
      throw Exception('Lỗi khi thích công thức: $error');
    }
  }

  // Thêm công thức vào danh sách yêu thích
  Future<void> addToFavorites(String recipeId) async {
    try {
      final index = _items.indexWhere((r) => r.id == recipeId);
      if (index == -1) {
        throw Exception('Công thức không tồn tại');
      }
      await _recipeService.addToFavorites(recipeId);
      // Làm mới danh sách để cập nhật trạng thái isFavorite
      await fetchRecipes();
    } catch (error) {
      throw Exception('Lỗi khi thêm vào danh sách yêu thích: $error');
    }
  }

  // Xóa công thức khỏi danh sách yêu thích
  Future<void> removeFromFavorites(String recipeId) async {
    try {
      final index = _items.indexWhere((r) => r.id == recipeId);
      if (index == -1) {
        throw Exception('Công thức không tồn tại');
      }
      await _recipeService.removeFromFavorites(recipeId);
      // Làm mới danh sách để cập nhật trạng thái isFavorite
      await fetchRecipes();
    } catch (error) {
      throw Exception('Lỗi khi xóa khỏi danh sách yêu thích: $error');
    }
  }

  // Lấy danh sách các công thức yêu thích (tùy chọn)
  Future<List<Recipe>> fetchFavoriteRecipes() async {
    try {
      // Lấy tất cả công thức và lọc những công thức có isFavorite = true
      final allRecipes = await _recipeService.fetchRecipes();
      final favoriteRecipes =
          allRecipes.where((recipe) => recipe.isFavorite).toList();
      return favoriteRecipes;
    } catch (error) {
      throw Exception('Lỗi khi lấy danh sách công thức yêu thích: $error');
    }
  }

  // Thêm công thức vào danh sách đã xem gần đây
  void addToRecentlyViewed(String recipeId) {
    if (_recentlyViewedIds.contains(recipeId)) {
      _recentlyViewedIds.remove(recipeId); // Đưa lên đầu nếu đã có
    }
    _recentlyViewedIds.insert(0, recipeId); // Thêm vào đầu danh sách
    if (_recentlyViewedIds.length > 10) {
      _recentlyViewedIds.removeLast(); // Giới hạn 10 công thức
    }
    notifyListeners();
  }
  // Lấy danh sách công thức đã xem gần đây
  Future<List<Recipe>> fetchRecentlyViewedRecipes() async {
    try {
      final allRecipes = await _recipeService.fetchRecipes();
      final recentlyViewedRecipes = allRecipes
          .where((recipe) => _recentlyViewedIds.contains(recipe.id))
          .toList()
        ..sort((a, b) =>
            _recentlyViewedIds.indexOf(b.id) -
            _recentlyViewedIds.indexOf(a.id)); // Sắp xếp theo thứ tự đã xem
      return recentlyViewedRecipes;
    } catch (error) {
      throw Exception('Lỗi khi lấy danh sách công thức đã xem gần đây: $error');
    }
  }
}
