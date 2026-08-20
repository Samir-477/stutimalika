import 'dart:io' show Platform;
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/splash_screen.dart';
import 'models/models.dart';
import 'services/audio_handler.dart';
import 'theme/app_colors.dart';

// App-scoped so playback and the OS media notification survive navigating
// away from the Reader screen. Provided via dependency injection rather than
// a plain global would be cleaner, but this app has no DI setup yet.
late final StutiAudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.loadPrefs();
  // Android 13+ hides the playback notification unless this is granted at
  // runtime — declaring POST_NOTIFICATIONS in the manifest alone isn't
  // enough, which is why the Spotify-style "now playing" bar wasn't showing.
  if (!kIsWeb && Platform.isAndroid) {
    await Permission.notification.request();
  }
  audioHandler = await AudioService.init(
    builder: () => StutiAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.stutimallika.audio',
      androidNotificationChannelName: 'Stutimallika Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
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
