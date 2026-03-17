import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/preferences_service.dart';

// ─── Settings Screen ──────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;

  const SettingsScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDark,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefsService = PreferencesService();

  late bool _isDark;
  bool _isCompact = false;
  String _defaultCategory = 'All';
  bool _cookingNotifications = true;
  bool _autoSync = false;

  static const _categories = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Dessert', 'Snack'];

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final compact = await _prefsService.getCompactCards();
    final cat = await _prefsService.getDefaultCategory();
    final notifs = await _prefsService.getCookingNotifications();
    final sync = await _prefsService.getAutoSync();
    setState(() {
      _isCompact = compact;
      _defaultCategory = cat;
      _cookingNotifications = notifs;
      _autoSync = sync;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(kPadding),
          children: [
            // ── Appearance Section ──────────────────────────────────────────────
            _SectionCard(
              title: 'Appearance',
              children: [
                _SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Theme',
                  subtitle: _isDark
                      ? 'Currently using dark mode'
                      : 'Currently using light mode',
                  trailing: Switch(
                    value: _isDark,
                    onChanged: (val) {
                      setState(() => _isDark = val);
                      widget.onThemeToggle();
                      _prefsService.setDarkTheme(val);
                    },
                    activeColor: kPrimaryColor,
                  ),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.grid_view_rounded,
                  title: 'Compact Cards',
                  subtitle: 'Use smaller cards to show more content',
                  trailing: Switch(
                    value: _isCompact,
                    onChanged: (val) {
                      setState(() => _isCompact = val);
                      _prefsService.setCompactCards(val);
                    },
                    activeColor: kPrimaryColor,
                  ),
                ),
                // Preview
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kPadding,
                    vertical: kPaddingSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(kPaddingSmall),
                        decoration: BoxDecoration(
                          color: isDark ? kDarkBorder : kLightBorder,
                          borderRadius:
                              BorderRadius.circular(kBorderRadiusSmall),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade600,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sample Recipe',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '30 minutes · Rating: 4.5 stars',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
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
              ],
            ),
            const SizedBox(height: 16),

            // ── Preferences Section ─────────────────────────────────────────────
            _SectionCard(
              title: 'Preferences',
              children: [
                _SettingsTile(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Default Category',
                  subtitle: 'New recipes will default to $_defaultCategory',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _defaultCategory,
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: kPrimaryColor,
                      ),
                    ],
                  ),
                  onTap: () => _showCategoryPicker(),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.notifications_rounded,
                  title: 'Cooking Notifications',
                  subtitle: 'Get reminders for cooking times',
                  trailing: Switch(
                    value: _cookingNotifications,
                    onChanged: (val) {
                      setState(() => _cookingNotifications = val);
                      _prefsService.setCookingNotifications(val);
                    },
                    activeColor: kPrimaryColor,
                  ),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.sync_rounded,
                  title: 'Auto Sync',
                  subtitle: 'Automatically sync recipes across devices',
                  trailing: Switch(
                    value: _autoSync,
                    onChanged: (val) {
                      setState(() => _autoSync = val);
                      _prefsService.setAutoSync(val);
                    },
                    activeColor: kPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Data Section ────────────────────────────────────────────────────
            _SectionCard(
              title: 'Data',
              children: [
                _SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Clear All Favorites',
                  subtitle: 'Remove all saved favorites',
                  iconColor: kErrorColor,
                  onTap: () => _showClearFavoritesDialog(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── About Section ───────────────────────────────────────────────────
            _SectionCard(
              title: 'About',
              children: [
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Version',
                  subtitle: kAppVersion,
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.code_rounded,
                  title: 'Developer',
                  subtitle: kDeveloperName,
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.open_in_new_rounded,
                  title: 'Visit Website',
                  subtitle: 'https://example.com/cookbook',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening website...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: kPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: kPadding),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Default Category',
                style: kSubheadingStyle,
              ),
              const SizedBox(height: kPadding),
              ..._categories.map(
                (cat) => ListTile(
                  title: Text(cat),
                  trailing: cat == _defaultCategory
                      ? const Icon(Icons.check_rounded, color: kPrimaryColor)
                      : null,
                  onTap: () {
                    setState(() => _defaultCategory = cat);
                    _prefsService.setDefaultCategory(cat);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearFavoritesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Favorites?'),
        content: const Text(
          'This will remove all your saved favorites. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _prefsService.saveFavoriteIds([]);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All favorites cleared.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: kErrorColor)),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Section Card ─────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kDarkCard : kLightSurface,
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: isDark ? kDarkBorder : kLightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(kPadding, kPadding, kPadding, 4),
            child: Text(title, style: kSubheadingStyle),
          ),
          ...children,
        ],
      ),
    );
  }
}

// ─── Settings Tile ─────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? kPrimaryColor).withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? kPrimaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
