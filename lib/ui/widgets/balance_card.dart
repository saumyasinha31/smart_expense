import 'package:flutter/material.dart';
import '../../utils/formatters.dart';
import '../theme.dart';

class BalanceCard extends StatelessWidget {
  final double balance;

  const BalanceCard({Key? key, required this.balance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Balance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              AppFormatters.formatCurrency(balance.abs()),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: isPositive ? AppColors.successGreen : AppColors.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              isPositive ? 'Positive' : 'Negative',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isPositive ? AppColors.successGreen : AppColors.errorRed,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
