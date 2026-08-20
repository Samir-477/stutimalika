import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../utils/page_transitions.dart';
import '../widgets/numbered_title.dart';
import 'reader_screen.dart';

class StotraListScreen extends StatefulWidget {
  final String composer;
  final String? title;
  const StotraListScreen({super.key, required this.composer, this.title});
  @override
  State<StotraListScreen> createState() => _StotraListScreenState();
}

class _StotraListScreenState extends State<StotraListScreen> {
  List<Stotra> stotras = [];
  String? error;

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
        stotras = jsonList
            .map((j) => Stotra.fromJson(j))
            .where((s) => s.category != 'suladi' && s.composer == widget.composer)
            .toList();
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text(widget.title ?? widget.composer, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18)),
      ),
      body: error != null
        ? Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red)))
        : stotras.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stotras.length,
            itemBuilder: (context, index) {
              final stotra = stotras[index];

              // Only these two currently have real audio wired up in ReaderScreen.
              final hasAudio = stotra.id == 'ramesha-stuti' || stotra.id == 'hayagriva-stotram';
              final title = resolveScriptText(stotra.title);

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: Icon(Icons.menu_book_rounded, color: c.brandText, size: 28),
                  title: NumberedTitle(number: index + 1, text: title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.brandText, height: 1.3)),
                  trailing: hasAudio ? Icon(Icons.play_circle_fill_rounded, color: c.accent, size: 32) : null,
                  onTap: () {
                    Navigator.push(context, smoothRoute(ReaderScreen(stotra: stotra)));
                  },
                ),
              );
            },
          ),
    );
  }
}
