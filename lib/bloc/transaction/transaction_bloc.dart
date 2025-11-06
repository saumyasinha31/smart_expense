import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/finance_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final FinanceRepository repository;

  TransactionBloc({required this.repository}) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  void _onLoadTransactions(LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final transactions = repository.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError('Failed to load transactions: $e'));
    }
  }

  void _onAddTransaction(AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      await repository.addTransaction(event.transaction);
      emit(TransactionAdded());
      add(LoadTransactions()); // Reload after add
    } catch (e) {
      emit(TransactionError('Failed to add transaction: $e'));
    }
  }

  void _onUpdateTransaction(UpdateTransaction event, Emitter<TransactionState> emit) async {
    try {
      await repository.updateTransaction(event.transaction);
      emit(TransactionUpdated());
      add(LoadTransactions()); // Reload after update
    } catch (e) {
      emit(TransactionError('Failed to update transaction: $e'));
    }
  }

  void _onDeleteTransaction(DeleteTransaction event, Emitter<TransactionState> emit) async {
    try {
      await repository.deleteTransaction(event.id);
      emit(TransactionDeleted());
      add(LoadTransactions()); // Reload after delete
    } catch (e) {
      emit(TransactionError('Failed to delete transaction: $e'));
    }
  }
}
