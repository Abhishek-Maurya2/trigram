import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Mode',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: themeNotifier.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeNotifier.setThemeMode(value);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: themeNotifier.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeNotifier.setThemeMode(value);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: themeNotifier.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeNotifier.setThemeMode(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
