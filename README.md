# MyFinance - Personal Finance & Expense Tracker

A cross-platform Flutter app for tracking personal expenses and budgets with offline-first architecture.

## Features

- **Dashboard**: View current balance, recent transactions, and expense analytics with pie charts
- **Transactions**: Add, edit, delete transactions with categories (Food, Travel, Bills, etc.)
- **Budgets**: Set monthly budgets per category with visual progress bars and alerts
- **Offline Storage**: Local persistence using Hive NoSQL database
- **Responsive UI**: Clean, intuitive design with light/dark theme support
- **State Management**: BLoC pattern for predictable state management

## Tech Stack

- **Framework**: Flutter 3.x+ with Dart
- **State Management**: flutter_bloc + bloc
- **Local Storage**: Hive + hive_flutter
- **Charts**: fl_chart for expense visualization
- **Utilities**: intl for formatting, equatable for state comparison

## Architecture

```
lib/
├── models/          # Data models with Hive adapters
├── storage/         # Hive storage layer
├── repository/      # Business logic abstraction
├── bloc/            # State management (Transaction, Dashboard, Budget)
├── ui/              # Screens and reusable widgets
│   ├── screens/     # Main app screens
│   ├── widgets/     # Reusable UI components
│   └── theme.dart   # App theming
└── utils/           # Validators, formatters, constants
```

## Getting Started

### Prerequisites

- Flutter 3.x+
- Dart SDK

### Installation

1. Clone the repository:
```bash
git clone https://github.com/saumyasinha31/smart_expense.git
cd finance_assignment
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Production

```bash
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
```

## Testing

Run tests:
```bash
flutter test
```

## Project Structure

- **Models**: Transaction, CategoryBudget, Settings with Hive serialization
- **Storage**: HiveStorage singleton for CRUD operations
- **Repository**: FinanceRepository provides data access with computed properties
- **BLoC**: Separate blocs for transaction management, dashboard metrics, and budget tracking
- **UI**: Modular screens and widgets with consistent theming

## Screenshots

### 📱 App Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/7ecf6053-e408-4f77-a60e-b01bf6ad0830" width="120">
  <img src="https://github.com/user-attachments/assets/2664dc09-36f2-4d50-81f6-8792d230df3f" width="120">
  <img src="https://github.com/user-attachments/assets/3652f27d-afd2-4553-bdd8-7bc3a21a65ba" width="120">
  <img src="https://github.com/user-attachments/assets/a67620e2-c4b4-4036-8899-e57e85ae8deb" width="120">
  <img src="https://github.com/user-attachments/assets/d75f6a59-6d91-41a1-a5fe-838f532dbcd5" width="120">
  <img src="https://github.com/user-attachments/assets/5805c45c-7484-4ca1-bedb-704cf62b4950" width="120">
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/d24b94be-d2f8-4674-8b89-c027e47e2239" width="120">
  <img src="https://github.com/user-attachments/assets/ca37b454-1a10-4f55-b723-d48db734e0d7" width="120">

</p>

