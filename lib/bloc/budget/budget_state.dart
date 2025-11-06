import 'package:equatable/equatable.dart';
import '../../models/category_budget.dart';
import '../../models/category.dart';
import '../../models/budget_alert_level.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<CategoryBudget> budgets;
  final Map<Category, double> currentSpent;
  final Map<Category, BudgetAlertLevel> alerts;

  const BudgetLoaded({
    required this.budgets,
    required this.currentSpent,
    required this.alerts,
  });

  @override
  List<Object?> get props => [budgets, currentSpent, alerts];
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}

class BudgetSet extends BudgetState {}

class BudgetDeleted extends BudgetState {}
