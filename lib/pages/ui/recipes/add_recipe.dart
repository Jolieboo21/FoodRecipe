import 'package:ct484_project/constants/colors.dart';
import 'package:ct484_project/models/categories.model.dart';
import 'package:ct484_project/models/recipes.model.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_manager.dart';

import 'package:ct484_project/services/auth_service.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddRecipeScreen extends StatefulWidget {
  static const routeName = '/add-recipe';
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _picker = ImagePicker();
  File? _coverPhoto;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _duration = 30;
  List<String> _ingredients = [];
  List<String> _steps = [];
  bool _isSuccess = false;
  bool _isLoading = false;
  final _ingredientController = TextEditingController();
  final _stepController = TextEditingController();
  String? _selectedCategoryId;
  late Future<void> _fetchCategoriesFuture;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverPhoto = File(pickedFile.path);
      });
    }
  }

  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text);
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addStep() {
    if (_stepController.text.isNotEmpty) {
      setState(() {
        _steps.add(_stepController.text);
        _stepController.clear();
      });
    }
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  void _resetForm() {
    setState(() {
      _isSuccess = false;
      _coverPhoto = null;
      _titleController.clear();
      _descriptionController.clear();
      _duration = 30;
      _ingredients.clear();
      _steps.clear();
      _selectedCategoryId = null;
    });
  }

  Future<void> _submitRecipe() async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _ingredients.isNotEmpty &&
        _steps.isNotEmpty &&
        _selectedCategoryId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final currentUser = await authService.getUserFromStore();

        if (currentUser == null) {
          throw Exception('Bạn cần đăng nhập để thêm công thức');
        }

        final recipeManager =
            Provider.of<RecipeManager>(context, listen: false);
        if (recipeManager.categories.isEmpty) {
          throw Exception('Không thể tải danh mục. Vui lòng thử lại sau.');
        }

        // Find the selected category
        final selectedCategory = recipeManager.categories.firstWhere(
          (cat) => cat.id == _selectedCategoryId,
          orElse: () {
            // Instead of throwing, return a dummy CategoryModel to satisfy the type
            // We will handle the error below
            return CategoryModel(id: '', name: '');
          },
        );

        // Check if the category was actually found
        if (selectedCategory.id.isEmpty) {
          throw Exception('Danh mục không tồn tại');
        }

        final newRecipe = Recipe(
          id: '',
          title: _titleController.text,
          description: _descriptionController.text,
          featuredImage: _coverPhoto,
          ingredients: _ingredients,
          steps: _steps,
          category: _selectedCategoryId!,
          categoryName: selectedCategory.name,
          duration: _duration,
          userId: currentUser.id,
          userName: currentUser.name,
          userAvatarUrl: currentUser.avatarUrl ?? '',
          likes: 0,
        );

        await recipeManager.addRecipe(newRecipe);

        setState(() {
          _isSuccess = true;
          _isLoading = false;
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the future to fetch categories
    _fetchCategoriesFuture =
        Provider.of<RecipeManager>(context, listen: false).fetchCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm công thức'),
        backgroundColor: AppColors.primary,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: _fetchCategoriesFuture,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: _isSuccess
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/successful.png',
                                height: 100,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Upload Success',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Nội dung đã được thêm, hãy chờ quản trị viên duyệt nhé',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Ingredients:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ..._ingredients
                                  .map((ingredient) => Text('- $ingredient'))
                                  .toList(),
                              const SizedBox(height: 16),
                              const Text(
                                'Steps:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ..._steps
                                  .asMap()
                                  .entries
                                  .map((entry) =>
                                      Text('${entry.key + 1}. ${entry.value}'))
                                  .toList(),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/home',
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Trở về trang chủ'),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _resetForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Thêm công thức mới'),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step 1: Cover Photo, Food Name, Description, Duration, Category
                            const Text(
                              'Phần 1',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: _coverPhoto != null
                                      ? Image.file(_coverPhoto!,
                                          fit: BoxFit.cover,
                                          width: double.infinity)
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.camera_alt,
                                                size: 40, color: Colors.grey),
                                            SizedBox(height: 10),
                                            Text(
                                              'Thêm ảnh minh họa',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Tên món ăn',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Chú thích - Khẩu phần',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            const Text('Thời gian nấu (phút)'),
                            Slider(
                              value: _duration.toDouble(),
                              min: 0,
                              max: 120,
                              divisions: 120,
                              label: _duration.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _duration = value.round();
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                            const SizedBox(height: 16),
                            const Text('Loại'),
                            Consumer<RecipeManager>(
                              builder: (ctx, recipeManager, child) {
                                if (recipeManager.categories.isEmpty) {
                                  return const Text('No categories available');
                                }
                                return DropdownButton<String>(
                                  value: _selectedCategoryId,
                                  hint: const Text('Chọn loại'),
                                  isExpanded: true,
                                  items: [
                                    ...recipeManager.categories.map(
                                        (category) => DropdownMenuItem<String>(
                                              value: category.id,
                                              child: Text(category.name),
                                            )),
                                    const DropdownMenuItem<String>(
                                      value: 'add_new',
                                      child: Text('Thêm loại mới', style: TextStyle(color: Color.fromARGB(255, 96, 139, 101)),),
                                    ),
                                  ],
                                  onChanged: (value) async {
                                    if (value == 'add_new') {
                                      final newCategoryName =
                                          await showDialog<String>(
                                        context: context,
                                        builder: (ctx) {
                                          final _newCategoryController =
                                              TextEditingController();
                                          return AlertDialog(
                                            title:
                                                const Text('Thêm loai mới'),
                                            content: TextField(
                                              controller:
                                                  _newCategoryController,
                                              decoration: const InputDecoration(
                                                  hintText:
                                                      'Enter category name'),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('Hủy bỏ'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  if (_newCategoryController
                                                      .text.isNotEmpty) {
                                                    Navigator.pop(
                                                        ctx,
                                                        _newCategoryController
                                                            .text);
                                                  }
                                                },
                                                child: const Text('Thêm'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (newCategoryName != null &&
                                          newCategoryName.isNotEmpty) {
                                        final newCategory = await recipeManager
                                            .addCategory(newCategoryName, null);
                                        if (newCategory != null) {
                                          setState(() {
                                            _selectedCategoryId =
                                                newCategory.id;
                                          });
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        _selectedCategoryId = value;
                                      });
                                    }
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Step 2: Ingredients and Steps
                            const Text(
                              'Phần 2',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            const Text('Nguyên liệu'),
                            ..._ingredients.asMap().entries.map((entry) {
                              final index = entry.key;
                              final ingredient = entry.value;
                              return ListTile(
                                leading: const Icon(Icons.check_circle,
                                    color: AppColors.primary),
                                title: Text(ingredient),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _removeIngredient(index),
                                ),
                              );
                            }),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary, // Màu nền
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Thêm nguyên liệu'),
                                    content: TextField(
                                      controller: _ingredientController,
                                      decoration: const InputDecoration(
                                          hintText: 'Điền nguyên liệu...'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _addIngredient();
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text('Thêm'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('+ Nguyên liệu',
                                style: TextStyle(color: Colors.white),
                              ),
                              
                            ),
                            const SizedBox(height: 16),
                            const Text('Các bước'),
                            ..._steps.asMap().entries.map((entry) {
                              final index = entry.key;
                              final step = entry.value;
                              return ListTile(
                                leading: Text('${index + 1}.',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                title: Text(step),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _removeStep(index),
                                ),
                              );
                            }),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary, 
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Thêm bước'),
                                    content: TextField(
                                      controller: _stepController,
                                      decoration: const InputDecoration(
                                          hintText: 'Điền bước...'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _addStep();
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text('Thêm'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('+ Bước', style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _submitRecipe,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text('Submit'),
                            ),
                          ],
                        ),
                );
              },
            ),
    );
  }
}
