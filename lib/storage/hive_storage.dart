import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/category_budget.dart';
import '../models/settings.dart';

class HiveStorage {
  static const String _transactionsBoxName = 'transactionsBox';
  static const String _budgetsBoxName = 'budgetsBox';
  static const String _settingsBoxName = 'settingsBox';

  Box<Transaction>? _transactionsBox;
  Box<CategoryBudget>? _budgetsBox;
  Box<Settings>? _settingsBox;

  // Singleton pattern
  static final HiveStorage _instance = HiveStorage._internal();
  factory HiveStorage() => _instance;
  HiveStorage._internal();

  /// Initialize Hive, register adapters, open boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    try {
    if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TransactionAdapter());
      }
    if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CategoryBudgetAdapter());
      }
    if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SettingsAdapter());
      }
    } catch (e) {
      // Ignore if registration fails
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
  if (_transactionsBox == null) return;
  try {
    await _transactionsBox!.put(transaction.id, transaction);
  } catch (e) {
    // Ignore or log
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
  if (_transactionsBox == null) return;
  try {
    await _transactionsBox!.put(transaction.id, transaction);
  } catch (e) {
    // Ignore or log
    }
  }

  Future<void> deleteTransaction(String id) async {
  if (_transactionsBox == null) return;
  try {
  await _transactionsBox!.delete(id);
  } catch (e) {
      // Ignore or log
    }
  }

  List<Transaction> getAllTransactions() {
  if (_transactionsBox == null) return [];
  try {
    return _transactionsBox!.values.toList();
  } catch (e) {
    return [];
    }
  }

  Stream<List<Transaction>> watchTransactions() {
  if (_transactionsBox == null) return Stream.value([]);
  try {
    return _transactionsBox!.watch().map((_) => getAllTransactions());
  } catch (e) {
    return Stream.value([]);
    }
  }

  Transaction? getTransactionById(String id) {
    if (_transactionsBox == null) return null;
    try {
      return _transactionsBox!.get(id);
    } catch (e) {
      return null;
    }
  }

  // ==================== BUDGETS ====================

  Future<void> saveBudget(CategoryBudget budget) async {
  if (_budgetsBox == null) return;
  try {
    await _budgetsBox!.put(budget.key, budget);
  } catch (e) {
    // Ignore or log
    }
  }

  Future<void> deleteBudget(String key) async {
  if (_budgetsBox == null) return;
  try {
  await _budgetsBox!.delete(key);
  } catch (e) {
      // Ignore or log
    }
  }

  List<CategoryBudget> getAllBudgets() {
  if (_budgetsBox == null) return [];
  try {
    return _budgetsBox!.values.toList();
  } catch (e) {
    return [];
    }
  }

  Stream<List<CategoryBudget>> watchBudgets() {
  if (_budgetsBox == null) return Stream.value([]);
  try {
    return _budgetsBox!.watch().map((_) => getAllBudgets());
  } catch (e) {
    return Stream.value([]);
    }
  }

  CategoryBudget? getBudget(String key) {
    if (_budgetsBox == null) return null;
    try {
      return _budgetsBox!.get(key);
    } catch (e) {
      return null;
    }
  }

  // ==================== SETTINGS ====================

  Future<void> saveSettings(Settings settings) async {
  if (_settingsBox == null) return;
  try {
    await _settingsBox!.put('app_settings', settings);
  } catch (e) {
    // Ignore or log
    }
  }

  Settings getSettings() {
  if (_settingsBox == null) return Settings();
  try {
    return _settingsBox!.get('app_settings') ?? Settings();
  } catch (e) {
    return Settings();
    }
  }

  Stream<Settings> watchSettings() {
  if (_settingsBox == null) return Stream.value(Settings());
  try {
    return _settingsBox!.watch(key: 'app_settings').map((_) => getSettings());
  } catch (e) {
    return Stream.value(Settings());
    }
  }

  // ==================== CLEANUP ====================

  Future<void> close() async {
    try {
      await _transactionsBox?.close();
      await _budgetsBox?.close();
      await _settingsBox?.close();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> clearAll() async {
    try {
      await _transactionsBox?.clear();
      await _budgetsBox?.clear();
      await _settingsBox?.clear();
    } catch (e) {
      // Ignore
    }
  }
}
