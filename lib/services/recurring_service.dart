import '../models/expense.dart';
import '../models/income.dart';
import 'expense_service.dart';
import 'income_service.dart';

class RecurringService {
  final ExpenseService _expenseService = ExpenseService();
  final IncomeService _incomeService = IncomeService();

  //point d'entree principal a appeler une fois au demarrage de l'appli
  Future<void> generateDueRecurringTransaction() async {
    final now = DateTime.now();
    await _generateExpenses(now);
    await _generateIncomes(now);
  }

  // Calcule "le même jour, le mois suivant", en gérant le cas où le jour
  // n'existe pas dans le mois suivant (ex: 31 janvier -> 28/29 février,
  // pas "3 mars" comme le ferait un calcul naïf).
  DateTime _nextMonth(DateTime date) {
    final year = date.month == 12 ? date.year + 1 : date.year;
    final month = date.month == 12 ? 1 : date.month + 1;
    final daysInNextMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > daysInNextMonth ? daysInNextMonth : date.day;
    return DateTime(year, month, day);
  }

  Future<void> _generateExpenses(DateTime now) async {
    final allExpenses = _expenseService.getAllExpenses();
    final recurringOnes = allExpenses.where((e) => e.isRecurring).toList();

    //On regroupe par "nom + categorie" pour identifier chaque serie
    //recurrente , et ne garder que l'occurrence la plus recente de chacune.
    final Map<String, Expense> latestBySeries = {};
    for (final e in recurringOnes) {
      final key = '${e.name}|${e.category}';
      final current = latestBySeries[key];
      if (current == null || e.date.isAfter(current.date)) {
        latestBySeries[key] = e;
      }
    }

    for (final last in latestBySeries.values) {
      DateTime nextDate = _nextMonth(last.date);

      //Boucle pour rattraper plusier mois manques d'affilee , pas juste le mois suivant immediat.
      while (!nextDate.isAfter(now)) {
        final alreadyExicts = allExpenses.any(
          (e) =>
              e.name == last.name &&
              e.category == last.category &&
              e.date.year == nextDate.year &&
              e.date.month == nextDate.month,
        );

        if (!alreadyExicts) {
          await _expenseService.addExpense(
            name: last.name,
            amount: last.amount,
            category: last.category,
            date: nextDate,
            note: last.note,
            isRecurring: true,
          );
        }
        nextDate = _nextMonth(nextDate);
      }
    }
  }

  Future<void> _generateIncomes(DateTime now) async {
    final allIncomes = _incomeService.getAllIncomes();
    final recurringOnes = allIncomes.where((i) => i.isRecurring).toList();

    final Map<String, Income> latestBySeries = {};
    for (final i in recurringOnes) {
      final key = i.name;
      final current = latestBySeries[key];
      if (current == null || i.date.isAfter(current.date)) {
        latestBySeries[key] = i;
      }
    }

    for (final last in latestBySeries.values) {
      DateTime nextDate = _nextMonth(last.date);

      while (!nextDate.isAfter(now)) {
        final alreadyExists = allIncomes.any(
          (i) =>
              i.name == last.name &&
              i.date.year == nextDate.year &&
              i.date.month == nextDate.month,
        );
        if (!alreadyExists) {
          await _incomeService.addIncome(
            name: last.name,
            amount: last.amount,
            date: nextDate,
            note: last.note,
            isRecurring: true,
          );
        }
        nextDate = _nextMonth(nextDate);
      }
    }
  }
}
