import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../database/hive_database.dart';

class ExpenseService {
  Box<Expense> get _box => Hive.box<Expense>(HiveDatabase.expenseBox);
  final _uuid = const Uuid();

  Future<void> addExpense({
    required String name,
    required double amount,
    required String category,
    required DateTime date,
    String? note,
    bool isRecurring = false,
    String? linkedGoalId,
  }) async {
  final expense = Expense(
    id: _uuid.v4(),
    name: name,
    amount: amount,
    category: category,
    date: date,
    note: note,
    isRecurring: isRecurring,
    linkedGoalId: linkedGoalId,
  );
  await _box.put(expense.id, expense);
  }

  List<Expense> getAllExpenses() {
    final expenses = _box.values.toList();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  List<Expense> getExpensesBetween(DateTime start, DateTime end) {
    return getAllExpenses().where((e) {
      return e.date.isAfter(start.subtract(const Duration(days: 1))) &&
          e.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  double getTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  // UPDATE : modifier une dépense existante
  Future<void> updateExpense(Expense expense) async {
    await expense.save();
  }

  // DELETE : supprimer une dépense
  Future<void> deleteExpense(Expense expense) async {
    await expense.delete();
  }

  Map<String, double> getTotalByCategory(List<Expense> expenses) {
    final Map<String, double> totals = {};
    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  // Toutes les dépenses liées à un objectif financier précis
  List<Expense> getExpensesLinkedToGoal(String goalId) {
    return getAllExpenses().where((e) => e.linkedGoalId == goalId).toList();
  }

  // Total dépensé "pour" un objectif (différent du montant épargné !)
  double getTotalSpentForGoal(String goalId) {
    return getTotal(getExpensesLinkedToGoal(goalId));
  }
}