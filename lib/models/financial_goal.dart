import 'package:hive/hive.dart';

part 'financial_goal.g.dart';

@HiveType(typeId: 4)
class FinancialGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  double savedAmount;

  @HiveField(4)
  DateTime createdDate;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.createdDate,
  });

  double get progressPercentage => targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0.0, 1.0);
}