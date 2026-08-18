import 'person.dart';

/// A person about to be saved. Separate from [Person] because there
/// is no id, no status and no received date yet, and reusing one
/// class with a nullable id is where the confusion starts.
class NewPerson {
  final String fullName;
  final String phone;
  final String? categoryId;

  /// Optional even here, so the quick-add path can pass nothing.
  final String? email;
  final QualificationLevel? qualification;
  final String? courseOfStudy;
  final String? institution;
  final int? yearsExperience;
  final String? currentOccupation;
  final String? referrerName;
  final IntakeChannel? channel;
  final RelationshipTier relationship;
  final String? notes;

  const NewPerson({
    required this.fullName,
    required this.phone,
    this.categoryId,
    this.email,
    this.qualification,
    this.courseOfStudy,
    this.institution,
    this.yearsExperience,
    this.currentOccupation,
    this.referrerName,
    this.channel,
    this.relationship = RelationshipTier.general,
    this.notes,
  });
}

/// Fields the edit screen can change. Everything null means "leave
/// as it is", so a partial update does not wipe untouched columns.
class PersonUpdate {
  final String? fullName;
  final String? phone;
  final String? categoryId;
  final String? email;
  final QualificationLevel? qualification;
  final String? courseOfStudy;
  final String? institution;
  final int? yearsExperience;
  final String? currentOccupation;
  final String? referrerName;
  final IntakeChannel? channel;
  final RelationshipTier? relationship;
  final String? notes;

  const PersonUpdate({
    this.fullName,
    this.phone,
    this.categoryId,
    this.email,
    this.qualification,
    this.courseOfStudy,
    this.institution,
    this.yearsExperience,
    this.currentOccupation,
    this.referrerName,
    this.channel,
    this.relationship,
    this.notes,
  });
}
