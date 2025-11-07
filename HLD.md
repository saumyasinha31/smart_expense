# MyFinance — High-Level Design

> Personal finance tracker with offline-first architecture, budget tracking, expense analytics, and modern UI with drawer navigation.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                             │
│  Dashboard • Transactions • Add/Edit • Budgets • Settings   │
│  Drawer Navigation • Swipe Gestures • Pie Chart Legend      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ BlocBuilder / BlocListener
                         │ dispatch events → receive states
                         │
┌────────────────────────▼────────────────────────────────────┐
│                      Bloc Layer                             │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────┐  │
│  │ Transaction  │  │  Dashboard   │  │   Budget     │  │Theme│  │
│  │    Bloc      │  │    Bloc      │  │    Bloc      │  │Bloc │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  └─────┘  │
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
- **Dashboard** — Balance card, recent transactions, expense chart with legend
- **Transactions** — List with swipe-to-edit/delete, tap-to-edit
- **Add/Edit Transaction** — Form with validation, INR currency
- **Budgets** — Category budget limits with progress bars and alerts
- **Settings** — Dark mode toggle

**Widgets:**
- `TransactionCard` — Single transaction tile with tap/swipe support
- `CategoryBadge` — Icon + color for categories
- `BudgetProgressBar` — Visual budget consumption with alerts
- `ExpenseChart` — Pie chart with external legend (no overlapping text)

**Navigation:**
- Side drawer with proper icons (dashboard, receipt_long, account_balance_wallet, settings)
- FAB for adding transactions on Dashboard and Transactions screens

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
- `RefreshDashboard` — Reload data

**States:**
- `DashboardLoading`
- `DashboardLoaded(balance, recentTransactions, categoryData)`
- `DashboardError(String message)`

#### **BudgetBloc**
Manages category budgets and alerts.

**Events:**
- `LoadBudgets` — Fetch all budget limits
- `SetBudget(category, amount, month, year)` — Set monthly limit
- `DeleteBudget(category, month, year)` — Remove budget

**States:**
- `BudgetLoading`
- `BudgetLoaded(List<CategoryBudget>, Map<Category, double> currentSpent, Map<Category, BudgetAlertLevel> alerts)`
- `BudgetError(String message)`

#### **ThemeBloc**
Manages app theme mode.

**Events:**
- `ToggleTheme` — Switch between light and dark mode

**States:**
- `ThemeState(ThemeMode themeMode)`

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
  Future<void> setBudget(Category category, double limit, int month, int year)
  Future<void> deleteBudget(Category category, int month, int year)

  Future<double> getBalance()
  Future<Map<Category, double>> getCategoryExpenses({int? month, int? year})
  Future<List<Transaction>> getRecentTransactions({int limit = 10})
  Future<Map<Category, BudgetAlertLevel>> getBudgetAlerts(int month, int year)
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
- **CategoryBudget** (typeId: 1) — category, monthlyLimit, month, year
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
 • Pie chart with legend
```

---

### **Swipe Edit/Delete Flow**

```
User swipes transaction
     ↓
Dismissible triggers onDismissed
     ↓
Swipe right: delete (with confirm dialog)
Swipe left: edit (direct navigation)
     ↓
For delete: context.read<TransactionBloc>().add(DeleteTransaction(id))
     ↓
Bloc emits success, UI shows snackbar with undo
     ↓
Local list updates immediately to prevent animation issues
```

---

### **Theme Toggle Flow**

```
User toggles switch in Settings
     ↓
UI: context.read<ThemeBloc>().add(ToggleTheme())
     ↓
ThemeBloc emits ThemeState(newMode)
     ↓
BlocBuilder rebuilds MaterialApp with new themeMode
     ↓
App theme switches instantly
```

---

## Tech Stack

### **Framework**
- Flutter SDK >=3.0.0 <4.0.0 with Dart
- Null-safety enabled

### **State Management**
- `flutter_bloc` + `bloc` — Predictable state management with events/states

### **Local Storage**
- `hive` + `hive_flutter` — Fast, offline-first NoSQL database
- Type adapters for custom models

### **Charts**
- `fl_chart` — Animated pie charts with external legends

### **Utilities**
- `intl` — Currency and date formatting
- `equatable` — Value equality for Bloc states/events

### **UI Enhancements**
- Swipe gestures for edit/delete
- Drawer navigation with proper icons
- INR currency support
- Light/dark theme toggle

### **Linting**
- `flutter_lints` — Recommended Flutter lints
- Custom `analysis_options.yaml`

### **UI Theme**
- Primary Purple: `#7C3AED`, `#A78BFA`
- Accent Yellow: `#FCD34D`
- Background: Light `#F9FAFB`, Dark `#111827`
- Rounded corners, soft shadows, micro-animations

---

## Status: Implementation Complete

The app is fully functional with all planned features implemented and tested.
