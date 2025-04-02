import 'package:ct484_project/constants/colors.dart';
import 'package:ct484_project/models/recipes.model.dart';
import 'package:ct484_project/pages/ui/recipes/grid_recipe.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_detail_screen.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_manager.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecipeByCategoryScreen extends StatefulWidget {
  static const routeName = '/recipes-by-category';
  final String categoryId;

  const RecipeByCategoryScreen({super.key, required this.categoryId});

  @override
  State<RecipeByCategoryScreen> createState() => _RecipeByCategoryScreenState();
}

class _RecipeByCategoryScreenState extends State<RecipeByCategoryScreen> {
  final _searchController = TextEditingController();
  List<Recipe> _filteredRecipes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _searchController.addListener(_filterRecipes);
  }

  Future<void> _fetchRecipes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final recipeManager = Provider.of<RecipeManager>(context, listen: false);
      // Lấy công thức theo danh mục và chỉ hiển thị công thức đã được phê duyệt
      await recipeManager.fetchRecipes(status: 'approved');
      setState(() {
        _filteredRecipes = recipeManager.items
            .where((recipe) => recipe.category == widget.categoryId)
            .toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải công thức: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterRecipes() {
    final query = _searchController.text.toLowerCase();
    final recipeManager = Provider.of<RecipeManager>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        _filteredRecipes = recipeManager.items
            .where((recipe) => recipe.category == widget.categoryId)
            .toList();
      } else {
        _filteredRecipes = recipeManager.items
            .where((recipe) =>
                recipe.category == widget.categoryId &&
                recipe.title.toLowerCase().contains(query))
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
          _filteredRecipes = recipeManager.items
              .where((recipe) => recipe.category == widget.categoryId)
              .toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Công thức theo danh mục'),
            backgroundColor: AppColors.primary,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                          ? const Center(
                              child: Text('Không tìm thấy công thức'))
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
