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

[Add screenshots here]

## Contributing

1. Follow Flutter lints and formatting
2. Write tests for new features
3. Use meaningful commit messages
4. Maintain clean, modular code structure

## License

This project is for educational purposes.
