import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/finance_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final FinanceRepository repository;
  late final StreamSubscription _transactionSubscription;

  DashboardBloc({required this.repository}) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);

    try {
      _transactionSubscription = repository.watchTransactions().listen((_) {
        add(LoadDashboard());
      });
    } catch (e) {
      // If watching fails, ignore for now
    }
  }

  @override
  Future<void> close() {
    _transactionSubscription.cancel();
    return super.close();
  }

  Future<void> _onLoadDashboard(LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final balance = await repository.getBalance();
      final recentTransactions = await repository.getRecentTransactions(limit: 10);
      final categoryExpenses = await repository.getCategoryExpenses();

      emit(DashboardLoaded(
        balance: balance,
        recentTransactions: recentTransactions,
        categoryExpenses: categoryExpenses,
      ));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard: $e'));
    }
  }

  void _onRefreshDashboard(RefreshDashboard event, Emitter<DashboardState> emit) async {
    await _onLoadDashboard(LoadDashboard(), emit);
  }
}
