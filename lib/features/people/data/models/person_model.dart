import 'package:cv_bank/core/utils/date_format.dart';
import 'package:cv_bank/features/people/data/models/person_document_model.dart';
import '../../domain/entities/person.dart';


// =====================================================================
// Enum mapping
//
// Dart enum names and Postgres enum labels differ in one place
// (walkIn vs walk_in), so the conversion lives here rather than being
// guessed at each call site.
// =====================================================================

T? _enumFrom<T extends Enum>(List<T> values, String? raw) {
  if (raw == null) return null;
  for (final v in values) {
    if (v.name == raw) return v;
  }
  return null;
}

String? channelToDb(IntakeChannel? c) => switch (c) {
  null => null,
  IntakeChannel.walkIn => 'walk_in',
  _ => c.name,
};

IntakeChannel? channelFromDb(String? raw) => switch (raw) {
  null => null,
  'walk_in' => IntakeChannel.walkIn,
  _ => _enumFrom(IntakeChannel.values, raw),
};

// =====================================================================
// Person
// =====================================================================

class PersonModel extends Person {
  const PersonModel({
    required super.id,
    required super.fullName,
    required super.phone,
    required super.status,
    required super.relationship,
    required super.receivedOn,
    super.categoryId,
    super.categoryName,
    super.email,
    super.qualification,
    super.courseOfStudy,
    super.institution,
    super.yearsExperience,
    super.currentOccupation,
    super.referrerName,
    super.channel,
    super.notes,
    super.currentPlacement,
    super.documentCount,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    // Nested selects arrive as a map for a to-one relation and a list
    // for a to-many, so both shapes are handled.
    final categoryJson = json['categories'] as Map<String, dynamic>?;

    final placementsRaw = json['placements'];
    final placements = placementsRaw is List
        ? placementsRaw.cast<Map<String, dynamic>>()
        : const <Map<String, dynamic>>[];

    // count() in a nested select comes back as [{count: n}].
    final docsRaw = json['documents'];
    final docCount = docsRaw is List && docsRaw.isNotEmpty
        ? ((docsRaw.first as Map<String, dynamic>)['count'] as num?)?.toInt() ??
              0
        : 0;

    return PersonModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      categoryId: json['category_id'] as String?,
      categoryName: categoryJson?['name'] as String?,
      status:
          _enumFrom(EmploymentStatus.values, json['status'] as String?) ??
          EmploymentStatus.unemployed,
      relationship:
          _enumFrom(RelationshipTier.values, json['relationship'] as String?) ??
          RelationshipTier.general,
      receivedOn: AppDate.parse(json['received_on'] as String),
      email: json['email'] as String?,
      qualification: _enumFrom(
        QualificationLevel.values,
        json['qualification'] as String?,
      ),
      courseOfStudy: json['course_of_study'] as String?,
      institution: json['institution'] as String?,
      yearsExperience: (json['years_experience'] as num?)?.toInt(),
      currentOccupation: json['current_occupation'] as String?,
      referrerName: json['referrer_name'] as String?,
      channel: channelFromDb(json['channel'] as String?),
      notes: json['notes'] as String?,
      currentPlacement: placements.isEmpty
          ? null
          : PlacementModel.fromJson(placements.first),
      documentCount: docCount,
    );
  }

  /// Local sqflite cache. Flat, no joins, so the shape differs from
  /// the server response.
  factory PersonModel.fromCache(Map<String, dynamic> row) {
    return PersonModel(
      id: row['id'] as String,
      fullName: row['full_name'] as String,
      phone: row['phone'] as String,
      categoryId: row['category_id'] as String?,
      categoryName: row['category_name'] as String?,
      status:
          _enumFrom(EmploymentStatus.values, row['status'] as String?) ??
          EmploymentStatus.unemployed,
      relationship:
          _enumFrom(RelationshipTier.values, row['relationship'] as String?) ??
          RelationshipTier.general,
      receivedOn: DateTime.fromMillisecondsSinceEpoch(
        row['received_on'] as int,
      ),
      documentCount: (row['document_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toCache() => {
    'id': id,
    'full_name': fullName,
    'phone': phone,
    'category_id': categoryId,
    'category_name': categoryName,
    'status': status.name,
    'relationship': relationship.name,
    'received_on': receivedOn.millisecondsSinceEpoch,
    'document_count': documentCount,
    'cached_at': DateTime.now().millisecondsSinceEpoch,
  };
}



