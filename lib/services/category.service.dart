import 'package:ct484_project/models/categories.model.dart';
import 'package:ct484_project/services/pocketbase_client.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  Future<PocketBase> _getClient() async {
    return await getPocketbaseInstance();
  }

  // Lấy URL ảnh từ PocketBase
  String _getFeaturedImageUrl(PocketBase pb, RecordModel categoryModel) {
    final featuredImageName = categoryModel.getStringValue('featuredImage');
    return pb.files.getUrl(categoryModel, featuredImageName).toString();
  }

  // Lấy danh sách loại món ăn
  Future<List<CategoryModel>> fetchCategories() async {
    final List<CategoryModel> categories = [];
    try {
      final pb = await _getClient();
      final categoryModels = await pb.collection('categories').getFullList();
      for (final categoryModel in categoryModels) {
        categories.add(
          CategoryModel.fromJson(categoryModel.toJson()
            ..addAll({'imageUrl': _getFeaturedImageUrl(pb, categoryModel)})),
        );
      }
      return categories;
    } catch (error) {
      return categories;
    }
  }

  // Thêm loại món ăn với ảnh
  Future<CategoryModel?> addCategory(CategoryModel category) async {
    try {
      final pb = await _getClient();
      final categoryModel = await pb.collection('categories').create(
            body: category.toJson(),
            files: category.featuredImage != null
                ? [
                    http.MultipartFile.fromBytes(
                      'featuredImage',
                      await category.featuredImage!.readAsBytes(),
                      filename: category.featuredImage!.path.split('/').last,
                    ),
                  ]
                : [],
          );
      return CategoryModel.fromJson(categoryModel.toJson()
        ..addAll({'imageUrl': _getFeaturedImageUrl(pb, categoryModel)}));
    } catch (error) {
      return null;
    }
  }
}
