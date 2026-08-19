import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3B2C))),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF7C5A3A)),
            title: const Text('Default Language'),
            subtitle: const Text('Kannada (Auto-detected)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: Color(0xFF7C5A3A)),
            title: const Text('Dark Mode'),
            trailing: Switch(value: false, onChanged: (v) {}, activeColor: const Color(0xFFE8863A)),
          ),
          const Divider(height: 32),
          const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3B2C))),
          const SizedBox(height: 12),
          const ListTile(
            leading: Icon(Icons.info_outline, color: Color(0xFF7C5A3A)),
            title: Text('Version'),
            subtitle: Text('1.0.0 (Flutter V1)'),
          ),
          ListTile(
            leading: const Icon(Icons.map, color: Color(0xFF7C5A3A)),
            title: const Text('Roadmap'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
