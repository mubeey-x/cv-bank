import 'package:cv_bank/core/utils/date_format.dart';
import '../../domain/entities/dashboard_stats.dart';

class DashboardTotalsModel extends DashboardTotals {
  const DashboardTotalsModel({
    required super.totalPeople,
    required super.employed,
    required super.unemployed,
    required super.newThisMonth,
  });

  /// From v_dashboard_totals. Postgres count() returns bigint, which
  /// arrives as int, but a brand new account with no rows can send
  /// nulls, so every field falls back to zero.
  factory DashboardTotalsModel.fromJson(Map<String, dynamic> json) {
    return DashboardTotalsModel(
      totalPeople: (json['total_people'] as num?)?.toInt() ?? 0,
      employed: (json['employed'] as num?)?.toInt() ?? 0,
      unemployed: (json['unemployed'] as num?)?.toInt() ?? 0,
      newThisMonth: (json['new_this_month'] as num?)?.toInt() ?? 0,
    );
  }
}

class CategoryStatModel extends CategoryStat {
  const CategoryStatModel({
    required super.id,
    required super.name,
    required super.pool,
    required super.employed,
  });

  /// From v_category_breakdown.
  factory CategoryStatModel.fromJson(Map<String, dynamic> json) {
    return CategoryStatModel(
      id: json['id'] as String,
      name: json['name'] as String,
      pool: (json['pool'] as num?)?.toInt() ?? 0,
      employed: (json['employed'] as num?)?.toInt() ?? 0,
    );
  }
}

class RecentPlacementModel extends RecentPlacement {
  const RecentPlacementModel({
    required super.id,
    required super.personId,
    required super.personName,
    required super.startedOn,
    super.positionTitle,
    super.organisation,
  });

  /// From v_recent_placements.
  factory RecentPlacementModel.fromJson(Map<String, dynamic> json) {
    return RecentPlacementModel(
      id: json['id'] as String,
      personId: json['person_id'] as String,
      personName: json['full_name'] as String,
      positionTitle: json['position_title'] as String?,
      organisation: json['organisation'] as String?,
      startedOn: AppDate.parse(json['started_on'] as String),
    );
  }
}
