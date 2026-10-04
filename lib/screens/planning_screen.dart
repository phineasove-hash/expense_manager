import 'package:flutter/material.dart';

import '../models/financial_goal.dart';
import '../services/plan_service.dart';
import '../services/goal_service.dart';
import '../services/category_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_drawer.dart';
import 'monthly_plan_review_screen.dart';

// Écran principal de planification : affiche le plan mensuel et les objectifs.
// Ce fichier contient la logique d'UI et appelle des services (PlanService,
// GoalService, CategoryService) pour récupérer/mettre à jour les données.
// Les commentaires ci-dessous expliquent les responsabilités de chaque méthode
// sans modifier le comportement existant.
class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  final PlanService _planService = PlanService();
  final GoalService _goalService = GoalService();
  final CategoryService _categoryService = CategoryService();

  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  static const List<String> _monthNames = [
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

  void _changeMonth(int offset) {
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + offset,
      );
    });
  }

  bool _shouldShowPreviousMonthBanner() {
    final currentPlan = _planService.getPlanForMonth(
      selectedMonth.year,
      selectedMonth.month,
    );
    if (currentPlan.isNotEmpty) return false;

    final prevMonth = selectedMonth.month == 1 ? 12 : selectedMonth.month - 1;
    final prevYear = selectedMonth.month == 1
        ? selectedMonth.year - 1
        : selectedMonth.year;
    final previousPlan = _planService.getPlanForMonth(prevYear, prevMonth);
    return previousPlan.isNotEmpty;
  }

  Future<void> _duplicatePreviousMonth() async {
    await _planService.duplicatePreviousMonthIfNeeded(
      selectedMonth.year,
      selectedMonth.month,
    );
    setState(() {});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan dupliqué depuis le mois précédent')),
    );
  }

  void _openPreviousMonthReview() {
    final prevMonth = selectedMonth.month == 1 ? 12 : selectedMonth.month - 1;
    final prevYear = selectedMonth.month == 1
        ? selectedMonth.year - 1
        : selectedMonth.year;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MonthlyPlanReviewScreen(year: prevYear, month: prevMonth),
      ),
    );
  }

  Future<void> _showAddPlanItemDialog() async {
    final categories = _categoryService.getCategories();
    String selectedCategory = categories.first;
    final amountController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Ajouter une ligne au plan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Montant prévu (FCFA)',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Ajouter'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true) {
      final amount = double.tryParse(amountController.text.trim());
      if (amount != null && amount > 0) {
        await _planService.addPlanItem(
          category: selectedCategory,
          plannedAmount: amount,
          year: selectedMonth.year,
          month: selectedMonth.month,
        );
        setState(() {});
      }
    }
  }

  Future<void> _showAddGoalDialog() async {
    final nameController = TextEditingController();
    final targetController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvel objectif'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'objectif',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Montant cible (FCFA)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Créer'),
          ),
        ],
      ),
    );

    if (result == true) {
      final name = nameController.text.trim();
      final target = double.tryParse(targetController.text.trim());
      if (name.isNotEmpty && target != null && target > 0) {
        await _goalService.addGoal(name: name, targetAmount: target);
        setState(() {});
      }
    }
  }

  Future<void> _showContributionDialog(FinancialGoal goal) async {
    final amountController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter à "${goal.name}"'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Montant à ajouter (FCFA)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result == true) {
      final amount = double.tryParse(amountController.text.trim());
      if (amount != null && amount > 0) {
        await _goalService.addContribution(goal, amount);
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final comparison = _planService.getComparisonForMonth(
      selectedMonth.year,
      selectedMonth.month,
    );
    final goals = _goalService.getAllGoals();
    final showBanner = _shouldShowPreviousMonthBanner();

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
          'Planification',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    '${_monthNames[selectedMonth.month - 1]} ${selectedMonth.year}',
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

            if (showBanner)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Un plan existait le mois dernier',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Consulte le bilan ou reprends les mêmes lignes pour ce mois-ci.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _openPreviousMonthReview,
                            child: const Text('Voir le bilan'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _duplicatePreviousMonth,
                            child: const Text('Dupliquer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MON PLAN DU MOIS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.gold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _showAddPlanItemDialog,
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (comparison.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Aucune ligne planifiée ce mois-ci.',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
              )
            else
              ...comparison.entries.map((entry) {
                final category = entry.key;
                final planned = entry.value.planned;
                final actual = entry.value.actual;
                final percentage = planned <= 0
                    ? 0.0
                    : (actual / planned).clamp(0.0, 1.0);
                final isOver = actual > planned;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground(context),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${actual.toStringAsFixed(0)} / ${planned.toStringAsFixed(0)} FCFA',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOver
                                  ? AppColors.danger
                                  : AppColors.textSecondary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 8,
                          backgroundColor: AppColors.background(context),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOver ? AppColors.danger : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MES OBJECTIFS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.gold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _showAddGoalDialog,
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (goals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Aucun objectif défini pour le moment.',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
              )
            else
              ...goals.map((goal) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground(context),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            goal.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showContributionDialog(goal),
                            child: const Text('+ Ajouter'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: goal.progressPercentage,
                          minHeight: 8,
                          backgroundColor: AppColors.background(context),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${goal.savedAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)} FCFA (${(goal.progressPercentage * 100).toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
