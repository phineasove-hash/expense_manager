import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))
            : null,
        title: const Text('Politique et conditions', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            'Toutes tes données (dépenses, revenus, budgets, objectifs) sont stockées '
            'uniquement sur cet appareil, dans une base de données locale. '
            'Aucune information n\'est envoyée sur internet ni partagée avec un tiers.\n\n'
            'En utilisant cette application, tu acceptes qu\'elle est fournie telle quelle, '
            'sans garantie, et destinée à un usage personnel de suivi de tes finances.\n\n'
            'La suppression de l\'application entraîne la perte définitive de toutes tes données, '
            'sauf sauvegarde manuelle de ta part.',
            style: TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary(context)),
          ),
        ),
      ),
    );
  }
}