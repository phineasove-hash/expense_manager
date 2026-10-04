import 'package:flutter/material.dart';

import '../models/budget.dart';
import '../services/budget_service.dart';

class ChangeBudgetPeriodScreen extends StatefulWidget {
  final Budget budget;

  const ChangeBudgetPeriodScreen({super.key, required this.budget});

  @override
  State<ChangeBudgetPeriodScreen> createState() => _ChangeBudgetPeriodScreenState();
}

class _ChangeBudgetPeriodScreenState extends State<ChangeBudgetPeriodScreen> {
  final BudgetService _budgetService = BudgetService();
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    // Pré-remplit avec les dates actuelles du budget
    startDate = widget.budget.startDate;
    endDate = widget.budget.endDate;
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

  Future<void> _save() async {
    if (endDate.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La date de fin doit être après la date de début')),
      );
      return;
    }

    await _budgetService.updateBudgetPeriod(widget.budget, startDate, endDate);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Changer la période')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _pickDate(true),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date de début'),
                child: Text('${startDate.day}/${startDate.month}/${startDate.year}'),
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
              child: ElevatedButton(onPressed: _save, child: const Text('ENREGISTRER')),
            ),
          ],
        ),
      ),
    );
  }
}