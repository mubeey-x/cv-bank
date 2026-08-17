import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/failures.dart';
import '../entities/category.dart';

abstract interface class CategoryRepository {
  /// Active categories with their counts, for the categories tab.
  Future<Either<Failure, List<Category>>> getCategories({
    bool includeInactive = false,
  });

  /// Names only, no counts. Used by the intake chips, where the
  /// count query would be wasted work on the screen that most needs
  /// to be fast.
  Future<Either<Failure, List<Category>>> getActiveNames();

  Future<Either<Failure, Category>> create(String name);

  Future<Either<Failure, Category>> rename({
    required String id,
    required String name,
  });

  /// Hides it from new entries without touching anyone already in it.
  Future<Either<Failure, Unit>> setActive({
    required String id,
    required bool isActive,
  });

  /// Only permitted when the category is empty. The repository
  /// checks; the database would otherwise just null out the
  /// category_id on everyone in it.
  Future<Either<Failure, Unit>> delete(String id);

  Future<Either<Failure, Unit>> reorder(List<String> orderedIds);
}
