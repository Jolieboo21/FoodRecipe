import 'package:ct484_project/constants/colors.dart';
import 'package:ct484_project/pages/ui/admin/recipe_management_screen.dart';
import 'package:ct484_project/pages/ui/admin/user_management_screen.dart';
import 'package:ct484_project/pages/ui/auth/auth_screen.dart';
import 'package:ct484_project/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatelessWidget {
  static const routeName = '/admin-dashboard';

  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(  
      appBar: AppBar(
        title: const Text('Quản trị'),
        backgroundColor: AppColors.primary,
        actions: [
          // Nút đăng xuất
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xác nhận đăng xuất', style:TextStyle(fontSize:20),),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Hủy', style: TextStyle(color: Color.fromARGB(255, 28, 130, 83))),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx); // Đóng dialog
                        // Hiển thị loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        try {
                          await authService.logout();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AuthScreen.routeName,
                            (Route<dynamic> route) => false,
                          );
                        } catch (error) {
                          Navigator.pop(context); // Đóng loading dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Đăng xuất thất bại: $error')),
                          );
                        }
                      },
                      child: const Text('Đăng xuất',
                          style: TextStyle(color: Color.fromARGB(255, 140, 134, 134))),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Đảm bảo column không chiếm toàn bộ chiều cao
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recipe Management Card
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, RecipeManagementScreen.routeName);
              },
              borderRadius: BorderRadius.circular(10),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'QUẢN LÝ CÔNG THỨC',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Khoảng cách động thay vì fix cứng

            // User Management Card
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, UserManagementScreen.routeName);
              },
              borderRadius: BorderRadius.circular(10),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'QUẢN LÝ NGƯỜI DÙNG',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
