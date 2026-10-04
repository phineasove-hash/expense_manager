import 'package:hive/hive.dart';

import '../database/hive_database.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/budget.dart';

class AppDataService {
  // Vide les transactions et budgets, mais on garde volontairement
  // les catégories personnalisées de l'utilisateur (pas de raison de
  // les perdre juste parce qu'il efface ses dépenses).
  Future<void> resetAllData() async {
    await Hive.box<Expense>(HiveDatabase.expenseBox).clear();
    await Hive.box<Income>(HiveDatabase.incomeBox).clear();
    await Hive.box<Budget>(HiveDatabase.budgetBox).clear();
  }

  int getTransactionCount() {
    final expenses = Hive.box<Expense>(HiveDatabase.expenseBox).length;
    final incomes = Hive.box<Income>(HiveDatabase.incomeBox).length;
    return expenses + incomes;
  }
}