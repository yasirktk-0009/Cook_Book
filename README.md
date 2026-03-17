# 📖 CookBook — Flutter Recipe App

A beginner-level Flutter application built for **Group A** as part of the project curriculum.
Clean, modern design with dark/light themes, local persistence, and full CRUD recipe management.

---

## ✨ Features

| Screen | Features |
|---|---|
| **Home** | AppBar, search bar (real-time filter), category chips, featured carousel, popular grid/list, empty state, pull-to-refresh, FAB to add recipe |
| **Recipe Detail** | Hero image, back/favorite overlay, info row (rating, difficulty, time), ingredient checkboxes, numbered step cards, sticky Start Cooking / Edit bar |
| **Favorites** | Sorted list (Rating / Time / A→Z), unfavorite toggle, empty state, pull-to-refresh |
| **Settings** | Dark/Light toggle, compact card mode + live preview, default category picker (bottom sheet), cooking notifications, auto sync, clear favorites, about section |
| **Add / Edit Recipe** *(Bonus)* | Validation banner, difficulty segmented control, rating slider, dynamic ingredients + steps, save/cancel |
| **Category Browser** *(Bonus)* | Masonry-style grid of categories, recipe count badges, tap-through to filtered list with See All toggle |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0` ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Dart `>=3.0.0`
- Android Studio or VS Code with Flutter extension

### Setup

```bash
# 1. Clone / unzip the project
cd cookbook_app

# 2. Install dependencies
flutter pub get

# 3. Run on connected device or emulator
flutter run
```

### Build Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry point, theme management
├── models/
│   └── recipe.dart                  # Recipe & Ingredient data models
├── screens/
│   ├── home_screen.dart             # Main screen with search, grid, carousel
│   ├── recipe_detail_screen.dart    # Full recipe view with steps
│   ├── favorites_screen.dart        # Saved favorites with sort
│   ├── settings_screen.dart         # App settings & preferences
│   ├── add_edit_recipe_screen.dart  # Add/Edit form (Bonus)
│   └── category_browser_screen.dart # Category grid browser (Bonus)
├── widgets/
│   ├── recipe_card.dart             # Full & compact recipe card
│   ├── rating_stars.dart            # Star rating display
│   ├── badge.dart                   # Time & Difficulty badges
│   ├── chip_filter.dart             # Category filter chips
│   └── section_header.dart         # Section title + action button
├── utils/
│   ├── constants.dart               # Colors, text styles, dimensions
│   └── sample_data.dart             # 8 seed recipes
└── services/
    └── preferences_service.dart     # SharedPreferences wrapper
```

---

## 📦 Dependencies

```yaml
shared_preferences: ^2.2.2     # Local storage (theme, favorites, settings)
cached_network_image: ^3.3.1   # Smooth async image loading with cache
flutter_rating_bar: ^4.0.1     # Star rating widget
cupertino_icons: ^1.0.6        # iOS-style icons
```

---

## 🎨 Design System

All design tokens live in `lib/utils/constants.dart`:

```dart
// Primary
const kPrimaryColor = Color(0xFF6C63FF);  // Purple
const kAccentOrange = Color(0xFFFF8C42);  // Orange (time badges)
const kStarColor    = Color(0xFFFFB800);  // Gold (ratings)

// Dark mode surfaces
const kDarkBg      = Color(0xFF0D0D0D);
const kDarkSurface = Color(0xFF1A1A2E);
const kDarkCard    = Color(0xFF16213E);

// Light mode surfaces
const kLightBg      = Color(0xFFF8F9FE);
const kLightSurface = Color(0xFFFFFFFF);
const kLightCard    = Color(0xFFF0F1F9);
```

---

## 💾 Data Persistence

Uses `shared_preferences` for small local data:

| Key | Type | Description |
|---|---|---|
| `isDarkTheme` | bool | Current theme mode |
| `isCompactCards` | bool | Compact vs. grid layout |
| `defaultCategory` | String | Default filter category |
| `favoriteIds` | List\<String\> | IDs of favourited recipes |
| `cookingNotifications` | bool | Notification preference |
| `autoSync` | bool | Auto-sync toggle |

---

## 🧭 Navigation

```
HomeScreen
├── → RecipeDetailScreen (tap recipe card)
│       └── → AddEditRecipeScreen (tap Edit)
├── → FavoritesScreen (AppBar heart icon)
│       └── → RecipeDetailScreen
├── → SettingsScreen (AppBar gear icon)
├── → CategoryBrowserScreen (Browse banner)
│       └── → RecipeDetailScreen
└── → AddEditRecipeScreen (FAB +)
```

Navigation uses `Navigator.push` with `MaterialPageRoute`:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
);
```

---

## 🧩 Widgets Used

`Scaffold` · `AppBar` · `SafeArea` · `SingleChildScrollView` · `ListView` · `GridView` ·
`Container` · `Card` · `SizedBox` · `Padding` · `Text` · `Icon` · `Image.network` ·
`TextField` · `ElevatedButton` · `OutlinedButton` · `TextButton` · `IconButton` ·
`DropdownButton` · `Slider` · `Switch` · `GestureDetector` · `InkWell` ·
`showModalBottomSheet` · `AlertDialog` · `Stack` · `Positioned` · `AnimatedContainer`

---

## 📝 Beginner Notes

- **State**: All state management uses `setState()` — no external libraries needed.
- **Persistence**: Only small values (IDs, booleans, strings) go in `shared_preferences`. Full recipe data lives in memory from `sample_data.dart`.
- **Images**: All recipe images are loaded from Unsplash URLs via `CachedNetworkImage`.
- **const**: Used throughout for performance — widgets that don't change are declared `const`.
- **Reusable widgets**: Common UI pieces (cards, badges, stars) are in `/widgets` so screens stay clean.

---

## 👥 Team

Built by **Group A** — beginner Flutter project.

Version `1.0.0` · Deadline: 14 days from receipt
