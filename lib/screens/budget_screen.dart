import 'package:flutter/material.dart';

import '../models/budget.dart';
import '../services/budget_service.dart';
import '../theme/app_colors.dart';
import 'edit_budget_amount_screen.dart';
import 'change_budget_period_screen.dart';
import 'budget_history_screen.dart';
import '../utils/date_format.dart';
import '../widgets/app_drawer.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final BudgetService _budgetService = BudgetService();

  final TextEditingController _amountController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 30));

  // Force l'affichage du formulaire de création même si un budget
  // existe déjà, le temps de créer un nouveau budget.
  bool _forceCreationForm = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        startDate = picked;
      } else {
        endDate = picked;
      }
    });
  }

  Future<void> _createFirstBudget() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant de budget invalide')),
      );
      return;
    }
    if (endDate.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début'),
        ),
      );
      return;
    }

    await _budgetService.setNewBudget(
      totalAmount: amount,
      startDate: startDate,
      endDate: endDate,
    );
    if (!mounted) return;
    setState(() {
      _forceCreationForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Budget? activeBudget = _budgetService.getActiveBudget();
    final bool showCreationForm = activeBudget == null || _forceCreationForm;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
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
          'Mon budget',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: showCreationForm
          ? _buildCreationForm()
          : _buildBudgetSummaryAndMenu(activeBudget),
    );
  }

  Widget _buildCreationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Créer un budget',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Montant du budget (FCFA)',
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _pickDate(true),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date de début'),
              child: Text(
                '${startDate.day}/${startDate.month}/${startDate.year}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _pickDate(false),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date de fin'),
              child: Text('${endDate.day}/${endDate.month}/${endDate.year}'),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createFirstBudget,
              child: const Text('CRÉER LE BUDGET'),
            ),
          ),
          if (_forceCreationForm) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _forceCreationForm = false),
                child: const Text('Annuler'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBudgetSummaryAndMenu(Budget budget) {
    final spent = _budgetService.getSpentAmount(budget);
    final remaining = _budgetService.getRemainingAmount(budget);
    final usage = _budgetService.getUsagePercentage(budget);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget actuel',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatBudgetPeriod(budget.startDate, budget.endDate),
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'BUDGET TOTAL',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${budget.totalAmount.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: usage,
                    minHeight: 10,
                    backgroundColor: AppColors.background(context),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      usage < 0.7
                          ? AppColors.success
                          : (usage < 0.9
                                ? AppColors.warning
                                : AppColors.danger),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dépensé',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${spent.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            color: AppColors.expense,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Restant',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${remaining.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildMenuTile(
            icon: Icons.edit_outlined,
            label: 'Modifier le budget',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditBudgetAmountScreen(budget: budget),
                ),
              );
              if (result == true) setState(() {});
            },
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            icon: Icons.calendar_today_outlined,
            label: 'Changer la période',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChangeBudgetPeriodScreen(budget: budget),
                ),
              );
              if (result == true) setState(() {});
            },
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            icon: Icons.add_circle_outline,
            label: 'Nouveau budget',
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Créer un nouveau budget ?'),
                  content: const Text(
                    'Le budget actuel sera archivé dans l\'historique. Tu pourras toujours le consulter plus tard.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Continuer'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                setState(() {
                  _forceCreationForm = true;
                });
              }
            },
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            icon: Icons.history,
            label: 'Historique des budgets',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BudgetHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary(context), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary(context)),
          ],
        ),
      ),
    );
  }
}
