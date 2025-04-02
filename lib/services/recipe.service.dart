import 'package:ct484_project/models/user.model.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:ct484_project/models/recipes.model.dart';
import 'package:ct484_project/models/categories.model.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'pocketbase_client.dart';

class RecipeService {
  Future<PocketBase> _getClient() async {
    return await getPocketbaseInstance();
  }

  String _getFeaturedImageUrl(PocketBase pb, RecordModel model) {
    final featuredImageName = model.getStringValue('featuredImage');
    if (featuredImageName.isEmpty) {
      return '';
    }
    return pb.files.getUrl(model, featuredImageName).toString();
  }

  String _getCategoryImageUrl(PocketBase pb, RecordModel model) {
    final featuredImageName = model.getStringValue('featuredImage');
    if (featuredImageName.isEmpty) {
      return '';
    }
    return pb.files.getUrl(model, featuredImageName).toString();
  }

  Future<List<Recipe>> fetchRecipes({String? status, String? userId}) async {
    try {
      final pb = await _getClient();
      String filter = '';
      if (userId != null) {
        filter = 'userId = "$userId"';
      }
      if (status != null) {
        filter = filter.isEmpty
            ? 'status = "$status"'
            : '$filter && status = "$status"';
      }
      final records = await pb.collection('recipes').getFullList(
            filter: filter,
            expand: 'userId,category',
          );
      final List<Recipe> recipes = [];
      for (final record in records) {
        final recipeData = record.toJson();
        recipeData['imageUrl'] = _getFeaturedImageUrl(pb, record);

        final userRecords = record.expand['userId'] as List<dynamic>?;
        RecordModel? userRecord;
        if (userRecords != null && userRecords.isNotEmpty) {
          userRecord = userRecords.first as RecordModel;
        }
        if (userRecord != null) {
          final userData = userRecord.toJson();
          recipeData['userName'] = userData['name'] ?? '';
          recipeData['userAvatarUrl'] = userData['avatar'] != null
              ? pb.files.getUrl(userRecord, userData['avatar']).toString()
              : '';
        } else {
          recipeData['userName'] = 'Unknown';
          recipeData['userAvatarUrl'] = '';
        }

        final categoryRecords = record.expand['category'] as List<dynamic>?;
        RecordModel? categoryRecord;
        if (categoryRecords != null && categoryRecords.isNotEmpty) {
          categoryRecord = categoryRecords.first as RecordModel;
        }
        if (categoryRecord != null) {
          final categoryData = categoryRecord.toJson();
          recipeData['categoryName'] = categoryData['name'] ?? 'Unknown';
        } else {
          recipeData['categoryName'] = 'Unknown';
        }

        recipeData['likes'] = record.getIntValue('likes', 0);
        recipeData['status'] = record.getStringValue('status', 'pending');
        // Kiểm tra xem công thức có trong danh sách yêu thích của người dùng hiện tại không
        recipeData['isFavorite'] = await _isFavorite(pb, record.id);
        recipes.add(Recipe.fromJson(recipeData));
      }
      return recipes;
    } catch (error) {
      throw Exception('Failed to fetch recipes: $error');
    }
  }

  Future <List<CategoryModel>> fetchCategories() async {
    try {
      final pb = await _getClient();
      final records = await pb.collection('categories').getFullList();
      final List<CategoryModel> categories = [];
      for (final record in records) {
        final categoryData = record.toJson();
        categoryData['imageUrl'] = _getCategoryImageUrl(pb, record);
        categories.add(CategoryModel.fromJson(categoryData));
      }
      return categories;
    } catch (error) {
      throw Exception('Failed to fetch categories: $error');
    }
  }

  Future<CategoryModel?> addCategory(String categoryName, File? featuredImage) async {
    try {
      if (categoryName.isEmpty) {
        throw Exception('Category name cannot be empty');
      }
      final pb = await _getClient();
      final body = {
        'name': categoryName,
      };
      final record = await pb.collection('categories').create(
            body: body,
            files: featuredImage != null
                ? [
                    http.MultipartFile.fromBytes(
                      'featuredImage',
                      await featuredImage.readAsBytes(),
                      filename: featuredImage.path.split('/').last,
                    ),
                  ]
                : [],
          );
      final categoryData = record.toJson();
      categoryData['imageUrl'] = _getCategoryImageUrl(pb, record);
      return CategoryModel.fromJson(categoryData);
    } catch (error) {
      throw Exception('Failed to add category: $error');
    }
  }

  Future<Recipe?> addRecipe(Recipe recipe) async {
    try {
      final pb = await _getClient();
      if (pb.authStore.model == null) {
        throw Exception('User not authenticated');
      }

      String categoryId = recipe.category;
      bool categoryExists = false;
      if (recipe.categoryName.isNotEmpty) {
        final existingCategories = await pb.collection('categories').getList(
              filter: 'name = "${recipe.categoryName}"',
            );
        if (existingCategories.items.isNotEmpty) {
          categoryId = existingCategories.items.first.id;
          categoryExists = true;
        }
      }

      if (!categoryExists && recipe.categoryName.isNotEmpty) {
        final newCategory = await addCategory(recipe.categoryName, null);
        if (newCategory != null) {
          categoryId = newCategory.id;
        } else {
          throw Exception('Failed to create new category');
        }
      }

      final body = {
        ...recipe.toJson(),
        'userId': pb.authStore.model!.id,
        'category': categoryId,
        'status': 'pending',
      };
      final record = await pb.collection('recipes').create(
            body: body,
            files: recipe.featuredImage != null
                ? [
                    http.MultipartFile.fromBytes(
                      'featuredImage',
                      await recipe.featuredImage!.readAsBytes(),
                      filename: recipe.featuredImage!.path.split('/').last,
                    ),
                  ]
                : [],
            expand: 'userId,category',
          );
      final recipeData = record.toJson();
      recipeData['imageUrl'] = _getFeaturedImageUrl(pb, record);

      final userRecords = record.expand['userId'] as List<dynamic>?;
      RecordModel? userRecord;
      if (userRecords != null && userRecords.isNotEmpty) {
        userRecord = userRecords.first as RecordModel;
      }
      if (userRecord != null) {
        final userData = userRecord.toJson();
        recipeData['userName'] = userData['name'] ?? '';
        recipeData['userAvatarUrl'] = userData['avatar'] != null
            ? pb.files.getUrl(userRecord, userData['avatar']).toString()
            : '';
      } else {
        recipeData['userName'] = 'Unknown';
        recipeData['userAvatarUrl'] = '';
      }

      final categoryRecords = record.expand['category'] as List<dynamic>?;
      RecordModel? categoryRecord;
      if (categoryRecords != null && categoryRecords.isNotEmpty) {
        categoryRecord = categoryRecords.first as RecordModel;
      }
      if (categoryRecord != null) {
        final categoryData = categoryRecord.toJson();
        recipeData['categoryName'] = categoryData['name'] ?? 'Unknown';
      } else {
        recipeData['categoryName'] = 'Unknown';
      }

      recipeData['likes'] = record.getIntValue('likes', 0);
      recipeData['status'] = record.getStringValue('status', 'pending');
      recipeData['isFavorite'] = await _isFavorite(pb, record.id);
      return Recipe.fromJson(recipeData);
    } catch (error) {
      throw Exception('Failed to add recipe: $error');
    }
  }

  Future<bool> updateRecipeStatus(String recipeId, String status) async {
    try {
      final pb = await _getClient();
      await pb.collection('recipes').getOne(recipeId);
      await pb.collection('recipes').update(
        recipeId,
        body: {
          'status': status,
        },
      );
      return true;
    } catch (error) {
      throw Exception('Failed to update recipe status: $error');
    }
  }

Future<bool> likeRecipe(String recipeId, int currentLikes) async {
    try {
      final pb = await _getClient();
      if (pb.authStore.model == null) {
        throw Exception('User not authenticated');
      }
      final userId = pb.authStore.model!.id;

      // Lấy thông tin công thức
      final recipeRecord = await pb.collection('recipes').getOne(recipeId);
      final likedBy = recipeRecord.getDataValue<List<dynamic>>('likedBy') ?? [];

      // Kiểm tra xem người dùng đã thích chưa
      if (likedBy.contains(userId)) {
        return false; // Người dùng đã thích, không làm gì
      }

      // Thêm userId vào likedBy và tăng likes
      final updatedLikedBy = [...likedBy, userId];
      await pb.collection('recipes').update(
        recipeId,
        body: {
          'likes': currentLikes + 1,
          'likedBy': updatedLikedBy,
        },
      );
      return true;
    } catch (error) {
      throw Exception('Failed to like recipe: $error');
    }
  }

  Future<bool> deleteRecipe(String id) async {
    try {
      final pb = await _getClient();
      await pb.collection('recipes').delete(id);
      return true;
    } catch (error) {
      throw Exception('Failed to delete recipe: $error');
    }
  }

  // Kiểm tra xem công thức có trong danh sách yêu thích của người dùng không
  Future<bool> _isFavorite(PocketBase pb, String recipeId) async {
    if (pb.authStore.model == null) return false;
    final userId = pb.authStore.model!.id;
    final user = await pb.collection('users').getOne(userId, expand: 'favorites');
    final favorites = user.expand['favorites'] as List<dynamic>? ?? [];
    return favorites.any((favorite) => favorite.id == recipeId);
  }

  // Thêm công thức vào danh sách yêu thích
// Trong RecipeService
Future<void> addToFavorites(String recipeId) async {
    try {
      final pb = await _getClient();
      if (pb.authStore.model == null) {
        throw Exception('User not authenticated');
      }
      final userId = pb.authStore.model!.id;

      // Lấy thông tin người dùng hiện tại
      final userRecord =
          await pb.collection('users').getOne(userId, expand: 'favorites');
      final user = UserModel.fromJson(userRecord.toJson());

      // Thêm công thức vào danh sách yêu thích
      final updatedUser = user.addFavorite(recipeId);

      // Cập nhật lên PocketBase
      await pb.collection('users').update(userId, body: {
        'favorites':
            updatedUser.favorites, // Gửi danh sách favorites dưới dạng mảng
      });
    } catch (error) {
      print('Error in addToFavorites: $error'); // Thêm log để debug
      throw Exception('Failed to add to favorites: $error');
    }
  }

  Future<void> removeFromFavorites(String recipeId) async {
    try {
      final pb = await _getClient();
      if (pb.authStore.model == null) {
        throw Exception('User not authenticated');
      }
      final userId = pb.authStore.model!.id;

      // Lấy thông tin người dùng hiện tại
      final userRecord =
          await pb.collection('users').getOne(userId, expand: 'favorites');
      final user = UserModel.fromJson(userRecord.toJson());

      // Xóa công thức khỏi danh sách yêu thích
      final updatedUser = user.removeFavorite(recipeId);

      // Cập nhật lên PocketBase
      await pb.collection('users').update(userId, body: updatedUser.toJson());
    } catch (error) {
      throw Exception('Failed to remove from favorites: $error');
    }
  }
}