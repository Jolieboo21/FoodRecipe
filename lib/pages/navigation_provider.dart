import 'package:flutter/material.dart';
import 'package:ct484_project/services/auth_service.dart';
import 'package:provider/provider.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void changeIndex(int index, BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final navItemsLength =
        authService.isAdmin ? 6 : 5; // 6 nếu là admin, 5 nếu không

    // Đảm bảo index nằm trong khoảng hợp lệ
    if (index < 0 || index >= navItemsLength) {
      _selectedIndex = 0; // Đặt về 0 nếu index không hợp lệ
    } else {
      _selectedIndex = index;
    }
    notifyListeners();
  }

  // Phương thức để làm mới index khi isAdmin thay đổi
  void resetIndexIfNeeded(bool isAdmin) {
    final navItemsLength = isAdmin ? 6 : 5;
    if (_selectedIndex >= navItemsLength) {
      _selectedIndex = 0; // Đặt về 0 nếu index không hợp lệ
      notifyListeners();
    }
  }
}
