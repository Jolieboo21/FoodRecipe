import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/user.model.dart';
import 'pocketbase_client.dart';

class AuthService with ChangeNotifier {
  UserModel? _user;
  void Function(UserModel? user)? onAuthChange;

  AuthService({this.onAuthChange}) {
    _initAuthListener();
  }

  // Getter để kiểm tra vai trò admin
  bool get isAdmin => _user?.role == 'admin';

  // Getter để lấy thông tin người dùng hiện tại
  UserModel? get currentUser => _user;

  // Khởi tạo listener cho sự thay đổi trạng thái xác thực
  Future<void> _initAuthListener() async {
    final pb = await getPocketbaseInstance();
    pb.authStore.onChange.listen((event) {
      if (event.record == null) {
        _user = null;
      } else {
        _user = UserModel.fromJson(event.record!.toJson());
      }
      notifyListeners();
      if (onAuthChange != null) {
        onAuthChange!(_user);
      }
    });

    // Kiểm tra trạng thái xác thực ban đầu
    final initialUser = await getUserFromStore();
    if (initialUser != null) {
      _user = initialUser;
      notifyListeners();
    }
  }

  // Đăng ký người dùng mới
  Future<UserModel> signup(String name, String email, String password,
      {String role = 'user'}) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception("Email, mật khẩu và tên không được để trống.");
    }

    final pb = await getPocketbaseInstance();
    try {
      final record = await pb.collection('users').create(body: {
        'name': name,
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'role': role,
        'isActive': true,
      });

      print("📡 API Response (Signup): ${record.toJson()}");
      final newUser = UserModel.fromJson(record.toJson());
      _user = newUser;
      notifyListeners();
      return newUser;
    } catch (error, stacktrace) {
      print("❌ Error (Signup): $error");
      print("📜 Stacktrace: $stacktrace");

      if (error is ClientException) {
        print("📡 API Response: ${error.response}");
        throw Exception(error.response['message'] ?? 'Đăng ký thất bại');
      }

      throw Exception('Đăng ký thất bại: $error');
    }
  }

  // Đăng nhập
  Future<UserModel> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email và mật khẩu không được để trống.");
    }

    final pb = await getPocketbaseInstance();
    try {
      final authRecord =
          await pb.collection('users').authWithPassword(email, password);
      final loggedInUser = UserModel.fromJson(authRecord.record.toJson());
      print("User after login: ${loggedInUser.toJson()}");
      print("Is admin: ${loggedInUser.role == 'admin'}");
      _user = loggedInUser;
      notifyListeners();
      return loggedInUser;
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message'] ?? 'Đăng nhập thất bại');
      }
      throw Exception('Đăng nhập thất bại: $error');
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    final pb = await getPocketbaseInstance();
    pb.authStore.clear();
    _user = null;
    notifyListeners();
  }

  // Lấy thông tin người dùng từ store
  Future<UserModel?> getUserFromStore() async {
    final pb = await getPocketbaseInstance();
    final model = pb.authStore.model;
    if (model == null) {
      print("No user in authStore");
      return null;
    }
    final user = UserModel.fromJson(model.toJson());
    print("User from store: ${user.toJson()}");
    return user;
  }

  // Lấy danh sách người dùng (dành cho admin)
  Future<List<UserModel>> fetchUsers() async {
    if (!isAdmin) {
      throw Exception('Bạn không có quyền truy cập danh sách người dùng');
    }

    final pb = await getPocketbaseInstance();
    try {
      final records = await pb.collection('users').getFullList();
      return records
          .map((record) => UserModel.fromJson(record.toJson()))
          .toList();
    } catch (error) {
      print('Lỗi khi lấy danh sách người dùng: $error');
      throw Exception('Không thể lấy danh sách người dùng: $error');
    }
  }

  // Khóa hoặc mở tài khoản người dùng
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    if (!isAdmin) {
      throw Exception('Bạn không có quyền thực hiện hành động này');
    }

    final pb = await getPocketbaseInstance();
    try {
      // Kiểm tra xem người dùng có tồn tại không
      await pb.collection('users').getOne(userId);
      await pb.collection('users').update(userId, body: {
        'isActive': isActive,
      });
    } catch (error) {
      print('Lỗi khi cập nhật trạng thái người dùng: $error');
      throw Exception('Không thể cập nhật trạng thái người dùng: $error');
    }
  }

  // Cập nhật vai trò người dùng
  Future<void> updateUserRole(String userId, String newRole) async {
    if (!isAdmin) {
      throw Exception('Bạn không có quyền thực hiện hành động này');
    }

    if (newRole != 'admin' && newRole != 'user') {
      throw Exception('Vai trò không hợp lệ. Chỉ hỗ trợ "admin" hoặc "user".');
    }

    final pb = await getPocketbaseInstance();
    try {
      // Kiểm tra xem người dùng có tồn tại không
      await pb.collection('users').getOne(userId);
      await pb.collection('users').update(userId, body: {
        'role': newRole,
      });
      // Nếu người dùng đang cập nhật là chính họ, cập nhật lại _user
      if (_user?.id == userId) {
        _user = UserModel(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
          role: newRole,
          avatarUrl: _user!.avatarUrl,
          isActive: _user!.isActive,
        );
        notifyListeners();
      }
    } catch (error) {
      print('Lỗi khi cập nhật vai trò người dùng: $error');
      throw Exception('Không thể cập nhật vai trò người dùng: $error');
    }
  }

  // Xóa tài khoản người dùng
  Future<void> deleteUser(String userId) async {
    if (!isAdmin) {
      throw Exception('Bạn không có quyền thực hiện hành động này');
    }

    final pb = await getPocketbaseInstance();
    try {
      // Kiểm tra xem người dùng có tồn tại không
      await pb.collection('users').getOne(userId);
      await pb.collection('users').delete(userId);
    } catch (error) {
      print('Lỗi khi xóa người dùng: $error');
      throw Exception('Không thể xóa người dùng: $error');
    }
  }
}
