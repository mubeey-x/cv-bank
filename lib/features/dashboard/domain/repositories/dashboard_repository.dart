import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/failures.dart';
import '../entities/dashboard_stats.dart';

abstract interface class DashboardRepository {
  /// One call, several views underneath.
  Future<Either<Failure, DashboardStats>> getStats();
}
