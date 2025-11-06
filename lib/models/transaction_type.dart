/// Transaction type enum
enum TransactionType {
  income,
  expense,
}

/// Extension for TransactionType display properties
extension TransactionTypeExtension on TransactionType {
  /// Human-readable name
  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
    }
  }

  /// Icon for the transaction type
  String get icon {
    switch (this) {
      case TransactionType.income:
        return '💰';
      case TransactionType.expense:
        return '💸';
    }
  }
}
