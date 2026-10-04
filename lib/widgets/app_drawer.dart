import 'package:flutter/material.dart';

import '../screens/manage_categories_screen.dart';
import '../screens/budget_history_screen.dart';
import '../theme/app_colors.dart';
import '../screens/settings_screen.dart';
import '../screens/help_screen.dart';
import '../screens/how_it_works_screen.dart';
import '../screens/about_screen.dart';
import '../screens/privacy_policy_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Affiche un message temporaire pour les écrans pas encore construits,
  // plutôt que de planter ou de ne rien faire silencieusement.
  void _showComingSoon(BuildContext context, String feature) {
    Navigator.pop(context); // ferme le drawer d'abord
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature — bientôt disponible')));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.cardBackground(context),
      child: SafeArea(
        child: Column(
          children: [
            // En-tête avec logo et nom de l'app
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expense Manager',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        Text(
                          'Gère ton argent simplement',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildTile(
                    context,
                    icon: Icons.category_outlined,
                    label: 'Gérer les catégories',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageCategoriesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.history,
                    label: 'Historique du budget',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BudgetHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.settings_outlined,
                    label: 'Réglages',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),

                  _buildTile(
                    context,
                    icon: Icons.person_outline,
                    label: 'Profil',
                    onTap: () => _showComingSoon(context, 'Profil'),
                  ),

                  _buildTile(
                    context,
                    icon: Icons.cloud_outlined,
                    label: 'Services',
                    onTap: () => _showComingSoon(context, 'Services'),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    child: Divider(height: 1),
                  ),

                  _buildTile(
                    context,
                    icon: Icons.help_outline,
                    label: 'Aide',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpScreen(),
                        ),
                      );
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.menu_book_outlined,
                    label: 'Fonctionnement de l\'application',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HowItWorksScreen(),
                        ),
                      );
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.info_outline,
                    label: 'À propos',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    ),
                  ),
                  _buildTile(
                    context,
                    icon: Icons.lock_outline,
                    label: 'Politique et conditions',
                    onTap: () {
                       Navigator.pop(context);
                       Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary(context), size: 22),
      title: Text(
        label,
        style: TextStyle(fontSize: 14, color: AppColors.textPrimary(context)),
      ),
      onTap: onTap,
    );
  }
}
