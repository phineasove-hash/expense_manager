import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/app_colors.dart';
import '../theme/category_style.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategoryPieChart({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(child: Text('Aucune dépense à afficher', style: TextStyle(color: AppColors.textSecondary(context)))),
      );
    }

    final total = categoryTotals.values.fold(0.0, (sum, v) => sum + v);
    final entries = categoryTotals.entries.toList();

    return Row(
      children: [
        SizedBox(
          height: 160,
          width: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: entries.map((entry) {
                final percentage = (entry.value / total * 100);
                return PieChartSectionData(
                  value: entry.value,
                  color: CategoryStyle.colorOf(entry.key),
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: 45,
                  titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: CategoryStyle.colorOf(entry.key), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.key, style: TextStyle(fontSize: 12, color: AppColors.textPrimary(context)), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class BalanceLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color lineColor;

  const BalanceLineChart({super.key, required this.spots, this.lineColor = AppColors.secondary});

  String _formatAmount(double value) {
    if (value.abs() >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    if (spots.length < 2) {
      return SizedBox(
        height: 200,
        child: Center(child: Text('Pas assez de données', style: TextStyle(color: AppColors.textSecondary(context)))),
      );
    }

    final gridColor = AppColors.background(context);
    final labelColor = AppColors.textSecondary(context);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(color: gridColor, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 7,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(value.toInt().toString(), style: TextStyle(fontSize: 10, color: labelColor)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) => Text(_formatAmount(value), style: TextStyle(fontSize: 10, color: labelColor)),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: lineColor,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: lineColor.withValues(alpha: 0.1)),
            ),
          ],
        ),
      ),
    );
  }
}

class WeekdayBarChart extends StatelessWidget {
  final List<double> amountsByWeekday;

  const WeekdayBarChart({super.key, required this.amountsByWeekday});

  static const List<String> _dayLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  String _formatAmount(double value) {
    if (value.abs() >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = amountsByWeekday.isEmpty ? 0.0 : amountsByWeekday.reduce((a, b) => a > b ? a : b);
    final labelColor = AppColors.textSecondary(context);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxValue == 0 ? 10 : maxValue * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) => Text(_formatAmount(value), style: TextStyle(fontSize: 10, color: labelColor)),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= _dayLabels.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_dayLabels[index], style: TextStyle(fontSize: 11, color: labelColor)),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(amountsByWeekday.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(toY: amountsByWeekday[index], color: AppColors.expense, width: 16, borderRadius: BorderRadius.circular(4)),
              ],
            );
          }),
        ),
      ),
    );
  }
}