import 'package:cv_bank/core/provider/supabase_provider.dart';
import 'package:cv_bank/features/people/data/repositories/person_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cv_bank/features/people/data/datasources/person_local_datasource.dart';
import 'package:cv_bank/features/people/data/datasources/person_remote_datasource.dart';
import 'package:cv_bank/features/people/domain/repositories/person_repository.dart';
import 'package:cv_bank/features/people/domain/usecases/manage_documents.dart';
import 'package:cv_bank/features/people/domain/usecases/manage_people.dart';
import 'package:cv_bank/features/people/domain/usecases/manage_placements.dart';

part 'person_providers.g.dart';

// ============================================================================
// DATA LAYER
// ============================================================================

@Riverpod(keepAlive: true)
PersonRemoteDataSource personRemoteDataSource(Ref ref) {
  return PersonSupabaseDataSource(ref.watch(supabaseProvider));
}

/// keepAlive because it holds an open sqflite connection. Recreating
/// it per screen would reopen the database each time.
@Riverpod(keepAlive: true)
PersonLocalDataSource personLocalDataSource(Ref ref) {
  return PersonSqfliteDataSource();
}

@Riverpod(keepAlive: true)
PersonRepository personRepository(Ref ref) {
  return PersonRepositoryImpl(
    remote: ref.watch(personRemoteDataSourceProvider),
    local: ref.watch(personLocalDataSourceProvider),
  );
}

// ============================================================================
// DOMAIN LAYER (Use Cases)
// ============================================================================

@riverpod
SearchPeople searchPeople(Ref ref) =>
    SearchPeople(ref.watch(personRepositoryProvider));

@riverpod
GetPerson getPerson(Ref ref) => GetPerson(ref.watch(personRepositoryProvider));

@riverpod
FindPersonByPhone findPersonByPhone(Ref ref) =>
    FindPersonByPhone(ref.watch(personRepositoryProvider));

@riverpod
AddPerson addPerson(Ref ref) => AddPerson(ref.watch(personRepositoryProvider));

@riverpod
UpdatePerson updatePerson(Ref ref) =>
    UpdatePerson(ref.watch(personRepositoryProvider));

@riverpod
ArchivePerson archivePerson(Ref ref) =>
    ArchivePerson(ref.watch(personRepositoryProvider));

// ---- Documents ----

@riverpod
GetDocuments getDocuments(Ref ref) =>
    GetDocuments(ref.watch(personRepositoryProvider));

@riverpod
UploadDocument uploadDocument(Ref ref) =>
    UploadDocument(ref.watch(personRepositoryProvider));

@riverpod
GetLocalDocument getLocalDocument(Ref ref) =>
    GetLocalDocument(ref.watch(personRepositoryProvider));

@riverpod
DeleteDocument deleteDocument(Ref ref) =>
    DeleteDocument(ref.watch(personRepositoryProvider));

@riverpod
ExtractDetails extractDetails(Ref ref) =>
    ExtractDetails(ref.watch(personRepositoryProvider));

// ---- Placements ----

@riverpod
MarkEmployed markEmployed(Ref ref) =>
    MarkEmployed(ref.watch(personRepositoryProvider));

@riverpod
MarkUnemployed markUnemployed(Ref ref) =>
    MarkUnemployed(ref.watch(personRepositoryProvider));

@riverpod
GetPlacements getPlacements(Ref ref) =>
    GetPlacements(ref.watch(personRepositoryProvider));
