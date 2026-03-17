import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';
import '../utils/constants.dart';
import 'rating_stars.dart';
import 'badge.dart';

// ─── Recipe Card Widget ────────────────────────────────────────────────────────
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onFavoriteTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompactCard(context);
    return _buildFullCard(context);
  }

  Widget _buildFullCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? kDarkCard : kLightSurface,
          borderRadius: BorderRadius.circular(kBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(kBorderRadius),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: recipe.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 140,
                      color: isDark ? kDarkBorder : kLightBorder,
                      child: const Center(
                        child: Icon(Icons.restaurant, color: Colors.grey),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 140,
                      color: isDark ? kDarkBorder : kLightBorder,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // Favorite button overlay
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: recipe.isFavorite
                            ? kPrimaryColor
                            : Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        recipe.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ── Info ────────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(kPaddingSmall + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RatingStars(rating: recipe.rating, size: 14),
                      TimeBadge(label: recipe.formattedTime),
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

  Widget _buildCompactCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? kDarkCard : kLightSurface,
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(kBorderRadiusSmall),
              ),
              child: CachedNetworkImage(
                imageUrl: recipe.imageUrl,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 70,
                  width: 70,
                  color: isDark ? kDarkBorder : kLightBorder,
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 70,
                  width: 70,
                  color: isDark ? kDarkBorder : kLightBorder,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.formattedTime} · Rating: ${recipe.rating} stars',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: onFavoriteTap,
              icon: Icon(
                recipe.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: recipe.isFavorite ? kPrimaryColor : Colors.grey,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
