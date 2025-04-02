import 'dart:io';

class UserModel {
  final String id;
  final String name;
  final String email;
  String? avatarUrl; // URL của ảnh avatar từ PocketBase
  final String role;
  final bool isActive;
  final List<String> favorites; // Danh sách ID của các công thức yêu thích

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.avatarUrl,
    this.favorites = const [], // Mặc định là danh sách rỗng
  });

  // Chuyển từ JSON (dữ liệu từ PocketBase) sang UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("User JSON: $json");
    // Xử lý trường favorites linh hoạt hơn
    List<String> favoritesList = [];
    final favoritesData = json['favorites'];
    if (favoritesData is List<dynamic>) {
      favoritesList = favoritesData.map((item) => item.toString()).toList();
    } else if (favoritesData is String && favoritesData.isNotEmpty) {
      // Nếu là chuỗi không rỗng, giả sử là một ID đơn lẻ (hiếm gặp)
      favoritesList = [favoritesData];
    } // Nếu là chuỗi rỗng hoặc null, giữ danh sách rỗng

    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ??
          json['@attachment.avatar'] ??
          '', // Lấy URL avatar
      role: json['role'] ?? 'user', // Mặc định là "user"
      isActive: json['isActive'] ?? true, // Mặc định là true
      favorites: favoritesList,
    );
  }

  // Chuyển UserModel sang JSON để gửi lên PocketBase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
      'favorites': favorites, // Bao gồm favorites trong JSON
    };
  }

  // Phương thức để cập nhật avatarUrl (sau khi upload)
  void updateAvatarUrl(String? newAvatarUrl) {
    avatarUrl = newAvatarUrl ?? '';
  }

  // Phương thức copyWith để tạo bản sao với các giá trị thay đổi
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
    bool? isActive,
    List<String>? favorites,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      favorites: favorites ?? this.favorites,
    );
  }

  // Phương thức để thêm một công thức vào danh sách yêu thích
  UserModel addFavorite(String recipeId) {
    if (favorites.contains(recipeId)) {
      return this; // Không thêm nếu đã có
    }
    return copyWith(favorites: [...favorites, recipeId]);
  }

  // Phương thức để xóa một công thức khỏi danh sách yêu thích
  UserModel removeFavorite(String recipeId) {
    if (!favorites.contains(recipeId)) {
      return this; // Không xóa nếu không có
    }
    return copyWith(
        favorites: favorites.where((id) => id != recipeId).toList());
  }
}
