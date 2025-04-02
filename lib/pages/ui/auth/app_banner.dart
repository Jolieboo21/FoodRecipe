import 'dart:math';
import 'package:flutter/material.dart';

class AppBanner extends StatelessWidget {
  const AppBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 24.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Image.asset(
            'assets/icons/Banner.png',
            height: 200, // Điều chỉnh kích thước logo
            width: 200,
          ),
          const SizedBox(width: 12), // Khoảng cách giữa logo và text
          // Text
        ],
      ),
    );
  }
}
