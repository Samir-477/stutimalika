class AppState {
  static String globalLang = 'kn';
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
