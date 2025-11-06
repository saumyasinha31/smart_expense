import 'package:equatable/equatable.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final double balance;
  final List<Transaction> recentTransactions;
  final Map<Category, double> categoryExpenses;

  const DashboardLoaded({
    required this.balance,
    required this.recentTransactions,
    required this.categoryExpenses,
  });

  @override
  List<Object?> get props => [balance, recentTransactions, categoryExpenses];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
