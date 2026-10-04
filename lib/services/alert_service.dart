import '../models/budget.dart';
import 'budget_service.dart';
import 'expense_service.dart';
import 'plan_service.dart';

// Représente une alerte simple : un titre, un message, un niveau de gravité.
class BudgetAlert {
  final String title;
  final String message;
  final AlertLevel level;

  BudgetAlert({
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

  // Calcule la liste des alertes actives, à partir du budget actif.
  // Pas de stockage : recalculé à chaque appel, toujours à jour.
  List<BudgetAlert> getActiveAlerts() {
    final List<BudgetAlert> alerts = [];

    final Budget? budget = _budgetService.getActiveBudget();
    if (budget != null) {
      final usage = _budgetService.getUsagePercentage(budget);
      final remainingDays = _budgetService.getRemainingDays(budget);

      // Dépassement complet
      if (usage >= 1.0) {
        alerts.add(
          BudgetAlert(
            title: 'Budget dépassé',
            message:
                'Tu as dépensé 100% ou plus de ton budget de ${budget.totalAmount.toStringAsFixed(0)} FCFA.',
            level: AlertLevel.danger,
          ),
        );
      }
      // Zone d'alerte (80-99%)
      else if (usage >= 0.8) {
        alerts.add(
          BudgetAlert(
            title: 'Attention à ton budget',
            message:
                'Tu as déjà utilisé ${(usage * 100).toStringAsFixed(0)}% de ton budget. '
                'Il te reste $remainingDays jour${remainingDays > 1 ? 's' : ''}.',
            level: AlertLevel.warning,
          ),
        );
      }
      // Budget respecté et proche de la fin de période -> message positif
      else if (remainingDays <= 3 && usage < 0.8) {
        alerts.add(
          BudgetAlert(
            title: 'Bien joué !',
            message:
                'Ton budget est encore bien respecté à quelques jours de la fin de la période.',
            level: AlertLevel.success,
          ),
        );
      }
    }

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final monthlyExpenses = _expenseService.getExpensesBetween(
      monthStart,
      monthEnd,
    );
    final actualByCategory = _expenseService.getTotalByCategory(
      monthlyExpenses,
    );

    for (final planItem in _planService.getPlanForMonth(now.year, now.month)) {
      final actual = actualByCategory[planItem.category] ?? 0.0;
      if (actual <= planItem.plannedAmount) {
        continue;
      }

      final overrun = actual - planItem.plannedAmount;
      alerts.add(
        BudgetAlert(
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
