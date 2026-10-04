import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const BalanceCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final double balance = totalIncome - totalExpense;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondary, // indigo profond, fixe dans les 2 thèmes
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label or, en majuscules espacées — le ton "signature"
                const Text(
                  'SOLDE ACTUEL',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                // Le chiffre héros : grand, serif, c'est LE point focal de l'écran
                Text(
                  balance.toStringAsFixed(0),
                  style: AppTheme.displayFont(fontSize: 34, color: const Color(0xFFF7F3EC)),
                ),
                Text(
                  'FCFA',
                  style: TextStyle(color: AppColors.gold.withValues(alpha: 0.7), fontSize: 12),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAmountColumn('Revenus', totalIncome, AppColors.income),
                    _buildAmountColumn('Dépenses', totalExpense, const Color(0xFFE0836F)),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
          // La frise dorée en zigzag : l'unique élément décoratif de l'app,
          // volontairement réservé à cet endroit précis (et à la barre de
          // progression du budget), pour ne pas devenir du "bruit" visuel.
          _buildZigzagStrip(),
        ],
      ),
    );
  }

  Widget _buildZigzagStrip() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
      child: SizedBox(
        height: 10,
        width: double.infinity,
        child: CustomPaint(painter: _ZigzagPainter()),
      ),
    );
  }

  Widget _buildAmountColumn(String label, double amount, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF9AA4BE), fontSize: 11)),
            Text(
              '${amount.toStringAsFixed(0)} FCFA',
              style: const TextStyle(color: Color(0xFFF7F3EC), fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

// Dessine la frise en triangles alternés (or / indigo / brique),
// inspirée des motifs tissés, sans copier un motif culturel précis.
class _ZigzagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const stripeWidth = 16.0;
    final colors = [AppColors.gold, AppColors.secondary, const Color(0xFFB94A3D), AppColors.secondary];
    int i = 0;
    for (double x = -stripeWidth; x < size.width + stripeWidth; x += stripeWidth) {
      final paint = Paint()..color = colors[i % colors.length];
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeWidth / 2, size.height)
        ..lineTo(x + stripeWidth, 0)
        ..close();
      canvas.drawPath(path, paint);
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}