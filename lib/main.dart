import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'models/models.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.loadPrefs();
  runApp(const StutiMallikaApp());
}

ThemeData _buildTheme(AppColors colors, Brightness brightness) {
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: colors.background,
    primaryColor: colors.chrome,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.chrome,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    cardColor: colors.surface,
    dividerColor: colors.divider,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C5A3A),
      brightness: brightness,
      primary: colors.chrome,
      secondary: colors.accent,
      surface: colors.surface,
    ),
    fontFamily: 'Serif', // Use a serif font for traditional look
    useMaterial3: true,
    extensions: [colors],
  );
}

class StutiMallikaApp extends StatelessWidget {
  const StutiMallikaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppState.darkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Stutimallika',
          theme: _buildTheme(AppColors.light, Brightness.light),
          darkTheme: _buildTheme(AppColors.dark, Brightness.dark),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
