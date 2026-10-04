import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/plan_item.dart';
import '../database/hive_database.dart';
import 'expense_service.dart';

class PlanService {
  Box<PlanItem> get _box => Hive.box<PlanItem>(HiveDatabase.planItemBox);
  final _uuid = const Uuid();
  final ExpenseService _expenseService = ExpenseService();

  // Récupère toutes les lignes de planification pour un mois donné
  List<PlanItem> getPlanForMonth(int year, int month) {
    return _box.values.where((item) => item.year == year && item.month == month).toList();
  }

  // Ajoute une nouvelle ligne au plan
  Future<void> addPlanItem({
    required String category,
    required double plannedAmount,
    required int year,
    required int month,
    String? linkedGoalId,
  }) async {
    final item = PlanItem(
      id: _uuid.v4(),
      category: category,
      plannedAmount: plannedAmount,
      year: year,
      month: month,
      linkedGoalId: linkedGoalId,
    );
    await _box.put(item.id, item);
  }

  Future<void> updatePlanItem(PlanItem item, double newAmount) async {
    item.plannedAmount = newAmount;
    await item.save();
  }

  Future<void> deletePlanItem(PlanItem item) async {
    await item.delete();
  }

  // Duplique le plan du mois précédent vers le mois donné,
  // seulement si le nouveau mois n'a pas déjà un plan existant
  // (évite d'écraser un plan déjà en cours si on rappelle par erreur).
  Future<void> duplicatePreviousMonthIfNeeded(int year, int month) async {
    final currentPlan = getPlanForMonth(year, month);
    if (currentPlan.isNotEmpty) return; // déjà un plan ce mois-ci, on ne touche à rien

    // Calcule le mois précédent (gère le passage décembre -> janvier)
    final previousMonth = month == 1 ? 12 : month - 1;
    final previousYear = month == 1 ? year - 1 : year;

    final previousPlan = getPlanForMonth(previousYear, previousMonth);
    if (previousPlan.isEmpty) return; // rien à dupliquer

    for (final oldItem in previousPlan) {
      await addPlanItem(
        category: oldItem.category,
        plannedAmount: oldItem.plannedAmount,
        year: year,
        month: month,
        linkedGoalId: oldItem.linkedGoalId,
      );
    }
  }

  // Calcule, pour chaque ligne du plan, le montant réellement dépensé
  // dans cette catégorie sur le mois concerné. Retourne une Map
  // { category: (prévu, réel) } pour un affichage facile.
  Map<String, ({double planned, double actual})> getComparisonForMonth(int year, int month) {
    final planItems = getPlanForMonth(year, month);
    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0);

    final expenses = _expenseService.getExpensesBetween(monthStart, monthEnd);
    final actualByCategory = _expenseService.getTotalByCategory(expenses);

    final Map<String, ({double planned, double actual})> comparison = {};
    for (final item in planItems) {
      comparison[item.category] = (
        planned: item.plannedAmount,
        actual: actualByCategory[item.category] ?? 0.0,
      );
    }
    return comparison;
  }
  // Cherche s'il existe une ligne de plan pour cette catégorie précise,
  // sur le mois donné. Retourne null s'il n'y en a pas.
  PlanItem? getPlanItemForCategory(String category, int year, int month) {
    final items = getPlanForMonth(year, month);
    try {
      return items.firstWhere((item) => item.category == category);
    } catch (e) {
      return null;
    }
  }
}