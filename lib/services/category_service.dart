import 'package:hive/hive.dart';

import '../database/hive_database.dart';

class CategoryService {
  // Les catégories de départ, utilisées uniquement au tout premier
  // lancement de l'app, avant que l'utilisateur n'en modifie la liste.
  static const List<String> _defaultCategories = [
    'Nourriture', 'Transport', 'Logement', 'Internet', 'Téléphone',
    'Éducation', 'Shopping', 'Loisirs', 'Santé', 'Autre',
  ];

  Box get _box => Hive.box(HiveDatabase.categoryBox);

  // Récupère la liste actuelle. Si c'est la toute première fois
  // (aucune liste enregistrée), on initialise avec les valeurs par défaut.
  List<String> getCategories() {
    final stored = _box.get('list');
    if (stored == null) {
      _box.put('list', _defaultCategories);
      return List<String>.from(_defaultCategories);
    }
    return List<String>.from(stored);
  }

  Future<void> addCategory(String name) async {
    final categories = getCategories();
    if (categories.contains(name)) return; // évite les doublons
    categories.add(name);
    await _box.put('list', categories);
  }

  Future<void> deleteCategory(String name) async {
    // "Autre" reste toujours disponible : c'est la catégorie de secours
    // utilisée par CategoryStyle quand une catégorie est inconnue.
    if (name == 'Autre') return;
    final categories = getCategories();
    categories.remove(name);
    await _box.put('list', categories);
  }
}