import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/category_budget.dart';
import '../models/settings.dart';

class HiveStorage {
  static const String _transactionsBoxName = 'transactionsBox';
  static const String _budgetsBoxName = 'budgetsBox';
  static const String _settingsBoxName = 'settingsBox';

  late Box<Transaction> _transactionsBox;
  late Box<CategoryBudget> _budgetsBox;
  late Box<Settings> _settingsBox;

  // Singleton pattern
  static final HiveStorage _instance = HiveStorage._internal();
  factory HiveStorage() => _instance;
  HiveStorage._internal();

  /// Initialize Hive, register adapters, open boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryBudgetAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
    }

    // Open boxes
    _transactionsBox = await Hive.openBox<Transaction>(_transactionsBoxName);
    _budgetsBox = await Hive.openBox<CategoryBudget>(_budgetsBoxName);
    _settingsBox = await Hive.openBox<Settings>(_settingsBoxName);

    // Run migrations if needed
    await _runMigrations();
  }

  Future<void> _runMigrations() async {
    // Check schema versions and migrate data
    // Example: if any Transaction has schemaVersion < 2, update fields
  }

  // ==================== TRANSACTIONS ====================

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
  }

  List<Transaction> getAllTransactions() {
    return _transactionsBox.values.toList();
  }

  Stream<List<Transaction>> watchTransactions() {
    return _transactionsBox.watch().map((_) => getAllTransactions());
  }

  Transaction? getTransactionById(String id) {
    return _transactionsBox.get(id);
  }

  // ==================== BUDGETS ====================

  Future<void> saveBudget(CategoryBudget budget) async {
    await _budgetsBox.put(budget.key, budget);
  }

  Future<void> deleteBudget(String key) async {
    await _budgetsBox.delete(key);
  }

  List<CategoryBudget> getAllBudgets() {
    return _budgetsBox.values.toList();
  }

  Stream<List<CategoryBudget>> watchBudgets() {
    return _budgetsBox.watch().map((_) => getAllBudgets());
  }

  CategoryBudget? getBudget(String key) {
    return _budgetsBox.get(key);
  }

  // ==================== SETTINGS ====================

  Future<void> saveSettings(Settings settings) async {
    await _settingsBox.put('app_settings', settings);
  }

  Settings getSettings() {
    return _settingsBox.get('app_settings') ?? Settings();
  }

  Stream<Settings> watchSettings() {
    return _settingsBox.watch(key: 'app_settings').map((_) => getSettings());
  }

  // ==================== CLEANUP ====================

  Future<void> close() async {
    await _transactionsBox.close();
    await _budgetsBox.close();
    await _settingsBox.close();
  }

  Future<void> clearAll() async {
    await _transactionsBox.clear();
    await _budgetsBox.clear();
    await _settingsBox.clear();
  }
}
