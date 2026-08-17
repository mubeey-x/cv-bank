import 'package:cv_bank/features/categories/data/provider/category_providers.dart';
import 'package:cv_bank/features/categories/domain/usecases/manage_categories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/usecase/usecase.dart';
import 'package:cv_bank/features/categories/domain/entities/category.dart';
import 'package:cv_bank/features/dashboard/presentation/controllers/dashboard_controller.dart';

part 'category_controller.g.dart';

/// Whether the list is showing categories the user has turned off.
@riverpod
class ShowInactive extends _$ShowInactive {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

/// The categories tab. Rebuilds automatically when the inactive
/// toggle flips, because build() watches it.
@riverpod
class CategoryListController extends _$CategoryListController {
  @override
  Future<List<Category>> build() async {
    final includeInactive = ref.watch(showInactiveProvider);
    final result = await ref.watch(getCategoriesProvider).call(includeInactive);
    return result.fold((f) => throw f, (list) => list);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final includeInactive = ref.read(showInactiveProvider);
      final result = await ref
          .read(getCategoriesProvider)
          .call(includeInactive);
      return result.fold((f) => throw f, (list) => list);
    });
  }
}

/// Just the names, for the intake chips. Separate provider so the
/// cheap query is not invalidated every time a count changes.
@riverpod
Future<List<Category>> activeCategoryNames(Ref ref) async {
  final result = await ref
      .watch(getActiveCategoryNamesProvider)
      .call(const NoParams());
  return result.fold((f) => throw f, (list) => list);
}

/// Every write goes through here. Each method returns a Failure or
/// null, so the sheet can show an inline error instead of the screen
/// having to interpret a state change.
@riverpod
class CategoryActions extends _$CategoryActions {
  @override
  bool build() => false; // isBusy

  Future<Failure?> create(String name) =>
      _run(() => ref.read(createCategoryProvider).call(name));

  Future<Failure?> rename({required String id, required String name}) => _run(
    () => ref
        .read(renameCategoryProvider)
        .call(RenameCategoryParams(id: id, name: name)),
  );

  Future<Failure?> setActive({required String id, required bool isActive}) =>
      _run(
        () => ref
            .read(setCategoryActiveProvider)
            .call(SetCategoryActiveParams(id: id, isActive: isActive)),
      );

  Future<Failure?> delete(Category category) =>
      _run(() => ref.read(deleteCategoryProvider).call(category));

  Future<Failure?> reorder(List<String> orderedIds) =>
      _run(() => ref.read(reorderCategoriesProvider).call(orderedIds));

  Future<Failure?> _run<T>(Future<Either<Failure, T>> Function() action) async {
    state = true;
    final result = await action();
    state = false;

    return result.fold<Failure?>((failure) => failure, (_) {
      ref.invalidate(categoryListControllerProvider);
      ref.invalidate(activeCategoryNamesProvider);
      ref.invalidate(dashboardControllerProvider);
      return null;
    });
  }
}
