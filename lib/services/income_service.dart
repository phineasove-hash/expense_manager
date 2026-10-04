import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/income.dart';
import '../database/hive_database.dart';

class IncomeService {
  Box<Income> get _box => Hive.box<Income>(HiveDatabase.incomeBox);
  final _uuid = const Uuid();

  //CREATE: ajouter un nouveau revenu
  Future<void> addIncome({
    required String name,
    required double amount,
    required DateTime date,
    String? note,
    bool isRecurring = false,
  }) async {
    final income = Income(
      id: _uuid.v4(),
      name: name,
      amount: amount,
      date: date,
      note: note,
      isRecurring: isRecurring,
    );
    await _box.put(income.id, income);
  }
  
  // READ : récupérer tous les revenus
  List<Income> getAllIncomes() {
    final incomes = _box.values.toList();

    incomes.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    return incomes;
  }

  //READ: tous les revenus compris entre deux dates
  List<Income> getIncomesBetween(DateTime start, DateTime end) {
    return getAllIncomes().where((i) {
      return i.date.isAfter(start.subtract(const Duration(days: 1))) &&
          i.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  //Calucul le total pour une liste de revenus donnee
  double getTotal(List<Income> incomes) {
    return incomes.fold(0.0, (sum, i) => sum + i.amount);
  }

  //UPDATE: modifier un revenu existant
  Future<void> updateIncome(Income income) async {
    await income.save();
  }

  //DELETE: supprimer un revenu
  Future<void> deleteIncome(Income income) async {
    await income.delete();
  }
}
