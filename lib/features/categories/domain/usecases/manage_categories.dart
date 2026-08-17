import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/usecase/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategories implements UseCase<List<Category>, bool> {
  final CategoryRepository repository;
  const GetCategories(this.repository);

  /// Params is includeInactive.
  @override
  Future<Either<Failure, List<Category>>> call(bool includeInactive) =>
      repository.getCategories(includeInactive: includeInactive);
}

class GetActiveCategoryNames implements UseCase<List<Category>, NoParams> {
  final CategoryRepository repository;
  const GetActiveCategoryNames(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) =>
      repository.getActiveNames();
}

class CreateCategory implements UseCase<Category, String> {
  final CategoryRepository repository;
  const CreateCategory(this.repository);

  @override
  Future<Either<Failure, Category>> call(String name) async {
    final clean = _clean(name);
    final invalid = _validate(clean);
    if (invalid != null) return left(invalid);

    return repository.create(clean);
  }
}

class RenameCategoryParams {
  final String id;
  final String name;

  const RenameCategoryParams({required this.id, required this.name});
}

class RenameCategory implements UseCase<Category, RenameCategoryParams> {
  final CategoryRepository repository;
  const RenameCategory(this.repository);

  @override
  Future<Either<Failure, Category>> call(RenameCategoryParams params) async {
    final clean = _clean(params.name);
    final invalid = _validate(clean);
    if (invalid != null) return left(invalid);

    return repository.rename(id: params.id, name: clean);
  }
}

class SetCategoryActiveParams {
  final String id;
  final bool isActive;

  const SetCategoryActiveParams({required this.id, required this.isActive});
}

class SetCategoryActive implements UseCase<Unit, SetCategoryActiveParams> {
  final CategoryRepository repository;
  const SetCategoryActive(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SetCategoryActiveParams params) =>
      repository.setActive(id: params.id, isActive: params.isActive);
}

class DeleteCategory implements UseCase<Unit, Category> {
  final CategoryRepository repository;
  const DeleteCategory(this.repository);

  /// Takes the whole Category, not just an id, so the guard can run
  /// here rather than after a round trip.
  @override
  Future<Either<Failure, Unit>> call(Category category) async {
    if (category.hasPeople) {
      return left(
        const ValidationFailure(
          'This category still has people in it. Turn it off instead, '
          'or move them first.',
        ),
      );
    }
    return repository.delete(category.id);
  }
}

class ReorderCategories implements UseCase<Unit, List<String>> {
  final CategoryRepository repository;
  const ReorderCategories(this.repository);

  @override
  Future<Either<Failure, Unit>> call(List<String> orderedIds) =>
      repository.reorder(orderedIds);
}

// ---------------------------------------------------------------------

/// Collapses internal whitespace too, so "Health  care" and
/// "Health care" cannot both exist.
String _clean(String raw) => raw.trim().replaceAll(RegExp(r'\s+'), ' ');

Failure? _validate(String name) {
  if (name.isEmpty) {
    return const ValidationFailure('Enter a category name.');
  }
  if (name.length > 40) {
    return const ValidationFailure('Keep it under 40 characters.');
  }
  return null;
}
