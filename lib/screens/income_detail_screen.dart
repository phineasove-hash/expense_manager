import 'package:flutter/material.dart';

import '../models/income.dart';
import '../services/income_service.dart';
import '../theme/app_colors.dart';
import 'add_transaction_screen.dart';

class IncomeDetailScreen extends StatelessWidget {
  final Income income;

  const IncomeDetailScreen({super.key, required this.income});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce revenu ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await IncomeService().deleteIncome(income);
      if (!context.mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Même principe que la dépense, mais en vert (couleur des revenus)
      appBar: AppBar(
        backgroundColor: AppColors.income,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'DÉTAIL DU REVENU',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.income.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.trending_up,
                color: AppColors.income,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Revenu',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),

            Text(
              '+${income.amount.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.income,
              ),
            ),
            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cardBackground(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(context, 'Source', income.name),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildInfoRow(
                    context,
                    'Date',
                    '${income.date.day}/${income.date.month}/${income.date.year}',
                  ),
                  if (income.isRecurring) ...[
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildInfoRow(context, 'Récurrence', 'Chaque mois'),
                  ],
                  if (income.note != null && income.note!.isNotEmpty) ...[
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildInfoRow(context, 'Note', income.note!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),

            FractionallySizedBox(
              widthFactor: 0.8,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddTransactionScreen(existingIncome: income),
                    ),
                  );
                  if (result == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.income),
                  foregroundColor: AppColors.income,
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('MODIFIER'),
              ),
            ),
            const SizedBox(height: 14),
            FractionallySizedBox(
              widthFactor: 0.8,
              child: ElevatedButton.icon(
                onPressed: () => _confirmDelete(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                label: const Text(
                  'SUPPRIMER',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}