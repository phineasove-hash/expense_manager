import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/income.dart';
import '../models/financial_goal.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';
import '../services/category_service.dart';
import '../services/goal_service.dart';
import '../services/plan_service.dart';
import '../theme/app_colors.dart';
import '../theme/category_style.dart';

class AddTransactionScreen extends StatefulWidget {
  final Expense? existingExpense;
  final Income? existingIncome;

  const AddTransactionScreen({super.key, this.existingExpense, this.existingIncome});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final IncomeService _incomeService = IncomeService();
  final CategoryService _categoryService = CategoryService();
  final GoalService _goalService = GoalService();
  final PlanService _planService = PlanService();

  List<String> categories = [];
  List<FinancialGoal> goals = [];

  bool isExpense = true;
  bool isRecurring = false;
  String? selectedGoalId;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String selectedCategory = '';
  DateTime selectedDate = DateTime.now();

  bool get isEditing => widget.existingExpense != null || widget.existingIncome != null;
  Color get accentColor => isExpense ? AppColors.expense : AppColors.income;

  @override
  void initState() {
    super.initState();
    categories = _categoryService.getCategories();
    selectedCategory = categories.first;
    goals = _goalService.getAllGoals();

    if (widget.existingExpense != null) {
      final e = widget.existingExpense!;
      isExpense = true;
      _nameController.text = e.name;
      _amountController.text = e.amount.toString();
      _noteController.text = e.note ?? '';
      selectedCategory = e.category;
      selectedDate = e.date;
      isRecurring = e.isRecurring;
      selectedGoalId = e.linkedGoalId;
    } else if (widget.existingIncome != null) {
      final i = widget.existingIncome!;
      isExpense = false;
      _nameController.text = i.name;
      _amountController.text = i.amount.toString();
      _noteController.text = i.note ?? '';
      selectedDate = i.date;
      isRecurring = i.isRecurring;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // Vérifie si l'ajout de cette dépense ferait dépasser la ligne de plan
  // correspondante. Retourne true si on peut continuer (pas de dépassement,
  // ou l'utilisateur a confirmé malgré l'avertissement).
  Future<bool> _checkBudgetOverrun(double amount) async {
    final now = selectedDate;
    final planItem = _planService.getPlanItemForCategory(selectedCategory, now.year, now.month);
    if (planItem == null) return true;

    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final expensesThisMonth = _expenseService
        .getExpensesBetween(monthStart, monthEnd)
        .where((e) => e.category == selectedCategory && e.id != widget.existingExpense?.id);
    final alreadySpent = _expenseService.getTotal(expensesThisMonth.toList());

    final projectedTotal = alreadySpent + amount;
    if (projectedTotal <= planItem.plannedAmount) return true;

    final overrun = projectedTotal - planItem.plannedAmount;

    if (!mounted) return false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dépassement de budget'),
        content: Text(
          'Cette dépense ferait dépasser ton plan pour "$selectedCategory" '
          'de ${overrun.toStringAsFixed(0)} FCFA ce mois-ci.\n\nTu veux quand même l\'enregistrer ?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enregistrer quand même', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _saveTransaction() async {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();

    if (name.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci de remplir le nom et le montant')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Montant invalide')));
      return;
    }

    if (isExpense) {
      final canProceed = await _checkBudgetOverrun(amount);
      if (!canProceed) return;
    }

    final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    if (isExpense) {
      if (widget.existingExpense != null) {
        final e = widget.existingExpense!;
        e.name = name;
        e.amount = amount;
        e.category = selectedCategory;
        e.date = selectedDate;
        e.note = note;
        e.isRecurring = isRecurring;
        e.linkedGoalId = selectedGoalId;
        await _expenseService.updateExpense(e);
      } else {
        await _expenseService.addExpense(
          name: name,
          amount: amount,
          category: selectedCategory,
          date: selectedDate,
          note: note,
          isRecurring: isRecurring,
          linkedGoalId: selectedGoalId,
        );
      }
    } else {
      if (widget.existingIncome != null) {
        final i = widget.existingIncome!;
        i.name = name;
        i.amount = amount;
        i.date = selectedDate;
        i.note = note;
        i.isRecurring = isRecurring;
        await _incomeService.updateIncome(i);
      } else {
        await _incomeService.addIncome(
          name: name,
          amount: amount,
          date: selectedDate,
          note: note,
          isRecurring: isRecurring,
        );
      }
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier' : (isExpense ? 'Ajouter une dépense' : 'Ajouter un revenu')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isEditing)
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: accentColor,
                      selectedForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    segments: const [
                      ButtonSegment(value: true, label: Text('Dépense')),
                      ButtonSegment(value: false, label: Text('Revenu')),
                    ],
                    selected: {isExpense},
                    onSelectionChanged: (newSelection) => setState(() => isExpense = newSelection.first),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: isExpense ? 'Nom de la dépense' : 'Source du revenu'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
            ),
            const SizedBox(height: 16),

            if (isExpense) ...[
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CategoryStyle.iconOf(category), size: 18, color: CategoryStyle.colorOf(category)),
                        const SizedBox(width: 10),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedCategory = value);
                },
              ),
              const SizedBox(height: 16),
            ],

            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optionnel)'),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(isExpense ? 'Dépense récurrente' : 'Revenu récurrent', style: const TextStyle(fontSize: 14)),
                subtitle: const Text('Se répète chaque mois', style: TextStyle(fontSize: 12)),
                value: isRecurring,
                activeThumbColor: accentColor,
                onChanged: (value) => setState(() => isRecurring = value),
              ),
            ),

            if (isExpense && goals.isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: selectedGoalId,
                decoration: const InputDecoration(labelText: 'Liée à un objectif ? (optionnel)'),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('Aucun')),
                  ...goals.map((goal) => DropdownMenuItem<String?>(value: goal.id, child: Text(goal.name))),
                ],
                onChanged: (value) => setState(() => selectedGoalId = value),
              ),
            ],

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                child: Text(isEditing ? 'METTRE À JOUR' : 'ENREGISTRER'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}