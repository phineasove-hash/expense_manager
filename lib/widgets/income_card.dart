import 'package:flutter/material.dart';

import '../models/income.dart';
import '../theme/app_colors.dart';

class IncomeCard extends StatelessWidget {
  final Income income;
  final VoidCallback? onTap;

  const IncomeCard({super.key, required this.income, this.onTap});

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: AppColors.income.withValues(alpha: 0.14),
              child: const Icon(
                Icons.trending_up,
                color: AppColors.income,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    income.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    '${income.date.day}/${income.date.month}/${income.date.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '+${income.amount.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                color: AppColors.income,
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
