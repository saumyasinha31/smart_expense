import '../models/transaction.dart';
import '../models/category.dart';
import '../models/category_budget.dart';
import '../models/transaction_type.dart';
import '../models/settings.dart';
import '../models/budget_alert_level.dart';
import '../storage/hive_storage.dart';

class FinanceRepository {
  final HiveStorage _storage;

  FinanceRepository(this._storage);

  // ==================== TRANSACTIONS ====================

  Stream<List<Transaction>> watchTransactions() {
    return _storage.watchTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _storage.addTransaction(transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _storage.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _storage.deleteTransaction(id);
  }

  List<Transaction> getAllTransactions() {
    return _storage.getAllTransactions();
  }

  // ==================== BUDGETS ====================

  Stream<List<CategoryBudget>> watchBudgets() {
    return _storage.watchBudgets();
  }

  Future<void> setBudget(Category category, double limit, int month, int year) async {
    final budget = CategoryBudget.create(
      category: category,
      monthlyLimit: limit,
      month: month,
      year: year,
    );
    await _storage.saveBudget(budget);
  }

  Future<void> deleteBudget(Category category, int month, int year) async {
    final key = '${category.index}_${year}_${month}';
    await _storage.deleteBudget(key);
  }

  List<CategoryBudget> getAllBudgets() {
    return _storage.getAllBudgets();
  }

  // ==================== COMPUTED DATA ====================

  Future<double> getBalance() async {
    final transactions = getAllTransactions();
    double balance = 0;
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        balance -= transaction.amount;
      } else {
        balance += transaction.amount;
      }
    }
    return balance;
  }

  Future<Map<Category, double>> getCategoryExpenses({int? month, int? year}) async {
    final transactions = getAllTransactions();
    final expenses = <Category, double>{};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        final include = month == null || year == null ||
            (transaction.date.month == month && transaction.date.year == year);
        if (include) {
          expenses[transaction.category] = (expenses[transaction.category] ?? 0) + transaction.amount;
        }
      }
    }

    return expenses;
  }

  Future<List<Transaction>> getRecentTransactions({int limit = 10}) async {
    final transactions = getAllTransactions();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions.take(limit).toList();
  }

  Future<Map<Category, BudgetAlertLevel>> getBudgetAlerts(int month, int year) async {
    final budgets = getAllBudgets();
    final expenses = await getCategoryExpenses(month: month, year: year);
    final alerts = <Category, BudgetAlertLevel>{};

    for (final budget in budgets) {
      if (budget.month == month && budget.year == year) {
        final spent = expenses[budget.category] ?? 0;
        final percentage = (spent / budget.monthlyLimit) * 100;

        if (percentage >= 100) {
          alerts[budget.category] = BudgetAlertLevel.danger;
        } else if (percentage >= 80) {
          alerts[budget.category] = BudgetAlertLevel.warning;
        } else {
          alerts[budget.category] = BudgetAlertLevel.safe;
        }
      }
    }

    return alerts;
  }

  // ==================== SETTINGS ====================

  Future<void> saveSettings(Settings settings) async {
    await _storage.saveSettings(settings);
  }

  Settings getSettings() {
    return _storage.getSettings();
  }

  Stream<Settings> watchSettings() {
    return _storage.watchSettings();
  }
}
