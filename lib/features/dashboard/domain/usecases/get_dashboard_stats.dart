import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/usecase/usecase.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStats implements UseCase<DashboardStats, NoParams> {
  final DashboardRepository repository;
  const GetDashboardStats(this.repository);

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams params) =>
      repository.getStats();
}
