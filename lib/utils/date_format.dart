const List<String> _monthNames = [
  'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
  'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
];

// Ajoute un zéro devant les jours à un seul chiffre (1 -> "01")
String _twoDigits(int n) => n < 10 ? '0$n' : '$n';

// Formate une période budgétaire, ex: "01 Juillet - 31 Juillet 2026"
String formatBudgetPeriod(DateTime start, DateTime end) {
  final startText = '${_twoDigits(start.day)} ${_monthNames[start.month - 1]}';
  final endText = '${_twoDigits(end.day)} ${_monthNames[end.month - 1]} ${end.year}';
  return '$startText - $endText';
}