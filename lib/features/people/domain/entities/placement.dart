/// A job someone was given. The employed toggle creates one of these
/// with only a date; position and organisation are optional because
/// the confirmation sheet must be tappable without typing.
class Placement {
  final String id;
  final String personId;
  final String? positionTitle;
  final String? organisation;
  final DateTime startedOn;
  final DateTime? endedOn;
  final bool isCurrent;

  const Placement({
    required this.id,
    required this.personId,
    required this.startedOn,
    required this.isCurrent,
    this.positionTitle,
    this.organisation,
    this.endedOn,
  });

  String? get description {
    final parts = [
      positionTitle,
      organisation,
    ].where((p) => p != null && p.trim().isNotEmpty).cast<String>();
    return parts.isEmpty ? null : parts.join(' · ');
  }
}
