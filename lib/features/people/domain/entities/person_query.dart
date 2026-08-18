import 'package:cv_bank/features/people/domain/entities/person.dart';

/// One object for every filter on the people list, so adding a filter
/// later does not change the repository signature again.
class PersonQuery {
  final String? search;
  final String? categoryId;
  final EmploymentStatus? status;
  final RelationshipTier? relationship;
  final QualificationLevel? qualification;
  final int limit;
  final int offset;

  const PersonQuery({
    this.search,
    this.categoryId,
    this.status,
    this.relationship,
    this.qualification,
    this.limit = 30,
    this.offset = 0,
  });

  PersonQuery copyWith({
    String? search,
    String? categoryId,
    EmploymentStatus? status,
    RelationshipTier? relationship,
    QualificationLevel? qualification,
    int? limit,
    int? offset,
    bool clearSearch = false,
    bool clearCategory = false,
    bool clearStatus = false,
    bool clearRelationship = false,
    bool clearQualification = false,
  }) {
    return PersonQuery(
      search: clearSearch ? null : (search ?? this.search),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      status: clearStatus ? null : (status ?? this.status),
      relationship: clearRelationship
          ? null
          : (relationship ?? this.relationship),
      qualification: clearQualification
          ? null
          : (qualification ?? this.qualification),
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  PersonQuery nextPage() => copyWith(offset: offset + limit);

  /// Drives the "clear filters" button and the filter-count badge.
  int get activeFilterCount => [
    categoryId,
    status,
    relationship,
    qualification,
  ].where((f) => f != null).length;

  bool get hasFilters => activeFilterCount > 0;
}
