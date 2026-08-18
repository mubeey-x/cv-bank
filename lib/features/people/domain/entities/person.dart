import 'package:cv_bank/core/utils/phone_normalizer.dart';
import 'package:cv_bank/features/people/domain/entities/placement.dart';

enum QualificationLevel {
  ssce,
  nce,
  nd,
  hnd,
  bsc,
  pgd,
  msc,
  phd,
  other;

  String get label => switch (this) {
    QualificationLevel.ssce => 'SSCE',
    QualificationLevel.nce => 'NCE',
    QualificationLevel.nd => 'ND',
    QualificationLevel.hnd => 'HND',
    QualificationLevel.bsc => 'BSc',
    QualificationLevel.pgd => 'PGD',
    QualificationLevel.msc => 'MSc',
    QualificationLevel.phd => 'PhD',
    QualificationLevel.other => 'Other',
  };
}

enum EmploymentStatus {
  unemployed,
  employed;

  String get label =>
      this == EmploymentStatus.employed ? 'Employed' : 'Waiting';
}

enum RelationshipTier {
  inner,
  referred,
  general;

  String get label => switch (this) {
    RelationshipTier.inner => 'Inner circle',
    RelationshipTier.referred => 'Referred',
    RelationshipTier.general => 'General',
  };
}

enum IntakeChannel {
  walkIn,
  whatsapp,
  email,
  event,
  referral,
  other;

  String get label => switch (this) {
    IntakeChannel.walkIn => 'Walk-in',
    IntakeChannel.whatsapp => 'WhatsApp',
    IntakeChannel.email => 'Email',
    IntakeChannel.event => 'Event',
    IntakeChannel.referral => 'Referral',
    IntakeChannel.other => 'Other',
  };
}

/// Someone in the pool.
///
/// Only [fullName], [phone] and [categoryId] are captured at intake.
/// Everything else is filled in later from the edit screen, or never,
/// which is why almost all of it is nullable.
class Person {
  final String id;
  final String fullName;
  final String phone;

  final String? categoryId;
  final String? categoryName;

  final EmploymentStatus status;
  final RelationshipTier relationship;
  final DateTime receivedOn;

  // Optional detail
  final String? email;
  final QualificationLevel? qualification;
  final String? courseOfStudy;
  final String? institution;
  final int? yearsExperience;
  final String? currentOccupation;
  final String? referrerName;
  final IntakeChannel? channel;
  final String? notes;

  /// The person's current placement, when they have one. Null while
  /// waiting, and null on list queries that skip the join.
  final Placement? currentPlacement;

  /// How many files are attached. Cheaper than loading them for a
  /// list, and enough to show a paperclip on the card.
  final int documentCount;

  const Person({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.status,
    required this.relationship,
    required this.receivedOn,
    this.categoryId,
    this.categoryName,
    this.email,
    this.qualification,
    this.courseOfStudy,
    this.institution,
    this.yearsExperience,
    this.currentOccupation,
    this.referrerName,
    this.channel,
    this.notes,
    this.currentPlacement,
    this.documentCount = 0,
  });

  bool get isEmployed => status == EmploymentStatus.employed;

  bool get hasDocuments => documentCount > 0;

  String get displayPhone => PhoneNormalizer.display(phone);

  /// The second line on a person card: category and phone.
  String get subtitle {
    final parts = [
      categoryName,
      displayPhone,
    ].where((p) => p != null && p.isNotEmpty).cast<String>();
    return parts.join(' · ');
  }

  /// Everything past the three intake fields. Drives the "incomplete"
  /// hint on the card, so a record captured in a hurry can be
  /// finished later without anyone having to remember which.
  bool get hasDetail =>
      qualification != null ||
      (courseOfStudy?.isNotEmpty ?? false) ||
      (currentOccupation?.isNotEmpty ?? false) ||
      (referrerName?.isNotEmpty ?? false);

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Person && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
