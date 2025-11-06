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
