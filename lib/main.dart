import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'storage/hive_storage.dart';
import 'repository/finance_repository.dart';
import 'bloc/transaction/transaction_bloc.dart';
import 'bloc/transaction/transaction_event.dart';
import 'bloc/dashboard/dashboard_bloc.dart';
import 'bloc/dashboard/dashboard_event.dart';
import 'bloc/budget/budget_bloc.dart';
import 'bloc/budget/budget_event.dart';
import 'ui/theme.dart';
import 'ui/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final storage = HiveStorage();
  await storage.init();

  // Initialize repository
  final repository = FinanceRepository(storage);

  runApp(MyFinanceApp(repository: repository));
}

class MyFinanceApp extends StatelessWidget {
  final FinanceRepository repository;

  const MyFinanceApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TransactionBloc(repository: repository)..add(LoadTransactions()),
        ),
        BlocProvider(
          create: (context) => DashboardBloc(repository: repository)..add(LoadDashboard()),
        ),
        BlocProvider(
          create: (context) => BudgetBloc(repository: repository)..add(LoadBudgets()),
        ),
      ],
      child: MaterialApp(
        title: 'MyFinance',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        home: const DashboardScreen(),
      ),
    );
  }
}
