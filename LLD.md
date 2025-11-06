# MyFinance — Low-Level Design (LLD)

> Detailed class definitions, method signatures, Hive schema, and Bloc/GetX mappings.

---

## Table of Contents

1. [Models & Hive Schema](#models--hive-schema)
2. [Storage Layer](#storage-layer)
3. [Repository Layer](#repository-layer)
4. [Bloc Layer](#bloc-layer)
5. [UI Layer](#ui-layer)
6. [Utils & Constants](#utils--constants)
7. [Sequence Diagrams](#sequence-diagrams)

---

## Models & Hive Schema

### **1. Transaction Model**

**File:** `lib/models/transaction.dart`

```dart
import 'package:hive/hive.dart';
import 'category.dart';
import 'transaction_type.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final int categoryIndex; // Store enum as int

  @HiveField(3)
  final int typeIndex; // Store enum as int

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String note;

  @HiveField(6)
  final int schemaVersion; // For migrations

  Transaction({
    required this.id,
    required this.amount,
    required this.categoryIndex,
    required this.typeIndex,
    required this.date,
    required this.note,
    this.schemaVersion = 1,
  });

  // Convenience getters
  Category get category => Category.values[categoryIndex];
  TransactionType get type => TransactionType.values[typeIndex];

  // Factory for creation
  factory Transaction.create({
    required double amount,
    required Category category,
    required TransactionType type,
    required DateTime date,
    String note = '',
  }) {
    return Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      categoryIndex: category.index,
      typeIndex: type.index,
      date: date,
      note: note,
    );
  }

  Transaction copyWith({
    String? id,
    double? amount,
    Category? category,
    TransactionType? type,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryIndex: category?.index ?? this.categoryIndex,
      typeIndex: type?.index ?? this.typeIndex,
      date: date ?? this.date,
      note: note ?? this.note,
      schemaVersion: this.schemaVersion,
    );
  }
}
```

**Hive TypeAdapter:** Auto-generated via `build_runner` → `transaction.g.dart`

**TypeId:** 0

**Fields:**
- `id` (String) — Unique identifier (timestamp-based)
- `amount` (double) — Transaction amount
- `categoryIndex` (int) — Enum index for Category
- `typeIndex` (int) — Enum index for TransactionType
- `date` (DateTime) — Transaction date
- `note` (String) — Optional memo
- `schemaVersion` (int) — For future migrations (default: 1)

---

### **2. CategoryBudget Model**

**File:** `lib/models/category_budget.dart`

```dart
import 'package:hive/hive.dart';
import 'category.dart';

part 'category_budget.g.dart';

@HiveType(typeId: 1)
class CategoryBudget extends HiveObject {
  @HiveField(0)
  final int categoryIndex;

  @HiveField(1)
  final double monthlyLimit;

  @HiveField(2)
  final int month; // 1-12

  @HiveField(3)
  final int year;

  @HiveField(4)
  final int schemaVersion;

  CategoryBudget({
    required this.categoryIndex,
    required this.monthlyLimit,
    required this.month,
    required this.year,
    this.schemaVersion = 1,
  });

  Category get category => Category.values[categoryIndex];

  String get key => '${categoryIndex}_${year}_${month}';

  factory CategoryBudget.create({
    required Category category,
    required double monthlyLimit,
    required int month,
    required int year,
  }) {
    return CategoryBudget(
      categoryIndex: category.index,
      monthlyLimit: monthlyLimit,
      month: month,
      year: year,
    );
  }

  CategoryBudget copyWith({
    double? monthlyLimit,
  }) {
    return CategoryBudget(
      categoryIndex: this.categoryIndex,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      month: this.month,
      year: this.year,
      schemaVersion: this.schemaVersion,
    );
  }
}
```

**TypeId:** 1

**Fields:**
- `categoryIndex` (int) — Category enum index
- `monthlyLimit` (double) — Budget limit for the month
- `month` (int) — Month (1-12)
- `year` (int) — Year
- `schemaVersion` (int)

**Key Strategy:** Composite key `categoryIndex_year_month` for lookups

---

### **3. Category Enum**

**File:** `lib/models/category.dart`

```dart
enum Category {
  food,
  travel,
  bills,
  shopping,
  entertainment,
  others,
}

extension CategoryExtension on Category {
  String get displayName {
    switch (this) {
      case Category.food:
        return 'Food';
      case Category.travel:
        return 'Travel';
      case Category.bills:
        return 'Bills';
      case Category.shopping:
        return 'Shopping';
      case Category.entertainment:
        return 'Entertainment';
      case Category.others:
        return 'Others';
    }
  }

  String get icon {
    switch (this) {
      case Category.food:
        return '🍔';
      case Category.travel:
        return '✈️';
      case Category.bills:
        return '📄';
      case Category.shopping:
        return '🛍️';
      case Category.entertainment:
        return '🎬';
      case Category.others:
        return '📦';
    }
  }

  String get colorHex {
    switch (this) {
      case Category.food:
        return '#EF4444'; // Red
      case Category.travel:
        return '#3B82F6'; // Blue
      case Category.bills:
        return '#F59E0B'; // Orange
      case Category.shopping:
        return '#EC4899'; // Pink
      case Category.entertainment:
        return '#8B5CF6'; // Purple
      case Category.others:
        return '#6B7280'; // Gray
    }
  }
}
```

---

### **4. TransactionType Enum**

**File:** `lib/models/transaction_type.dart`

```dart
enum TransactionType {
  income,
  expense,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
    }
  }
}
```

---

### **5. Settings Model**

**File:** `lib/models/settings.dart`

```dart
import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 2)
class Settings extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final String currency;

  @HiveField(2)
  final int schemaVersion;

  Settings({
    this.isDarkMode = false,
    this.currency = 'USD',
    this.schemaVersion = 1,
  });

  Settings copyWith({
    bool? isDarkMode,
    String? currency,
  }) {
    return Settings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currency: currency ?? this.currency,
      schemaVersion: this.schemaVersion,
    );
  }
}
```

**TypeId:** 2

**Fields:**
- `isDarkMode` (bool) — Theme preference
- `currency` (String) — Currency code (USD, EUR, etc.)
- `schemaVersion` (int)

---

### **Hive TypeId Summary**

| Model | TypeId | Box Name |
|-------|--------|----------|
| Transaction | 0 | `transactionsBox` |
| CategoryBudget | 1 | `budgetsBox` |
| Settings | 2 | `settingsBox` |

**Why these TypeIds?** Sequential starting from 0, easy to remember, deterministic.

---

### **Migration Strategy**

**Scenario:** Add a new field `tags` (List<String>) to Transaction in v2.

**Approach:**
1. Add new field with `@HiveField(7)` and default value
2. Increment `schemaVersion` to 2 in new instances
3. In `HiveStorage.init()`, check existing records:
   ```dart
   if (transaction.schemaVersion < 2) {
     // Migrate: add empty tags, update schemaVersion, save
   }
   ```

**Box versioning:** Store a global schema version in `settingsBox` to track migrations.

---

## Storage Layer

### **HiveStorage Class**

**File:** `lib/storage/hive_storage.dart`

```dart
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
```

---

## Repository Layer

### **FinanceRepository Class**

**File:** `lib/repository/finance_repository.dart`

```dart
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/category_budget.dart';
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
      limit: limit,
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
```

---

## UI Layer

### **Theme Configuration**

**File:** `lib/ui/theme.dart`

```dart
import 'package:flutter/material.dart';

/// App color palette with purple, white, and yellow theme
class AppColors {
  // Purple shades
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFA78BFA);
  static const Color palePurple = Color(0xFFEDE9FE);

  // Accent
  static const Color accentYellow = Color(0xFFFCD34D);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);
  static const Color backgroundGray = Color(0xFFF9FAFB);

  // Status colors
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
}

/// Light theme configuration
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryPurple,
    secondary: AppColors.accentYellow,
    surface: AppColors.white,
    error: AppColors.errorRed,
  ),
  scaffoldBackgroundColor: AppColors.backgroundGray,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryPurple,
    foregroundColor: AppColors.white,
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: AppColors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.textGray),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.textGray),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.errorRed),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryPurple,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      elevation: 2,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.accentYellow,
    foregroundColor: AppColors.textDark,
    elevation: 4,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textDark,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textDark,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.textDark,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.textGray,
    ),
  ),
);

/// Dark theme configuration
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.lightPurple,
    secondary: AppColors.accentYellow,
    surface: Color(0xFF1F2937),
    error: AppColors.errorRed,
  ),
  scaffoldBackgroundColor: const Color(0xFF111827),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F2937),
    foregroundColor: AppColors.white,
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardTheme(
    elevation: 4,
    color: const Color(0xFF1F2937),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF374151),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF4B5563)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF4B5563)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.lightPurple, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightPurple,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.white,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.white,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.white,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Color(0xFF9CA3AF),
    ),
  ),
);
```

---

## Utils & Constants

### **Validators**

**File:** `lib/utils/validators.dart`

```dart
class Validators {
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Invalid amount';
    }
    if (amount <= 0) {
      return 'Amount must be positive';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
```

---

### **Formatters**

**File:** `lib/utils/formatters.dart`

```dart
import 'package:intl/intl.dart';

class AppFormatters {
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  static String formatMonthYear(int month, int year) {
    final date = DateTime(year, month);
    return DateFormat('MMMM yyyy').format(date);
  }
}
```

---

### **Constants**

**File:** `lib/utils/constants.dart`

```dart
class AppConstants {
  static const String appName = 'MyFinance';
  static const int recentTransactionLimit = 10;
  static const double budgetWarningThreshold = 80.0; // percentage
  static const double budgetDangerThreshold = 100.0;
}
```

---

## Sequence Diagrams

### **Add Transaction Flow**

```
User                UI                  TransactionBloc      Repository          HiveStorage
  |                   |                        |                  |                    |
  |--Fill Form------->|                        |                  |                    |
  |                   |                        |                  |                    |
  |--Tap Save-------->|                        |                  |                    |
  |                   |                        |                  |                    |
  |                   |--add(AddTransaction)-->|                  |                    |
  |                   |                        |                  |                    |
  |                   |                        |--addTransaction->|                    |
  |                   |                        |                  |                    |
  |                   |                        |                  |--put(txn)--------->|
  |                   |                        |                  |                    |
  |                   |                        |                  |<---Future<void>----|
  |                   |                        |                  |                    |
  |                   |                        |<--Future<void>---|                    |
  |                   |                        |                  |                    |
  |                   |<--emit(Success)--------|                  |                    |
  |                   |                        |                  |                    |
  |<--Show Snackbar---|                        |                  |                    |
  |<--Navigate Back---|                        |                  |                    |
  |                   |                        |                  |                    |
```

---

### **Budget Alert Flow**

```
Transaction Added    DashboardBloc       BudgetBloc         Repository
      |                    |                   |                  |
      |--notify---------->|                   |                  |
      |                    |                   |                  |
      |                    |                   |<--watchTransactions()
      |                    |                   |                  |
      |                    |                   |--getCategorySpent->|
      |                    |                   |                  |
      |                    |                   |<--spent: $850----|
      |                    |                   |                  |
      |                    |      Calculate:   |                  |
      |                    |      $850/$1000 = 85%               |
      |                    |                   |                  |
      |                    |<--emit(BudgetAlert: warning)--------|
      |                    |                   |                  |
      UI shows yellow badge on budget screen
```

---

**STOP HERE. Awaiting your approval of this LLD before I begin code implementation.**

**Next Steps After Approval:**
1. Phase 1: Initialize Flutter project, add dependencies, folder structure
2. Phase 2: Implement models & generate Hive adapters
3. Phase 3: Build storage layer
4. Phase 4: Implement blocs & repository
5. Phase 5: Build UI screens
6. Phase 6: Add tests
7. Phase 7: Polish & README
