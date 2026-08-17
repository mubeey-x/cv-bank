/// A grouping the account holder created. The only thing they
/// configure in the MVP.
class Category {
  final String id;
  final String name;
  final int sortOrder;
  final bool isActive;

  /// Counts come from a view joined onto people. They are null when
  /// the category was loaded without them, which happens on the
  /// intake chips where only the name is needed.
  final int? peopleCount;
  final int? employedCount;

  const Category({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.isActive,
    this.peopleCount,
    this.employedCount,
  });

  int get pool => peopleCount ?? 0;
  int get employed => employedCount ?? 0;
  int get waiting => pool - employed;

  double get employedRatio => pool == 0 ? 0 : employed / pool;

  /// Deactivating is safe; deleting is not. The category screen uses
  /// this to decide which action to offer.
  bool get hasPeople => pool > 0;

  Category copyWith({String? name, int? sortOrder, bool? isActive}) {
    return Category(
      id: id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      peopleCount: peopleCount,
      employedCount: employedCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Category && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
