class Account {
  final String id;
  final String email;
  final String name;
  final bool isEmailConfirmed;
  final DateTime createdAt;

  const Account({
    required this.id,
    required this.email,
    required this.name,
    required this.isEmailConfirmed,
    required this.createdAt,
  });

  /// For the avatar when there is no photo.
  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return email.isEmpty ? '?' : email[0].toUpperCase();
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Account && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
