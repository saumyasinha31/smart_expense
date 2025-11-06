import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/finance_repository.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final FinanceRepository repository;

  BudgetBloc({required this.repository}) : super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<SetBudget>(_onSetBudget);
    on<DeleteBudget>(_onDeleteBudget);
  }

  void _onLoadBudgets(LoadBudgets event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final now = DateTime.now();
      final budgets = repository.getAllBudgets();
      final currentSpent = await repository.getCategoryExpenses(
        month: now.month,
        year: now.year,
      );
      final alerts = await repository.getBudgetAlerts(now.month, now.year);

      emit(BudgetLoaded(
        budgets: budgets,
        currentSpent: currentSpent,
        alerts: alerts,
      ));
    } catch (e) {
      emit(BudgetError('Failed to load budgets: $e'));
    }
  }

  void _onSetBudget(SetBudget event, Emitter<BudgetState> emit) async {
    try {
      await repository.setBudget(
        event.category,
        event.limit,
        event.month,
        event.year,
      );
      emit(BudgetSet());
      add(LoadBudgets()); // Reload after set
    } catch (e) {
      emit(BudgetError('Failed to set budget: $e'));
    }
  }

  void _onDeleteBudget(DeleteBudget event, Emitter<BudgetState> emit) async {
    try {
      await repository.deleteBudget(event.category, event.month, event.year);
      emit(BudgetDeleted());
      add(LoadBudgets()); // Reload after delete
    } catch (e) {
      emit(BudgetError('Failed to delete budget: $e'));
    }
  }
}
