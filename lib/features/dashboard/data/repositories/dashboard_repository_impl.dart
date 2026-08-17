import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/error/guard.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remote;
  const DashboardRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, DashboardStats>> getStats() => guard(() async {
    // All four at once. Sequentially this would be four round
    // trips stacked end to end; in parallel it costs one.
    final results = await Future.wait([
      remote.fetchTotals(),
      remote.fetchCategoryStats(),
      remote.fetchRecentPlacements(),
      remote.fetchPlacedThisMonth(),
    ]);

    return DashboardStats(
      totals: results[0] as DashboardTotals,
      categories: results[1] as List<CategoryStat>,
      recentPlacements: results[2] as List<RecentPlacement>,
      placedThisMonth: results[3] as int,
    );
  });
}
