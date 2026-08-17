import 'package:cv_bank/features/dashboard/data/provider/dashboard_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/usecase/usecase.dart';
import 'package:cv_bank/features/dashboard/domain/entities/dashboard_stats.dart';

part 'dashboard_controller.g.dart';

/// One AsyncValue for the whole screen, because the repository loads
/// everything in one go. Three states to handle, not twelve.
@riverpod
class DashboardController extends _$DashboardController {
  @override
  Future<DashboardStats> build() async {
    final result = await ref
        .watch(getDashboardStatsProvider)
        .call(const NoParams());

    // Throwing on the left turns the Failure into AsyncError, which
    // the screen reads back with .when(). The Failure survives as
    // the error object, so the UI still gets its message.
    return result.fold((failure) => throw failure, (stats) => stats);
  }

  /// Pull to refresh. Keeps the old data on screen while reloading,
  /// so the dashboard does not flash back to a spinner.
  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(getDashboardStatsProvider)
          .call(const NoParams());
      return result.fold((failure) => throw failure, (stats) => stats);
    });
  }
}

/// Anything that changes the numbers should call this: adding a
/// person, marking someone employed, editing a category.
extension DashboardInvalidation on Ref {
  void invalidateDashboard() => invalidate(dashboardControllerProvider);
}

/// Helper for the screen: pulls the Failure out of an AsyncError,
/// falling back to a generic one if something else was thrown.
Failure failureFrom(Object error) =>
    error is Failure ? error : const UnknownFailure();
