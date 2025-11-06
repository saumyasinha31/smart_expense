enum BudgetAlertLevel {
  safe,
  warning,
  danger,
}

extension BudgetAlertLevelExtension on BudgetAlertLevel {
  String get displayName {
    switch (this) {
      case BudgetAlertLevel.safe:
        return 'Safe';
      case BudgetAlertLevel.warning:
        return 'Warning';
      case BudgetAlertLevel.danger:
        return 'Danger';
    }
  }

  String get colorHex {
    switch (this) {
      case BudgetAlertLevel.safe:
        return '#10B981'; // Green
      case BudgetAlertLevel.warning:
        return '#F59E0B'; // Orange
      case BudgetAlertLevel.danger:
        return '#EF4444'; // Red
    }
  }
}
