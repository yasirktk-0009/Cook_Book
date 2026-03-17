import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/preferences_service.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = PreferencesService();
  final isDark = await prefs.getDarkTheme();

  runApp(CookBookApp(initialDark: isDark));
}

// ─── Root App ─────────────────────────────────────────────────────────────────
class CookBookApp extends StatefulWidget {
  final bool initialDark;

  const CookBookApp({super.key, required this.initialDark});

  @override
  State<CookBookApp> createState() => _CookBookAppState();
}

class _CookBookAppState extends State<CookBookApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.initialDark;
  }

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,

      // ── Dark Theme ─────────────────────────────────────────────────────────
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: kPrimaryColor,
          secondary: kAccentOrange,
          surface: kDarkSurface,
          background: kDarkBg,
          error: kErrorColor,
        ),
        scaffoldBackgroundColor: kDarkBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: kDarkBg,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardColor: kDarkCard,
        dividerColor: kDarkBorder,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kDarkCard,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white70),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith(
            (states) =>
                states.contains(MaterialState.selected) ? kPrimaryColor : null,
          ),
          trackColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.selected)
                ? kPrimaryColor.withOpacity(0.4)
                : null,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: kDarkCard,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // ── Light Theme ────────────────────────────────────────────────────────
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: kPrimaryColor,
          secondary: kAccentOrange,
          surface: kLightSurface,
          background: kLightBg,
          error: kErrorColor,
        ),
        scaffoldBackgroundColor: kLightBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: kLightBg,
          foregroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        cardColor: kLightSurface,
        dividerColor: kLightBorder,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kLightCard,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith(
            (states) =>
                states.contains(MaterialState.selected) ? kPrimaryColor : null,
          ),
          trackColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.selected)
                ? kPrimaryColor.withOpacity(0.4)
                : null,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey.shade800,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      home: HomeScreen(
        onThemeToggle: _toggleTheme,
        isDark: _isDark,
      ),
    );
  }
}
