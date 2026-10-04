import 'package:hive_flutter/hive_flutter.dart';

import '../models/expense.dart';
import '../models/income.dart';
import '../models/budget.dart';
import '../models/plan_item.dart';
import '../models/financial_goal.dart';

// Classe utilitaire centralisant l'initialisation de Hive.
// - enregistre les adapters générés pour chaque modèle Hive
// - ouvre les boxes (boîtes de stockage) utilisées par l'app
// Toutes les méthodes sont statiques : on n'instancie pas `HiveDatabase`.
class HiveDatabase {
  static const String expenseBox = 'expenses';
  static const String incomeBox = 'incomes';
  static const String budgetBox = 'budgets';
  static const String categoryBox = 'categories';
  static const String planItemBox = 'plan_items';
  static const String financialGoalBox = 'financial_goals';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Prevents crashes if the app hot-restarts during development
    // and tries to register the same adapter twice.
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(IncomeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(BudgetAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PlanItemAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(FinancialGoalAdapter());
    }

    await Hive.openBox<Expense>(expenseBox);
    await Hive.openBox<Income>(incomeBox);
    await Hive.openBox<Budget>(budgetBox);
    await Hive.openBox<PlanItem>(planItemBox);
    await Hive.openBox<FinancialGoal>(financialGoalBox);
    // Box "générique" (sans modèle Hive dédié) : on y stocke juste une
    // liste de textes, donc pas besoin d'adapter comme pour Expense/Income/Budget.
    await Hive.openBox(categoryBox);
  }
}
