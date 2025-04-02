import 'dart:io';

import 'package:ct484_project/models/user.model.dart';
import 'package:ct484_project/services/profile.service.dart';
import 'package:flutter/foundation.dart';


class ProfileManager with ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  UserModel? _userProfile;

  UserModel? get userProfile => _userProfile;

  Future<void> fetchProfile() async {
    try {
      _userProfile = await _profileService.fetchProfile();
      notifyListeners();
    } catch (error) {
      print('Lỗi khi lấy thông tin cá nhân: $error');
    }
  }

  Future<bool> updateProfile(String name, String email) async {
    final success = await _profileService.updateProfile(name, email);
    if (success) {
      await fetchProfile();
    }
    return success;
  }

  Future<String?> uploadAvatar(File imageFile) async {
    final avatarUrl = await _profileService.uploadAvatar(imageFile);
    if (avatarUrl != null) {
      _userProfile
          ?.updateAvatarUrl(avatarUrl); // Cập nhật avatarUrl trong model
      notifyListeners(); // Cập nhật UI
    }
    await fetchProfile(); // Đảm bảo đồng bộ với server
    return avatarUrl;
  }

  Future<bool> logout() async {
    final success = await _profileService.logout();
    if (success) {
      _userProfile = null;
      notifyListeners();
    }
    return success;
  }
}
