import 'package:shared_preferences/shared_preferences.dart';

// ─── Preferences Service ──────────────────────────────────────────────────────
// Handles all local storage using shared_preferences
class PreferencesService {
  static const _keyDarkTheme = 'isDarkTheme';
  static const _keyCompactCards = 'isCompactCards';
  static const _keyDefaultCategory = 'defaultCategory';
  static const _keyFavorites = 'favoriteIds';
  static const _keyCookingNotifications = 'cookingNotifications';
  static const _keyAutoSync = 'autoSync';

  // ── Theme ────────────────────────────────────────────────────────────────────
  Future<bool> getDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkTheme) ?? true; // Default dark
  }

  Future<void> setDarkTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkTheme, value);
  }

  // ── Compact Cards ────────────────────────────────────────────────────────────
  Future<bool> getCompactCards() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCompactCards) ?? false;
  }

  Future<void> setCompactCards(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCompactCards, value);
  }

  // ── Default Category ─────────────────────────────────────────────────────────
  Future<String> getDefaultCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDefaultCategory) ?? 'All';
  }

  Future<void> setDefaultCategory(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultCategory, value);
  }

  // ── Favorites ────────────────────────────────────────────────────────────────
  Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  Future<void> saveFavoriteIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavorites, ids);
  }

  // ── Cooking Notifications ────────────────────────────────────────────────────
  Future<bool> getCookingNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCookingNotifications) ?? true;
  }

  Future<void> setCookingNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCookingNotifications, value);
  }

  // ── Auto Sync ─────────────────────────────────────────────────────────────────
  Future<bool> getAutoSync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoSync) ?? false;
  }

  Future<void> setAutoSync(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoSync, value);
  }
}
