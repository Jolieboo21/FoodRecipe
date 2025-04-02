import 'package:flutter/material.dart';
import 'auth_card.dart';
import 'app_banner.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/icons/bg_login.jpg'),
          fit: BoxFit.cover,
          opacity: 0.5,
        )),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppBanner(),
                const SizedBox(height: 40),
                AuthCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
