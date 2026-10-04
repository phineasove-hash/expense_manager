import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/expense_service.dart';
import '../theme/app_colors.dart';
import '../theme/category_style.dart';
import 'add_transaction_screen.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette dépense ?'),
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
      await ExpenseService().deleteExpense(expense);
      if (!context.mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = CategoryStyle.colorOf(expense.category);
    final categoryIcon = CategoryStyle.iconOf(expense.category);

    return Scaffold(
      // Header rouge, texte blanc, centré
      appBar: AppBar(
        backgroundColor: AppColors.expense,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'DÉTAIL DE LA DÉPENSE',
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
            // Icône de catégorie, grande et colorée
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(categoryIcon, color: categoryColor, size: 34),
            ),
            const SizedBox(height: 16),

            // Catégorie, en petit au-dessus du montant
            Text(
              expense.category,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),

            // Le montant, gros et centré
            Text(
              '-${expense.amount.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.expense,
              ),
            ),
            const SizedBox(height: 32),

            // Carte d'informations, centrées et espacées
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
                  _buildInfoRow(context, 'Nom', expense.name),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildInfoRow(
                    context,
                    'Date',
                    '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                  ),
                  if (expense.isRecurring) ...[
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildInfoRow(context, 'Récurrence', 'Chaque mois'),
                  ],
                  if (expense.note != null && expense.note!.isNotEmpty) ...[
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildInfoRow(context, 'Note', expense.note!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Boutons centrés, espacés, largeur ajustée (80% de l'écran)
            FractionallySizedBox(
              widthFactor: 0.8,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddTransactionScreen(existingExpense: expense),
                    ),
                  );
                  if (result == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.expense),
                  foregroundColor: AppColors.expense,
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