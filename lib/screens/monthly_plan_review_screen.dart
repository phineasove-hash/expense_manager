import 'package:flutter/material.dart';

import '../services/plan_service.dart';
import '../theme/app_colors.dart';

class MonthlyPlanReviewScreen extends StatelessWidget {
  final int year;
  final int month;

  const MonthlyPlanReviewScreen({
    super.key,
    required this.year,
    required this.month,
  });

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

  @override
  Widget build(BuildContext context) {
    final comparison = PlanService().getComparisonForMonth(year, month);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bilan de ${_monthNames[month - 1]} $year',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: comparison.isEmpty
          ? Center(
              child: Text(
                'Aucun plan pour ce mois-là',
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: comparison.length,
              itemBuilder: (context, index) {
                final category = comparison.keys.elementAt(index);
                final data = comparison[category]!;
                // Écart : positif = surplus (on a dépensé moins que prévu),
                // négatif = déficit (on a dépensé plus que prévu).
                final variance = data.planned - data.actual;
                final isDeficit = variance < 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Prévu : ${data.planned.toStringAsFixed(0)} FCFA',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          Text(
                            'Réel : ${data.actual.toStringAsFixed(0)} FCFA',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isDeficit ? AppColors.danger : AppColors.success)
                                  .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isDeficit
                              ? 'Déficit de ${variance.abs().toStringAsFixed(0)} FCFA'
                              : 'Surplus de ${variance.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            color: isDeficit
                                ? AppColors.danger
                                : AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
