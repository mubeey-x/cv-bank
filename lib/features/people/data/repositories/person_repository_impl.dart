import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/exceptions.dart';
import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/error/guard.dart';
import '../../domain/entities/new_person.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/person_document.dart';
import '../../domain/entities/person_query.dart';
import '../../domain/entities/placement.dart';
import '../../domain/repositories/person_repository.dart';
import '../datasources/person_local_datasource.dart';
import '../datasources/person_remote_datasource.dart';

class PersonRepositoryImpl implements PersonRepository {
  final PersonRemoteDataSource remote;
  final PersonLocalDataSource local;

  const PersonRepositoryImpl({required this.remote, required this.local});

  // -------------------------------------------------------------------
  // People
  // -------------------------------------------------------------------

  /// Tries the network first and falls back to cache only on a network
  /// failure. Checking connectivity up front would add a probe to
  /// every call on the happy path, which is most of the time.
  @override
  Future<Either<Failure, List<Person>>> search(PersonQuery query) async {
    try {
      final people = await remote.search(query);

      // Only the first page is worth caching. Deep pages are a
      // filtered slice nobody returns to offline.
      if (query.offset == 0) {
        await local.cachePeople(people);
      }
      return right(people);
    } on NetworkException {
      final cached = await local.cachedPeople(
        categoryId: query.categoryId,
        limit: query.limit,
      );
      return cached.isEmpty ? left(const NetworkFailure()) : right(cached);
    } on AppException catch (e) {
      return left(e.toFailure());
    } catch (_) {
      return left(const UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Person>> getById(String id) =>
      guard(() => remote.getById(id));

  @override
  Future<Either<Failure, Person?>> findByPhone(String phone) =>
      guard(() => remote.findByPhone(phone));

  /// The duplicate index is (owner_id, phone_key), so a second entry
  /// with the same number throws 23505. The generic message does not
  /// help the user act, so it is replaced with one that does.
  @override
  Future<Either<Failure, Person>> add(NewPerson draft) async {
    try {
      final person = await remote.insert(draft);
      await local.cachePeople([person]);
      return right(person);
    } on DuplicateException {
      return left(
        const DuplicateFailure(
          'Someone with this phone number is already in your list.',
        ),
      );
    } on AppException catch (e) {
      return left(e.toFailure());
    } catch (_) {
      return left(const UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Person>> update(
    String id,
    PersonUpdate changes,
  ) async {
    try {
      final person = await remote.update(id, changes);
      await local.cachePeople([person]);
      return right(person);
    } on DuplicateException {
      return left(
        const DuplicateFailure('Another person already has that phone number.'),
      );
    } on AppException catch (e) {
      return left(e.toFailure());
    } catch (_) {
      return left(const UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> archive(String id) => guard(() async {
    await remote.archive(id);
    await local.removeCached(id);
    return unit;
  });

  // -------------------------------------------------------------------
  // Documents
  // -------------------------------------------------------------------

  @override
  Future<Either<Failure, List<PersonDocument>>> getDocuments(String personId) =>
      guard(() => remote.fetchDocuments(personId));

  @override
  Future<Either<Failure, PersonDocument>> uploadDocument({
    required String personId,
    required DocumentUpload upload,
  }) => guard(() => remote.uploadDocument(personId: personId, upload: upload));

  @override
  Future<Either<Failure, String>> getDocumentUrl(String storagePath) =>
      guard(() => remote.signedUrl(storagePath));

  /// Cache first, network second. A CV opened once opens instantly
  /// afterwards and still works with no connection.
  @override
  Future<Either<Failure, String>> getLocalDocument(
    PersonDocument document,
  ) async {
    try {
      final existing = await local.cachedFile(document.storagePath);
      if (existing != null) return right(existing.path);

      final bytes = await remote.downloadDocument(document.storagePath);
      final file = await local.writeFile(document.storagePath, bytes);
      return right(file.path);
    } on AppException catch (e) {
      return left(e.toFailure());
    } catch (_) {
      return left(const FileFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDocument(PersonDocument document) =>
      guard(() async {
        await remote.deleteDocument(document);
        return unit;
      });

  /// Extraction is a convenience, not a requirement. A failure here
  /// returns empty rather than an error, so the user simply types the
  /// two fields themselves instead of seeing a scary message.
  @override
  Future<Either<Failure, ExtractedDetails>> extractDetails(
    String storagePath,
  ) async {
    try {
      return right(await remote.extractDetails(storagePath));
    } catch (_) {
      return right(const ExtractedDetails());
    }
  }

  // -------------------------------------------------------------------
  // Placements
  // -------------------------------------------------------------------

  @override
  Future<Either<Failure, Placement>> markEmployed({
    required String personId,
    String? positionTitle,
    String? organisation,
    DateTime? startedOn,
  }) => guard(() async {
    final placement = await remote.insertPlacement(
      personId: personId,
      positionTitle: positionTitle,
      organisation: organisation,
      startedOn: startedOn,
    );
    // The cached row still says unemployed; drop it rather than
    // leave a stale badge on the offline list.
    await local.removeCached(personId);
    return placement;
  });

  @override
  Future<Either<Failure, Unit>> markUnemployed(String personId) =>
      guard(() async {
        await remote.endCurrentPlacement(personId);
        await local.removeCached(personId);
        return unit;
      });

  @override
  Future<Either<Failure, List<Placement>>> getPlacements(String personId) =>
      guard(() => remote.fetchPlacements(personId));
}
