import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:expense_manager/database/hive_database.dart';
import 'package:expense_manager/theme/app_theme.dart';

class FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsPath() async => '.';

  @override
  Future<String?> getApplicationSupportPath() async => '.';

  @override
  Future<String?> getTemporaryPath() async => '.';
}

void main() {
  setUpAll(() async {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    await HiveDatabase.init();
  });

  test('La base de donnees locale s\'initialise sans erreur', () async {
    // Vérifie que Hive est bien prêt à l'emploi après l'initialisation,
    // sans passer par l'interface graphique (qui déclenche le
    // téléchargement de police, non disponible en environnement de test).
    expect(HiveDatabase.expenseBox, isNotEmpty);
  });

  test('Les themes clair et sombre se construisent sans erreur', () {
    // On vérifie juste que la construction des ThemeData ne plante pas,
    // sans réellement afficher à l'écran (donc sans déclencher le
    // chargement réseau de la police Fraunces).
    expect(AppTheme.lightTheme, isA<ThemeData>());
    expect(AppTheme.darkTheme, isA<ThemeData>());
  });
}