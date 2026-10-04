import 'package:hive/hive.dart';

part 'expense.g.dart';

// typeId 0 -> Expense
// Hive utilise ce typeId pour enregistrer et récupérer les objets Expense.
@HiveType(typeId: 0)
class Expense extends HiveObject {
  // Identifiant unique de la dépense.
  @HiveField(0)
  String id;

  // Nom de la dépense, affiché dans l'application.
  // Exemple : "Café", "Essence".
  @HiveField(1)
  String name;

  // Catégorie de la dépense.
  // Exemple : "Nourriture", "Transport", "Loisirs".
  @HiveField(2)
  String category;

  // Montant de la dépense.
  @HiveField(3)
  double amount;

  // Date de la dépense.
  @HiveField(4)
  DateTime date;

  // Note facultative pour ajouter des détails.
  @HiveField(5)
  String? note;

  // Indique si la dépense est récurrente.
  @HiveField(6)
  bool isRecurring;

  @HiveField(7)
  String? linkedGoalId; // null si cette dépense n'est liée à aucun objectif

  Expense({
  required this.id,
  required this.name,
  required this.amount,
  required this.category,
  required this.date,
  this.note,
  this.isRecurring = false,
  this.linkedGoalId,
});
}
