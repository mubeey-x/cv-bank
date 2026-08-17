class DashboardTotals {
  final int totalPeople;
  final int employed;
  final int unemployed;
  final int newThisMonth;

  const DashboardTotals({
    required this.totalPeople,
    required this.employed,
    required this.unemployed,
    required this.newThisMonth,
  });

  static const empty = DashboardTotals(
    totalPeople: 0,
    employed: 0,
    unemployed: 0,
    newThisMonth: 0,
  );

  /// Drives the split bar. 0.0 when the pool is empty, so the widget
  /// never has to guard against dividing by zero.
  double get employedRatio => totalPeople == 0 ? 0 : employed / totalPeople;

  /// The dashboard replaces itself with a first-run prompt when true.
  bool get isEmpty => totalPeople == 0;
}

/// One bar in the "By category" card.
class CategoryStat {
  final String id;
  final String name;
  final int pool;
  final int employed;

  const CategoryStat({
    required this.id,
    required this.name,
    required this.pool,
    required this.employed,
  });

  double get ratio => pool == 0 ? 0 : employed / pool;
}

/// One row in "Recent placements".
class RecentPlacement {
  final String id;
  final String personId;
  final String personName;
  final String? positionTitle;
  final String? organisation;
  final DateTime startedOn;

  const RecentPlacement({
    required this.id,
    required this.personId,
    required this.personName,
    required this.startedOn,
    this.positionTitle,
    this.organisation,
  });

  /// The secondary line under the name. Null when the user confirmed
  /// the placement without typing a role, which is the common case.
  String? get subtitle {
    final parts = [
      positionTitle,
      organisation,
    ].where((p) => p != null && p.trim().isNotEmpty).cast<String>();
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

/// Everything one dashboard load returns.
class DashboardStats {
  final DashboardTotals totals;
  final List<CategoryStat> categories;
  final List<RecentPlacement> recentPlacements;
  final int placedThisMonth;

  const DashboardStats({
    required this.totals,
    required this.categories,
    required this.recentPlacements,
    required this.placedThisMonth,
  });

  static const empty = DashboardStats(
    totals: DashboardTotals.empty,
    categories: [],
    recentPlacements: [],
    placedThisMonth: 0,
  );

  /// Categories with nobody in them are noise on a bar chart.
  List<CategoryStat> get populatedCategories =>
      categories.where((c) => c.pool > 0).toList();
}
