
import 'package:ct484_project/models/recipes.model.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_item.dart';
import 'package:flutter/material.dart';

class GridRecipes extends StatelessWidget {
  final List<Recipe> recipes;
  final Function(Recipe) onTap; // Add onTap callback

  const GridRecipes({
    super.key,
    required this.recipes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 items per row
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.75, // Adjust the aspect ratio for better layout
      ),
      itemCount: recipes.length,
      itemBuilder: (ctx, index) {
        final recipe = recipes[index];
        return RecipeItem(
          recipe: recipe,
          categoryName: recipe.categoryName,
          // Use the onTap callback instead of GestureDetector in RecipeItem
        );
      },
    );
  }
}
