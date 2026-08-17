// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeCategoryNamesHash() =>
    r'd2ab2ece27a05d9a0a47004eea19274193b6b97f';

/// Just the names, for the intake chips. Separate provider so the
/// cheap query is not invalidated every time a count changes.
///
/// Copied from [activeCategoryNames].
@ProviderFor(activeCategoryNames)
final activeCategoryNamesProvider =
    AutoDisposeFutureProvider<List<Category>>.internal(
      activeCategoryNames,
      name: r'activeCategoryNamesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeCategoryNamesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveCategoryNamesRef = AutoDisposeFutureProviderRef<List<Category>>;
String _$showInactiveHash() => r'939eea7a5faa753da048b6fe9e2079a6d1ec54cc';

/// Whether the list is showing categories the user has turned off.
///
/// Copied from [ShowInactive].
@ProviderFor(ShowInactive)
final showInactiveProvider =
    AutoDisposeNotifierProvider<ShowInactive, bool>.internal(
      ShowInactive.new,
      name: r'showInactiveProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$showInactiveHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShowInactive = AutoDisposeNotifier<bool>;
String _$categoryListControllerHash() =>
    r'9d6cf9dff91bd1b5f36cb1e2b52b6c0143d8f356';

/// The categories tab. Rebuilds automatically when the inactive
/// toggle flips, because build() watches it.
///
/// Copied from [CategoryListController].
@ProviderFor(CategoryListController)
final categoryListControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      CategoryListController,
      List<Category>
    >.internal(
      CategoryListController.new,
      name: r'categoryListControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoryListControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CategoryListController = AutoDisposeAsyncNotifier<List<Category>>;
String _$categoryActionsHash() => r'f46459bc3e59bebd6a853a9a25f4a97e13da4330';

/// Every write goes through here. Each method returns a Failure or
/// null, so the sheet can show an inline error instead of the screen
/// having to interpret a state change.
///
/// Copied from [CategoryActions].
@ProviderFor(CategoryActions)
final categoryActionsProvider =
    AutoDisposeNotifierProvider<CategoryActions, bool>.internal(
      CategoryActions.new,
      name: r'categoryActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoryActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CategoryActions = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
