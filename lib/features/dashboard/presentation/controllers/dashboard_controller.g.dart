// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardControllerHash() =>
    r'a5112deb9accae0863684a4f90ec5e78d805132f';

/// One AsyncValue for the whole screen, because the repository loads
/// everything in one go. Three states to handle, not twelve.
///
/// Copied from [DashboardController].
@ProviderFor(DashboardController)
final dashboardControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      DashboardController,
      DashboardStats
    >.internal(
      DashboardController.new,
      name: r'dashboardControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DashboardController = AutoDisposeAsyncNotifier<DashboardStats>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
