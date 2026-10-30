import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Theme'),
                  subtitle: Text(settings.themeMode.name),
                  trailing: DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                    ],
                    onChanged: (v) {
                      if (v != null) settings.setThemeMode(v);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Accent color'),
                  subtitle: const Text('Tap a color'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Wrap(
                    spacing: 10,
                    children: List.generate(SettingsService.accentColors.length, (i) {
                      final color = SettingsService.accentColors[i];
                      final selected = settings.accentColor == color;
                      return GestureDetector(
                        onTap: () => settings.setAccentIndex(i),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text('Units', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              title: const Text('Use Celsius'),
              subtitle: Text(settings.useCelsius ? '°C' : '°F'),
              value: settings.useCelsius,
              onChanged: (v) => settings.setUseCelsius(v),
            ),
          ),

          const SizedBox(height: 24),
          Text('About', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('Open Weather'),
                  subtitle: Text('Version 1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Data source'),
                  subtitle: const Text('Open-Meteo (CC BY 4.0)'),
                  onTap: () {},
                ),
                const Divider(height: 1),
                const ListTile(
                  title: Text('License'),
                  subtitle: Text('MIT'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
