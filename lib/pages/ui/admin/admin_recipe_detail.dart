import 'package:ct484_project/constants/colors.dart';
import 'package:ct484_project/models/recipes.model.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminRecipeDetailScreen extends StatelessWidget {
  static const routeName = '/admin-recipe-detail';

  const AdminRecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy recipe từ arguments
    final recipe = ModalRoute.of(context)!.settings.arguments as Recipe;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
         backgroundColor: AppColors.primary,
        actions: [
          // Nút xóa công thức
          IconButton(
            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () {
              _confirmAction(
                context,
                'Xóa công thức',
                'Bạn có chắc là muốn xóa công thức này',
                () async {
                  final recipeManager =
                      Provider.of<RecipeManager>(context, listen: false);
                  await recipeManager.deleteRecipe(recipe.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recipe deleted')),
                  );
                  Navigator.pop(context); // Quay lại sau khi xóa
                },
              );
            },
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh công thức
              if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    recipe.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    ),
                  ),
                )
              else
                Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50),
                ),
              const SizedBox(height: 16),

              // Tiêu đề công thức
              Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Trạng thái công thức
              Text(
                'Status: ${recipe.status.capitalize()}',
                style: TextStyle(
                  fontSize: 16,
                  color: recipe.status == 'approved'
                      ? Colors.green
                      : recipe.status == 'rejected'
                          ? Colors.red
                          : Colors.orange,
                ),
              ),
              const SizedBox(height: 8),

              // Người tạo và danh mục
              Text(
                'Created by: ${recipe.userName}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Category: ${recipe.categoryName}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Mô tả
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                recipe.description ?? 'No description available.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Nguyên liệu
              const Text(
                'Ingredients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              recipe.ingredients.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipe.ingredients
                          .asMap()
                          .entries
                          .map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  '${entry.key + 1}. ${entry.value}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ))
                          .toList(),
                    )
                  : const Text(
                      'No ingredients listed.',
                      style: TextStyle(fontSize: 16),
                    ),
              const SizedBox(height: 16),

              // Các bước thực hiện
              const Text(
                'Steps',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              recipe.steps.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipe.steps
                          .asMap()
                          .entries
                          .map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  'Step ${entry.key + 1}: ${entry.value}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ))
                          .toList(),
                    )
                  : const Text(
                      'No steps provided.',
                      style: TextStyle(fontSize: 16),
                    ),
              const SizedBox(height: 16),

              // Nút hành động (Approve/Reject) nếu status là pending
              if (recipe.status == 'pending') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _confirmAction(
                          context,
                          'Duyệt công thức',
                          'Bạn có chắc là muốn duyệt công thức này',
                          () async {
                            final recipeManager = Provider.of<RecipeManager>(
                                context,
                                listen: false);
                            await recipeManager.updateRecipeStatus(
                                recipe.id, 'approved');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Recipe approved')),
                            );
                            Navigator.pop(
                                context); // Quay lại sau khi phê duyệt
                          },
                        );
                      },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Approve', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _confirmAction(
                          context,
                          'Từ chối công thức',
                          'Bạn có chắc là muốn từ chối công thức này',
                          () async {
                            final recipeManager = Provider.of<RecipeManager>(
                                context,
                                listen: false);
                            await recipeManager.updateRecipeStatus(
                                recipe.id, 'rejected');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Recipe rejected')),
                            );
                            Navigator.pop(context); // Quay lại sau khi từ chối
                          },
                        );
                      },
                      icon: const Icon(Icons.close, color: Colors.white,),
                      label: const Text('Reject', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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
            child: const Text('Hủy', style: TextStyle(color: Color.fromARGB(255, 27, 134, 41))),
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
            child: const Text('Chấp nhận', style: TextStyle(color: Color.fromARGB(255, 128, 113, 113))),
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
