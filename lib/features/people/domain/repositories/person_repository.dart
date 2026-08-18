import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/failures.dart';
import '../entities/new_person.dart';
import '../entities/person.dart';
import '../entities/person_document.dart';
import '../entities/person_query.dart';
import '../entities/placement.dart';

abstract interface class PersonRepository {
  Future<Either<Failure, List<Person>>> search(PersonQuery query);

  Future<Either<Failure, Person>> getById(String id);

  /// Returns the existing person when the phone number is already in
  /// the pool, so the UI can offer to open them instead of creating
  /// a duplicate.
  Future<Either<Failure, Person?>> findByPhone(String phone);

  Future<Either<Failure, Person>> add(NewPerson draft);

  Future<Either<Failure, Person>> update(String id, PersonUpdate changes);

  /// Soft delete. A record removed by mistake is painful to recover,
  /// so nothing is ever hard deleted from the app.
  Future<Either<Failure, Unit>> archive(String id);

  // ---- Documents ----

  Future<Either<Failure, List<PersonDocument>>> getDocuments(String personId);

  Future<Either<Failure, PersonDocument>> uploadDocument({
    required String personId,
    required DocumentUpload upload,
  });

  /// Signed URL for the viewer. Expires, so it is fetched on open
  /// rather than stored.
  Future<Either<Failure, String>> getDocumentUrl(String storagePath);

  /// Downloads and caches locally, so a file opened once opens
  /// instantly and works offline. Returns the local path.
  Future<Either<Failure, String>> getLocalDocument(PersonDocument document);

  Future<Either<Failure, Unit>> deleteDocument(PersonDocument document);

  /// Reads name, phone and email out of an uploaded file, for the
  /// intake pre-fill. Never saved without confirmation.
  Future<Either<Failure, ExtractedDetails>> extractDetails(String storagePath);

  // ---- Placements ----

  Future<Either<Failure, Placement>> markEmployed({
    required String personId,
    String? positionTitle,
    String? organisation,
    DateTime? startedOn,
  });

  /// Ends the current placement, which returns them to the pool.
  Future<Either<Failure, Unit>> markUnemployed(String personId);

  /// Full history, for the person detail screen.
  Future<Either<Failure, List<Placement>>> getPlacements(String personId);
}
