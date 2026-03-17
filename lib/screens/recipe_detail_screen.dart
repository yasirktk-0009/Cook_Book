import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';
import '../utils/constants.dart';
import '../widgets/rating_stars.dart';
import '../widgets/badge.dart';
import 'add_edit_recipe_screen.dart';

// ─── Recipe Detail Screen ─────────────────────────────────────────────────────
class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback onFavoriteToggle;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.onFavoriteToggle,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Recipe _recipe;
  // Track checked ingredients
  final Set<int> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Image ───────────────────────────────────────────────
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: _recipe.imageUrl,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 300,
                          color: isDark ? kDarkCard : kLightBorder,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 300,
                          color: isDark ? kDarkCard : kLightBorder,
                          child: const Icon(
                            Icons.restaurant,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      // Gradient
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Back button
                      Positioned(
                        top: 12,
                        left: 12,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      // Favorite button
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            widget.onFavoriteToggle();
                            setState(() {
                              _recipe = _recipe.copyWith(
                                isFavorite: !_recipe.isFavorite,
                              );
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _recipe.isFavorite
                                  ? kPrimaryColor
                                  : Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _recipe.isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(kPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Title ────────────────────────────────────────────────
                        Text(_recipe.title, style: kHeadingStyle),
                        const SizedBox(height: 12),

                        // ── Info Row ─────────────────────────────────────────────
                        Row(
                          children: [
                            RatingStars(
                              rating: _recipe.rating,
                              size: 18,
                              showLabel: true,
                            ),
                            const SizedBox(width: 12),
                            DifficultyBadge(difficulty: _recipe.difficulty),
                            const SizedBox(width: 8),
                            TimeBadge(label: _recipe.formattedTime),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Ingredients ─────────────────────────────────────────
                        const Text('Ingredients', style: kSubheadingStyle),
                        const SizedBox(height: 12),
                        ...List.generate(_recipe.ingredients.length, (index) {
                          final ingredient = _recipe.ingredients[index];
                          final isChecked = _checkedIngredients.contains(index);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isChecked) {
                                  _checkedIngredients.remove(index);
                                } else {
                                  _checkedIngredients.add(index);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: isChecked
                                          ? kPrimaryColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isChecked
                                            ? kPrimaryColor
                                            : Colors.grey.withOpacity(0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isChecked
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      ingredient.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        decoration: isChecked
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: isChecked
                                            ? Colors.grey
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      ingredient.quantity,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),

                        // ── Steps ────────────────────────────────────────────────
                        const Text('Steps', style: kSubheadingStyle),
                        const SizedBox(height: 12),
                        ...List.generate(_recipe.steps.length, (index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(kPadding),
                            decoration: BoxDecoration(
                              color: isDark ? kDarkCard : kLightCard,
                              borderRadius:
                                  BorderRadius.circular(kBorderRadius),
                              border: Border.all(
                                color: isDark ? kDarkBorder : kLightBorder,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _recipe.steps[index],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Extra space for sticky bar
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Sticky Bottom Bar ──────────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: kPadding,
                  vertical: kPaddingSmall,
                ),
                decoration: BoxDecoration(
                  color: isDark ? kDarkBg : kLightBg,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? kDarkBorder : kLightBorder,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🍳 Let\'s cook! Follow the steps above.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.restaurant_rounded, size: 18),
                        label: const Text('Start Cooking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final updated = await Navigator.push<Recipe>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddEditRecipeScreen(recipe: _recipe),
                            ),
                          );
                          if (updated != null) {
                            setState(() => _recipe = updated);
                          }
                        },
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimaryColor,
                          side: const BorderSide(color: kPrimaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
