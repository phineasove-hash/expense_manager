import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BudgetProgress extends StatelessWidget {
  final double totalAmount;
  final double spentAmount;
  final double remainingAmount;
  final double usagePercentage;
  final int remainingDays;

  const BudgetProgress({
    super.key,
    required this.totalAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.usagePercentage,
    required this.remainingDays,
  });

  @override
  Widget build(BuildContext context) {
    final Color progressColor = usagePercentage < 0.7
        ? AppColors.success
        : usagePercentage < 0.9
            ? AppColors.gold
            : AppColors.danger;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Petit repère or, cohérent avec le label de la carte de solde
          const Text(
            'BUDGET DU MOIS',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${totalAmount.toStringAsFixed(0)} FCFA',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel(context, 'Dépensé', spentAmount, AppColors.expense),
              _buildLabel(context, 'Restant', remainingAmount, AppColors.success),
            ],
          ),
          const SizedBox(height: 12),
          // Barre de progression : même logique de couleur, mais bordée
          // discrètement d'or pour rester cohérente avec la signature
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: usagePercentage,
              minHeight: 8,
              backgroundColor: AppColors.background(context),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(usagePercentage * 100).toStringAsFixed(0)}% utilisé',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
              ),
              Text(
                '$remainingDays jours restants',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
        Text(
          '${amount.toStringAsFixed(0)} FCFA',
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
        ),
      ],
    );
  }
}