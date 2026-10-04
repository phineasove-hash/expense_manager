import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/budget.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../services/budget_service.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';
import '../theme/app_colors.dart';
import '../widgets/chart_widget.dart';
import '../widgets/app_drawer.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final IncomeService _incomeService = IncomeService();
  final BudgetService _budgetService = BudgetService();

  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  DateTime get _monthStart =>
      DateTime(selectedMonth.year, selectedMonth.month, 1);
  DateTime get _monthEnd =>
      DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

  void _changeMonth(int offset) {
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + offset,
      );
    });
  }

  List<FlSpot> _buildBalanceSpots(
    List<Expense> expensesInMonth,
    List<Income> incomesInMonth,
  ) {
    final daysInMonth = _monthEnd.day;
    double runningBalance = 0;
    final List<FlSpot> spots = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final dayExpenses = expensesInMonth.where((e) => e.date.day == day);
      final dayIncomes = incomesInMonth.where((i) => i.date.day == day);

      for (final e in dayExpenses) {
        runningBalance -= e.amount;
      }
      for (final i in dayIncomes) {
        runningBalance += i.amount;
      }

      spots.add(FlSpot(day.toDouble(), runningBalance));
    }

    return spots;
  }

  List<double> _buildWeekdayTotals(List<Expense> expensesInMonth) {
    final List<double> totals = List.filled(7, 0.0);
    for (final expense in expensesInMonth) {
      final index = expense.date.weekday - 1;
      totals[index] += expense.amount;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final expensesInMonth = _expenseService.getExpensesBetween(
      _monthStart,
      _monthEnd,
    );
    final incomesInMonth = _incomeService.getIncomesBetween(
      _monthStart,
      _monthEnd,
    );
    final categoryTotals = _expenseService.getTotalByCategory(expensesInMonth);
    final balanceSpots = _buildBalanceSpots(expensesInMonth, incomesInMonth);
    final weekdayTotals = _buildWeekdayTotals(expensesInMonth);

    final totalExpenses = _expenseService.getTotal(expensesInMonth);
    final totalIncomes = _incomeService.getTotal(incomesInMonth);
    final monthBalance = totalIncomes - totalExpenses;
    final Budget? activeBudget = _budgetService.getActiveBudget();

    const monthNames = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)) : Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
        title: const Text('Statistiques', style: TextStyle(fontWeight: FontWeight.bold)),
      ),  
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélecteur de mois
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cardBackground(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _changeMonth(-1),
                  ),
                  Text(
                    '${monthNames[selectedMonth.month - 1]} ${selectedMonth.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _changeMonth(1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Résumé du mois
            _buildStatCard('Revenus du mois', totalIncomes, AppColors.income),
            const SizedBox(height: 10),
            _buildStatCard(
              'Dépenses du mois',
              totalExpenses,
              AppColors.expense,
            ),
            const SizedBox(height: 10),
            _buildStatCard(
              'Solde du mois',
              monthBalance,
              monthBalance >= 0 ? AppColors.income : AppColors.expense,
            ),
            const SizedBox(height: 16),

            if (activeBudget != null) _buildBudgetSummary(activeBudget),

            const SizedBox(height: 24),
            _buildChartCard(
              'Dépenses par catégorie',
              CategoryPieChart(categoryTotals: categoryTotals),
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              'Évolution du solde',
              BalanceLineChart(spots: balanceSpots),
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              'Dépenses par jour',
              WeekdayBarChart(amountsByWeekday: weekdayTotals),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, double value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)} FCFA',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummary(Budget budget) {
    final spent = _budgetService.getSpentAmount(budget);
    final remaining = _budgetService.getRemainingAmount(budget);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget actif',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Montant : ${budget.totalAmount.toStringAsFixed(0)} FCFA',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 13,
            ),
          ),
          Text(
            'Dépensé : ${spent.toStringAsFixed(0)} FCFA',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 13,
            ),
          ),
          Text(
            'Restant : ${remaining.toStringAsFixed(0)} FCFA',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toLowerCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          chart,
        ],
      ),
    );
  }
}