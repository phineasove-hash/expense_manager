import 'package:expense_manager/services/recurring_service.dart';
import 'package:flutter/material.dart';

import 'database/hive_database.dart';
import 'screens/main_navigation.dart';
import 'services/theme_controller.dart';
import 'theme/app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.init();

  //Genere automatiquement les transactions recurrentes qui auraient du se repeter depuis la derniere ouverture de l'app.
  await RecurringService().generateDueRecurringTransaction();
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  // Clé stable, créée une seule fois pour toute la durée de vie de l'app.
  // Elle garantit que le Navigator garde son identité même quand
  // MaterialApp se reconstruit (ex: changement de thème), ce qui évite
  // les conflits avec une animation de transition en cours.
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Expense Manager',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const MainNavigation(),
        );
      },
    );
  }
}


