import 'package:ct484_project/models/recipes.model.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_detail_screen.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class RecipeItem extends StatefulWidget {
  final Recipe recipe;
  final String categoryName;

  const RecipeItem({
    super.key,
    required this.recipe,
    required this.categoryName,
  });

  @override
  State<RecipeItem> createState() => _RecipeItemState();
}

class _RecipeItemState extends State<RecipeItem> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.recipe.isFavorite; // Khởi tạo giá trị ban đầu
  }

  Future<void> _toggleFavorite() async {
    // Cập nhật trạng thái giao diện ngay lập tức, nhưng chỉ khi widget còn mounted
    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }

    try {
      final recipeManager = Provider.of<RecipeManager>(context, listen: false);
      if (_isFavorite) {
        await recipeManager.addToFavorites(widget.recipe.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã thêm vào yêu thích')),
          );
        }
      } else {
        await recipeManager.removeFromFavorites(widget.recipe.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa khỏi yêu thích')),
          );
        }
      }
    } catch (e) {
      // Chỉ gọi setState nếu widget còn mounted
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite; // Hoàn tác thay đổi giao diện
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = widget.recipe.userAvatarUrl != null &&
        widget.recipe.userAvatarUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          RecipeDetailScreen.routeName,
          arguments: widget.recipe,
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: widget.recipe.imageUrl != null &&
                          widget.recipe.imageUrl!.isNotEmpty
                      ? Image.network(
                          widget.recipe.imageUrl!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50),
                          ),
                        )
                      : Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 50),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleFavorite, // Gọi hàm toggle
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipe.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.categoryName} • ${widget.recipe.duration} mins',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: hasAvatar
                            ? NetworkImage(widget.recipe.userAvatarUrl!)
                            : null,
                        backgroundColor: Colors.grey[300],
                        child: hasAvatar
                            ? null
                            : const Icon(Icons.person, size: 10),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.recipe.userName,
                          style: const TextStyle(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
