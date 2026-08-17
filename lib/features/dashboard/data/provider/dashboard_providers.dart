import 'package:cv_bank/core/provider/supabase_provider.dart';
import 'package:cv_bank/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cv_bank/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:cv_bank/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:cv_bank/features/dashboard/domain/usecases/get_dashboard_stats.dart';

part 'dashboard_providers.g.dart';

// ============================================================================
// DATA LAYER
// ============================================================================

@Riverpod(keepAlive: true)
DashboardRemoteDataSource dashboardRemoteDataSource(Ref ref) {
  return DashboardSupabaseDataSource(ref.watch(supabaseProvider));
}

@Riverpod(keepAlive: true)
DashboardRepository dashboardRepository(Ref ref) {
  return DashboardRepositoryImpl(
    remote: ref.watch(dashboardRemoteDataSourceProvider),
  );
}

// ============================================================================
// DOMAIN LAYER (Use Cases)
// ============================================================================

@riverpod
GetDashboardStats getDashboardStats(Ref ref) =>
    GetDashboardStats(ref.watch(dashboardRepositoryProvider));
