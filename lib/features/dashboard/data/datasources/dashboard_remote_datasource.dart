import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:cv_bank/core/error/supabase_error_mapper.dart';
import '../models/dashboard_stats_model.dart';

abstract interface class DashboardRemoteDataSource {
  Future<DashboardTotalsModel> fetchTotals();
  Future<List<CategoryStatModel>> fetchCategoryStats();
  Future<List<RecentPlacementModel>> fetchRecentPlacements({int limit = 3});
  Future<int> fetchPlacedThisMonth();
}

class DashboardSupabaseDataSource implements DashboardRemoteDataSource {
  final SupabaseClient client;
  const DashboardSupabaseDataSource(this.client);

  @override
  Future<DashboardTotalsModel> fetchTotals() => mapSupabaseErrors(() async {
    final row = await client.from('v_dashboard_totals').select().maybeSingle();

    // maybeSingle rather than single: the view aggregates, so it
    // should always return one row, but a null here would throw
    // rather than showing an empty dashboard.
    return row == null
        ? const DashboardTotalsModel(
            totalPeople: 0,
            employed: 0,
            unemployed: 0,
            newThisMonth: 0,
          )
        : DashboardTotalsModel.fromJson(row);
  });

  @override
  Future<List<CategoryStatModel>> fetchCategoryStats() =>
      mapSupabaseErrors(() async {
        final rows = await client
            .from('v_category_breakdown')
            .select()
            .order('sort_order');

        return rows.map((r) => CategoryStatModel.fromJson(r)).toList();
      });

  @override
  Future<List<RecentPlacementModel>> fetchRecentPlacements({int limit = 3}) =>
      mapSupabaseErrors(() async {
        final rows = await client
            .from('v_recent_placements')
            .select()
            .limit(limit);

        return rows.map((r) => RecentPlacementModel.fromJson(r)).toList();
      });

  @override
  Future<int> fetchPlacedThisMonth() => mapSupabaseErrors(() async {
    final row = await client
        .from('v_placement_totals')
        .select('placed_this_month')
        .maybeSingle();

    return (row?['placed_this_month'] as num?)?.toInt() ?? 0;
  });
}
