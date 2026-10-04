import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/budget.dart';
import '../database/hive_database.dart';
import 'expense_service.dart';

class BudgetService {
  Box<Budget> get _box => Hive.box<Budget>(HiveDatabase.budgetBox);
  final _uuid = const Uuid();

  // Ce service a besoin du service des dépenses pour ses calculs
  // (combien a-t-on dépensé dans la période du budget).
  final ExpenseService _expenseService = ExpenseService();

  // Créer un nouveau budget désactive automatiquement l'ancien,
  // pour respecter la règle "un seul budget actif à la fois".
  Future<void> setNewBudget({
    required double totalAmount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    for (final existingBudget in _box.values) {
      if (existingBudget.isActive) {
        existingBudget.isActive = false;
        await existingBudget.save();
      }
    }

    final budget = Budget(
      id: _uuid.v4(),
      totalAmount: totalAmount,
      startDate: startDate,
      endDate: endDate,
      isActive: true,
    );
    await _box.put(budget.id, budget);
  }

  // Créer un nouveau budget désactive automatiquement l'ancien,
  // pour respecter la règle "un seul budget actif à la fois".
  Budget? getActiveBudget() {
    try {
      return _box.values.firstWhere((b) => b.isActive);
    } catch (e) {
      // firstWhere lève une erreur si rien n'est trouvé :
      // on transforme ça simplement en "pas de budget actif" (null).
      return null;
    }
  }

  //Historique des budgets passees du plus recent au plus au plus ancien
  List<Budget> getBudgetHistory() {
    final budgets = _box.values.where((b) => !b.isActive).toList();
    budgets.sort((a, b) => b.startDate.compareTo(a.startDate));
    return budgets;
  }

  //Calcule combien a ete depensee sur la periode du budget actif
  double getSpentAmount(Budget budget) {
    final expenses = _expenseService.getExpensesBetween(
      budget.startDate,
      budget.endDate,
    );
    return _expenseService.getTotal(expenses);
  }

  //Calcul combien il reste sur le budget
  double getRemainingAmount(Budget budget) {
    return budget.totalAmount - getSpentAmount(budget);
  }

  //Retourne un pourcentage entre 0.0 et 1.0 (Pour la barre de progression)
  double getUsagePercentage(Budget budget) {
    if (budget.totalAmount <= 0) return 0.0;
    final percentage = getSpentAmount(budget) / budget.totalAmount;
    //On limite entre 0 et 1 meme si l'utilisateur depasse son budget
    return percentage.clamp(0.0, 1.0);
  }

  //Nombre de jour restantd dans la periode du budget
  int getRemainingDays(Budget budget) {
    final today = DateTime.now();
    final remaining = budget.endDate.difference(today).inDays;
    return remaining < 0 ? 0 : remaining;
  }
  
  // Modifie uniquement le montant du budget actif, sans le remplacer
  // ni toucher à sa période (contrairement à setNewBudget).
  Future<void> updateBudgetAmount(Budget budget, double newAmount) async {
    budget.totalAmount = newAmount;
    await budget.save();
  }

  // Modifie uniquement la période du budget actif, sans toucher au montant.
  Future<void> updateBudgetPeriod(Budget budget, DateTime newStart, DateTime newEnd) async {
    budget.startDate = newStart;
    budget.endDate = newEnd;
    await budget.save();
  }


}
