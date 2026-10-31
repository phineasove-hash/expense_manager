import 'package:hive/hive.dart';

import '../database/hive_database.dart';
import '../models/budget.dart';
import 'budget_service.dart';
import 'expense_service.dart';
import 'plan_service.dart';

// Représente une alerte : un identifiant stable, un titre, un message, une gravité.
class BudgetAlert {
  // Identifiant stable : il permet de savoir si l'utilisateur a déjà vu cette alerte,
  // même si le message change légèrement (ex: le montant du dépassement).
  final String key;
  final String title;
  final String message;
  final AlertLevel level;

  BudgetAlert({
    required this.key,
    required this.title,
    required this.message,
    required this.level,
  });
}

enum AlertLevel { warning, danger, success }

class AlertService {
  final BudgetService _budgetService = BudgetService();
  final PlanService _planService = PlanService();
  final ExpenseService _expenseService = ExpenseService();

  static const String _seenKeysField = 'seen_alert_keys';

  // On réutilise la box générique (la même que pour les réglages).
  Box get _settingsBox => Hive.box(HiveDatabase.categoryBox);

  Set<String> _getSeenKeys() {
    final stored = _settingsBox.get(_seenKeysField);
    if (stored == null) return <String>{};
    return List<String>.from(stored).toSet();
  }

  // Nombre d'alertes que l'utilisateur n'a pas encore consultées
  // (c'est ce nombre qui décide si le point rouge s'affiche).
  int getUnseenCount() {
    final seen = _getSeenKeys();
    return getActiveAlerts().where((alert) => !seen.contains(alert.key)).length;
  }

  // Marque toutes les alertes actuelles comme vues.
  // On remplace la liste par les alertes actuelles : si une alerte disparaît
  // puis revient plus tard, elle compte de nouveau comme nouvelle.
  Future<void> markAllAsSeen() async {
    final keys = getActiveAlerts().map((alert) => alert.key).toList();
    await _settingsBox.put(_seenKeysField, keys);
  }

  // Calcule la liste des alertes actives. Rien n'est stocké : recalculé à chaque appel.
  List<BudgetAlert> getActiveAlerts() {
    final List<BudgetAlert> alerts = [];

    final Budget? budget = _budgetService.getActiveBudget();
    if (budget != null) {
      final usage = _budgetService.getUsagePercentage(budget);
      final remainingDays = _budgetService.getRemainingDays(budget);

      if (usage >= 1.0) {
        alerts.add(
          BudgetAlert(
            key: 'budget_exceeded_${budget.id}',
            title: 'Budget dépassé',
            message:
                'Tu as dépensé 100% ou plus de ton budget de ${budget.totalAmount.toStringAsFixed(0)} FCFA.',
            level: AlertLevel.danger,
          ),
        );
      } else if (usage >= 0.8) {
        alerts.add(
          BudgetAlert(
            key: 'budget_warning_${budget.id}',
            title: 'Attention à ton budget',
            message:
                'Tu as déjà utilisé ${(usage * 100).toStringAsFixed(0)}% de ton budget. '
                'Il te reste $remainingDays jour${remainingDays > 1 ? 's' : ''}.',
            level: AlertLevel.warning,
          ),
        );
      } else if (remainingDays <= 3 && usage < 0.8) {
        alerts.add(
          BudgetAlert(
            key: 'budget_success_${budget.id}',
            title: 'Bien joué !',
            message: 'Ton budget est encore bien respecté à quelques jours de la fin de la période.',
            level: AlertLevel.success,
          ),
        );
      }
    }

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final monthlyExpenses = _expenseService.getExpensesBetween(monthStart, monthEnd);
    final actualByCategory = _expenseService.getTotalByCategory(monthlyExpenses);

    for (final planItem in _planService.getPlanForMonth(now.year, now.month)) {
      final actual = actualByCategory[planItem.category] ?? 0.0;
      if (actual <= planItem.plannedAmount) {
        continue;
      }

      final overrun = actual - planItem.plannedAmount;
      alerts.add(
        BudgetAlert(
          key: 'plan_${now.year}_${now.month}_${planItem.category}',
          title: 'Plan dépassé',
          message:
              'Tu as dépassé ton plan "${planItem.category}" de ${overrun.toStringAsFixed(0)} FCFA ce mois-ci (${actual.toStringAsFixed(0)} / ${planItem.plannedAmount.toStringAsFixed(0)} FCFA).',
          level: AlertLevel.warning,
        ),
      );
    }

    return alerts;
  }
}