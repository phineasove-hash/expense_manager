import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const List<Map<String, String>> _faqItems = [
    {
      'question': 'Comment ajouter une depense ?',
      'answer':
          'Depense l\'ecran Acceuil, appuie surle bouton "+" en bas à droite, remplis les informations et enregistre.',
    },
    {
      'question': 'Comment definir un budget ?',
      'answer':
          'Va dans l\'onglet Budget, indique un montant et une  periode, puis enregistre. Le budget sera actif pour la période choisie.',
    },
    {
      'question': 'Mes donnees sont-elles envoyees sur internet ?',
      'answer':
          'Non , toutes tes donnees restent stockees uniquement sur ton appareil. L\'application ne collecte ni ne partage aucune information.',
    },
    {
      'question': 'Comment creer un objectif d\'epargne ?',
      'answer':
          'Dans l\'onglet Plan, section "Mes objectifs", appuie sur le bouton "+" pour ajouter un nouvel objectif.',
    },
    {
      'question': 'Puis-je changer de device ?',
      'answer':
          'Pas encore, cette fonctionnalite arrivera dans  une prochaine version',
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
          'Aide',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqItems.length,
        itemBuilder: (context, index) {
          final item = _faqItems[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            child: ExpansionTile(
              title: Text(
                item['question']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item['answer']!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
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
