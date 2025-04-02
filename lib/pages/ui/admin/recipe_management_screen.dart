import 'package:ct484_project/constants/colors.dart';
import 'package:ct484_project/models/recipes.model.dart';
import 'package:ct484_project/pages/ui/admin/admin_recipe_detail.dart';

import 'package:ct484_project/pages/ui/recipes/recipe_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecipeManagementScreen extends StatefulWidget {
  static const routeName = '/recipe-management';

  const RecipeManagementScreen({super.key});

  @override
  _RecipeManagementScreenState createState() => _RecipeManagementScreenState();
}

class _RecipeManagementScreenState extends State<RecipeManagementScreen> {
  late Future<void> _fetchRecipesFuture;
  String _selectedStatus = 'pending'; // Trạng thái mặc định

  @override
  void initState() {
    super.initState();
    _fetchRecipesFuture = _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    final recipeManager = Provider.of<RecipeManager>(context, listen: false);
    await recipeManager.fetchRecipes(status: _selectedStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý công thức'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Dropdown để lọc theo trạng thái
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedStatus,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedStatus = newValue;
                    _fetchRecipesFuture = _fetchRecipes();
                  });
                }
              },
              items: <String>['pending', 'approved', 'rejected']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(StringExtension(value).capitalize()),
                );
              }).toList(),
            ),
          ),
          // Danh sách công thức
          Expanded(
            child: FutureBuilder<void>(
              future: _fetchRecipesFuture,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                return Consumer<RecipeManager>(
                  builder: (ctx, recipeManager, child) {
                    final recipes = recipeManager.items;

                    if (recipes.isEmpty) {
                      return Center(
                          child: Text('Danh sách $_selectedStatus rỗng'));
                    }

                    return ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (ctx, index) {
                        final recipe = recipes[index];
                        return ListTile(
                          title: Text(recipe.title),
                          subtitle: Text('Trạng thái: ${recipe.status}'),
                          onTap: () {
                            // Điều hướng đến màn hình chi tiết công thức cho admin
                            Navigator.pushNamed(
                              context,
                              AdminRecipeDetailScreen.routeName,
                              arguments: recipe,
                            ).then((_) {
                              // Làm mới danh sách sau khi quay lại
                              setState(() {
                                _fetchRecipesFuture = _fetchRecipes();
                              });
                            });
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_selectedStatus == 'pending') ...[
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () {
                                    _confirmAction(
                                      context,
                                      'Duyệt công thức',
                                      'Bạn có chắc là muốn duyệt công thức này?',
                                      () async {
                                        await recipeManager.updateRecipeStatus(
                                            recipe.id, 'approved');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('Công thức đã được duyệt')),
                                        );
                                        setState(() {
                                          _fetchRecipesFuture = _fetchRecipes();
                                        });
                                      },
                                    );
                                  },
                                  tooltip: 'Approve',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () {
                                    _confirmAction(
                                      context,
                                      'Không duyệt công thức',
                                      'Bạn có chắc là không duyệt công thức này?',
                                      () async {
                                        await recipeManager.updateRecipeStatus(
                                            recipe.id, 'rejected');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('Công thức đã bị từ chối')),
                                        );
                                        setState(() {
                                          _fetchRecipesFuture = _fetchRecipes();
                                        });
                                      },
                                    );
                                  },
                                  tooltip: 'Reject',
                                ),
                              ],
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _confirmAction(
                                    context,
                                    'Xóa công thức',
                                    'Bạn có chắc là muốn xóa công thức này?',
                                    () async {
                                      await recipeManager
                                          .deleteRecipe(recipe.id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Công thức đã bị xóa')),
                                      );
                                      setState(() {
                                        _fetchRecipesFuture = _fetchRecipes();
                                      });
                                    },
                                  );
                                },
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAction(
    BuildContext context,
    String title,
    String content,
    Future<void> Function() onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Color.fromARGB(255, 39, 140, 49))),
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
                await onConfirm();
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $error')),
                );
              } finally {
                Navigator.pop(context); // Đóng loading dialog
              }
            },
            child: const Text('Chấp nhận', style: TextStyle(color: Color.fromARGB(255, 102, 118, 107))),
          ),
        ],
      ),
    );
  }
}

// Extension để viết hoa chữ cái đầu
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
