import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../utils/page_transitions.dart';
import 'reader_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Stotra> _all = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/stotras.json');
      final List<dynamic> jsonList = json.decode(jsonStr);
      setState(() {
        _all = jsonList.map((j) => Stotra.fromJson(j)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(toolbarHeight: 72, title: Text(scriptText('मम प्रियाणि', 'ನನ್ನ ಮೆಚ್ಚಿನವುಗಳು'))),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
          : ValueListenableBuilder<Set<String>>(
              valueListenable: AppState.favorites,
              builder: (context, favoriteIds, _) {
                final results = _all.where((s) => favoriteIds.contains(s.id)).toList();
                if (results.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        scriptText('अद्यापि कोऽपि स्तोत्रः प्रियेषु न योजितः। पठनसमये हृदयचिह्नं स्पृशतु।', 'ಇನ್ನೂ ಯಾವುದೇ ಮೆಚ್ಚಿನವುಗಳಿಲ್ಲ. ಓದುವಾಗ ಹೃದಯ ಐಕಾನ್ ಒತ್ತಿ.'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: c.mutedText, fontSize: 15),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final stotra = results[index];
                    String? img;
                    if (stotra.id == 'hayagriva-stotram') img = 'assets/images/hayagreevastotram.jpeg';
                    if (stotra.id == 'ramesha-stuti') img = 'assets/images/rameshastuti.jpeg';
                    if (stotra.id == 'sri-narasimha-devara-suladi') img = 'assets/images/narsimha suladi.jpeg';
                    if (stotra.id == 'durga-suladhi') img = 'assets/images/durga suladi.jpeg';
                    if (stotra.id == 'sri-mukhya-prana-suladi') img = 'assets/images/mukhyaprana suladi.jpeg';
                    final hasAudio = stotra.id == 'ramesha-stuti' || stotra.id == 'hayagriva-stotram';

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: img != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(img, width: 48, height: 48, fit: BoxFit.cover),
                            )
                          : Icon(Icons.menu_book_rounded, color: c.brandText),
                        title: Text(stotra.title[AppState.scriptLang] ?? stotra.title['kn'] ?? stotra.title['sa'] ?? '', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: c.brandText, height: 1.3)),
                        subtitle: Text(stotra.composer, style: TextStyle(color: c.mutedText)),
                        trailing: hasAudio ? Icon(Icons.play_circle_fill_rounded, color: c.accent, size: 28) : null,
                        onTap: () {
                          Navigator.push(context, smoothRoute(ReaderScreen(stotra: stotra)));
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
