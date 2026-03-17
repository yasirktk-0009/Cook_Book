import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../utils/constants.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

// ─── Favorites Screen ─────────────────────────────────────────────────────────
class FavoritesScreen extends StatefulWidget {
  final List<Recipe> recipes;
  final Future<void> Function(Recipe) onFavoriteToggle;

  const FavoritesScreen({
    super.key,
    required this.recipes,
    required this.onFavoriteToggle,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _sortBy = 'Rating';

  List<Recipe> get _favorites {
    final favs = widget.recipes.where((r) => r.isFavorite).toList();
    switch (_sortBy) {
      case 'Rating':
        favs.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Time':
        favs.sort((a, b) => a.cookTimeMinutes.compareTo(b.cookTimeMinutes));
        break;
      case 'A→Z':
        favs.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    return favs;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = _favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: kPadding),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                items: const [
                  DropdownMenuItem(value: 'Rating', child: Text('Rating ↓')),
                  DropdownMenuItem(value: 'Time', child: Text('Time ↑')),
                  DropdownMenuItem(value: 'A→Z', child: Text('A → Z')),
                ],
                onChanged: (val) => setState(() => _sortBy = val!),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
                dropdownColor: isDark ? kDarkCard : kLightSurface,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 400));
            setState(() {});
          },
          color: kPrimaryColor,
          child: favorites.isEmpty
              ? ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border_rounded,
                              size: 72,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No favorites yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the heart on any recipe to save it here',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(kPadding),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final recipe = favorites[index];
                    return RecipeCard(
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
                    );
                  },
                ),
        ),
      ),
    );
  }
}
