import 'package:hive/hive.dart';

part 'budget.g.dart';

// typeId 2 -> Budget
// Hive utilise ce typeId pour stocker et récupérer les objets Budget.
@HiveType(typeId: 2)
class Budget extends HiveObject {
  // Identifiant unique du budget.
  @HiveField(0)
  String id;

  // Montant total prévu pour le budget.
  @HiveField(1)
  double totalAmount;

  // Date de début de la période du budget.
  @HiveField(2)
  DateTime startDate;

  // Date de fin de la période du budget.
  @HiveField(3)
  DateTime endDate;

  // Indique si le budget est actif.
  @HiveField(4)
  bool isActive;

  Budget({
    required this.id,
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  bool isDateInRange(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        date.isBefore(endDate.add(const Duration(days: 1)));
  }
}
