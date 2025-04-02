import 'package:ct484_project/models/recipes.model.dart';
import 'package:ct484_project/pages/ui/category/category_manager.dart';
import 'package:ct484_project/pages/ui/profile/profile_manager.dart';
import 'package:ct484_project/pages/ui/recipes/add_recipe.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_detail_screen.dart';
import 'package:ct484_project/pages/ui/recipes/recipe_manager.dart';
import 'package:ct484_project/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ct484_project/pages/navigation_provider.dart';
import 'package:ct484_project/pages/ui/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Check if onboarding has been completed
  Future<bool> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 42, 112, 202),
      secondary: Colors.deepOrange,
      surface: Colors.white,
      surfaceTint: Colors.grey[200],
    );

    final themeData = ThemeData(
      fontFamily: 'Lato',
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shadowColor: colorScheme.shadow,
        elevation: 4,
      ),
      dialogTheme: DialogTheme(
        titleTextStyle: TextStyle(
          fontSize: 24,
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          fontSize: 20,
          color: colorScheme.onSurface,
        ),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ChangeNotifierProvider(create: (context) => CategoryManager()),
        ChangeNotifierProvider(create: (context) => RecipeManager()),
        ChangeNotifierProvider(create: (context) => ProfileManager()),
      ],
      child: Consumer<AuthService>(
        builder: (ctx, authService, child) {
          return MaterialApp(
            title: 'Food Recipes',
            debugShowCheckedModeBanner: false,
            theme: themeData,
            home: FutureBuilder<bool>(
              future: _checkOnboardingStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SafeArea(child: SplashScreen());
                }
                if (snapshot.hasData && !snapshot.data!) {
                  // Show onboarding if not completed
                  return const SafeArea(child: OnboardingScreen());
                }
                // Otherwise, proceed with the existing logic
                return authService.currentUser != null
                    ? SafeArea(
                        child: authService.isAdmin
                            ? const AdminDashboard()
                            : const MainScreen(),
                      )
                    : FutureBuilder(
                        future: authService.getUserFromStore(),
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SafeArea(child: SplashScreen());
                          }
                          if (snapshot.hasData && snapshot.data != null) {
                            return SafeArea(
                              child: authService.isAdmin
                                  ? const AdminDashboard()
                                  : const MainScreen(),
                            );
                          }
                          return const SafeArea(child: AuthScreen());
                        },
                      );
              },
            ),
            routes: {
              MainScreen.routeName: (context) =>
                  const SafeArea(child: MainScreen()),
              OtherScreen.routeName: (ctx) =>
                  const SafeArea(child: OtherScreen()),
              ListRecipesOverScreen.routeName: (ctx) =>
                  const SafeArea(child: ListRecipesOverScreen()),
              CategoryScreen.routeName: (ctx) =>
                  const SafeArea(child: CategoryScreen()),
              AddRecipeScreen.routeName: (context) =>
                  const SafeArea(child: AddRecipeScreen()),
              RecipeDetailScreen.routeName: (context) => RecipeDetailScreen(
                    recipe:
                        ModalRoute.of(context)!.settings.arguments as Recipe,
                  ),
              AdminDashboard.routeName: (context) =>
                  const SafeArea(child: AdminDashboard()),
              UserManagementScreen.routeName: (context) =>
                  const SafeArea(child: UserManagementScreen()),
              RecipeManagementScreen.routeName: (context) =>
                  const SafeArea(child: RecipeManagementScreen()),
              AuthScreen.routeName: (context) =>
                  const SafeArea(child: AuthScreen()),
              AdminRecipeDetailScreen.routeName: (context) =>
                  const SafeArea(child: AdminRecipeDetailScreen()),
              OnboardingScreen.routeName: (context) =>
                  const SafeArea(child: OnboardingScreen()), // Add this route
            },
            onGenerateRoute: (settings) {
              if (settings.name == RecipeByCategoryScreen.routeName) {
                final categoryId = settings.arguments as String?;
                print('categoryId from arguments: $categoryId');
                if (categoryId == null || categoryId.isEmpty) {
                  return MaterialPageRoute(
                    builder: (ctx) => const SafeArea(
                      child: Scaffold(
                        body: Center(
                          child: Text('categoryId không hợp lệ'),
                        ),
                      ),
                    ),
                  );
                }
                return MaterialPageRoute(
                  settings: settings,
                  builder: (ctx) {
                    return SafeArea(
                      child: RecipeByCategoryScreen(categoryId: categoryId),
                    );
                  },
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
