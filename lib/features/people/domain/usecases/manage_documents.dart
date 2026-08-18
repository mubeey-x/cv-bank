import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/usecase/usecase.dart';
import '../entities/person_document.dart';
import '../repositories/person_repository.dart';

/// Storage is capped on the free tier and a phone camera can produce
/// a 12MB photo, so the limit is enforced before upload rather than
/// discovered afterwards.
const int kMaxDocumentBytes = 10 * 1024 * 1024;

class GetDocuments implements UseCase<List<PersonDocument>, String> {
  final PersonRepository repository;
  const GetDocuments(this.repository);

  @override
  Future<Either<Failure, List<PersonDocument>>> call(String personId) =>
      repository.getDocuments(personId);
}

class UploadDocumentParams {
  final String personId;
  final DocumentUpload upload;
  final int? sizeBytes;

  const UploadDocumentParams({
    required this.personId,
    required this.upload,
    this.sizeBytes,
  });
}

class UploadDocument implements UseCase<PersonDocument, UploadDocumentParams> {
  final PersonRepository repository;
  const UploadDocument(this.repository);

  @override
  Future<Either<Failure, PersonDocument>> call(
    UploadDocumentParams params,
  ) async {
    final size = params.sizeBytes;
    if (size != null && size > kMaxDocumentBytes) {
      return left(
        const ValidationFailure('That file is too large. Maximum is 10MB.'),
      );
    }
    return repository.uploadDocument(
      personId: params.personId,
      upload: params.upload,
    );
  }
}

class GetLocalDocument implements UseCase<String, PersonDocument> {
  final PersonRepository repository;
  const GetLocalDocument(this.repository);

  @override
  Future<Either<Failure, String>> call(PersonDocument document) =>
      repository.getLocalDocument(document);
}

class DeleteDocument implements UseCase<Unit, PersonDocument> {
  final PersonRepository repository;
  const DeleteDocument(this.repository);

  @override
  Future<Either<Failure, Unit>> call(PersonDocument document) =>
      repository.deleteDocument(document);
}

class ExtractDetails implements UseCase<ExtractedDetails, String> {
  final PersonRepository repository;
  const ExtractDetails(this.repository);

  @override
  Future<Either<Failure, ExtractedDetails>> call(String storagePath) =>
      repository.extractDetails(storagePath);
}
