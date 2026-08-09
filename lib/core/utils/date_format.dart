import 'package:intl/intl.dart';

/// Formatting for display, and conversion for Supabase.

class AppDate {
  const AppDate._();

  static final _day = DateFormat('d MMM yyyy'); // 12 Aug 2026
  static final _dayShort = DateFormat('d MMM'); // 12 Aug
  static final _dayTime = DateFormat('d MMM, h:mm a');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _iso = DateFormat('yyyy-MM-dd');

  // ---- Display ----

  static String full(DateTime d) => _day.format(d.toLocal());

  static String short(DateTime d) => _dayShort.format(d.toLocal());

  static String withTime(DateTime d) => _dayTime.format(d.toLocal());

  static String monthYear(DateTime d) => _monthYear.format(d.toLocal());

  /// 'Today', 'Yesterday', '3 days ago', then falls back to a date.
  /// Used on the recent placements list and the people list.
  static String relative(DateTime d) {
    final local = d.toLocal();
    final today = _midnight(DateTime.now());
    final then = _midnight(local);
    final days = today.difference(then).inDays;

    return switch (days) {
      0 => 'Today',
      1 => 'Yesterday',
      < 7 && > 1 => '$days days ago',
      < 14 => 'Last week',
      < 31 => '${(days / 7).floor()} weeks ago',
      _ => full(local),
    };
  }

  /// '2 years 3 months' — for how long someone has held a placement.
  static String duration(DateTime from, [DateTime? to]) {
    final end = (to ?? DateTime.now()).toLocal();
    final start = from.toLocal();

    var months = (end.year - start.year) * 12 + end.month - start.month;
    if (end.day < start.day) months--;
    if (months < 1) return 'Less than a month';

    final years = months ~/ 12;
    final rem = months % 12;

    final parts = <String>[
      if (years > 0) '$years year${years == 1 ? '' : 's'}',
      if (rem > 0) '$rem month${rem == 1 ? '' : 's'}',
    ];
    return parts.join(' ');
  }

  // ---- Supabase ----

  /// For a `date` column. Send the local calendar day, not UTC, or a
  /// record added at 1am WAT lands on the previous day.
  static String toIsoDate(DateTime d) => _iso.format(d.toLocal());

  /// Parses either a 'yyyy-MM-dd' date or a full timestamp.
  static DateTime parse(String raw) => DateTime.parse(raw).toLocal();

  static DateTime? tryParse(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw)?.toLocal();

  /// For a `timestamptz` column.
  static String toIsoTimestamp(DateTime d) => d.toUtc().toIso8601String();

  // ---- Ranges, for the dashboard ----

  static DateTime startOfMonth([DateTime? from]) {
    final d = (from ?? DateTime.now()).toLocal();
    return DateTime(d.year, d.month);
  }

  static DateTime startOfYear([DateTime? from]) {
    final d = (from ?? DateTime.now()).toLocal();
    return DateTime(d.year);
  }

  static DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);
}
