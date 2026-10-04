import 'package:hive/hive.dart';

part 'income.g.dart';

// typeId 1 -> doit être différent de celui de Expense (qui est 0)
// Hive utilise ce typeId pour identifier les objets enregistrés dans la base.
@HiveType(typeId: 1)
class Income extends HiveObject {
  // Identifiant unique de l'entrée de revenu.
  @HiveField(0)
  String id;

  // Nom du revenu affiché dans l'application.
  // Exemple : "Salaire" ou "Freelance".
  @HiveField(1)
  String name;

  // Montant du revenu.
  @HiveField(2)
  double amount;

  // Date du revenu.
  @HiveField(3)
  DateTime date;

  // Champ optionnel pour une note ou une description complémentaire.
  @HiveField(4)
  String? note;

  // Indique si le revenu est récurrent (mensuel, etc.).
  @HiveField(5)
  bool isRecurring;

  Income({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    this.note,
    this.isRecurring = false,
  });
}
