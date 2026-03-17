import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';
import '../utils/constants.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

// ─── Category Browser Screen (Bonus) ─────────────────────────────────────────
// Shows a visual grid of all categories with recipe counts.
// Tapping a category card shows a filtered list with a "See All" option.

class CategoryBrowserScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final Future<void> Function(Recipe) onFavoriteToggle;

  const CategoryBrowserScreen({
    super.key,
    required this.recipes,
    required this.onFavoriteToggle,
  });

  static const _categoryMeta = {
    'Breakfast': (
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFFFF8C42),
      description: 'Start your day right',
    ),
    'Lunch': (
      icon: Icons.lunch_dining_rounded,
      color: Color(0xFF4CAF50),
      description: 'Midday fuel',
    ),
    'Dinner': (
      icon: Icons.dinner_dining_rounded,
      color: Color(0xFF6C63FF),
      description: 'Evening favourites',
    ),
    'Dessert': (
      icon: Icons.cake_rounded,
      color: Color(0xFFE91E8C),
      description: 'Sweet treats',
    ),
    'Snack': (
      icon: Icons.fastfood_rounded,
      color: Color(0xFF00BCD4),
      description: 'Quick bites',
    ),
  };

  int _countForCategory(String category) =>
      recipes.where((r) => r.category == category).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Browse Categories',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What are you in the mood for?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: kPadding),

              // ── Masonry-style grid using a custom layout ─────────────────────
              // Two tall cards on the left column, three shorter on the right
              _MasonryGrid(
                categories: _categoryMeta.keys.toList(),
                categoryMeta: _categoryMeta,
                countForCategory: _countForCategory,
                onCategoryTap: (category) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _CategoryDetailScreen(
                        category: category,
                        recipes: recipes
                            .where((r) => r.category == category)
                            .toList(),
                        onFavoriteToggle: onFavoriteToggle,
                        color: _categoryMeta[category]!.color,
                        icon: _categoryMeta[category]!.icon,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Masonry Grid ─────────────────────────────────────────────────────────────
class _MasonryGrid extends StatelessWidget {
  final List<String> categories;
  final Map<String, dynamic> categoryMeta;
  final int Function(String) countForCategory;
  final void Function(String) onCategoryTap;

  const _MasonryGrid({
    required this.categories,
    required this.categoryMeta,
    required this.countForCategory,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    // Layout: 2-column masonry
    // Left col: 0 (tall), 2 (short), 4 (short)
    // Right col: 1 (tall), 3 (short)
    final leftCol = [0, 2, 4].where((i) => i < categories.length).toList();
    final rightCol = [1, 3].where((i) => i < categories.length).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column
        Expanded(
          child: Column(
            children: leftCol.map((i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CategoryCard(
                  category: categories[i],
                  meta: categoryMeta[categories[i]],
                  count: countForCategory(categories[i]),
                  height: i == 0 ? 200 : 150,
                  onTap: () => onCategoryTap(categories[i]),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 12),
        // Right column — offset so it doesn't perfectly align
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              children: rightCol.map((i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CategoryCard(
                    category: categories[i],
                    meta: categoryMeta[categories[i]],
                    count: countForCategory(categories[i]),
                    height: i == 1 ? 200 : 150,
                    onTap: () => onCategoryTap(categories[i]),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Category Card ─────────────────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final String category;
  final dynamic meta;
  final int count;
  final double height;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.meta,
    required this.count,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = meta.color as Color;
    final IconData icon = meta.icon as IconData;
    final String description = meta.description as String;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.85),
              color.withOpacity(0.55),
            ],
          ),
          borderRadius: BorderRadius.circular(kBorderRadius),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative background circle
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: -10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(kPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  // Text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$count recipe${count == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
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

// ─── Category Detail Screen ────────────────────────────────────────────────────
// Shown when user taps a category. Lists recipes + "See All" toggle.
class _CategoryDetailScreen extends StatefulWidget {
  final String category;
  final List<Recipe> recipes;
  final Future<void> Function(Recipe) onFavoriteToggle;
  final Color color;
  final IconData icon;

  const _CategoryDetailScreen({
    required this.category,
    required this.recipes,
    required this.onFavoriteToggle,
    required this.color,
    required this.icon,
  });

  @override
  State<_CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<_CategoryDetailScreen> {
  static const _previewCount = 4;
  bool _showAll = false;

  List<Recipe> get _displayed => _showAll
      ? widget.recipes
      : widget.recipes.take(_previewCount).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: widget.color.withOpacity(0.15),
        foregroundColor: widget.color,
        iconTheme: IconThemeData(color: widget.color),
      ),
      body: SafeArea(
        child: widget.recipes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No ${widget.category} recipes yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(kPadding),
                children: [
                  // ── Header banner ────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(kPadding),
                    margin: const EdgeInsets.only(bottom: kPadding),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.color.withOpacity(0.2),
                          widget.color.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      border: Border.all(
                        color: widget.color.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(widget.icon, color: widget.color, size: 32),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: widget.color,
                              ),
                            ),
                            Text(
                              '${widget.recipes.length} recipe${widget.recipes.length == 1 ? '' : 's'} available',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.color.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Recipe list ───────────────────────────────────────────────
                  ..._displayed.map((recipe) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RecipeCard(
                        recipe: recipe,
                        compact: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailScreen(
                                recipe: recipe,
                                onFavoriteToggle: () async {
                                  await widget.onFavoriteToggle(recipe);
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                        onFavoriteTap: () async {
                          await widget.onFavoriteToggle(recipe);
                          setState(() {});
                        },
                      ),
                    );
                  }),

                  // ── See All button ─────────────────────────────────────────────
                  if (widget.recipes.length > _previewCount)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: OutlinedButton(
                        onPressed: () => setState(() => _showAll = !_showAll),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: widget.color,
                          side: BorderSide(color: widget.color),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _showAll
                              ? 'Show Less'
                              : 'See All ${widget.recipes.length} Recipes',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
