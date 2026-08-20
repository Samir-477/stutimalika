import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const scriptLangLabels = {'sa': 'Sanskrit', 'kn': 'Kannada', 'hi': 'Hindi', 'en': 'English', 'te': 'Telugu', 'ta': 'Tamil'};

// Devanagari and Telugu are parallel Unicode blocks (same ISCII-derived
// layout), so every relevant codepoint is exactly +0x300 from its Devanagari
// counterpart — a lossless, exact conversion.
const int _devaToTeluguOffset = 0x300;
const Set<int> _devaPassthrough = {0x0964, 0x0965}; // danda / double danda

String _devanagariToTelugu(String s) {
  final buffer = StringBuffer();
  for (final rune in s.runes) {
    if (_devaPassthrough.contains(rune) || rune < 0x0900 || rune > 0x097F) {
      buffer.writeCharCode(rune);
    } else {
      buffer.writeCharCode(rune + _devaToTeluguOffset);
    }
  }
  return buffer.toString();
}

// Tamil has no separate letters for aspirated/voiced consonant distinctions,
// so several Devanagari consonants collapse onto one Tamil letter — the same
// convention used in printed Tamil Sanskrit stotras (e.g. Vishnu
// Sahasranamam Tamil editions). Grantha-borrowed letters (sha/ssa/sa/ha/ja)
// are standard Unicode Tamil-block characters. Anusvara renders as the
// practical "m + pulli" (ம்), visarga as the Tamil aytham (ஃ), and vocalic-r
// (ऋ) matra as "ிரு" (the same convention that spells Krishna as "கிருஷ்ணா").
const Map<int, String> _devaToTamil = {
  0x0905: 'அ', 0x0906: 'ஆ', 0x0907: 'இ', 0x0908: 'ஈ', 0x0909: 'உ', 0x090A: 'ஊ',
  0x090F: 'ஏ', 0x0910: 'ஐ', 0x0913: 'ஓ', 0x0914: 'ஔ',
  0x0915: 'க', 0x0916: 'க', 0x0917: 'க', 0x0918: 'க', 0x0919: 'ங',
  0x091A: 'ச', 0x091B: 'ச', 0x091C: 'ஜ', 0x091D: 'ஜ', 0x091E: 'ஞ',
  0x091F: 'ட', 0x0920: 'ட', 0x0921: 'ட', 0x0922: 'ட', 0x0923: 'ண',
  0x0924: 'த', 0x0925: 'த', 0x0926: 'த', 0x0927: 'த', 0x0928: 'ந',
  0x092A: 'ப', 0x092B: 'ப', 0x092C: 'ப', 0x092D: 'ப', 0x092E: 'ம',
  0x092F: 'ய', 0x0930: 'ர', 0x0932: 'ல', 0x0935: 'வ',
  0x0936: 'ஶ', 0x0937: 'ஷ', 0x0938: 'ஸ', 0x0939: 'ஹ', 0x0933: 'ள',
  0x093E: 'ா', 0x093F: 'ி', 0x0940: 'ீ', 0x0941: 'ு', 0x0942: 'ூ',
  0x0947: 'ே', 0x0948: 'ை', 0x094B: 'ோ', 0x094C: 'ௌ',
  0x094D: '்', 0x0902: 'ம்', 0x0903: 'ஃ',
  0x0964: '।', 0x0965: '॥',
};
const int _devaVocalicRMatra = 0x0943; // ऋ matra

String _devanagariToTamil(String s) {
  final buffer = StringBuffer();
  for (final rune in s.runes) {
    if (rune == _devaVocalicRMatra) {
      buffer.write('ிரு');
    } else {
      final mapped = _devaToTamil[rune];
      buffer.write(mapped ?? String.fromCharCode(rune));
    }
  }
  return buffer.toString();
}

// Kannada and Devanagari are also parallel Unicode blocks — Kannada sits at
// a fixed +0x380 offset from Devanagari — so suladi content (composed
// originally in Kannada, with no Sanskrit source) can be bridged into
// Devanagari the same lossless way, and from there into Telugu/Tamil via
// the functions above.
const int _kannadaToDevaOffset = -0x380;

String _kannadaToDevanagari(String s) {
  final buffer = StringBuffer();
  for (final rune in s.runes) {
    if (rune < 0x0C80 || rune > 0x0CFF) {
      buffer.writeCharCode(rune);
    } else {
      buffer.writeCharCode(rune + _kannadaToDevaOffset);
    }
  }
  return buffer.toString();
}

// Picks a string for the current script setting — used for static section
// names/labels not backed by stotras.json. Hindi reads Devanagari (the same
// script as Sanskrit), so it maps to `sa`. Telugu/Tamil are transliterated
// live from the Sanskrit string using the same rules applied to the verse
// content in stotras.json. English uses a hand-written plain-letter
// romanization (e.g. "Shri Vadiraja"), not the Devanagari string.
String scriptText(String sa, String kn, String en) {
  switch (AppState.scriptLang) {
    case 'kn':
      return kn;
    case 'te':
      return _devanagariToTelugu(sa);
    case 'ta':
      return _devanagariToTamil(sa);
    case 'en':
      return en;
    default:
      return sa;
  }
}

// Resolves a verse/title text map (with 'sa', 'kn', and optionally 'iast',
// 'te', 'ta' keys) against the current script setting, with script-aware
// fallbacks: Hindi reads Devanagari (same as Sanskrit) and English reads the
// IAST Roman transliteration where available. If a dedicated 'te'/'ta'/'sa'
// entry isn't present, it's transliterated live instead of silently falling
// back to Kannada — from Sanskrit where available, or bridged live from
// Kannada for suladi content, which has no Sanskrit source to begin with.
String resolveScriptText(Map<String, String> textMap) {
  final lang = AppState.scriptLang;
  String? devanagari() => textMap['sa'] ?? (textMap['kn'] != null ? _kannadaToDevanagari(textMap['kn']!) : null);

  if (lang == 'sa' || lang == 'hi') return devanagari() ?? textMap['kn'] ?? '';
  if (lang == 'en') return textMap['en'] ?? textMap['iast'] ?? devanagari() ?? textMap['kn'] ?? '';
  if (lang == 'te' || lang == 'ta') {
    final direct = textMap[lang];
    if (direct != null) return direct;
    final sa = devanagari();
    if (sa != null) return lang == 'te' ? _devanagariToTelugu(sa) : _devanagariToTamil(sa);
    return textMap['kn'] ?? '';
  }
  return textMap[lang] ?? devanagari() ?? textMap['kn'] ?? '';
}

class AppState {
  static const _scriptPrefKey = 'default_script_lang';
  static const _meaningPrefKey = 'default_meaning_lang';
  static const _favoritesPrefKey = 'favorite_stotra_ids';

  // Currently active script for verse text and titles everywhere in the app.
  // Starts out equal to the saved default, but the अA quick-access menus can
  // change this for the current session without touching the saved default.
  // Backed by a ValueNotifier (not a plain field) so that changing it from
  // anywhere — the Home appbar, deep inside the Reader screen, Settings —
  // triggers an app-wide rebuild instead of only refreshing whichever single
  // screen happened to make the change.
  static final ValueNotifier<String> _scriptLangNotifier = ValueNotifier<String>('kn');
  static String get scriptLang => _scriptLangNotifier.value;
  static set scriptLang(String value) => _scriptLangNotifier.value = value;
  static ValueListenable<String> get scriptLangListenable => _scriptLangNotifier;

  // Currently active language for the meaning printed under each verse.
  static final ValueNotifier<String> _meaningLangNotifier = ValueNotifier<String>('kn');
  static String get meaningLang => _meaningLangNotifier.value;
  static set meaningLang(String value) => _meaningLangNotifier.value = value;
  static ValueListenable<String> get meaningLangListenable => _meaningLangNotifier;

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

/// Rebuilds [builder] whenever the active script or meaning language
/// changes, no matter where in the app that change was made. Screens wrap
/// their content in this instead of relying on the change to cascade down
/// from the app root — a screen sitting underneath the current one in the
/// Navigator stack (e.g. Home, still mounted while the Reader screen is on
/// top) needs to update the moment the language changes, not just the next
/// time it happens to rebuild for some other reason.
class ScriptListener extends StatelessWidget {
  final WidgetBuilder builder;
  const ScriptListener({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([AppState.scriptLangListenable, AppState.meaningLangListenable]),
      builder: (context, _) => builder(context),
    );
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
