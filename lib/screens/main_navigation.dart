import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'transactions_screen.dart';
import 'budget_screen.dart';
import 'statistics_screen.dart';
import 'planning_screen.dart';

// `MainNavigation` gère la barre de navigation en bas et choisit
// quel écran afficher selon l'index sélectionné.
// Ne modifie pas la navigation : ces commentaires décrivent juste
// la façon dont les écrans sont construits via `_buildScreen`.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const TransactionsScreen();
      case 2:
        return const BudgetScreen();
      case 3:
        return const StatisticsScreen();
      case 4:
        return const PlanningScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreen(currentIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            label: 'Plan',
          ),
        ],
      ),
    );
  }
}
