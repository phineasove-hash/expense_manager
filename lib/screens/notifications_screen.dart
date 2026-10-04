import 'package:flutter/material.dart';

import '../services/alert_service.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Color _colorForLevel(AlertLevel level) {
    switch (level) {
      case AlertLevel.danger:
        return AppColors.danger;
      case AlertLevel.warning:
        return AppColors.warning;
      case AlertLevel.success:
        return AppColors.success;
    }
  }

  IconData _iconForLevel(AlertLevel level) {
    switch (level) {
      case AlertLevel.danger:
        return Icons.error_outline;
      case AlertLevel.warning:
        return Icons.warning_amber_outlined;
      case AlertLevel.success:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alerts = AlertService().getActiveAlerts();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: alerts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 56,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune notification pour le moment',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary(context)),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final color = _colorForLevel(alert.level);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border(
                      left: BorderSide(color: color, width: 4),
                      top: BorderSide(color: AppColors.secondary.withValues(alpha: 0.06), width: 1),
                      right: BorderSide(color: AppColors.secondary.withValues(alpha: 0.06), width: 1),
                      bottom: BorderSide(color: AppColors.secondary.withValues(alpha: 0.06), width: 1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(_iconForLevel(alert.level), color: color, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alert.message,
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
