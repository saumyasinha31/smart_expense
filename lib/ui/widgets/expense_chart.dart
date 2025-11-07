import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/category.dart';
import '../theme.dart';

class ExpenseChart extends StatelessWidget {
  final Map<Category, double> categoryData;

  const ExpenseChart({Key? key, required this.categoryData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No expenses to display',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    final sections = categoryData.entries.map((entry) {
      final color = Color(int.parse(entry.key.colorHex.replaceFirst('#', '0xff')));
      return PieChartSectionData(
        value: entry.value,
        color: color,
        radius: 80,
        showTitle: false,
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expenses by Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: categoryData.entries.map((entry) {
                final color = Color(int.parse(entry.key.colorHex.replaceFirst('#', '0xff')));
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.key.displayName}: ₹${entry.value.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
