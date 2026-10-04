import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../theme/app_colors.dart';
import '../theme/category_style.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseCard({super.key, required this.expense, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color categoryColor = CategoryStyle.colorOf(expense.category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: categoryColor.withValues(alpha: 0.14),
              child: Icon(
                CategoryStyle.iconOf(expense.category),
                color: categoryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    expense.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '-${expense.amount.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                color: AppColors.expense,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
