import 'package:pocketbase/pocketbase.dart';
import 'package:ct484_project/services/pocketbase_client.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:ct484_project/models/user.model.dart';

class ProfileService {
  Future<PocketBase> _getClient() async {
    return await getPocketbaseInstance();
  }

  // Lấy URL của avatar từ PocketBase
  String _getAvatarUrl(PocketBase pb, RecordModel userModel) {
    final avatarName = userModel.getStringValue('avatar');
    return pb.files.getUrl(userModel, avatarName).toString();
  }

  Future<UserModel?> fetchProfile() async {
    try {
      final pb = await _getClient();
      final user = pb.authStore.record; // Đây là RecordModel
      if (user != null) {
        final profileData = user.toJson(); // Chuyển thành Map<String, dynamic>
        profileData['avatarUrl'] =
            _getAvatarUrl(pb, user); // Thêm avatarUrl vào dữ liệu
        return UserModel.fromJson(profileData); // Ánh xạ thành UserModel
      }
      return null;
    } catch (error) {
      print('Lỗi khi lấy thông tin cá nhân: $error');
      return null;
    }
  }

  Future<bool> updateProfile(String name, String email) async {
    try {
      final pb = await _getClient();
      final user = pb.authStore.record;
      if (user != null) {
        await pb.collection('users').update(user.id, body: {
          'name': name,
          'email': email,
        });
        return true;
      }
      return false;
    } catch (error) {
      print('Lỗi khi cập nhật profile: $error');
      return false;
    }
  }

  Future<String?> uploadAvatar(File imageFile) async {
    try {
      final pb = await _getClient();
      final user = pb.authStore.record;
      if (user != null) {
        // Tạo MultipartFile từ file ảnh
        final file = await http.MultipartFile.fromPath(
          'avatar', // Tên trường trong database
          imageFile.path,
          filename:
              'avatar_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        // Gửi yêu cầu update với file
        final record = await pb.collection('users').update(
          user.id,
          files: [file], // Sử dụng tham số files để gửi file
        );

        // Lấy URL của avatar từ record trả về
        final avatarUrl = _getAvatarUrl(pb, record);
        print('Avatar URL sau khi upload: $avatarUrl');
        return avatarUrl;
      }
      return null;
    } catch (error) {
      print('Lỗi khi upload avatar: $error');
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      final pb = await _getClient();
      pb.authStore.clear();
      return true;
    } catch (error) {
      print('Lỗi khi đăng xuất: $error');
      return false;
    }
  }
}
