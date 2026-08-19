import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/models.dart';
import 'stotra_list_screen.dart';
import 'reader_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/app logo.jpeg', height: 40, fit: BoxFit.contain),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Text('अA', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language settings will apply globally here.')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Recently Played', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3B2C))),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRecentCard(context, 'assets/images/rameshastuti.jpeg', 'ramesha-stuti', 'श्रीवादिराजतीर्थ विरचित\nरमेशस्तुतिः'),
                const SizedBox(width: 12),
                _buildRecentCard(context, 'assets/images/hayagreevastotram.jpeg', 'hayagriva-stotram', 'श्रीवादिराजतीर्थ विरचित\nहयग्रीवसम्पदास्तोत्रम्'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C5A3A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
            child: const Row(
              children: [
                Icon(Icons.favorite),
                SizedBox(width: 16),
                Expanded(child: Text('My Favorites', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3B2C))),
          const SizedBox(height: 12),
          _buildCategoryCard(context, 'स्तुति विभाग', Icons.menu_book, true),
          _buildCategoryCard(context, 'कीर्तन विभाग', Icons.music_note, false),
          _buildCategoryCard(context, 'सुळादि विभाग', Icons.notifications, false, isSuladi: true),
        ],
      ),
    );
  }

  Widget _buildRecentCard(BuildContext context, String image, String stotraId, String title) {
    return GestureDetector(
      onTap: () async {
        try {
          final jsonStr = await DefaultAssetBundle.of(context).loadString('assets/data/stotras.json');
          final List<dynamic> jsonList = json.decode(jsonStr);
          final stotras = jsonList.map((j) => Stotra.fromJson(j)).toList();
          
          Stotra stotra;
          if (stotraId == 'hayagriva-stotram') {
            stotra = Stotra(
              id: 'hayagriva-stotram',
              title: {'kn': 'ಹಯಗ್ರೀವ ಸ್ತೋತ್ರಮ್', 'sa': 'हयग्रीव स्तोत्रम्'},
              composer: 'Sri Vadiraja Tirtha',
              category: 'stuti',
              audioAsset: 'hayagreeva stotra.mp4',
              verses: [Verse(id: 'hs-v1', startTimeMs: 0, endTimeMs: 10000, text: {'kn': 'Audio loaded...'}, meaning: {})],
            );
          } else {
            stotra = stotras.firstWhere((s) => s.id == stotraId);
          }

          if (context.mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ReaderScreen(stotra: stotra)));
          }
        } catch (e) {
          debugPrint('Error loading recent: $e');
        }
      },
      child: Container(
        width: 160,
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
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.bottomLeft,
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, height: 1.4)),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, bool hasSubcategories, {bool isSuladi = false}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: Color(0xFFDCC8B2), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF7C5A3A)),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3B2C))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF7C5A3A)),
        onTap: () {
          if (hasSubcategories) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StotraSubcategoriesScreen()));
          } else if (isSuladi) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SuladiListScreen()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content coming soon')));
          }
        },
      ),
    );
  }
}

class StotraSubcategoriesScreen extends StatelessWidget {
  const StotraSubcategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final composers = [
      '१. वेदव्यासदेवकृतस्तोत्राणि',
      '२. श्रीमध्वाचार्यकृतस्तोत्राणि',
      '३. श्रीवादिराजतीर्थकृतस्तोत्राणि',
      '४. श्रीविजयीन्द्रतीर्थकृतस्तोत्राणि',
      '५. श्रीव्यासराजतीर्थकृतस्तोत्राणि',
      '६. श्रीराघवेन्द्रतीर्थकृतस्तोत्राणि',
      '७. अन्यकृतस्तोत्राणि'
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('स्तुति विभाग')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: composers.length,
        itemBuilder: (context, index) {
          bool hasContent = index == 2; // Only item 3 has content
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(composers[index], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C5A3A))),
              trailing: hasContent ? const Icon(Icons.chevron_right) : const Text('Coming soon', style: TextStyle(color: Colors.grey)),
              onTap: hasContent ? () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StotraListScreen(composer: 'श्रीवादिराजतीर्थकृतस्तोत्राणि')));
              } : null,
            ),
          );
        },
      ),
    );
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
    return Scaffold(
      appBar: AppBar(title: const Text('सुळादि विभाग')),
      body: error != null 
        ? Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red)))
        : suladis.isEmpty 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: suladis.length,
            itemBuilder: (context, index) {
              final suladi = suladis[index];
              String? img;
              if (suladi.id == 'sri-narasimha-devara-suladi') img = 'assets/images/narsimha suladi.jpeg';
              if (suladi.id == 'durga-suladhi') img = 'assets/images/durga suladi.jpeg';
              if (suladi.id == 'sri-mukhya-prana-suladi') img = 'assets/images/mukhyaprana suladi.jpeg';
              
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: img != null 
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(img, width: 50, height: 50, fit: BoxFit.cover),
                      )
                    : null,
                  title: Text(suladi.title[AppState.globalLang] ?? suladi.title['kn'] ?? suladi.title['sa'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7C5A3A))),
                  trailing: const Icon(Icons.play_arrow, color: Color(0xFFE8863A)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ReaderScreen(stotra: suladi)));
                  },
                ),
              );
            },
          ),
    );
  }
}
