import 'package:hive/hive.dart';

part 'plan_item.g.dart';

// Modèle `PlanItem` : représente une ligne du plan mensuel.
// - Annoté pour Hive (génération d'un adapter via build_runner).
// - `typeId` doit être unique parmi les modèles enregistrés.
@HiveType(typeId: 3)
class PlanItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String category;

  @HiveField(2)
  double plannedAmount;

  @HiveField(3)
  int year;

  @HiveField(4)
  int month;

  @HiveField(5)
  String? linkedGoalId;

  PlanItem({
    required this.id,
    required this.category,
    required this.plannedAmount,
    required this.year,
    required this.month,
    this.linkedGoalId,
  });
}
