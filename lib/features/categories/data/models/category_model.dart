
import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.sortOrder,
    required super.isActive,
    super.peopleCount,
    super.employedCount,
  });

  /// From the categories table. No counts.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// From v_category_breakdown. Counts included.
  factory CategoryModel.fromView(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      peopleCount: (json['pool'] as num?)?.toInt() ?? 0,
      employedCount: (json['employed'] as num?)?.toInt() ?? 0,
    );
  }
}
