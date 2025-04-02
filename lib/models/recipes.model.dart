import 'dart:io';

class Recipe {
  final String id;
  final String title;
  final String description;
  final File? featuredImage;
  final String? imageUrl; // URL của ảnh từ PocketBase
  final List<String> ingredients;
  final List<String> steps;
  final String category;
  final String categoryName;
  final int duration;
  final String userId; // ID của người tạo công thức
  final String userName;
  final String userAvatarUrl;
  final int likes;
  final String status; // "pending", "approved", "rejected"
  final bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    this.featuredImage,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.category,
    required this.categoryName,
    required this.duration,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    this.likes = 0,
    this.status = 'pending',
    this.isFavorite = false,
  });

  // Chuyển từ JSON (dữ liệu từ PocketBase) sang Recipe
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      ingredients:
          (json['ingredients'] as List<dynamic>?)?.cast<String>() ?? [],
      steps: (json['steps'] as List<dynamic>?)?.cast<String>() ?? [],
      category: json['category'] ?? '',
      categoryName: json['categoryName'] ?? 'Unknown',
      duration: json['duration'] ?? 0,
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatarUrl: json['userAvatarUrl'] ?? '',
      likes: json['likes'] ?? 0,
      status: json['status'] ?? 'pending',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Chuyển Recipe sang JSON để gửi lên PocketBase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'category': category,
      'categoryName': categoryName,
      'duration': duration,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'likes': likes,
      'status': status,
      'isFavorite': isFavorite,
    };
  }

  // Thêm phương thức copyWith
  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    File? featuredImage,
    String? imageUrl,
    List<String>? ingredients,
    List<String>? steps,
    String? category,
    String? categoryName,
    int? duration,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    int? likes,
    String? status,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      featuredImage: featuredImage ?? this.featuredImage,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      duration: duration ?? this.duration,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      likes: likes ?? this.likes,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
