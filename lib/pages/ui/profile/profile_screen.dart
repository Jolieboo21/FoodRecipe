import 'package:ct484_project/constants/colors.dart';
import 'package:ct484_project/pages/ui/profile/profile_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Provider.of<ProfileManager>(context, listen: false)
        .fetchProfile()
        .then((_) {
      final profile =
          Provider.of<ProfileManager>(context, listen: false).userProfile;
      if (profile != null) {
        _nameController.text = profile.name;
        _emailController.text = profile.email;
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa thông tin'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height *
                0.5, // Giới hạn chiều cao tối đa
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (Provider.of<ProfileManager>(context, listen: false)
                                    .userProfile
                                    ?.avatarUrl !=
                                null
                            ? NetworkImage(Provider.of<ProfileManager>(context,
                                    listen: false)
                                .userProfile!
                                .avatarUrl!)
                            : null) as ImageProvider?,
                    backgroundColor: Colors.grey[300],
                    child: (_selectedImage == null &&
                            Provider.of<ProfileManager>(context, listen: false)
                                    .userProfile
                                    ?.avatarUrl ==
                                null)
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên'),
                ),
                const SizedBox(
                    height: 8), // Thêm khoảng cách giữa các TextField
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final success = await Provider.of<ProfileManager>(context,
                      listen: false)
                  .updateProfile(_nameController.text, _emailController.text);
              if (success) {
                if (_selectedImage != null) {
                  await Provider.of<ProfileManager>(context, listen: false)
                      .uploadAvatar(_selectedImage!);
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Cập nhật thông tin thành công!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật thất bại!')),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileManager>(
      builder: (ctx, profileManager, child) {
        final profile = profileManager.userProfile;
        return Scaffold(
          body: profile == null
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 70,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (profile.avatarUrl != null
                                    ? NetworkImage(profile.avatarUrl!)
                                    : null) as ImageProvider?,
                            backgroundColor: Colors.grey[300],
                            child: (_selectedImage == null &&
                                    profile.avatarUrl == null)
                                ? const Icon(Icons.person,
                                    size: 70, color: Colors.grey)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          profile.name,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          profile.email,
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _showEditDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Chỉnh sửa thông tin'),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
