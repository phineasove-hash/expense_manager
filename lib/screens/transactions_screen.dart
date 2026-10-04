import 'package:flutter/material.dart';

import '../services/expense_service.dart';
import '../services/income_service.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../theme/app_colors.dart';
import '../widgets/expense_card.dart';
import '../widgets/income_card.dart';
import 'expense_detail_screen.dart';
import 'income_detail_screen.dart';
import '../widgets/app_drawer.dart';

enum TransactionFilter { all, expenses, incomes }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final IncomeService _incomeService = IncomeService();
  TransactionFilter currentFilter = TransactionFilter.all;

  @override
  Widget build(BuildContext context) {
    final allExpenses = _expenseService.getAllExpenses();
    final allIncomes = _incomeService.getAllIncomes();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        // Si on peut revenir en arrière (écran ouvert par-dessus un autre),
        // on affiche une flèche retour. Sinon (écran affiché via la bottom
        // nav, à la racine), on garde l'icône ☰ classique pour le Drawer.
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        title: const Text(
          'Transaction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterButton(
                    label: 'Toutes',
                    isSelected: currentFilter == TransactionFilter.all,
                    color: AppColors.secondary,
                    onTap: () =>
                        setState(() => currentFilter = TransactionFilter.all),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton(
                    label: 'Dépenses',
                    isSelected: currentFilter == TransactionFilter.expenses,
                    color: AppColors.expense,
                    onTap: () => setState(
                      () => currentFilter = TransactionFilter.expenses,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton(
                    label: 'Revenus',
                    isSelected: currentFilter == TransactionFilter.incomes,
                    color: AppColors.income,
                    onTap: () => setState(
                      () => currentFilter = TransactionFilter.incomes,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildTransactionList(allExpenses, allIncomes)),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // L'indigo (couleur de "Toutes") est trop sombre pour ressortir sur
    // le fond quasi-noir du mode sombre. On l'éclaircit uniquement dans
    // ce cas précis, sans toucher aux autres couleurs (rouge, vert) qui
    // restent déjà bien visibles sur fond sombre.
    final Color displayColor = (isDark && color == AppColors.secondary)
        ? Color.lerp(color, Colors.white, 0.55) ?? color
        : color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? displayColor : Colors.transparent,
          border: Border.all(color: displayColor, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : displayColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<void> _openExpenseDetail(Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(expense: expense),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _openIncomeDetail(Income income) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomeDetailScreen(income: income),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  Widget _buildTransactionList(
    List<Expense> allExpenses,
    List<Income> allIncomes,
  ) {
    if (currentFilter == TransactionFilter.expenses) {
      if (allExpenses.isEmpty) {
        return _buildEmptyMessage('Aucune dépense enregistrée');
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allExpenses.length,
        itemBuilder: (context, index) => ExpenseCard(
          expense: allExpenses[index],
          onTap: () => _openExpenseDetail(allExpenses[index]),
        ),
      );
    }

    if (currentFilter == TransactionFilter.incomes) {
      if (allIncomes.isEmpty) {
        return _buildEmptyMessage('Aucun revenu enregistré');
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allIncomes.length,
        itemBuilder: (context, index) => IncomeCard(
          income: allIncomes[index],
          onTap: () => _openIncomeDetail(allIncomes[index]),
        ),
      );
    }

    if (allExpenses.isEmpty && allIncomes.isEmpty) {
      return _buildEmptyMessage('Aucune transaction pour le moment');
    }

    final List<dynamic> merged = [...allExpenses, ...allIncomes];
    merged.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: merged.length,
      itemBuilder: (context, index) {
        final item = merged[index];
        if (item is Expense) {
          return ExpenseCard(
            expense: item,
            onTap: () => _openExpenseDetail(item),
          );
        } else {
          return IncomeCard(income: item, onTap: () => _openIncomeDetail(item));
        }
      },
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: AppColors.textSecondary(context)),
      ),
    );
  }
}
