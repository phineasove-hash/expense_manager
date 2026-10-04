import 'package:flutter/material.dart';

import '../services/app_data_service.dart';
import '../services/theme_controller.dart';
import '../theme/app_colors.dart';
import 'manage_categories_screen.dart';
import 'notifications_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppDataService _appDataService = AppDataService();

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser toutes les données ?'),
        content: const Text(
          'Toutes tes dépenses, revenus et budgets seront définitivement supprimés. Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Réinitialiser',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _appDataService.resetAllData();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toutes les données ont été réinitialisées'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionCount = _appDataService.getTransactionCount();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Réglages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeSelector(),
          const SizedBox(height: 10),
          _buildTile(
            icon: Icons.category_outlined,
            title: 'Gérer mes catégories',
            subtitle: 'Ajouter ou supprimer des catégories',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageCategoriesScreen(),
                ),
              );
              setState(() {});
            },
          ),
          const SizedBox(height: 10),
          _buildTile(
            icon: Icons.attach_money,
            title: 'Devise',
            subtitle: 'FCFA',
          ),
          const SizedBox(height: 10),
          _buildTile(
            icon: Icons.bar_chart,
            title: 'Activité',
            subtitle:
                '$transactionCount transaction${transactionCount > 1 ? 's' : ''} enregistrée${transactionCount > 1 ? 's' : ''}',
          ),
          const SizedBox(height: 10),
          _buildTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Alertes de dépassement de budget',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildTile(
            icon: Icons.language_outlined,
            title: 'Langue',
            subtitle: 'Français',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Langue — bientôt disponible')),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Confidentialité et sécurité',
            subtitle: 'Tes données restent sur cet appareil',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Confidentialité — bientôt disponible'),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildTile(
            icon: Icons.info_outline,
            title: 'À propos',
            subtitle: 'Expense Manager v1.0',
          ),
          const SizedBox(height: 30),
          _buildTile(
            icon: Icons.delete_forever_outlined,
            title: 'Réinitialiser mes données',
            subtitle: 'Supprime toutes les transactions et budgets',
            isDanger: true,
            onTap: _confirmReset,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeMode,
      builder: (context, currentMode, _) {
        return Container(
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
              Row(
                children: [
                  Icon(
                    Icons.brightness_6_outlined,
                    color: AppColors.textSecondary(context),
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Apparence',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildThemeOption(
                      context,
                      'Clair',
                      ThemeMode.light,
                      Icons.light_mode_outlined,
                      currentMode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildThemeOption(
                      context,
                      'Sombre',
                      ThemeMode.dark,
                      Icons.dark_mode_outlined,
                      currentMode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildThemeOption(
                      context,
                      'Système',
                      ThemeMode.system,
                      Icons.settings_suggest_outlined,
                      currentMode,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    ThemeMode mode,
    IconData icon,
    ThemeMode currentMode,
  ) {
    final bool isSelected = currentMode == mode;

    return InkWell(
      onTap: () => ThemeController.instance.setThemeMode(mode),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : AppColors.textSecondary(context),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Colors.white
                    : AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDanger = false,
  }) {
    final color = isDanger
        ? AppColors.danger
        : AppColors.textSecondary(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDanger
                          ? AppColors.danger
                          : AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary(context),
              ),
          ],
        ),
      ),
    );
  }
}
