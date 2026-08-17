import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/exceptions.dart';
import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/error/guard.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remote;
  const CategoryRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<Category>>> getCategories({
    bool includeInactive = false,
  }) => guard(() => remote.fetchWithCounts(includeInactive: includeInactive));

  @override
  Future<Either<Failure, List<Category>>> getActiveNames() =>
      guard(() => remote.fetchActiveNames());

  @override
  Future<Either<Failure, Category>> create(String name) =>
      _guardName(() => remote.insert(name), name);

  @override
  Future<Either<Failure, Category>> rename({
    required String id,
    required String name,
  }) => _guardName(() => remote.rename(id, name), name);

  @override
  Future<Either<Failure, Unit>> setActive({
    required String id,
    required bool isActive,
  }) => guard(() async {
    await remote.setActive(id, isActive);
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> delete(String id) => guard(() async {
    await remote.delete(id);
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> reorder(List<String> orderedIds) =>
      guard(() async {
        await remote.reorder(orderedIds);
        return unit;
      });

  /// The (owner_id, name) unique index fires on a duplicate. The
  /// generic DuplicateFailure message is about people, so name it
  /// properly here.
  Future<Either<Failure, Category>> _guardName<T extends Category>(
    Future<T> Function() action,
    String name,
  ) async {
    try {
      return right(await action());
    } on DuplicateException {
      return left(ValidationFailure('You already have a "$name" category.'));
    } on AppException catch (e) {
      return left(e.toFailure());
    } catch (_) {
      return left(const UnknownFailure());
    }
  }
}
