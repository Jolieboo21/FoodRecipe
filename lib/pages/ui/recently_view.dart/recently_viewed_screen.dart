import 'package:ct484_project/constants/colors.dart';
import 'package:ct484_project/models/recipes.model.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_item.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_manager.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecentlyViewedScreen extends StatelessWidget {
  static const routeName = '/recently-viewed';

  const RecentlyViewedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đã xem gần đây'),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<List<Recipe>>(
        future: Provider.of<RecipeManager>(context, listen: false)
            .fetchRecentlyViewedRecipes(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Chưa có món ăn nào đươc xem'));
          }

          final recentlyViewedRecipes = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: recentlyViewedRecipes.length,
            itemBuilder: (ctx, index) {
              final recipe = recentlyViewedRecipes[index];
              return RecipeItem(
                recipe: recipe,
                categoryName: recipe.categoryName,
              );
            },
          );
        },
      ),
    );
  }
}
