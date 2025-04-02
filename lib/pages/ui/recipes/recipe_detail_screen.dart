import 'package:ct484_project/constants/colors.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ct484_project/models/recipes.model.dart';

class RecipeDetailScreen extends StatefulWidget {
  static const routeName = '/recipe-detail';
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late int _likes;
  bool _hasLiked = false;

  @override
  void initState() {
    super.initState();
    _likes = widget.recipe.likes;
    // Giả sử bạn có cách kiểm tra người dùng đã thích chưa (tạm thời để false)
    _hasLiked = false; // Sẽ cập nhật sau nếu cần kiểm tra từ server
  }

  Future<void> _likeRecipe(RecipeManager recipeManager) async {
    if (_hasLiked) return; // Không làm gì nếu đã thích

    try {
      final success = await recipeManager.likeRecipe(widget.recipe.id);
      if (success && mounted) {
        setState(() {
          _likes += 1;
          _hasLiked = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi thích công thức')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Thêm công thức vào danh sách đã xem (từ yêu cầu trước)
    Provider.of<RecipeManager>(context, listen: false)
        .addToRecentlyViewed(widget.recipe.id);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: widget.recipe.imageUrl != null &&
                    widget.recipe.imageUrl!.isNotEmpty
                ? Image.network(
                    widget.recipe.imageUrl!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    ),
                  )
                : Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 250,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.recipe.categoryName} • ${widget.recipe.duration} mins',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: widget.recipe.userAvatarUrl !=
                                          null &&
                                      widget.recipe.userAvatarUrl!.isNotEmpty
                                  ? NetworkImage(widget.recipe.userAvatarUrl!)
                                  : null,
                              backgroundColor: Colors.grey[300],
                              child: widget.recipe.userAvatarUrl == null ||
                                      widget.recipe.userAvatarUrl!.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.recipe.userName,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Consumer<RecipeManager>(
                          builder: (ctx, recipeManager, child) => Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _hasLiked
                                      ? Icons.thumb_up_alt
                                      : Icons.thumb_up_alt_outlined,
                                  color: AppColors.primary,
                                ),
                                onPressed: () => _likeRecipe(recipeManager),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_likes Likes',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.recipe.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ingredients',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...widget.recipe.ingredients.map((ingredient) => Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppColors.primary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(ingredient)),
                          ],
                        )),
                    const SizedBox(height: 16),
                    const Text(
                      'Steps',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...widget.recipe.steps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(child: Text(step)),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
