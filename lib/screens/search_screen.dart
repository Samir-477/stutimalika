import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../utils/page_transitions.dart';
import 'reader_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Stotra> _all = [];
  List<Stotra> _results = [];
  String _query = '';
  String _filter = 'all'; // 'all', 'stuti', 'suladi'
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  Future<void> _loadData() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/stotras.json');
      final List<dynamic> jsonList = json.decode(jsonStr);
      setState(() {
        _all = jsonList.map((j) => Stotra.fromJson(j)).toList();
        _loading = false;
        _applyFilter();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _query.trim().toLowerCase();
    setState(() {
      _results = _all.where((s) {
        final isSuladi = s.category == 'suladi';
        final matchesCategory = _filter == 'all' || (_filter == 'suladi' ? isSuladi : !isSuladi);
        if (!matchesCategory) return false;
        if (q.isEmpty) return true;
        final titleMatch = s.title.values.any((t) => t.toLowerCase().contains(q));
        final composerMatch = s.composer.toLowerCase().contains(q);
        return titleMatch || composerMatch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ScriptListener(builder: (context) => Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: scriptText('स्तोत्रं गवेषयतु...', 'ಹುಡುಕಿ...', 'Search stotras...'),
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (v) {
            _query = v;
            _applyFilter();
          },
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _query = '';
                _applyFilter();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _filterChip(context, 'all', scriptText('सर्वे', 'ಎಲ್ಲಾ', 'All')),
                const SizedBox(width: 8),
                _filterChip(context, 'stuti', scriptText('स्तोत्राणि', 'ಸ್ತೋತ್ರಗಳು', 'Stotras')),
                const SizedBox(width: 8),
                _filterChip(context, 'suladi', scriptText('सुळादि', 'ಸುಳಾದಿ', 'Suladi')),
              ],
            ),
          ),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                : _results.isEmpty
                  ? Center(
                      child: Text(
                        _query.trim().isEmpty
                          ? scriptText('टङ्कयित्वा गवेषयतु', 'ಹುಡುಕಲು ಟೈಪ್ ಮಾಡಿ', 'Type to search')
                          : scriptText('कोऽपि परिणामो न प्राप्तः', 'ಯಾವುದೇ ಫಲಿತಾಂಶಗಳು ಸಿಗಲಿಲ್ಲ', 'No results found'),
                        style: TextStyle(color: c.mutedText, fontSize: 15),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final stotra = _results[index];
                        String? img;
                        if (stotra.id == 'hayagriva-stotram') img = 'assets/images/hayagreevastotram.jpeg';
                        if (stotra.id == 'ramesha-stuti') img = 'assets/images/rameshastuti.jpeg';
                        if (stotra.id == 'sri-narasimha-devara-suladi') img = 'assets/images/narsimha suladi.jpeg';
                        if (stotra.id == 'durga-suladhi') img = 'assets/images/durga suladi.jpeg';
                        if (stotra.id == 'sri-mukhya-prana-suladi') img = 'assets/images/mukhyaprana suladi.jpeg';
                        // No dedicated artwork exists for these two — reuse existing images.
                        if (stotra.id == 'sri-kapila-devara-suladi') img = 'assets/images/rameshastuti.jpeg';
                        if (stotra.id == 'dhanvanthri-suladhi') img = 'assets/images/hayagreevastotram.jpeg';

                        // Only these two currently have real audio wired up in ReaderScreen.
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
                            title: Text(resolveScriptText(stotra.title), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: c.brandText, height: 1.3)),
                            subtitle: Text(stotra.composer, style: TextStyle(color: c.mutedText)),
                            trailing: hasAudio ? Icon(Icons.play_circle_fill_rounded, color: c.accent, size: 28) : null,
                            onTap: () {
                              Navigator.push(context, smoothRoute(ReaderScreen(stotra: stotra)));
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    ));
  }

  Widget _filterChip(BuildContext context, String value, String label) {
    final c = context.colors;
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        _filter = value;
        _applyFilter();
      },
      selectedColor: c.accent,
      backgroundColor: c.surface,
      labelStyle: TextStyle(color: selected ? Colors.white : c.brandText, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: c.divider)),
    );
  }
}
