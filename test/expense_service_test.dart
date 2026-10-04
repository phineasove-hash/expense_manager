import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:expense_manager/models/expense.dart';
import 'package:expense_manager/services/expense_service.dart';

void main() {
  late ExpenseService expenseService;
  late Directory tempDir;

  setUp(() async {
    // 1. Dossier temporaire pour isoler les données du test
    tempDir = await Directory.systemTemp.createTemp('hive_expense_tests');
    Hive.init(tempDir.path);

    // 2. Enregistrement de l'adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseAdapter());
    }

    // 3. Ouverture de la boîte Hive utilisée par ExpenseService
    await Hive.openBox<Expense>('expenses');

    expenseService = ExpenseService();
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ExpenseService - Tests Unitaires Complétes', () {
    test('Doit ajouter une dépense avec succès et la récupérer', () async {
      final now = DateTime.now();

      await expenseService.addExpense(
        name: 'Café',
        amount: 3.50,
        category: 'Nourriture',
        date: now,
      );

      final expenses = expenseService.getAllExpenses();

      expect(expenses.length, 1);
      expect(expenses.first.name, 'Café');
      expect(expenses.first.amount, 3.50);
      expect(expenses.first.category, 'Nourriture');
    });

    test('Doit calculer le total des dépenses correctement', () async {
      final now = DateTime.now();

      await expenseService.addExpense(
        name: 'Courses',
        amount: 50.0,
        category: 'Alimentation',
        date: now,
      );

      await expenseService.addExpense(
        name: 'Essence',
        amount: 40.0,
        category: 'Transport',
        date: now,
      );

      final expenses = expenseService.getAllExpenses();
      final total = expenseService.getTotal(expenses);

      expect(total, 90.0);
    });

    test('Doit calculer le total par catégorie', () async {
      final now = DateTime.now();

      await expenseService.addExpense(
        name: 'Burger',
        amount: 15.0,
        category: 'Nourriture',
        date: now,
      );

      await expenseService.addExpense(
        name: 'Pizza',
        amount: 20.0,
        category: 'Nourriture',
        date: now,
      );

      await expenseService.addExpense(
        name: 'Bus',
        amount: 5.0,
        category: 'Transport',
        date: now,
      );

      final expenses = expenseService.getAllExpenses();
      final totalsByCategory = expenseService.getTotalByCategory(expenses);

      expect(totalsByCategory['Nourriture'], 35.0);
      expect(totalsByCategory['Transport'], 5.0);
    });

    test('Doit supprimer une dépense', () async {
      final now = DateTime.now();

      await expenseService.addExpense(
        name: 'Livre',
        amount: 12.0,
        category: 'Loisirs',
        date: now,
      );

      var expenses = expenseService.getAllExpenses();
      expect(expenses.length, 1);

      // Suppression
      await expenseService.deleteExpense(expenses.first);

      expenses = expenseService.getAllExpenses();
      expect(expenses.length, 0);
    });
  });
}