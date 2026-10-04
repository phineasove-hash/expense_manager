import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../database/hive_database.dart';

class SettingsService {
  Box get _box => Hive.box(HiveDatabase.categoryBox); // on réutilise la box générique existante

  // On stocke le choix sous forme de texte simple : 'light', 'dark', 'system'
  ThemeMode getThemeMode() {
    final stored = _box.get('theme_mode', defaultValue: 'system');
    switch (stored) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await _box.put('theme_mode', value);
  }
}