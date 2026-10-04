import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Politique et conditions')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Politique de confidentialité',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Cette application stocke vos données localement sur votre appareil pour vous permettre de gérer vos dépenses et revenus sans dépendre d’un serveur externe.',
            ),
            SizedBox(height: 16),
            Text(
              'Conditions d’utilisation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'L’application est fournie à titre d’outil de gestion personnelle. Vous êtes responsable de l’utilisation des données que vous saisissez.',
            ),
          ],
        ),
      ),
    );
  }
}
