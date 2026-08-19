import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'reader_screen.dart';

class StotraListScreen extends StatefulWidget {
  final String composer;
  const StotraListScreen({super.key, required this.composer});
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
            .where((s) => s.category != 'suladi')
            .toList();
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.composer)),
      body: error != null 
        ? Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red)))
        : stotras.isEmpty 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stotras.length,
            itemBuilder: (context, index) {
              final stotra = stotras[index];
              String? img;
              if (stotra.id == 'hayagriva') img = 'assets/images/hayagreevastotram.jpeg';
              if (stotra.id == 'ramesha') img = 'assets/images/rameshastuti.jpeg';
              
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
                  title: Text(stotra.title[AppState.globalLang] ?? stotra.title['kn'] ?? stotra.title['sa'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7C5A3A))),
                  trailing: const Icon(Icons.play_arrow, color: Color(0xFFE8863A)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ReaderScreen(stotra: stotra)));
                  },
                ),
              );
            },
          ),
    );
  }
}
