import 'package:ct484_project/models/recipes.model.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_item.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_manager.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ct484_project/constants/colors.dart'; // Adjust the import path as necessary

class FavoriteScreen extends StatelessWidget {
  static const routeName = '/favorites';

  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Công thức yêu thích'),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<List<Recipe>>(
        future: Provider.of<RecipeManager>(context, listen: false)
            .fetchFavoriteRecipes(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có công thức yêu thích nào'));
          }

          final favoriteRecipes = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: favoriteRecipes.length,
            itemBuilder: (ctx, index) {
              final recipe = favoriteRecipes[index];
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
