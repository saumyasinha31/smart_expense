import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/transaction.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../widgets/transaction_card.dart';
import 'add_edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late List<Transaction> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionLoaded) {
          setState(() {
            _transactions = state.transactions;
          });
        }
      },
      builder: (context, state) {
        if (state is TransactionLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<TransactionBloc>().add(LoadTransactions());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return Dismissible(
                  key: Key(transaction.id),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.blue,
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text('Are you sure you want to delete this transaction?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    return true;
                  },
                  onDismissed: (direction) {
                    setState(() {
                      _transactions.removeAt(index);
                    });
                    if (direction == DismissDirection.startToEnd) {
                      context.read<TransactionBloc>().add(DeleteTransaction(transaction.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Transaction deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              context.read<TransactionBloc>().add(AddTransaction(transaction));
                            },
                          ),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditTransactionScreen(transaction: transaction),
                        ),
                      );
                    }
                  },
                  child: TransactionCard(
                    transaction: transaction,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditTransactionScreen(transaction: transaction),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }

        if (state is TransactionError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
