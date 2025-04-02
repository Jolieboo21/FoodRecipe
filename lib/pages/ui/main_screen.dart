import 'package:ct484_project/pages/navigation_provider.dart';
import 'package:ct484_project/pages/ui/admin/admin_dashboard.dart';
import 'package:ct484_project/pages/ui/favorites/favorite_screen.dart'; // Thêm import
import 'package:ct484_project/pages/ui/recently_view.dart/recently_viewed_screen.dart';
import 'package:ct484_project/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ct484_project/pages/ui/screen.dart';

class MainScreen extends StatelessWidget {
  static const routeName = '/home';
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NavigationProvider>(context);
    final authService = Provider.of<AuthService>(context);

    // Lắng nghe thay đổi của isAdmin và làm mới selectedIndex nếu cần
    authService.addListener(() {
      provider.resetIndexIfNeeded(authService.isAdmin);
    });

    final navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tất cả'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.category), label: 'Phân loại'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.favorite), label: 'Yêu thích'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.history), label: 'Gần đây'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz), label: 'Khác'),
      if (authService.isAdmin)
        const BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings), label: 'Quản trị'),
    ];

    // Kiểm tra selectedIndex trước khi hiển thị BottomNavigationBar
    if (provider.selectedIndex >= navItems.length) {
      provider.changeIndex(0, context);
    }

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300), // Thời gian chuyển đổi
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
                opacity: animation, child: child); // Hiệu ứng fade
          },
          child: _buildBody(provider.selectedIndex, authService.isAdmin),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: provider.selectedIndex,
        onTap: (index) => provider.changeIndex(index, context),
        selectedItemColor: const Color.fromARGB(255, 6, 140, 98),
        unselectedItemColor: Colors.grey,
        items: navItems,
      ),
    );
  }

  Widget _buildBody(int index, bool isAdmin) {
    // Nếu là admin và index là tab "Admin"
    if (isAdmin && index == 5) {
      return const AdminDashboard();
    }

    // Các tab khác
    switch (index) {
      case 0:
        return const ListRecipesOverScreen();
      case 1:
        return const CategoryScreen();
      case 2:
        return const FavoriteScreen(); // Hiển thị FavoriteScreen
      case 3:
        return const RecentlyViewedScreen(); // Giữ nguyên hoặc thay thế nếu cần
      case 4:
        return const OtherScreen();
      default:
        return const ListRecipesOverScreen();
    }
  }
}
