import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))
            : null,
        title: const Text('À propos', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 16),
                Text(
                  'Expense Manager',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context)),
                ),
                const SizedBox(height: 4),
                Text('Version 1.0.0', style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context))),
                const SizedBox(height: 24),
                Text(
                  'Une application de gestion financière personnelle pensée pour un suivi simple, local et confidentiel de ton argent, en FCFA.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}