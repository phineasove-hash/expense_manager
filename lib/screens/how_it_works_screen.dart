import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  static const List<Map<String, dynamic>> _steps = [
    {
      'icon': Icons.add_circle_outline,
      'title': 'Enregistre tes depenses et revenus',
      'text': 'Chaque transaction est classee par categorie et par date.',
    },
    {
      'icon': Icons.account_balance_wallet_outlined,
      'title': 'Definis un budget',
      'text':
          'Fixe un montant et une periode pour suivre ce que tu peux depenser.',
    },
    {
      'icon': Icons.event_note_outlined,
      'title': 'Planifie ton mois',
      'text':
          'Repartis ton budget par categorie avant meme que le mois commence.',
    },
    {
      'icon': Icons.bar_chart_outlined,
      'title': 'Analyse tes statistiques',
      'text': 'Visualise ou va ton argent grace aux graphiques.',
    },
    {
      'icon': Icons.notifications_outlined,
      'title': 'Reste informe',
      'text': 'Recois une alerte si tu depasses ton budget prevu.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Fonctionnement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _steps.length,
        itemBuilder: (context, index) {
          final step = _steps[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step['icon'] as IconData,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['text'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
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
