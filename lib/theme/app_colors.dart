import 'package:flutter/material.dart';

class AppColors {
  // Couleurs de marque : identiques dans les deux thèmes.
  // Palette ancrée dans la teinture textile ouest-africaine
  // (indigo, or) plutôt qu'une palette "fintech" générique.
  static const Color primary = Color(0xFFB94A3D); // brique/terre cuite (dépenses, actions)
  static const Color secondary = Color(0xFF14213D); // indigo profond
  static const Color gold = Color(0xFFC9A227); // accent or, signature de l'app

  static const Color income = Color(0xFF3E7C59); // vert forêt
  static const Color expense = Color(0xFFB94A3D); // brique
  static const Color warning = Color(0xFFC9A227); // or (réutilisé pour cohérence)
  static const Color danger = Color(0xFFB94A3D);
  static const Color success = Color(0xFF3E7C59);

  // Fonds et textes, propres à chaque thème
  static const Color lightBackground = Color(0xFFF7F3EC); // papier chaud, pas blanc froid
  static const Color darkBackground = Color(0xFF0B0F1A); // indigo quasi-noir, plus sombre que "secondary"
  static const Color lightCardBackground = Colors.white;
  static const Color darkCardBackground = Color(0xFF1E2C4D);

  static const Color lightTextPrimary = Color(0xFF14213D); // indigo, pas noir pur
  static const Color darkTextPrimary = Color(0xFFF7F3EC);

  static const Color lightTextSecondary = Color(0xFF8A8474); // brun-gris chaud
  static const Color darkTextSecondary = Color(0xFFA9B0C8);

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;
  }

  static Color cardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkCardBackground : lightCardBackground;
  }

  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  }
}