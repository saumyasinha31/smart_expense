import 'package:flutter/material.dart';
import '../../models/category.dart';

class CategoryBadge extends StatelessWidget {
  final Category category;
  final double? size;

  const CategoryBadge({Key? key, required this.category, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(int.parse(category.colorHex.replaceFirst('#', '0xff'))).withOpacity(0.1),
        border: Border.all(
          color: Color(int.parse(category.colorHex.replaceFirst('#', '0xff'))),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.icon, style: TextStyle(fontSize: size ?? 16)),
          const SizedBox(width: 4),
          Text(
            category.displayName,
            style: TextStyle(
              fontSize: size != null ? size! * 0.75 : 12,
              color: Color(int.parse(category.colorHex.replaceFirst('#', '0xff'))),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
