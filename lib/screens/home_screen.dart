import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/budget.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';
import '../services/budget_service.dart';
import '../theme/app_colors.dart';
import '../widgets/balance_card.dart';
import '../widgets/budget_progress.dart';
import '../widgets/expense_card.dart';
import '../widgets/income_card.dart';
import '../widgets/chart_widget.dart';
import 'add_transaction_screen.dart';
import 'expense_detail_screen.dart';
import 'income_detail_screen.dart';
import '../widgets/app_drawer.dart';
import '../services/alert_service.dart';
import 'notifications_screen.dart';
import 'transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final IncomeService _incomeService = IncomeService();
  final BudgetService _budgetService = BudgetService();

  // Fusionne dépenses et revenus en une seule liste triée par date
  // (du plus récent au plus ancien), puis transforme chaque élément
  // en la bonne carte visuelle (ExpenseCard ou IncomeCard).
  List<Widget> _buildMergedTransactions(
    List<Expense> allExpenses,
    List allIncomes,
  ) {
    final List<dynamic> merged = [...allExpenses, ...allIncomes];
    merged.sort((a, b) => b.date.compareTo(a.date));

    return merged.map<Widget>((item) {
      // On regarde le type réel de l'objet pour savoir quelle carte utiliser.
      if (item is Expense) {
        return ExpenseCard(
          expense: item,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExpenseDetailScreen(expense: item),
              ),
            );
            if (result == true) setState(() {});
          },
        );
      } else {
        return IncomeCard(
          income: item,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IncomeDetailScreen(income: item),
              ),
            );
            if (result == true) setState(() {});
          },
        );
      }
    }).toList();
  }

  //Construit les points de la courbe sur les 30 derniers jours,
  //peu importe le mois calendaire(contrairement a statistique qui
  //suit un mois precis). Ca garanti toujours une courbe visible,
  //meme le 2 du mois.
  List<FlSpot> _buildRecentBalanceSpots(
    List<Expense> allExpenses,
    List allIncomes,
  ) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 29));

    final expensesInRange = _expenseService.getExpensesBetween(startDate, now);
    final incomesInRange = _incomeService.getIncomesBetween(startDate, now);

    double runningBalance = 0;
    final List<FlSpot> spots = [];

    for (int i = 0; i < 30; i++) {
      final currentDate = startDate.add(Duration(days: i));

      final daysExpenses = expensesInRange.where(
        (e) =>
            e.date.year == currentDate.year &&
            e.date.month == currentDate.month &&
            e.date.day == currentDate.day,
      );
      final daysIncomes = incomesInRange.where(
        (inc) =>
            inc.date.year == currentDate.year &&
            inc.date.month == currentDate.month &&
            inc.date.day == currentDate.day,
      );

      for (final e in daysExpenses) {
        runningBalance -= e.amount;
      }
      for (final inc in daysIncomes) {
        runningBalance += inc.amount;
      }

      spots.add(FlSpot(i.toDouble(), runningBalance));
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final allExpenses = _expenseService.getAllExpenses();
    final allIncomes = _incomeService.getAllIncomes();
    final totalExpense = _expenseService.getTotal(allExpenses);
    final totalIncome = _incomeService.getTotal(allIncomes);
    final Budget? activeBudget = _budgetService.getActiveBudget();
    final balanceSpots = _buildRecentBalanceSpots(allExpenses, allIncomes);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)) : Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
        title: const Text(
          'Accueil',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [ 
        Builder(
          builder: (context) {
            final alertCount = AlertService().getActiveAlerts().length;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                  },
                ),
               // Petit badge rouge si au moins une alerte existe
                if (alertCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                  ),
                ),
             ],
            );
          },
        ),
        ],
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceCard(totalIncome: totalIncome, totalExpense: totalExpense),
            const SizedBox(height: 16),

            if (activeBudget != null)
              BudgetProgress(
                totalAmount: activeBudget.totalAmount,
                spentAmount: _budgetService.getSpentAmount(activeBudget),
                remainingAmount: _budgetService.getRemainingAmount(
                  activeBudget,
                ),
                usagePercentage: _budgetService.getUsagePercentage(
                  activeBudget,
                ),
                remainingDays: _budgetService.getRemainingDays(activeBudget),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.background(context),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Aucun budget défini pour le moment.',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Évolution du solde : même widget que sur Statistiques,
            // juste avec une couleur différente (violet) pour la distinguer.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  const Text(
                    'Évolution du solde (30 derniers jours)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  BalanceLineChart(
                    spots: balanceSpots,
                    lineColor: const Color(0xFF9B59B6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions récentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TransactionsScreen()),
                    );
                 },
                 child: const Text('Voir tout', style: TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600)),
               ),
              ],
            ),
            const SizedBox(height: 4),

            if (allExpenses.isEmpty && allIncomes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Aucune transaction pour le moment.\nAppuie sur + pour commencer.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  ),
                ),
              )
            else ...[
              ..._buildMergedTransactions(allExpenses, allIncomes).take(5),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          if (result == true) setState(() {});
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
