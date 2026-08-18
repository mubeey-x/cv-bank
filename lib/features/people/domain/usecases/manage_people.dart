import 'package:fpdart/fpdart.dart';

import 'package:cv_bank/core/error/failures.dart';
import 'package:cv_bank/core/usecase/usecase.dart';
import 'package:cv_bank/core/utils/phone_normalizer.dart';
import '../entities/new_person.dart';
import '../entities/person.dart';
import '../entities/person_query.dart';
import '../repositories/person_repository.dart';

class SearchPeople implements UseCase<List<Person>, PersonQuery> {
  final PersonRepository repository;
  const SearchPeople(this.repository);

  @override
  Future<Either<Failure, List<Person>>> call(PersonQuery query) =>
      repository.search(query);
}

class GetPerson implements UseCase<Person, String> {
  final PersonRepository repository;
  const GetPerson(this.repository);

  @override
  Future<Either<Failure, Person>> call(String id) => repository.getById(id);
}

class FindPersonByPhone implements UseCase<Person?, String> {
  final PersonRepository repository;
  const FindPersonByPhone(this.repository);

  @override
  Future<Either<Failure, Person?>> call(String phone) async {
    if (PhoneNormalizer.key(phone).isEmpty) return right(null);
    return repository.findByPhone(phone);
  }
}

class AddPerson implements UseCase<Person, NewPerson> {
  final PersonRepository repository;
  const AddPerson(this.repository);

  @override
  Future<Either<Failure, Person>> call(NewPerson draft) async {
    final name = draft.fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) {
      return left(const ValidationFailure('Enter a name.'));
    }

    final phone = draft.phone.trim();
    if (PhoneNormalizer.key(phone).isEmpty) {
      return left(const ValidationFailure('Enter a phone number.'));
    }

    // Deliberately not rejecting a phone that fails looksValid. The
    // whole intake design is about not slowing people down, and
    // prefix rules go stale. The database enforces uniqueness; this
    // only checks that something was entered.

    return repository.add(
      NewPerson(
        fullName: name,
        phone: phone,
        categoryId: draft.categoryId,
        email: draft.email?.trim(),
        qualification: draft.qualification,
        courseOfStudy: draft.courseOfStudy?.trim(),
        institution: draft.institution?.trim(),
        yearsExperience: draft.yearsExperience,
        currentOccupation: draft.currentOccupation?.trim(),
        referrerName: draft.referrerName?.trim(),
        channel: draft.channel,
        relationship: draft.relationship,
        notes: draft.notes?.trim(),
      ),
    );
  }
}

class UpdatePersonParams {
  final String id;
  final PersonUpdate changes;

  const UpdatePersonParams({required this.id, required this.changes});
}

class UpdatePerson implements UseCase<Person, UpdatePersonParams> {
  final PersonRepository repository;
  const UpdatePerson(this.repository);

  @override
  Future<Either<Failure, Person>> call(UpdatePersonParams params) async {
    final name = params.changes.fullName?.trim();
    if (name != null && name.isEmpty) {
      return left(const ValidationFailure('Name cannot be empty.'));
    }

    final phone = params.changes.phone?.trim();
    if (phone != null && PhoneNormalizer.key(phone).isEmpty) {
      return left(const ValidationFailure('Phone cannot be empty.'));
    }

    return repository.update(params.id, params.changes);
  }
}

class ArchivePerson implements UseCase<Unit, String> {
  final PersonRepository repository;
  const ArchivePerson(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String id) => repository.archive(id);
}
