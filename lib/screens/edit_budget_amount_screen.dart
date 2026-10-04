import 'package:flutter/material.dart';

import '../models/budget.dart';
import '../services/budget_service.dart';

class EditBudgetAmountScreen extends StatefulWidget {
  final Budget budget;

  const EditBudgetAmountScreen({super.key, required this.budget});

  @override
  State<EditBudgetAmountScreen> createState() => _EditBudgetAmountScreenState();
}

class _EditBudgetAmountScreenState extends State<EditBudgetAmountScreen> {
  final BudgetService _budgetService = BudgetService();
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    // Pré-remplit le champ avec le montant actuel du budget
    _amountController = TextEditingController(text: widget.budget.totalAmount.toString());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide')),
      );
      return;
    }

    await _budgetService.updateBudgetAmount(widget.budget, amount);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le budget')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nouveau montant (FCFA)'),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _save, child: const Text('ENREGISTRER')),
            ),
          ],
        ),
      ),
    );
  }
}