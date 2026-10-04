import 'dart:io';

import 'package:expense_manager/database/hive_database.dart';
import 'package:expense_manager/models/budget.dart';
import 'package:expense_manager/models/expense.dart';
import 'package:expense_manager/models/plan_item.dart';
import 'package:expense_manager/services/alert_service.dart';
import 'package:expense_manager/services/expense_service.dart';
import 'package:expense_manager/services/plan_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late ExpenseService expenseService;
  late PlanService planService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('plan_alert_tests');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(BudgetAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PlanItemAdapter());
    }

    await Hive.openBox<Expense>(HiveDatabase.expenseBox);
    await Hive.openBox<Budget>(HiveDatabase.budgetBox);
    await Hive.openBox<PlanItem>(HiveDatabase.planItemBox);

    expenseService = ExpenseService();
    planService = PlanService();
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'should create a plan alert when an expense exceeds the monthly plan',
    () async {
      final now = DateTime.now();

      await planService.addPlanItem(
        category: 'Nourriture',
        plannedAmount: 1000,
        year: now.year,
        month: now.month,
      );

      final planItem = planService.getPlanItemForCategory(
        'Nourriture',
        now.year,
        now.month,
      );
      expect(planItem, isNotNull);
      expect(planItem!.plannedAmount, 1000);

      await expenseService.addExpense(
        name: 'Courses',
        amount: 1200,
        category: 'Nourriture',
        date: now,
      );

      final alerts = AlertService().getActiveAlerts();

      expect(alerts, isNotEmpty);
      expect(
        alerts.any(
          (alert) =>
              alert.title.contains('Plan') ||
              alert.message.contains('Nourriture'),
        ),
        isTrue,
      );
    },
  );
}
