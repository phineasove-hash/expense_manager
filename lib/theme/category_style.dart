import 'package:flutter/material.dart';

// Associe chaque catégorie à une couleur ET une icône, dans un seul endroit.
// Si demain ta maquette change une couleur de catégorie, tu ne modifies
// qu'ici, jamais dans les écrans qui l'utilisent.
class CategoryStyle {
  static const Map<String, Color> _colors = {
    'Nourriture': Color(0xFFFF9F43), // orange
    'Transport': Color(0xFF2F6FED), // bleu
    'Logement': Color(0xFF9B59B6), // violet
    'Internet': Color(0xFF1ABC9C), // turquoise
    'Téléphone': Color(0xFF3498DB), // bleu clair
    'Éducation': Color(0xFFE74C3C), // rouge
    'Shopping': Color(0xFFE91E63), // rose
    'Loisirs': Color(0xFF27AE60), // vert
    'Sport': Color.fromARGB(255, 57, 61, 61),
    'Santé': Color(0xFF16A085), // vert foncé
    'Autre': Color(0xFF95A5A6), // gris
  };

  static const Map<String, IconData> _icons = {
    'Nourriture': Icons.fastfood,
    'Transport': Icons.directions_car,
    'Logement': Icons.home,
    'Internet': Icons.wifi,
    'Téléphone': Icons.phone_android,
    'Éducation': Icons.school,
    'Shopping': Icons.shopping_bag,
    'Loisirs': Icons.sports_esports,
    'Sport': Icons.sports_baseball,
    'Santé': Icons.local_hospital,
    'Autre': Icons.attach_money,
  };

  // Si jamais une catégorie inconnue arrive (ex: ancienne donnée),
  // on retombe sur une couleur/icône par défaut plutôt que de planter.
  static Color colorOf(String category) => _colors[category] ?? _colors['Autre']!;
  static IconData iconOf(String category) => _icons[category] ?? _icons['Autre']!;
}
