import 'package:flutter/material.dart';

import '../services/budget_service.dart';
import '../theme/app_colors.dart';

class BudgetHistoryScreen extends StatelessWidget {
  const BudgetHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // On appelle directement le service ici : cet écran est en lecture
    // seule, pas besoin de StatefulWidget ni de setState.
    final history = BudgetService().getBudgetHistory();

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des budgets')),
      body: history.isEmpty
          ? Center(
              child: Text(
                'Aucun ancien budget pour le moment',
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final budget = history[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
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
                      Text(
                        '${budget.totalAmount.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Du ${budget.startDate.day}/${budget.startDate.month}/${budget.startDate.year} '
                        'au ${budget.endDate.day}/${budget.endDate.month}/${budget.endDate.year}',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 13,
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
