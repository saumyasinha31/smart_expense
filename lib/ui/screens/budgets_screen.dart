import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/category.dart';
import '../../models/budget_alert_level.dart';
import '../../bloc/budget/budget_bloc.dart';
import '../../bloc/budget/budget_state.dart';
import '../../bloc/budget/budget_event.dart';
import '../widgets/budget_progress_bar.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({Key? key}) : super(key: key);

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final Map<Category, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final category in Category.values) {
      _controllers[category] = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<BudgetBloc>().add(LoadBudgets());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: Category.values.map((category) {
                  final budget = state.budgets.firstWhere(
                    (b) => b.category == category && b.month == DateTime.now().month && b.year == DateTime.now().year,
                    orElse: () => null as dynamic,
                  );
                  final spent = state.currentSpent[category] ?? 0;
                  final limit = budget?.monthlyLimit ?? 0;
                  final alertLevel = state.alerts[category] ?? BudgetAlertLevel.safe;

                  return Column(
                    children: [
                      BudgetProgressBar(
                        category: category,
                        spent: spent,
                        limit: limit,
                        alertLevel: alertLevel,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controllers[category],
                              decoration: InputDecoration(
                                labelText: 'Set budget for ${category.displayName}',
                                hintText: limit > 0 ? limit.toString() : 'Enter amount',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final amount = double.tryParse(_controllers[category]!.text);
                              if (amount != null && amount > 0) {
                                final now = DateTime.now();
                                context.read<BudgetBloc>().add(SetBudget(
                                  category: category,
                                  limit: amount,
                                  month: now.month,
                                  year: now.year,
                                ));
                                _controllers[category]!.clear();
                              }
                            },
                            child: const Text('Set'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            );
          }

          if (state is BudgetError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
