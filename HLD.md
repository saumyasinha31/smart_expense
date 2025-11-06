# MyFinance — High-Level Design

> Personal finance tracker with offline-first architecture, budget tracking, and expense analytics.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                             │
│  Dashboard • Transactions • Add/Edit • Budgets • Settings   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ BlocBuilder / BlocListener
                         │ dispatch events → receive states
                         │
┌────────────────────────▼────────────────────────────────────┐
│                      Bloc Layer                             │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Transaction  │  │  Dashboard   │  │   Budget     │      │
│  │    Bloc      │  │    Bloc      │  │    Bloc      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ repository methods
                         │ streams for real-time updates
                         │
┌────────────────────────▼────────────────────────────────────┐
│                  Repository Layer                           │
│                 FinanceRepository                           │
│                                                              │
│  • addTransaction()      • getTransactions()                │
│  • updateTransaction()   • deleteTransaction()              │
│  • setBudget()           • getBudgets()                     │
│  • getBalance()          • getCategoryExpenses()            │
│                                                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ CRUD operations
                         │ Stream<List<T>>
                         │
┌────────────────────────▼────────────────────────────────────┐
│                    Storage Layer                            │
│                     HiveStorage                             │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │transactions  │  │   budgets    │  │  settings    │      │
│  │     Box      │  │     Box      │  │     Box      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Core Components

### **UI Layer** (`lib/ui/`)

Screens and widgets that users interact with. Each screen uses `BlocBuilder` to rebuild on state changes.

**Screens:**
- **Dashboard** — Balance card, recent transactions, expense chart
- **Transactions** — List of all transactions with search/filter
- **Add/Edit Transaction** — Form with validation
- **Budgets** — Category budget limits with progress bars
- **Settings** — Theme toggle, preferences

**Widgets:**
- `TransactionCard` — Single transaction tile
- `CategoryBadge` — Icon + color for categories
- `BudgetProgressBar` — Visual budget consumption
- `ExpenseChart` — Pie/bar chart for categories

---

### **Bloc Layer** (`lib/bloc/`)

State management using `flutter_bloc`. Each Bloc handles specific domain logic.

#### **TransactionBloc**
Manages transaction CRUD operations.

**Events:**
- `LoadTransactions` — Fetch all transactions
- `AddTransaction` — Save new transaction
- `UpdateTransaction` — Edit existing transaction
- `DeleteTransaction` — Remove transaction (with undo buffer)

**States:**
- `TransactionLoading`
- `TransactionLoaded(List<Transaction>)`
- `TransactionError(String message)`

#### **DashboardBloc**
Computes dashboard metrics from transaction data.

**Events:**
- `LoadDashboard` — Calculate balance, recent items, category totals

**States:**
- `DashboardLoading`
- `DashboardLoaded(balance, recentTransactions, categoryData)`
- `DashboardError(String message)`

#### **BudgetBloc**
Manages category budgets and alerts.

**Events:**
- `LoadBudgets` — Fetch all budget limits
- `SetBudget(category, amount)` — Set monthly limit
- `CheckBudgetAlerts` — Evaluate if any category is near/over limit

**States:**
- `BudgetLoading`
- `BudgetLoaded(List<CategoryBudget>)`
- `BudgetAlert(category, percentage, severity)` — Yellow (≥80%), Red (≥100%)

---

### **Repository Layer** (`lib/repository/`)

Single source of truth. Abstracts storage and provides streams for reactive updates.

**FinanceRepository:**
```dart
class FinanceRepository {
  Stream<List<Transaction>> watchTransactions()
  Future<void> addTransaction(Transaction transaction)
  Future<void> updateTransaction(Transaction transaction)
  Future<void> deleteTransaction(String id)

  Stream<List<CategoryBudget>> watchBudgets()
  Future<void> setBudget(Category category, double limit)

  Future<double> getBalance()
  Future<Map<Category, double>> getCategoryExpenses()
}
```

---

### **Storage Layer** (`lib/storage/`)

Hive-based offline persistence.

**HiveStorage:**
- Opens 3 boxes on app init: `transactionsBox`, `budgetsBox`, `settingsBox`
- Registers type adapters for custom models
- Provides async CRUD methods
- Exposes streams via `.watch()` for reactive data

**Hive Models:**
- **Transaction** (typeId: 0) — id, amount, category, type, date, note
- **CategoryBudget** (typeId: 1) — category, monthlyLimit, currentSpent
- **Settings** (typeId: 2) — isDarkMode, currency

---

## Data Flow

### **Add Transaction Flow**

```
User fills form
     ↓
Taps "Save" button
     ↓
UI: context.read<TransactionBloc>().add(AddTransactionEvent(transaction))
     ↓
TransactionBloc receives event
     ↓
Calls repository.addTransaction(transaction)
     ↓
Repository calls hiveStorage.add(transaction)
     ↓
Hive saves to transactionsBox
     ↓
TransactionBloc emits TransactionAddedState
     ↓
UI (BlocListener) shows success snackbar, navigates back
     ↓
DashboardBloc (watching repository stream) auto-recomputes balance/chart
     ↓
Dashboard UI rebuilds with updated data
```

---

### **Dashboard Load Flow**

```
Dashboard screen init
     ↓
UI: context.read<DashboardBloc>().add(LoadDashboardEvent())
     ↓
DashboardBloc fetches data from repository
     ↓
Repository reads from Hive boxes (transactions + budgets)
     ↓
Bloc computes:
 • balance = Σ(income) - Σ(expense)
 • recentTransactions = last 10 sorted by date
 • categoryData = group by category, sum amounts
     ↓
Emits DashboardLoadedState(balance, recent, categoryData)
     ↓
BlocBuilder rebuilds UI with:
 • Balance card
 • Recent transactions list
 • Pie chart of category expenses
```

---

### **Budget Alert Flow**

```
New transaction added
     ↓
Repository stream notifies BudgetBloc
     ↓
BudgetBloc recalculates currentSpent for affected category
     ↓
Checks: currentSpent vs monthlyLimit
     ↓
If ≥80%: emit BudgetAlertState(category, percentage, 'warning')
If ≥100%: emit BudgetAlertState(category, percentage, 'danger')
     ↓
Budgets screen (BlocBuilder) updates progress bar color:
 • Yellow for warning
 • Red for danger
```

---

## Tech Stack

### **Framework**
- Flutter 3.x+ (null-safety enabled)
- Dart

### **State Management**
- `flutter_bloc` + `bloc` — Predictable state management with events/states

### **Local Storage**
- `hive` + `hive_flutter` — Fast, offline-first NoSQL database
- Type adapters for custom models

### **Charts**
- `fl_chart` — Animated pie/bar charts for expense analytics

### **Utilities**
- `intl` — Currency and date formatting
- `equatable` — Value equality for Bloc states/events

### **Linting**
- `flutter_lints` — Recommended Flutter lints
- Custom `analysis_options.yaml`

### **UI Theme**
- Primary Purple: `#7C3AED`, `#A78BFA`
- Accent Yellow: `#FCD34D`
- Background: `#FFFFFF`
- Rounded corners, soft shadows, micro-animations

---

## Bloc ↔ GetX Mapping Reference

| Bloc Pattern | GetX Equivalent |
|--------------|-----------------|
| `BlocProvider` | `Get.put(Controller())` |
| `BlocBuilder` | `Obx(() => ...)` |
| `context.read<Bloc>().add(Event)` | `Get.find<Controller>().method()` |
| Event classes | Controller methods |
| State classes | Reactive variables (`.obs`) |
| `emit(NewState)` | `update()` or `.value = ...` |

**Example:**

**Bloc:**
```dart
// Event
class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;
}

// In Bloc
on<AddTransactionEvent>((event, emit) async {
  await repository.addTransaction(event.transaction);
  emit(TransactionAddedState());
});

// UI
context.read<TransactionBloc>().add(AddTransactionEvent(transaction));
```

**GetX Equivalent:**
```dart
// Controller
class TransactionController extends GetxController {
  void addTransaction(Transaction transaction) async {
    await repository.addTransaction(transaction);
    transactions.refresh();
  }
}

// UI
Get.find<TransactionController>().addTransaction(transaction);
```

---

**Status:** Awaiting approval before proceeding to Low-Level Design (LLD).
