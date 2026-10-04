import 'package:flutter/material.dart';

import 'settings_service.dart';

// Un contrôleur global et unique (singleton) pour le thème de l'app.
// N'importe quel écran peut lire ou modifier le thème directement via
// ThemeController.instance, sans avoir besoin de le recevoir en paramètre.
class ThemeController {
  ThemeController._(); // constructeur privé : personne ne peut créer d'instance directement

  static final ThemeController instance = ThemeController._();

  final SettingsService _settingsService = SettingsService();

  // ValueNotifier : une "boîte" qui contient une valeur et prévient
  // automatiquement tous ceux qui l'écoutent quand elle change.
  late final ValueNotifier<ThemeMode> themeMode = ValueNotifier(_settingsService.getThemeMode());

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode; // change la valeur -> notifie tous les écrans qui écoutent
    _settingsService.setThemeMode(mode); // sauvegarde le choix pour la prochaine ouverture
  }
}