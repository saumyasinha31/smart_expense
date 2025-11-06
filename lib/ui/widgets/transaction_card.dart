import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../utils/formatters.dart';
import '../theme.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type.index == 1; // TransactionType.expense
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(int.parse(transaction.category.colorHex.replaceFirst('#', '0xff'))),
          child: Text(
            transaction.category.icon,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          AppFormatters.formatCurrency(transaction.amount),
          style: TextStyle(
            color: isExpense ? AppColors.errorRed : AppColors.successGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.category.displayName),
            Text(
              AppFormatters.formatDate(transaction.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (transaction.note.isNotEmpty)
              Text(
                transaction.note,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: Icon(
          isExpense ? Icons.arrow_downward : Icons.arrow_upward,
          color: isExpense ? AppColors.errorRed : AppColors.successGreen,
        ),
      ),
    );
  }
}
