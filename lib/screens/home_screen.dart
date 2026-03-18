import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';
import '../utils/constants.dart';
import '../utils/sample_data.dart';
import '../services/preferences_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/chip_filter.dart';
import '../widgets/section_header.dart';
import '../widgets/rating_stars.dart';
import '../widgets/badge.dart';
import 'recipe_detail_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'add_edit_recipe_screen.dart';
import 'category_browser_screen.dart';

// ─── Home Screen ──────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDark,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _prefsService = PreferencesService();
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isCompact = false;
  bool _isRefreshing = false;
  final _searchController = TextEditingController();

  static const _categories = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Dessert', 'Snack'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final recipes = getSampleRecipes();
    final favoriteIds = await _prefsService.getFavoriteIds();
    final compact = await _prefsService.getCompactCards();
    final defaultCat = await _prefsService.getDefaultCategory();

    for (final r in recipes) {
      r.isFavorite = favoriteIds.contains(r.id);
    }

    setState(() {
      _allRecipes = recipes;
      _isCompact = compact;
      _selectedCategory = defaultCat;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredRecipes = _allRecipes.where((r) {
        final matchesCategory =
            _selectedCategory == 'All' || r.category == _selectedCategory;
        final matchesSearch =
            _searchQuery.isEmpty ||
            r.title.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    setState(() {
      recipe.isFavorite = !recipe.isFavorite;
    });
    final favoriteIds =
        _allRecipes.where((r) => r.isFavorite).map((r) => r.id).toList();
    await _prefsService.saveFavoriteIds(favoriteIds);
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    await _loadData();
    setState(() => _isRefreshing = false);
  }

  List<Recipe> get _featuredRecipes =>
      _allRecipes.where((r) => r.rating >= 4.5).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          kAppName,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              // Focus the search field
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FavoritesScreen(
                  recipes: _allRecipes,
                  onFavoriteToggle: _toggleFavorite,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    onThemeToggle: widget.onThemeToggle,
                    isDark: isDark,
                  ),
                ),
              );
              _loadData(); // Reload in case settings changed
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        
        onPressed: () async {
          final newRecipe = await Navigator.push<Recipe>(
            context,
            MaterialPageRoute(builder: (_) => const AddEditRecipeScreen()),
          );
          if (newRecipe != null) {
            setState(() {
              _allRecipes.insert(0, newRecipe);
              _applyFilters();
            });
          }
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: kPrimaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: kPadding),

                // ── Search Bar ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kPadding),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      _searchQuery = val;
                      _applyFilters();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search recipes...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _searchQuery = '';
                                _applyFilters();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? kDarkCard : kLightCard,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: kPadding),

                // ── Category Chips ─────────────────────────────────────────────
                ChipFilter(
                  categories: _categories,
                  selected: _selectedCategory,
                  onSelected: (cat) {
                    _selectedCategory = cat;
                    _applyFilters();
                  },
                ),
                const SizedBox(height: kPaddingLarge),

                // ── Featured Carousel ──────────────────────────────────────────
                if (_featuredRecipes.isNotEmpty) ...[
                  const SectionHeader(title: 'Featured'),
                  const SizedBox(height: kPaddingSmall),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: kPadding),
                      itemCount: _featuredRecipes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final recipe = _featuredRecipes[index];
                        return GestureDetector(
                          onTap: () => _navigateToDetail(recipe),
                          child: SizedBox(
                            width: 300,
                            child: _FeaturedCard(
                              recipe: recipe,
                              onFavoriteTap: () => _toggleFavorite(recipe),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: kPaddingLarge),
                ],

                // ── Browse Categories Banner ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kPadding),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryBrowserScreen(
                          recipes: _allRecipes,
                          onFavoriteToggle: _toggleFavorite,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kPadding,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPrimaryColor, kPrimaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.grid_view_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Browse by Category',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Explore Breakfast, Lunch, Dinner & more',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: kPadding),

                // ── Popular Recipes Grid ───────────────────────────────────────
                SectionHeader(
                  title: 'Popular Recipes',
                  actionLabel: _isCompact ? 'Grid view' : 'List view',
                  onAction: () {
                    setState(() => _isCompact = !_isCompact);
                    _prefsService.setCompactCards(_isCompact);
                  },
                ),
                const SizedBox(height: kPaddingSmall),

                // Empty state
                if (_filteredRecipes.isEmpty)
                  _EmptyState(query: _searchQuery)
                else if (_isCompact)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: kPadding),
                    itemCount: _filteredRecipes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final recipe = _filteredRecipes[index];
                      return RecipeCard(
                        recipe: recipe,
                        compact: true,
                        onTap: () => _navigateToDetail(recipe),
                        onFavoriteTap: () => _toggleFavorite(recipe),
                      );
                    },
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: kPadding),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _filteredRecipes[index];
                      return RecipeCard(
                        recipe: recipe,
                        onTap: () => _navigateToDetail(recipe),
                        onFavoriteTap: () => _toggleFavorite(recipe),
                      );
                    },
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(Recipe recipe) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailScreen(
          recipe: recipe,
          onFavoriteToggle: () => _toggleFavorite(recipe),
        ),
      ),
    );
    setState(() {}); // Refresh in case favorite changed
  }
}

// ─── Featured Card ─────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onFavoriteTap;

  const _FeaturedCard({required this.recipe, required this.onFavoriteTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kBorderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: recipe.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: kDarkCard),
            errorWidget: (_, __, ___) => Container(
              color: kDarkCard,
              child: const Icon(Icons.restaurant, color: Colors.grey),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          // Info
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RatingStars(rating: recipe.rating, size: 16),
                    TimeBadge(label: recipe.formattedTime),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String query;

  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: kPadding),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              query.isEmpty ? 'No recipes found' : 'No results for "$query"',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search or category',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}
