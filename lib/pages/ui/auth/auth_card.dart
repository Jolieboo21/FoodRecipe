import 'dart:developer' show log;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ct484_project/constants/colors.dart';
import 'package:ct484_project/services/auth_service.dart';
import 'package:ct484_project/pages/ui/screen.dart';
import '../shared/dialog_utils.dart';

enum AuthMode { signup, login }

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'name': '',
    'email': '',
    'password': '',
  };
  final _isSubmitting = ValueNotifier<bool>(false);
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    _isSubmitting.value = true;

    try {
      final authService = context.read<AuthService>();
      if (_authMode == AuthMode.login) {
        // Đăng nhập
        await authService.login(
          _authData['email']!,
          _authData['password']!,
        );
        // Điều hướng đến MainScreen sau khi đăng nhập thành công
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            MainScreen.routeName,
            (Route<dynamic> route) => false,
          );
        }
      } else {
        // Đăng ký
        await authService.signup(
          _authData['name'] ?? '',
          _authData['email']!,
          _authData['password']!,
        );
        // Hiển thị thông báo đăng ký thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign up successful! Please log in.')),
          );
        }
        // Chuyển về chế độ login
        _switchAuthMode();
      }
    } catch (error) {
      log('$error');
      if (mounted) {
        showErrorDialog(context, error.toString());
      }
    } finally {
      _isSubmitting.value = false;
    }
  }

  void _switchAuthMode() {
    setState(() {
      _authMode =
          _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.sizeOf(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 8.0,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        width: deviceSize.width * 0.85,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildEmailField(),
                const SizedBox(height: 16),
                if (_authMode == AuthMode.signup) ...[
                  _buildNameField(),
                  const SizedBox(height: 16),
                ],
                _buildPasswordField(),
                if (_authMode == AuthMode.signup) ...[
                  const SizedBox(height: 16),
                  _buildPasswordConfirmField(),
                ],
                const SizedBox(height: 24),
                ValueListenableBuilder<bool>(
                  valueListenable: _isSubmitting,
                  builder: (context, isSubmitting, child) {
                    return isSubmitting
                        ? const CircularProgressIndicator(
                            color: AppColors.primary)
                        : _buildSubmitButton();
                  },
                ),
                const SizedBox(height: 12),
                _buildAuthModeSwitchButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthModeSwitchButton() {
    return TextButton(
      onPressed: _switchAuthMode,
      child: Text(
        '${_authMode == AuthMode.login ? 'ĐĂNG KÝ' : 'ĐĂNG NHẬP'} NGAY',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        _authMode == AuthMode.login ? 'ĐĂNG NHẬP' : 'ĐĂNG KÝ',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPasswordConfirmField() {
    return TextFormField(
      enabled: _authMode == AuthMode.signup,
      decoration: _inputDecoration('Nhập lại mật khẩu'),
      obscureText: true,
      validator: _authMode == AuthMode.signup
          ? (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match!';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: _inputDecoration('Mật khẩu'),
      obscureText: true,
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.length < 5) {
          return 'Password must be at least 5 characters!';
        }
        return null;
      },
      onSaved: (value) {
        _authData['password'] = value!;
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: _inputDecoration('Tên đầy đủ'),
      keyboardType: TextInputType.name,
      validator: _authMode == AuthMode.signup
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name!';
              }
              return null;
            }
          : null,
      onSaved: (value) {
        _authData['name'] = value!;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: _inputDecoration('Email'),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty || !value.contains('@')) {
          return 'Please enter a valid email!';
        }
        return null;
      },
      onSaved: (value) {
        _authData['email'] = value!;
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.secondaryText),
      filled: true,
      fillColor: AppColors.form,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }
}
