import 'package:ct484_project/constants/colors.dart';
import 'package:ct484_project/pages/ui/auth/auth_screen.dart';
import 'package:ct484_project/pages/ui/profile/profile_screen.dart';
import 'package:ct484_project/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtherScreen extends StatelessWidget {
  static const routeName = '/others';
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          const Expanded(
            child: ProfileScreen(),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: _buildOption(context, 'Đăng xuất', Icons.logout, () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xác nhận đăng xuất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?',  style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Hủy',  style: TextStyle(color: Color.fromARGB(255, 144, 189, 167)),
                      ),
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
                          await context.read<AuthService>().logout();
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
                          style: TextStyle(color: Color.fromARGB(255, 64, 126, 10))),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
