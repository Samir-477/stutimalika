import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Picks between a Sanskrit and Kannada string based on the current script
// setting — used for static section names/labels not backed by stotras.json.
String scriptText(String sa, String kn) => AppState.scriptLang == 'sa' ? sa : kn;

class AppState {
  static const _scriptPrefKey = 'default_script_lang';
  static const _meaningPrefKey = 'default_meaning_lang';
  static const _favoritesPrefKey = 'favorite_stotra_ids';

  // Currently active script for verse text and titles everywhere in the app: 'sa' or 'kn' only.
  // Starts out equal to the saved default, but the अA quick-access menus can change this
  // for the current session without touching the saved default.
  static String scriptLang = 'kn';
  // Currently active language for the meaning printed under each verse: 'kn', 'en', 'hi', 'te', 'ta', 'sa'.
  static String meaningLang = 'kn';

  // Dark mode, listenable so MaterialApp can rebuild its theme when it changes.
  static final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);

  // Favorited stotra/suladi ids, listenable so any screen showing favorite
  // state (heart icons, the Favorites list) updates the moment it changes.
  static final ValueNotifier<Set<String>> favorites = ValueNotifier<Set<String>>({});

  static bool isFavorite(String stotraId) => favorites.value.contains(stotraId);

  static Future<void> toggleFavorite(String stotraId) async {
    final updated = Set<String>.from(favorites.value);
    if (!updated.remove(stotraId)) updated.add(stotraId);
    favorites.value = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesPrefKey, updated.toList());
  }

  // Loads the saved default language preferences and applies them as the
  // starting session values. Call once at app startup, before runApp.
  static Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    scriptLang = prefs.getString(_scriptPrefKey) ?? 'kn';
    meaningLang = prefs.getString(_meaningPrefKey) ?? 'kn';
    favorites.value = (prefs.getStringList(_favoritesPrefKey) ?? []).toSet();
  }

  // Sets the permanent default script — applied immediately and persisted
  // so it's still the starting choice next time the app is opened.
  static Future<void> setDefaultScriptLang(String code) async {
    scriptLang = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scriptPrefKey, code);
  }

  // Sets the permanent default meaning language — applied immediately and
  // persisted so it's still the starting choice next time the app is opened.
  static Future<void> setDefaultMeaningLang(String code) async {
    meaningLang = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_meaningPrefKey, code);
  }
}

class Verse {
  final String id;
  final int startTimeMs;
  final int endTimeMs;
  final Map<String, String> text; 
  final Map<String, String> meaning;

  Verse({required this.id, required this.startTimeMs, required this.endTimeMs, required this.text, required this.meaning});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'] ?? '',
      startTimeMs: json['startTimeMs'] ?? 0,
      endTimeMs: json['endTimeMs'] ?? 0,
      text: Map<String, String>.from(json['text'] ?? {}),
      meaning: Map<String, String>.from(json['meaning'] ?? {}),
    );
  }
}

class Stotra {
  final String id;
  final Map<String, String> title;
  final String composer;
  final String category;
  final String audioAsset;
  final List<Verse> verses;

  Stotra({required this.id, required this.title, required this.composer, required this.category, required this.audioAsset, required this.verses});

  factory Stotra.fromJson(Map<String, dynamic> json) {
    var vList = json['verses'] as List? ?? [];
    return Stotra(
      id: json['id'] ?? '',
      title: Map<String, String>.from(json['title'] ?? {}),
      composer: json['composer'] ?? '',
      category: json['category'] ?? 'stuti',
      audioAsset: json['audioAsset'] ?? '',
      verses: vList.map((i) => Verse.fromJson(i)).toList(),
    );
  }
}
