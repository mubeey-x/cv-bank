// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$personRemoteDataSourceHash() =>
    r'53d46afeb70cc1f65f30dbf7298cb79a8825efe2';

/// See also [personRemoteDataSource].
@ProviderFor(personRemoteDataSource)
final personRemoteDataSourceProvider =
    Provider<PersonRemoteDataSource>.internal(
      personRemoteDataSource,
      name: r'personRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$personRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PersonRemoteDataSourceRef = ProviderRef<PersonRemoteDataSource>;
String _$personLocalDataSourceHash() =>
    r'41381799d03dcda9438a0f99ee18e506976bee9c';

/// keepAlive because it holds an open sqflite connection. Recreating
/// it per screen would reopen the database each time.
///
/// Copied from [personLocalDataSource].
@ProviderFor(personLocalDataSource)
final personLocalDataSourceProvider = Provider<PersonLocalDataSource>.internal(
  personLocalDataSource,
  name: r'personLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$personLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PersonLocalDataSourceRef = ProviderRef<PersonLocalDataSource>;
String _$personRepositoryHash() => r'1194df5c6f8a041685ca3f0d1e62be093e9f6c1a';

/// See also [personRepository].
@ProviderFor(personRepository)
final personRepositoryProvider = Provider<PersonRepository>.internal(
  personRepository,
  name: r'personRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$personRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PersonRepositoryRef = ProviderRef<PersonRepository>;
String _$searchPeopleHash() => r'3d75009d16a759e2ce90d9cc8a69786c18ab4243';

/// See also [searchPeople].
@ProviderFor(searchPeople)
final searchPeopleProvider = AutoDisposeProvider<SearchPeople>.internal(
  searchPeople,
  name: r'searchPeopleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchPeopleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchPeopleRef = AutoDisposeProviderRef<SearchPeople>;
String _$getPersonHash() => r'bf7cc5d96531e4e85a39a4d66aa3578401e5b25c';

/// See also [getPerson].
@ProviderFor(getPerson)
final getPersonProvider = AutoDisposeProvider<GetPerson>.internal(
  getPerson,
  name: r'getPersonProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getPersonHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetPersonRef = AutoDisposeProviderRef<GetPerson>;
String _$findPersonByPhoneHash() => r'6eb201c3072613d4d1dac0a8563167e247e8f7d2';

/// See also [findPersonByPhone].
@ProviderFor(findPersonByPhone)
final findPersonByPhoneProvider =
    AutoDisposeProvider<FindPersonByPhone>.internal(
      findPersonByPhone,
      name: r'findPersonByPhoneProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$findPersonByPhoneHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FindPersonByPhoneRef = AutoDisposeProviderRef<FindPersonByPhone>;
String _$addPersonHash() => r'3ffac19f1e1f9a0eb85a0f065d0d4564b2b73a83';

/// See also [addPerson].
@ProviderFor(addPerson)
final addPersonProvider = AutoDisposeProvider<AddPerson>.internal(
  addPerson,
  name: r'addPersonProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$addPersonHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddPersonRef = AutoDisposeProviderRef<AddPerson>;
String _$updatePersonHash() => r'5a54ddd6676cbd1df6c206228f62b5133336420d';

/// See also [updatePerson].
@ProviderFor(updatePerson)
final updatePersonProvider = AutoDisposeProvider<UpdatePerson>.internal(
  updatePerson,
  name: r'updatePersonProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updatePersonHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdatePersonRef = AutoDisposeProviderRef<UpdatePerson>;
String _$archivePersonHash() => r'ac5946e90e14e3cce105ce17ccb34d7873303ef9';

/// See also [archivePerson].
@ProviderFor(archivePerson)
final archivePersonProvider = AutoDisposeProvider<ArchivePerson>.internal(
  archivePerson,
  name: r'archivePersonProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$archivePersonHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ArchivePersonRef = AutoDisposeProviderRef<ArchivePerson>;
String _$getDocumentsHash() => r'1235657ad2a92fea0ec1acf69a2bbaf09f522901';

/// See also [getDocuments].
@ProviderFor(getDocuments)
final getDocumentsProvider = AutoDisposeProvider<GetDocuments>.internal(
  getDocuments,
  name: r'getDocumentsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getDocumentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetDocumentsRef = AutoDisposeProviderRef<GetDocuments>;
String _$uploadDocumentHash() => r'9dfbd9cdd9643b4bfe202bc50ffcc185d0f2d284';

/// See also [uploadDocument].
@ProviderFor(uploadDocument)
final uploadDocumentProvider = AutoDisposeProvider<UploadDocument>.internal(
  uploadDocument,
  name: r'uploadDocumentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$uploadDocumentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UploadDocumentRef = AutoDisposeProviderRef<UploadDocument>;
String _$getLocalDocumentHash() => r'1ac5933c29338b6529c546d1646cbfa3e3a4fb94';

/// See also [getLocalDocument].
@ProviderFor(getLocalDocument)
final getLocalDocumentProvider = AutoDisposeProvider<GetLocalDocument>.internal(
  getLocalDocument,
  name: r'getLocalDocumentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getLocalDocumentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetLocalDocumentRef = AutoDisposeProviderRef<GetLocalDocument>;
String _$deleteDocumentHash() => r'2e214b8e574de8597f7b9c1ac084169ae8b0116c';

/// See also [deleteDocument].
@ProviderFor(deleteDocument)
final deleteDocumentProvider = AutoDisposeProvider<DeleteDocument>.internal(
  deleteDocument,
  name: r'deleteDocumentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteDocumentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteDocumentRef = AutoDisposeProviderRef<DeleteDocument>;
String _$extractDetailsHash() => r'577516a7aee62f2b036492e8eb137f78056a7c3a';

/// See also [extractDetails].
@ProviderFor(extractDetails)
final extractDetailsProvider = AutoDisposeProvider<ExtractDetails>.internal(
  extractDetails,
  name: r'extractDetailsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$extractDetailsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExtractDetailsRef = AutoDisposeProviderRef<ExtractDetails>;
String _$markEmployedHash() => r'2b63675766c7f8c748f320b9da956f2095b7bea3';

/// See also [markEmployed].
@ProviderFor(markEmployed)
final markEmployedProvider = AutoDisposeProvider<MarkEmployed>.internal(
  markEmployed,
  name: r'markEmployedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$markEmployedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MarkEmployedRef = AutoDisposeProviderRef<MarkEmployed>;
String _$markUnemployedHash() => r'658a5c0686e5c8dc06413ec7fcc79a409aba5b00';

/// See also [markUnemployed].
@ProviderFor(markUnemployed)
final markUnemployedProvider = AutoDisposeProvider<MarkUnemployed>.internal(
  markUnemployed,
  name: r'markUnemployedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$markUnemployedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MarkUnemployedRef = AutoDisposeProviderRef<MarkUnemployed>;
String _$getPlacementsHash() => r'28d655760131b88168ac879051bc5f7732373577';

/// See also [getPlacements].
@ProviderFor(getPlacements)
final getPlacementsProvider = AutoDisposeProvider<GetPlacements>.internal(
  getPlacements,
  name: r'getPlacementsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getPlacementsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetPlacementsRef = AutoDisposeProviderRef<GetPlacements>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
