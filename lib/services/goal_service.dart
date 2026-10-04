import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/financial_goal.dart';
import '../database/hive_database.dart';

class GoalService {
  Box<FinancialGoal> get _box => Hive.box<FinancialGoal>(HiveDatabase.financialGoalBox);
  final _uuid = const Uuid();

  List<FinancialGoal> getAllGoals() {
    return _box.values.toList()..sort((a, b) => b.createdDate.compareTo(a.createdDate));
  }

  Future<void> addGoal({required String name, required double targetAmount}) async {
    final goal = FinancialGoal(
      id: _uuid.v4(),
      name: name,
      targetAmount: targetAmount,
      createdDate: DateTime.now(),
    );
    await _box.put(goal.id, goal);
  }

  // Ajoute une contribution à un objectif (par exemple, quand tu valides
  // qu'une ligne de plan "Épargne" a bien été respectée ce mois-ci).
  Future<void> addContribution(FinancialGoal goal, double amount) async {
    goal.savedAmount += amount;
    await goal.save();
  }

  Future<void> deleteGoal(FinancialGoal goal) async {
    await goal.delete();
  }
}