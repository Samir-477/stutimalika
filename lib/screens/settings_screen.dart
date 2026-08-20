import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/icon_badge.dart';

const _scriptLabels = {'sa': 'Sanskrit', 'kn': 'Kannada'};
const _meaningLabels = {'kn': 'Kannada', 'en': 'English', 'hi': 'Hindi', 'te': 'Telugu', 'ta': 'Tamil', 'sa': 'Sanskrit'};

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showDefaultLanguagePicker() {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Widget langTile(String label, String code, String currentValue, Future<void> Function(String) onSelect) {
              return ListTile(
                title: Text(label),
                trailing: currentValue == code ? Icon(Icons.check, color: c.accent) : null,
                onTap: () async {
                  await onSelect(code);
                  setSheetState(() {});
                  setState(() {});
                },
              );
            }

            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 4), child: Text('Default Script (verses & titles)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c.brandText))),
                    langTile('Sanskrit', 'sa', AppState.scriptLang, AppState.setDefaultScriptLang),
                    langTile('Kannada', 'kn', AppState.scriptLang, AppState.setDefaultScriptLang),
                    const Divider(height: 1),
                    Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text('Default Meaning Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c.brandText))),
                    langTile('Kannada', 'kn', AppState.meaningLang, AppState.setDefaultMeaningLang),
                    langTile('English', 'en', AppState.meaningLang, AppState.setDefaultMeaningLang),
                    langTile('Hindi', 'hi', AppState.meaningLang, AppState.setDefaultMeaningLang),
                    langTile('Telugu', 'te', AppState.meaningLang, AppState.setDefaultMeaningLang),
                    langTile('Tamil', 'ta', AppState.meaningLang, AppState.setDefaultMeaningLang),
                    langTile('Sanskrit', 'sa', AppState.meaningLang, AppState.setDefaultMeaningLang),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.heading)),
          const SizedBox(height: 12),
          ListTile(
            leading: const IconBadge(Icons.translate_rounded, size: 40),
            title: const Text('Default Language'),
            subtitle: Text('${_scriptLabels[AppState.scriptLang]} script · ${_meaningLabels[AppState.meaningLang]} meaning'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showDefaultLanguagePicker,
          ),
          ListTile(
            leading: const IconBadge(Icons.dark_mode_rounded, size: 40),
            title: const Text('Dark Mode'),
            trailing: ValueListenableBuilder<bool>(
              valueListenable: AppState.darkMode,
              builder: (context, isDark, _) {
                return Switch(
                  value: isDark,
                  onChanged: (v) => AppState.darkMode.value = v,
                  activeThumbColor: c.accent,
                );
              },
            ),
          ),
          const Divider(height: 32),
          Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.heading)),
          const SizedBox(height: 12),
          const ListTile(
            leading: IconBadge(Icons.info_rounded, size: 40),
            title: Text('Version'),
            subtitle: Text('1.0.0 (Flutter V1)'),
          ),
          ListTile(
            leading: const IconBadge(Icons.map_rounded, size: 40),
            title: const Text('Roadmap'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
