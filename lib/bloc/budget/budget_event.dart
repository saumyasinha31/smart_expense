import 'package:equatable/equatable.dart';
import '../../models/category.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudgets extends BudgetEvent {}

class SetBudget extends BudgetEvent {
  final Category category;
  final double limit;
  final int month;
  final int year;

  const SetBudget({
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [category, limit, month, year];
}

class DeleteBudget extends BudgetEvent {
  final Category category;
  final int month;
  final int year;

  const DeleteBudget({
    required this.category,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [category, month, year];
}
