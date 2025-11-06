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
