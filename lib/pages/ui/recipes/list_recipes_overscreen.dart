import 'package:ct484_project/constants/colors.dart';
import 'package:ct484_project/models/recipes.model.dart';
import 'package:ct484_project/pages/ui/recipes/add_recipe.dart';
import 'package:ct484_project/pages/ui/recipes/grid_recipe.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_detail_screen.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListRecipesOverScreen extends StatefulWidget {
  static const routeName = '/recipes';
  const ListRecipesOverScreen({super.key});

  @override
  State<ListRecipesOverScreen> createState() => _ListRecipesOverScreenState();
}

class _ListRecipesOverScreenState extends State<ListRecipesOverScreen> {
  final _searchController = TextEditingController();
  List<Recipe> _filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    final recipeManager = Provider.of<RecipeManager>(context, listen: false);
    // Chỉ lấy công thức đã được phê duyệt
    recipeManager.fetchRecipes(status: 'approved');
    recipeManager.fetchCategories();
    _searchController.addListener(_filterRecipes);
  }

  void _filterRecipes() {
    final query = _searchController.text.toLowerCase();
    final recipeManager = Provider.of<RecipeManager>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        _filteredRecipes = recipeManager.items;
      } else {
        _filteredRecipes = recipeManager.items
            .where((recipe) => recipe.title.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeManager>(
      builder: (ctx, recipeManager, child) {
        // Cập nhật _filteredRecipes khi danh sách công thức thay đổi
        if (_searchController.text.isEmpty) {
          _filteredRecipes = recipeManager.items;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Công thức nấu ăn (${_filteredRecipes.length})', // Hiển thị số lượng món
            ),
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).pushNamed(AddRecipeScreen.routeName);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm công thức...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
              Expanded(
                child: _filteredRecipes.isEmpty
                    ? const Center(child: Text('Không tìm thấy công thức'))
                    : GridRecipes(
                        recipes: _filteredRecipes,
                        onTap: (recipe) {
                          Navigator.pushNamed(
                            context,
                            RecipeDetailScreen.routeName,
                            arguments: recipe,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
