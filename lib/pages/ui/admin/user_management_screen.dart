import 'package:ct484_project/constants/colors.dart';
import 'package:ct484_project/models/user.model.dart';
import 'package:flutter/material.dart';
import 'package:ct484_project/services/auth_service.dart';
import 'package:provider/provider.dart';

class UserManagementScreen extends StatefulWidget {
  static const routeName = '/user-management';

  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late Future<List<UserModel>> _fetchUsersFuture;

  @override
  void initState() {
    super.initState();
    _fetchUsersFuture = _fetchUsers();
  }

  Future<List<UserModel>> _fetchUsers() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    return await authService.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _fetchUsersFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('Không có người dùng nào.'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (ctx, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text('role: ${user.role}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        user.isActive ? Icons.lock_open : Icons.lock,
                        color: user.isActive ? Colors.green : Colors.red,
                      ),
                      onPressed: () {
                        _confirmAction(
                          context,
                          user.isActive
                              ? 'Khóa tài khoản'
                              : 'Mở khóa tài khoản',
                          user.isActive
                              ? 'Bạn có chắc muốn khóa tài khoản này?'
                              : 'Bạn có chắc muốn mở khóa tài khoản này?',
                          () async {
                            final authService = Provider.of<AuthService>(
                                context,
                                listen: false);
                            await authService.toggleUserStatus(
                                user.id, !user.isActive);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(user.isActive
                                    ? 'Đã khóa tài khoản'
                                    : 'Đã mở khóa tài khoản'),
                              ),
                            );
                            setState(() {
                              _fetchUsersFuture = _fetchUsers();
                            });
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.admin_panel_settings),
                      onPressed: () {
                        final newRole = user.role == 'admin' ? 'user' : 'admin';
                        _confirmAction(
                          context,
                          'Thay đổi vai trò',
                          'Bạn có chắc muốn thay đổi vai trò thành $newRole?',
                          () async {
                            final authService = Provider.of<AuthService>(
                                context,
                                listen: false);
                            await authService.updateUserRole(user.id, newRole);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Đã cập nhật vai trò thành $newRole'),
                              ),
                            );
                            setState(() {
                              _fetchUsersFuture = _fetchUsers();
                            });
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _confirmAction(
                          context,
                          'Xóa người dùng',
                          'Bạn có chắc muốn xóa người dùng này?',
                          () async {
                            final authService = Provider.of<AuthService>(
                                context,
                                listen: false);
                            await authService.deleteUser(user.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Đã xóa người dùng')),
                            );
                            setState(() {
                              _fetchUsersFuture = _fetchUsers();
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmAction(
    BuildContext context,
    String title,
    String content,
    Future<void> Function() onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Color.fromARGB(255, 18, 133, 85))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Đóng dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) =>
                    const Center(child: CircularProgressIndicator()),
              );
              try {
                await onConfirm();
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $error')),
                );
              } finally {
                Navigator.pop(context); // Đóng loading dialog
              }
            },
            child: const Text('Xác nhận', style: TextStyle(color: Color.fromARGB(255, 103, 111, 105))),
          ),
        ],
      ),
    );
  }
}
