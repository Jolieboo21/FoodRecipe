import 'dart:io';

class CategoryModel {
  final String id;
  final String name;
  final File? featuredImage;
 String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    this.featuredImage,
    this.imageUrl = '',
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
    };
  }
  // Cập nhật URL ảnh sau khi upload
  void updateImageUrl(String newImageUrl) {
    imageUrl = newImageUrl;
  }
}
