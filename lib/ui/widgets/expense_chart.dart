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
        title: '${entry.key.displayName}\n\$${entry.value.toStringAsFixed(0)}',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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
            const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }
}
