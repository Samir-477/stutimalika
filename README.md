# Stuti Sangraha

Stuti Sangraha is a comprehensive, cross-platform Flutter application designed to serve as a digital repository for Hindu devotional literature, specifically focusing on Stotras, Ashtakams, and Suladis from the Madhwa tradition. The application provides an elegant, temple-themed reading and listening experience, fully localized in multiple scripts with synchronized audio playback capabilities.

## Architecture and Technical Stack

- Framework: Flutter (Dart)
- Architecture: Provider/Stateful Widget architecture for localized state management.
- Audio Engine: `just_audio` for robust playback, seeking, and playback speed control.
- Assets: Packaged natively with local JSON data structures and embedded `.mp4` audio files to ensure seamless offline functionality.
- UI/UX: Custom-built "Warm Temple" aesthetic utilizing specific hex colors (`#7C5A3A` Brown, `#F3E7D6` Cream, `#E8863A` Orange) to emulate traditional scripture reading.

## Core Features

1. Hierarchical Content Organization
The app categorizes literature into distinct logical sections:
- Stuti Vibhaga (General Stotras)
- Kirtana Vibhaga (Musical Compositions)
- Suladi Vibhaga (Specialized rhythmic compositions)

2. Multi-Language Engine
A global state management system (`AppState.globalLang`) allows the user to dynamically switch the script and meaning languages across the entire application simultaneously. 
Supported scripts/languages include:
- Kannada
- Sanskrit (Devanagari)
- English (Meanings & UI)
- Telugu, Tamil, and Hindi (Extensible support)

3. Synchronized Reader Screen
The Reader Screen parses dynamic JSON payloads to present structured verses. When a corresponding local audio asset is present, the app initializes a media player featuring:
- Algorithmic verse-highlight synchronization based on audio duration interpolation.
- Full playback controls (Play, Pause, +/- 5 seconds seek, loop toggle).
- Dynamic playback speed adjustment (0.75x to 2.0x).
- Graceful degradation (hides audio controls automatically if no media file is linked to the text).

4. Dynamic Asset Resolution
The application features an offline data layer (`assets/data/stotras.json`) which maps specific content IDs to their respective imagery and audio files without requiring external API calls, ensuring high performance.

## Project Structure

- `lib/models/models.dart`: Defines the data schema (`Stotra`, `Verse`) and parses the complex multi-language JSON mappings.
- `lib/screens/home_screen.dart`: The primary dashboard featuring "Recently Played", "Favorites", and category navigation.
- `lib/screens/reader_screen.dart`: The core content consumption interface handling text rendering, language switching, and the `just_audio` implementation.
- `lib/screens/stotra_list_screen.dart`: Dynamically filters and displays content belonging to standard categories.
- `lib/screens/settings_screen.dart`: Manages global application preferences.
- `assets/data/stotras.json`: The central database containing all text payloads, translations, and asset mappings.

## Build Instructions

### Prerequisites
- Flutter SDK (3.x or higher)
- Android Studio or appropriate Android build tools (for APK generation)

### Running Locally
To launch the application in debug mode on a connected device or emulator:
```bash
flutter run
```

### Building the Release APK
To compile the highly-optimized, release-ready Android application package:
```bash
flutter build apk --release
```
The compiled output will be available in the `build/app/outputs/flutter-apk/app-release.apk` directory.

## Data Expansion

To add new content, modify `assets/data/stotras.json` adhering to the following schema constraints:
- Ensure the `id` field is unique.
- Provide `title` and `text` maps containing the respective language keys (e.g., `"kn"` for Kannada, `"sa"` for Sanskrit).
- If audio is available, supply the exact filename in the `audioAsset` field and place the file in the `assets/audio/` directory.

## License
Proprietary software. All rights reserved.
