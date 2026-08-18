import 'dart:async';

import 'package:cv_bank/features/people/data/provider/person_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/features/categories/presentation/controllers/category_controller.dart';
import 'package:cv_bank/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:cv_bank/features/people/domain/entities/new_person.dart';
import 'package:cv_bank/features/people/domain/entities/person.dart';
import 'package:cv_bank/features/people/domain/entities/person_document.dart';
import 'package:cv_bank/features/people/domain/entities/person_query.dart';
import 'package:cv_bank/features/people/domain/entities/placement.dart';
import 'package:cv_bank/features/people/domain/usecases/manage_documents.dart';
import 'package:cv_bank/features/people/domain/usecases/manage_people.dart';
import 'package:cv_bank/features/people/domain/usecases/manage_placements.dart';

part 'person_controller.g.dart';

// =====================================================================
// Filters
//
// Held separately from the list so changing a filter is a cheap state
// write, and the list rebuilds by watching this.
// =====================================================================

@riverpod
class PersonFilters extends _$PersonFilters {
  @override
  PersonQuery build() => const PersonQuery();

  Timer? _debounce;

  /// Typing fires on every keystroke, so the query only updates once
  /// the user pauses. Without this, a five-letter name is five
  /// requests.
  void setSearch(String term) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      state = term.trim().isEmpty
          ? state.copyWith(clearSearch: true, offset: 0)
          : state.copyWith(search: term.trim(), offset: 0);
    });
    ref.onDispose(() => _debounce?.cancel());
  }

  void setCategory(String? id) => state = id == null
      ? state.copyWith(clearCategory: true, offset: 0)
      : state.copyWith(categoryId: id, offset: 0);

  void setStatus(EmploymentStatus? status) => state = status == null
      ? state.copyWith(clearStatus: true, offset: 0)
      : state.copyWith(status: status, offset: 0);

  void setRelationship(RelationshipTier? tier) => state = tier == null
      ? state.copyWith(clearRelationship: true, offset: 0)
      : state.copyWith(relationship: tier, offset: 0);

  void setQualification(QualificationLevel? q) => state = q == null
      ? state.copyWith(clearQualification: true, offset: 0)
      : state.copyWith(qualification: q, offset: 0);

  void clearAll() => state = PersonQuery(search: state.search);
}

// =====================================================================
// List
// =====================================================================

class PersonListState {
  final List<Person> people;
  final bool hasMore;
  final bool isLoadingMore;

  const PersonListState({
    required this.people,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  PersonListState copyWith({
    List<Person>? people,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PersonListState(
      people: people ?? this.people,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

@riverpod
class PersonListController extends _$PersonListController {
  @override
  Future<PersonListState> build() async {
    // Rebuilds whenever any filter changes.
    final query = ref.watch(personFiltersProvider);

    final result = await ref.read(searchPeopleProvider).call(query);
    return result.fold(
      (failure) => throw failure,
      (people) => PersonListState(
        people: people,
        // A full page back means there is probably another.
        hasMore: people.length >= query.limit,
      ),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final query = ref
        .read(personFiltersProvider)
        .copyWith(offset: current.people.length);

    final result = await ref.read(searchPeopleProvider).call(query);

    state = result.fold(
      (_) => AsyncData(current.copyWith(isLoadingMore: false)),
      (more) => AsyncData(
        current.copyWith(
          people: [...current.people, ...more],
          hasMore: more.length >= query.limit,
          isLoadingMore: false,
        ),
      ),
    );
  }
}

// =====================================================================
// Detail
// =====================================================================

@riverpod
Future<Person> personDetail(Ref ref, String id) async {
  final result = await ref.watch(getPersonProvider).call(id);
  return result.fold((f) => throw f, (person) => person);
}

@riverpod
Future<List<PersonDocument>> personDocuments(Ref ref, String personId) async {
  final result = await ref.watch(getDocumentsProvider).call(personId);
  return result.fold((f) => throw f, (docs) => docs);
}

@riverpod
Future<List<Placement>> personPlacements(Ref ref, String personId) async {
  final result = await ref.watch(getPlacementsProvider).call(personId);
  return result.fold((f) => throw f, (list) => list);
}

/// Local path to a cached copy of the file, downloading it if this is
/// the first open.
@riverpod
Future<String> documentFile(Ref ref, PersonDocument document) async {
  final result = await ref.watch(getLocalDocumentProvider).call(document);
  return result.fold((f) => throw f, (path) => path);
}

// =====================================================================
// Intake
// =====================================================================

class IntakeState {
  final String? storagePath;
  final String? fileName;
  final bool isUploading;
  final bool isExtracting;
  final ExtractedDetails? extracted;
  final Person? duplicate;

  const IntakeState({
    this.storagePath,
    this.fileName,
    this.isUploading = false,
    this.isExtracting = false,
    this.extracted,
    this.duplicate,
  });

  IntakeState copyWith({
    String? storagePath,
    String? fileName,
    bool? isUploading,
    bool? isExtracting,
    ExtractedDetails? extracted,
    Person? duplicate,
    bool clearDuplicate = false,
  }) {
    return IntakeState(
      storagePath: storagePath ?? this.storagePath,
      fileName: fileName ?? this.fileName,
      isUploading: isUploading ?? this.isUploading,
      isExtracting: isExtracting ?? this.isExtracting,
      extracted: extracted ?? this.extracted,
      duplicate: clearDuplicate ? null : (duplicate ?? this.duplicate),
    );
  }

  bool get hasFile => fileName != null;
  bool get isBusy => isUploading || isExtracting;
}

@riverpod
class IntakeController extends _$IntakeController {
  @override
  IntakeState build() => const IntakeState();

  Timer? _phoneDebounce;

  /// The picked file, held on the phone until the person row exists.
  DocumentUpload? _pending;
  int? _pendingSize;

  DocumentUpload? get pendingUpload => _pending;
  int? get pendingSize => _pendingSize;

  /// Checks for an existing person as the number is typed, so a
  /// duplicate is caught before the user finishes filling the form
  /// rather than after they hit save.
  void checkPhone(String phone) {
    _phoneDebounce?.cancel();
    if (phone.trim().length < 7) {
      state = state.copyWith(clearDuplicate: true);
      return;
    }

    _phoneDebounce = Timer(const Duration(milliseconds: 500), () async {
      final result = await ref.read(findPersonByPhoneProvider).call(phone);
      result.fold(
        (_) {},
        (person) => state = person == null
            ? state.copyWith(clearDuplicate: true)
            : state.copyWith(duplicate: person),
      );
    });
    ref.onDispose(() => _phoneDebounce?.cancel());
  }

  /// Remembers the file only. Nothing is uploaded here: a document
  /// row needs a real person_id, and the person does not exist yet.
  /// The upload happens in _save() once we have an id.
  void attachFile(DocumentUpload upload, int? sizeBytes) {
    _pending = upload;
    _pendingSize = sizeBytes;
    state = state.copyWith(fileName: upload.fileName);
  }

  void reset() {
    _pending = null;
    _pendingSize = null;
    state = const IntakeState();
  }
}

/// The file lands in storage before the person exists, so it goes
/// under a temp folder and is re-linked once we have an id.

//   Future<Failure?> attachAndExtract(
//     DocumentUpload upload,
//     int? sizeBytes,
//   ) async {
//     state = state.copyWith(isUploading: true, fileName: upload.fileName);
//     debugPrint('INTAKE: staging ${upload.fileName} at ${upload.filePath}');
//     // Uploaded against a placeholder person id; the real link is made
//     // in save() once the row exists.
//     final uploadResult = await ref
//         .read(uploadDocumentProvider)
//         .call(
//           UploadDocumentParams(
//             personId: 'staging',
//             upload: upload,
//             sizeBytes: sizeBytes,
//           ),
//         );

//     return uploadResult.fold(
//           (failure) {
//             state = const IntakeState();
//             return failure;
//           },
//           (document) async {
//             state = state.copyWith(
//               isUploading: false,
//               isExtracting: true,
//               storagePath: document.storagePath,
//             );

//             final extractResult = await ref
//                 .read(extractDetailsProvider)
//                 .call(document.storagePath);

//             state = extractResult.fold(
//               (_) => state.copyWith(isExtracting: false),
//               (details) =>
//                   state.copyWith(isExtracting: false, extracted: details),
//             );
//             return null;
//           },
//         )
//         as Failure?;
//   }

//   void reset() => state = const IntakeState();
// }

// =====================================================================
// Writes
// =====================================================================

@riverpod
class PersonActions extends _$PersonActions {
  @override
  bool build() => false; // isBusy

  Future<(Person?, Failure?)> add(NewPerson draft) async {
    state = true;
    final result = await ref.read(addPersonProvider).call(draft);
    state = false;

    return result.fold((failure) => (null, failure), (person) {
      _invalidateAll();
      return (person, null);
    });
  }

  Future<Failure?> update(String id, PersonUpdate changes) async {
    state = true;
    final result = await ref
        .read(updatePersonProvider)
        .call(UpdatePersonParams(id: id, changes: changes));
    state = false;

    return result.fold((failure) => failure, (_) {
      _invalidateAll();
      ref.invalidate(personDetailProvider(id));
      return null;
    });
  }

  Future<Failure?> archive(String id) async {
    state = true;
    final result = await ref.read(archivePersonProvider).call(id);
    state = false;

    return result.fold((f) => f, (_) {
      _invalidateAll();
      return null;
    });
  }

  Future<Failure?> markEmployed({
    required String personId,
    String? positionTitle,
    String? organisation,
  }) async {
    state = true;
    final result = await ref
        .read(markEmployedProvider)
        .call(
          MarkEmployedParams(
            personId: personId,
            positionTitle: positionTitle,
            organisation: organisation,
          ),
        );
    state = false;

    return result.fold((f) => f, (_) {
      _invalidateAll();
      ref.invalidate(personDetailProvider(personId));
      ref.invalidate(personPlacementsProvider(personId));
      return null;
    });
  }

  Future<Failure?> markUnemployed(String personId) async {
    state = true;
    final result = await ref.read(markUnemployedProvider).call(personId);
    state = false;

    return result.fold((f) => f, (_) {
      _invalidateAll();
      ref.invalidate(personDetailProvider(personId));
      ref.invalidate(personPlacementsProvider(personId));
      return null;
    });
  }

  Future<Failure?> attachDocument({
    required String personId,
    required DocumentUpload upload,
    int? sizeBytes,
  }) async {
    state = true;
    final result = await ref
        .read(uploadDocumentProvider)
        .call(
          UploadDocumentParams(
            personId: personId,
            upload: upload,
            sizeBytes: sizeBytes,
          ),
        );
    state = false;

    return result.fold((f) => f, (_) {
      ref.invalidate(personDocumentsProvider(personId));
      ref.invalidate(personDetailProvider(personId));
      return null;
    });
  }

  Future<Failure?> removeDocument(PersonDocument document) async {
    state = true;
    final result = await ref.read(deleteDocumentProvider).call(document);
    state = false;

    return result.fold((f) => f, (_) {
      ref.invalidate(personDocumentsProvider(document.personId));
      ref.invalidate(personDetailProvider(document.personId));
      return null;
    });
  }

  /// Any change to a person moves the counts on the categories tab
  /// and the dashboard, so all three refresh together.
  void _invalidateAll() {
    ref.invalidate(personListControllerProvider);
    ref.invalidate(categoryListControllerProvider);
    ref.invalidate(dashboardControllerProvider);
  }
}
