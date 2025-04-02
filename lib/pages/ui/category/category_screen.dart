import 'package:ct484_project/constants/colors.dart';
import 'package:ct484_project/models/categories.model.dart';
import 'package:ct484_project/pages/ui/category/category_itemCart.dart';
import 'package:ct484_project/pages/ui/category/category_manager.dart';
import 'package:ct484_project/pages/ui/recipes/recipeCategories_overscreen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CategoryScreen extends StatefulWidget {
  static const routeName = '/category';
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _nameController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<CategoryManager>(context, listen: false)
          .fetchCategories();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh mục: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _addCategory() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm loại món ăn',  
        style: TextStyle(color: AppColors.primary,fontSize: 16, ),
         textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên loại',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _selectedImage == null
                ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // Màu nền
                    ),
                    onPressed: _pickImage,
                    child: const Text('Chọn ảnh', style: TextStyle(color: Colors.white)),
                  )
                : Column(
                    children: [
                      Image.file(
                        _selectedImage!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      TextButton(
                        onPressed: _pickImage,
                        child: const Text('Thay đổi ảnh'),
                      ),
                    ],
                  ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedImage = null;
                _nameController.clear();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Hủy',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                setState(() {
                  _isLoading = true;
                });
                try {
                  final newCategory = CategoryModel(
                    id: '',
                    name: _nameController.text,
                    imageUrl: '',
                    featuredImage: _selectedImage,
                  );
                  await Provider.of<CategoryManager>(context, listen: false)
                      .addCategory(newCategory);
                  setState(() {
                    _selectedImage = null;
                    _nameController.clear();
                  });
                  Navigator.pop(ctx);
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi thêm danh mục: $error')),
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập tên danh mục')),
                );
              }
            },
            child: const Text('Thêm',  style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecipes(String categoryId) {
    Navigator.pushNamed(
      context,
      RecipeByCategoryScreen.routeName,
      arguments: categoryId,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryManager>(
      builder: (ctx, categoryManager, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Danh mục món ăn'),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: _addCategory,
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[100]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: categoryManager.items.isEmpty
                      ? const Center(child: Text('Chưa có danh mục nào'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(10),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: categoryManager.itemCount,
                          itemBuilder: (ctx, index) {
                            final category = categoryManager.items[index];
                            return CategoryCardItem(
                              id: category.id,
                              name: category.name,
                              imageUrl: category.imageUrl,
                              onTap: () => _showRecipes(category.id),
                            );
                          },
                        ),
                ),
        );
      },
    );
  }
}
