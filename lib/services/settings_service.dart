import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // Theme
  ThemeMode get themeMode {
    final value = _prefs.getString('themeMode') ?? 'system';
    return ThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString('themeMode', mode.name);
    notifyListeners();
  }

  // Accent color
  static const accentColors = [
    Colors.blue,
    Colors.teal,
    Colors.indigo,
    Colors.purple,
    Colors.orange,
    Colors.green,
    Colors.pink,
  ];

  Color get accentColor {
    final index = _prefs.getInt('accentIndex') ?? 0;
    return accentColors[index.clamp(0, accentColors.length - 1)];
  }

  Future<void> setAccentIndex(int index) async {
    await _prefs.setInt('accentIndex', index);
    notifyListeners();
  }

  // Units
  bool get useCelsius => _prefs.getBool('useCelsius') ?? true;

  Future<void> setUseCelsius(bool value) async {
    await _prefs.setBool('useCelsius', value);
    notifyListeners();
  }

  // Last city
  String? get lastCity => _prefs.getString('lastCity');

  Future<void> setLastCity(String city) async {
    await _prefs.setString('lastCity', city);
  }
}
