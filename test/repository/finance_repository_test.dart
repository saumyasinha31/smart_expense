import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../lib/models/transaction.dart';
import '../../lib/models/category.dart';
import '../../lib/models/transaction_type.dart';
import '../../lib/storage/hive_storage.dart';
import '../../lib/repository/finance_repository.dart';

class MockHiveStorage extends Mock implements HiveStorage {}

void main() {
  late MockHiveStorage mockStorage;
  late FinanceRepository repository;

  setUp(() {
    mockStorage = MockHiveStorage();
    repository = FinanceRepository(mockStorage);
  });

  group('FinanceRepository', () {
    test('getBalance returns correct balance', () async {
      final transactions = [
        Transaction.create(
          amount: 100,
          category: Category.food,
          type: TransactionType.income,
          date: DateTime.now(),
        ),
        Transaction.create(
          amount: 50,
          category: Category.food,
          type: TransactionType.expense,
          date: DateTime.now(),
        ),
      ];

      when(() => mockStorage.getAllTransactions()).thenReturn(transactions);

      final balance = await repository.getBalance();

      expect(balance, 50);
    });

    test('getCategoryExpenses returns correct expenses', () async {
      final transactions = [
        Transaction.create(
          amount: 25,
          category: Category.food,
          type: TransactionType.expense,
          date: DateTime.now(),
        ),
        Transaction.create(
          amount: 30,
          category: Category.travel,
          type: TransactionType.expense,
          date: DateTime.now(),
        ),
      ];

      when(() => mockStorage.getAllTransactions()).thenReturn(transactions);

      final expenses = await repository.getCategoryExpenses();

      expect(expenses[Category.food], 25);
      expect(expenses[Category.travel], 30);
    });
  });
}
