import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/icon_badge.dart';
import '../widgets/numbered_title.dart';
import '../utils/page_transitions.dart';
import 'stotra_list_screen.dart';
import 'reader_screen.dart';
import 'settings_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showScriptPicker() {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        Widget scriptTile(String label, String code) {
          return ListTile(
            title: Text(label),
            trailing: AppState.scriptLang == code ? Icon(Icons.check, color: c.accent) : null,
            onTap: () { setState(() => AppState.scriptLang = code); Navigator.pop(context); },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 4), child: Text('Script (applies app-wide)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c.brandText))),
              ...scriptLangLabels.entries.map((e) => scriptTile(e.value, e.key)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ScriptListener(builder: (context) => Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        centerTitle: false,
        title: Text(
          scriptText('स्तुतिमल्लिका', 'ಸ್ತುತಿಮಲ್ಲಿಕಾ', 'Stutimallika'),
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, smoothRoute(const SearchScreen())),
          ),
          IconButton(
            icon: const Text('अA', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            onPressed: _showScriptPicker,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(context, smoothRoute(const SettingsScreen()));
              // Default language/script may have changed in Settings — refresh to pick it up.
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(scriptText('Recently Played', 'ಇತ್ತೀಚೆಗೆ ಆಲಿಸಿದ್ದು', 'Recently Played'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.heading)),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRecentCard(context, 'assets/images/rameshastuti.jpeg', 'ramesha-stuti', scriptText('श्रीवादिराजतीर्थ विरचित\nरमेशस्तुतिः', 'ಶ್ರೀವಾದಿರಾಜತೀರ್ಥ ವಿರಚಿತ\nರಮೇಶಸ್ತುತಿಃ', 'Sri Vadiraja Tirtha\nRamesha Stuti')),
                const SizedBox(width: 12),
                _buildRecentCard(context, 'assets/images/hayagreevastotram.jpeg', 'hayagriva-stotram', scriptText('श्रीवादिराजतीर्थ विरचित\nहयग्रीवसम्पदास्तोत्रम्', 'ಶ್ರೀವಾದಿರಾಜತೀರ್ಥ ವಿರಚಿತ\nಹಯಗ್ರೀವಸಂಪದಾಸ್ತೋತ್ರಮ್', 'Sri Vadiraja Tirtha\nHayagriva Sampada Stotram')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c.chrome,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.push(context, smoothRoute(const FavoritesScreen())),
            child: const Row(
              children: [
                Icon(Icons.favorite_rounded),
                SizedBox(width: 16),
                Expanded(child: Text('My Favorites', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(scriptText('Categories', 'ವಿಭಾಗಗಳು', 'Categories'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.heading)),
          const SizedBox(height: 12),
          _buildCategoryCard(context, scriptText('स्तुति विभाग', 'ಸ್ತುತಿ ವಿಭಾಗ', 'Stuti Vibhaga'), scriptText('भक्तिपूर्ण स्तोत्राणि', 'ಭಕ್ತಿಪೂರ್ಣ ಸ್ತೋತ್ರಗಳು', 'Devotional Stotras'), Icons.auto_stories_rounded, true),
          _buildCategoryCard(context, scriptText('कीर्तन विभाग', 'ಕೀರ್ತನ ವಿಭಾಗ', 'Kirtan Vibhaga'), scriptText('सुमधुर कीर्तनानि', 'ಸುಮಧುರ ಕೀರ್ತನೆಗಳು', 'Melodious Kirtans'), Icons.graphic_eq_rounded, false),
          _buildCategoryCard(context, scriptText('सुळादि विभाग', 'ಸುಳಾದಿ ವಿಭಾಗ', 'Suladi Vibhaga'), scriptText('पारम्परिक सुळादयः', 'ಪಾರಂಪರಿಕ ಸುಳಾದಿಗಳು', 'Traditional Suladis'), Icons.library_music_rounded, false, isSuladi: true),
        ],
      ),
    ));
  }

  Widget _buildRecentCard(BuildContext context, String image, String stotraId, String title) {
    return GestureDetector(
      onTap: () async {
        try {
          final jsonStr = await DefaultAssetBundle.of(context).loadString('assets/data/stotras.json');
          final List<dynamic> jsonList = json.decode(jsonStr);
          final stotras = jsonList.map((j) => Stotra.fromJson(j)).toList();

          final stotra = stotras.firstWhere((s) => s.id == stotraId);

          if (context.mounted) {
            Navigator.push(context, smoothRoute(ReaderScreen(stotra: stotra)));
          }
        } catch (e) {
          debugPrint('Error loading recent: $e');
        }
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.bottomLeft,
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, height: 1.4)),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String subtitle, IconData icon, bool hasSubcategories, {bool isSuladi = false}) {
    final c = context.colors;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [c.surface, Color.lerp(c.surface, c.iconCircleBg, 0.55)!],
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: IconBadge(icon),
          title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.heading)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(subtitle, style: TextStyle(fontSize: 13, color: c.mutedText)),
          ),
          trailing: Icon(Icons.chevron_right, color: c.brandText),
          onTap: () {
            if (hasSubcategories) {
              Navigator.push(context, smoothRoute(const StotraSubcategoriesScreen()));
            } else if (isSuladi) {
              Navigator.push(context, smoothRoute(const SuladiListScreen()));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content coming soon')));
            }
          },
        ),
      ),
    );
  }
}

class StotraSubcategoriesScreen extends StatelessWidget {
  const StotraSubcategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ScriptListener(builder: (context) {
      final composers = [
        scriptText('वेदव्यासदेवकृतस्तोत्राणि', 'ವೇದವ್ಯಾಸದೇವಕೃತಸ್ತೋತ್ರಾಣಿ', 'Stotras by Sri Vedavyasa Deva'),
        scriptText('श्रीमध्वाचार्यकृतस्तोत्राणि', 'ಶ್ರೀಮಧ್ವಾಚಾರ್ಯಕೃತಸ್ತೋತ್ರಾಣಿ', 'Stotras by Sri Madhvacharya'),
        scriptText('श्रीवादिराजतीर्थकृतस्तोत्राणि', 'ಶ್ರೀವಾದಿರಾಜತೀರ್ಥಕೃತಸ್ತೋತ್ರಾಣಿ', 'Stotras by Sri Vadiraja Tirtha'),
        scriptText('श्रीविजयीन्द्रतीर्थकृतस्तोत्राणि', 'ಶ್ರೀವಿಜಯೀನ್ದ್ರತೀರ್ಥಕೃತಸ್ತೋತ್ರಾಣಿ', 'Stotras by Sri Vijayeendra Tirtha'),
        scriptText('श्रीव्यासराजतीर्थकृतस्तोत्राणि', 'ಶ್ರೀವ್ಯಾಸರಾಜತೀರ್ಥಕೃತಸ್ತೋತ್ರಾಣಿ', 'Stotras by Sri Vyasaraja Tirtha'),
        scriptText('श्रीराघवेन्द्रतीर्थकृतस्तोत्राणि', 'ಶ್ರೀರಾಘವೇನ್ದ್ರತೀರ್ಥಕೃತಸ್ತೋತ್ರಾಣಿ', 'Stotras by Sri Raghavendra Tirtha'),
        scriptText('अन्यकृतस्तोत्राणि', 'ಅನ್ಯಕೃತಸ್ತೋತ್ರಾಣಿ', 'Stotras by Other Composers'),
      ];

      return Scaffold(
        appBar: AppBar(toolbarHeight: 72, title: Text(scriptText('स्तुति विभाग', 'ಸ್ತುತಿ ವಿಭಾಗ', 'Stuti Vibhaga'))),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: composers.length,
          itemBuilder: (context, index) {
            bool hasContent = index == 2; // Only item 3 has content
            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Icon(Icons.menu_book_rounded, color: c.brandText, size: 28),
                title: NumberedTitle(number: index + 1, text: composers[index], style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: c.brandText, height: 1.3)),
                trailing: hasContent ? const Icon(Icons.chevron_right) : const Text('Coming soon', style: TextStyle(color: Colors.grey)),
                onTap: hasContent ? () {
                  Navigator.push(context, smoothRoute(const StotraListScreen(composer: 'Sri Vadiraja Tirtha', titleMap: {'sa': 'श्रीवादिराजतीर्थकृतस्तोत्राणि', 'kn': 'ಶ್ರೀವಾದಿರಾಜತೀರ್ಥಕೃತಸ್ತೋತ್ರಾಣಿ', 'en': 'Stotras by Sri Vadiraja Tirtha'})));
                } : null,
              ),
            );
          },
        ),
      );
    });
  }
}

class SuladiListScreen extends StatefulWidget {
  const SuladiListScreen({super.key});
  @override
  State<SuladiListScreen> createState() => _SuladiListScreenState();
}

class _SuladiListScreenState extends State<SuladiListScreen> {
  List<Stotra> suladis = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jsonStr = await DefaultAssetBundle.of(context).loadString('assets/data/stotras.json');
      final List<dynamic> jsonList = json.decode(jsonStr);
      setState(() {
        suladis = jsonList
            .map((j) => Stotra.fromJson(j))
            .where((s) => s.category == 'suladi')
            .toList();
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ScriptListener(builder: (context) => Scaffold(
      appBar: AppBar(toolbarHeight: 72, title: Text(scriptText('सुळादि विभाग', 'ಸುಳಾದಿ ವಿಭಾಗ', 'Suladi Vibhaga'))),
      body: error != null
        ? Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red)))
        : suladis.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: suladis.length + 1,
            itemBuilder: (context, index) {
              final bookIcon = Icon(Icons.menu_book_rounded, color: c.brandText, size: 28);

              if (index == suladis.length) {
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: bookIcon,
                    title: NumberedTitle(number: index + 1, text: scriptText('यन्त्रोद्धारक हनुमत्सुळादि', 'ಯಂತ್ರೋದ್ಧಾರಕ ಹನುಮತ್ಸುಳಾದಿ', 'Yantroddharaka Hanuman Suladi'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: c.brandText, height: 1.3)),
                    trailing: const Text('Coming soon', style: TextStyle(color: Colors.grey)),
                  ),
                );
              }

              final suladi = suladis[index];

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: bookIcon,
                  title: NumberedTitle(number: index + 1, text: resolveScriptText(suladi.title), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: c.brandText, height: 1.3)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(context, smoothRoute(ReaderScreen(stotra: suladi)));
                  },
                ),
              );
            },
          ),
    ));
  }
}
