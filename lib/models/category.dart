/// Category enum for transactions
enum Category {
  food,
  travel,
  bills,
  shopping,
  entertainment,
  others,
}

/// Extension for Category display properties
extension CategoryExtension on Category {
  /// Human-readable name
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

  /// Emoji icon for the category
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

  /// Color hex for the category
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
