import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/budget_alert_level.dart';
import '../../utils/formatters.dart';
import '../theme.dart';

class BudgetProgressBar extends StatelessWidget {
  final Category category;
  final double spent;
  final double limit;
  final BudgetAlertLevel alertLevel;

  const BudgetProgressBar({
    Key? key,
    required this.category,
    required this.spent,
    required this.limit,
    required this.alertLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (spent / limit).clamp(0.0, 1.0);
    final progressColor = _getProgressColor();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(int.parse(category.colorHex.replaceFirst('#', '0xff'))),
                  child: Text(category.icon, style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${AppFormatters.formatCurrency(spent)} / ${AppFormatters.formatCurrency(limit)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(percentage * 100).toInt()}%',
                    style: TextStyle(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor() {
    switch (alertLevel) {
      case BudgetAlertLevel.safe:
        return AppColors.successGreen;
      case BudgetAlertLevel.warning:
        return AppColors.warningOrange;
      case BudgetAlertLevel.danger:
        return AppColors.errorRed;
    }
  }
}
