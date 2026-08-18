// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$personDetailHash() => r'4c24892211ee84de2dfa992bcd4694a74f6889de';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [personDetail].
@ProviderFor(personDetail)
const personDetailProvider = PersonDetailFamily();

/// See also [personDetail].
class PersonDetailFamily extends Family<AsyncValue<Person>> {
  /// See also [personDetail].
  const PersonDetailFamily();

  /// See also [personDetail].
  PersonDetailProvider call(String id) {
    return PersonDetailProvider(id);
  }

  @override
  PersonDetailProvider getProviderOverride(
    covariant PersonDetailProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'personDetailProvider';
}

/// See also [personDetail].
class PersonDetailProvider extends AutoDisposeFutureProvider<Person> {
  /// See also [personDetail].
  PersonDetailProvider(String id)
    : this._internal(
        (ref) => personDetail(ref as PersonDetailRef, id),
        from: personDetailProvider,
        name: r'personDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$personDetailHash,
        dependencies: PersonDetailFamily._dependencies,
        allTransitiveDependencies:
            PersonDetailFamily._allTransitiveDependencies,
        id: id,
      );

  PersonDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Person> Function(PersonDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PersonDetailProvider._internal(
        (ref) => create(ref as PersonDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Person> createElement() {
    return _PersonDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PersonDetailRef on AutoDisposeFutureProviderRef<Person> {
  /// The parameter `id` of this provider.
  String get id;
}

class _PersonDetailProviderElement
    extends AutoDisposeFutureProviderElement<Person>
    with PersonDetailRef {
  _PersonDetailProviderElement(super.provider);

  @override
  String get id => (origin as PersonDetailProvider).id;
}

String _$personDocumentsHash() => r'9840edaa0ed57e69cae0dae939c122b7c5c60c31';

/// See also [personDocuments].
@ProviderFor(personDocuments)
const personDocumentsProvider = PersonDocumentsFamily();

/// See also [personDocuments].
class PersonDocumentsFamily extends Family<AsyncValue<List<PersonDocument>>> {
  /// See also [personDocuments].
  const PersonDocumentsFamily();

  /// See also [personDocuments].
  PersonDocumentsProvider call(String personId) {
    return PersonDocumentsProvider(personId);
  }

  @override
  PersonDocumentsProvider getProviderOverride(
    covariant PersonDocumentsProvider provider,
  ) {
    return call(provider.personId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'personDocumentsProvider';
}

/// See also [personDocuments].
class PersonDocumentsProvider
    extends AutoDisposeFutureProvider<List<PersonDocument>> {
  /// See also [personDocuments].
  PersonDocumentsProvider(String personId)
    : this._internal(
        (ref) => personDocuments(ref as PersonDocumentsRef, personId),
        from: personDocumentsProvider,
        name: r'personDocumentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$personDocumentsHash,
        dependencies: PersonDocumentsFamily._dependencies,
        allTransitiveDependencies:
            PersonDocumentsFamily._allTransitiveDependencies,
        personId: personId,
      );

  PersonDocumentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.personId,
  }) : super.internal();

  final String personId;

  @override
  Override overrideWith(
    FutureOr<List<PersonDocument>> Function(PersonDocumentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PersonDocumentsProvider._internal(
        (ref) => create(ref as PersonDocumentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        personId: personId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PersonDocument>> createElement() {
    return _PersonDocumentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonDocumentsProvider && other.personId == personId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, personId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PersonDocumentsRef on AutoDisposeFutureProviderRef<List<PersonDocument>> {
  /// The parameter `personId` of this provider.
  String get personId;
}

class _PersonDocumentsProviderElement
    extends AutoDisposeFutureProviderElement<List<PersonDocument>>
    with PersonDocumentsRef {
  _PersonDocumentsProviderElement(super.provider);

  @override
  String get personId => (origin as PersonDocumentsProvider).personId;
}

String _$personPlacementsHash() => r'96bcd5140217eb097f6cc8954225ce80c2a1a6b6';

/// See also [personPlacements].
@ProviderFor(personPlacements)
const personPlacementsProvider = PersonPlacementsFamily();

/// See also [personPlacements].
class PersonPlacementsFamily extends Family<AsyncValue<List<Placement>>> {
  /// See also [personPlacements].
  const PersonPlacementsFamily();

  /// See also [personPlacements].
  PersonPlacementsProvider call(String personId) {
    return PersonPlacementsProvider(personId);
  }

  @override
  PersonPlacementsProvider getProviderOverride(
    covariant PersonPlacementsProvider provider,
  ) {
    return call(provider.personId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'personPlacementsProvider';
}

/// See also [personPlacements].
class PersonPlacementsProvider
    extends AutoDisposeFutureProvider<List<Placement>> {
  /// See also [personPlacements].
  PersonPlacementsProvider(String personId)
    : this._internal(
        (ref) => personPlacements(ref as PersonPlacementsRef, personId),
        from: personPlacementsProvider,
        name: r'personPlacementsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$personPlacementsHash,
        dependencies: PersonPlacementsFamily._dependencies,
        allTransitiveDependencies:
            PersonPlacementsFamily._allTransitiveDependencies,
        personId: personId,
      );

  PersonPlacementsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.personId,
  }) : super.internal();

  final String personId;

  @override
  Override overrideWith(
    FutureOr<List<Placement>> Function(PersonPlacementsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PersonPlacementsProvider._internal(
        (ref) => create(ref as PersonPlacementsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        personId: personId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Placement>> createElement() {
    return _PersonPlacementsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonPlacementsProvider && other.personId == personId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, personId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PersonPlacementsRef on AutoDisposeFutureProviderRef<List<Placement>> {
  /// The parameter `personId` of this provider.
  String get personId;
}

class _PersonPlacementsProviderElement
    extends AutoDisposeFutureProviderElement<List<Placement>>
    with PersonPlacementsRef {
  _PersonPlacementsProviderElement(super.provider);

  @override
  String get personId => (origin as PersonPlacementsProvider).personId;
}

String _$documentFileHash() => r'510d4b467936b57665cae551ac57b07b2b556199';

/// Local path to a cached copy of the file, downloading it if this is
/// the first open.
///
/// Copied from [documentFile].
@ProviderFor(documentFile)
const documentFileProvider = DocumentFileFamily();

/// Local path to a cached copy of the file, downloading it if this is
/// the first open.
///
/// Copied from [documentFile].
class DocumentFileFamily extends Family<AsyncValue<String>> {
  /// Local path to a cached copy of the file, downloading it if this is
  /// the first open.
  ///
  /// Copied from [documentFile].
  const DocumentFileFamily();

  /// Local path to a cached copy of the file, downloading it if this is
  /// the first open.
  ///
  /// Copied from [documentFile].
  DocumentFileProvider call(PersonDocument document) {
    return DocumentFileProvider(document);
  }

  @override
  DocumentFileProvider getProviderOverride(
    covariant DocumentFileProvider provider,
  ) {
    return call(provider.document);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'documentFileProvider';
}

/// Local path to a cached copy of the file, downloading it if this is
/// the first open.
///
/// Copied from [documentFile].
class DocumentFileProvider extends AutoDisposeFutureProvider<String> {
  /// Local path to a cached copy of the file, downloading it if this is
  /// the first open.
  ///
  /// Copied from [documentFile].
  DocumentFileProvider(PersonDocument document)
    : this._internal(
        (ref) => documentFile(ref as DocumentFileRef, document),
        from: documentFileProvider,
        name: r'documentFileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$documentFileHash,
        dependencies: DocumentFileFamily._dependencies,
        allTransitiveDependencies:
            DocumentFileFamily._allTransitiveDependencies,
        document: document,
      );

  DocumentFileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.document,
  }) : super.internal();

  final PersonDocument document;

  @override
  Override overrideWith(
    FutureOr<String> Function(DocumentFileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocumentFileProvider._internal(
        (ref) => create(ref as DocumentFileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        document: document,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _DocumentFileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentFileProvider && other.document == document;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, document.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocumentFileRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `document` of this provider.
  PersonDocument get document;
}

class _DocumentFileProviderElement
    extends AutoDisposeFutureProviderElement<String>
    with DocumentFileRef {
  _DocumentFileProviderElement(super.provider);

  @override
  PersonDocument get document => (origin as DocumentFileProvider).document;
}

String _$personFiltersHash() => r'a3abdd68e55a4558ffe31124f0ff6414c8d0fdad';

/// See also [PersonFilters].
@ProviderFor(PersonFilters)
final personFiltersProvider =
    AutoDisposeNotifierProvider<PersonFilters, PersonQuery>.internal(
      PersonFilters.new,
      name: r'personFiltersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$personFiltersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PersonFilters = AutoDisposeNotifier<PersonQuery>;
String _$personListControllerHash() =>
    r'3bc9ae292c036e5e95214f55cbb01097e5f65cba';

/// See also [PersonListController].
@ProviderFor(PersonListController)
final personListControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      PersonListController,
      PersonListState
    >.internal(
      PersonListController.new,
      name: r'personListControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$personListControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PersonListController = AutoDisposeAsyncNotifier<PersonListState>;
String _$intakeControllerHash() => r'53c8fc54d834e71adc369b97782e619ac9c9eab4';

/// See also [IntakeController].
@ProviderFor(IntakeController)
final intakeControllerProvider =
    AutoDisposeNotifierProvider<IntakeController, IntakeState>.internal(
      IntakeController.new,
      name: r'intakeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$intakeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$IntakeController = AutoDisposeNotifier<IntakeState>;
String _$personActionsHash() => r'67df8eddf394834249fb6cfab6131f8ca4f2f55a';

/// See also [PersonActions].
@ProviderFor(PersonActions)
final personActionsProvider =
    AutoDisposeNotifierProvider<PersonActions, bool>.internal(
      PersonActions.new,
      name: r'personActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$personActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PersonActions = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
