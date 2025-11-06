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
